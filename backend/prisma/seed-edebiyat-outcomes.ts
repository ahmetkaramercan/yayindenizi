import { PrismaClient, BookCategory } from '@prisma/client';

const prisma = new PrismaClient();

const BOOK_TITLE = 'Edebiyat Denemeleri';

const OUTCOMES: { code: string; name: string; category: string }[] = [
  { code: '9.10.4', name: 'Söz Öbeklerinde Anlam', category: 'Edebiyat' },
  { code: '9.11.3', name: 'Parçadaki Cümlelerin İçerik ve Özellikleri', category: 'Edebiyat' },
  { code: '9.12.2', name: 'Düşünceyi Geliştirme Yolları', category: 'Edebiyat' },
  { code: '9.14.4', name: 'Paragrafın Yorumlanması', category: 'Edebiyat' },
  { code: '9.14.2', name: 'Paragrafta Yardımcı Düşünceler', category: 'Edebiyat' },
  { code: '12.2.4', name: 'Söz Sanatları (Edebî Sanatlar)', category: 'Edebiyat' },
  { code: '12.2.3', name: 'Konularına Göre Şiir Türleri', category: 'Edebiyat' },
  { code: '12.4.2', name: 'Anonim Halk Edebiyatı', category: 'Edebiyat' },
  { code: '12.4.5', name: 'Tekke Edebiyatı', category: 'Edebiyat' },
  { code: '10.2.2', name: 'Halk Hikâyeleri', category: 'Edebiyat' },
  { code: '12.5.3', name: 'Divan Edebiyatı Nazım Biçimleri', category: 'Edebiyat' },
  { code: '10.2.3', name: 'Mesnevi', category: 'Edebiyat' },
  { code: '12.5.4', name: 'Divan Şiirinin Temsilcileri', category: 'Edebiyat' },
  { code: '12.7.5', name: 'Tanzimat Dönemi Sanatçıları', category: 'Edebiyat' },
  { code: '12.8.5', name: 'Servetifunun Dönemi Sanatçıları', category: 'Edebiyat' },
  { code: '12.10.4', name: 'Toplumcu Gerçekçi Hikâye', category: 'Edebiyat' },
  { code: '11.5.2', name: 'Fıkra', category: 'Edebiyat' },
  { code: '12.9.2', name: 'Millî Edebiyat Dönemi\'nde Şiir ve Şairler', category: 'Edebiyat' },
  { code: '12.10.18', name: 'Cumhuriyet Dönemi\'nde Bireyin İç Dünyasını Esas Alan Roman', category: 'Edebiyat' },
  { code: '12.10.7', name: 'Saf (Öz) Şiir - Yedi Meşaleciler', category: 'Edebiyat' },
  { code: '12.10.28', name: 'Cumhuriyet Dönemi\'nde Tiyatro', category: 'Edebiyat' },
  { code: '12.6.1', name: 'Edebî Akımlar', category: 'Edebiyat' },
  { code: '9.10.2', name: 'Metne Sözcük Yerleştirme', category: 'Edebiyat' },
  { code: '9.14.1', name: 'Paragrafta Ana Düşünce (Ana Fikir)', category: 'Edebiyat' },
  { code: '9.11.6', name: 'İki Cümleyi Birleştirme', category: 'Edebiyat' },
  { code: '9.13.3', name: 'Paragrafta Anlatım Akışını Bozan Cümle', category: 'Edebiyat' },
  { code: '12.2.1', name: 'Şiir (Nazım) / Şiirde Ahenk Ögeleri', category: 'Edebiyat' },
  { code: '10.4.1', name: 'Destan', category: 'Edebiyat' },
  { code: '10.3.3.2', name: 'Anonim halk şiiri nazım şekillerini tanır', category: 'Edebiyat' },
  { code: '12.2.12', name: 'Masal-Fabl', category: 'Edebiyat' },
  { code: '12.5.5', name: 'Divan Edebiyatında Nesir', category: 'Edebiyat' },
  { code: '12.7.3', name: 'Tanzimat Edebiyatında Türler', category: 'Edebiyat' },
  { code: '10.5.4.2', name: 'Millî Edebiyat Dönemi yazarlarını tanır.', category: 'Edebiyat' },
  { code: '10.31.6.5', name: 'Millî Edebiyat Dönemi\'nde şiir', category: 'Edebiyat' },
  { code: '12.10.26', name: 'Cumhuriyet Dönemi\'nde Modernizmi ve Postmodernizmi Esas Alan Roman', category: 'Edebiyat' },
  { code: '12.10.8', name: 'Toplumcu Şiir (1923-1940)', category: 'Edebiyat' },
  { code: '12.10.24', name: '1980 Sonrası Roman', category: 'Edebiyat' },
  { code: '12.9.4', name: 'Cümleyi Yorumlama ve Açıklama', category: 'Edebiyat' },
  { code: '9.12.1', name: 'Anlatım Teknikleri', category: 'Edebiyat' },
  { code: '12.4.4', name: 'Âşık Edebiyatı Saz Şairleri', category: 'Edebiyat' },
  { code: '12.7.4', name: 'Tanzimat Dönemi Türk Romanı', category: 'Edebiyat' },
  { code: '11.3.2.1', name: 'Servetifünun Dönemi şiirinin genel özelliklerini kavrar', category: 'Edebiyat' },
  { code: '11.6.4', name: 'Millî Edebiyat Dönemi\'nde Roman', category: 'Edebiyat' },
  { code: '12.10.11', name: 'I. Yeni (Garip Akımı) (1940-1954)', category: 'Edebiyat' },
  { code: '12.10.22', name: '1923-1950 Arasında Roman', category: 'Edebiyat' },
  { code: '22.10.21', name: 'Cumhuriyet Dönemi\'nde Roman', category: 'Edebiyat' },
  { code: '12.10.25', name: 'Cumhuriyet Dönemi\'nde Toplumcu Gerçekçi Roman', category: 'Edebiyat' },
  { code: '9.13.1', name: 'Paragrafı İkiye Ayırma', category: 'Edebiyat' },
  { code: '9.13.2', name: 'Paragrafta Boş Bırakılan Yerleri Tamamlama', category: 'Edebiyat' },
  { code: '12.4.3', name: 'Âşık Edebiyatı', category: 'Edebiyat' },
  { code: '10.4.2', name: 'Efsane', category: 'Edebiyat' },
  { code: '12.4.6', name: 'Tekke Edebiyatı Şairleri', category: 'Edebiyat' },
  { code: '12.10.9', name: 'Millî Edebiyat Zevk ve Anlayışını Sürdüren Şiir', category: 'Edebiyat' },
  { code: '12.8.6', name: 'Fecriati Edebiyatının Oluşumu ve Özellikleri', category: 'Edebiyat' },
  { code: '21.3.9', name: 'Millî Edebiyat Dönemi\'nde Hikâye', category: 'Edebiyat' },
  { code: '12.10.19', name: 'Cumhuriyet Dönemi\'nde Dinî Değerleri ve Metafizik Anlayışı Öne Çıkaran Şiir', category: 'Edebiyat' },
  { code: '12.10.23', name: '1950-1980 Arasında Roman', category: 'Edebiyat' },
  { code: '9.11.4', name: 'Cümleyi Yorumlama ve Açıklama', category: 'Edebiyat' },
  { code: '9.3.7', name: 'Şiirde ahengi sağlayan özellikleri/unsurları belirler', category: 'Edebiyat' },
  { code: '10.6.3', name: 'Geleneksel Türk tiyatrosu türlerini ayırt eder ve özelliklerini bilir', category: 'Edebiyat' },
  { code: '10.2.2.1', name: 'Dede Korkut Hikâyeleri\'ni inceler ve genel özelliklerini kavrar', category: 'Edebiyat' },
  { code: '10.3.4.3', name: 'Tasavvuf şairlerini tanır', category: 'Edebiyat' },
  { code: '10.3.6.3', name: 'Divan edebiyatı sanatçılarını tanır', category: 'Edebiyat' },
  { code: '10.2.4.2', name: 'Mesnevi türündeki önemli yazar ve eserleri tanır', category: 'Edebiyat' },
  { code: '10.3.6.2', name: 'Divan edebiyatı nazım türlerini inceler', category: 'Edebiyat' },
  { code: '11.3.1.2', name: 'Tanzimat Dönemi şairlerini tanır', category: 'Edebiyat' },
  { code: '11.3.3.2', name: 'Fecriati şairlerini tanır', category: 'Edebiyat' },
  { code: '11.3.5.2', name: 'Beş Hececileri tanır ve şiirlerinin genel özelliklerini kavrar', category: 'Edebiyat' },
  { code: '11.2.2.2', name: 'Bireyin iç dünyasını esas alan hikâyelerin özelliklerini kavrar ve bu anlayışla eser veren yazarları bilir', category: 'Edebiyat' },
  { code: '12.3.8.2', name: 'İkinci yeni şairlerini bilir', category: 'Edebiyat' },
  { code: '12.3.1.2', name: 'Cumhuriyet Dönemi saf şiir anlayışının şairlerini bilir', category: 'Edebiyat' },
  { code: '12.5.2.2', name: '1950-1980 arasında tiyatro eseri veren yazarları tanır', category: 'Edebiyat' },
  { code: '11.1.2.1', name: 'Edebi akımları ve edebiyata yansımalarını bilir', category: 'Edebiyat' },
  { code: '12.4.3.2', name: 'Modernizmi esas alan romanların özelliklerini kavrar', category: 'Edebiyat' },
  { code: '9.3.9', name: 'Şiirdeki mazmun, imge ve edebî sanatları belirleyerek bunların anlama katkısını değerlendirir', category: 'Edebiyat' },
  { code: '10.3.2.1', name: 'Geçiş Dönemi edebiyatını tanır ve genel özelliklerini kavrar', category: 'Edebiyat' },
  { code: '10.2.4.1', name: 'Mesneviyi tanımlar ve genel özelliklerini kavrar', category: 'Edebiyat' },
  { code: '22.3.2', name: 'İslamiyet Öncesi Türk Edebiyatı', category: 'Edebiyat' },
  { code: '10.7.1', name: 'Divan Edebiyatında Nesir', category: 'Edebiyat' },
  { code: '11.5.2.2', name: 'Servetifünun Dönemi roman yazarlarını tanır', category: 'Edebiyat' },
  { code: '12.4.1.1', name: 'Bireyin iç dünyasını esas alan romanların özelliklerini kavrar', category: 'Edebiyat' },
  { code: '12.4.2.2', name: 'Toplumcu gerçekçi roman yazarlarını tanır', category: 'Edebiyat' },
  { code: '12.3.4.2', name: 'Mavi hareketini bilir', category: 'Edebiyat' },
  { code: '22.10.6', name: 'Cumhuriyet Dönemi\'nde Şiir', category: 'Edebiyat' },
  { code: '9.13.5', name: 'Cümlelerden Paragraf Oluşturma', category: 'Edebiyat' },
  { code: '9.3.8', name: 'Şiirin nazım biçimini ve nazım türünü tespit eder', category: 'Edebiyat' },
  { code: '10.4.1.4', name: 'İslamiyetten önce ve islamiyetten sonra Türk destanlarını bilir', category: 'Edebiyat' },
  { code: '10.3.4.2', name: 'Dinî-Tasavvufi halk şiiri nazım şekillerini inceler', category: 'Edebiyat' },
  { code: '11.5.1.2', name: 'Tanzimat Dönemi roman yazarlarını tanır', category: 'Edebiyat' },
  { code: '11.2.3.2', name: 'Servetifünun Dönemi hikâye yazarlarını tanır', category: 'Edebiyat' },
  { code: '10.31.6.5.1', name: 'Millî Edebiyat Dönemi şiirinin genel özelliklerini kavrar.', category: 'Edebiyat' },
  { code: '12.3.8.1', name: 'İkinci yeni şiir anlayışının genel özelliklerini bilir', category: 'Edebiyat' },
  { code: '12.2.1.1', name: '1960 sonrası hikâyesinin genel özelliklerini kavrar', category: 'Edebiyat' },
  { code: '10.2.3.1', name: 'Halk hikâyesini tanımlar ve genel özelliklerini kavrar', category: 'Edebiyat' },
  { code: '9.4.2.1', name: 'Fabl türünün genel özelliklerini belirler', category: 'Edebiyat' },
  { code: '10.6.2.2', name: 'Tanzimat Dönemi tiyatro yazarlarını tanır', category: 'Edebiyat' },
  { code: '10.3.3.4', name: 'Âşık edebiyatı nazım türlerini inceler', category: 'Edebiyat' },
  { code: '12.3.9.2', name: 'Dinî değerleri, geleneğe duyarlığı ve metafizik anlayışı öne çıkaran modern şairleri tanır', category: 'Edebiyat' },
  { code: '22.4.2', name: 'Anonim Halk Edebiyatı', category: 'Edebiyat' },
  { code: '10.3.3.3', name: 'Âşık tarzı halk şiirinin genel özelliklerini açıklar', category: 'Edebiyat' },
  { code: '11.5.3.2', name: 'Millî Edebiyat Dönemi yazarlarını tanır', category: 'Edebiyat' },
  { code: '12.4.1.2', name: 'Cumhuriyet Dönemi\'nde eser veren roman yazarlarını tanır', category: 'Edebiyat' },
  { code: '11.3.2.2', name: 'Servetifünun Dönemi şairlerini tanır', category: 'Edebiyat' },
  { code: '12.2.2.1', name: 'Modernist hikâyelerin özelliklerini kavrar ve bu anlayışla eser veren yazarları bilir', category: 'Edebiyat' },
  { code: '12.3.6.1', name: '1960 sonrası toplumcu eğilimleri yansıtan şiir anlayışının genel özelliklerini bilir', category: 'Edebiyat' },
  { code: '11.14.6', name: 'Paragrafın Konusu', category: 'Edebiyat' },
  { code: '11.3.1.1', name: 'Tanzimat Dönemi şiirinin genel özelliklerini kavrar', category: 'Edebiyat' },
  { code: '12.4.4.1', name: 'Milli-Dinî Duyarlılığı Yansıtan romanları tanır', category: 'Edebiyat' },
  { code: '12.3.2.1', name: 'Garip akımına ait şiir anlayışının genel özelliklerini bilir', category: 'Edebiyat' },
  { code: '22.5.1', name: 'Divan Edebiyatı Genel Özellikler', category: 'Edebiyat' },
  { code: '10.31.6.4', name: 'Servetifünun Dönemi\'nde şiir', category: 'Edebiyat' },
  { code: '12.3.4.1', name: 'İkinci yeni şiir anlayışının genel özelliklerini bilir', category: 'Edebiyat' },
  { code: '12.3.10.1', name: 'Cumhuriyet Dönemi\'nde Bağımsız Şairleri tanır', category: 'Edebiyat' },
  { code: '12.3.5.1', name: 'Millî edebiyat anlayışını yansıtan şiirlerin genel özelliklerini bilir', category: 'Edebiyat' },
  { code: '22.10.2', name: 'Cumhuriyet Dönemi\'nde Hikâye', category: 'Edebiyat' },
  { code: '9.3.1.14', name: 'Metinler arası karşılaştırmalar yapar', category: 'Edebiyat' },
  { code: '11.6.1.1', name: '1923-1950 arasında eser veren yazarların ve bu dönemde yazılan romanların genel özelliklerini kavrar.', category: 'Edebiyat' },
  { code: '9.4.1.2', name: 'Türün önemli yazarlarını ve eserlerini sıralar', category: 'Edebiyat' },
  { code: '9.4.1.1', name: 'Masal türünün genel özelliklerini belirler', category: 'Edebiyat' },
  { code: '10.3.3.1', name: 'Halk şiirini tanımlar ve genel özelliklerini kavrar.', category: 'Edebiyat' },
  { code: '10.31.6.5.2', name: 'Millî Edebiyat Dönemi şairlerini tanır.', category: 'Edebiyat' },
  { code: '22.10.25', name: 'Cumhuriyet Dönemi\'nde Toplumcu Gerçekçi Roman', category: 'Edebiyat' },
];

async function main() {
  console.log('Seeding Edebiyat Denemeleri - outcomes');

  // 1. Create or find book
  let book = await prisma.book.findFirst({
    where: { title: BOOK_TITLE },
    select: { id: true },
  });

  if (!book) {
    book = await prisma.book.create({
      data: {
        title: BOOK_TITLE,
        description: 'TYT Edebiyat deneme kitabı - 16 deneme, her denemede 24 soru',
        category: BookCategory.DENEME,
      },
      select: { id: true },
    });
    console.log(`✓ Book created: ${book.id}`);
  } else {
    console.log(`✓ Book found: ${book.id}`);
  }

  const bookId = book.id;

  // 2. Upsert outcomes
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
