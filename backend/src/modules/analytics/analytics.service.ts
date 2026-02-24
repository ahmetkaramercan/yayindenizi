import {
  Injectable,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import { PrismaService } from '@/prisma/prisma.service';

export interface OutcomeStat {
  learningOutcomeId: string;
  code: string;
  learningOutcomeName: string;
  category: string;
  totalQuestions: number;
  correctAnswers: number;
  incorrectAnswers: number;
  accuracy: number;
}

export interface SectionStat {
  sectionId: string;
  sectionTitle: string;
  bookTitle: string;
  totalTests: number;
  averageScore: number;
  bestScore: number;
  accuracy: number;
  totalTime: number;
}

@Injectable()
export class AnalyticsService {
  constructor(private prisma: PrismaService) {}

  // ─── Helpers ────────────────────────────────────────────────────────────

  async verifyTeacherAccess(teacherId: string, studentId: string) {
    const relation = await this.prisma.teacherStudent.findUnique({
      where: { teacherId_studentId: { teacherId, studentId } },
    });
    if (!relation) {
      throw new ForbiddenException('Bu öğrenci sizinle bağlantılı değil');
    }
  }

  private async ensureUserExists(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { id: true },
    });
    if (!user) throw new NotFoundException('User not found');
  }

  // ─── Overview ───────────────────────────────────────────────────────────

  async getStudentOverview(userId: string, bookId?: string) {
    await this.ensureUserExists(userId);

    const where: { userId: string; section?: { bookId: string } } = { userId };
    if (bookId) {
      where.section = { bookId };
    }
    const analytics = await this.prisma.analytics.findMany({
      where,
    });

    if (analytics.length === 0) {
      return {
        totalTests: 0,
        averageScore: 0,
        totalQuestions: 0,
        totalCorrect: 0,
        totalIncorrect: 0,
        overallAccuracy: 0,
        totalTime: 0,
      };
    }

    const totalTests = analytics.reduce((s, a) => s + a.totalTests, 0);
    const totalQuestions = analytics.reduce((s, a) => s + a.totalQuestions, 0);
    const totalCorrect = analytics.reduce((s, a) => s + a.correctAnswers, 0);
    const totalIncorrect = analytics.reduce((s, a) => s + a.incorrectAnswers, 0);
    const totalTime = analytics.reduce((s, a) => s + a.totalTime, 0);

    const weightedScore = analytics.reduce(
      (s, a) => s + a.averageScore * a.totalTests,
      0,
    );
    const averageScore = totalTests > 0 ? weightedScore / totalTests : 0;
    const overallAccuracy =
      totalQuestions > 0 ? (totalCorrect / totalQuestions) * 100 : 0;

    return {
      totalTests,
      averageScore: Math.round(averageScore * 100) / 100,
      totalQuestions,
      totalCorrect,
      totalIncorrect,
      overallAccuracy: Math.round(overallAccuracy * 100) / 100,
      totalTime,
    };
  }

  // ─── Section stats ──────────────────────────────────────────────────────

  async getStudentSectionStats(userId: string, bookId?: string): Promise<SectionStat[]> {
    const where: { userId: string; section?: { bookId: string } } = { userId };
    if (bookId) where.section = { bookId };
    const analytics = await this.prisma.analytics.findMany({
      where,
      include: { section: { include: { book: true } } },
      orderBy: { accuracy: 'asc' },
    });

    return analytics.map((a) => ({
      sectionId: a.sectionId,
      sectionTitle: a.section.title,
      bookTitle: a.section.book.title,
      totalTests: a.totalTests,
      averageScore: a.averageScore,
      bestScore: a.bestScore,
      accuracy: a.accuracy,
      totalTime: a.totalTime,
    }));
  }

  // ─── Learning outcome stats (reads from materialized table) ─────────

  async getStudentLearningOutcomeStats(
    userId: string,
    bookId?: string,
  ): Promise<OutcomeStat[]> {
    const where: { userId: string; learningOutcome?: { bookId: string | null } } = { userId };
    if (bookId) {
      where.learningOutcome = { bookId };
    }
    const rows = await this.prisma.outcomeAnalytics.findMany({
      where,
      include: {
        learningOutcome: { select: { id: true, code: true, name: true, category: true } },
      },
      orderBy: { accuracy: 'asc' },
    });

    return rows.map((r) => ({
      learningOutcomeId: r.learningOutcomeId,
      code: r.learningOutcome.code,
      learningOutcomeName: r.learningOutcome.name,
      category: r.learningOutcome.category,
      totalQuestions: r.totalQuestions,
      correctAnswers: r.correctAnswers,
      incorrectAnswers: r.incorrectAnswers,
      accuracy: r.accuracy,
    }));
  }

  // ─── Outcome stats grouped by category ──────────────────────────────

  async getStudentOutcomesByCategory(userId: string, bookId?: string) {
    const stats = await this.getStudentLearningOutcomeStats(userId, bookId);

    const categoryMap = new Map<
      string,
      { total: number; correct: number; outcomes: number }
    >();

    for (const s of stats) {
      const existing = categoryMap.get(s.category);
      if (existing) {
        existing.total += s.totalQuestions;
        existing.correct += s.correctAnswers;
        existing.outcomes++;
      } else {
        categoryMap.set(s.category, {
          total: s.totalQuestions,
          correct: s.correctAnswers,
          outcomes: 1,
        });
      }
    }

    return Array.from(categoryMap.entries())
      .map(([category, data]) => ({
        category,
        outcomeCount: data.outcomes,
        totalQuestions: data.total,
        correctAnswers: data.correct,
        accuracy:
          data.total > 0
            ? Math.round((data.correct / data.total) * 10000) / 100
            : 0,
      }))
      .sort((a, b) => a.accuracy - b.accuracy);
  }

  // ─── Weak outcomes ──────────────────────────────────────────────────────

  async getStudentWeakOutcomes(
    userId: string,
    threshold = 50,
    bookId?: string,
  ): Promise<OutcomeStat[]> {
    const where: { userId: string; accuracy: { lt: number }; learningOutcome?: { bookId: string | null } } = {
      userId,
      accuracy: { lt: threshold },
    };
    if (bookId) where.learningOutcome = { bookId };
    const rows = await this.prisma.outcomeAnalytics.findMany({
      where,
      include: {
        learningOutcome: { select: { id: true, code: true, name: true, category: true } },
      },
      orderBy: { accuracy: 'asc' },
    });

    return rows.map((r) => ({
      learningOutcomeId: r.learningOutcomeId,
      code: r.learningOutcome.code,
      learningOutcomeName: r.learningOutcome.name,
      category: r.learningOutcome.category,
      totalQuestions: r.totalQuestions,
      correctAnswers: r.correctAnswers,
      incorrectAnswers: r.incorrectAnswers,
      accuracy: r.accuracy,
    }));
  }

  // ─── Progress over time ─────────────────────────────────────────────────

  async getStudentProgressOverTime(userId: string, bookId?: string) {
    const where: { userId: string; test?: { section: { bookId: string } } } = { userId };
    if (bookId) where.test = { section: { bookId } };
    const results = await this.prisma.result.findMany({
      where,
      select: {
        id: true,
        score: true,
        createdAt: true,
        test: { select: { title: true, level: true } },
      },
      orderBy: { createdAt: 'asc' },
    });

    return results.map((r) => ({
      id: r.id,
      score: r.score,
      date: r.createdAt,
      testTitle: r.test.title,
      level: r.test.level,
    }));
  }

  // ─── Weak sections ─────────────────────────────────────────────────────

  async getStudentWeakSections(
    userId: string,
    threshold = 50,
    bookId?: string,
  ): Promise<SectionStat[]> {
    const stats = await this.getStudentSectionStats(userId, bookId);
    return stats.filter((s) => s.accuracy < threshold);
    return stats.filter((s) => s.accuracy < threshold);
  }

  // ─── Full analysis ──────────────────────────────────────────────────────

  async getStudentFullAnalysis(userId: string, bookId?: string) {
    const [
      overview,
      sectionStats,
      learningOutcomeStats,
      outcomesByCategory,
      progressOverTime,
      weakSections,
      weakOutcomes,
    ] = await Promise.all([
      this.getStudentOverview(userId, bookId),
      this.getStudentSectionStats(userId, bookId),
      this.getStudentLearningOutcomeStats(userId, bookId),
      this.getStudentOutcomesByCategory(userId, bookId),
      this.getStudentProgressOverTime(userId, bookId),
      this.getStudentWeakSections(userId, 50, bookId),
      this.getStudentWeakOutcomes(userId, 50, bookId),
    ]);

    // Flutter uyumluluğu: root seviyede totalTests, overallSuccess, learningOutcomes
    const learningOutcomes = learningOutcomeStats.map((s) => ({
      id: s.learningOutcomeId,
      learningOutcomeId: s.learningOutcomeId,
      name: s.learningOutcomeName,
      description: s.category,
      totalQuestions: s.totalQuestions,
      completedQuestions: s.totalQuestions,
      correctAnswers: s.correctAnswers,
      incorrectAnswers: s.incorrectAnswers,
      completionPercentage: 100,
      successPercentage: s.accuracy,
    }));

    return {
      overview,
      sectionStats,
      learningOutcomeStats,
      outcomesByCategory,
      progressOverTime,
      weakSections,
      weakOutcomes,
      // Flutter / öğretmen paneli için
      totalTests: overview.totalTests,
      overallSuccess: overview.overallAccuracy,
      totalCorrect: overview.totalCorrect,
      totalIncorrect: overview.totalIncorrect,
      learningOutcomes,
    };
  }

  // ─── Section (seviye) analysis ───────────────────────────────────────────

  async getSectionAnalysis(userId: string, sectionId: string) {
    const section = await this.prisma.section.findUnique({
      where: { id: sectionId },
      include: { book: true },
    });
    if (!section) throw new NotFoundException('Section not found');

    const results = await this.prisma.result.findMany({
      where: { userId, test: { sectionId } },
      include: {
        answers: {
          include: {
            question: {
              include: {
                learningOutcome: { select: { id: true, code: true, name: true, category: true } },
                questionOutcomes: {
                  include: { learningOutcome: { select: { id: true, code: true, name: true, category: true } } },
                },
              },
            },
          },
        },
      },
    });

    const outcomeBreakdown = new Map<
      string,
      { code: string; name: string; category: string; total: number; correct: number }
    >();

    let totalQuestions = 0;
    let totalCorrect = 0;
    let totalIncorrect = 0;

    for (const result of results) {
      for (const answer of result.answers) {
        totalQuestions++;
        if (answer.isCorrect) totalCorrect++;
        else if (answer.selectedIndex != null) totalIncorrect++;

        // learningOutcomeId veya questionOutcomes (many-to-many) üzerinden kazanım
        let lo = answer.question.learningOutcome;
        if (!lo && answer.question.questionOutcomes?.length) {
          lo = answer.question.questionOutcomes[0].learningOutcome;
        }
        if (!lo) continue;

        const existing = outcomeBreakdown.get(lo.id);
        if (existing) {
          existing.total++;
          if (answer.isCorrect) existing.correct++;
        } else {
          outcomeBreakdown.set(lo.id, {
            code: lo.code,
            name: lo.name,
            category: lo.category,
            total: 1,
            correct: answer.isCorrect ? 1 : 0,
          });
        }
      }
    }

    const learningOutcomes = Array.from(outcomeBreakdown.entries()).map(
      ([id, data]) => ({
        id,
        learningOutcomeId: id,
        name: data.name,
        description: data.category,
        totalQuestions: data.total,
        completedQuestions: data.total,
        correctAnswers: data.correct,
        incorrectAnswers: data.total - data.correct,
        completionPercentage: 100,
        successPercentage:
          data.total > 0
            ? Math.round((data.correct / data.total) * 10000) / 100
            : 0,
      }),
    );

    return {
      sectionId,
      sectionTitle: section.title,
      bookTitle: section.book.title,
      totalTests: results.length,
      totalQuestions,
      totalCorrect,
      totalIncorrect,
      overallSuccess:
        totalQuestions > 0
          ? Math.round((totalCorrect / totalQuestions) * 10000) / 100
          : 0,
      learningOutcomes,
    };
  }

  // ─── Single test breakdown ──────────────────────────────────────────────

  async getTestAnalysis(resultId: string) {
    const result = await this.prisma.result.findUnique({
      where: { id: resultId },
      include: {
        answers: {
          include: {
            question: {
              include: { learningOutcome: { select: { id: true, code: true, name: true, category: true } } },
            },
          },
        },
        test: { include: { section: true } },
      },
    });

    if (!result) throw new NotFoundException('Result not found');

    const outcomeBreakdown = new Map<
      string,
      { code: string; name: string; category: string; total: number; correct: number }
    >();

    for (const answer of result.answers) {
      const lo = answer.question.learningOutcome;
      if (!lo) continue;

      const existing = outcomeBreakdown.get(lo.id);
      if (existing) {
        existing.total++;
        if (answer.isCorrect) existing.correct++;
      } else {
        outcomeBreakdown.set(lo.id, {
          code: lo.code,
          name: lo.name,
          category: lo.category,
          total: 1,
          correct: answer.isCorrect ? 1 : 0,
        });
      }
    }

    const totalQuestions = result.answers.length;
    const correctCount = result.answers.filter((a) => a.isCorrect).length;
    const incorrectCount = result.answers.filter(
      (a) => !a.isCorrect && a.selectedIndex != null,
    ).length;
    const skippedCount = result.answers.filter(
      (a) => a.selectedIndex == null,
    ).length;

    return {
      resultId: result.id,
      testTitle: result.test.title,
      sectionTitle: result.test.section.title,
      score: result.score,
      totalTime: result.totalTime,
      statistics: {
        totalQuestions,
        correct: correctCount,
        incorrect: incorrectCount,
        skipped: skippedCount,
        accuracy:
          totalQuestions > 0
            ? Math.round((correctCount / totalQuestions) * 10000) / 100
            : 0,
      },
      learningOutcomeBreakdown: Array.from(outcomeBreakdown.entries()).map(
        ([id, data]) => ({
          learningOutcomeId: id,
          ...data,
          accuracy:
            data.total > 0
              ? Math.round((data.correct / data.total) * 10000) / 100
              : 0,
        }),
      ),
      answers: result.answers.map((a) => ({
        questionId: a.questionId,
        questionText: a.question.text,
        selectedIndex: a.selectedIndex,
        correctIndex: a.question.correctAnswerIndex,
        isCorrect: a.isCorrect,
        explanation: a.question.explanation,
        learningOutcome: a.question.learningOutcome?.name ?? null,
      })),
    };
  }

  // ─── Recalculate outcome analytics (admin/migration utility) ────────

  async recalculateOutcomeAnalytics(userId: string) {
    // Hem questions.learning_outcome_id hem question_outcomes
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
        WHERE r.user_id = ${userId} AND q.learning_outcome_id IS NOT NULL
        UNION ALL
        SELECT qo.learning_outcome_id AS outcome_id, a.is_correct
        FROM answers a
        JOIN results r ON a.result_id = r.id
        JOIN question_outcomes qo ON a.question_id = qo.question_id
        JOIN questions q ON a.question_id = q.id
        WHERE r.user_id = ${userId} AND q.learning_outcome_id IS NULL
      ) sub
      GROUP BY outcome_id
    `;

    const now = new Date();

    await this.prisma.$transaction(
      rows.map((row) => {
        const total = Number(row.total);
        const correct = Number(row.correct);
        const incorrect = total - correct;
        const accuracy =
          total > 0 ? Math.round((correct / total) * 10000) / 100 : 0;

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

    return { recalculated: rows.length };
  }
}
