import 'package:jaya_propertiy/app/utils/common/date_time_util.dart';
import 'package:jaya_propertiy/app/utils/common/generate_wristband_util.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/common/printer_util.dart';
import 'package:jaya_propertiy/app/utils/constant/date_format_constant.dart';
import 'package:jaya_propertiy/domain/entities/order/response_create_ticket_no_entity.dart';
import 'package:jaya_propertiy/presentation/components/custom_alert.dart';

/// Kategori lokasi tiket playground, sama dengan yang memicu input nama anak di
/// keranjang (`TicketEntity.ticketLocationCategory`).
const String kategoriPlayground = 'PLGRD';

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
  Future<HasilGelang> cetak(
    List<ResponseCreateTicketNoEntity> semua, {
    required Set<String> namaPlayground,
  }) async {
    final semuaKeStruk = HasilGelang(tercetak: const [], keStruk: semua);

    // Dipisah lebih dulu, bahkan saat printernya belum ada, supaya log bisa
    // membedakan "tidak ada tiket playground" dari "ada tapi printernya belum
    // diatur". Keduanya berakhir sama di kertas, tapi sebabnya jauh berbeda dan
    // itulah yang dicari saat menelusuri gelang yang tidak keluar.
    final (:gelang, :struk) = pisahkan(
      semua,
      namaPlayground,
      gelangPendamping: printerUtil.wristbandConfig.gelangPendamping,
    );

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
    for (final t in gelang) {
      bytes.addAll(generateWristbandUtil.dataWristbandPrint(
        config: config,
        qrCode: t.ticketNo!,
        ticketNo: t.ticketNo,
        berlakuSampai: _berlaku(t),
        // Penanda pendamping ikut dicetak supaya petugas gate bisa membedakan
        // gelang gratis dari gelang berbayar tanpa memindai satu per satu.
        pendamping: t.isCompanion == 'Y',
      ));
    }

    logger.safeLog('CETAK GELANG : ${gelang.length} gelang playground '
        '(${struk.length} tiket lain ke struk'
        '${printerUtil.wristbandConfig.gelangPendamping ? "" : ", pendamping dimatikan"}'
        '), ${bytes.length} byte');

    final hasil = await printerUtil.printWristband(bytes);
    if (hasil == HasilCetakGelang.terkirim ||
        hasil == HasilCetakGelang.simulasi) {
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
  /// [gelangPendamping] false membuang tiket pendamping dari cetak gelang —
  /// QR-nya tetap keluar di struk, jadi tidak ada tiket yang kehilangan QR.
  static ({
    List<ResponseCreateTicketNoEntity> gelang,
    List<ResponseCreateTicketNoEntity> struk,
  }) pisahkan(
    List<ResponseCreateTicketNoEntity> semua,
    Set<String> namaPlayground, {
    bool gelangPendamping = true,
  }) {
    final gelang = <ResponseCreateTicketNoEntity>[];
    final struk = <ResponseCreateTicketNoEntity>[];
    for (final t in semua) {
      final nomor = t.ticketNo;
      final layak = nomor != null &&
          nomor.trim().isNotEmpty &&
          namaPlayground.contains(namaDasar(t)) &&
          (gelangPendamping || t.isCompanion != 'Y');
      (layak ? gelang : struk).add(t);
    }
    return (gelang: gelang, struk: struk);
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

  /// Masa berlaku yang dicetak di gelang.
  ///
  /// Hanya **tanggal**, bukan jam. Untuk tiket berdurasi, argonya baru berjalan
  /// saat gelang dipindai di gate — jam berakhirnya belum ada saat gelang
  /// dicetak di kasir. Mencetak jam tebakan di sini akan berselisih dengan papan
  /// TV di gate, dan pelanggan akan memercayai yang tercetak.
  String? _berlaku(ResponseCreateTicketNoEntity t) {
    final tanggal = t.ticketActiveDate;
    if (tanggal == null) return null;
    return 's/d ${dateTimeUtil.getFormattedDate(
      date: tanggal.toLocal(),
      format: dateFormat.dateWithoutTime,
    )}';
  }
}

GelangUtil gelangUtil = GelangUtil();
