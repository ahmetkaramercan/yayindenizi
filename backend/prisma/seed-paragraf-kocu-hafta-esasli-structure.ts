import { PrismaClient, BookCategory } from '@prisma/client';

const prisma = new PrismaClient();

const BOOK_TITLE = 'Paragraf Koçu (Hafta Esaslı)';
const BOOK_IMAGE_URL = 'photos/paragraf_kocu_hafta_esasli.jpeg';
const TESTS_PER_SECTION = 20;
const TOTAL_LEVELS = 8;
const TIME_LIMIT = 480; // 8 dakika

async function main() {
  console.log(`Seeding "${BOOK_TITLE}" structure...`);

  // Kitabı bul veya oluştur
  let book = await prisma.book.findFirst({
    where: { title: BOOK_TITLE },
    select: { id: true },
  });

  if (!book) {
    book = await prisma.book.create({
      data: {
        title: BOOK_TITLE,
        description: 'Haftalık paragraf testleri ile TYT hazırlığı',
        imageUrl: BOOK_IMAGE_URL,
        category: BookCategory.PARAGRAF,
      },
      select: { id: true },
    });
    console.log(`✓ Kitap oluşturuldu: ${book.id}`);
  } else {
    // imageUrl güncel tut
    await prisma.book.update({
      where: { id: book.id },
      data: { imageUrl: BOOK_IMAGE_URL },
    });
    console.log(`✓ Kitap mevcut, güncellendi: ${book.id}`);
  }

  const bookId = book.id;
  let totalTests = 0;

  for (let level = 1; level <= TOTAL_LEVELS; level++) {
    const sectionTitle = `Seviye ${level}`;

    // Section'ı bul veya oluştur
    let section = await prisma.section.findFirst({
      where: { bookId, title: sectionTitle },
      select: { id: true },
    });

    if (!section) {
      section = await prisma.section.create({
        data: {
          title: sectionTitle,
          description: `Seviye ${level} - Paragraf testleri`,
          orderIndex: level - 1,
          bookId,
        },
        select: { id: true },
      });
      console.log(`  ✓ Section oluşturuldu: ${sectionTitle}`);
    }

    const sectionId = section.id;

    // Bu section'daki mevcut test sayısını kontrol et
    const existingCount = await prisma.test.count({
      where: { sectionId },
    });

    const startTestNo = (level - 1) * TESTS_PER_SECTION + 1;
    const testsToCreate = TESTS_PER_SECTION - existingCount;

    if (testsToCreate <= 0) {
      console.log(`  ⏭  ${sectionTitle}: ${existingCount} test zaten mevcut`);
      totalTests += existingCount;
      continue;
    }

    // Eksik testleri sıralı oluştur (createdAt sırası önemli)
    for (let i = existingCount; i < TESTS_PER_SECTION; i++) {
      const testNo = startTestNo + i;
      await prisma.test.create({
        data: {
          title: `Test ${testNo}`,
          level,
          timeLimit: TIME_LIMIT,
          sectionId,
        },
      });
    }

    console.log(`  ✓ ${sectionTitle}: ${testsToCreate} test oluşturuldu (${startTestNo}–${startTestNo + TESTS_PER_SECTION - 1})`);
    totalTests += TESTS_PER_SECTION;
  }

  console.log(`\n✓ Toplam: ${TOTAL_LEVELS} section, ${totalTests} test`);
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
