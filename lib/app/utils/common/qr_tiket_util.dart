import 'package:jaya_propertiy/domain/entities/order/response_create_ticket_no_entity.dart';
import 'package:jaya_propertiy/domain/entities/sale/ticket_entity.dart';

/// Penyaring tiket yang QR-nya perlu dicetak.
///
/// Tiket yang disetup **Tanpa Scan** (Setup Tiket → Aktivasi di TV) tidak
/// pernah dipindai di gate maupun di papan TV, jadi QR-nya tidak ada gunanya:
/// kertasnya hanya memanjangkan struk dan membuat pelanggan mengira ada yang
/// harus ditunjukkan.
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

  /// Tiket yang QR-nya masih perlu dicetak.
  ///
  /// Daftar kosong berarti tidak ada yang perlu dicetak sama sekali — keadaan
  /// yang wajar bila seluruh isi order memang tanpa scan, dan harus bisa
  /// dibedakan dari "printer tidak ada" oleh pemanggilnya.
  static List<ResponseCreateTicketNoEntity> perluQr(
    List<ResponseCreateTicketNoEntity> tiket,
    Set<String> namaTanpaScan,
  ) {
    if (namaTanpaScan.isEmpty) return tiket;
    return tiket
        .where((e) => !namaTanpaScan.contains(kunciNama(e.ticketName)))
        .toList();
  }
}
