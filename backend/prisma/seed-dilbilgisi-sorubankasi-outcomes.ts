import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient() as any;

const BOOK_TITLE = 'Dil Bilgisi Soru Bankası';

// Her konu bölümü için bir kazanım. Her soru kendi bölümünün kazanımını alır.
const OUTCOMES: { code: string; name: string; category: string }[] = [
  // === SES VE YAZI ===
  { code: 'DB.1',  name: 'Ses Bilgisi',                          category: 'Ses ve Yazı' },
  { code: 'DB.2',  name: 'Yazım Kuralları',                      category: 'Ses ve Yazı' },
  { code: 'DB.3',  name: 'Noktalama İşaretleri',                category: 'Ses ve Yazı' },
  // === SÖZCÜK YAPISI ===
  { code: 'DB.4',  name: 'Sözcükte Yapı',                        category: 'Sözcük Yapısı' },
  // === SÖZCÜK TÜRLERİ ===
  { code: 'DB.5',  name: 'İsim (Ad) - İsim Tamlaması',          category: 'Sözcük Türleri' },
  { code: 'DB.6',  name: 'Sıfat (Ön Ad) - Sıfat Tamlaması',    category: 'Sözcük Türleri' },
  { code: 'DB.7',  name: 'Zamir (Adıl)',                         category: 'Sözcük Türleri' },
  { code: 'DB.8',  name: 'Zarf (Belirteç)',                      category: 'Sözcük Türleri' },
  { code: 'DB.9',  name: 'Edat (İlgeç) - Bağlaç - Ünlem',      category: 'Sözcük Türleri' },
  // === FİİL ===
  { code: 'DB.10', name: 'Fiil (Eylem)',                         category: 'Fiil' },
  { code: 'DB.11', name: 'Fiilde Çatı',                          category: 'Fiil' },
  { code: 'DB.12', name: 'Fiilimsi (Eylemsi)',                   category: 'Fiil' },
  // === CÜMLE BİLGİSİ ===
  { code: 'DB.13', name: 'Cümlenin Ögeleri',                    category: 'Cümle Bilgisi' },
  { code: 'DB.14', name: 'Cümle Çeşitleri',                     category: 'Cümle Bilgisi' },
  // === KARMA ===
  { code: 'DB.15', name: 'Karma Dil Bilgisi',                   category: 'Karma' },
];

async function main() {
  console.log('Seeding Dil Bilgisi Soru Bankası - learning outcomes');

  const book = await prisma.book.findFirst({
    where: { title: BOOK_TITLE },
    select: { id: true },
  });
  if (!book) {
    throw new Error(`Book "${BOOK_TITLE}" not found. Run seed:dilbilgisi:sorubankasi:structure first.`);
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
