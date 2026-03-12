import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient() as any;

const BOOK_TITLE = 'TYT Türkçe Denemeleri';

const OUTCOMES: { code: string; name: string; category: string }[] = [
  { code: '21.1.1', name: 'Sözcükte Anlam', category: 'Sözcük Anlamı' },
  { code: '21.1.2', name: 'Metne Sözcük Yerleştirme', category: 'Sözcük Anlamı' },
  { code: '21.1.4', name: 'Söz Öbeklerinde Anlam', category: 'Sözcük Anlamı' },
  { code: '21.1.5', name: 'Deyimler ve Atasözleri', category: 'Sözcük Anlamı' },
  { code: '21.2', name: 'CÜMLENİN ANLAMI VE YORUMU', category: 'Cümlenin Anlamı' },
  { code: '21.2.1', name: 'Cümleler Arasındaki Anlam İlişkileri', category: 'Cümlenin Anlamı' },
  { code: '21.2.2', name: 'Cümlede Kavramlar', category: 'Cümlenin Anlamı' },
  {
    code: '21.2.3',
    name: 'Parçadaki Cümlelerin içerik ve Ozellikleri',
    category: 'Cümlenin Anlamı',
  },
  { code: '21.2.4', name: 'Cümleyi Yorumlama ve Açıklama', category: 'Cümlenin Anlamı' },
  { code: '21.2.6', name: 'İki Cümleyi Birleştirme', category: 'Cümlenin Anlamı' },
  {
    code: '21.3',
    name: 'ANLATIM TEKNİKLERİ VE DÜŞÜNCEYİ GELİŞTİRME YOLLARI',
    category: 'Anlatım Teknikleri',
  },
  { code: '21.4.1', name: 'Paragrafı İkiye Ayırma', category: 'Paragraf Yapısı' },
  {
    code: '21.4.2',
    name: 'Paragrafta Boş Bırakılan Yerleri Tamamlama',
    category: 'Paragraf Yapısı',
  },
  { code: '21.4.3', name: 'Paragrafta Anlatım Akışını Bozan Cümle', category: 'Paragraf Yapısı' },
  { code: '21.4.4', name: 'Paragrafa Cümle Yerleştirme', category: 'Paragraf Yapısı' },
  { code: '21.4.5', name: 'Cümlelerden Paragraf Oluşturma', category: 'Paragraf Yapısı' },
  { code: '21.5.1', name: 'Paragrafta Ana Düşünce (Ana Fikir)', category: 'Paragraf Anlam' },
  { code: '21.5.2', name: 'Paragrafta Yardımcı Düşünceler', category: 'Paragraf Anlam' },
  {
    code: '21.5.3',
    name: 'Paragrafın Karşılık Olduğu Soruyu Belirleme',
    category: 'Paragraf Anlam',
  },
  { code: '21.5.4', name: 'Paragrafın Yorumlanması', category: 'Paragraf Anlam' },
  { code: '21.5.5', name: 'Diyaloğun Yorumlanması', category: 'Paragraf Anlam' },
  { code: '21.5.6', name: 'Paragrafın Konusu', category: 'Paragraf Anlam' },
  { code: '21.5.10', name: 'Paragrafa Özgü Soru Kökü', category: 'Paragraf Anlam' },
  { code: '21.6.2', name: 'Ünsüzlerle İlgili Ses Olayları', category: 'Ses Bilgisi' },
  { code: '21.6.3', name: 'Ses Bilgisi - Karma', category: 'Ses Bilgisi' },
  { code: '21.7', name: 'YAZIM KURALLARI', category: 'Yazım Kuralları' },
  { code: '21.7.2', name: 'Büyük Harflerin Yazılışı', category: 'Yazım Kuralları' },
  { code: '21.7.5', name: 'Bitişik ve Ayrı Yazılan Kelimeler', category: 'Yazım Kuralları' },
  { code: '21.7.6', name: 'Kisaltmalarin Yazilisi', category: 'Yazım Kuralları' },
  { code: '21.7.9', name: 'Yazım Kuralları - Karma', category: 'Yazım Kuralları' },
  { code: '21.8', name: 'NOKTALAMA İŞARETLERİ', category: 'Noktalama İşaretleri' },
  { code: '21.8.2', name: 'Virgül', category: 'Noktalama İşaretleri' },
  { code: '21.8.3', name: 'Noktalı Virgül', category: 'Noktalama İşaretleri' },
  { code: '21.8.4', name: 'İki Nokta', category: 'Noktalama İşaretleri' },
  { code: '21.8.9', name: 'Tırnak İşareti - Kesme İşareti', category: 'Noktalama İşaretleri' },
  { code: '21.8.12', name: 'Noktalama İşaretleri - Karma', category: 'Noktalama İşaretleri' },
  { code: '21.9', name: 'EKLER VE SÖZCÜK YAPISI', category: 'Ekler ve Sözcük Yapısı' },
  { code: '21.9.2', name: 'Ekler ve Ek Çeşitleri', category: 'Ekler ve Sözcük Yapısı' },
  { code: '21.10.15', name: 'Ad Soylu Sözcükler - Karma', category: 'Ad Soylu Sözcükler' },
  { code: '21.11', name: 'TAMLAMALAR', category: 'Tamlamalar' },
  { code: '21.11.3', name: 'Tamlamalar - Karma', category: 'Tamlamalar' },
  { code: '21.13.4', name: 'Fiilimsiler - Karma', category: 'Fiilimsi' },
  { code: '21.15', name: 'CÜMLENİN ÖGELERİ', category: 'Cümlenin Ögeleri' },
  { code: '21.15.6', name: 'Cümlenin Ögeleri - Karma', category: 'Cümlenin Ögeleri' },
  { code: '21.16.3', name: 'Yüklemin Türüne Göre Cümleler', category: 'Cümle Türleri' },
  { code: '21.17', name: 'KARMA DİL BİLGİSİ', category: 'Karma' },
  { code: '21.18', name: 'ANLATIM BOZUKLUKLARI', category: 'Anlatım Bozuklukları' },
];

import { RAW_MAPPINGS_TEXT } from './tyt-turkce-raw-mappings';

type RawMapping = { testNo: number; questionNo: number; code: string };

const RAW_MAPPINGS: RawMapping[] = RAW_MAPPINGS_TEXT.trim().split('\n').filter(Boolean).map(line => {
  const [testStr, qNoStr, code] = line.split('\t');
  return {
    testNo: parseInt(testStr.replace('TEST ', ''), 10),
    questionNo: parseInt(qNoStr, 10),
    code: code.trim()
  };
});

async function main() {
  console.log('Seeding TYT Türkçe Denemeleri - learning outcomes');

  const book = await prisma.book.findFirst({
    where: { title: BOOK_TITLE },
    select: { id: true },
  });
  if (!book) {
    throw new Error(`Book "${BOOK_TITLE}" not found. Run seed:tyt-turkce:structure first.`);
  }
  const bookId = book.id;

  // Clear existing mappings
  const deletedMappings = await prisma.questionOutcome.deleteMany({
    where: {
      question: {
        test: {
          section: {
            bookId,
          },
        },
      },
    },
  });
  console.log(`✓ Removed ${deletedMappings.count} old mappings`);

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

  // Create mappings
  const outcomeMap = new Map(
    (
      await prisma.learningOutcome.findMany({
        where: { bookId },
        select: { id: true, code: true },
      })
    ).map((o: any) => [o.code, o.id]),
  );

  const orderedTests = await prisma.test.findMany({
    where: { section: { bookId } },
    select: { id: true, title: true },
    orderBy: [{ createdAt: 'asc' }],
  });

  const testIdByNumber = new Map<number, string>(
    orderedTests.map((t: any) => {
      const match = t.title.match(/Deneme (\d+)/);
      return [match ? parseInt(match[1]) : 0, t.id];
    }),
  );

  let skipped = 0;
  let createdMappings = 0;

  for (const row of RAW_MAPPINGS) {
    const outcomeId = outcomeMap.get(row.code);
    if (!outcomeId) {
      console.warn(`Outcome not found for code: ${row.code}`);
      skipped++;
      continue;
    }

    const testId = testIdByNumber.get(row.testNo);
    if (!testId) {
      console.warn(`Test not found for Deneme ${row.testNo}`);
      skipped++;
      continue;
    }

    const question = await prisma.question.findFirst({
      where: {
        testId,
        orderIndex: row.questionNo - 1,
      },
      select: { id: true },
    });

    if (!question) {
      console.warn(`Question not found for Deneme ${row.testNo}, Q ${row.questionNo}`);
      skipped++;
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
    createdMappings++;
  }

  console.log('\n=== VALIDATION ===');
  const count = await prisma.learningOutcome.count({ where: { bookId } });
  const mappingCount = await prisma.questionOutcome.count({
    where: {
      question: {
        test: {
          section: { bookId },
        },
      },
    },
  });
  console.log(`Outcomes for "${BOOK_TITLE}": ${count}`);
  console.log(`Mappings created: ${createdMappings} (Skipped: ${skipped})`);
  console.log(`Total Mappings in DB for this book: ${mappingCount}`);
  console.log('✓ Done');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
