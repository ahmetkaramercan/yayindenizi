import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient() as any;

const BOOK_TITLE = 'Edebiyat Soru Bankası';

// Konu bölümleri: bölümdeki tüm sorular aynı kazanımı alır.
// section title → kazanım kodu
const SECTION_OUTCOME_MAP: Record<string, string> = {
  'Edebiyat - Edebiyatın Diğer Sanatlarla ve Bilimle İlişkisi':                                                                                                                                      'EB.1',
  'Edebiyatın Tarih ve Din ile İlişkisi / Türkçenin Tarihî Gelişimi / Türk Edebiyatının Tarihî Dönemleri':                                                                                          'EB.2',
  'Edebiyatın Tarih ve Din ile İlişkisi / Türkçenin Tarihî Gelişimi / Türk Edebiyatının Tarihî Dönemleri / Edebiyat ve Toplum İlişkisi / Edebiyat Sanat Akımları ile İlişkisi':                    'EB.3',
  'Edebiyat ve Felsefe İlişkisi / Edebiyat ve Psikoloji İlişkisi / Dilin Tarihî Süreç İçerisindeki Değişimi / Türkçenin Önemli Sözlükleri':                                                        'EB.4',
  'Şiir (Tür Bilgisi)':                                                                               'EB.5',
  'Edebî Sanatlar':                                                                                   'EB.6',
  'İslamiyet Öncesi Sözlü ve Yazılı Ürünler':                                                         'EB.7',
  'Geçiş Dönemi Ürünleri':                                                                            'EB.8',
  'Halk Edebiyatında Şiir (Anonim Halk Edebiyatı)':                                                  'EB.9',
  'Halk Edebiyatında Şiir (Âşık Edebiyatı)':                                                         'EB.10',
  'Halk Edebiyatında Şiir (Tekke Edebiyatı)':                                                        'EB.11',
  'Divan Edebiyatında Şiir':                                                                          'EB.12',
  "Tanzimat Dönemi'nde Şiir":                                                                         'EB.13',
  "Servetifünun Dönemi'nde Şiir":                                                                     'EB.14',
  'Fecriati Edebiyatında Şiir':                                                                       'EB.15',
  "Millî Edebiyat Dönemi'nde Şiir":                                                                   'EB.16',
  "Cumhuriyet Dönemi'nde Şiir (Saf Şiir)":                                                           'EB.17',
  "Cumhuriyet Dönemi'nde Şiir (Millî Edebiyat Zevk ve Anlayışını Sürdüren Şiir / Beş Hececiler - Yedi Meşaleciler)": 'EB.18',
  "Cumhuriyet Dönemi'nde Şiir (Toplumcu Gerçekçi Şiir / 1923-1960)":                                 'EB.19',
  "Cumhuriyet Dönemi'nde Şiir (Garip Akımı - Maviciler)":                                            'EB.20',
  "Cumhuriyet Dönemi'nde Şiir (Garip Dışında Yeniliği Sürdüren Şiir)":                               'EB.21',
  "Cumhuriyet Dönemi'nde Şiir (İkinci Yeni Şiiri)":                                                  'EB.22',
  "Cumhuriyet Dönemi'nde Şiir (Mistik-Metafizik Şiir)":                                              'EB.23',
  "Cumhuriyet Dönemi'nde Şiir (1960 Sonrası Toplumcu Şiir)":                                         'EB.24',
  "Cumhuriyet Dönemi'nde Şiir (1980 Sonrası Şiir)":                                                  'EB.25',
  "Cumhuriyet Dönemi'nde Şiir (Halk Şiiri)":                                                         'EB.26',
  "Cumhuriyet Dönemi'nde Şiir Karma Test":                                                            'EB.27',
  'Hikâye (Tür Bilgisi)':                                                                             'EB.28',
  'Masal – Fabl – Destan – Efsane':                                                                   'EB.29',
  'Halk Hikâyeleri – Dede Korkut Hikâyeleri – Mesnevi':                                              'EB.30',
  "Tanzimat'tan Cumhuriyet Dönemi'ne Kadar Hikâye":                                                  'EB.31',
  "Cumhuriyet Dönemi'nde Hikâye (Millî – Dinî Duyarlılığı Yansıtan Hikâyeler)":                      'EB.32',
  "Cumhuriyet Dönemi'nde Hikâye (Modernist Hikâye)":                                                 'EB.33',
  "Cumhuriyet Dönemi'nde Hikâye (Bireyin İç Dünyasını Yansıtan Hikâyeler)":                          'EB.34',
  "Cumhuriyet Dönemi'nde Hikâye Karma Test":                                                          'EB.35',
  "Cumhuriyet Dönemi'nde Hikâye (Toplumcu Gerçekçi Hikâye)":                                         'EB.36',
  'Roman (Tür Bilgisi)':                                                                              'EB.37',
  "Servetifünun Dönemi'nde Roman":                                                                    'EB.38',
  "Millî Edebiyat Dönemi'nde Roman":                                                                  'EB.39',
  "Tanzimat Dönemi'nde Roman":                                                                        'EB.40',
  "Cumhuriyet Dönemi'nde Roman (Millî ve Dinî Duyarlılığı Esas Alan Roman)":                          'EB.41',
  "Cumhuriyet Dönemi'nde Roman (Bireyin İç Dünyasını Esas Alan Roman)":                               'EB.42',
  "Cumhuriyet Dönemi'nde Roman (Toplumcu Gerçekçi Roman)":                                            'EB.43',
  "Cumhuriyet Dönemi'nde Roman (Modernizmi Esas Alan Roman)":                                         'EB.44',
  "Cumhuriyet Dönemi'nde Roman (1980 Sonrası Roman – Popüler Roman)":                                 'EB.45',
  'Tiyatro (Tür Bilgisi)':                                                                            'EB.46',
  'Geleneksel Türk Tiyatrosu':                                                                        'EB.47',
  "Tanzimat Dönemi'nde Tiyatro":                                                                      'EB.48',
  "Millî Edebiyat Dönemi'nde Tiyatro":                                                                'EB.49',
  "Cumhuriyet Dönemi'nde Tiyatro":                                                                    'EB.50',
  'Öğretici Metinler':                                                                                'EB.51',
  'Divan Edebiyatında Nesir':                                                                         'EB.52',
  "Tanzimat'tan Cumhuriyet Dönemi'ne Kadar Öğretici Metinler":                                       'EB.53',
  "Cumhuriyet Dönemi'nde Öğretici Metinler":                                                          'EB.54',
  'Sözlü Anlatım':                                                                                    'EB.55',
  'Edebî Akımlar':                                                                                    'EB.56',
  'Türkiye Dışı Çağdaş Türk Edebiyatı':                                                              'EB.57',
};

async function main() {
  console.log('Seeding Edebiyat Soru Bankası - question-outcome mappings');

  const book = await prisma.book.findFirst({
    where: { title: BOOK_TITLE },
    select: { id: true },
  });
  if (!book) {
    throw new Error(`Book "${BOOK_TITLE}" not found. Run seed:edebiyat-soru-bankasi:structure first.`);
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
