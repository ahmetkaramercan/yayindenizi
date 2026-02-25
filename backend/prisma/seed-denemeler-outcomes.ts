import { PrismaClient, BookCategory } from '@prisma/client';

const prisma = new PrismaClient();

const BOOK_TITLE = 'Paragraf Koçu Denemeleri';

const OUTCOMES: { code: string; name: string; category: string }[] = [
  { code: '21.3', name: 'ANLATIM TEKNİKLERİ VE DÜŞÜNCEYİ GELİŞTİRME YOLLARI', category: 'Paragraf' },
  { code: '21.5.2', name: 'Paragrafta Yardımcı Düşünceler', category: 'Paragraf Anlam' },
  { code: '21.4.4', name: 'Paragrafa Cümle Yerleştirme', category: 'Paragraf Yapısı' },
  { code: '21.5.9', name: 'Diyalogta Boş Bırakılan Yerleri Tamamlama', category: 'Diyalog' },
  { code: '21.5.1', name: 'Paragrafta Ana Düşünce (Ana Fikir)', category: 'Paragraf Anlam' },
  { code: '21.4.3', name: 'Paragrafta Anlatım Akışını Bozan Cümle', category: 'Paragraf Yapısı' },
  { code: '21.4.1', name: 'Paragrafı İkiye Ayırma', category: 'Paragraf Yapısı' },
  { code: '21.4.6', name: 'Paragrafta Cümlelerin Yerini Değiştirme', category: 'Paragraf Yapısı' },
  { code: '21.4.2', name: 'Paragrafta Boş Bırakılan Yerleri Tamamlama', category: 'Paragraf Yapısı' },
  { code: '21.5.6', name: 'Paragrafın Konusu', category: 'Paragraf Anlam' },
  { code: '21.5.3', name: 'Paragrafın Karşılık Olduğu Soruyu Belirleme', category: 'Paragraf Anlam' },
  { code: '21.5.4', name: 'Paragrafın Yorumlanması', category: 'Paragraf Anlam' },
  { code: '21.2.2', name: 'Cümlede Kavramlar', category: 'Cümle' },
  { code: '21.5.5', name: 'Diyaloğun Yorumlanması', category: 'Diyalog' },
  { code: '21.5.10', name: 'Paragrafa Özgü Soru Kökü', category: 'Paragraf Anlam' },
  { code: '21.4.5', name: 'Cümlelerden Paragraf Oluşturma', category: 'Paragraf Yapısı' },
  { code: '21.5.8', name: 'İki Paragrafın Karşılaştırılması', category: 'Paragraf Anlam' },
];

async function main() {
  console.log('Seeding Paragraf Koçu Denemeleri - outcomes');

  // 1. Create or find book
  let book = await prisma.book.findFirst({
    where: { title: BOOK_TITLE },
    select: { id: true },
  });

  if (!book) {
    book = await prisma.book.create({
      data: {
        title: BOOK_TITLE,
        description: 'TYT Paragraf deneme kitabı - her seviyede 4 deneme, her denemede 25 soru',
        category: BookCategory.DENEME,
      },
      select: { id: true },
    });
    console.log(`✓ Book created: ${book.id}`);
  } else {
    console.log(`✓ Book found: ${book.id}`);
  }

  const bookId = book.id;

  // 2. Upsert all 17 outcomes
  for (const o of OUTCOMES) {
    await prisma.learningOutcome.upsert({
      where: { bookId_code: { bookId, code: o.code } },
      update: { name: o.name, category: o.category },
      create: { code: o.code, name: o.name, category: o.category, bookId },
    });
  }
  console.log(`✓ ${OUTCOMES.length} outcomes upserted`);

  // 3. Validate
  const totalOutcomes = await prisma.learningOutcome.count({ where: { bookId } });
  console.log('\n=== VALIDATION ===');
  console.log(`Outcomes for "${BOOK_TITLE}": ${totalOutcomes}`);
  console.log('✓ Done');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
