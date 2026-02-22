-- CreateTable
CREATE TABLE "outcome_analytics" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "learning_outcome_id" TEXT NOT NULL,
    "total_questions" INTEGER NOT NULL DEFAULT 0,
    "correct_answers" INTEGER NOT NULL DEFAULT 0,
    "incorrect_answers" INTEGER NOT NULL DEFAULT 0,
    "accuracy" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "last_attempt_at" TIMESTAMP(3),
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "outcome_analytics_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "outcome_analytics_user_id_idx" ON "outcome_analytics"("user_id");

-- CreateIndex
CREATE INDEX "outcome_analytics_learning_outcome_id_idx" ON "outcome_analytics"("learning_outcome_id");

-- CreateIndex
CREATE UNIQUE INDEX "outcome_analytics_user_id_learning_outcome_id_key" ON "outcome_analytics"("user_id", "learning_outcome_id");

-- AddForeignKey
ALTER TABLE "outcome_analytics" ADD CONSTRAINT "outcome_analytics_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "outcome_analytics" ADD CONSTRAINT "outcome_analytics_learning_outcome_id_fkey" FOREIGN KEY ("learning_outcome_id") REFERENCES "learning_outcomes"("id") ON DELETE CASCADE ON UPDATE CASCADE;
