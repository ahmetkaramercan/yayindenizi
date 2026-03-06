import { PrismaClient, BookCategory } from '@prisma/client';

const prisma = new PrismaClient() as any;

const BOOK_TITLE = 'Dil Bilgisi Soru Bankası';
const BOOK_IMAGE_URL = 'photos/dil_bilgisi_soru_bankasi.jpeg';

const LETTER_TO_INDEX: Record<string, number> = {
  A: 0,
  B: 1,
  C: 2,
  D: 3,
  E: 4,
};

const SECTIONS: {
  title: string;
  description: string;
  tests: { title: string; answers: string[] }[];
}[] = [
  {
    title: 'Ses Bilgisi',
    description: 'Ses bilgisine ait testler',
    tests: [
      { title: 'Test 1', answers: ['E', 'D', 'B', 'A', 'A', 'C', 'C', 'E'] },
      { title: 'Test 2', answers: ['A', 'D', 'D', 'D', 'E', 'D', 'E', 'D', 'E', 'A'] },
      { title: 'Test 3', answers: ['A', 'B', 'B', 'E', 'A', 'A', 'E', 'A', 'C', 'E', 'C'] },
      { title: 'Test 4', answers: ['D', 'B', 'B', 'D', 'A', 'E', 'E', 'E', 'D', 'D', 'E'] },
      { title: 'Test 5', answers: ['E', 'A', 'D', 'C', 'B', 'D', 'E', 'E', 'C', 'B', 'C'] },
    ],
  },
  {
    title: 'Yazım Kuralları',
    description: 'Yazım kurallarına ait testler',
    tests: [
      { title: 'Test 1',  answers: ['D', 'B', 'C', 'C', 'E', 'A', 'A', 'E', 'D'] },
      { title: 'Test 2',  answers: ['C', 'E', 'E', 'B', 'D', 'A', 'D', 'C', 'C', 'C'] },
      { title: 'Test 3',  answers: ['D', 'B', 'B', 'C', 'A', 'A', 'D', 'B', 'D', 'D', 'C', 'E'] },
      { title: 'Test 4',  answers: ['E', 'B', 'E', 'B', 'D', 'B', 'D', 'C', 'A', 'A', 'A', 'D'] },
      { title: 'Test 5',  answers: ['B', 'E', 'C', 'E', 'D', 'C', 'A', 'D', 'D', 'E', 'D', 'B'] },
      { title: 'Test 6',  answers: ['C', 'E', 'A', 'E', 'D', 'B', 'E', 'C', 'B', 'D', 'D', 'B'] },
      { title: 'Test 7',  answers: ['C', 'A', 'D', 'A', 'C', 'C', 'A', 'D', 'B', 'D', 'B', 'C'] },
      { title: 'Test 8',  answers: ['C', 'B', 'B', 'D', 'A', 'B', 'E', 'A', 'D', 'A', 'E', 'C'] },
      { title: 'Test 9',  answers: ['A', 'C', 'C', 'A', 'C', 'E', 'C', 'B', 'C', 'B', 'A'] },
      { title: 'Test 10', answers: ['D', 'D', 'C', 'D', 'D', 'D', 'D', 'B', 'E', 'C'] },
    ],
  },
  {
    title: 'Noktalama İşaretleri',
    description: 'Noktalama işaretlerine ait testler',
    tests: [
      { title: 'Test 1',  answers: ['D', 'C', 'C', 'E', 'C', 'E', 'D', 'D', 'C', 'C'] },
      { title: 'Test 2',  answers: ['B', 'E', 'E', 'B', 'E', 'C', 'B', 'A', 'C', 'E', 'D', 'C'] },
      { title: 'Test 3',  answers: ['A', 'E', 'D', 'E', 'E', 'B', 'B', 'C', 'B', 'C', 'E', 'D'] },
      { title: 'Test 4',  answers: ['D', 'B', 'A', 'C', 'E', 'C', 'B', 'E', 'E', 'A', 'B', 'E'] },
      { title: 'Test 5',  answers: ['E', 'B', 'D', 'E', 'E', 'D', 'A', 'E', 'C', 'C', 'C', 'A'] },
      { title: 'Test 6',  answers: ['C', 'D', 'D', 'D', 'A', 'D', 'E', 'A', 'D', 'D', 'A'] },
      { title: 'Test 7',  answers: ['D', 'A', 'D', 'C', 'B', 'D', 'E', 'B', 'E', 'D', 'E', 'C'] },
      { title: 'Test 8',  answers: ['C', 'C', 'E', 'E', 'B', 'E', 'C', 'C', 'E', 'E', 'D'] },
      { title: 'Test 9',  answers: ['C', 'B', 'E', 'C', 'C', 'E', 'B', 'B', 'D', 'D', 'C', 'C'] },
      { title: 'Test 10', answers: ['C', 'A', 'A', 'D', 'C', 'B', 'D', 'E', 'B', 'C'] },
    ],
  },
  {
    title: 'Sözcükte Yapı',
    description: 'Sözcükte yapıya ait testler',
    tests: [
      { title: 'Test 1', answers: ['A', 'C', 'C', 'E', 'D', 'B', 'E', 'E', 'A', 'D', 'E', 'B'] },
      { title: 'Test 2', answers: ['D', 'E', 'D', 'C', 'E', 'B', 'A', 'C', 'E', 'C', 'C'] },
      { title: 'Test 3', answers: ['A', 'B', 'E', 'E', 'C', 'A', 'B', 'B', 'D', 'D', 'B'] },
      { title: 'Test 4', answers: ['D', 'E', 'A', 'C', 'E', 'C', 'C', 'A', 'D', 'E'] },
      { title: 'Test 5', answers: ['D', 'D', 'B', 'C', 'A', 'E', 'D', 'C', 'E', 'B'] },
      { title: 'Test 6', answers: ['D', 'D', 'B', 'A', 'C', 'D', 'D', 'C', 'B', 'A', 'C'] },
    ],
  },
  {
    title: 'İsim (Ad) - İsim Tamlaması',
    description: 'İsim ve isim tamlamasına ait testler',
    tests: [
      { title: 'Test 1', answers: ['B', 'C', 'B', 'E', 'E', 'B', 'D', 'C', 'E', 'B'] },
      { title: 'Test 2', answers: ['E', 'C', 'D', 'B', 'E', 'A', 'E', 'B', 'C', 'C'] },
      { title: 'Test 3', answers: ['B', 'E', 'B', 'D', 'C', 'A', 'A', 'B', 'D', 'D', 'E'] },
      { title: 'Test 4', answers: ['C', 'C', 'B', 'C', 'C', 'B', 'B', 'C', 'A'] },
    ],
  },
  {
    title: 'Sıfat (Ön Ad) - Sıfat Tamlaması',
    description: 'Sıfat ve sıfat tamlamasına ait testler',
    tests: [
      { title: 'Test 1', answers: ['E', 'C', 'A', 'C', 'B', 'C', 'C', 'E', 'D', 'D'] },
      { title: 'Test 2', answers: ['A', 'A', 'C', 'A', 'B', 'D', 'D', 'C', 'D'] },
      { title: 'Test 3', answers: ['A', 'B', 'B', 'E', 'A', 'D', 'B', 'D', 'B', 'C', 'E'] },
      { title: 'Test 4', answers: ['A', 'C', 'E', 'E', 'E', 'B', 'E', 'B', 'E', 'E', 'A'] },
    ],
  },
  {
    title: 'Zamir (Adıl)',
    description: 'Zamir konusuna ait testler',
    tests: [
      { title: 'Test 1', answers: ['C', 'C', 'A', 'E', 'B', 'A', 'A', 'D', 'A'] },
      { title: 'Test 2', answers: ['E', 'D', 'D', 'A', 'B', 'D', 'E', 'D', 'B', 'B', 'C'] },
      { title: 'Test 3', answers: ['D', 'D', 'B', 'E', 'A', 'B', 'D', 'D', 'A', 'A', 'C'] },
      { title: 'Test 4', answers: ['E', 'E', 'B', 'C', 'D', 'D', 'D', 'C', 'B', 'E'] },
    ],
  },
  {
    title: 'Zarf (Belirteç)',
    description: 'Zarf konusuna ait testler',
    tests: [
      { title: 'Test 1', answers: ['A', 'E', 'C', 'B', 'B', 'B', 'E', 'E', 'C'] },
      { title: 'Test 2', answers: ['B', 'E', 'D', 'D', 'D', 'B', 'E', 'D', 'C', 'A', 'D'] },
      { title: 'Test 3', answers: ['E', 'A', 'B', 'D', 'E', 'C', 'D', 'D', 'C', 'D', 'C'] },
      { title: 'Test 4', answers: ['B', 'B', 'B', 'A', 'D', 'A', 'C', 'D', 'B', 'A', 'A'] },
    ],
  },
  {
    title: 'Edat (İlgeç) - Bağlaç - Ünlem',
    description: 'Edat, bağlaç ve ünleme ait testler',
    tests: [
      { title: 'Test 1', answers: ['A', 'C', 'B', 'E', 'B', 'D', 'A', 'D', 'D', 'E', 'A', 'D'] },
      { title: 'Test 2', answers: ['D', 'A', 'E', 'D', 'A', 'C', 'D', 'D', 'D'] },
      { title: 'Test 3', answers: ['A', 'A', 'B', 'C', 'A', 'E', 'A', 'B', 'B', 'D'] },
      { title: 'Test 4', answers: ['E', 'B', 'C', 'D', 'C', 'E', 'E', 'D', 'D', 'E'] },
    ],
  },
  {
    title: 'Fiil (Eylem)',
    description: 'Fiil konusuna ait testler',
    tests: [
      { title: 'Test 1', answers: ['D', 'A', 'E', 'A', 'B', 'C', 'A', 'E', 'B', 'A', 'D', 'B'] },
      { title: 'Test 2', answers: ['C', 'A', 'A', 'E', 'A', 'E', 'C', 'D', 'D', 'B', 'D'] },
      { title: 'Test 3', answers: ['B', 'B', 'E', 'C', 'A', 'D', 'C', 'D', 'B', 'B', 'D'] },
      { title: 'Test 4', answers: ['C', 'C', 'A', 'E', 'E', 'C', 'C', 'A', 'E'] },
      { title: 'Test 5', answers: ['C', 'C', 'C', 'A', 'B', 'E', 'D', 'E', 'C'] },
    ],
  },
  {
    title: 'Fiilde Çatı',
    description: 'Fiilde çatıya ait testler',
    tests: [
      { title: 'Test 1', answers: ['A', 'B', 'C', 'E', 'D', 'B', 'B', 'A', 'E', 'B', 'E'] },
      { title: 'Test 2', answers: ['A', 'A', 'B', 'A', 'A', 'B', 'E', 'C', 'B', 'C', 'E', 'A'] },
      { title: 'Test 3', answers: ['A', 'A', 'C', 'C', 'C', 'A', 'E', 'D', 'D', 'D', 'B'] },
      { title: 'Test 4', answers: ['A', 'D', 'D', 'C', 'C', 'A', 'E', 'E', 'B', 'E'] },
    ],
  },
  {
    title: 'Fiilimsi (Eylemsi)',
    description: 'Fiilimsi konusuna ait testler',
    tests: [
      { title: 'Test 1', answers: ['B', 'B', 'E', 'C', 'D', 'A', 'D', 'D', 'C', 'C', 'A', 'D'] },
      { title: 'Test 2', answers: ['E', 'B', 'A', 'B', 'D', 'D', 'C', 'A', 'C', 'D', 'E', 'B'] },
      { title: 'Test 3', answers: ['C', 'D', 'B', 'B', 'B', 'E', 'D', 'D', 'A', 'A', 'B', 'C'] },
      { title: 'Test 4', answers: ['B', 'D', 'C', 'D', 'B', 'A', 'E', 'D', 'C', 'A'] },
    ],
  },
  {
    title: 'Cümlenin Ögeleri',
    description: 'Cümlenin ögelerine ait testler',
    tests: [
      { title: 'Test 1', answers: ['E', 'D', 'D', 'D', 'D', 'D', 'A', 'D', 'D', 'C', 'A'] },
      { title: 'Test 2', answers: ['B', 'A', 'D', 'E', 'B', 'D', 'B', 'D', 'A', 'C', 'B'] },
      { title: 'Test 3', answers: ['C', 'D', 'A', 'E', 'C', 'E', 'B', 'D', 'C', 'C'] },
      { title: 'Test 4', answers: ['D', 'E', 'A', 'B', 'E', 'E', 'E', 'D', 'B', 'B', 'A'] },
      { title: 'Test 5', answers: ['D', 'D', 'C', 'E', 'C', 'B', 'B', 'D', 'D', 'E', 'A', 'B'] },
      { title: 'Test 6', answers: ['C', 'B', 'E', 'A', 'E', 'D', 'D', 'E', 'A', 'C', 'A'] },
    ],
  },
  {
    title: 'Cümle Çeşitleri',
    description: 'Cümle çeşitlerine ait testler',
    tests: [
      { title: 'Test 1', answers: ['C', 'B', 'E', 'E', 'E', 'A', 'C', 'E', 'E', 'B'] },
      { title: 'Test 2', answers: ['A', 'C', 'D', 'D', 'C', 'C', 'E', 'E', 'B'] },
      { title: 'Test 3', answers: ['B', 'E', 'E', 'C', 'B', 'D', 'C', 'B', 'C', 'B', 'D'] },
      { title: 'Test 4', answers: ['A', 'C', 'D', 'D', 'A', 'E', 'D', 'C', 'C', 'B', 'E', 'B'] },
    ],
  },
  {
    title: 'Karma Dil Bilgisi Sorular',
    description: 'Dil bilgisi konularını bir arada içeren karma testler',
    tests: [
      { title: 'Test 1',  answers: ['E', 'C', 'C', 'B', 'E', 'E', 'D', 'D', 'D', 'A', 'C'] },
      { title: 'Test 2',  answers: ['B', 'D', 'E', 'A', 'E', 'D', 'E', 'C', 'D', 'A', 'A'] },
      { title: 'Test 3',  answers: ['B', 'B', 'A', 'C', 'E', 'B', 'A', 'D', 'B', 'C', 'D'] },
      { title: 'Test 4',  answers: ['B', 'E', 'E', 'C', 'D', 'B', 'D', 'C', 'B', 'A'] },
      { title: 'Test 5',  answers: ['E', 'B', 'B', 'D', 'C', 'A', 'C', 'E', 'E', 'E', 'D', 'A'] },
      { title: 'Test 6',  answers: ['B', 'B', 'D', 'E', 'D', 'C', 'E', 'E', 'A', 'B'] },
      { title: 'Test 7',  answers: ['E', 'E', 'D', 'A', 'B', 'C', 'D', 'A', 'B'] },
      { title: 'Test 8',  answers: ['A', 'C', 'B', 'E', 'D', 'E', 'B', 'B', 'E'] },
      { title: 'Test 9',  answers: ['C', 'E', 'E', 'D', 'A', 'A', 'C', 'A', 'D'] },
      { title: 'Test 10', answers: ['D', 'E', 'E', 'E', 'E', 'D', 'E', 'C', 'B'] },
      { title: 'Test 11', answers: ['C', 'D', 'C', 'C', 'D', 'A', 'C', 'E', 'C'] },
      { title: 'Test 12', answers: ['A', 'B', 'B', 'D', 'D', 'A', 'C', 'D', 'A', 'B', 'C', 'C'] },
      { title: 'Test 13', answers: ['D', 'A', 'C', 'C', 'B', 'D', 'E', 'D', 'A', 'D', 'E', 'C'] },
    ],
  },
];

async function main() {
  console.log('Seeding Dil Bilgisi Soru Bankası - structure (sections, tests, questions)');

  let book = await prisma.book.findFirst({
    where: { title: BOOK_TITLE },
    select: { id: true },
  });

  if (!book) {
    book = await prisma.book.create({
      data: {
        title: BOOK_TITLE,
        description: 'TYT Dil Bilgisi konu bazlı soru bankası',
        imageUrl: BOOK_IMAGE_URL,
        category: BookCategory.KONU,
      },
      select: { id: true },
    });
    console.log(`✓ Book created: ${book.id}`);
  } else {
    await prisma.book.update({
      where: { id: book.id },
      data: {
        title: BOOK_TITLE,
        description: 'TYT Dil Bilgisi konu bazlı soru bankası',
        imageUrl: BOOK_IMAGE_URL,
        category: BookCategory.KONU,
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

  let totalSections = 0;
  let totalTests = 0;
  let totalQuestions = 0;

  for (let sIdx = 0; sIdx < SECTIONS.length; sIdx++) {
    const sectionData = SECTIONS[sIdx];

    const section = await prisma.section.create({
      data: {
        title: sectionData.title,
        description: sectionData.description,
        orderIndex: sIdx,
        bookId,
      },
    });
    totalSections++;

    for (let tIdx = 0; tIdx < sectionData.tests.length; tIdx++) {
      const testData = sectionData.tests[tIdx];

      const test = await prisma.test.create({
        data: {
          title: testData.title,
          description: testData.title,
          level: 1,
          timeLimit: testData.answers.length * 72, // ~72 saniye/soru
          sectionId: section.id,
        },
      });
      totalTests++;

      const questions = testData.answers.map((letter, orderIndex) => {
        const idx = LETTER_TO_INDEX[letter.toUpperCase()] ?? 0;
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
  }

  console.log(`✓ ${totalSections} sections created`);
  console.log(`✓ ${totalTests} tests created`);
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
