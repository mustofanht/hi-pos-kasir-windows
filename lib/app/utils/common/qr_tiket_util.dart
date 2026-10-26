import 'package:jaya_propertiy/domain/entities/order/response_create_ticket_no_entity.dart';
import 'package:jaya_propertiy/domain/entities/sale/ticket_entity.dart';

/// Penyaring tiket yang masih perlu dicetak.
///
/// Tiket yang disetup **Tanpa Scan** (Setup Tiket → Aktivasi di TV) tidak
/// pernah dipindai di gate maupun di papan TV, jadi QR-nya tidak ada gunanya —
/// baik sebagai kertas di struk maupun sebagai gelang. Kertasnya hanya
/// memanjangkan struk dan membuat pelanggan mengira ada yang harus
/// ditunjukkan, dan gelangnya hanya menghabiskan pita.
///
/// Penyaringan memakai **nama tiket**, bukan id, karena hanya nama itulah yang
/// dibawa balasan pembuatan tiket — cara yang sama dipakai alur ini untuk
/// memisahkan booking lapangan dan gelang playground.
class QrTiketUtil {
  /// Akhiran yang dibubuhkan server pada nama tiket pendamping.
  ///
  /// Tiket pendamping lahir dari tiket berbayarnya, jadi ikut nasib induknya:
  /// kalau induknya tanpa scan, pendampingnya pun tidak perlu QR. Tanpa
  /// memotong akhiran ini, pendampingnya tidak akan pernah cocok dengan
  /// katalog dan QR-nya tetap keluar sendirian di struk.
  static const String _akhiranPendamping = ' (Pendamping)';

  /// Bentuk nama yang bisa dibandingkan: tanpa spasi tepi, tanpa akhiran
  /// pendamping, dan tidak peduli besar-kecil huruf.
  static String kunciNama(String? nama) {
    var teks = (nama ?? '').trim();
    if (teks.toLowerCase().endsWith(_akhiranPendamping.toLowerCase())) {
      teks = teks.substring(0, teks.length - _akhiranPendamping.length).trim();
    }
    return teks.toUpperCase();
  }

  /// Nama tiket yang disetup Tanpa Scan, diambil dari keranjang.
  ///
  /// Keranjang dipakai karena di sanalah entitas tiketnya masih utuh; balasan
  /// pembuatan tiket hanya membawa nama.
  static Set<String> namaTanpaScan(Iterable<TicketEntity?> tiket) {
    final nama = <String>{};
    for (final t in tiket) {
      if (t == null || !t.tanpaScan) continue;
      final kunci = kunciNama(t.ticketName);
      if (kunci.isNotEmpty) nama.add(kunci);
    }
    return nama;
  }

  /// Tiket yang masih perlu dicetak — sebagai gelang maupun kertas QR.
  ///
  /// Daftar kosong berarti tidak ada yang perlu dicetak sama sekali — keadaan
  /// yang wajar bila seluruh isi order memang tanpa scan, dan harus bisa
  /// dibedakan dari "printer tidak ada" oleh pemanggilnya.
  static List<ResponseCreateTicketNoEntity> perluDicetak(
    List<ResponseCreateTicketNoEntity> tiket,
    Set<String> namaTanpaScan,
  ) {
    if (namaTanpaScan.isEmpty) return tiket;
    return tiket
        .where((e) => !namaTanpaScan.contains(kunciNama(e.ticketName)))
        .toList();
  }

  /// Apakah order dengan tiket bernama [namaTiketOrder] masih punya sesuatu
  /// untuk dicetak?
  ///
  /// Diperiksa dari **nama tiket pada order**, sebelum nomor tiketnya diminta
  /// ke server — jadi bisa dipakai lebih dulu, saat kasir baru menekan tombol.
  /// Itu gunanya: tanpa pemeriksaan ini kasir meminta izin, leader
  /// menyetujuinya, dan baru sesudah itu layar memberi tahu tidak ada yang bisa
  /// dicetak. Satu persetujuan terbuang untuk pekerjaan yang memang tidak ada,
  /// dan kasir mengulanginya karena menyangka izinnya yang gagal.
  ///
  /// Tiket **lapangan** selalu dihitung perlu dicetak: ia keluar sebagai struk
  /// penjualan (court + jam + harga), bukan QR, jadi penanda Tanpa Scan tidak
  /// meniadakannya.
  ///
  /// Sengaja **berpihak pada mencetak**. Daftar nama yang kosong, katalog
  /// tanpa-scan yang kosong (mis. gagal diambil dari server), atau nama yang
  /// tidak dikenali semuanya menghasilkan `true`. Pelanggan yang pulang tanpa
  /// QR jauh lebih mahal daripada satu kertas yang tidak perlu — dan keputusan
  /// terakhir tetap ada pada penyaring [perluDicetak] sesudah nomor tiketnya
  /// terbit.
  static bool adaYangPerluDicetak({
    required Iterable<String?> namaTiketOrder,
    required Set<String> namaTanpaScan,
    Iterable<String?> namaLapangan = const <String>[],
  }) {
    if (namaTanpaScan.isEmpty) return true;
    final daftar = namaTiketOrder
        .map(kunciNama)
        .where((n) => n.isNotEmpty)
        .toList();
    if (daftar.isEmpty) return true;
    final lapangan = namaLapangan
        .map(kunciNama)
        .where((n) => n.isNotEmpty)
        .toSet();
    return daftar
        .any((n) => lapangan.contains(n) || !namaTanpaScan.contains(n));
  }
}
