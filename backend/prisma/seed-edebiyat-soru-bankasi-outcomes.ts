import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient() as any;

const BOOK_TITLE = 'Edebiyat Soru Bankası';

// Her konu bölümü için bir kazanım. Her soru kendi bölümünün kazanımını alır.
const OUTCOMES: { code: string; name: string; category: string }[] = [
  // === EDEBİYATA GİRİŞ ===
  { code: 'EB.1',  name: 'Edebiyat - Edebiyatın Diğer Sanatlarla ve Bilimle İlişkisi',                                                                                                                                       category: 'Edebiyata Giriş' },
  { code: 'EB.2',  name: 'Edebiyatın Tarih ve Din ile İlişkisi / Türkçenin Tarihî Gelişimi / Türk Edebiyatının Tarihî Dönemleri',                                                                                           category: 'Edebiyata Giriş' },
  { code: 'EB.3',  name: 'Edebiyatın Tarih ve Din ile İlişkisi / Türkçenin Tarihî Gelişimi / Türk Edebiyatının Tarihî Dönemleri / Edebiyat ve Toplum İlişkisi / Edebiyat Sanat Akımları ile İlişkisi',                     category: 'Edebiyata Giriş' },
  { code: 'EB.4',  name: 'Edebiyat ve Felsefe İlişkisi / Edebiyat ve Psikoloji İlişkisi / Dilin Tarihî Süreç İçerisindeki Değişimi / Türkçenin Önemli Sözlükleri',                                                         category: 'Edebiyata Giriş' },
  // === ŞİİR ===
  { code: 'EB.5',  name: 'Şiir (Tür Bilgisi)',                                                                category: 'Şiir' },
  { code: 'EB.6',  name: 'Edebî Sanatlar',                                                                    category: 'Şiir' },
  // === TARİHÎ DÖNEMLER ===
  { code: 'EB.7',  name: 'İslamiyet Öncesi Sözlü ve Yazılı Ürünler',                                          category: 'Tarihî Dönemler' },
  { code: 'EB.8',  name: 'Geçiş Dönemi Ürünleri',                                                             category: 'Tarihî Dönemler' },
  { code: 'EB.9',  name: 'Halk Edebiyatında Şiir (Anonim Halk Edebiyatı)',                                    category: 'Halk Edebiyatı' },
  { code: 'EB.10', name: 'Halk Edebiyatında Şiir (Âşık Edebiyatı)',                                           category: 'Halk Edebiyatı' },
  { code: 'EB.11', name: 'Halk Edebiyatında Şiir (Tekke Edebiyatı)',                                          category: 'Halk Edebiyatı' },
  { code: 'EB.12', name: 'Divan Edebiyatında Şiir',                                                           category: 'Divan Edebiyatı' },
  // === DÖNEMLER - ŞİİR ===
  { code: 'EB.13', name: "Tanzimat Dönemi'nde Şiir",                                                          category: 'Dönemler - Şiir' },
  { code: 'EB.14', name: "Servetifünun Dönemi'nde Şiir",                                                      category: 'Dönemler - Şiir' },
  { code: 'EB.15', name: 'Fecriati Edebiyatında Şiir',                                                        category: 'Dönemler - Şiir' },
  { code: 'EB.16', name: "Millî Edebiyat Dönemi'nde Şiir",                                                    category: 'Dönemler - Şiir' },
  // === CUMHURİYET DÖNEMİ - ŞİİR ===
  { code: 'EB.17', name: "Cumhuriyet Dönemi'nde Şiir (Saf Şiir)",                                             category: 'Cumhuriyet Dönemi Şiir' },
  { code: 'EB.18', name: "Cumhuriyet Dönemi'nde Şiir (Millî Edebiyat Zevk ve Anlayışını Sürdüren Şiir / Beş Hececiler - Yedi Meşaleciler)", category: 'Cumhuriyet Dönemi Şiir' },
  { code: 'EB.19', name: "Cumhuriyet Dönemi'nde Şiir (Toplumcu Gerçekçi Şiir / 1923-1960)",                   category: 'Cumhuriyet Dönemi Şiir' },
  { code: 'EB.20', name: "Cumhuriyet Dönemi'nde Şiir (Garip Akımı - Maviciler)",                              category: 'Cumhuriyet Dönemi Şiir' },
  { code: 'EB.21', name: "Cumhuriyet Dönemi'nde Şiir (Garip Dışında Yeniliği Sürdüren Şiir)",                 category: 'Cumhuriyet Dönemi Şiir' },
  { code: 'EB.22', name: "Cumhuriyet Dönemi'nde Şiir (İkinci Yeni Şiiri)",                                    category: 'Cumhuriyet Dönemi Şiir' },
  { code: 'EB.23', name: "Cumhuriyet Dönemi'nde Şiir (Mistik-Metafizik Şiir)",                                category: 'Cumhuriyet Dönemi Şiir' },
  { code: 'EB.24', name: "Cumhuriyet Dönemi'nde Şiir (1960 Sonrası Toplumcu Şiir)",                           category: 'Cumhuriyet Dönemi Şiir' },
  { code: 'EB.25', name: "Cumhuriyet Dönemi'nde Şiir (1980 Sonrası Şiir)",                                    category: 'Cumhuriyet Dönemi Şiir' },
  { code: 'EB.26', name: "Cumhuriyet Dönemi'nde Şiir (Halk Şiiri)",                                           category: 'Cumhuriyet Dönemi Şiir' },
  { code: 'EB.27', name: "Cumhuriyet Dönemi'nde Şiir Karma Test",                                             category: 'Cumhuriyet Dönemi Şiir' },
  // === HİKÂYE ===
  { code: 'EB.28', name: 'Hikâye (Tür Bilgisi)',                                                               category: 'Hikâye' },
  { code: 'EB.29', name: 'Masal – Fabl – Destan – Efsane',                                                    category: 'Hikâye' },
  { code: 'EB.30', name: 'Halk Hikâyeleri – Dede Korkut Hikâyeleri – Mesnevi',                                category: 'Hikâye' },
  { code: 'EB.31', name: "Tanzimat'tan Cumhuriyet Dönemi'ne Kadar Hikâye",                                    category: 'Hikâye' },
  { code: 'EB.32', name: "Cumhuriyet Dönemi'nde Hikâye (Millî – Dinî Duyarlılığı Yansıtan Hikâyeler)",        category: 'Hikâye' },
  { code: 'EB.33', name: "Cumhuriyet Dönemi'nde Hikâye (Modernist Hikâye)",                                   category: 'Hikâye' },
  { code: 'EB.34', name: "Cumhuriyet Dönemi'nde Hikâye (Bireyin İç Dünyasını Yansıtan Hikâyeler)",            category: 'Hikâye' },
  { code: 'EB.35', name: "Cumhuriyet Dönemi'nde Hikâye Karma Test",                                           category: 'Hikâye' },
  { code: 'EB.36', name: "Cumhuriyet Dönemi'nde Hikâye (Toplumcu Gerçekçi Hikâye)",                           category: 'Hikâye' },
  // === ROMAN ===
  { code: 'EB.37', name: 'Roman (Tür Bilgisi)',                                                                category: 'Roman' },
  { code: 'EB.38', name: "Servetifünun Dönemi'nde Roman",                                                     category: 'Roman' },
  { code: 'EB.39', name: "Millî Edebiyat Dönemi'nde Roman",                                                   category: 'Roman' },
  { code: 'EB.40', name: "Tanzimat Dönemi'nde Roman",                                                         category: 'Roman' },
  { code: 'EB.41', name: "Cumhuriyet Dönemi'nde Roman (Millî ve Dinî Duyarlılığı Esas Alan Roman)",            category: 'Roman' },
  { code: 'EB.42', name: "Cumhuriyet Dönemi'nde Roman (Bireyin İç Dünyasını Esas Alan Roman)",                 category: 'Roman' },
  { code: 'EB.43', name: "Cumhuriyet Dönemi'nde Roman (Toplumcu Gerçekçi Roman)",                              category: 'Roman' },
  { code: 'EB.44', name: "Cumhuriyet Dönemi'nde Roman (Modernizmi Esas Alan Roman)",                           category: 'Roman' },
  { code: 'EB.45', name: "Cumhuriyet Dönemi'nde Roman (1980 Sonrası Roman – Popüler Roman)",                   category: 'Roman' },
  // === TİYATRO ===
  { code: 'EB.46', name: 'Tiyatro (Tür Bilgisi)',                                                              category: 'Tiyatro' },
  { code: 'EB.47', name: 'Geleneksel Türk Tiyatrosu',                                                         category: 'Tiyatro' },
  { code: 'EB.48', name: "Tanzimat Dönemi'nde Tiyatro",                                                       category: 'Tiyatro' },
  { code: 'EB.49', name: "Millî Edebiyat Dönemi'nde Tiyatro",                                                  category: 'Tiyatro' },
  { code: 'EB.50', name: "Cumhuriyet Dönemi'nde Tiyatro",                                                     category: 'Tiyatro' },
  // === ÖĞRETİCİ METİNLER ===
  { code: 'EB.51', name: 'Öğretici Metinler',                                                                  category: 'Öğretici Metinler' },
  { code: 'EB.52', name: 'Divan Edebiyatında Nesir',                                                          category: 'Öğretici Metinler' },
  { code: 'EB.53', name: "Tanzimat'tan Cumhuriyet Dönemi'ne Kadar Öğretici Metinler",                         category: 'Öğretici Metinler' },
  { code: 'EB.54', name: "Cumhuriyet Dönemi'nde Öğretici Metinler",                                           category: 'Öğretici Metinler' },
  { code: 'EB.55', name: 'Sözlü Anlatım',                                                                     category: 'Öğretici Metinler' },
  // === KARMA ===
  { code: 'EB.56', name: 'Edebî Akımlar',                                                                     category: 'Karma' },
  { code: 'EB.57', name: 'Türkiye Dışı Çağdaş Türk Edebiyatı',                                               category: 'Karma' },
];

async function main() {
  console.log('Seeding Edebiyat Soru Bankası - learning outcomes');

  const book = await prisma.book.findFirst({
    where: { title: BOOK_TITLE },
    select: { id: true },
  });
  if (!book) {
    throw new Error(`Book "${BOOK_TITLE}" not found. Run seed:edebiyat-soru-bankasi:structure first.`);
  }
  const bookId = book.id;

  const deleted = await prisma.learningOutcome.deleteMany({ where: { bookId } });
  if (deleted.count > 0) console.log(`✓ Removed ${deleted.count} old outcomes`);

  for (const outcome of OUTCOMES) {
    await prisma.learningOutcome.create({
      data: {
        code: outcome.code,
        name: outcome.name,
        category: outcome.category,
        bookId,
      },
    });
  }

  console.log(`✓ ${OUTCOMES.length} learning outcomes created`);

  console.log('\n=== VALIDATION ===');
  const count = await prisma.learningOutcome.count({ where: { bookId } });
  console.log(`Outcomes for "${BOOK_TITLE}": ${count}`);
  console.log('✓ Done');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
