-- AlterTable
ALTER TABLE "learning_outcomes" ADD COLUMN     "book_id" TEXT,
ADD COLUMN     "code" TEXT NOT NULL;

-- CreateTable
CREATE TABLE "question_outcomes" (
    "id" TEXT NOT NULL,
    "question_id" TEXT NOT NULL,
    "learning_outcome_id" TEXT NOT NULL,

    CONSTRAINT "question_outcomes_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "question_outcomes_learning_outcome_id_idx" ON "question_outcomes"("learning_outcome_id");

-- CreateIndex
CREATE UNIQUE INDEX "question_outcomes_question_id_learning_outcome_id_key" ON "question_outcomes"("question_id", "learning_outcome_id");

-- CreateIndex
CREATE UNIQUE INDEX "learning_outcomes_book_id_code_key" ON "learning_outcomes"("book_id", "code");

-- AddForeignKey
ALTER TABLE "question_outcomes" ADD CONSTRAINT "question_outcomes_question_id_fkey" FOREIGN KEY ("question_id") REFERENCES "questions"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "question_outcomes" ADD CONSTRAINT "question_outcomes_learning_outcome_id_fkey" FOREIGN KEY ("learning_outcome_id") REFERENCES "learning_outcomes"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "learning_outcomes" ADD CONSTRAINT "learning_outcomes_book_id_fkey" FOREIGN KEY ("book_id") REFERENCES "books"("id") ON DELETE SET NULL ON UPDATE CASCADE;
