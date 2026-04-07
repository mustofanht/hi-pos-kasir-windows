# 🚀 Setup Guide - Jaya Property POS Mobile

Panduan lengkap untuk setup development environment project ini di Mac menggunakan FVM.

---

## 📋 Requirements yang Diperlukan

### Software Requirements
| Software | Version Required | Status |
|----------|-----------------|--------|
| Flutter (via FVM) | 3.10.6 | ✅ Sudah terinstall |
| Dart SDK | 3.0.6 | ✅ Included dengan Flutter |
| Java JDK | 11 atau 17 | ⚠️ Perlu install (saat ini: Java 23) |
| Android SDK | API 21-31 | Perlu verifikasi |
| FVM | Latest | ✅ Sudah terinstall (v3.2.1) |
| Xcode | Latest (untuk iOS) | Perlu verifikasi |
| CocoaPods | Latest | Perlu verifikasi |

---

## 🔴 CRITICAL: Install Java 11 atau 17

### Masalah:
- **Java Anda saat ini**: Java 23.0.2
- **Java yang diperlukan**: Java 11 atau Java 17
- **Alasan**: Android Gradle Plugin 7.3.0 tidak kompatibel dengan Java 23

### Solusi 1: Install Java 11 (Recommended)

```bash
# Install Java 11 menggunakan Homebrew
brew install openjdk@11

# Link Java 11 ke system
sudo ln -sfn /opt/homebrew/opt/openjdk@11/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-11.jdk

# Verify installation
/usr/libexec/java_home -V
```

### Solusi 2: Install Java 17 (Alternative)

```bash
# Install Java 17 menggunakan Homebrew
brew install openjdk@17

# Link Java 17 ke system
sudo ln -sfn /opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-17.jdk

# Verify installation
/usr/libexec/java_home -V
```

### Set Java Version untuk Project

Tambahkan ke file `~/.zshrc` atau `~/.bash_profile`:

```bash
# Untuk Java 11
export JAVA_HOME=$(/usr/libexec/java_home -v 11)

# ATAU untuk Java 17
export JAVA_HOME=$(/usr/libexec/java_home -v 17)

# Tambahkan ke PATH
export PATH=$JAVA_HOME/bin:$PATH
```

Reload shell:
```bash
source ~/.zshrc  # atau source ~/.bash_profile
```

Verifikasi:
```bash
java -version
# Harus menampilkan Java 11.x.x atau Java 17.x.x
```

---

## 📱 Step-by-Step Setup Project

### 1. Verifikasi FVM dan Flutter

```bash
# Cek FVM version
fvm --version

# Cek Flutter version yang digunakan project
fvm flutter --version

# Pastikan menggunakan Flutter 3.10.6
fvm list
```

### 2. Install Dependencies Flutter

```bash
# Navigate ke project directory
cd /Users/mac/Documents/vsCode/POS-JAYA/syspos-mobile

# Install dependencies menggunakan FVM
fvm flutter pub get
```

### 3. Verifikasi Android Setup

```bash
# Cek Android SDK installation
fvm flutter doctor -v

# Jika ada issue dengan Android SDK, install dengan:
# Android Studio > SDK Manager > Install:
# - Android SDK Platform 31
# - Android SDK Build-Tools 33.x.x
# - Android SDK Command-line Tools
```

### 4. Setup Android Licenses

```bash
# Accept all Android licenses
fvm flutter doctor --android-licenses
```

### 5. Clean dan Rebuild Project

```bash
# Clean project
fvm flutter clean

# Get dependencies lagi
fvm flutter pub get

# Generate files (jika diperlukan)
fvm flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 🔍 Verifikasi Setup

### Check Flutter Doctor

```bash
fvm flutter doctor -v
```

Output yang diharapkan:
```
✓ Flutter (Channel stable, 3.10.6, on macOS)
✓ Android toolchain - develop for Android devices
✓ Xcode - develop for iOS and macOS
✓ Chrome - develop for the web
✓ Android Studio
✓ VS Code
✓ Connected device
```

### Test Build Android

```bash
# Build Android APK
fvm flutter build apk --debug

# Atau run di emulator/device
fvm flutter run
```

---

## 🐛 Troubleshooting

### Issue: "Gradle build failed with exit code 1"

**Penyebab**: Java version tidak kompatibel

**Solusi**:
```bash
# Pastikan menggunakan Java 11 atau 17
java -version

# Set JAVA_HOME di terminal
export JAVA_HOME=$(/usr/libexec/java_home -v 11)

# Clean dan rebuild
fvm flutter clean
fvm flutter pub get
fvm flutter run
```

### Issue: "Flutter SDK not found"

**Solusi**:
```bash
# Pastikan FVM sudah disetup
fvm install 3.10.6
fvm use 3.10.6

# Atau global
fvm global 3.10.6
```

### Issue: "Execution failed for task ':app:checkDebugAarMetadata'"

**Solusi**:
```bash
cd android
./gradlew clean
cd ..
fvm flutter clean
fvm flutter pub get
```

### Issue: "CocoaPods not installed" (untuk iOS)

**Solusi**:
```bash
# Install CocoaPods
sudo gem install cocoapods

# Setup CocoaPods
cd ios
pod install
cd ..
```

---

## 📦 Dependencies Utama Project

### Core Dependencies
- **get**: State management (v4.6.5)
- **get_storage**: Local storage
- **syncfusion_flutter_charts**: Charts visualization
- **thermal_printer**: Printer support
- **image_picker**: Image selection
- **flutter_svg**: SVG support
- **jwt_decoder**: JWT authentication

### Plugin Lokal
- **presentation_displays**: Custom plugin di `./plugin/presentation_displays`

---

## 🌐 Environment Configuration

Project ini memiliki 3 environment:

1. **Local**: `http://192.168.18.195:8080/syspos-service/api/v1`
2. **Development**: `http://194.238.23.222:8080/syspos-service/api/v1`
3. **Production**: `http://103.150.92.131:8080/syspos-service/api/v1`

Konfigurasi di: `lib/app/utils/constant/env_constant.dart`

---

## 🚀 Running the Project

### Debug Mode
```bash
fvm flutter run
```

### Release Mode
```bash
fvm flutter run --release
```

### Build APK
```bash
fvm flutter build apk --release
```

### Build for specific flavor (jika ada)
```bash
fvm flutter run --debug -t lib/main.dart
```

---

## 📱 Device/Emulator Setup

### Android Emulator
```bash
# List available emulators
emulator -list-avds

# Start emulator
emulator -avd <emulator_name>

# Atau dari Android Studio
# Tools > Device Manager > Create Device
```

### iOS Simulator (Mac only)
```bash
# List available simulators
xcrun simctl list devices

# Open simulator
open -a Simulator
```

---

## 🔐 Additional Setup (Optional)

### VS Code Extensions (Recommended)
- Flutter
- Dart
- Flutter Widget Snippets
- Pubspec Assist
- Error Lens

### Android Studio Plugins
- Flutter
- Dart

---

## 📞 Support

Jika ada issue:
1. Cek Flutter Doctor: `fvm flutter doctor -v`
2. Cek Java version: `java -version` (harus 11 atau 17)
3. Clean project: `fvm flutter clean && fvm flutter pub get`
4. Restart IDE

---

## ✅ Quick Checklist

Sebelum mulai development:

- [ ] Java 11 atau 17 terinstall
- [ ] JAVA_HOME sudah diset dengan benar
- [ ] FVM Flutter 3.10.6 aktif
- [ ] `fvm flutter doctor` semua hijau
- [ ] Android licenses diterima
- [ ] Dependencies terinstall (`fvm flutter pub get`)
- [ ] Project bisa di-build (`fvm flutter build apk --debug`)
- [ ] Project bisa di-run (`fvm flutter run`)

---

**Last Updated**: April 6, 2026
**Flutter Version**: 3.10.6
**Required Java**: 11 or 17
