import { PrismaClient, BookCategory } from '@prisma/client';

const prisma = new PrismaClient();

const BOOK_TITLE = 'Edebiyat Denemeleri';
const LEGACY_BOOK_TITLES = ['Edebiyat Denemeleri Kitabı'];
const BOOK_IMAGE_URL = 'photos/edebiyat_denemeleri.jpeg';

const LETTER_TO_INDEX: Record<string, number> = {
  A: 0,
  B: 1,
  C: 2,
  D: 3,
  E: 4,
};

// 16 deneme, her denemede 24 soru. Seviye yok.
const ANSWER_KEYS: string[][] = [
  ['D', 'A', 'C', 'D', 'D', 'D', 'C', 'C', 'C', 'D', 'E', 'C', 'D', 'E', 'D', 'C', 'D', 'B', 'B', 'B', 'A', 'D', 'A', 'D'],
  ['B', 'E', 'C', 'C', 'D', 'E', 'B', 'D', 'E', 'A', 'E', 'D', 'A', 'B', 'A', 'C', 'D', 'A', 'D', 'C', 'C', 'B', 'B', 'A'],
  ['C', 'C', 'D', 'E', 'E', 'D', 'E', 'C', 'A', 'C', 'C', 'E', 'C', 'E', 'B', 'B', 'C', 'D', 'C', 'D', 'D', 'A', 'E', 'B'],
  ['D', 'A', 'D', 'D', 'D', 'B', 'E', 'B', 'D', 'C', 'B', 'C', 'C', 'B', 'A', 'C', 'D', 'D', 'D', 'B', 'D', 'C', 'A', 'C'],
  ['B', 'E', 'A', 'C', 'D', 'C', 'D', 'D', 'B', 'C', 'A', 'C', 'B', 'C', 'E', 'E', 'D', 'E', 'B', 'C', 'D', 'E', 'A', 'D'],
  ['B', 'D', 'C', 'D', 'D', 'D', 'B', 'E', 'C', 'A', 'D', 'E', 'E', 'E', 'B', 'C', 'B', 'D', 'B', 'D', 'D', 'B', 'B', 'D'],
  ['D', 'C', 'D', 'D', 'D', 'A', 'B', 'D', 'D', 'C', 'E', 'B', 'A', 'E', 'C', 'E', 'C', 'B', 'D', 'D', 'E', 'A', 'D', 'E'],
  ['B', 'D', 'D', 'C', 'D', 'E', 'C', 'E', 'A', 'D', 'C', 'C', 'D', 'C', 'B', 'E', 'C', 'C', 'A', 'E', 'E', 'A', 'B', 'C'],
  ['D', 'E', 'E', 'D', 'A', 'C', 'A', 'E', 'C', 'D', 'B', 'E', 'B', 'A', 'A', 'B', 'C', 'C', 'D', 'D', 'A', 'A', 'C', 'D'],
  ['A', 'E', 'E', 'D', 'D', 'B', 'B', 'E', 'B', 'C', 'E', 'D', 'B', 'D', 'E', 'D', 'A', 'A', 'B', 'D', 'A', 'B', 'E', 'B'],
  ['D', 'E', 'C', 'E', 'D', 'A', 'A', 'C', 'D', 'A', 'E', 'B', 'C', 'A', 'D', 'A', 'E', 'E', 'B', 'D', 'B', 'A', 'C', 'E'],
  ['B', 'C', 'D', 'B', 'C', 'E', 'A', 'D', 'B', 'D', 'C', 'E', 'B', 'A', 'D', 'C', 'A', 'D', 'B', 'B', 'E', 'C', 'A', 'D'],
  ['C', 'B', 'E', 'D', 'D', 'D', 'B', 'A', 'C', 'B', 'E', 'D', 'A', 'C', 'B', 'E', 'E', 'A', 'A', 'B', 'D', 'C', 'A', 'E'],
  ['A', 'C', 'B', 'D', 'C', 'A', 'D', 'C', 'B', 'D', 'C', 'D', 'A', 'C', 'E', 'C', 'D', 'A', 'C', 'B', 'D', 'A', 'D', 'E'],
  ['C', 'E', 'D', 'B', 'E', 'D', 'A', 'B', 'C', 'D', 'C', 'E', 'A', 'B', 'A', 'D', 'B', 'C', 'E', 'B', 'D', 'E', 'B', 'D'],
  ['E', 'C', 'B', 'D', 'A', 'D', 'A', 'D', 'E', 'B', 'A', 'A', 'D', 'C', 'B', 'D', 'E', 'D', 'A', 'C', 'B', 'E', 'C', 'A'],
];

async function main() {
  console.log('Seeding Edebiyat Denemeleri - structure (sections, tests, questions)');

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
        description: 'TYT Edebiyat deneme kitabı - 16 deneme, her denemede 24 soru',
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
        description: 'TYT Edebiyat deneme kitabı - 16 deneme, her denemede 24 soru',
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
      description: '16 edebiyat denemesi',
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
        timeLimit: 40 * 60, // 40 dakika
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
  console.log(`✓ 16 tests created`);
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
