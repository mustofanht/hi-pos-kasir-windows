# HI-POS Kasir — Menjalankan & Build Versi Windows

Panduan ini khusus untuk **aplikasi kasir versi Windows (EXE)**. Sumber kode
terbaru selalu berasal dari **GitLab `hipos`, branch `enhance-hipos`**.

---

## 1. Peta repo & branch

| Remote   | URL                                                      | Fungsi |
|----------|----------------------------------------------------------|--------|
| `hipos`  | `gitlab.com/mobile-apps3722910/hi-pos-kasir.git`          | **Sumber kode utama.** Semua fitur baru masuk ke branch `enhance-hipos`. |
| `github` | `github.com/mustofanht/hi-pos-kasir-windows.git`          | **Mesin build.** Hanya dipakai menjalankan GitHub Actions (Windows runner). |
| `origin` | `gitlab.com/mobile-apps3722910/hi-pos-kasir-raumah.git`   | Varian lain, tidak dipakai untuk build Windows. |

Branch yang terlibat:

```
GitLab  hipos/enhance-hipos          <- kode terbaru (tanpa folder windows/)
                 |
                 |  rebase: 2 commit build ditumpuk di atasnya
                 v
GitHub  enhance-hipos-windows        <- branch build (kode + windows/ + CI)
                 |
                 v
        GitHub Actions "Build Windows EXE"
                 |
                 v
        HI-POS-Kasir-Setup-<env>.exe (artifact, 1 file installer)
```

`enhance-hipos-windows` = isi `enhance-hipos` **persis**, ditambah 2 commit:

1. `ci: build Windows EXE dari enhance-hipos` — folder `windows/` (runner C++,
   icon & nama "HI-POS Kasir") + workflow GitHub Actions.
2. `ci: hasilkan satu file installer HI-POS-Kasir-Setup.exe` — skrip Inno Setup
   + bundling runtime Visual C++.

> **Penting:** jangan menulis kode fitur di branch `enhance-hipos-windows`.
> Branch ini hanya "pembungkus build" dan akan di-rebase terus-menerus.
> Fitur tetap dikerjakan & di-push ke `enhance-hipos` di GitLab.

---

## 2. Alur rutin: ambil kode terbaru dari GitLab lalu build

Jalankan dari folder project (`D:\FLUTTER\POS-WINDOWS-GITHUB\hi-pos-kasir`):

```bash
# 1. Tarik commit terbaru dari GitLab
git fetch hipos

# 2. Pindah ke branch build
git checkout enhance-hipos-windows

# 3. Tumpuk ulang 2 commit build di atas kode terbaru
git rebase hipos/enhance-hipos

# 4. Kirim ke GitHub (memicu build otomatis)
git push github enhance-hipos-windows --force-with-lease
```

Kenapa `--force-with-lease`: rebase menulis ulang 2 commit build itu, jadi
riwayat branch berubah. `--force-with-lease` tetap menolak push kalau ada
perubahan lain di GitHub yang belum Anda ambil, jadi lebih aman dari `-f`.

**Kalau rebase konflik:** konflik hampir selalu terjadi di
`.github/workflows/build-windows.yml`, folder `windows/`, atau `README.md`
(file yang disentuh commit build). Yang dipertahankan adalah versi commit build
— kecuali `README.md`, yang perlu digabung manual supaya perubahan dari
`enhance-hipos` tidak hilang:

```bash
git checkout --theirs .github/workflows/build-windows.yml
git add .github/workflows/build-windows.yml
git rebase --continue
```

> Saat `git rebase`, istilahnya terbalik dari yang biasa dibayangkan:
> **`--theirs` = commit build milik kita** yang sedang ditumpuk, `--ours` =
> kode dari `enhance-hipos`. Kalau ragu, batalkan dengan `git rebase --abort`
> lalu ulangi.

Alternatif tanpa force-push (kalau rebase terasa merepotkan):
`git merge hipos/enhance-hipos` di branch build, lalu
`git push github enhance-hipos-windows`. Riwayat jadi lebih berantakan, hasil
build sama saja.

---

## 3. Menjalankan build di GitHub Actions

### 3a. Otomatis (setiap push)

Push ke `enhance-hipos-windows` langsung memicu workflow **Build Windows EXE**.
Build otomatis ini selalu memakai server **dev** (`dev.hi-pos.id`).

### 3b. Manual + pilih server (untuk installer produksi)

1. Buka <https://github.com/mustofanht/hi-pos-kasir-windows/actions>
2. Pilih workflow **Build Windows EXE** → tombol **Run workflow**
3. Branch: `enhance-hipos-windows`
4. **Target server aplikasi**: `production` (atau `dev` untuk uji coba)
5. Klik **Run workflow**, tunggu ±6–8 menit

### 3c. Mengambil hasilnya

Buka run yang sudah selesai → bagian **Artifacts** di bawah ringkasan:

| Artifact | Isi |
|----------|-----|
| `hipos-kasir-installer-production` | `HI-POS-Kasir-Setup-production.exe` |
| `hipos-kasir-installer-dev`        | `HI-POS-Kasir-Setup-dev.exe` |

GitHub selalu membungkus artifact dalam `.zip`, jadi hasil unduhan perlu
di-extract satu kali. Di dalamnya hanya ada satu file installer — tidak ada
folder atau file tambahan. Artifact tersimpan 90 hari.

---

## 4. Memasang di PC kasir

1. Salin `HI-POS-Kasir-Setup-production.exe` ke PC kasir, klik dua kali.
2. Windows SmartScreen akan memperingatkan ("Windows protected your PC") karena
   installer belum ditandatangani digital → **More info → Run anyway**.
   (Peringatan ini hanya hilang jika memakai sertifikat code-signing berbayar.)
3. Installer memasang ke `C:\Program Files\HI-POS Kasir`, membuat shortcut Start
   Menu, opsi shortcut Desktop, dan entri di **Apps & Features**.
4. **Update**: jalankan installer versi baru, instalasi lama otomatis ditimpa
   (AppId-nya sama). Tidak perlu uninstall dulu.

Catatan:

- Installer `dev` dan `production` memakai AppId & folder tujuan yang sama, jadi
  **tidak bisa terpasang berdampingan** di satu PC. Pakai PC/VM terpisah untuk
  uji coba dev.
- Runtime Visual C++ (`msvcp140.dll`, `vcruntime140.dll`, `vcruntime140_1.dll`)
  ikut dibundel, jadi PC yang belum pernah dipasangi VC++ Redistributable tetap
  bisa menjalankan aplikasi.

### Batasan versi Windows

| Fitur | Status di Windows |
|---|---|
| Cetak struk/tiket thermal | **Didukung** — `thermal_printer` punya implementasi Windows (USB & TCP/network). |
| Layar pelanggan (customer display) | **Tidak jalan** — plugin `presentation_displays` (vendor di folder `plugin/`) hanya punya implementasi Android. |
| Sisanya (penjualan, member, shift, laporan) | Berjalan normal. |

---

## 5. Menjalankan untuk development di Windows

### Prasyarat

| Kebutuhan | Keterangan |
|---|---|
| Flutter **3.24.5** (stable) | Versi yang sama dipakai CI. Cek dengan `flutter --version`. |
| Visual Studio 2022 | Workload **"Desktop development with C++"** beserta komponen default (MSVC v143 + Windows SDK). Visual Studio **Build Tools** saja juga cukup. |

> Tanpa Visual Studio, `flutter build windows` gagal dengan pesan *"Visual Studio
> not installed"* — inilah alasan build EXE dikerjakan di GitHub Actions. Cek
> kesiapan mesin dengan `flutter doctor -v`.

### Menjalankan

```bash
flutter pub get

# Server dev (default)
flutter run -d windows

# Server produksi
flutter run -d windows --dart-define=ENV=production
```

Server ditentukan oleh `--dart-define=ENV=<dev|production|local|chatbot>`; lihat
`lib/app/utils/constant/env_constant.dart`. Tanpa flag nilainya **`dev`**, jadi
`flutter run` biasa tidak akan pernah menyentuh server produksi.

### Build lokal (kalau Visual Studio sudah terpasang)

```bash
flutter build windows --release --dart-define=ENV=production
```

Output: `build\windows\x64\runner\Release\` — berisi `hi-pos-kasir.exe`,
beberapa DLL, dan folder `data\`. **Seluruh isi folder itu harus disalin
bersama-sama**; `hi-pos-kasir.exe` sendirian tidak bisa jalan.

Membungkusnya jadi installer satu file (butuh [Inno Setup 6](https://jrsoftware.org/isdl.php)):

```powershell
& "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" "/DSourceDir=D:\FLUTTER\POS-WINDOWS-GITHUB\hi-pos-kasir\build\windows\x64\runner\Release" "/DAppVersion=1.0.0" "/Obuild\installer" "windows\installer\hipos-kasir.iss"
```

Hasil: `build\installer\HI-POS-Kasir-Setup.exe`. Gunakan **path absolut** untuk
`SourceDir`, karena path relatif dihitung dari lokasi file `.iss`.

---

## 6. Isi pipeline build

File: `.github/workflows/build-windows.yml` (runner `windows-2022`).

| Step | Yang dikerjakan |
|---|---|
| Setup Flutter | Pasang Flutter 3.24.5 stable (dengan cache) |
| Enable Windows desktop | `flutter config --enable-windows-desktop` |
| Install dependencies | `flutter pub get` |
| Build Windows release | `flutter build windows --release --dart-define=ENV=$APP_ENV` |
| Bundel runtime Visual C++ | Salin `msvcp140*` / `vcruntime140*` dari folder VC Redist ke folder Release |
| Siapkan Inno Setup | Pakai Inno Setup bawaan runner; kalau tidak ada, `choco install innosetup` |
| Bangun installer | `ISCC` mengompilasi `windows/installer/hipos-kasir.iss` |
| Upload installer | Artifact `hipos-kasir-installer-<env>` |

File pendukung:

- `windows/installer/hipos-kasir.iss` — konfigurasi installer (nama, folder
  tujuan, shortcut, icon, AppId). **AppId jangan diubah**, karena itu yang
  membuat instalasi lama tertimpa rapi saat update.
- `windows/runner/` — kode runner C++ Flutter: judul jendela "HI-POS Kasir"
  (`main.cpp`), metadata versi (`Runner.rc`), nama EXE `hi-pos-kasir`
  (`windows/CMakeLists.txt`).
- `windows/runner/resources/app_icon.ico` — icon aplikasi & installer.

Nomor versi installer otomatis: `1.0.0.<nomor run Actions>`.

---

## 7. Troubleshooting

| Gejala | Penyebab & solusi |
|---|---|
| `flutter doctor` → "Visual Studio not installed" | Wajar di PC tanpa VS. Build lewat GitHub Actions, atau pasang VS 2022 + workload Desktop C++. |
| Build Actions gagal di step **Build Windows release** dengan error CMake menyebut nama plugin | Ada dependensi baru di `enhance-hipos` yang tidak mendukung Windows. Cek paket itu di pub.dev (tab *Platforms*); bungkus pemakaiannya dengan `if (Platform.isAndroid)` atau cari alternatif yang mendukung Windows. |
| Aplikasi jalan tapi data salah/kosong | Salah target server. Build otomatis (push) selalu `dev`; untuk PC kasir pakai run manual dengan `production`. |
| Aplikasi gagal start di PC kasir dengan error DLL | Kalau step "Bundel runtime Visual C++" sempat memberi warning, pasang manual [VC++ Redistributable x64](https://aka.ms/vs/17/release/vc_redist.x64.exe). |
| SmartScreen memblokir installer | Normal untuk installer tanpa tanda tangan → **More info → Run anyway**. |
| `git push` ditolak (`non-fast-forward`) | Anda baru rebase; pakai `git push github enhance-hipos-windows --force-with-lease`. |
| Artifact hilang dari halaman run | Artifact kedaluwarsa setelah 90 hari. Jalankan ulang workflow. |

---

## 8. Ringkasan perintah harian

```bash
# ambil kode terbaru dari GitLab & kirim ke mesin build
git fetch hipos
git checkout enhance-hipos-windows
git rebase hipos/enhance-hipos
git push github enhance-hipos-windows --force-with-lease

# lalu: Actions -> Build Windows EXE -> Run workflow -> env: production
# unduh artifact hipos-kasir-installer-production -> extract -> jalankan setup
```
