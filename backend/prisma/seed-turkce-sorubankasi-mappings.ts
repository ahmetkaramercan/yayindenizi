import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient() as any;

const BOOK_TITLE = 'Türkçe Soru Bankası';

// Konu bölümleri: bölümdeki tüm sorular aynı kazanım kodunu alır.
// section title → kazanım kodu
// NOT: Karma test bölümleri buraya eklenmez; KARMA_MAPPINGS kullanılır.
const SECTION_OUTCOME_MAP: Record<string, string> = {
  'Sözcüğün Anlamı - Anlam Olayları':    'TR.1',
  'Söz Öbeğinin Anlamı':                  'TR.2',
  'Deyim - Atasözü - İkileme':            'TR.3',
  'Sözcükte ve Sözcük Gruplarında Anlam': 'TR.4',
  'Cümlede Anlam':                         'TR.5',
  'Cümle Oluşturma - Cümle Tamamlama':   'TR.6',
  'Cümlede Kavramlar':                     'TR.7',
  'Cümlede Anlatım':                       'TR.8',
  'Paragrafta Anlatım':                    'TR.9',
  'Paragrafta Yapı':                       'TR.10',
  'Paragrafta Anlam':                      'TR.11',
  'Zincir Soru':                           'TR.12',
  // 'Paragraf Karma Sorular' → soru bazlı kazanımlar KARMA_MAPPINGS'te tanımlı
  'Cümlede Anlam ve Anlatım Karma Test':                                'TR.14',
  // === SES VE YAZI ===
  'Ses Bilgisi':                                                         'TR.15',
  'Yazım Kuralları':                                                     'TR.16',
  'Noktalama İşaretleri':                                               'TR.17',
  'Ses Bilgisi - Yazım Kuralları - Noktalama İşaretleri Karma Testler': 'TR.18',
  // === SÖZCÜK YAPISI ===
  'Kök - Ek Kavramları':                                                 'TR.19',
  'Sözcüğün Yapısı':                                                     'TR.20',
  'Sözcükte Yapı Karma Test':                                            'TR.21',
  // === SÖZCÜK TÜRLERİ ===
  'İsim (Ad)':                                                           'TR.22',
  'Sıfat (Ön Ad)':                                                       'TR.23',
  'Tamlamalar':                                                          'TR.24',
  'Zamir (Adıl)':                                                        'TR.25',
  'Zarf (Belirteç)':                                                     'TR.26',
  'Edat - Bağlaç - Ünlem':                                              'TR.27',
  // === FİİL ===
  'Fiilde Anlam ve Kip / Ek Fiil':                                      'TR.28',
  'Fiilde Yapı':                                                         'TR.29',
  'Fiilimsiler':                                                         'TR.30',
  'Fiilde Çatı':                                                         'TR.31',
  'Sözcük Türleri Karma Test':                                           'TR.32',
  // === CÜMLE BİLGİSİ ===
  'Cümlenin Ögeleri':                                                    'TR.33',
  'Cümle Türleri':                                                       'TR.34',
  'Cümle Bilgisi Karma Test':                                            'TR.35',
  'Dil Bilgisi Karma Testler':                                           'TR.36',
  // === ANLATIM BOZUKLUKLARI ===
  'Anlama Dayalı Anlatım Bozuklukları':                                 'TR.37',
  'Dil Bilgisi Dayalı Anlatım Bozuklukları':                            'TR.38',
};

// Karma testler: her soru ayrı kazanım alır.
// { sectionTitle, testTitle, questionNo, code }
// Karma testler verildikçe buraya eklenecek.
const KARMA_MAPPINGS: { sectionTitle: string; testTitle: string; questionNo: number; code: string }[] = [
  // === PARAGRAF KARMA SORULAR - Test 1 ===
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 1', questionNo: 1, code: 'TR.39' }, // Yardımcı düşünce
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 1', questionNo: 2, code: 'TR.40' }, // Ana düşünce
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 1', questionNo: 3, code: 'TR.41' }, // Diyalogda boş bırakılan yer
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 1', questionNo: 4, code: 'TR.42' }, // Paragrafta yorum
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 1', questionNo: 5, code: 'TR.9'  }, // Paragrafta Anlatım
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 1', questionNo: 6, code: 'TR.40' }, // Ana düşünce
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 1', questionNo: 7, code: 'TR.43' }, // Düşüncenin akışını bozan cümle
  // === PARAGRAF KARMA SORULAR - Test 2 ===
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 2', questionNo: 1, code: 'TR.39' }, // Yardımcı düşünce
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 2', questionNo: 2, code: 'TR.43' }, // Düşüncenin akışını bozan cümle
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 2', questionNo: 3, code: 'TR.44' }, // Paragrafı ikiye bölme
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 2', questionNo: 4, code: 'TR.39' }, // Yardımcı düşünce
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 2', questionNo: 5, code: 'TR.40' }, // Ana düşünce
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 2', questionNo: 6, code: 'TR.45' }, // Paragrafın konusu
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 2', questionNo: 7, code: 'TR.46' }, // Boş bırakılan yeri tamamlama
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 2', questionNo: 8, code: 'TR.47' }, // Paragraf oluşturma
  // === PARAGRAF KARMA SORULAR - Test 3 ===
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 3', questionNo: 1, code: 'TR.40' }, // Ana düşünce
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 3', questionNo: 2, code: 'TR.9'  }, // Paragrafta Anlatım
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 3', questionNo: 3, code: 'TR.40' }, // Ana düşünce
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 3', questionNo: 4, code: 'TR.39' }, // Yardımcı düşünce
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 3', questionNo: 5, code: 'TR.40' }, // Ana düşünce
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 3', questionNo: 6, code: 'TR.39' }, // Yardımcı düşünce
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 3', questionNo: 7, code: 'TR.43' }, // Düşüncenin akışını bozan cümle
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 3', questionNo: 8, code: 'TR.48' }, // Paragrafa cümle ekleme
  // === PARAGRAF KARMA SORULAR - Test 4 ===
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 4', questionNo: 1, code: 'TR.39' }, // Yardımcı düşünce
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 4', questionNo: 2, code: 'TR.39' }, // Yardımcı düşünce
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 4', questionNo: 3, code: 'TR.9'  }, // Paragrafta Anlatım
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 4', questionNo: 4, code: 'TR.44' }, // Paragrafı ikiye bölme
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 4', questionNo: 5, code: 'TR.43' }, // Düşüncenin akışını bozan cümle
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 4', questionNo: 6, code: 'TR.46' }, // Boş bırakılan yeri tamamlama
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 4', questionNo: 7, code: 'TR.47' }, // Paragraf oluşturma
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 4', questionNo: 8, code: 'TR.39' }, // Yardımcı düşünce
  // === PARAGRAF KARMA SORULAR - Test 5 ===
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 5', questionNo: 1, code: 'TR.39' }, // Yardımcı düşünce
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 5', questionNo: 2, code: 'TR.47' }, // Paragraf oluşturma
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 5', questionNo: 3, code: 'TR.44' }, // Paragrafı ikiye bölme
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 5', questionNo: 4, code: 'TR.46' }, // Boş bırakılan yeri tamamlama
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 5', questionNo: 5, code: 'TR.39' }, // Yardımcı düşünce
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 5', questionNo: 6, code: 'TR.40' }, // Ana düşünce
  // === PARAGRAF KARMA SORULAR - Test 6 ===
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 6', questionNo: 1, code: 'TR.39' }, // Yardımcı düşünce
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 6', questionNo: 2, code: 'TR.43' }, // Düşüncenin akışını bozan cümle
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 6', questionNo: 3, code: 'TR.45' }, // Paragrafın konusu
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 6', questionNo: 4, code: 'TR.9'  }, // Paragrafta Anlatım
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 6', questionNo: 5, code: 'TR.39' }, // Yardımcı düşünce
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 6', questionNo: 6, code: 'TR.48' }, // Paragrafa cümle ekleme
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 6', questionNo: 7, code: 'TR.40' }, // Ana düşünce
  // === PARAGRAF KARMA SORULAR - Test 7 ===
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 7', questionNo: 1, code: 'TR.44' }, // Paragrafı ikiye bölme
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 7', questionNo: 2, code: 'TR.48' }, // Paragrafa cümle ekleme
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 7', questionNo: 3, code: 'TR.43' }, // Düşüncenin akışını bozan cümle
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 7', questionNo: 4, code: 'TR.39' }, // Yardımcı düşünce
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 7', questionNo: 5, code: 'TR.41' }, // Diyalogda boş bırakılan yeri tamamlama
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 7', questionNo: 6, code: 'TR.40' }, // Ana düşünce
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 7', questionNo: 7, code: 'TR.39' }, // Yardımcı düşünce
  // === PARAGRAF KARMA SORULAR - Test 8 ===
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 8', questionNo: 1, code: 'TR.46' }, // Paragrafta boş bırakılan yeri tamamlama
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 8', questionNo: 2, code: 'TR.46' }, // Paragrafta boş bırakılan yeri tamamlama
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 8', questionNo: 3, code: 'TR.39' }, // Yardımcı düşünce
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 8', questionNo: 4, code: 'TR.39' }, // Yardımcı düşünce
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 8', questionNo: 5, code: 'TR.49' }, // Paragraf cümlesinin anlamını belirleme
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 8', questionNo: 6, code: 'TR.39' }, // Yardımcı düşünce
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 8', questionNo: 7, code: 'TR.9'  }, // Paragrafta anlatım
  // === PARAGRAF KARMA SORULAR - Test 9 ===
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 9', questionNo: 1, code: 'TR.47' }, // Paragraf oluşturma
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 9', questionNo: 2, code: 'TR.46' }, // Paragrafta boş bırakılan yeri tamamlama
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 9', questionNo: 3, code: 'TR.43' }, // Düşüncenin akışını bozan cümle
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 9', questionNo: 4, code: 'TR.44' }, // Paragrafı ikiye bölme
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 9', questionNo: 5, code: 'TR.40' }, // Ana düşünce
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 9', questionNo: 6, code: 'TR.50' }, // Soruya cevap paragraf
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 9', questionNo: 7, code: 'TR.39' }, // Yardımcı düşünce
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 9', questionNo: 8, code: 'TR.39' }, // Yardımcı düşünce
  // === PARAGRAF KARMA SORULAR - Test 10 ===
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 10', questionNo: 1, code: 'TR.39' }, // Yardımcı düşünce
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 10', questionNo: 2, code: 'TR.39' }, // Yardımcı düşünce
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 10', questionNo: 3, code: 'TR.46' }, // Boş bırakılan yeri tamamlama
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 10', questionNo: 4, code: 'TR.9'  }, // Paragrafta Anlatım
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 10', questionNo: 5, code: 'TR.40' }, // Ana düşünce
  { sectionTitle: 'Paragraf Karma Sorular', testTitle: 'Test 10', questionNo: 6, code: 'TR.9'  }, // Paragrafta Anlatım
];

async function main() {
  console.log('Seeding Türkçe Soru Bankası - question-outcome mappings');

  const book = await prisma.book.findFirst({
    where: { title: BOOK_TITLE },
    select: { id: true },
  });
  if (!book) {
    throw new Error(`Book "${BOOK_TITLE}" not found. Run seed:turkce:sorubankasi:structure first.`);
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

  // Eski mapping'leri sil
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
