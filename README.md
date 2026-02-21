# Yayın Denizi

Flutter ile geliştirilmiş, Clean Architecture prensiplerine uygun mobil uygulama projesi.

## Özellikler

- ✅ Clean Architecture yapısı
- ✅ Riverpod state management
- ✅ Modüler ve ölçeklenebilir yapı
- ✅ Öğrenci ve Öğretmen panelleri
- ✅ Takip ve analiz odaklı
- ✅ iOS ve Android uyumlu

## Proje Yapısı

```
lib/
├── core/                    # Çekirdek modüller
│   ├── constants/          # Sabitler
│   ├── di/                  # Dependency Injection
│   ├── errors/              # Hata yönetimi
│   ├── routing/             # Routing yapılandırması
│   ├── theme/               # Tema ve renkler
│   ├── utils/               # Yardımcı fonksiyonlar
│   └── widgets/             # Ortak widget'lar
│
└── features/                # Feature modülleri
    ├── student/             # Öğrenci modülü
    │   ├── data/            # Data katmanı
    │   ├── domain/          # Domain katmanı
    │   └── presentation/    # Presentation katmanı
    │
    └── teacher/             # Öğretmen modülü
        ├── data/            # Data katmanı
        ├── domain/          # Domain katmanı
        └── presentation/    # Presentation katmanı
```

## Renk Paleti

- **Ana Renk**: Koyu Lacivert (#1A237E)
- **İkincil Renk**: Beyaz (#FFFFFF)
- **Vurgu Rengi**: Kırmızı (#D32F2F)

## Kurulum

1. Flutter SDK'nın kurulu olduğundan emin olun (Flutter 3.0+)
2. Bağımlılıkları yükleyin:
   ```bash
   flutter pub get
   ```
3. Code generation için (gerekirse):
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

## Çalıştırma

```bash
# Android
flutter run

# iOS
flutter run -d ios

# Belirli bir cihaz için
flutter devices
flutter run -d <device_id>
```

## Geliştirme

### Clean Architecture Katmanları

1. **Presentation Layer**: UI, Widgets, State Management (Riverpod)
2. **Domain Layer**: Entities, Use Cases, Repository Interfaces
3. **Data Layer**: Models, Data Sources, Repository Implementations

### State Management

Proje Riverpod kullanmaktadır. Provider'lar `features/*/presentation/providers/` klasöründe bulunur.

### Ortak Widget'lar

Ortak widget'lar `core/widgets/` klasöründe bulunur:
- `AppButton`: Çok amaçlı buton widget'ı
- `AppTextField`: Özelleştirilebilir metin giriş alanı
- `AppCard`: Standart kart widget'ı
- `AppLoading`: Yükleme göstergesi
- `AppEmptyState`: Boş durum gösterimi
- `AppErrorWidget`: Hata gösterimi

## Lisans

Bu proje özel bir projedir.

