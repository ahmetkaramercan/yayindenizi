import { PrismaClient, BookCategory } from '@prisma/client';

const prisma = new PrismaClient() as any;

const BOOK_TITLE = 'TYT Türkçe Denemeleri';
const BOOK_IMAGE_URL = 'photos/tyt_turkce_denemeleri.jpeg';

const LETTER_TO_INDEX: Record<string, number> = {
  A: 0, B: 1, C: 2, D: 3, E: 4,
};

// 16 deneme, her denemede 40 soru
const ANSWER_KEYS: string[][] = [
  // Deneme 1
  ['E','B','D','C','B','A','E','C','A','B','D','C','A','E','E','E','D','E','A','A','E','C','A','B','B','A','D','C','C','D','D','B','B','C','D','C','B','E','D','A'],
  // Deneme 2
  ['B','D','E','C','A','D','A','C','B','B','D','A','D','A','E','C','C','B','B','E','C','C','B','A','A','E','E','D','A','D','E','B','D','A','C','E','D','E','C','B'],
  // Deneme 3
  ['E','D','D','E','B','C','C','A','E','E','A','D','B','B','C','A','B','A','B','D','C','C','D','E','E','B','D','B','A','A','C','C','E','E','D','B','D','A','C','A'],
  // Deneme 4
  ['D','C','E','C','E','A','B','E','D','A','C','E','B','B','D','E','C','A','D','A','B','C','E','A','C','B','C','E','D','A','D','D','B','B','E','D','A','B','A','C'],
  // Deneme 5
  ['C','B','D','E','A','A','E','C','C','D','D','B','B','D','E','D','D','C','B','A','C','E','A','B','E','B','A','C','A','D','E','E','C','B','A','E','D','A','B','C'],
  // Deneme 6
  ['C','A','E','D','D','E','B','C','D','C','D','C','A','A','E','C','E','A','A','D','D','A','E','B','D','E','B','B','C','C','D','C','A','B','B','B','E','B','D','A'],
  // Deneme 7
  ['E','E','A','A','D','C','C','D','E','C','D','D','A','B','A','A','C','C','B','D','A','C','B','D','E','C','B','E','B','B','B','E','D','A','C','A','B','E','E','D'],
  // Deneme 8
  ['A','C','E','C','A','B','D','B','D','D','C','D','E','B','E','B','A','D','E','A','E','D','A','E','C','A','C','C','E','A','B','D','B','E','A','B','C','B','C','D'],
  // Deneme 9
  ['D','B','E','B','A','E','A','D','B','C','D','E','E','A','D','C','B','C','C','C','B','A','E','C','B','C','E','D','D','A','A','A','C','B','B','A','D','E','D','A'],
  // Deneme 10
  ['A','E','E','B','E','D','C','B','D','A','A','C','B','A','E','D','D','D','C','C','D','E','B','B','D','B','C','E','A','C','B','A','C','B','C','D','A','E','E','A'],
  // Deneme 11
  ['B','B','C','E','D','C','C','A','C','D','A','E','B','A','E','D','D','A','C','E','A','E','A','A','D','B','E','C','D','B','C','C','B','D','B','B','E','B','D','A'],
  // Deneme 12
  ['C','B','B','E','A','B','C','B','A','E','E','D','A','C','D','E','D','A','B','C','B','D','D','E','C','A','E','B','C','E','A','C','C','A','B','E','D','E','C','B'],
  // Deneme 13
  ['A','E','B','D','C','C','A','B','B','D','A','D','E','D','B','E','A','E','C','C','B','A','C','A','D','C','B','E','A','A','D','E','B','E','A','B','E','D','C','D'],
  // Deneme 14
  ['C','B','B','A','B','D','C','E','D','E','A','E','A','D','E','A','A','D','E','C','B','C','E','C','E','B','D','C','A','B','B','A','D','C','E','C','D','B','D','A'],
  // Deneme 15
  ['A','C','D','C','E','E','D','D','E','D','A','C','D','E','A','B','E','C','B','C','A','A','A','C','B','B','D','B','C','D','A','E','A','D','B','E','E','B','D','E'],
  // Deneme 16
  ['E','B','D','C','B','A','E','C','A','B','D','C','A','E','E','E','D','E','A','A','E','C','A','B','B','A','D','C','C','D','D','B','B','C','D','C','B','E','D','A'],
];

async function main() {
  console.log(`Seeding "${BOOK_TITLE}" - structure (sections, tests, questions)`);

  let book = await prisma.book.findFirst({
    where: { title: BOOK_TITLE },
    select: { id: true },
  });

  if (!book) {
    book = await prisma.book.create({
      data: {
        title: BOOK_TITLE,
        description: 'TYT Türkçe deneme sınavları - 16 deneme, her denemede 40 soru',
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
        description: 'TYT Türkçe deneme sınavları - 16 deneme, her denemede 40 soru',
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
      description: '16 TYT Türkçe denemesi',
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
        timeLimit: answers.length * 72, // ~48 dakika (40 soru)
        sectionId: section.id,
      },
    });

    const questions = answers.map((letter, orderIndex) => ({
      text: '',
      optionA: 'A',
      optionB: 'B',
      optionC: 'C',
      optionD: 'D',
      optionE: 'E',
      correctAnswerIndex: LETTER_TO_INDEX[letter.toUpperCase()] ?? 4,
      orderIndex,
      testId: test.id,
    }));

    await prisma.question.createMany({ data: questions });
    totalQuestions += questions.length;
  }

  console.log(`✓ 1 section created`);
  console.log(`✓ ${ANSWER_KEYS.length} tests created`);
  console.log(`✓ ${totalQuestions} questions created`);

  console.log('\n=== VALIDATION ===');
  const sectionCount = await prisma.section.count({ where: { bookId } });
  const testCount = await prisma.test.count({ where: { section: { bookId } } });
  const questionCount = await prisma.question.count({ where: { test: { section: { bookId } } } });
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
