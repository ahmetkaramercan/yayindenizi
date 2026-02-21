-- CreateTable
CREATE TABLE "student_answers" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "question_id" TEXT NOT NULL,
    "selected_index" INTEGER NOT NULL,
    "is_correct" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "student_answers_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "student_answers_user_id_idx" ON "student_answers"("user_id");

-- CreateIndex
CREATE INDEX "student_answers_question_id_idx" ON "student_answers"("question_id");

-- CreateIndex
CREATE UNIQUE INDEX "student_answers_user_id_question_id_key" ON "student_answers"("user_id", "question_id");

-- AddForeignKey
ALTER TABLE "student_answers" ADD CONSTRAINT "student_answers_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "student_answers" ADD CONSTRAINT "student_answers_question_id_fkey" FOREIGN KEY ("question_id") REFERENCES "questions"("id") ON DELETE CASCADE ON UPDATE CASCADE;
