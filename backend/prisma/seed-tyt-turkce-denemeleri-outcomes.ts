import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient() as any;

const BOOK_TITLE = 'TYT Türkçe Denemeleri';

const OUTCOMES: { code: string; name: string; category: string }[] = [
  // === SÖZCÜK ANLAMI ===
  { code: '21.1.1',  name: 'Sözcükte Anlam',                                            category: 'Sözcük Anlamı' },
  { code: '21.1.2',  name: 'Metne Sözcük Yerleştirme',                                  category: 'Sözcük Anlamı' },
  { code: '21.1.4',  name: 'Söz Öbeklerinde Anlam',                                     category: 'Sözcük Anlamı' },
  { code: '21.1.5',  name: 'Deyimler ve Atasözleri',                                    category: 'Sözcük Anlamı' },
  // === CÜMLENİN ANLAMI VE YORUMU ===
  { code: '21.2',    name: 'CÜMLENİN ANLAMI VE YORUMU',                                 category: 'Cümlenin Anlamı' },
  { code: '21.2.1',  name: 'Cümleler Arasındaki Anlam İlişkileri',                      category: 'Cümlenin Anlamı' },
  { code: '21.2.2',  name: 'Cümlede Kavramlar',                                         category: 'Cümlenin Anlamı' },
  { code: '21.2.3',  name: 'Parçadaki Cümlelerin İçerik ve Özellikleri',                category: 'Cümlenin Anlamı' },
  { code: '21.2.4',  name: 'Cümleyi Yorumlama ve Açıklama',                             category: 'Cümlenin Anlamı' },
  { code: '21.2.6',  name: 'İki Cümleyi Birleştirme',                                   category: 'Cümlenin Anlamı' },
  // === ANLATIM TEKNİKLERİ ===
  { code: '21.3',    name: 'Anlatım Teknikleri ve Düşünceyi Geliştirme Yolları',         category: 'Anlatım Teknikleri' },
  // === PARAGRAF DÜZENLEME ===
  { code: '21.4.1',  name: 'Paragrafı İkiye Ayırma',                                    category: 'Paragraf Düzenleme' },
  { code: '21.4.2',  name: 'Paragrafta Boş Bırakılan Yerleri Tamamlama',                category: 'Paragraf Düzenleme' },
  { code: '21.4.3',  name: 'Paragrafta Anlatım Akışını Bozan Cümle',                    category: 'Paragraf Düzenleme' },
  { code: '21.4.4',  name: 'Paragrafa Cümle Yerleştirme',                               category: 'Paragraf Düzenleme' },
  { code: '21.4.5',  name: 'Cümlelerden Paragraf Oluşturma',                            category: 'Paragraf Düzenleme' },
  // === PARAGRAF ANLAM ===
  { code: '21.5.1',  name: 'Paragrafta Ana Düşünce (Ana Fikir)',                         category: 'Paragraf Anlam' },
  { code: '21.5.2',  name: 'Paragrafta Yardımcı Düşünceler',                            category: 'Paragraf Anlam' },
  { code: '21.5.3',  name: 'Paragrafın Karşılık Olduğu Soruyu Belirleme',               category: 'Paragraf Anlam' },
  { code: '21.5.4',  name: 'Paragrafın Yorumlanması',                                   category: 'Paragraf Anlam' },
  { code: '21.5.5',  name: 'Diyaloğun Yorumlanması',                                    category: 'Paragraf Anlam' },
  { code: '21.5.6',  name: 'Paragrafın Konusu',                                         category: 'Paragraf Anlam' },
  { code: '21.5.10', name: 'Paragrafa Özgü Soru Kökü',                                  category: 'Paragraf Anlam' },
  // === SES BİLGİSİ ===
  { code: '21.6.2',  name: 'Ünsüzlerle İlgili Ses Olayları',                            category: 'Ses Bilgisi' },
  { code: '21.6.3',  name: 'Ses Bilgisi - Karma',                                       category: 'Ses Bilgisi' },
  // === YAZIM KURALLARI ===
  { code: '21.7',    name: 'YAZIM KURALLARI',                                            category: 'Yazım Kuralları' },
  { code: '21.7.2',  name: 'Büyük Harflerin Yazılışı',                                  category: 'Yazım Kuralları' },
  { code: '21.7.5',  name: 'Bitişik ve Ayrı Yazılan Kelimeler',                          category: 'Yazım Kuralları' },
  { code: '21.7.6',  name: 'Kısaltmaların Yazılışı',                                    category: 'Yazım Kuralları' },
  { code: '21.7.9',  name: 'Yazım Kuralları - Karma',                                   category: 'Yazım Kuralları' },
  // === NOKTALAMA İŞARETLERİ ===
  { code: '21.8',    name: 'NOKTALAMA İŞARETLERİ',                                      category: 'Noktalama İşaretleri' },
  { code: '21.8.2',  name: 'Virgül',                                                    category: 'Noktalama İşaretleri' },
  { code: '21.8.3',  name: 'Noktalı Virgül',                                            category: 'Noktalama İşaretleri' },
  { code: '21.8.4',  name: 'İki Nokta',                                                 category: 'Noktalama İşaretleri' },
  { code: '21.8.9',  name: 'Tırnak İşareti - Kesme İşareti',                            category: 'Noktalama İşaretleri' },
  { code: '21.8.12', name: 'Noktalama İşaretleri - Karma',                              category: 'Noktalama İşaretleri' },
  // === EKLER VE SÖZCÜK YAPISI ===
  { code: '21.9',    name: 'EKLER VE SÖZCÜK YAPISI',                                    category: 'Ekler ve Sözcük Yapısı' },
  { code: '21.9.2',  name: 'Ekler ve Ek Çeşitleri',                                    category: 'Ekler ve Sözcük Yapısı' },
  // === AD SOYLU SÖZCÜKLER ===
  { code: '21.10.15',name: 'Ad Soylu Sözcükler - Karma',                                category: 'Ad Soylu Sözcükler' },
  // === TAMLAMALAR ===
  { code: '21.11',   name: 'TAMLAMALAR',                                                category: 'Tamlamalar' },
  { code: '21.11.3', name: 'Tamlamalar - Karma',                                        category: 'Tamlamalar' },
  // === FİİLİMSİLER ===
  { code: '21.13.4', name: 'Fiilimsiler - Karma',                                       category: 'Fiilimsi' },
  // === CÜMLENİN ÖGELERİ ===
  { code: '21.15',   name: 'CÜMLENİN ÖGELERİ',                                         category: 'Cümlenin Ögeleri' },
  { code: '21.15.6', name: 'Cümlenin Ögeleri - Karma',                                  category: 'Cümlenin Ögeleri' },
  // === CÜMLE TÜRLERİ ===
  { code: '21.16.3', name: 'Yüklemin Türüne Göre Cümleler',                             category: 'Cümle Türleri' },
  // === KARMA DİL BİLGİSİ ===
  { code: '21.17',   name: 'KARMA DİL BİLGİSİ',                                        category: 'Karma' },
  // === ANLATIM BOZUKLUKLARI ===
  { code: '21.18',   name: 'ANLATIM BOZUKLUKLARI',                                      category: 'Anlatım Bozuklukları' },
];

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
