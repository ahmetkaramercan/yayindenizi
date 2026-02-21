import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '@/prisma/prisma.service';

export interface OutcomeStat {
  learningOutcomeId: string;
  learningOutcomeName: string;
  category: string;
  totalQuestions: number;
  correctAnswers: number;
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

  async getStudentOverview(userId: string) {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) throw new NotFoundException('User not found');

    const analytics = await this.prisma.analytics.findMany({
      where: { userId },
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

    const weightedScore = analytics.reduce((s, a) => s + a.averageScore * a.totalTests, 0);
    const averageScore = totalTests > 0 ? weightedScore / totalTests : 0;
    const overallAccuracy = totalQuestions > 0 ? (totalCorrect / totalQuestions) * 100 : 0;

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

  async getStudentSectionStats(userId: string): Promise<SectionStat[]> {
    const analytics = await this.prisma.analytics.findMany({
      where: { userId },
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

  async getStudentLearningOutcomeStats(userId: string): Promise<OutcomeStat[]> {
    const answers = await this.prisma.answer.findMany({
      where: { result: { userId } },
      include: {
        question: { include: { learningOutcome: true } },
      },
    });

    const outcomeMap = new Map<string, OutcomeStat>();

    for (const answer of answers) {
      const lo = answer.question.learningOutcome;
      if (!lo) continue;

      const existing = outcomeMap.get(lo.id);
      if (existing) {
        existing.totalQuestions++;
        if (answer.isCorrect) existing.correctAnswers++;
      } else {
        outcomeMap.set(lo.id, {
          learningOutcomeId: lo.id,
          learningOutcomeName: lo.name,
          category: lo.category,
          totalQuestions: 1,
          correctAnswers: answer.isCorrect ? 1 : 0,
          accuracy: 0,
        });
      }
    }

    return Array.from(outcomeMap.values())
      .map((s) => ({
        ...s,
        accuracy:
          s.totalQuestions > 0
            ? Math.round((s.correctAnswers / s.totalQuestions) * 10000) / 100
            : 0,
      }))
      .sort((a, b) => a.accuracy - b.accuracy);
  }

  async getStudentProgressOverTime(userId: string) {
    const results = await this.prisma.result.findMany({
      where: { userId },
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

  async getStudentWeakSections(userId: string, threshold = 50): Promise<SectionStat[]> {
    const stats = await this.getStudentSectionStats(userId);
    return stats.filter((s) => s.accuracy < threshold);
  }

  async getStudentFullAnalysis(userId: string) {
    const [overview, sectionStats, learningOutcomeStats, progressOverTime, weakSections] =
      await Promise.all([
        this.getStudentOverview(userId),
        this.getStudentSectionStats(userId),
        this.getStudentLearningOutcomeStats(userId),
        this.getStudentProgressOverTime(userId),
        this.getStudentWeakSections(userId),
      ]);

    return {
      overview,
      sectionStats,
      learningOutcomeStats,
      progressOverTime,
      weakSections,
    };
  }

  async getTestAnalysis(resultId: string) {
    const result = await this.prisma.result.findUnique({
      where: { id: resultId },
      include: {
        answers: {
          include: { question: { include: { learningOutcome: true } } },
        },
        test: { include: { section: true } },
      },
    });

    if (!result) throw new NotFoundException('Result not found');

    const outcomeBreakdown = new Map<
      string,
      { name: string; category: string; total: number; correct: number }
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
    const skippedCount = result.answers.filter((a) => a.selectedIndex == null).length;

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
      learningOutcomeBreakdown: Array.from(outcomeBreakdown.entries()).map(([id, data]) => ({
        learningOutcomeId: id,
        ...data,
        accuracy:
          data.total > 0 ? Math.round((data.correct / data.total) * 10000) / 100 : 0,
      })),
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
}
