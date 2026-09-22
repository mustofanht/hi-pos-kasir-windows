import 'package:intl/intl.dart';
import 'package:jaya_propertiy/app/utils/common/generate_wristband_util.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/common/printer_util.dart';
import 'package:jaya_propertiy/domain/entities/order/response_create_ticket_no_entity.dart';
import 'package:jaya_propertiy/presentation/components/custom_alert.dart';

/// Akhiran yang dibubuhkan server pada nama tiket pendamping.
///
/// `TrnOrderService.createTicketNo` mengirim balik nama tiket pendamping sebagai
/// `"<nama tiket> (Pendamping)"`, bukan nama aslinya. Tanpa memotong akhiran ini
/// gelang pendamping tidak akan pernah cocok dengan katalog playground — yang
/// berbayar keluar sebagai gelang, yang pendamping tertinggal di kertas struk,
/// padahal keduanya dipakai anak yang sama masuk gate.
const String _akhiranPendamping = ' (Pendamping)';

/// Pembagian tiket setelah upaya cetak gelang: mana yang sudah keluar sebagai
/// gelang, dan mana yang masih harus dicetak QR-nya di kertas struk.
///
/// Dua daftar, bukan satu bool, karena satu order bisa memuat keduanya
/// sekaligus — dua tiket playground dan satu tiket kolam renang. Menjawabnya
/// dengan "sudah/belum" memaksa seluruh order ikut satu nasib, dan salah satu
/// kelompok pasti kehilangan QR-nya.
class HasilGelang {
  final List<ResponseCreateTicketNoEntity> tercetak;
  final List<ResponseCreateTicketNoEntity> keStruk;

  const HasilGelang({required this.tercetak, required this.keStruk});

  bool get adaGelang => tercetak.isNotEmpty;
}

/// Waktu pembelian di gelang: `2026-04-03 13:52:46`, sama dengan gelang cetak
/// outlet playground yang dijadikan contoh.
final DateFormat _formatWaktu = DateFormat('yyyy-MM-dd HH:mm:ss');

/// Jembatan antara tiket yang baru dibuat dan printer gelang.
///
/// Dipisah dari alur penjualan karena dipakai dua kali dengan data yang sama:
/// saat pembayaran, dan saat cetak ulang dari menu Cek Order. Menyalinnya di dua
/// tempat berarti suatu saat yang satu diperbaiki dan yang lain tidak.
class GelangUtil {
  /// Mencetak gelang untuk tiket **berkategori playground saja**.
  ///
  /// [namaPlayground] adalah nama-nama tiket yang lokasinya berkategori
  /// `PLGRD`. Penyaringan memakai nama karena itulah satu-satunya penanda yang
  /// dibawa balasan pembuatan tiket — sama seperti cara alur ini sudah memisah
  /// booking lapangan sebelumnya.
  ///
  /// Tiket di luar playground **tidak** dicetak sebagai gelang; QR-nya tetap
  /// keluar di kertas struk seperti sebelumnya. Begitu juga bila printer gelang
  /// belum diatur, atau bila cetaknya gagal — pelanggan tidak boleh pulang tanpa
  /// tiket karena satu perangkat ngadat.
  ///
  /// [lokasi] dan [waktu] dicetak di samping QR dan sama untuk setiap gelang
  /// dalam order ini; nomor tiket diambil dari tiketnya sendiri, jadi setiap
  /// gelang membawa nomor yang benar-benar dipindai gate — bukan nomor order
  /// yang sama untuk semua gelang. Baris di bawah lokasi berbeda per tiket —
  /// nama anak, atau `Pendamping (nama anak)`; lihat [barisNama]. [pembeli]
  /// hanya dipakai bila nama anak kosong. Semuanya boleh kosong; baris yang
  /// kosong tidak dicetak.
  Future<HasilGelang> cetak(
    List<ResponseCreateTicketNoEntity> semua, {
    required Set<String> namaPlayground,
    String? lokasi,
    String? pembeli,
    DateTime? waktu,
  }) async {
    final semuaKeStruk = HasilGelang(tercetak: const [], keStruk: semua);

    // Satu baris per tiket, sebelum apa pun diputuskan.
    //
    // Ditambahkan setelah dua gelang keluar dari order yang seharusnya
    // menghasilkan satu. Tanpa catatan ini, "gelang kedua" bisa berarti tiga hal
    // yang berbeda — tiket pendamping yang lolos saringan, cetakan yang terbelah
    // media, atau gelang kosong yang terdorong keluar printer — dan ketiganya
    // terlihat sama di tangan.
    logger.safeLog('CETAK GELANG katalog playground='
        '${namaPlayground.length} nama, tiket=${semua.length}');
    for (final t in semua) {
      logger.safeLog('  tiket ${t.ticketNo} nama="${t.ticketName}" '
          'dasar="${namaDasar(t)}" pendamping=${t.isCompanion} '
          'playground=${namaPlayground.contains(namaDasar(t))}');
    }

    // Dipisah lebih dulu, bahkan saat printernya belum ada, supaya log bisa
    // membedakan "tidak ada tiket playground" dari "ada tapi printernya belum
    // diatur". Keduanya berakhir sama di kertas, tapi sebabnya jauh berbeda dan
    // itulah yang dicari saat menelusuri gelang yang tidak keluar.
    final (:gelang, :struk) = pisahkan(semua, namaPlayground);

    logger.safeLog('CETAK GELANG keputusan: '
        'gelang=[${gelang.map((e) => e.ticketNo).join(", ")}] '
        'struk=[${struk.map((e) => e.ticketNo).join(", ")}]');

    if (gelang.isEmpty) {
      logger.safeLog('CETAK GELANG : tidak ada tiket playground di order ini '
          '(${semua.length} tiket, katalog playground ${namaPlayground.length} nama)');
      return semuaKeStruk;
    }

    if (!printerUtil.punyaPrinterGelang) {
      logger.safeLog('CETAK GELANG : ${gelang.length} tiket playground, tapi '
          'printer gelang BELUM DIATUR -> QR dicetak di struk');
      return semuaKeStruk;
    }

    final config = printerUtil.wristbandConfig;
    final bytes = <int>[];
    // Dipasangkan dari seluruh tiket order, bukan hanya yang jadi gelang:
    // pendamping butuh nama anaknya, dan tiket anak itulah yang menyimpannya.
    final namaGelang = barisNama(semua, pembeli: pembeli);
    // Dicetak urut nomor tiket, jadi setiap gelang anak langsung diikuti gelang
    // pendampingnya — tidak perlu dicocokkan lagi saat dibagikan di kasir.
    final urutCetak = [...gelang]..sort(_urutNomor);
    for (final t in urutCetak) {
      logger.safeLog('  gelang ${t.ticketNo} nama="${namaGelang[t.ticketNo] ?? ""}"');
      bytes.addAll(generateWristbandUtil.dataGelangPlayground(
        config: config,
        qrCode: t.ticketNo!,
        lokasi: lokasi,
        nama: namaGelang[t.ticketNo],
        nomorTiket: t.ticketNo,
        waktu: waktu == null ? null : _formatWaktu.format(waktu.toLocal()),
      ));
    }

    logger.safeLog('CETAK GELANG : ${gelang.length} gelang playground '
        '(${struk.length} tiket lain ke struk'
        '), ${bytes.length} byte, ${bytes.where((b) => b == 0x0A).length} baris');

    final hasil = await printerUtil.printWristband(bytes);
    if (hasil == HasilCetakGelang.terkirim) {
      return HasilGelang(tercetak: gelang, keStruk: struk);
    }

    alert.error('Cetak Gelang Gagal',
        'QR playground dicetak di struk sebagai gantinya. Periksa printer gelang.');
    return semuaKeStruk;
  }

  /// Memisahkan tiket yang layak jadi gelang dari yang tetap ke kertas struk.
  ///
  /// Dipisah dari [cetak] supaya aturannya bisa diuji tanpa printer — inilah
  /// bagian yang menentukan pelanggan mana yang dapat gelang, dan salah di sini
  /// tidak terlihat sampai ada yang berdiri di gate tanpa QR.
  ///
  /// Tiket tanpa nomor ikut ke struk, bukan dibuang: nomor kosong berarti ada
  /// yang salah di hulu, dan menghilangkannya diam-diam hanya menyembunyikannya.
  ///
  /// Tiket pendamping selalu ikut dicetak sebagai gelang. Dulu ada saklar di
  /// kasir untuk mematikannya; sekarang jatah gelang diatur lewat setup tiket
  /// (bundling barang "Gelang" di back office), jadi keputusan itu tidak lagi
  /// dibuat per perangkat.
  static ({
    List<ResponseCreateTicketNoEntity> gelang,
    List<ResponseCreateTicketNoEntity> struk,
  }) pisahkan(
    List<ResponseCreateTicketNoEntity> semua,
    Set<String> namaPlayground,
  ) {
    final gelang = <ResponseCreateTicketNoEntity>[];
    final struk = <ResponseCreateTicketNoEntity>[];
    for (final t in semua) {
      final nomor = t.ticketNo;
      final layak = nomor != null &&
          nomor.trim().isNotEmpty &&
          namaPlayground.contains(namaDasar(t));
      (layak ? gelang : struk).add(t);
    }
    return (gelang: gelang, struk: struk);
  }

  /// Panjang nama anak di dalam `Pendamping (...)`. Baris gelang dipotong di 32
  /// karakter; tanpa batas ini, nama yang panjang memotong kurung penutupnya.
  static const int _namaAnakMaks = 19;

  /// Baris di bawah nama lokasi untuk setiap tiket, dikunci nomor tiket.
  ///
  /// - Tiket anak: nama anaknya. Kosong bila kasir tidak mengisinya — server
  ///   memang membiarkannya kosong untuk order satu tiket — dan saat itu
  ///   dipakai nama pemesan [pembeli], sama seperti papan TV playground.
  /// - Tiket pendamping: `Pendamping (nama anak)`, atau `Pendamping` saja bila
  ///   anaknya tidak bernama.
  ///
  /// Server tidak menyimpan hubungan pendamping ke anaknya; kolom
  /// `otdtl_child_name` pendamping selalu berisi "Pendamping". Yang pasti hanya
  /// urutan pembuatannya: di dalam satu transaksi, pendamping dibuat tepat
  /// setelah tiket anaknya dengan tiket yang sama, sehingga nomornya tepat
  /// sesudah nomor anak. Karena itu tiket **diurutkan menurut nomor** lebih
  /// dulu, dan setiap pendamping dipasangkan dengan tiket anak terdekat
  /// sebelumnya yang bernama dasar sama.
  ///
  /// Urutan balasan server sendiri tidak dipakai: pada cetak ulang, server
  /// membaca tiket tanpa `ORDER BY` sambil memperbarui statusnya, dan urutan
  /// baris Postgres setelah pembaruan tidak dijamin.
  static Map<String, String?> barisNama(
    List<ResponseCreateTicketNoEntity> tiket, {
    String? pembeli,
  }) {
    String? bersih(String? s) =>
        s == null || s.trim().isEmpty ? null : s.trim();

    final hasil = <String, String?>{};
    final anakTerakhir = <String, String?>{};
    for (final t in [...tiket]..sort(_urutNomor)) {
      final nomor = t.ticketNo;
      if (nomor == null) continue;
      if (t.isCompanion == 'Y') {
        var anak = anakTerakhir[namaDasar(t)];
        if (anak != null && anak.length > _namaAnakMaks) {
          anak = anak.substring(0, _namaAnakMaks).trimRight();
        }
        hasil[nomor] = anak == null ? 'Pendamping' : 'Pendamping ($anak)';
      } else {
        final anak = bersih(t.childName) ?? bersih(pembeli);
        anakTerakhir[namaDasar(t)] = anak;
        hasil[nomor] = anak;
      }
    }
    return hasil;
  }

  /// Nomor tiket berpanjang sama dan urut waktu pembuatan di dalam satu order,
  /// jadi cukup dibandingkan sebagai teks — panjangnya lebih dulu, berjaga bila
  /// formatnya kelak bertambah digit.
  static int _urutNomor(
      ResponseCreateTicketNoEntity a, ResponseCreateTicketNoEntity b) {
    final x = a.ticketNo ?? '';
    final y = b.ticketNo ?? '';
    return x.length != y.length ? x.length.compareTo(y.length) : x.compareTo(y);
  }

  /// Nama tiket seperti yang ada di katalog, tanpa hiasan yang ditambahkan
  /// server. Lihat [_akhiranPendamping].
  static String namaDasar(ResponseCreateTicketNoEntity t) {
    final nama = t.ticketName ?? '';
    if (t.isCompanion == 'Y' && nama.endsWith(_akhiranPendamping)) {
      return nama.substring(0, nama.length - _akhiranPendamping.length);
    }
    return nama;
  }
}

GelangUtil gelangUtil = GelangUtil();
