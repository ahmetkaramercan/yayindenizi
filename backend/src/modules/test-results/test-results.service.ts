import { Injectable, NotFoundException, ConflictException, Logger } from '@nestjs/common';
import { PrismaService } from '@/prisma/prisma.service';
import { SubmitTestResultDto } from './dto';

@Injectable()
export class TestResultsService {
  private readonly logger = new Logger(TestResultsService.name);

  constructor(private prisma: PrismaService) {}

  async submit(userId: string, dto: SubmitTestResultDto) {
    const test = await this.prisma.test.findUnique({
      where: { id: dto.testId },
      include: { questions: true, section: true },
    });
    if (!test) throw new NotFoundException('Test bulunamadı');

    // Duplicate prevention: aynı öğrenci aynı testi tekrar gönderemez
    const existing = await this.prisma.result.findFirst({
      where: { userId, testId: dto.testId },
    });
    if (existing) {
      throw new ConflictException('Bu testi zaten çözdünüz. Her test yalnızca bir kez gönderilebilir.');
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

    await this.updateAnalytics(userId, test.sectionId);

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
}
