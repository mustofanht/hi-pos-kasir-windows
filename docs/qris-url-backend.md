# Panduan Backend — Format Field `qrisUrl` (QRIS)

**Untuk:** Tim Backend `syspos-service`
**Dari:** Tim Aplikasi Kasir (HI-POS)
**Perihal:** QR QRIS tidak tampil di aplikasi karena format `qrisUrl` tidak berupa URL gambar
**Tanggal:** 2026-07-09

---

## 1. Ringkasan Masalah

Saat memproses pembayaran **QRIS**, gambar QR **tidak tampil** di aplikasi kasir maupun di layar pelanggan (customer display).

Penyebabnya: response `createOrder` mengirim `qrisUrl` berupa **string mock/payload polos**, bukan URL gambar QR. Aplikasi kasir menampilkan QR dengan cara **memuat gambar dari URL** (`Image.network`) — aplikasi **tidak** meng-generate QR dari string. Jadi kalau `qrisUrl` bukan URL gambar, QR tidak bisa ditampilkan.

---

## 2. Bukti dari Log Aplikasi

Response `createOrder` yang diterima aplikasi (status `200`, "Save Successs"):

```json
{
  "data": {
    "orderNumber": "09072609ORD0005",
    "orderPaidBy": "QRIS",
    "orderPaymentNo": "09072609PV0005",
    "qrisUrl": "MOCK-QRIS:2026070967100000052"
  }
}
```

Nilai `qrisUrl` = `MOCK-QRIS:2026070967100000052` → **bukan URL gambar** → QR gagal ditampilkan.

---

## 3. Format yang Benar (sudah diverifikasi)

`qrisUrl` **harus berupa URL gambar penuh**. Contoh nilai yang benar:

```
https://sit-payer.paylabs.co.id/payer-api/qr?70f1c88a458baef72b64fa8104c7583eMOCK-QRIS%3A2026070967100000049
```

Hasil pemeriksaan header URL di atas (valid — mengembalikan gambar PNG):

```http
HTTP/1.1 200 OK
Content-Type: image/png
Content-Length: 6793
content-disposition: attachment; filename="qr.png"
```

---

## 3a. Bedakan: "Sandbox vs Produksi" ≠ "MOCK-QRIS vs URL Paylabs"

Ada **dua hal berbeda** yang sering tertukar. Keduanya **tidak berkaitan**.

### (i) Sandbox vs Produksi — soal pembayaran nyata

Saat ini Paylabs masih **sandbox / SIT (dev)**, jadi belum ada uang sungguhan yang berpindah. Ini **normal untuk tahap dev** dan **bukan bug**. QR sandbox tetap bisa discan/ditest lewat simulator Paylabs — hanya bukan transaksi uang asli. Ini akan otomatis menjadi pembayaran nyata saat naik ke environment produksi.

### (ii) `MOCK-QRIS:...` vs URL Paylabs — soal QR bisa tampil

Ini masalah yang **sebenarnya** dan **terpisah** dari poin (i). Perhatikan bahwa isi mock sebetulnya **sudah ada di dalam URL** yang benar:

```
https://sit-payer.paylabs.co.id/payer-api/qr?70f1c88a458baef72b64fa8104c7583eMOCK-QRIS%3A2026070967100000049
                                             └─────────── isi mock ada DI DALAM URL ───────────┘
```

| | Nilai | Bisa ditampilkan aplikasi? |
|---|---|---|
| **Yang dikembalikan Paylabs sandbox** | URL penuh `https://sit-payer.paylabs.co.id/...` → menghasilkan gambar PNG QR asli | ✅ Ya (via `Image.network`) |
| **Yang diterima aplikasi (dari log)** | Hanya potongan dalamnya: `MOCK-QRIS:2026070967100000052` | ❌ Bukan URL, bukan payload EMVCo valid |

**Kesimpulan:** masalahnya **bukan** karena Paylabs masih sandbox. Masalahnya, **backend `syspos-service` tidak meneruskan `qrisUrl` versi URL penuh** dari response Paylabs ke aplikasi — yang terkirim malah hanya potongan string `MOCK-QRIS:...`.

**Yang perlu dilakukan (berlaku untuk sandbox maupun produksi):** teruskan nilai `qrisUrl` dari response Paylabs **apa adanya** — URL penuh `https://sit-payer.paylabs.co.id/...` di sandbox (nanti domain produksi saat live). Dengan begitu QR langsung tampil **dan** bisa ditest scan di sandbox, tanpa perlu menunggu produksi.

---

## 4. Kontrak Field `qrisUrl`

Aplikasi kini menerima **salah satu** dari dua format berikut:

**Opsi A — URL gambar QR (disarankan bila provider menyediakan)**

| No | Persyaratan |
|----|-------------|
| A1 | Berupa **absolute URL** dengan skema `https://`. |
| A2 | URL **langsung mengembalikan file gambar** (`Content-Type: image/png` atau `image/*`) — **bukan** halaman HTML, JSON, atau redirect ke halaman login. |
| A3 | Dapat diakses **tanpa autentikasi / token / session** (device kasir memuatnya langsung sebagai gambar). |

**Opsi B — payload QRIS (string EMVCo)**

| No | Persyaratan |
|----|-------------|
| B1 | Berupa **string payload QRIS standar EMVCo** (mulai dari `00020101...`). Aplikasi akan menggambar QR-nya sendiri. |
| B2 | Harus payload **asli dan valid** agar bisa discan & dibayar — **bukan** placeholder seperti `MOCK-QRIS:...`. |

**Berlaku untuk kedua opsi**

| No | Persyaratan |
|----|-------------|
| 1 | Field yang dibaca aplikasi: **`data.qrisUrl`**. |
| 2 | Format **konsisten di semua environment** (DEV / SIT / mock / production). |
| 3 | **Jangan** mengirim nilai placeholder/mock (mis. `MOCK-QRIS:2026070967100000052`). Nilai ini bukan URL gambar dan bukan payload EMVCo yang valid, sehingga QR tidak bisa dibayar. |

> Deteksi format oleh aplikasi: bila nilai mengandung `http` → diperlakukan sebagai **URL gambar** (Opsi A); selain itu → diperlakukan sebagai **payload QRIS** dan digambar sebagai QR (Opsi B).

### Endpoint terkait

```
POST /syspos-service/api/v1/trn_order/createOrder
```

Berlaku untuk **order reguler** maupun **order member** — keduanya membaca `data.qrisUrl` dari response yang sama.

---

## 5. Contoh Response yang Diharapkan

```json
{
  "timestamp": "2026-07-09T13:37:01.460+07:00",
  "statusCode": 200,
  "message": "Save Successs",
  "data": {
    "orderNumber": "09072609ORD0005",
    "orderName": "muz",
    "orderTotalAmt": 30000.0,
    "orderPaidBy": "QRIS",
    "orderStatus": "N",
    "orderPaymentNo": "09072609PV0005",
    "qrisUrl": "https://sit-payer.paylabs.co.id/payer-api/qr?70f1c88a458baef72b64fa8104c7583eMOCK-QRIS%3A2026070967100000049"
  }
}
```

---

## 6. Cara Verifikasi Cepat (opsional, untuk backend)

Jalankan perintah berikut terhadap nilai `qrisUrl`. Harus mengembalikan `200 OK` dengan `Content-Type: image/*`:

```bash
curl -I "https://sit-payer.paylabs.co.id/payer-api/qr?70f1c88a458baef72b64fa8104c7583eMOCK-QRIS%3A2026070967100000049"
```

Jika `Content-Type` bukan `image/*`, atau statusnya redirect/`401`/`403`, aplikasi tidak akan bisa menampilkan QR.

---

## 7. Catatan Sisi Aplikasi (sudah diperbaiki)

Untuk mendukung format di atas, sisi aplikasi sudah diperbaiki:

- **Dukungan dua format** — aplikasi kini bisa menampilkan QR dari **URL gambar** (Opsi A) maupun **payload QRIS string** (Opsi B, digambar sendiri via `qr_flutter`).
- **Perbaikan penimpaan QR** — sebelumnya QR di customer display sempat hilang karena tertimpa update berikutnya; sekarang QR dipertahankan.
- **Penanganan nilai kosong** — bila `qrisUrl` kosong/null, aplikasi menampilkan pesan **"QR belum tersedia"** (bukan crash), sehingga mudah dikenali saat testing.

> **Penting:** meski aplikasi sudah bisa menggambar QR dari string apa pun, nilai **`MOCK-QRIS:...`** tetap **tidak dapat dibayar** karena bukan payload QRIS asli. Untuk transaksi nyata, backend tetap harus mengirim URL gambar valid (Opsi A) atau payload EMVCo asli (Opsi B).
