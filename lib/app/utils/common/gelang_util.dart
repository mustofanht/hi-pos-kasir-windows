import 'package:jaya_propertiy/app/utils/common/date_time_util.dart';
import 'package:jaya_propertiy/app/utils/common/generate_wristband_util.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/common/printer_util.dart';
import 'package:jaya_propertiy/app/utils/constant/date_format_constant.dart';
import 'package:jaya_propertiy/domain/entities/order/response_create_ticket_no_entity.dart';

/// Jembatan antara tiket yang baru dibuat dan printer gelang.
///
/// Dipisah dari alur penjualan karena dipakai dua kali dengan data yang sama:
/// saat pembayaran, dan saat cetak ulang dari menu Cek Order. Menyalinnya di dua
/// tempat berarti suatu saat yang satu diperbaiki dan yang lain tidak.
class GelangUtil {
  /// Mencetak satu gelang per tiket.
  ///
  /// Mengembalikan **false** bila printer gelang belum diatur atau cetaknya
  /// gagal — dan itu bukan kesalahan, melainkan jalur mundur yang disengaja:
  /// pemanggil lalu mencetak QR sebagai sambungan struk seperti sebelumnya.
  /// Outlet yang belum punya printer gelang harus tetap bisa menjual tiket.
  Future<bool> cetak(List<ResponseCreateTicketNoEntity> tiket) async {
    if (!printerUtil.punyaPrinterGelang) return false;

    final config = printerUtil.wristbandConfig;
    final bytes = <int>[];
    var jumlah = 0;

    for (final t in tiket) {
      final nomor = t.ticketNo;
      if (nomor == null || nomor.trim().isEmpty) continue;

      bytes.addAll(generateWristbandUtil.dataWristbandPrint(
        config: config,
        qrCode: nomor,
        ticketNo: nomor,
        berlakuSampai: _berlaku(t),
        // Penanda pendamping ikut dicetak supaya petugas gate bisa membedakan
        // gelang gratis dari gelang berbayar tanpa memindai satu per satu.
        pendamping: t.isCompanion == 'Y',
      ));
      jumlah++;
    }

    if (jumlah == 0) return false;

    logger.safeLog('CETAK GELANG : $jumlah gelang, ${bytes.length} byte');
    return printerUtil.printWristband(bytes);
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
