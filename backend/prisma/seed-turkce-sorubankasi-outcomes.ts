import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient() as any;

const BOOK_TITLE = 'Türkçe Soru Bankası';

// Türkçe Soru Bankası kazanımları.
// Konu bölümleri için her bölümün tüm soruları aynı kazanımı taşır.
// Karma testler için her sorunun kazanımı ayrıca belirtilir.
const OUTCOMES: { code: string; name: string; category: string }[] = [
  // === ANLAM BİLGİSİ ===
  { code: 'TR.1',  name: 'Sözcüğün Anlamı - Anlam Olayları',       category: 'Anlam Bilgisi' },
  { code: 'TR.2',  name: 'Söz Öbeğinin Anlamı',                     category: 'Anlam Bilgisi' },
  { code: 'TR.3',  name: 'Deyim - Atasözü - İkileme',               category: 'Anlam Bilgisi' },
  { code: 'TR.4',  name: 'Sözcükte ve Sözcük Gruplarında Anlam',    category: 'Anlam Bilgisi' },
  // === CÜMLE ===
  { code: 'TR.5',  name: 'Cümlede Anlam',                           category: 'Cümle' },
  { code: 'TR.6',  name: 'Cümle Oluşturma - Cümle Tamamlama',      category: 'Cümle' },
  { code: 'TR.7',  name: 'Cümlede Kavramlar',                       category: 'Cümle' },
  { code: 'TR.8',  name: 'Cümlede Anlatım',                         category: 'Cümle' },
  // === PARAGRAF ===
  { code: 'TR.9',  name: 'Paragrafta Anlatım',                      category: 'Paragraf' },
  { code: 'TR.10', name: 'Paragrafta Yapı',                          category: 'Paragraf' },
  { code: 'TR.11', name: 'Paragrafta Anlam',                         category: 'Paragraf' },
  { code: 'TR.12', name: 'Zincir Soru',                              category: 'Paragraf' },
  { code: 'TR.13', name: 'Karma Paragraf Sorusu',                                          category: 'Paragraf' },
  { code: 'TR.14', name: 'Cümlede Anlam ve Anlatım Karma Test',                           category: 'Cümle' },
  // === SES VE YAZI ===
  { code: 'TR.15', name: 'Ses Bilgisi',                                                    category: 'Ses ve Yazı' },
  { code: 'TR.16', name: 'Yazım Kuralları',                                                category: 'Ses ve Yazı' },
  { code: 'TR.17', name: 'Noktalama İşaretleri',                                          category: 'Ses ve Yazı' },
  { code: 'TR.18', name: 'Ses Bilgisi - Yazım Kuralları - Noktalama İşaretleri Karma',   category: 'Ses ve Yazı' },
  // === SÖZCÜK YAPISI ===
  { code: 'TR.19', name: 'Kök - Ek Kavramları',                                           category: 'Sözcük Yapısı' },
  { code: 'TR.20', name: 'Sözcüğün Yapısı',                                               category: 'Sözcük Yapısı' },
  { code: 'TR.21', name: 'Sözcükte Yapı Karma Test',                                      category: 'Sözcük Yapısı' },
  // === SÖZCÜK TÜRLERİ ===
  { code: 'TR.22', name: 'İsim (Ad)',                                                      category: 'Sözcük Türleri' },
  { code: 'TR.23', name: 'Sıfat (Ön Ad)',                                                  category: 'Sözcük Türleri' },
  { code: 'TR.24', name: 'Tamlamalar',                                                     category: 'Sözcük Türleri' },
  { code: 'TR.25', name: 'Zamir (Adıl)',                                                   category: 'Sözcük Türleri' },
  { code: 'TR.26', name: 'Zarf (Belirteç)',                                                category: 'Sözcük Türleri' },
  { code: 'TR.27', name: 'Edat - Bağlaç - Ünlem',                                         category: 'Sözcük Türleri' },
  // === FİİL ===
  { code: 'TR.28', name: 'Fiilde Anlam ve Kip / Ek Fiil',                                 category: 'Fiil' },
  { code: 'TR.29', name: 'Fiilde Yapı',                                                    category: 'Fiil' },
  { code: 'TR.30', name: 'Fiilimsiler',                                                    category: 'Fiil' },
  { code: 'TR.31', name: 'Fiilde Çatı',                                                    category: 'Fiil' },
  { code: 'TR.32', name: 'Sözcük Türleri Karma Test',                                     category: 'Sözcük Türleri' },
  // === CÜMLE BİLGİSİ ===
  { code: 'TR.33', name: 'Cümlenin Ögeleri',                                              category: 'Cümle Bilgisi' },
  { code: 'TR.34', name: 'Cümle Türleri',                                                  category: 'Cümle Bilgisi' },
  { code: 'TR.35', name: 'Cümle Bilgisi Karma Test',                                      category: 'Cümle Bilgisi' },
  { code: 'TR.36', name: 'Dil Bilgisi Karma Testler',                                     category: 'Dil Bilgisi' },
  // === ANLATIM BOZUKLUKLARI ===
  { code: 'TR.37', name: 'Anlama Dayalı Anlatım Bozuklukları',                           category: 'Anlatım Bozuklukları' },
  { code: 'TR.38', name: 'Dil Bilgisi Dayalı Anlatım Bozuklukları',                      category: 'Anlatım Bozuklukları' },
  // Buraya yeni konular eklenecek (veriler geldikçe)
];

async function main() {
  console.log('Seeding Türkçe Soru Bankası - learning outcomes');

  const book = await prisma.book.findFirst({
    where: { title: BOOK_TITLE },
    select: { id: true },
  });
  if (!book) {
    throw new Error(`Book "${BOOK_TITLE}" not found. Run seed:turkce:sorubankasi:structure first.`);
  }
  const bookId = book.id;

  // Mevcut kazanımları sil
  const deleted = await prisma.learningOutcome.deleteMany({ where: { bookId } });
  if (deleted.count > 0) console.log(`✓ Removed ${deleted.count} old outcomes`);

  // Yeni kazanımları oluştur
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
