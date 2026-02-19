# Student Model

Bu klasörde Öğrenci ile ilgili data modelleri bulunur.

## StudentModel

Öğrenci verilerini JSON formatında serialize/deserialize etmek için kullanılır.

### Özellikler:
- `id`: Öğrenci ID'si (opsiyonel)
- `adSoyad`: Ad Soyad (zorunlu)
- `email`: Email adresi (zorunlu)
- `sifre`: Şifre (opsiyonel, güvenlik için genelde gönderilmez)
- `il`: İl bilgisi (opsiyonel)
- `ilce`: İlçe bilgisi (opsiyonel)
- `bagliOgretmenler`: Bağlı öğretmen ID'leri listesi

### JSON Field Mapping:
- `_id` → `id`
- `ad_soyad` → `adSoyad`
- `bagli_ogretmenler` → `bagliOgretmenler`

### Kullanım:

```dart
// JSON'dan model oluşturma
final json = {
  '_id': '123',
  'ad_soyad': 'Ahmet Yılmaz',
  'email': 'ahmet@example.com',
  'il': 'İstanbul',
  'ilce': 'Kadıköy',
  'bagli_ogretmenler': ['teacher1', 'teacher2']
};
final studentModel = StudentModel.fromJson(json);

// Model'den JSON'a çevirme
final jsonData = studentModel.toJson();

// Entity'ye dönüştürme
final student = studentModel.toEntity();

// Entity'den model oluşturma
final model = StudentModel.fromEntity(student);
```

### Code Generation:

Model dosyalarını oluşturmak için:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

