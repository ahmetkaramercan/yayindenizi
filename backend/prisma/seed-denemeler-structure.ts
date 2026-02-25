import { PrismaClient, BookCategory } from '@prisma/client';

const prisma = new PrismaClient();

const BOOK_TITLE = 'Paragraf Koçu Denemeleri';
const LEGACY_BOOK_TITLES = ['Paragraf Koçu Denemeleri Kitabı'];
const BOOK_IMAGE_URL = 'photos/paragraf_kocu_denemeleri.jpeg';

// A=0, B=1, C=2, D=3, E=4. F treated as E (typo in DENEME 17 Q12)
const LETTER_TO_INDEX: Record<string, number> = {
  A: 0,
  B: 1,
  C: 2,
  D: 3,
  E: 4,
  F: 4, // fallback for typo
};

// Section title, then 4 denemeler with 25 answers each (as letter strings)
const ANSWER_KEYS: { sectionTitle: string; denemeler: string[][] }[] = [
  {
    sectionTitle: 'BAŞLANGIÇ',
    denemeler: [
      ['B', 'C', 'D', 'E', 'E', 'B', 'D', 'A', 'A', 'D', 'B', 'A', 'C', 'C', 'E', 'D', 'C', 'E', 'D', 'B', 'A', 'C', 'B', 'E', 'A'],
      ['D', 'A', 'A', 'C', 'A', 'B', 'C', 'E', 'E', 'D', 'B', 'E', 'B', 'C', 'D', 'D', 'C', 'A', 'E', 'A', 'D', 'B', 'C', 'B', 'E'],
      ['B', 'B', 'A', 'D', 'D', 'A', 'C', 'A', 'E', 'C', 'D', 'C', 'E', 'E', 'C', 'B', 'A', 'B', 'B', 'C', 'C', 'A', 'E', 'A', 'D'],
      ['E', 'B', 'E', 'A', 'C', 'C', 'E', 'C', 'D', 'A', 'B', 'B', 'C', 'E', 'B', 'A', 'B', 'A', 'D', 'C', 'A', 'E', 'D', 'D', 'B'],
    ],
  },
  {
    sectionTitle: 'GELİŞİM',
    denemeler: [
      ['A', 'E', 'D', 'D', 'C', 'A', 'A', 'B', 'B', 'E', 'C', 'D', 'C', 'B', 'B', 'B', 'D', 'A', 'E', 'E', 'A', 'C', 'E', 'D', 'C'],
      ['B', 'D', 'C', 'D', 'E', 'A', 'C', 'B', 'A', 'C', 'B', 'A', 'B', 'A', 'C', 'C', 'A', 'E', 'A', 'E', 'C', 'E', 'C', 'D', 'B'],
      ['E', 'A', 'C', 'B', 'D', 'A', 'C', 'E', 'B', 'D', 'B', 'D', 'E', 'A', 'A', 'B', 'C', 'E', 'C', 'B', 'D', 'C', 'D', 'A', 'E'],
      ['B', 'B', 'C', 'B', 'C', 'A', 'D', 'E', 'C', 'D', 'C', 'A', 'E', 'B', 'A', 'C', 'B', 'E', 'D', 'D', 'B', 'D', 'A', 'C', 'D'],
    ],
  },
  {
    sectionTitle: 'İLERLEME',
    denemeler: [
      ['C', 'A', 'C', 'D', 'C', 'A', 'E', 'A', 'A', 'D', 'A', 'C', 'C', 'E', 'B', 'E', 'B', 'C', 'E', 'D', 'B', 'D', 'D', 'D', 'E'],
      ['C', 'D', 'B', 'C', 'A', 'A', 'C', 'D', 'E', 'B', 'A', 'B', 'C', 'E', 'A', 'C', 'E', 'D', 'B', 'B', 'D', 'A', 'E', 'D', 'E'],
      ['B', 'B', 'C', 'D', 'D', 'D', 'D', 'B', 'C', 'C', 'A', 'A', 'C', 'A', 'A', 'E', 'C', 'D', 'B', 'D', 'A', 'D', 'B', 'C', 'E'],
      ['C', 'C', 'E', 'C', 'D', 'D', 'B', 'C', 'B', 'C', 'E', 'A', 'C', 'C', 'B', 'B', 'D', 'B', 'A', 'E', 'D', 'A', 'D', 'E', 'A'],
    ],
  },
  {
    sectionTitle: 'UZMANLAŞMA',
    denemeler: [
      ['E', 'D', 'A', 'D', 'A', 'E', 'D', 'C', 'C', 'A', 'E', 'B', 'B', 'D', 'E', 'A', 'D', 'B', 'C', 'A', 'E', 'C', 'D', 'B', 'B'],
      ['E', 'A', 'B', 'D', 'C', 'C', 'D', 'B', 'C', 'A', 'E', 'B', 'A', 'B', 'A', 'E', 'D', 'D', 'A', 'E', 'D', 'B', 'A', 'B', 'C'],
      ['B', 'A', 'C', 'A', 'B', 'A', 'A', 'E', 'D', 'B', 'D', 'B', 'C', 'B', 'C', 'B', 'C', 'B', 'E', 'C', 'A', 'D', 'C', 'E', 'E'],
      ['A', 'C', 'B', 'E', 'A', 'D', 'C', 'E', 'B', 'B', 'B', 'C', 'D', 'E', 'C', 'E', 'D', 'C', 'D', 'D', 'B', 'A', 'B', 'A', 'D'],
    ],
  },
  {
    sectionTitle: 'YÜKSELİŞ',
    denemeler: [
      ['E', 'C', 'A', 'B', 'A', 'D', 'C', 'C', 'B', 'A', 'A', 'E', 'E', 'B', 'C', 'C', 'D', 'D', 'B', 'E', 'D', 'C', 'D', 'B', 'D'], // Q12: F -> E
      ['C', 'B', 'D', 'C', 'A', 'B', 'E', 'C', 'A', 'A', 'E', 'D', 'D', 'C', 'E', 'D', 'B', 'E', 'A', 'B', 'A', 'B', 'C', 'E', 'A'],
      ['C', 'C', 'A', 'C', 'D', 'E', 'D', 'B', 'B', 'E', 'A', 'D', 'C', 'A', 'B', 'C', 'E', 'D', 'A', 'D', 'A', 'E', 'C', 'B', 'B'],
      ['B', 'C', 'E', 'C', 'A', 'A', 'D', 'E', 'C', 'B', 'C', 'B', 'B', 'E', 'A', 'E', 'D', 'C', 'C', 'D', 'A', 'A', 'D', 'B', 'D'],
    ],
  },
  {
    sectionTitle: 'ZİRVE',
    denemeler: [
      ['A', 'B', 'E', 'C', 'A', 'A', 'C', 'C', 'C', 'D', 'D', 'D', 'C', 'E', 'B', 'B', 'A', 'B', 'A', 'E', 'A', 'E', 'C', 'B', 'E'],
      ['E', 'C', 'B', 'D', 'D', 'C', 'A', 'E', 'A', 'C', 'C', 'B', 'B', 'E', 'D', 'C', 'A', 'B', 'B', 'D', 'A', 'A', 'E', 'E', 'C'],
      ['D', 'E', 'C', 'B', 'A', 'A', 'D', 'A', 'C', 'E', 'E', 'E', 'C', 'B', 'C', 'C', 'D', 'C', 'B', 'B', 'D', 'A', 'B', 'E', 'D'],
      ['B', 'D', 'E', 'E', 'D', 'E', 'B', 'C', 'D', 'E', 'C', 'A', 'B', 'A', 'B', 'E', 'C', 'B', 'C', 'A', 'D', 'B', 'C', 'C', 'A'],
    ],
  },
];

async function main() {
  console.log('Seeding Paragraf Koçu Denemeleri - structure (sections, tests, questions)');

  const candidateBooks = await prisma.book.findMany({
    where: { title: { in: [BOOK_TITLE, ...LEGACY_BOOK_TITLES] } },
    select: { id: true },
  });
  const emptyBookIds: string[] = [];
  for (const candidate of candidateBooks) {
    const sectionCount = await prisma.section.count({
      where: { bookId: candidate.id },
    });
    if (sectionCount === 0) {
      emptyBookIds.push(candidate.id);
    }
  }

  const deletedEmptyBooks = await prisma.book.deleteMany({
    where: { id: { in: emptyBookIds } },
  });
  if (deletedEmptyBooks.count > 0) {
    console.log(`✓ Removed ${deletedEmptyBooks.count} empty legacy book record(s)`);
  }

  let book = await prisma.book.findFirst({
    where: { title: { in: [BOOK_TITLE, ...LEGACY_BOOK_TITLES] } },
    select: { id: true, title: true },
  });

  if (!book) {
    book = await prisma.book.create({
      data: {
        title: BOOK_TITLE,
        description: 'TYT Paragraf deneme kitabı - her seviyede 4 deneme, her denemede 25 soru',
        imageUrl: BOOK_IMAGE_URL,
        category: BookCategory.DENEME,
      },
      select: { id: true, title: true },
    });
    console.log(`✓ Book created: ${book.id}`);
  } else {
    await prisma.book.update({
      where: { id: book.id },
      data: {
        title: BOOK_TITLE,
        description: 'TYT Paragraf deneme kitabı - her seviyede 4 deneme, her denemede 25 soru',
        imageUrl: BOOK_IMAGE_URL,
        category: BookCategory.DENEME,
      },
    });
    console.log(`✓ Book found: ${book.id}`);
  }

  const bookId = book.id;

  // Delete existing sections for this book (cascade deletes tests, questions, question_outcomes)
  const existingSections = await prisma.section.findMany({
    where: { bookId },
    select: { id: true },
  });
  if (existingSections.length > 0) {
    await prisma.section.deleteMany({ where: { bookId } });
    console.log(`✓ Removed ${existingSections.length} existing sections`);
  }

  let denemeNo = 1;
  let totalQuestions = 0;

  for (let sIdx = 0; sIdx < ANSWER_KEYS.length; sIdx++) {
    const { sectionTitle, denemeler } = ANSWER_KEYS[sIdx];
    const section = await prisma.section.create({
      data: {
        title: sectionTitle,
        description: `${sectionTitle} seviyesi - 4 deneme`,
        orderIndex: sIdx,
        bookId,
      },
    });

    for (let dIdx = 0; dIdx < denemeler.length; dIdx++) {
      const answers = denemeler[dIdx];
      const testTitle = `Deneme ${denemeNo}`;
      const test = await prisma.test.create({
        data: {
          title: testTitle,
          description: `${sectionTitle} - ${testTitle}`,
          level: sIdx + 1,
          timeLimit: 45 * 60, // 45 dakika
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
      denemeNo++;
    }
  }

  console.log(`✓ 6 sections created`);
  console.log(`✓ 24 tests created`);
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
