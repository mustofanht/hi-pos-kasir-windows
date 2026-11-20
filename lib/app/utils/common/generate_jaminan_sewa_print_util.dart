import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/app/utils/common/date_time_util.dart';
import 'package:jaya_propertiy/app/utils/common/kas_util.dart';
import 'package:jaya_propertiy/app/utils/common/kepala_struk_util.dart';
import 'package:jaya_propertiy/app/utils/constant/date_format_constant.dart';
import 'package:jaya_propertiy/domain/entities/jaminansewa/jaminan_sewa_entity.dart';

/// Isian yang kosong dicetak "-", bukan dibiarkan kosong — baris berlabel
/// hampa terbaca sebagai cetakan yang terpotong.
String _isi(String? nilai) {
  final bersih = (nilai ?? '').trim();
  return bersih.isEmpty ? '-' : bersih;
}

/// Struk jaminan sewa item (syspos V159): cash-in saat barang disewakan,
/// cash-out (pengembalian dana) saat barang kembali dalam kondisi baik.
class GenerateJaminanSewaPrintUtil {
  /// Struk CASH-IN, dicetak sesudah jaminan diterima.
  ///
  /// [uangDiterima]/[kembalian] murni lokal (tidak dikirim ke backend, sama
  /// seperti `OrderModel.kembalian` pada struk penjualan biasa) — hanya diisi
  /// untuk metode Tunai.
  Future<List<int>> dataTerimaJaminanPrint({
    String? locationName,
    String? locationAddress,
    String? locationPhone,
    required PaperSize paperSize,
    required JaminanSewaEntity data,
    double? uangDiterima,
    double? kembalian,
    /// true = buka laci kasir (jaminan diterima tunai).
    bool bukaLaci = false,
  }) async {
    List<int> bytes = [];
    if (bukaLaci) bytes += KasUtil.perintahBukaLaci;
    final profile = await CapabilityProfile.load();
    final generator = Generator(paperSize, profile);
    bytes += generator.setGlobalFont(PosFontType.fontA);
    bytes += generator.reset();

    bytes += KepalaStruk.cetak(
      generator,
      nama: locationName,
      alamat: locationAddress,
      telepon: locationPhone,
    );

    bytes += generator.text(
      'JAMINAN SEWA ITEM',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.hr();

    bytes += generator.text(
      'No. Jaminan : ${_isi(data.jmnNo)}',
      styles: const PosStyles(align: PosAlign.left, bold: true),
    );
    bytes += generator.text(
      'Kasir : ${_isi(data.createdBy)}',
      styles: const PosStyles(align: PosAlign.left),
    );
    bytes += generator.text(
      data.createdDate != null
          ? dateTimeUtil.getFormattedDate(
              date: data.createdDate!,
              format: dateFormat.fullTimePrinted,
            )
          : dateTimeUtil.now(format: dateFormat.fullTimePrinted),
      styles: const PosStyles(align: PosAlign.left),
    );
    bytes += generator.hr();

    bytes += generator.text(
      'Item   : ${_isi(data.itemName)}',
      styles: const PosStyles(align: PosAlign.left),
    );
    bytes += generator.text(
      'Qty    : ${(data.qty ?? 1).toStringAsFixed(0)}',
      styles: const PosStyles(align: PosAlign.left),
    );
    bytes += generator.text(
      'Metode : ${_isi(data.paymentName ?? 'TUNAI')}',
      styles: const PosStyles(align: PosAlign.left),
    );
    if ((data.paymentRefNo ?? '').trim().isNotEmpty) {
      bytes += generator.text(
        'No. Ref: ${data.paymentRefNo}',
        styles: const PosStyles(align: PosAlign.left),
      );
    }
    bytes += generator.text(
      'Nama   : ${_isi(data.customerName)}',
      styles: const PosStyles(align: PosAlign.left),
    );
    bytes += generator.text(
      'No HP  : ${_isi(data.customerPhone)}',
      styles: const PosStyles(align: PosAlign.left),
    );
    if ((data.notes ?? '').trim().isNotEmpty) {
      bytes += generator.text(
        'Catatan: ${data.notes}',
        styles: const PosStyles(align: PosAlign.left),
      );
    }
    bytes += generator.hr();

    bytes += generator.row([
      PosColumn(
        text: 'JUMLAH JAMINAN',
        width: 7,
        styles: const PosStyles(align: PosAlign.left, bold: true),
      ),
      PosColumn(
        text: common.currencyFormat(data.amount ?? 0),
        width: 5,
        styles: const PosStyles(align: PosAlign.right, bold: true),
      ),
    ]);
    if (uangDiterima != null) {
      bytes += generator.row([
        PosColumn(
          text: 'Uang Diterima',
          width: 7,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: common.currencyFormat(uangDiterima),
          width: 5,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
      bytes += generator.row([
        PosColumn(
          text: 'Kembalian',
          width: 7,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: common.currencyFormat(kembalian ?? 0),
          width: 5,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }
    bytes += generator.hr();

    bytes += generator.text(
      '>>> SIMPAN STRUK INI <<<',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.text(
      'Jaminan dikembalikan penuh saat',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      'barang dikembalikan dalam kondisi baik.',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      'Tunjukkan struk ini saat pengembalian.',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.cut();

    return bytes;
  }

  /// Struk CASH-OUT (pengembalian dana), dicetak sesudah jaminan dikembalikan.
  Future<List<int>> dataPengembalianJaminanPrint({
    String? locationName,
    String? locationAddress,
    String? locationPhone,
    required PaperSize paperSize,
    required JaminanSewaEntity data,
    /// true = buka laci kasir (pengembalian jaminan selalu tunai).
    bool bukaLaci = false,
  }) async {
    List<int> bytes = [];
    if (bukaLaci) bytes += KasUtil.perintahBukaLaci;
    final profile = await CapabilityProfile.load();
    final generator = Generator(paperSize, profile);
    bytes += generator.setGlobalFont(PosFontType.fontA);
    bytes += generator.reset();

    bytes += KepalaStruk.cetak(
      generator,
      nama: locationName,
      alamat: locationAddress,
      telepon: locationPhone,
    );

    bytes += generator.text(
      'PENGEMBALIAN JAMINAN SEWA',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.hr();

    bytes += generator.text(
      'Ref. Jaminan : ${_isi(data.jmnNo)}',
      styles: const PosStyles(align: PosAlign.left, bold: true),
    );
    bytes += generator.text(
      'Kasir : ${_isi(data.updatedBy)}',
      styles: const PosStyles(align: PosAlign.left),
    );
    bytes += generator.text(
      data.updatedDate != null
          ? dateTimeUtil.getFormattedDate(
              date: data.updatedDate!,
              format: dateFormat.fullTimePrinted,
            )
          : dateTimeUtil.now(format: dateFormat.fullTimePrinted),
      styles: const PosStyles(align: PosAlign.left),
    );
    bytes += generator.hr();

    bytes += generator.text(
      'Item   : ${_isi(data.itemName)}',
      styles: const PosStyles(align: PosAlign.left),
    );
    bytes += generator.text(
      'Qty    : ${(data.qty ?? 1).toStringAsFixed(0)}',
      styles: const PosStyles(align: PosAlign.left),
    );
    bytes += generator.text(
      'Nama   : ${_isi(data.customerName)}',
      styles: const PosStyles(align: PosAlign.left),
    );
    if ((data.refundNotes ?? '').trim().isNotEmpty) {
      bytes += generator.text(
        'Kondisi barang: ${data.refundNotes}',
        styles: const PosStyles(align: PosAlign.left),
      );
    }
    bytes += generator.hr();

    bytes += generator.row([
      PosColumn(
        text: 'DIKEMBALIKAN',
        width: 7,
        styles: const PosStyles(align: PosAlign.left, bold: true),
      ),
      PosColumn(
        text: common.currencyFormat(data.amount ?? 0),
        width: 5,
        styles: const PosStyles(align: PosAlign.right, bold: true),
      ),
    ]);
    bytes += generator.hr();

    bytes += generator.text(
      'TERIMA KASIH',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.cut();

    return bytes;
  }
}

final generateJaminanSewaPrintUtil = GenerateJaminanSewaPrintUtil();
