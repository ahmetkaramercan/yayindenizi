import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient() as any;

const BOOK_TITLE = 'Dil Bilgisi Soru Bankası';

// Konu bölümleri: bölümdeki tüm sorular aynı kazanımı alır.
// section title → kazanım kodu
const SECTION_OUTCOME_MAP: Record<string, string> = {
  'Ses Bilgisi':                          'DB.1',
  'Yazım Kuralları':                      'DB.2',
  'Noktalama İşaretleri':               'DB.3',
  'Sözcükte Yapı':                        'DB.4',
  'İsim (Ad) - İsim Tamlaması':          'DB.5',
  'Sıfat (Ön Ad) - Sıfat Tamlaması':    'DB.6',
  'Zamir (Adıl)':                         'DB.7',
  'Zarf (Belirteç)':                      'DB.8',
  'Edat (İlgeç) - Bağlaç - Ünlem':      'DB.9',
  'Fiil (Eylem)':                         'DB.10',
  'Fiilde Çatı':                          'DB.11',
  'Fiilimsi (Eylemsi)':                  'DB.12',
  'Cümlenin Ögeleri':                    'DB.13',
  'Cümle Çeşitleri':                     'DB.14',
  'Karma Dil Bilgisi Sorular':           'DB.15',
};

// Karma testler için soru bazlı kazanım eşlemeleri.
// Şu an karma bölüm tümden DB.15 alıyor; ilerleyen süreçte buraya per-soru kayıtlar eklenebilir.
const KARMA_MAPPINGS: { sectionTitle: string; testTitle: string; questionNo: number; code: string }[] = [
  // Örnek format:
  // { sectionTitle: 'Karma Dil Bilgisi Sorular', testTitle: 'Test 1', questionNo: 1, code: 'DB.1' },
];

async function main() {
  console.log('Seeding Dil Bilgisi Soru Bankası - question-outcome mappings');

  const book = await prisma.book.findFirst({
    where: { title: BOOK_TITLE },
    select: { id: true },
  });
  if (!book) {
    throw new Error(`Book "${BOOK_TITLE}" not found. Run seed:dilbilgisi:sorubankasi:structure first.`);
  }
  const bookId = book.id;

  const outcomes = await prisma.learningOutcome.findMany({
    where: { bookId },
    select: { id: true, code: true },
  });
  const outcomeMap = new Map<string, string>(outcomes.map((o: any) => [o.code, o.id]));

  const sections = await prisma.section.findMany({
    where: { bookId },
    select: { id: true, title: true },
  });
  const sectionMap = new Map<string, string>(sections.map((s: any) => [s.title, s.id]));

  const deleted = await prisma.questionOutcome.deleteMany({
    where: { question: { test: { section: { bookId } } } },
  });
  console.log(`✓ Removed ${deleted.count} old mappings`);

  let mappingCount = 0;
  let skippedCount = 0;

  // === KONU BÖLÜMLERİ: tüm sorular aynı kazanımı alır ===
  for (const [sectionTitle, outcomeCode] of Object.entries(SECTION_OUTCOME_MAP)) {
    const sectionId = sectionMap.get(sectionTitle);
    if (!sectionId) {
      console.warn(`⚠ Section not found: "${sectionTitle}"`);
      skippedCount++;
      continue;
    }

    const outcomeId = outcomeMap.get(outcomeCode);
    if (!outcomeId) {
      console.warn(`⚠ Outcome not found for code: ${outcomeCode}`);
      skippedCount++;
      continue;
    }

    const questions = await prisma.question.findMany({
      where: { test: { sectionId } },
      select: { id: true },
    });

    for (const question of questions) {
      await prisma.questionOutcome.create({
        data: {
          questionId: question.id,
          learningOutcomeId: outcomeId,
        },
      });
      mappingCount++;
    }

    console.log(`✓ ${questions.length} questions mapped → ${outcomeCode} (${sectionTitle})`);
  }

  // === KARMA TESTLER: her soru ayrı kazanım ===
  if (KARMA_MAPPINGS.length > 0) {
    for (const row of KARMA_MAPPINGS) {
      const sectionId = sectionMap.get(row.sectionTitle);
      if (!sectionId) {
        console.warn(`⚠ Section not found: "${row.sectionTitle}"`);
        skippedCount++;
        continue;
      }

      const test = await prisma.test.findFirst({
        where: { sectionId, title: row.testTitle },
        select: { id: true },
      });
      if (!test) {
        console.warn(`⚠ Test not found: "${row.testTitle}" in "${row.sectionTitle}"`);
        skippedCount++;
        continue;
      }

      const question = await prisma.question.findFirst({
        where: { testId: test.id, orderIndex: row.questionNo - 1 },
        select: { id: true },
      });
      if (!question) {
        console.warn(`⚠ Question not found: Q${row.questionNo} in "${row.testTitle}"`);
        skippedCount++;
        continue;
      }

      const outcomeId = outcomeMap.get(row.code);
      if (!outcomeId) {
        console.warn(`⚠ Outcome not found for code: ${row.code}`);
        skippedCount++;
        continue;
      }

      await prisma.questionOutcome.create({
        data: {
          questionId: question.id,
          learningOutcomeId: outcomeId,
        },
      });
      mappingCount++;
    }
  }

  console.log(`\n✓ ${mappingCount} question-outcome mappings created`);
  if (skippedCount > 0) console.log(`⚠ ${skippedCount} skipped`);

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
