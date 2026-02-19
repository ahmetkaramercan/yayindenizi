# Clean Architecture Yapısı

Bu proje Clean Architecture prensiplerine uygun olarak geliştirilmiştir.

## Katmanlar

### 1. Presentation Layer
- **Konum**: `features/*/presentation/`
- **Sorumluluklar**:
  - UI bileşenleri (Pages, Widgets)
  - State Management (Riverpod Providers)
  - User Input handling
  - UI State yönetimi

### 2. Domain Layer
- **Konum**: `features/*/domain/`
- **Sorumluluklar**:
  - Business Logic
  - Entities (Domain modelleri)
  - Use Cases (Business kuralları)
  - Repository Interfaces

### 3. Data Layer
- **Konum**: `features/*/data/`
- **Sorumluluklar**:
  - Data Models
  - Data Sources (Remote, Local)
  - Repository Implementations
  - API Client'lar

## Bağımlılık Yönü

```
Presentation → Domain ← Data
```

- Presentation katmanı sadece Domain katmanına bağımlıdır
- Data katmanı Domain katmanına bağımlıdır
- Domain katmanı hiçbir katmana bağımlı değildir (en içteki katman)

## Feature Modülleri

Her feature modülü kendi içinde bağımsız çalışır:

```
feature/
├── data/
│   ├── datasources/      # API, Local DB vb.
│   ├── models/           # Data modelleri
│   └── repositories/     # Repository implementasyonları
│
├── domain/
│   ├── entities/         # Domain modelleri
│   ├── repositories/     # Repository interface'leri
│   └── usecases/         # Business logic
│
└── presentation/
    ├── pages/            # Sayfa widget'ları
    ├── providers/        # Riverpod providers
    └── widgets/          # Feature'a özel widget'lar
```

## Core Modül

Tüm feature'lar tarafından kullanılan ortak bileşenler:

- **Theme**: Renkler, text stilleri, tema yapılandırması
- **Widgets**: Ortak widget'lar (Button, TextField, Card vb.)
- **Utils**: Yardımcı fonksiyonlar, extensions
- **Constants**: Sabitler
- **Errors**: Hata yönetimi
- **Routing**: Navigation yapılandırması
- **DI**: Dependency Injection

## State Management

Riverpod kullanılmaktadır. Provider'lar `presentation/providers/` klasöründe bulunur.

### Provider Tipleri:
- **StateProvider**: Basit state yönetimi
- **StateNotifierProvider**: Karmaşık state yönetimi
- **FutureProvider**: Async işlemler
- **StreamProvider**: Stream işlemleri

## Best Practices

1. **Separation of Concerns**: Her katman kendi sorumluluğuna odaklanır
2. **Dependency Inversion**: Domain katmanı interface'lere bağımlıdır
3. **Single Responsibility**: Her class/modül tek bir sorumluluğa sahiptir
4. **DRY Principle**: Tekrarlayan kod core modüle taşınır
5. **Testability**: Her katman bağımsız test edilebilir

