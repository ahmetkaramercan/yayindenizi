import { PrismaClient, BookCategory } from '@prisma/client';

const prisma = new PrismaClient() as any;

const BOOK_TITLE = 'Dil Bilgisi Denemeleri';
const LEGACY_BOOK_TITLES = ['Dil Bilgisi Denemeleri Kitabı'];
const BOOK_IMAGE_URL = 'photos/dil_bilgisi_denemeleri.jpeg';

const LETTER_TO_INDEX: Record<string, number> = {
  A: 0,
  B: 1,
  C: 2,
  D: 3,
  E: 4,
};

// 30 deneme, her denemede 13 soru. Seviye yok.
const ANSWER_KEYS: string[][] = [
  ['B', 'B', 'D', 'C', 'E', 'C', 'D', 'B', 'D', 'D', 'A', 'C', 'C'],
  ['D', 'C', 'C', 'A', 'B', 'B', 'B', 'E', 'D', 'A', 'A', 'D', 'C'],
  ['B', 'C', 'A', 'A', 'D', 'E', 'B', 'E', 'B', 'E', 'C', 'B', 'B'],
  ['D', 'E', 'C', 'C', 'E', 'A', 'D', 'E', 'C', 'E', 'C', 'D', 'A'],
  ['E', 'B', 'A', 'D', 'C', 'B', 'A', 'A', 'B', 'A', 'E', 'C', 'E'],
  ['D', 'B', 'C', 'E', 'D', 'E', 'E', 'D', 'D', 'E', 'C', 'A', 'C'],
  ['C', 'A', 'E', 'B', 'B', 'A', 'C', 'E', 'E', 'B', 'B', 'C', 'D'],
  ['A', 'D', 'E', 'A', 'E', 'A', 'D', 'A', 'D', 'B', 'E', 'C', 'E'],
  ['E', 'D', 'D', 'E', 'A', 'C', 'A', 'D', 'C', 'E', 'A', 'A', 'D'],
  ['D', 'B', 'C', 'D', 'C', 'A', 'E', 'E', 'B', 'A', 'E', 'D', 'E'],
  ['B', 'D', 'C', 'D', 'C', 'A', 'C', 'B', 'B', 'B', 'C', 'D', 'A'],
  ['B', 'D', 'C', 'E', 'C', 'D', 'B', 'A', 'D', 'A', 'C', 'C', 'B'],
  ['C', 'E', 'D', 'D', 'A', 'B', 'D', 'B', 'C', 'E', 'A', 'E', 'C'],
  ['E', 'E', 'C', 'D', 'E', 'E', 'A', 'A', 'E', 'A', 'E', 'A', 'D'],
  ['C', 'C', 'E', 'C', 'E', 'D', 'D', 'D', 'C', 'A', 'A', 'E', 'E'],
  ['E', 'B', 'B', 'E', 'E', 'C', 'A', 'B', 'B', 'C', 'D', 'E', 'B'],
  ['C', 'A', 'A', 'E', 'A', 'A', 'D', 'C', 'A', 'C', 'B', 'E', 'B'],
  ['E', 'D', 'C', 'A', 'C', 'D', 'E', 'B', 'C', 'D', 'D', 'E', 'E'],
  ['B', 'D', 'B', 'C', 'E', 'B', 'D', 'B', 'E', 'C', 'B', 'A', 'E'],
  ['C', 'D', 'C', 'B', 'B', 'B', 'C', 'A', 'C', 'A', 'E', 'B', 'D'],
  ['C', 'C', 'A', 'B', 'A', 'B', 'E', 'B', 'D', 'C', 'E', 'A', 'D'],
  ['A', 'B', 'A', 'E', 'D', 'C', 'E', 'B', 'E', 'C', 'B', 'C', 'D'],
  ['B', 'C', 'D', 'D', 'B', 'C', 'B', 'D', 'A', 'D', 'B', 'D', 'B'],
  ['D', 'C', 'B', 'A', 'C', 'C', 'B', 'D', 'C', 'C', 'A', 'A', 'D'],
  ['A', 'E', 'B', 'A', 'C', 'D', 'C', 'B', 'D', 'E', 'B', 'D', 'E'],
  ['B', 'E', 'E', 'B', 'A', 'B', 'C', 'C', 'A', 'D', 'B', 'C', 'E'],
  ['D', 'E', 'C', 'C', 'D', 'B', 'C', 'E', 'C', 'E', 'A', 'C', 'E'],
  ['B', 'D', 'A', 'E', 'E', 'B', 'E', 'C', 'B', 'E', 'B', 'A', 'B'],
  ['D', 'D', 'A', 'C', 'D', 'A', 'C', 'E', 'E', 'C', 'C', 'D', 'C'],
  ['A', 'B', 'C', 'C', 'A', 'D', 'D', 'A', 'E', 'D', 'B', 'C', 'E'],
];

async function main() {
  console.log('Seeding Dil Bilgisi Denemeleri - structure (sections, tests, questions)');

  const deletedLegacyBooks = await prisma.book.deleteMany({
    where: { title: { in: LEGACY_BOOK_TITLES } },
  });
  if (deletedLegacyBooks.count > 0) {
    console.log(`✓ Removed ${deletedLegacyBooks.count} legacy book record(s)`);
  }

  let book = await prisma.book.findFirst({
    where: { title: BOOK_TITLE },
    select: { id: true },
  });

  if (!book) {
    book = await prisma.book.create({
      data: {
        title: BOOK_TITLE,
        description: 'TYT Dil Bilgisi deneme kitabı - 30 deneme, her denemede 13 soru',
        imageUrl: BOOK_IMAGE_URL,
        category: BookCategory.DENEME,
      },
      select: { id: true },
    });
    console.log(`✓ Book created: ${book.id}`);
  } else {
    await prisma.book.update({
      where: { id: book.id },
      data: {
        title: BOOK_TITLE,
        description: 'TYT Dil Bilgisi deneme kitabı - 30 deneme, her denemede 13 soru',
        imageUrl: BOOK_IMAGE_URL,
        category: BookCategory.DENEME,
      },
    });
    console.log(`✓ Book found: ${book.id}`);
  }

  const bookId = book.id;

  const existingSections = await prisma.section.findMany({
    where: { bookId },
    select: { id: true },
  });
  if (existingSections.length > 0) {
    await prisma.section.deleteMany({ where: { bookId } });
    console.log(`✓ Removed ${existingSections.length} existing sections`);
  }

  const section = await prisma.section.create({
    data: {
      title: 'Denemeler',
      description: '30 dil bilgisi denemesi',
      orderIndex: 0,
      bookId,
    },
  });

  let totalQuestions = 0;

  for (let dIdx = 0; dIdx < ANSWER_KEYS.length; dIdx++) {
    const answers = ANSWER_KEYS[dIdx];
    const testTitle = `Deneme ${dIdx + 1}`;
    const test = await prisma.test.create({
      data: {
        title: testTitle,
        description: testTitle,
        level: 1,
        timeLimit: 20 * 60, // 20 dakika (13 soru)
        sectionId: section.id,
      },
    });

    const questions = answers.map((letter, orderIndex) => {
      const idx = LETTER_TO_INDEX[letter.toUpperCase()] ?? 4;
      return {
        text: '',
        optionA: 'A',
        optionB: 'B',
        optionC: 'C',
        optionD: 'D',
        optionE: 'E',
        correctAnswerIndex: idx,
        orderIndex,
        testId: test.id,
      };
    });

    await prisma.question.createMany({ data: questions });
    totalQuestions += questions.length;
  }

  console.log(`✓ 1 section created`);
  console.log(`✓ 30 tests created`);
  console.log(`✓ ${totalQuestions} questions created`);

  console.log('\n=== VALIDATION ===');
  const sectionCount = await prisma.section.count({ where: { bookId } });
  const testCount = await prisma.test.count({
    where: { section: { bookId } },
  });
  const questionCount = await prisma.question.count({
    where: { test: { section: { bookId } } },
  });
  console.log(`Sections: ${sectionCount}`);
  console.log(`Tests: ${testCount}`);
  console.log(`Questions: ${questionCount}`);
  console.log('✓ Done');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
