# Flutter POS System

## 📱 Deskripsi
Aplikasi Point of Sale (POS) yang dibangun menggunakan Flutter dengan arsitektur clean architecture. Sistem ini dirancang untuk mengelola penjualan tiket, member, voucher, dan transaksi.

## 🏗️ Arsitektur
Aplikasi ini menggunakan **Clean Architecture** dengan pemisahan layer:
- **Presentation Layer**: UI components, controllers, dan bindings
- **Domain Layer**: Business logic dan entities
- **Data Layer**: Models, services, dan resources

## 🚀 Fitur Utama

### 🛒 Sistema Penjualan
- Keranjang belanja interaktif
- Addon dan voucher
- Sistem deposit dan potongan
- Multiple payment methods

### 🖨️ Sistem Print
- Print tiket
- Konfigurasi printer

## 📋 Persyaratan Sistem

### Development Environment
- **Flutter SDK**: 3.10.6
- **Dart**: >=2.19.0 <4.0.0
- **Android Studio** atau **VS Code**
- **Git**

### Target Platform
- **Android**: API level 21+
- **iOS**: iOS 11.0+
- **Windows**: Windows 10+

## 🛠️ Instalasi

### 1. Clone Repository
```bash
git clone https://gitlab.com/jaya-property1/syspos-mobile
cd flutter-pos
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Konfigurasi Environment
```bash
Aplikasi sudah dikonfigurasi dengan multiple environment:

Local: http://192.168.18.195:8080/syspos-service/api/v1
Development: http://194.238.23.222:8080/syspos-service/api/v1
Production: http://103.150.92.131:8080/syspos-service/api/v1
Chatbot: https://chatbot.com/

# Set environment di networ_source.dart atau app configuration
final Environment environment = Environment.dev; // Ganti sesuai kebutuhan
```

### 4. Run Application
```bash
# Development mode
flutter run

# Release mode
flutter run --release
```

## 📁 Struktur Project

```
lib/
├── app/                    # Konfigurasi aplikasi
│   ├── main/              # Entry point dan routing
│   └── utils/             # Utilities dan konstanta
├── data/                  # Data layer
│   ├── models/            # Data models
│   ├── services/          # API services
│   └── resources/         # Network resources
├── domain/                # Domain layer
│   └── entities/          # Business entities
└── presentation/          # Presentation layer
    ├── bindings/          # Dependency injection
    ├── components/        # Reusable components
    ├── controllers/       # Business logic controllers
    └── views/             # UI screens
```

## 🔧 Konfigurasi

### Database Configuration
```dart
// lib/app/utils/constant/env_constant.dart
class EnvConstant {
  static const String baseUrl = 'your-api-base-url';
  static const String apiKey = 'your-api-key';
  static const String dbName = 'pos_database';
}
```

## 🚦 State Management
Aplikasi menggunakan **GetX** untuk:
- State management
- Dependency injection
- Route management

## 📱 Screens Overview

### Authentication
- **Login Page**: Autentikasi pengguna

### Main Modules
- **Sale Page**: Modul penjualan
- **Shift Management**: Manajemen shift kasir
- **Settings**: Konfigurasi aplikasi


## 📦 Build & Deploy

### Android APK
```bash
flutter build apk --release
```

### Android Bundle
```bash
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

**Made with ❤️ using Flutter**