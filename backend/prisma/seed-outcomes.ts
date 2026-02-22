import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

const BOOK_ID = 'ff865cff-1c3b-4464-b044-4c29ec0aa622';

const OUTCOMES: { code: string; name: string; category: string }[] = [
  { code: '21.3', name: 'Anlatım Teknikleri ve Düşünceyi Geliştirme Yolları', category: 'Paragraf' },
  { code: '21.4.1', name: 'Paragrafı İkiye Ayırma', category: 'Paragraf Yapısı' },
  { code: '21.4.2', name: 'Paragrafta Boş Bırakılan Yerleri Tamamlama', category: 'Paragraf Yapısı' },
  { code: '21.4.3', name: 'Paragrafta Anlatım Akışını Bozan Cümle', category: 'Paragraf Yapısı' },
  { code: '21.4.4', name: 'Paragrafa Cümle Yerleştirme', category: 'Paragraf Yapısı' },
  { code: '21.4.5', name: 'Cümlelerden Paragraf Oluşturma', category: 'Paragraf Yapısı' },
  { code: '21.4.6', name: 'Paragrafta Cümlelerin Yerini Değiştirme', category: 'Paragraf Yapısı' },
  { code: '21.5.1', name: 'Paragrafta Ana Düşünce (Ana Fikir)', category: 'Paragraf Anlam' },
  { code: '21.5.2', name: 'Paragrafta Yardımcı Düşünceler', category: 'Paragraf Anlam' },
  { code: '21.5.3', name: 'Paragrafın Karşılık Olduğu Soruyu Belirleme', category: 'Paragraf Anlam' },
  { code: '21.5.4', name: 'Paragrafın Yorumlanması', category: 'Paragraf Anlam' },
  { code: '21.5.6', name: 'Paragrafın Konusu', category: 'Paragraf Anlam' },
  { code: '21.5.10', name: 'Paragrafa Özgü Soru Kökü', category: 'Paragraf Anlam' },
  { code: '21.5.11', name: 'Bir Paragrafa Bağlı Çoklu Sorular', category: 'Paragraf Anlam' },
];

interface RawRow {
  testNo: string;
  questionNo: string;
  codes: string[];
}

const RAW_DATA: RawRow[] = [
  // TEST 1
  { testNo: '1', questionNo: '1', codes: ['21.5.4'] },
  { testNo: '1', questionNo: '2', codes: ['21.5.6'] },
  { testNo: '1', questionNo: '3', codes: ['21.5.2'] },
  { testNo: '1', questionNo: '4', codes: ['21.5.4'] },
  { testNo: '1', questionNo: '5', codes: ['21.4.2'] },
  { testNo: '1', questionNo: '6', codes: ['21.3'] },
  { testNo: '1', questionNo: '7', codes: ['21.5.11', '21.5.2'] },
  { testNo: '1', questionNo: '8', codes: ['21.5.11', '21.5.6'] },
  // TEST 2
  { testNo: '2', questionNo: '1', codes: ['21.5.2'] },
  { testNo: '2', questionNo: '2', codes: ['21.5.1'] },
  { testNo: '2', questionNo: '3', codes: ['21.5.2'] },
  { testNo: '2', questionNo: '4', codes: ['21.4.3'] },
  { testNo: '2', questionNo: '5', codes: ['21.5.3'] },
  { testNo: '2', questionNo: '6', codes: ['21.5.1'] },
  { testNo: '2', questionNo: '7', codes: ['21.4.2'] },
  // TEST 3
  { testNo: '3', questionNo: '1', codes: ['21.5.2'] },
  { testNo: '3', questionNo: '2', codes: ['21.5.1'] },
  { testNo: '3', questionNo: '3', codes: ['21.5.6'] },
  { testNo: '3', questionNo: '4', codes: ['21.5.6'] },
  { testNo: '3', questionNo: '5', codes: ['21.3'] },
  { testNo: '3', questionNo: '6', codes: ['21.4.6'] },
  { testNo: '3', questionNo: '7', codes: ['21.4.4'] },
  { testNo: '3', questionNo: '8', codes: ['21.5.2'] },
  // TEST 4
  { testNo: '4', questionNo: '1', codes: ['21.4.1'] },
  { testNo: '4', questionNo: '2', codes: ['21.5.6'] },
  { testNo: '4', questionNo: '3', codes: ['21.4.2'] },
  { testNo: '4', questionNo: '4', codes: ['21.5.2'] },
  { testNo: '4', questionNo: '5', codes: ['21.3'] },
  { testNo: '4', questionNo: '6', codes: ['21.5.2'] },
  { testNo: '4', questionNo: '7', codes: ['21.5.2'] },
  { testNo: '4', questionNo: '8', codes: ['21.5.1'] },
];

async function main() {
  console.log('Seeding outcomes for book:', BOOK_ID);

  // 1. Upsert all outcomes
  for (const o of OUTCOMES) {
    await prisma.learningOutcome.upsert({
      where: { bookId_code: { bookId: BOOK_ID, code: o.code } },
      update: { name: o.name, category: o.category },
      create: { code: o.code, name: o.name, category: o.category, bookId: BOOK_ID },
    });
  }
  console.log(`✓ ${OUTCOMES.length} outcomes upserted`);

  // 2. Build outcome code -> id map
  const outcomes = await prisma.learningOutcome.findMany({ where: { bookId: BOOK_ID } });
  const outcomeMap = new Map(outcomes.map((o) => [o.code, o.id]));

  // 3. For each test-question row, find question and link outcomes
  let mappingCount = 0;
  let skippedCount = 0;

  const testsByNumber = new Map<string, string>();

  for (const row of RAW_DATA) {
    const testTitle = `Başlangıç - Test ${row.testNo}`;

    if (!testsByNumber.has(row.testNo)) {
      const test = await prisma.test.findFirst({
        where: {
          title: testTitle,
          section: { bookId: BOOK_ID },
        },
        select: { id: true },
      });
      if (test) testsByNumber.set(row.testNo, test.id);
    }

    const testId = testsByNumber.get(row.testNo);
    if (!testId) {
      console.warn(`⚠ Test not found: ${testTitle}`);
      skippedCount++;
      continue;
    }

    const questionIndex = parseInt(row.questionNo, 10) - 1;
    const question = await prisma.question.findFirst({
      where: { testId, orderIndex: questionIndex },
      select: { id: true },
    });

    if (!question) {
      console.warn(`⚠ Question not found: Test ${row.testNo} Q${row.questionNo} (orderIndex=${questionIndex})`);
      skippedCount++;
      continue;
    }

    for (const code of row.codes) {
      const outcomeId = outcomeMap.get(code);
      if (!outcomeId) {
        console.warn(`⚠ Outcome not found for code: ${code}`);
        skippedCount++;
        continue;
      }

      await prisma.questionOutcome.upsert({
        where: {
          questionId_learningOutcomeId: {
            questionId: question.id,
            learningOutcomeId: outcomeId,
          },
        },
        update: {},
        create: {
          questionId: question.id,
          learningOutcomeId: outcomeId,
        },
      });
      mappingCount++;
    }
  }

  console.log(`✓ ${mappingCount} question-outcome mappings created`);
  if (skippedCount > 0) console.log(`⚠ ${skippedCount} skipped`);

  // 4. Validate
  const totalOutcomes = await prisma.learningOutcome.count({ where: { bookId: BOOK_ID } });
  const totalMappings = await prisma.questionOutcome.count();
  const orphanMappings = await prisma.questionOutcome.count({
    where: {
      OR: [
        { question: { test: { section: { bookId: { not: BOOK_ID } } } } },
      ],
    },
  });

  console.log('\n=== VALIDATION ===');
  console.log(`Outcomes: ${totalOutcomes}`);
  console.log(`Mappings: ${totalMappings}`);
  console.log(`Orphan mappings: ${orphanMappings}`);
  console.log('✓ Done');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
