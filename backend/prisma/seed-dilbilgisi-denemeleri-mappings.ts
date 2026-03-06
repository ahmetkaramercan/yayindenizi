import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient() as any;

const BOOK_TITLE = 'Dil Bilgisi Denemeleri';

// Her soru için kazanım kodları.
// Birden fazla kod varsa soru her kazanıma ayrı ayrı sayılır.
const QUESTION_OUTCOMES: Array<{
  testNo: number;     // 1-30
  questionNo: number; // 1-13
  codes: string[];
}> = [
  // ─── TEST 1 ───────────────────────────────────────────────────────────────
  { testNo: 1, questionNo: 1,  codes: ['21.17'] },
  { testNo: 1, questionNo: 2,  codes: ['21.9'] },
  { testNo: 1, questionNo: 3,  codes: ['21.7'] },
  { testNo: 1, questionNo: 4,  codes: ['21.15.6'] },
  { testNo: 1, questionNo: 5,  codes: ['21.12'] },
  { testNo: 1, questionNo: 6,  codes: ['21.17'] },
  { testNo: 1, questionNo: 7,  codes: ['21.17'] },
  { testNo: 1, questionNo: 8,  codes: ['21.10.8'] },
  { testNo: 1, questionNo: 9,  codes: ['21.17'] },
  { testNo: 1, questionNo: 10, codes: ['21.17'] },
  { testNo: 1, questionNo: 11, codes: ['21.8.2'] },
  { testNo: 1, questionNo: 12, codes: ['21.7'] },
  { testNo: 1, questionNo: 13, codes: ['21.18'] },
  // ─── TEST 2 ───────────────────────────────────────────────────────────────
  { testNo: 2, questionNo: 1,  codes: ['21.11'] },
  { testNo: 2, questionNo: 2,  codes: ['21.7'] },
  { testNo: 2, questionNo: 3,  codes: ['21.6'] },
  { testNo: 2, questionNo: 4,  codes: ['21.18'] },
  { testNo: 2, questionNo: 5,  codes: ['21.7'] },
  { testNo: 2, questionNo: 6,  codes: ['21.17'] },
  { testNo: 2, questionNo: 7,  codes: ['21.15'] },
  { testNo: 2, questionNo: 8,  codes: ['21.10'] },
  { testNo: 2, questionNo: 9,  codes: ['21.17'] },
  { testNo: 2, questionNo: 10, codes: ['21.8.12'] },
  { testNo: 2, questionNo: 11, codes: ['21.17'] },
  { testNo: 2, questionNo: 12, codes: ['21.12', '21.13'] },
  { testNo: 2, questionNo: 13, codes: ['21.18'] },
  // ─── TEST 3 ───────────────────────────────────────────────────────────────
  { testNo: 3, questionNo: 1,  codes: ['21.6.1'] },
  { testNo: 3, questionNo: 2,  codes: ['21.15'] },
  { testNo: 3, questionNo: 3,  codes: ['21.7'] },
  { testNo: 3, questionNo: 4,  codes: ['21.8'] },
  { testNo: 3, questionNo: 5,  codes: ['21.11'] },
  { testNo: 3, questionNo: 6,  codes: ['21.17.1'] },
  { testNo: 3, questionNo: 7,  codes: ['21.2.2'] },
  { testNo: 3, questionNo: 8,  codes: ['21.17'] },
  { testNo: 3, questionNo: 9,  codes: ['21.16'] },
  { testNo: 3, questionNo: 10, codes: ['21.10'] },
  { testNo: 3, questionNo: 11, codes: ['21.9.2'] },
  { testNo: 3, questionNo: 12, codes: ['21.10'] },
  { testNo: 3, questionNo: 13, codes: ['21.7'] },
  // ─── TEST 4 ───────────────────────────────────────────────────────────────
  { testNo: 4, questionNo: 1,  codes: ['21.17'] },
  { testNo: 4, questionNo: 2,  codes: ['21.8'] },
  { testNo: 4, questionNo: 3,  codes: ['21.8.2'] },
  { testNo: 4, questionNo: 4,  codes: ['21.10.15'] },
  { testNo: 4, questionNo: 5,  codes: ['21.17'] },
  { testNo: 4, questionNo: 6,  codes: ['21.15.1'] },
  { testNo: 4, questionNo: 7,  codes: ['21.7'] },
  { testNo: 4, questionNo: 8,  codes: ['21.17'] },
  { testNo: 4, questionNo: 9,  codes: ['21.9'] },
  { testNo: 4, questionNo: 10, codes: ['21.12.6'] },
  { testNo: 4, questionNo: 11, codes: ['21.10'] },
  { testNo: 4, questionNo: 12, codes: ['21.17'] },
  { testNo: 4, questionNo: 13, codes: ['21.18'] },
  // ─── TEST 5 ───────────────────────────────────────────────────────────────
  { testNo: 5, questionNo: 1,  codes: ['21.17'] },
  { testNo: 5, questionNo: 2,  codes: ['21.8'] },
  { testNo: 5, questionNo: 3,  codes: ['21.7'] },
  { testNo: 5, questionNo: 4,  codes: ['21.18'] },
  { testNo: 5, questionNo: 5,  codes: ['21.10'] },
  { testNo: 5, questionNo: 6,  codes: ['21.16'] },
  { testNo: 5, questionNo: 7,  codes: ['21.17'] },
  { testNo: 5, questionNo: 8,  codes: ['21.9'] },
  { testNo: 5, questionNo: 9,  codes: ['21.15'] },
  { testNo: 5, questionNo: 10, codes: ['21.10.15'] },
  { testNo: 5, questionNo: 11, codes: ['21.7'] },
  { testNo: 5, questionNo: 12, codes: ['21.17'] },
  { testNo: 5, questionNo: 13, codes: ['21.10'] },
  // ─── TEST 6 ───────────────────────────────────────────────────────────────
  { testNo: 6, questionNo: 1,  codes: ['21.6'] },
  { testNo: 6, questionNo: 2,  codes: ['21.8.12'] },
  { testNo: 6, questionNo: 3,  codes: ['21.7'] },
  { testNo: 6, questionNo: 4,  codes: ['21.18'] },
  { testNo: 6, questionNo: 5,  codes: ['21.10'] },
  { testNo: 6, questionNo: 6,  codes: ['21.15.1'] },
  { testNo: 6, questionNo: 7,  codes: ['21.12', '21.10', '21.6'] },
  { testNo: 6, questionNo: 8,  codes: ['21.17'] },
  { testNo: 6, questionNo: 9,  codes: ['21.10'] },
  { testNo: 6, questionNo: 10, codes: ['21.17'] },
  { testNo: 6, questionNo: 11, codes: ['21.17'] },
  { testNo: 6, questionNo: 12, codes: ['21.10'] },
  { testNo: 6, questionNo: 13, codes: ['21.16.5', '21.12.6'] },
  // ─── TEST 7 ───────────────────────────────────────────────────────────────
  { testNo: 7, questionNo: 1,  codes: ['21.6'] },
  { testNo: 7, questionNo: 2,  codes: ['21.8'] },
  { testNo: 7, questionNo: 3,  codes: ['21.7.9'] },
  { testNo: 7, questionNo: 4,  codes: ['21.7'] },
  { testNo: 7, questionNo: 5,  codes: ['21.18'] },
  { testNo: 7, questionNo: 6,  codes: ['21.17'] },
  { testNo: 7, questionNo: 7,  codes: ['21.17.1'] },
  { testNo: 7, questionNo: 8,  codes: ['21.17'] },
  { testNo: 7, questionNo: 9,  codes: ['21.17.1'] },
  { testNo: 7, questionNo: 10, codes: ['21.15.1'] },
  { testNo: 7, questionNo: 11, codes: ['21.9'] },
  { testNo: 7, questionNo: 12, codes: ['21.9.2'] },
  { testNo: 7, questionNo: 13, codes: ['21.13', '21.14', '21.12'] },
  // ─── TEST 8 ───────────────────────────────────────────────────────────────
  { testNo: 8, questionNo: 1,  codes: ['21.10'] },
  { testNo: 8, questionNo: 2,  codes: ['21.7.1'] },
  { testNo: 8, questionNo: 3,  codes: ['21.8'] },
  { testNo: 8, questionNo: 4,  codes: ['21.18'] },
  { testNo: 8, questionNo: 5,  codes: ['21.15.1'] },
  { testNo: 8, questionNo: 6,  codes: ['21.10.15'] },
  { testNo: 8, questionNo: 7,  codes: ['21.10'] },
  { testNo: 8, questionNo: 8,  codes: ['21.17'] },
  { testNo: 8, questionNo: 9,  codes: ['21.17'] },
  { testNo: 8, questionNo: 10, codes: ['21.16', '21.12'] },
  { testNo: 8, questionNo: 11, codes: ['21.8'] },
  { testNo: 8, questionNo: 12, codes: ['21.9.4'] },
  { testNo: 8, questionNo: 13, codes: ['21.11'] },
  // ─── TEST 9 ───────────────────────────────────────────────────────────────
  { testNo: 9, questionNo: 1,  codes: ['21.6'] },
  { testNo: 9, questionNo: 2,  codes: ['21.7'] },
  { testNo: 9, questionNo: 3,  codes: ['21.7'] },
  { testNo: 9, questionNo: 4,  codes: ['21.8'] },
  { testNo: 9, questionNo: 5,  codes: ['21.9'] },
  { testNo: 9, questionNo: 6,  codes: ['21.9.2'] },
  { testNo: 9, questionNo: 7,  codes: ['21.15'] },
  { testNo: 9, questionNo: 8,  codes: ['21.17'] },
  { testNo: 9, questionNo: 9,  codes: ['21.17.1'] },
  { testNo: 9, questionNo: 10, codes: ['21.17'] },
  { testNo: 9, questionNo: 11, codes: ['21.10'] },
  { testNo: 9, questionNo: 12, codes: ['21.15', '21.16', '21.10', '21.11'] },
  { testNo: 9, questionNo: 13, codes: ['21.10'] },
  // ─── TEST 10 ──────────────────────────────────────────────────────────────
  { testNo: 10, questionNo: 1,  codes: ['21.10.8', '21.10.9'] },
  { testNo: 10, questionNo: 2,  codes: ['21.13'] },
  { testNo: 10, questionNo: 3,  codes: ['21.6'] },
  { testNo: 10, questionNo: 4,  codes: ['21.17'] },
  { testNo: 10, questionNo: 5,  codes: ['21.15'] },
  { testNo: 10, questionNo: 6,  codes: ['21.10'] },
  { testNo: 10, questionNo: 7,  codes: ['21.17'] },
  { testNo: 10, questionNo: 8,  codes: ['21.10'] },
  { testNo: 10, questionNo: 9,  codes: ['21.9'] },
  { testNo: 10, questionNo: 10, codes: ['21.18'] },
  { testNo: 10, questionNo: 11, codes: ['21.7'] },
  { testNo: 10, questionNo: 12, codes: ['21.8'] },
  { testNo: 10, questionNo: 13, codes: ['21.8'] },
  // ─── TEST 11 ──────────────────────────────────────────────────────────────
  { testNo: 11, questionNo: 1,  codes: ['21.6'] },
  { testNo: 11, questionNo: 2,  codes: ['21.15'] },
  { testNo: 11, questionNo: 3,  codes: ['21.17'] },
  { testNo: 11, questionNo: 4,  codes: ['21.10', '21.13', '21.11', '21.12'] },
  { testNo: 11, questionNo: 5,  codes: ['21.9.2'] },
  { testNo: 11, questionNo: 6,  codes: ['21.17'] },
  { testNo: 11, questionNo: 7,  codes: ['21.17.1'] },
  { testNo: 11, questionNo: 8,  codes: ['21.17'] },
  { testNo: 11, questionNo: 9,  codes: ['21.12.5'] },
  { testNo: 11, questionNo: 10, codes: ['21.18'] },
  { testNo: 11, questionNo: 11, codes: ['21.7'] },
  { testNo: 11, questionNo: 12, codes: ['21.7'] },
  { testNo: 11, questionNo: 13, codes: ['21.8.12'] },
  // ─── TEST 12 ──────────────────────────────────────────────────────────────
  { testNo: 12, questionNo: 1,  codes: ['21.15'] },
  { testNo: 12, questionNo: 2,  codes: ['21.16', '21.12'] },
  { testNo: 12, questionNo: 3,  codes: ['21.17'] },
  { testNo: 12, questionNo: 4,  codes: ['21.11'] },
  { testNo: 12, questionNo: 5,  codes: ['21.9'] },
  { testNo: 12, questionNo: 6,  codes: ['21.17'] },
  { testNo: 12, questionNo: 7,  codes: ['21.13'] },
  { testNo: 12, questionNo: 8,  codes: ['21.6'] },
  { testNo: 12, questionNo: 9,  codes: ['21.10.3', '21.10.4'] },
  { testNo: 12, questionNo: 10, codes: ['21.7.5'] },
  { testNo: 12, questionNo: 11, codes: ['21.7'] },
  { testNo: 12, questionNo: 12, codes: ['21.8'] },
  { testNo: 12, questionNo: 13, codes: ['21.8'] },
  // ─── TEST 13 ──────────────────────────────────────────────────────────────
  { testNo: 13, questionNo: 1,  codes: ['21.6'] },
  { testNo: 13, questionNo: 2,  codes: ['21.17.1'] },
  { testNo: 13, questionNo: 3,  codes: ['21.9'] },
  { testNo: 13, questionNo: 4,  codes: ['21.15'] },
  { testNo: 13, questionNo: 5,  codes: ['21.18'] },
  { testNo: 13, questionNo: 6,  codes: ['21.7'] },
  { testNo: 13, questionNo: 7,  codes: ['21.7'] },
  { testNo: 13, questionNo: 8,  codes: ['21.8'] },
  { testNo: 13, questionNo: 9,  codes: ['21.8.3'] },
  { testNo: 13, questionNo: 10, codes: ['21.11.1'] },
  { testNo: 13, questionNo: 11, codes: ['21.13'] },
  { testNo: 13, questionNo: 12, codes: ['21.17'] },
  { testNo: 13, questionNo: 13, codes: ['21.10.10'] },
  // ─── TEST 14 ──────────────────────────────────────────────────────────────
  { testNo: 14, questionNo: 1,  codes: ['21.9'] },
  { testNo: 14, questionNo: 2,  codes: ['21.6'] },
  { testNo: 14, questionNo: 3,  codes: ['21.11'] },
  { testNo: 14, questionNo: 4,  codes: ['21.17'] },
  { testNo: 14, questionNo: 5,  codes: ['21.15.6'] },
  { testNo: 14, questionNo: 6,  codes: ['21.2.3'] },
  { testNo: 14, questionNo: 7,  codes: ['21.9'] },
  { testNo: 14, questionNo: 8,  codes: ['21.12.1'] },
  { testNo: 14, questionNo: 9,  codes: ['21.11'] },
  { testNo: 14, questionNo: 10, codes: ['21.7.9'] },
  { testNo: 14, questionNo: 11, codes: ['21.7'] },
  { testNo: 14, questionNo: 12, codes: ['21.8'] },
  { testNo: 14, questionNo: 13, codes: ['21.12.1'] },
  // ─── TEST 15 ──────────────────────────────────────────────────────────────
  { testNo: 15, questionNo: 1,  codes: ['21.10.10'] },
  { testNo: 15, questionNo: 2,  codes: ['21.17.1'] },
  { testNo: 15, questionNo: 3,  codes: ['21.17'] },
  { testNo: 15, questionNo: 4,  codes: ['21.9.5'] },
  { testNo: 15, questionNo: 5,  codes: ['21.17'] },
  { testNo: 15, questionNo: 6,  codes: ['21.17'] },
  { testNo: 15, questionNo: 7,  codes: ['21.15'] },
  { testNo: 15, questionNo: 8,  codes: ['21.7.9'] },
  { testNo: 15, questionNo: 9,  codes: ['21.7'] },
  { testNo: 15, questionNo: 10, codes: ['21.8'] },
  { testNo: 15, questionNo: 11, codes: ['21.8'] },
  { testNo: 15, questionNo: 12, codes: ['21.8'] },
  { testNo: 15, questionNo: 13, codes: ['21.15.1'] },
  // ─── TEST 16 ──────────────────────────────────────────────────────────────
  { testNo: 16, questionNo: 1,  codes: ['21.9'] },
  { testNo: 16, questionNo: 2,  codes: ['21.6'] },
  { testNo: 16, questionNo: 3,  codes: ['21.15.6'] },
  { testNo: 16, questionNo: 4,  codes: ['21.16', '21.11', '21.13', '21.14', '21.15'] },
  { testNo: 16, questionNo: 5,  codes: ['21.17.1'] },
  { testNo: 16, questionNo: 6,  codes: ['21.17'] },
  { testNo: 16, questionNo: 7,  codes: ['21.17'] },
  { testNo: 16, questionNo: 8,  codes: ['21.17'] },
  { testNo: 16, questionNo: 9,  codes: ['21.17'] },
  { testNo: 16, questionNo: 10, codes: ['21.18'] },
  { testNo: 16, questionNo: 11, codes: ['21.8.12'] },
  { testNo: 16, questionNo: 12, codes: ['21.7'] },
  { testNo: 16, questionNo: 13, codes: ['21.8.12'] },
  // ─── TEST 17 ──────────────────────────────────────────────────────────────
  { testNo: 17, questionNo: 1,  codes: ['21.17'] },
  { testNo: 17, questionNo: 2,  codes: ['21.6.1'] },
  { testNo: 17, questionNo: 3,  codes: ['21.7'] },
  { testNo: 17, questionNo: 4,  codes: ['21.7'] },
  { testNo: 17, questionNo: 5,  codes: ['21.8'] },
  { testNo: 17, questionNo: 6,  codes: ['21.18.1'] },
  { testNo: 17, questionNo: 7,  codes: ['21.15.6'] },
  { testNo: 17, questionNo: 8,  codes: ['21.17'] },
  { testNo: 17, questionNo: 9,  codes: ['21.17'] },
  { testNo: 17, questionNo: 10, codes: ['21.17'] },
  { testNo: 17, questionNo: 11, codes: ['21.17'] },
  { testNo: 17, questionNo: 12, codes: ['21.17'] },
  { testNo: 17, questionNo: 13, codes: ['21.17'] },
  // ─── TEST 18 ──────────────────────────────────────────────────────────────
  { testNo: 18, questionNo: 1,  codes: ['21.9.1'] },
  { testNo: 18, questionNo: 2,  codes: ['21.6'] },
  { testNo: 18, questionNo: 3,  codes: ['21.9.5'] },
  { testNo: 18, questionNo: 4,  codes: ['21.15.3'] },
  { testNo: 18, questionNo: 5,  codes: ['21.18.1'] },
  { testNo: 18, questionNo: 6,  codes: ['21.7'] },
  { testNo: 18, questionNo: 7,  codes: ['21.7'] },
  { testNo: 18, questionNo: 8,  codes: ['21.8'] },
  { testNo: 18, questionNo: 9,  codes: ['21.17'] },
  { testNo: 18, questionNo: 10, codes: ['21.17'] },
  { testNo: 18, questionNo: 11, codes: ['21.17'] },
  { testNo: 18, questionNo: 12, codes: ['21.17'] },
  { testNo: 18, questionNo: 13, codes: ['21.17'] },
  // ─── TEST 19 ──────────────────────────────────────────────────────────────
  { testNo: 19, questionNo: 1,  codes: ['21.15'] },
  { testNo: 19, questionNo: 2,  codes: ['21.17'] },
  { testNo: 19, questionNo: 3,  codes: ['21.6'] },
  { testNo: 19, questionNo: 4,  codes: ['21.17'] },
  { testNo: 19, questionNo: 5,  codes: ['21.17'] },
  { testNo: 19, questionNo: 6,  codes: ['21.17'] },
  { testNo: 19, questionNo: 7,  codes: ['21.17'] },
  { testNo: 19, questionNo: 8,  codes: ['21.17'] },
  { testNo: 19, questionNo: 9,  codes: ['21.13', '21.11', '21.12', '21.10'] },
  { testNo: 19, questionNo: 10, codes: ['21.18'] },
  { testNo: 19, questionNo: 11, codes: ['21.7'] },
  { testNo: 19, questionNo: 12, codes: ['21.7'] },
  { testNo: 19, questionNo: 13, codes: ['21.8'] },
  // ─── TEST 20 ──────────────────────────────────────────────────────────────
  { testNo: 20, questionNo: 1,  codes: ['21.6'] },
  { testNo: 20, questionNo: 2,  codes: ['21.15'] },
  { testNo: 20, questionNo: 3,  codes: ['21.10'] },
  { testNo: 20, questionNo: 4,  codes: ['21.18'] },
  { testNo: 20, questionNo: 5,  codes: ['21.17'] },
  { testNo: 20, questionNo: 6,  codes: ['21.17'] },
  { testNo: 20, questionNo: 7,  codes: ['21.17'] },
  { testNo: 20, questionNo: 8,  codes: ['21.7'] },
  { testNo: 20, questionNo: 9,  codes: ['21.17'] },
  { testNo: 20, questionNo: 10, codes: ['21.17'] },
  { testNo: 20, questionNo: 11, codes: ['21.17.1'] },
  { testNo: 20, questionNo: 12, codes: ['21.7'] },
  { testNo: 20, questionNo: 13, codes: ['21.8'] },
  // ─── TEST 21 ──────────────────────────────────────────────────────────────
  { testNo: 21, questionNo: 1,  codes: ['21.11', '21.10', '21.6'] },
  { testNo: 21, questionNo: 2,  codes: ['21.9'] },
  { testNo: 21, questionNo: 3,  codes: ['21.17'] },
  { testNo: 21, questionNo: 4,  codes: ['21.7'] },
  { testNo: 21, questionNo: 5,  codes: ['21.7'] },
  { testNo: 21, questionNo: 6,  codes: ['21.8.12'] },
  { testNo: 21, questionNo: 7,  codes: ['21.17'] },
  { testNo: 21, questionNo: 8,  codes: ['21.17'] },
  { testNo: 21, questionNo: 9,  codes: ['21.17'] },
  { testNo: 21, questionNo: 10, codes: ['21.17'] },
  { testNo: 21, questionNo: 11, codes: ['21.17'] },
  { testNo: 21, questionNo: 12, codes: ['21.17'] },
  { testNo: 21, questionNo: 13, codes: ['21.18'] },
  // ─── TEST 22 ──────────────────────────────────────────────────────────────
  { testNo: 22, questionNo: 1,  codes: ['21.7.9'] },
  { testNo: 22, questionNo: 2,  codes: ['21.7'] },
  { testNo: 22, questionNo: 3,  codes: ['21.8'] },
  { testNo: 22, questionNo: 4,  codes: ['21.8'] },
  { testNo: 22, questionNo: 5,  codes: ['21.6'] },
  { testNo: 22, questionNo: 6,  codes: ['21.15'] },
  { testNo: 22, questionNo: 7,  codes: ['21.17'] },
  { testNo: 22, questionNo: 8,  codes: ['21.10.3'] },
  { testNo: 22, questionNo: 9,  codes: ['21.17'] },
  { testNo: 22, questionNo: 10, codes: ['21.10'] },
  { testNo: 22, questionNo: 11, codes: ['21.9'] },
  { testNo: 22, questionNo: 12, codes: ['21.11.1'] },
  { testNo: 22, questionNo: 13, codes: ['21.17'] },
  // ─── TEST 23 ──────────────────────────────────────────────────────────────
  { testNo: 23, questionNo: 1,  codes: ['21.7'] },
  { testNo: 23, questionNo: 2,  codes: ['21.7'] },
  { testNo: 23, questionNo: 3,  codes: ['21.8'] },
  { testNo: 23, questionNo: 4,  codes: ['21.8'] },
  { testNo: 23, questionNo: 5,  codes: ['21.17'] },
  { testNo: 23, questionNo: 6,  codes: ['21.17'] },
  { testNo: 23, questionNo: 7,  codes: ['21.13'] },
  { testNo: 23, questionNo: 8,  codes: ['21.17'] },
  { testNo: 23, questionNo: 9,  codes: ['21.2.3'] },
  { testNo: 23, questionNo: 10, codes: ['21.6'] },
  { testNo: 23, questionNo: 11, codes: ['21.15'] },
  { testNo: 23, questionNo: 12, codes: ['21.9'] },
  { testNo: 23, questionNo: 13, codes: ['21.10.10', '21.10.11'] },
  // ─── TEST 24 ──────────────────────────────────────────────────────────────
  { testNo: 24, questionNo: 1,  codes: ['21.7'] },
  { testNo: 24, questionNo: 2,  codes: ['21.7'] },
  { testNo: 24, questionNo: 3,  codes: ['21.8'] },
  { testNo: 24, questionNo: 4,  codes: ['21.8'] },
  { testNo: 24, questionNo: 5,  codes: ['21.13', '21.10'] },
  { testNo: 24, questionNo: 6,  codes: ['21.17.1'] },
  { testNo: 24, questionNo: 7,  codes: ['21.9.4'] },
  { testNo: 24, questionNo: 8,  codes: ['21.6.1'] },
  { testNo: 24, questionNo: 9,  codes: ['21.15'] },
  { testNo: 24, questionNo: 10, codes: ['21.17'] },
  { testNo: 24, questionNo: 11, codes: ['21.11'] },
  { testNo: 24, questionNo: 12, codes: ['21.17'] },
  { testNo: 24, questionNo: 13, codes: ['21.18'] },
  // ─── TEST 25 ──────────────────────────────────────────────────────────────
  { testNo: 25, questionNo: 1,  codes: ['21.7'] },
  { testNo: 25, questionNo: 2,  codes: ['21.4.2'] },
  { testNo: 25, questionNo: 3,  codes: ['21.7'] },
  { testNo: 25, questionNo: 4,  codes: ['21.8'] },
  { testNo: 25, questionNo: 5,  codes: ['21.14.1'] },
  { testNo: 25, questionNo: 6,  codes: ['21.10'] },
  { testNo: 25, questionNo: 7,  codes: ['21.13'] },
  { testNo: 25, questionNo: 8,  codes: ['21.17'] },
  { testNo: 25, questionNo: 9,  codes: ['21.9.5'] },
  { testNo: 25, questionNo: 10, codes: ['21.6'] },
  { testNo: 25, questionNo: 11, codes: ['21.15'] },
  { testNo: 25, questionNo: 12, codes: ['21.10', '21.13'] },
  { testNo: 25, questionNo: 13, codes: ['21.17'] },
  // ─── TEST 26 ──────────────────────────────────────────────────────────────
  { testNo: 26, questionNo: 1,  codes: ['21.7'] },
  { testNo: 26, questionNo: 2,  codes: ['21.8'] },
  { testNo: 26, questionNo: 3,  codes: ['21.7'] },
  { testNo: 26, questionNo: 4,  codes: ['21.8'] },
  { testNo: 26, questionNo: 5,  codes: ['21.11.2'] },
  { testNo: 26, questionNo: 6,  codes: ['21.10'] },
  { testNo: 26, questionNo: 7,  codes: ['21.6'] },
  { testNo: 26, questionNo: 8,  codes: ['21.17'] },
  { testNo: 26, questionNo: 9,  codes: ['21.15.6'] },
  { testNo: 26, questionNo: 10, codes: ['21.13', '21.15'] },
  { testNo: 26, questionNo: 11, codes: ['21.9'] },
  { testNo: 26, questionNo: 12, codes: ['21.17'] },
  { testNo: 26, questionNo: 13, codes: ['21.17'] },
  // ─── TEST 27 ──────────────────────────────────────────────────────────────
  { testNo: 27, questionNo: 1,  codes: ['21.7'] },
  { testNo: 27, questionNo: 2,  codes: ['21.7'] },
  { testNo: 27, questionNo: 3,  codes: ['21.8'] },
  { testNo: 27, questionNo: 4,  codes: ['21.8'] },
  { testNo: 27, questionNo: 5,  codes: ['21.13'] },
  { testNo: 27, questionNo: 6,  codes: ['21.9'] },
  { testNo: 27, questionNo: 7,  codes: ['21.6.2'] },
  { testNo: 27, questionNo: 8,  codes: ['21.13', '21.10'] }, // "veya" → her ikisi de
  { testNo: 27, questionNo: 9,  codes: ['21.17'] },
  { testNo: 27, questionNo: 10, codes: ['21.15'] },
  { testNo: 27, questionNo: 11, codes: ['21.18'] },
  { testNo: 27, questionNo: 12, codes: ['21.9.4'] },
  { testNo: 27, questionNo: 13, codes: ['21.17'] },
  // ─── TEST 28 ──────────────────────────────────────────────────────────────
  { testNo: 28, questionNo: 1,  codes: ['21.7'] },
  { testNo: 28, questionNo: 2,  codes: ['21.7'] },
  { testNo: 28, questionNo: 3,  codes: ['21.8'] },
  { testNo: 28, questionNo: 4,  codes: ['21.8.12'] },
  { testNo: 28, questionNo: 5,  codes: ['21.9'] },
  { testNo: 28, questionNo: 6,  codes: ['21.6'] },
  { testNo: 28, questionNo: 7,  codes: ['21.10', '21.13'] },
  { testNo: 28, questionNo: 8,  codes: ['21.17'] },
  { testNo: 28, questionNo: 9,  codes: ['21.11'] },
  { testNo: 28, questionNo: 10, codes: ['21.17'] },
  { testNo: 28, questionNo: 11, codes: ['21.10.10'] },
  { testNo: 28, questionNo: 12, codes: ['21.15'] },
  { testNo: 28, questionNo: 13, codes: ['21.15.1'] },
  // ─── TEST 29 ──────────────────────────────────────────────────────────────
  { testNo: 29, questionNo: 1,  codes: ['21.7'] },
  { testNo: 29, questionNo: 2,  codes: ['21.8'] },
  { testNo: 29, questionNo: 3,  codes: ['21.7'] },
  { testNo: 29, questionNo: 4,  codes: ['21.8.3'] },
  { testNo: 29, questionNo: 5,  codes: ['21.17'] },
  { testNo: 29, questionNo: 6,  codes: ['21.10'] },
  { testNo: 29, questionNo: 7,  codes: ['21.9.5'] },
  { testNo: 29, questionNo: 8,  codes: ['21.6'] },
  { testNo: 29, questionNo: 9,  codes: ['21.15', '21.10'] },
  { testNo: 29, questionNo: 10, codes: ['21.16.3'] },
  { testNo: 29, questionNo: 11, codes: ['21.10.1'] },
  { testNo: 29, questionNo: 12, codes: ['21.17'] },
  { testNo: 29, questionNo: 13, codes: ['21.18'] },
  // ─── TEST 30 ──────────────────────────────────────────────────────────────
  { testNo: 30, questionNo: 1,  codes: ['21.7'] },
  { testNo: 30, questionNo: 2,  codes: ['21.7.1'] },
  { testNo: 30, questionNo: 3,  codes: ['21.8'] },
  { testNo: 30, questionNo: 4,  codes: ['21.8'] },
  { testNo: 30, questionNo: 5,  codes: ['21.6'] },
  { testNo: 30, questionNo: 6,  codes: ['21.9'] },
  { testNo: 30, questionNo: 7,  codes: ['21.10'] },
  { testNo: 30, questionNo: 8,  codes: ['21.10', '21.13'] },
  { testNo: 30, questionNo: 9,  codes: ['21.10'] },
  { testNo: 30, questionNo: 10, codes: ['21.13'] },
  { testNo: 30, questionNo: 11, codes: ['21.15'] },
  { testNo: 30, questionNo: 12, codes: ['21.17'] },
  { testNo: 30, questionNo: 13, codes: ['21.18'] },
];

async function main() {
  console.log('Seeding Dil Bilgisi Denemeleri - question-outcome mappings');

  const book = await prisma.book.findFirst({
    where: { title: BOOK_TITLE },
    select: { id: true },
  });
  if (!book) {
    throw new Error(`Book "${BOOK_TITLE}" not found. Run seed:dilbilgisi:structure first.`);
  }
  const bookId = book.id;

  // Kazanımları yükle
  const outcomes = await prisma.learningOutcome.findMany({
    where: { bookId },
    select: { id: true, code: true },
  });
  const outcomeMap = new Map<string, string>(outcomes.map((o: any) => [o.code, o.id]));

  // Tüm testleri yükle: "Deneme 1" → id
  const tests = await prisma.test.findMany({
    where: { section: { bookId } },
    select: { id: true, title: true },
  });
  const testMap = new Map<number, string>();
  for (const t of tests) {
    const match = t.title.match(/Deneme (\d+)/);
    if (match) testMap.set(parseInt(match[1]), t.id);
  }

  // Tüm soruları yükle: testId + orderIndex → questionId
  const questions = await prisma.question.findMany({
    where: { test: { section: { bookId } } },
    select: { id: true, testId: true, orderIndex: true },
  });
  const questionMap = new Map<string, string>();
  for (const q of questions) {
    questionMap.set(`${q.testId}:${q.orderIndex}`, q.id);
  }

  // Eski eşleştirmeleri sil
  const deleted = await prisma.questionOutcome.deleteMany({
    where: { question: { test: { section: { bookId } } } },
  });
  console.log(`✓ Removed ${deleted.count} old mappings`);

  let mappingCount = 0;
  let skippedCount = 0;
  const unknownCodes = new Set<string>();

  for (const entry of QUESTION_OUTCOMES) {
    const testId = testMap.get(entry.testNo);
    if (!testId) {
      console.warn(`⚠ Test not found: Deneme ${entry.testNo}`);
      skippedCount++;
      continue;
    }

    const questionId = questionMap.get(`${testId}:${entry.questionNo - 1}`);
    if (!questionId) {
      console.warn(`⚠ Question not found: Deneme ${entry.testNo} Q${entry.questionNo}`);
      skippedCount++;
      continue;
    }

    for (const code of entry.codes) {
      const outcomeId = outcomeMap.get(code);
      if (!outcomeId) {
        unknownCodes.add(code);
        continue;
      }
      await prisma.questionOutcome.create({
        data: { questionId, learningOutcomeId: outcomeId },
      });
      mappingCount++;
    }
  }

  if (unknownCodes.size > 0) {
    console.warn(`⚠ Unknown outcome codes (skipped): ${[...unknownCodes].sort().join(', ')}`);
  }

  console.log(`\n✓ ${mappingCount} question-outcome mappings created`);
  if (skippedCount > 0) console.log(`⚠ ${skippedCount} entries skipped`);

  const totalMappings = await prisma.questionOutcome.count({
    where: { question: { test: { section: { bookId } } } },
  });
  console.log('\n=== VALIDATION ===');
  console.log(`Mappings for "${BOOK_TITLE}": ${totalMappings}`);
  console.log('✓ Done');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
