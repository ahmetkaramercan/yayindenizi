import '../../features/student/domain/entities/learning_outcome.dart';

/// Uygulama genelinde kullanılan kazanımlar
class AppLearningOutcomes {
  AppLearningOutcomes._();

  // Paragraf Kazanımları
  static const LearningOutcome paragraftaAnlam = LearningOutcome(
    id: 'paragrafta_anlam',
    name: 'Paragrafta Anlam',
    description: 'Paragrafın ana düşüncesi, yardımcı düşünceleri ve anlam ilişkileri',
  );

  static const LearningOutcome paragrafYapisi = LearningOutcome(
    id: 'paragraf_yapisi',
    name: 'Paragraf Yapısı',
    description: 'Paragrafın yapısı ve düzenlenmesi',
  );

  static const LearningOutcome paragrafTamamlama = LearningOutcome(
    id: 'paragraf_tamamlama',
    name: 'Paragraf Tamamlama',
    description: 'Paragrafı uygun cümle ile tamamlama',
  );

  // Cümle Kazanımları
  static const LearningOutcome cumledeAnlam = LearningOutcome(
    id: 'cumlede_anlam',
    name: 'Cümlede Anlam',
    description: 'Cümlenin anlamı ve anlam ilişkileri',
  );

  static const LearningOutcome cumleYapisi = LearningOutcome(
    id: 'cumle_yapisi',
    name: 'Cümle Yapısı',
    description: 'Cümlenin yapısı ve öğeleri',
  );

  static const LearningOutcome cumleTamamlama = LearningOutcome(
    id: 'cumle_tamamlama',
    name: 'Cümle Tamamlama',
    description: 'Cümleyi uygun kelime ile tamamlama',
  );

  // Kelime Kazanımları
  static const LearningOutcome kelimeAnlami = LearningOutcome(
    id: 'kelime_anlami',
    name: 'Kelime Anlamı',
    description: 'Kelimelerin anlamları ve kullanımları',
  );

  static const LearningOutcome deyimAtasozu = LearningOutcome(
    id: 'deyim_atasozu',
    name: 'Deyim ve Atasözü',
    description: 'Deyimlerin ve atasözlerinin anlamları',
  );

  // Dil Bilgisi Kazanımları
  static const LearningOutcome sesBilgisi = LearningOutcome(
    id: 'ses_bilgisi',
    name: 'Ses Bilgisi',
    description: 'Ses olayları ve yazım kuralları',
  );

  static const LearningOutcome ekler = LearningOutcome(
    id: 'ekler',
    name: 'Ekler',
    description: 'Yapım ve çekim ekleri',
  );

  static const LearningOutcome sozcukTurleri = LearningOutcome(
    id: 'sozcuk_turleri',
    name: 'Sözcük Türleri',
    description: 'İsim, sıfat, zamir, zarf, fiil vb.',
  );

  // Tüm kazanımları getir
  static List<LearningOutcome> getAll() {
    return [
      paragraftaAnlam,
      paragrafYapisi,
      paragrafTamamlama,
      cumledeAnlam,
      cumleYapisi,
      cumleTamamlama,
      kelimeAnlami,
      deyimAtasozu,
      sesBilgisi,
      ekler,
      sozcukTurleri,
    ];
  }

  // ID'ye göre kazanım bul
  static LearningOutcome? findById(String id) {
    return getAll().firstWhere(
      (outcome) => outcome.id == id,
      orElse: () => const LearningOutcome(
        id: 'unknown',
        name: 'Bilinmeyen Kazanım',
      ),
    );
  }
}


