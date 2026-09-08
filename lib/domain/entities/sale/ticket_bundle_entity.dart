import 'package:jaya_propertiy/app/utils/common/logger_util.dart';

/// Satu aturan bundling tiket ↔ merchandise (syspos.mst_ticket_bundle).
///
/// Kasir memakainya untuk menampilkan & menagih merchandise yang menempel pada
/// sebuah tiket. Harga tetap dihitung ulang backend saat order disimpan; nilai
/// di sini hanya supaya kasir menampilkan total yang sama dengan yang ditagih.
class TicketBundleEntity {
  int? bundleId;
  int? bundleTicketId;
  String? bundleTicketName;
  int? bundleProductId;
  String? bundleProductName;
  double? bundleProductPrice;

  /// Jumlah merchandise per 1 tiket.
  int? bundleQty;

  /// MANDATORY = otomatis ikut; OPTIONAL = hanya bila dipilih customer.
  String? bundleType;

  /// FREE / DISCOUNTED / FIXED / NORMAL.
  String? bundlePriceType;

  /// Harga satuan setelah aturan bundling, dihitung backend.
  double? bundleEffectivePrice;

  String? bundleState;

  /// Saldo stok merchandise di lokasinya.
  double? bundleProductStock;

  /// 'Y' bila stok merchandise ini dipantau.
  String? bundleProductFlInventory;

  TicketBundleEntity({
    this.bundleId,
    this.bundleTicketId,
    this.bundleTicketName,
    this.bundleProductId,
    this.bundleProductName,
    this.bundleProductPrice,
    this.bundleQty,
    this.bundleType,
    this.bundlePriceType,
    this.bundleEffectivePrice,
    this.bundleState,
    this.bundleProductStock,
    this.bundleProductFlInventory,
  });

  bool get isMandatory => (bundleType ?? '').toUpperCase() == 'MANDATORY';

  /// Harga satuan yang ditagih ke customer.
  double get unitPrice => bundleEffectivePrice ?? 0;

  /// true bila stok merchandise ini dipantau backend. Saldo yang tidak terkirim
  /// dianggap "tidak dipantau" — lebih baik daripada menganggapnya nol dan
  /// memblokir penjualan tiket karena data yang tidak lengkap.
  bool get isInventoryTracked =>
      bundleProductFlInventory == 'Y' && bundleProductStock != null;

  /// Banyaknya tiket yang masih bisa dijual dengan bundling ini.
  /// null = stok tidak dipantau, jadi tidak membatasi.
  int? maxTicketByStock() {
    if (!isInventoryTracked) return null;
    final perTiket = bundleQty ?? 1;
    if (perTiket <= 0) return null;
    return ((bundleProductStock ?? 0) ~/ perTiket).toInt();
  }

  TicketBundleEntity.fromJson(Map<String, dynamic> json) {
    try {
      bundleId = json['bundleId'];
      bundleTicketId = json['bundleTicketId'];
      bundleTicketName = json['bundleTicketName'];
      bundleProductId = json['bundleProductId'];
      bundleProductName = json['bundleProductName'];
      bundleProductPrice = json['bundleProductPrice'] != null
          ? (json['bundleProductPrice'] as num).toDouble()
          : null;
      bundleQty = json['bundleQty'];
      bundleType = json['bundleType'];
      bundlePriceType = json['bundlePriceType'];
      bundleEffectivePrice = json['bundleEffectivePrice'] != null
          ? (json['bundleEffectivePrice'] as num).toDouble()
          : null;
      bundleState = json['bundleState'];
      bundleProductStock = json['bundleProductStock'] != null
          ? (json['bundleProductStock'] as num).toDouble()
          : null;
      bundleProductFlInventory = json['bundleProductFlInventory'];
    } catch (e) {
      logger.safeLog('error $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "bundleId": bundleId,
      "bundleTicketId": bundleTicketId,
      "bundleTicketName": bundleTicketName,
      "bundleProductId": bundleProductId,
      "bundleProductName": bundleProductName,
      "bundleProductPrice": bundleProductPrice,
      "bundleQty": bundleQty,
      "bundleType": bundleType,
      "bundlePriceType": bundlePriceType,
      "bundleEffectivePrice": bundleEffectivePrice,
      "bundleState": bundleState,
      "bundleProductStock": bundleProductStock,
      "bundleProductFlInventory": bundleProductFlInventory,
    };
  }
}
