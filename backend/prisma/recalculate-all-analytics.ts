import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('Recalculating Outcome Analytics for all users...');

  // Get all users who have submitted results
  const usersWithResults = await prisma.result.findMany({
    select: { userId: true },
    distinct: ['userId'],
  });

  console.log(`Found ${usersWithResults.length} users with results.`);

  for (const { userId } of usersWithResults) {
    console.log(`Processing user: ${userId}`);

    // This logic is copied from AnalyticsService.recalculateOutcomeAnalytics
    // It finds both direct learningOutcomeId and many-to-many bridge questionOutcomes
    const rows = await prisma.$queryRaw<
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

    for (const row of rows) {
      const total = Number(row.total);
      const correct = Number(row.correct);
      const incorrect = total - correct;
      const accuracy = total > 0 ? Math.round((correct / total) * 10000) / 100 : 0;

      await prisma.outcomeAnalytics.upsert({
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
    }
    console.log(`✓ Recalculated ${rows.length} outcomes for user ${userId}`);
  }

  console.log('✓ All analytics recalculated successfully.');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
