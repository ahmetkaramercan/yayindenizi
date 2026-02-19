# Teacher Model

Bu klasörde Öğretmen ile ilgili data modelleri bulunur.

## TeacherModel

Öğretmen verilerini JSON formatında serialize/deserialize etmek için kullanılır.

### Özellikler:
- `id`: Öğretmen ID'si (opsiyonel)
- `adSoyad`: Ad Soyad (zorunlu)
- `email`: Email adresi (zorunlu)
- `sifre`: Şifre (opsiyonel, güvenlik için genelde gönderilmez)
- `il`: İl bilgisi (opsiyonel)
- `ilce`: İlçe bilgisi (opsiyonel)
- `okul`: Okul bilgisi (opsiyonel)
- `ogretmenKodu`: Öğretmen kodu (unique, zorunlu)

### JSON Field Mapping:
- `_id` → `id`
- `ad_soyad` → `adSoyad`
- `ogretmen_kodu` → `ogretmenKodu`

### Kullanım:

```dart
// JSON'dan model oluşturma
final json = {
  '_id': '456',
  'ad_soyad': 'Mehmet Demir',
  'email': 'mehmet@example.com',
  'il': 'Ankara',
  'ilce': 'Çankaya',
  'okul': 'Atatürk İlkokulu',
  'ogretmen_kodu': 'TCH001'
};
final teacherModel = TeacherModel.fromJson(json);

// Model'den JSON'a çevirme
final jsonData = teacherModel.toJson();

// Entity'ye dönüştürme
final teacher = teacherModel.toEntity();

// Entity'den model oluşturma
final model = TeacherModel.fromEntity(teacher);
```

### Code Generation:

Model dosyalarını oluşturmak için:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```


