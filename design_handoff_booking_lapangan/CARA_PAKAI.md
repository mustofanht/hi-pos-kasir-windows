# Cara Menerapkan ke Claude Code

Paket ini berisi desain untuk fitur **Booking Lapangan** pada aplikasi kasir POS "Arena Sports Club". Ikuti langkah di bawah agar Claude Code bisa mengimplementasikannya ke dalam codebase aplikasi Anda yang sebenarnya.

## Langkah-langkah

1. **Salin folder ini** (`design_handoff_booking_lapangan/`) ke dalam root folder proyek/codebase aplikasi kasir Anda.

2. **Buka proyek itu di Claude Code** (jalankan `claude` di dalam folder proyek dari terminal).

3. **Tempel prompt di bawah ini** ke Claude Code:

---

```
Baca file design_handoff_booking_lapangan/README.md dan buka prototipe HTML
design_handoff_booking_lapangan/Booking Lapangan Multi Olahraga.dc.html di
browser untuk memahami desain dan interaksinya.

Lalu implementasikan fitur "Booking Lapangan" ini ke dalam codebase aplikasi
kasir yang sudah ada, dengan mengikuti aturan berikut:

- Pakai komponen, style, navigasi, dan struktur yang SUDAH ADA di codebase ini
  — jangan buat sistem baru dari nol. Prototipe HTML hanya referensi visual.
- Tambahkan sebagai sub-tab "Booking Lapangan" di layar Penjualan, di sebelah
  tab Ticket / Potongan / Item yang sudah ada.
- Flow: pilih lapangan (daftar chip satu baris yang bisa digeser horizontal) →
  pilih jam/durasi pada grid jadwal → ringkasan di panel Pesanan → Bayar →
  konfirmasi "Booking Berhasil".
- HANYA untuk pemesanan hari ini (tidak ada navigasi tanggal maju/mundur).
- Sebelum menulis kode, telusuri codebase dan jelaskan ke saya:
  1) di mana layar Penjualan / tab didefinisikan,
  2) komponen mana yang akan kamu pakai ulang,
  3) dari mana data lapangan & ketersediaan slot diambil (API/DB).
- Data lapangan, ketersediaan slot per jam, dan harga saat ini masih hardcode
  di prototipe — sambungkan ke sumber data asli di codebase.
- Setelah selesai, tunjukkan diff dan cara menjalankannya secara lokal.

Tanyakan ke saya jika ada yang belum jelas sebelum mulai menulis kode.
```

---

4. **Tinjau rencana Claude Code** sebelum menyetujui perubahan. Pastikan ia benar-benar memakai komponen yang sudah ada, bukan membuat UI baru yang terpisah.

## Isi paket

- `README.md` — spesifikasi desain lengkap (layout, state, interaksi, warna, token).
- `Booking Lapangan Multi Olahraga.dc.html` — prototipe HTML interaktif (bisa dibuka langsung di browser).
- `CARA_PAKAI.md` — file ini.

## Catatan penting untuk konteks

- Prototipe ini adalah **referensi desain**, bukan kode produksi untuk disalin mentah-mentah. Tugas Claude Code adalah membuat ulang desain ini memakai teknologi & komponen codebase Anda yang sebenarnya.
- Semua teks memakai Bahasa Indonesia, sesuaikan dengan gaya bahasa aplikasi yang ada.
- Harga saat ini flat Rp 100.000/jam untuk semua lapangan — konfirmasikan apakah nanti perlu harga berbeda per jenis olahraga / peak-hour.
