import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient() as any;

const BOOK_TITLE = 'Dil Bilgisi Denemeleri';

const OUTCOMES: { code: string; name: string; category: string }[] = [
  // === CÜMLE ===
  { code: '21.2.2',  name: 'Cümlede Kavramlar',                                        category: 'Cümle' },
  { code: '21.2.3',  name: 'Parçadaki Cümlelerin İçerik ve Özellikleri',               category: 'Cümle' },
  // === PARAGRAF ===
  { code: '21.4.2',  name: 'Paragrafta Boş Bırakılan Yerleri Tamamlama',               category: 'Paragraf' },
  // === SES BİLGİSİ ===
  { code: '21.6',    name: 'SES BİLGİSİ',                                               category: 'Ses Bilgisi' },
  { code: '21.6.1',  name: 'Ünlülerle İlgili Ses Olayları',                             category: 'Ses Bilgisi' },
  { code: '21.6.2',  name: 'Ünsüzlerle İlgili Ses Olayları',                            category: 'Ses Bilgisi' },
  // === YAZIM KURALLARI ===
  { code: '21.7',    name: 'YAZIM KURALLARI',                                            category: 'Yazım Kuralları' },
  { code: '21.7.1',  name: "de'nin, ki'nin ve mi'nin Yazımı",                            category: 'Yazım Kuralları' },
  { code: '21.7.5',  name: 'Bitişik ve Ayrı Yazılan Kelimeler',                          category: 'Yazım Kuralları' },
  { code: '21.7.9',  name: 'Yazım Kuralları - Karma',                                   category: 'Yazım Kuralları' },
  // === NOKTALAMA İŞARETLERİ ===
  { code: '21.8',    name: 'NOKTALAMA İŞARETLERİ',                                      category: 'Noktalama İşaretleri' },
  { code: '21.8.2',  name: 'Virgül',                                                    category: 'Noktalama İşaretleri' },
  { code: '21.8.3',  name: 'Noktalı Virgül',                                            category: 'Noktalama İşaretleri' },
  { code: '21.8.12', name: 'Noktalama İşaretleri - Karma',                              category: 'Noktalama İşaretleri' },
  // === EKLER VE SÖZCÜK YAPISI ===
  { code: '21.9',    name: 'EKLER VE SÖZCÜK YAPISI',                                    category: 'Ekler ve Sözcük Yapısı' },
  { code: '21.9.1',  name: 'Kök ve Kök Çeşitleri',                                     category: 'Ekler ve Sözcük Yapısı' },
  { code: '21.9.2',  name: 'Ekler ve Ek Çeşitleri',                                    category: 'Ekler ve Sözcük Yapısı' },
  { code: '21.9.4',  name: 'Çekim Ekleri ve Türleri',                                  category: 'Ekler ve Sözcük Yapısı' },
  { code: '21.9.5',  name: 'Yapısı Bakımından Sözcükler',                               category: 'Ekler ve Sözcük Yapısı' },
  // === AD SOYLU SÖZCÜKLER ===
  { code: '21.10',    name: 'AD SOYLU SÖZCÜKLER',                                       category: 'Ad Soylu Sözcükler' },
  { code: '21.10.1',  name: 'İsimler',                                                  category: 'Ad Soylu Sözcükler' },
  { code: '21.10.3',  name: 'Sıfatlar',                                                 category: 'Ad Soylu Sözcükler' },
  { code: '21.10.4',  name: 'Sıfat (21.10.4)',                                          category: 'Ad Soylu Sözcükler' }, // TODO: adını doğrula
  { code: '21.10.8',  name: 'Zamirler',                                                 category: 'Ad Soylu Sözcükler' },
  { code: '21.10.9',  name: 'Zamir (21.10.9)',                                          category: 'Ad Soylu Sözcükler' }, // TODO: adını doğrula
  { code: '21.10.10', name: 'Zarflar',                                                  category: 'Ad Soylu Sözcükler' },
  { code: '21.10.11', name: 'Zarf (21.10.11)',                                          category: 'Ad Soylu Sözcükler' }, // TODO: adını doğrula
  { code: '21.10.15', name: 'Ad Soylu Sözcükler - Karma',                               category: 'Ad Soylu Sözcükler' },
  // === TAMLAMALAR ===
  { code: '21.11',   name: 'TAMLAMALAR',                                                category: 'Tamlamalar' },
  { code: '21.11.1', name: 'İsim Tamlamaları',                                          category: 'Tamlamalar' },
  { code: '21.11.2', name: 'Sıfat Tamlamaları',                                         category: 'Tamlamalar' },
  // === FİİLLER ===
  { code: '21.12',   name: 'FİİLLER',                                                   category: 'Fiiller' },
  { code: '21.12.1', name: 'Fiillerde Kip - Kişi - Zaman',                              category: 'Fiiller' },
  { code: '21.12.5', name: 'Fiilde Yapı',                                               category: 'Fiiller' },
  { code: '21.12.6', name: 'Fiiller - Karma',                                           category: 'Fiiller' },
  // === FİİLİMSİLER ===
  { code: '21.13',   name: 'FİİLİMSİLER',                                               category: 'Fiilimsi' },
  // === FİİL ÇATISI ===
  { code: '21.14',   name: 'FİİL ÇATISI',                                               category: 'Fiil Çatısı' },
  { code: '21.14.1', name: 'Özne-Yüklem İlişkisine Göre Fiil Çatıları',                category: 'Fiil Çatısı' },
  // === CÜMLENİN ÖGELERİ ===
  { code: '21.15',   name: 'CÜMLENİN ÖGELERİ',                                         category: 'Cümlenin Ögeleri' },
  { code: '21.15.1', name: 'Özne ve Yüklem',                                            category: 'Cümlenin Ögeleri' },
  { code: '21.15.3', name: 'Ara Söz - Ara Cümle / Cümle Dışı Unsur / Vurgu',           category: 'Cümlenin Ögeleri' },
  { code: '21.15.6', name: 'Cümlenin Ögeleri - Karma',                                  category: 'Cümlenin Ögeleri' },
  // === CÜMLE TÜRLERİ ===
  { code: '21.16',   name: 'CÜMLE TÜRLERİ',                                             category: 'Cümle Türleri' },
  { code: '21.16.3', name: 'Yüklemin Türüne Göre Cümleler',                             category: 'Cümle Türleri' },
  { code: '21.16.5', name: 'Cümle Türleri (21.16.5)',                                   category: 'Cümle Türleri' }, // TODO: adını doğrula
  // === KARMA DİL BİLGİSİ ===
  { code: '21.17',   name: 'KARMA DİL BİLGİSİ',                                        category: 'Karma' },
  { code: '21.17.1', name: 'Karma Dil Bilgisi',                                         category: 'Karma' },
  // === ANLATIM BOZUKLUKLARI ===
  { code: '21.18',   name: 'ANLATIM BOZUKLUKLARI',                                      category: 'Anlatım Bozuklukları' },
  { code: '21.18.1', name: 'Yapısal Anlatım Bozuklukları',                              category: 'Anlatım Bozuklukları' },
];

async function main() {
  console.log('Seeding Dil Bilgisi Denemeleri - learning outcomes');

  const book = await prisma.book.findFirst({
    where: { title: BOOK_TITLE },
    select: { id: true },
  });
  if (!book) {
    throw new Error(`Book "${BOOK_TITLE}" not found. Run seed:dilbilgisi:structure first.`);
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
