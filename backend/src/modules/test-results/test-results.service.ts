import { Injectable, NotFoundException, Logger } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '@/prisma/prisma.service';
import { SubmitTestResultDto } from './dto';
import { AnalyticsService } from '../analytics/analytics.service';

@Injectable()
export class TestResultsService {
  private readonly logger = new Logger(TestResultsService.name);

  constructor(
    private prisma: PrismaService,
    private analyticsService: AnalyticsService,
  ) {}

  async submit(userId: string, dto: SubmitTestResultDto) {
    const test = await this.prisma.test.findUnique({
      where: { id: dto.testId },
      include: {
        questions: {
          include: { questionOutcomes: { select: { learningOutcomeId: true } } },
        },
        section: true,
      },
    });
    if (!test) throw new NotFoundException('Test bulunamadı');

    const existing = await this.prisma.result.findFirst({
      where: { userId, testId: dto.testId },
      include: {
        answers: {
          include: { question: { select: { id: true, correctAnswerIndex: true, learningOutcomeId: true, orderIndex: true } } },
          orderBy: { question: { orderIndex: 'asc' } },
        },
        test: { select: { id: true, title: true, level: true, questions: true } },
      },
    });

    if (existing) {
      this.logger.log(`Returning existing result for student ${userId}, test ${dto.testId}`);
      const totalQuestions = existing.test.questions.length;
      const correctCount = existing.answers.filter((a) => a.isCorrect).length;
      const wrongCount = existing.answers.filter((a) => !a.isCorrect && a.selectedIndex != null).length;
      const emptyCount = totalQuestions - correctCount - wrongCount;

      return {
        resultId: existing.id,
        testId: existing.testId,
        testTitle: existing.test.title,
        score: Math.round(existing.score * 100) / 100,
        totalQuestions,
        correctCount,
        wrongCount,
        emptyCount,
        alreadySubmitted: true,
        answers: existing.answers.map((a) => ({
          questionId: a.questionId,
          selectedIndex: a.selectedIndex,
          correctAnswerIndex: a.question.correctAnswerIndex,
          isCorrect: a.isCorrect,
        })),
      };
    }

    const questionMap = new Map(test.questions.map((q) => [q.id, q]));

    let correctCount = 0;
    let wrongCount = 0;
    let emptyCount = 0;

    const answersData = dto.answers.map((a) => {
      const question = questionMap.get(a.questionId);
      const isCorrect = question != null && a.selectedIndex != null && a.selectedIndex === question.correctAnswerIndex;

      if (a.selectedIndex == null) {
        emptyCount++;
      } else if (isCorrect) {
        correctCount++;
      } else {
        wrongCount++;
      }

      return {
        questionId: a.questionId,
        selectedIndex: a.selectedIndex ?? null,
        isCorrect,
      };
    });

    const totalQuestions = test.questions.length;
    const score = totalQuestions > 0 ? (correctCount / totalQuestions) * 100 : 0;

    const result = await this.prisma.result.create({
      data: {
        userId,
        testId: dto.testId,
        totalTime: dto.totalTime,
        score,
        finishedAt: new Date(),
        answers: { create: answersData },
      },
      include: {
        answers: {
          include: { question: { select: { id: true, correctAnswerIndex: true, learningOutcomeId: true } } },
          orderBy: { question: { orderIndex: 'asc' } },
        },
        test: { select: { id: true, title: true, level: true } },
      },
    });

    this.logger.log(`Student ${userId} submitted test ${dto.testId}: ${correctCount}/${totalQuestions}`);

    const affectedOutcomeIds = [
      ...new Set(
        test.questions.flatMap((q) => {
          const ids: string[] = [];
          if (q.learningOutcomeId) ids.push(q.learningOutcomeId);
          ids.push(
            ...q.questionOutcomes.map((qo) => qo.learningOutcomeId),
          );
          return ids;
        }),
      ),
    ];

    await Promise.all([
      this.updateAnalytics(userId, test.sectionId),
      this.updateOutcomeAnalytics(userId, affectedOutcomeIds),
    ]);
    await this.analyticsService.invalidateUserCache(userId);

    return {
      resultId: result.id,
      testId: result.testId,
      testTitle: result.test.title,
      score: Math.round(score * 100) / 100,
      totalQuestions,
      correctCount,
      wrongCount,
      emptyCount,
      answers: result.answers.map((a) => ({
        questionId: a.questionId,
        selectedIndex: a.selectedIndex,
        correctAnswerIndex: a.question.correctAnswerIndex,
        isCorrect: a.isCorrect,
      })),
    };
  }

  async findByUser(userId: string, testId?: string) {
    return this.prisma.result.findMany({
      where: {
        userId,
        ...(testId ? { testId } : {}),
      },
      include: {
        test: { include: { section: { include: { book: true } } } },
        answers: {
          include: { question: { select: { id: true, correctAnswerIndex: true, learningOutcomeId: true } } },
          orderBy: { question: { orderIndex: 'asc' } },
        },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async findOne(id: string) {
    const result = await this.prisma.result.findUnique({
      where: { id },
      include: {
        test: {
          include: {
            section: { include: { book: true } },
          },
        },
        answers: {
          include: { question: { select: { id: true, correctAnswerIndex: true, learningOutcomeId: true, orderIndex: true } } },
          orderBy: { question: { orderIndex: 'asc' } },
        },
        user: { select: { id: true, adSoyad: true, email: true } },
      },
    });
    if (!result) throw new NotFoundException('Sonuç bulunamadı');
    return result;
  }

  async getUserHistory(userId: string, limit = 50) {
    return this.prisma.result.findMany({
      where: { userId },
      include: {
        test: { include: { section: { include: { book: true } } } },
      },
      orderBy: { createdAt: 'desc' },
      take: limit,
    });
  }

  private async updateAnalytics(userId: string, sectionId: string) {
    const results = await this.prisma.result.findMany({
      where: { userId, test: { sectionId } },
      include: { answers: true },
    });

    const totalTests = results.length;
    const totalQuestions = results.reduce((s, r) => s + r.answers.length, 0);
    const correctAnswers = results.reduce(
      (s, r) => s + r.answers.filter((a) => a.isCorrect).length,
      0,
    );
    const incorrectAnswers = totalQuestions - correctAnswers;
    const averageScore =
      totalTests > 0 ? results.reduce((s, r) => s + r.score, 0) / totalTests : 0;
    const bestScore = totalTests > 0 ? Math.max(...results.map((r) => r.score)) : 0;
    const totalTime = results.reduce((s, r) => s + r.totalTime, 0);
    const accuracy = totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0;

    await this.prisma.analytics.upsert({
      where: { userId_sectionId: { userId, sectionId } },
      update: {
        totalTests,
        totalQuestions,
        correctAnswers,
        incorrectAnswers,
        averageScore: Math.round(averageScore * 100) / 100,
        bestScore: Math.round(bestScore * 100) / 100,
        totalTime,
        accuracy: Math.round(accuracy * 100) / 100,
        lastAttemptAt: new Date(),
      },
      create: {
        userId,
        sectionId,
        totalTests,
        totalQuestions,
        correctAnswers,
        incorrectAnswers,
        averageScore: Math.round(averageScore * 100) / 100,
        bestScore: Math.round(bestScore * 100) / 100,
        totalTime,
        accuracy: Math.round(accuracy * 100) / 100,
        lastAttemptAt: new Date(),
      },
    });
  }

  private async updateOutcomeAnalytics(userId: string, learningOutcomeIds: string[]) {
    if (learningOutcomeIds.length === 0) return;

    // Hem questions.learning_outcome_id hem question_outcomes tablosunu kullan
    // (seed-outcomes QuestionOutcome ile bağlar, questions.learning_outcome_id kullanmaz)
    const rows = await this.prisma.$queryRaw<
      { learning_outcome_id: string; total: bigint; correct: bigint }[]
    >`
      SELECT outcome_id AS learning_outcome_id,
             COUNT(*)::bigint AS total,
             SUM(CASE WHEN is_correct THEN 1 ELSE 0 END)::bigint AS correct
      FROM (
        SELECT q.learning_outcome_id AS outcome_id, a.is_correct
        FROM answers a
        JOIN results r ON a.result_id = r.id
        JOIN questions q ON a.question_id = q.id
        WHERE r.user_id = ${userId}
          AND q.learning_outcome_id IN (${Prisma.join(learningOutcomeIds)})
        UNION ALL
        SELECT qo.learning_outcome_id AS outcome_id, a.is_correct
        FROM answers a
        JOIN results r ON a.result_id = r.id
        JOIN question_outcomes qo ON a.question_id = qo.question_id
        JOIN questions q ON a.question_id = q.id
        WHERE r.user_id = ${userId}
          AND q.learning_outcome_id IS NULL
          AND qo.learning_outcome_id IN (${Prisma.join(learningOutcomeIds)})
      ) sub
      GROUP BY outcome_id
    `;

    const now = new Date();

    await Promise.all(
      rows.map((row) => {
        const total = Number(row.total);
        const correct = Number(row.correct);
        const incorrect = total - correct;
        const accuracy = total > 0 ? Math.round((correct / total) * 10000) / 100 : 0;

        return this.prisma.outcomeAnalytics.upsert({
          where: {
            userId_learningOutcomeId: {
              userId,
              learningOutcomeId: row.learning_outcome_id,
            },
          },
          update: {
            totalQuestions: total,
            correctAnswers: correct,
            incorrectAnswers: incorrect,
            accuracy,
            lastAttemptAt: now,
          },
          create: {
            userId,
            learningOutcomeId: row.learning_outcome_id,
            totalQuestions: total,
            correctAnswers: correct,
            incorrectAnswers: incorrect,
            accuracy,
            lastAttemptAt: now,
          },
        });
      }),
    );
  }
}
