/// Günün Bilgisi - Türkçe yazım kuralları veritabanı
/// Her gün bir bilgi gösterilir, liste bitince başa döner.

class GununBilgisiItem {
  final String correct;
  final String incorrect;
  final String? description;

  const GununBilgisiItem({
    required this.correct,
    required this.incorrect,
    this.description,
  });
}

const List<GununBilgisiItem> gununBilgisiListesi = [
  GununBilgisiItem(
      correct: "Akşamüstü",
      incorrect: "Akşam üstü",
      description: "Somut bir yer bildirmeyen 'üst' kelimesi bitişik yazılır."),
  GununBilgisiItem(
      correct: "Hal",
      incorrect: "Hâl",
      description: "Sebze, meyve satılan yer anlamındaysa şapkasız yazılır."),
  GununBilgisiItem(
      correct: "Hâl",
      incorrect: "Hal",
      description:
          "Durum, vaziyet anlamındaysa düzeltme işareti (şapka) kullanılır."),
  GununBilgisiItem(
      correct: "Hakim",
      incorrect: "Hâkim",
      description: "Bilge, her şeyi bilen anlamındaysa şapkasız yazılır."),
  GununBilgisiItem(
      correct: "Hâkim",
      incorrect: "Hakim",
      description: "Yargıç veya egemenlik kuran anlamındaysa şapkalı yazılır."),
  GununBilgisiItem(correct: "Havaalanı", incorrect: "Hava alanı"),
  GununBilgisiItem(correct: "Hava yolu", incorrect: "Havayolu"),
  GununBilgisiItem(correct: "Eloğlu", incorrect: "El oğlu"),
  GununBilgisiItem(correct: "Elkızı", incorrect: "El kızı"),
  GununBilgisiItem(correct: "Dayıoğlu", incorrect: "Dayı oğlu"),
  GununBilgisiItem(correct: "Çevrim dışı", incorrect: "Çevrimdışı"),
  GununBilgisiItem(correct: "Çevre yolu", incorrect: "Çevreyolu"),
  GununBilgisiItem(correct: "Egzoz", incorrect: "Egzos / Eksoz"),
  GununBilgisiItem(
      correct: "Hiçbir şey",
      incorrect: "Hiç birşey",
      description: "Şey her zaman ayrı yazılır."),
  GununBilgisiItem(correct: "Birdenbire", incorrect: "Birden bire"),
  GununBilgisiItem(correct: "Darmadağınık", incorrect: "Darma dağınık"),
  GununBilgisiItem(correct: "Köpek balığı", incorrect: "Köpekbalığı"),
  GununBilgisiItem(
      correct: "Çörek otu / Dereotu",
      incorrect: "Çörekotu / Dere otu",
      description: "Dereotu istisnadır, bitişik yazılır."),
  GununBilgisiItem(correct: "Zeytinyağı", incorrect: "Zeytin yağı"),
  GununBilgisiItem(correct: "Darbetmek", incorrect: "Darp etmek"),
  GununBilgisiItem(correct: "Hoşça kal", incorrect: "Hoşçakal"),
  GununBilgisiItem(correct: "Hoş geldiniz", incorrect: "Hoşgeldiniz"),
  GununBilgisiItem(correct: "Doküman", incorrect: "Döküman"),
  GununBilgisiItem(correct: "Unvan", incorrect: "Ünvan"),
  GununBilgisiItem(correct: "Pardösü", incorrect: "Pardesü"),
  GununBilgisiItem(
      correct: "18 Haziran 2022",
      incorrect: "18 haziran 2022",
      description: "Belirli bir tarih bildiren ay adları büyük harfle başlar."),
  GununBilgisiItem(correct: "Etüdü", incorrect: "Etütü"),
  GununBilgisiItem(correct: "Geçidi", incorrect: "Geçiti"),
  GununBilgisiItem(correct: "Simidi", incorrect: "Simiti"),
  GununBilgisiItem(correct: "Bir an", incorrect: "Biran"),
  GununBilgisiItem(
      correct: "Birçoğu / Birkaçı", incorrect: "Bir çoğu / Bir kaçı"),
  GununBilgisiItem(correct: "Art arda", incorrect: "Arda arda / Artarda"),
  GununBilgisiItem(
      correct: "Peşi sıra / Ardı sıra", incorrect: "Peşisıra / Ardısıra"),
  GununBilgisiItem(correct: "Ayrık otu", incorrect: "Ayrıkotu"),
  GununBilgisiItem(correct: "Güzelavrat otu", incorrect: "Güzel avrat otu"),
  GununBilgisiItem(
      correct: "Sivri biber / Dolma biber",
      incorrect: "Sivribiber / Dolmabiber"),
  GununBilgisiItem(
      correct: "Karabiber / Kırmızıbiber / Yeşilbiber",
      incorrect: "Kara biber / Kırmızı biber",
      description: "Renk adlarıyla kurulan bitki adları bitişik yazılır."),
  GununBilgisiItem(
      correct: "Kuru çay / Kuru boya / Kuru yemiş",
      incorrect: "Kuruçay / Kuruyemiş"),
  GununBilgisiItem(
      correct: "Yeşil fasulye / Yeşil soğan",
      incorrect: "Yeşilfasulye / Yeşilsoğan"),
  GununBilgisiItem(correct: "Orduevi / Aşevi", incorrect: "Ordu evi / Aş evi"),
  GununBilgisiItem(
      correct: "Orman evi / Dağ evi / Bağ evi", incorrect: "Ormanevi / Dağevi"),
  GununBilgisiItem(correct: "Baba ocağı", incorrect: "Babaocağı"),
  GununBilgisiItem(correct: "Atardamar", incorrect: "Atar damar"),
  GununBilgisiItem(
      correct: "Ana dil / Ana deniz / Ana dal", incorrect: "Anadil / Anadeniz"),
  GununBilgisiItem(correct: "Anaokulu", incorrect: "Ana okulu"),
  GununBilgisiItem(correct: "Dil balığı", incorrect: "Dilbalığı"),
  GununBilgisiItem(correct: "Dil bilgisi", incorrect: "Dilbilgisi"),
  GununBilgisiItem(
      correct: "Dinî bayram / Millî maç",
      incorrect: "Dini bayram / Milli maç",
      description: "Nispet i'si (î) kullanılır."),
  GununBilgisiItem(
      correct: "Resmî bayram / Tarihî gün",
      incorrect: "Resmi bayram / Tarihi gün"),
  GununBilgisiItem(
      correct: "Resmigeçit / Resmikabul",
      incorrect: "Resmi geçit / Resmi kabul"),
  GununBilgisiItem(correct: "Şikâyet / Rüzgâr", incorrect: "Sikayet / Rüzgar"),
  GununBilgisiItem(
      correct: "Dahil",
      incorrect: "Dâhil",
      description: "Bir işe karışmış olmak anlamındaysa şapkasızdır."),
  GununBilgisiItem(
      correct: "Dâhil",
      incorrect: "Dahil",
      description: "İçeri veya 'ile birlikte' anlamındaysa şapkalı yazılır."),
  GununBilgisiItem(
      correct: "Tabii",
      incorrect: "Tabi",
      description: "Doğal, olağan anlamındaysa çift 'i' ile yazılır."),
  GununBilgisiItem(
      correct: "Tabi",
      incorrect: "Tabii",
      description: "Bağımlı veya yayımcı anlamındaysa tek 'i' ile yazılır."),
  GununBilgisiItem(correct: "Cevretmek", incorrect: "Cevr etmek"),
  GununBilgisiItem(correct: "Halletmek", incorrect: "Hal etmek"),
  GununBilgisiItem(
      correct: "Takdir etmek / Terk etmek",
      incorrect: "Takdiretmek / Terketmek"),
  GununBilgisiItem(correct: "Atabey / Ağabey", incorrect: "Ata bey / Ağa bey"),
  GununBilgisiItem(
      correct: "Hanımanne / Hanımefendi / Hanımeli",
      incorrect: "Hanım anne / Hanım eli"),
  GununBilgisiItem(correct: "Çapanoğlu", incorrect: "Çapan oğlu"),
  GununBilgisiItem(correct: "Deli divane", incorrect: "Delidivane"),
  GununBilgisiItem(correct: "Delikanlı", incorrect: "Deli kanlı"),
  GununBilgisiItem(correct: "Darağacı", incorrect: "Dar ağacı"),
  GununBilgisiItem(correct: "Soya çekim", incorrect: "Soyaçekim"),
  GununBilgisiItem(
      correct: "Antialerjik / Antibakteriyel", incorrect: "Anti alerjik"),
  GununBilgisiItem(correct: "Antrenman / Antrenör", incorrect: "Antreman"),
  GununBilgisiItem(correct: "Laboratuvar / Laborant", incorrect: "Laboratuar"),
  GununBilgisiItem(correct: "Aksesuar", incorrect: "Aksesuar (Doğru)"),
  GununBilgisiItem(correct: "Entelektüel", incorrect: "Entellektüel"),
  GununBilgisiItem(correct: "Stajyer", incorrect: "Stajer"),
  GununBilgisiItem(correct: "Sömestir", incorrect: "Sömestr"),
  GununBilgisiItem(correct: "Hristiyanlaşma", incorrect: "Hıristiyanlaşma"),
  GununBilgisiItem(correct: "Heykeltıraş", incorrect: "Heykeltraş"),
  GununBilgisiItem(correct: "Dil peyniri", incorrect: "Dilpeyniri"),
  GununBilgisiItem(correct: "Otoyol", incorrect: "Oto yol"),
  GununBilgisiItem(
      correct: "Saygıdeğer / Vatansever / Kadirşinas",
      incorrect: "Saygı değer / Vatan sever"),
  GununBilgisiItem(
      correct: "Mütevazı",
      incorrect: "Mütevazi",
      description: "Alçak gönüllü anlamındaki kelime 'ı' ile biter."),
  GununBilgisiItem(
      correct: "Mütevazi",
      incorrect: "Mütevazı",
      description: "Paralel anlamındaki kelime 'i' ile biter."),
  GununBilgisiItem(
      correct: "Alçak gönüllü / Alçak basınç",
      incorrect: "Alçakgönüllü / Alçakbasınç"),
  GununBilgisiItem(
      correct: "Yazar kasa / Dönme dolap", incorrect: "Yazarkasa / Dönmedolap"),
  GununBilgisiItem(correct: "Tükenmez kalem", incorrect: "Tükenmezkalem"),
  GununBilgisiItem(
      correct: "Yazarçizer / Okuryazar", incorrect: "Yazar çizer / Okur yazar"),
  GununBilgisiItem(correct: "İkide bir", incorrect: "İkidebir"),
  GununBilgisiItem(
      correct: "Birebir",
      incorrect: "Bire bir",
      description: "Etkisi kesin (ilaç vb.) anlamındaysa bitişik yazılır."),
  GununBilgisiItem(
      correct: "Bire bir",
      incorrect: "Birebir",
      description: "Karşılıklı veya oran anlamındaysa ayrı yazılır."),
  GununBilgisiItem(
      correct: "Binbir",
      incorrect: "Bin bir",
      description: "Pek çok, çok sayıda anlamındaysa bitişik yazılır."),
  GununBilgisiItem(
      correct: "Güzel Sanatlar Akademisinin",
      incorrect: "Akademisi'nin",
      description: "Kurum, kuruluş adlarına gelen ekler kesmeyle ayrılmaz."),
  GununBilgisiItem(
      correct: "Türkçeyi / Türkler / Safranbolulular",
      incorrect: "Türkçe'yi / Türk'ler",
      description: "Yapım eki almış özel isimlere gelen ekler ayrılmaz."),
  GununBilgisiItem(
      correct: "Dershane / Darphane / Hastane / Pastane",
      incorrect: "Dersan / Hastahane"),
  GununBilgisiItem(
      correct: "İlkokul / Ortaokul", incorrect: "İlk okul / Orta okul"),
  GununBilgisiItem(
      correct: "Lisansüstü / Yükseköğrenim / Yükseköğretim",
      incorrect: "Lisans üstü / Yüksek öğrenim"),
  GununBilgisiItem(
      correct: "Açık öğretim / Açık lise / Açık oturum",
      incorrect: "Açıköğretim / Açıklise"),
  GununBilgisiItem(correct: "Başa baş", incorrect: "Başabaş"),
  GununBilgisiItem(
      correct: "Başkâtip / Başyapıt / Başöğretmen / Başörtüsü",
      incorrect: "Baş katip / Baş yapıt"),
  GununBilgisiItem(correct: "Menü", incorrect: "Menü (Doğru)"),
  GununBilgisiItem(correct: "Akılalmaz", incorrect: "Akıl almaz"),
  GununBilgisiItem(correct: "Akıl kârı", incorrect: "Akılkârı"),
  GununBilgisiItem(
      correct: "Âlem",
      incorrect: "Alem",
      description: "Evren, dünya anlamındaysa şapkalı yazılır."),
  GununBilgisiItem(
      correct: "Alem",
      incorrect: "Âlem",
      description: "Bayrak veya simge anlamındaysa şapkasız yazılır."),
  GununBilgisiItem(correct: "Deyince / Deyip", incorrect: "Dyince / Diyip"),
  GununBilgisiItem(
      correct: "Avrupa Birliği'ne",
      incorrect: "Avrupa Birliğine",
      description: "İstisna: AB'ye gelen ek kesme ile ayrılır."),
  GununBilgisiItem(
      correct: "Amik Ovamızın / Amik Ovası'na", incorrect: "Amik ovası"),
  GununBilgisiItem(
      correct: "Cumhuriyet Dönemi Türk Edebiyatı'na",
      incorrect: "Cumhuriyet dönemi"),
  GununBilgisiItem(correct: "Kedi balığı", incorrect: "Kedibalığı"),
  GununBilgisiItem(
      correct: "Kedidili",
      incorrect: "Kedi dili",
      description: "Bisküvi anlamındaysa bitişik yazılır."),
  GununBilgisiItem(
      correct: "Çalı kuşu / Deve kuşu", incorrect: "Çalıkuşu / Devekuşu"),
  GununBilgisiItem(
      correct: "Ateş böceği / Hamam böceği",
      incorrect: "Ateşböceği / Hamamböceği"),
  GununBilgisiItem(
      correct: "Yer elması / Yer çekimi", incorrect: "Yerelması / Yerçekimi"),
  GununBilgisiItem(correct: "Yeryüzü", incorrect: "Yer yüzü"),
  GununBilgisiItem(
      correct: "Yeraltı",
      incorrect: "Yer altı",
      description: "Gizli ve yasa dışı anlamındaysa bitişik yazılır."),
  GununBilgisiItem(
      correct: "Yer altı",
      incorrect: "Yeraltı",
      description: "Somut olarak yerin altı anlamındaysa ayrı yazılır."),
  GununBilgisiItem(
      correct: "Hava küre / Su küre", incorrect: "Havaküre / Suküre"),
  GununBilgisiItem(correct: "Çoban Yıldızı", incorrect: "Çoban yıldızı"),
  GununBilgisiItem(correct: "Kuyruklu yıldız", incorrect: "Kuyrukluyıldız"),
  GununBilgisiItem(correct: "Çalar saat", incorrect: "Çalarsaat"),
  GununBilgisiItem(
      correct: "Suçüstü / Öğleüzeri / Ayaküzeri",
      incorrect: "Suç üstü / Öğle üzeri"),
  GununBilgisiItem(
      correct: "İçişleri / Dışişleri", incorrect: "İç işleri / Dış işleri"),
  GununBilgisiItem(correct: "Memnun olunma", incorrect: "Memnolunma"),
  GununBilgisiItem(correct: "Menedilme / Menediş", incorrect: "Men edilme"),
  GununBilgisiItem(correct: "Katetmek", incorrect: "Kat etmek"),
  GununBilgisiItem(correct: "Baş ucu kitabı", incorrect: "Başucu kitabı"),
  GununBilgisiItem(
      correct: "Başucu",
      incorrect: "Baş ucu",
      description: "Gökbilim terimi anlamındaysa bitişik yazılır."),
  GununBilgisiItem(
      correct: "Dizüstü bilgisayar", incorrect: "Diz üstü bilgisayar"),
  GununBilgisiItem(
      correct: "Göz bebeği / Göz nuru", incorrect: "Gözbebeği / Göznuru"),
  GununBilgisiItem(correct: "Gözyaşı", incorrect: "Göz yaşı"),
  GununBilgisiItem(
      correct: "Türk Dili dergisi",
      incorrect: "Türk Dili Dergisi",
      description: "Özel isme dahil olmayan 'dergi' kelimesi küçük yazılır."),
  GununBilgisiItem(correct: "At sineği", incorrect: "Atsineği"),
  GununBilgisiItem(correct: "Karasinek", incorrect: "Kara sinek"),
  GununBilgisiItem(correct: "Kutup ayısı", incorrect: "Kutupayısı"),
  GununBilgisiItem(correct: "Bozayı", incorrect: "Boz ayı"),
  GununBilgisiItem(
      correct: "13.00'te",
      incorrect: "13.00'de",
      description: "Saat 13 'on üç' diye okunduğu için 'te' eki gelir."),
  GununBilgisiItem(correct: "17.30'da", incorrect: "17.30'ta"),
];

/// Bugünün bilgisi index'ini döndürür.
/// Epoch'tan bu yana geçen gün sayısını liste uzunluğuna modülo alarak hesaplar.
/// Her gün farklı bir bilgi gösterilir, liste bitince başa döner.
int getGununBilgisiIndex() {
  final now = DateTime.now();
  final epoch = DateTime(2024, 1, 1);
  final daysSinceEpoch = now.difference(epoch).inDays;
  return daysSinceEpoch % gununBilgisiListesi.length;
}

/// Bugünün bilgisini döndürür.
GununBilgisiItem getGununBilgisi() {
  return gununBilgisiListesi[getGununBilgisiIndex()];
}
