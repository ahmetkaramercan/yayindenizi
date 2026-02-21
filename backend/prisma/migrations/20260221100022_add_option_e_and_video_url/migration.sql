-- AlterTable
ALTER TABLE "questions" ADD COLUMN     "option_e" TEXT NOT NULL DEFAULT 'E',
ADD COLUMN     "video_url" TEXT,
ALTER COLUMN "text" SET DEFAULT '',
ALTER COLUMN "option_a" SET DEFAULT 'A',
ALTER COLUMN "option_b" SET DEFAULT 'B',
ALTER COLUMN "option_c" SET DEFAULT 'C',
ALTER COLUMN "option_d" SET DEFAULT 'D';
