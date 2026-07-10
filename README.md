# Hi-POS Kasir

Aplikasi **Point of Sale (Kasir)** berbasis Flutter untuk lini produk Hi-POS.
Menangani transaksi penjualan, cetak tiket ber-QR melalui printer thermal,
tampilan layar pelanggan (secondary display), keanggotaan, shift kasir, serta
laporan penjualan.

## Fitur Utama

- **Autentikasi** — login kasir dengan JWT.
- **Penjualan (Sale)** — keranjang, pilih produk/tiket, hitung total, pembayaran,
  dan struk.
- **Cetak Tiket + QR** — tiap `ticketNo` dicetak sebagai QR via printer thermal
  (`esc_pos_utils_plus` + `thermal_printer`). Mendukung opsi pendamping
  (1 tiket → 2 QR).
- **Customer Display** — layar kedua menghadap pelanggan menggunakan
  `presentation_displays` (menampilkan item & total saat transaksi).
- **Member** — pencarian & pengelolaan keanggotaan pelanggan.
- **Shift Kasir** — buka/tutup shift.
- **Bukti Pembayaran (Proof of Payment)**.
- **Laporan & Grafik** — dashboard penjualan dengan `syncfusion_flutter_charts`
  dan `fl_chart`.
- **Pengaturan** — konfigurasi perangkat, printer, dan aplikasi.

## Arsitektur

Aplikasi memakai pola **GetX** (State Management + Dependency Injection + Routing):

```
lib/
├── app/
│   └── utils/
│       ├── styles/        # Tema & palet warna (color_style.dart, theme_style.dart)
│       ├── constant/      # Environment & konstanta (env_constant.dart)
│       └── common/        # Util cetak (generate_print_util.dart), dll
├── data/
│   └── services/          # Service API (mis. order_ticket_service.dart)
├── domain/
│   └── entities/          # Entity (mis. response_create_ticket_no_entity.dart)
└── presentation/
    ├── bindings/          # GetX bindings (injeksi controller)
    ├── components/        # Widget reusable
    ├── controllers/       # GetX controllers
    └── views/
        ├── auth/
        └── modules/       # sale, customer, member, shift, print_ticket,
                           # proofofpayment, setting, home
```

## Warna / Tema

Palet utama didefinisikan di `lib/app/utils/styles/color_style.dart`:

| Token        | Nilai                       |
|--------------|-----------------------------|
| `primary`    | `#612FF5` (ungu)            |
| `primaryDark`| `#3907CD`                   |
| `green`      | `#42AD43`                   |
| `red`        | `#CE2F21`                   |
| `yellow`     | `#FFC300`                   |

> Palet yang sama dipakai sebagai acuan warna aplikasi **Hi-Pos Swift (hi-pos-item)**.

## Teknologi

| Paket | Kegunaan |
|---|---|
| `get` | State management, DI, routing |
| `get_storage` | Penyimpanan lokal ringan |
| `google_fonts` | Tipografi |
| `esc_pos_utils_plus`, `thermal_printer` | Cetak struk & tiket thermal |
| `presentation_displays` | Layar kedua (customer display) |
| `syncfusion_flutter_charts`, `fl_chart` | Grafik laporan |
| `table_calendar` | Pemilihan tanggal/laporan |
| `flutter_svg`, `flutter_carousel_widget` | Aset & UI |
| `jwt_decoder` | Dekode token JWT |
| `device_info_plus` | Info perangkat |

## Konfigurasi API

Base URL diatur lewat `lib/app/utils/constant/env_constant.dart` (enum
`Environment`: `local`, `dev`, `production`, `chatbot`).

```dart
// contoh
Environment.dev.url; // https://dev.hi-pos.id/syspos-service/api/v1
```

## Menjalankan

### Prasyarat

- Flutter SDK (Dart `>=3.0.6 <4.0.0`)
- Android Studio / VS Code
- Perangkat Android dengan printer thermal (untuk fitur cetak)

### Langkah

```bash
flutter pub get
flutter run
```

### Build APK Release

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`.

## Catatan

- Plugin `presentation_displays` di-vendor secara lokal di `./plugin/presentation_displays`.
- `win32` di-*override* ke `5.5.4` agar kompatibel dengan Dart SDK terbaru
  (lihat `dependency_overrides` di `pubspec.yaml`).
