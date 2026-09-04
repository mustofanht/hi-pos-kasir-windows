import 'package:jaya_propertiy/app/utils/common/logger_util.dart';

class AddonEntity {
  int? productId;
  String? productName;
  String? productType;
  double? productPrice;
  int? productLoc;
  String? productLocName;
  String? productState;
  String? pathImg;
  int? minRentPrd;
  String? isBooked;
  String? productRentType;
  DateTime? startDate;
  DateTime? endDate;
  DateTime? closeDate;

  /// Daftar SEMUA booking terjadwal hari ini yang belum mulai, sudah dirangkai
  /// backend dalam WIB, mis. "15:00-16:00, 19:00-20:00" (okupansi terbuka =
  /// "Mulai HH:mm"). Dipakai badge "Sudah Dibooking". Item TIDAK terkunci —
  /// tetap bisa disewakan untuk jam kosong lain. null/kosong = tidak ada booking.
  String? upcomingBookingsText;

  /// Inventory (V86). 'Y' = stok produk ini di-track backend; produk lain
  /// (sewa, tiket) tetap unlimited dan keempat field di bawah bernilai null.
  String? productFlInventory;

  /// Sisa stok di lokasi produk. null = produk tidak di-track stok.
  double? stockAvailable;

  /// Ambang batas peringatan stok menipis.
  double? stockMinStock;

  /// Satuan stok (pcs, box, ...).
  String? stockUom;

  /// NORMAL / LOW_STOCK / OUT_OF_STOCK; null bila produk tidak di-track stok.
  String? stockStatus;

  /// true bila stok produk ini di-track backend.
  bool get isInventoryTracked => productFlInventory == 'Y' && stockAvailable != null;

  /// true bila stok habis — kasir tidak boleh menambahkannya ke keranjang.
  bool get isOutOfStock => isInventoryTracked && (stockAvailable ?? 0) <= 0;

  /// true bila stok sudah di bawah/ sama dengan batas minimum (masih bisa dijual).
  bool get isLowStock =>
      isInventoryTracked &&
      !isOutOfStock &&
      (stockAvailable ?? 0) <= (stockMinStock ?? 0);

  AddonEntity({
    this.productId,
    this.productName,
    this.productType,
    this.productPrice,
    this.productLoc,
    this.productLocName,
    this.productState,
    this.pathImg,
    this.minRentPrd,
    this.isBooked,
    this.productRentType,
    this.startDate,
    this.endDate,
    this.closeDate,
    this.upcomingBookingsText,
    this.productFlInventory,
    this.stockAvailable,
    this.stockMinStock,
    this.stockUom,
    this.stockStatus,
  });

  AddonEntity.fromJson(Map<String, dynamic> json) {
    try {
      productId = json['productId'];
      productName = json['productName'];
      productType = json['productType'];
      productPrice = json['productPrice'] != null
          ? (json['productPrice'] as num).toDouble()
          : null;
      productLoc = json['productLoc'];
      productLocName = json['productLocName'];
      productState = json['productState'];
      pathImg = json['pathImg'];
      minRentPrd = json['minRentPrd'];
      isBooked = json['isBooked'];
      productRentType = json['productRentType'];
      startDate = json['startDate'] != null
          ? DateTime.parse(json['startDate']).toLocal()
          : null;
      endDate = json['endDate'] != null
          ? DateTime.parse(json['endDate']).toLocal()
          : null;
      closeDate = json['closeDate'] != null
          ? DateTime.parse(json['closeDate']).toLocal()
          : null;
      upcomingBookingsText = json['upcomingBookingsText'];
      productFlInventory = json['productFlInventory'];
      stockAvailable = json['stockAvailable'] != null
          ? (json['stockAvailable'] as num).toDouble()
          : null;
      stockMinStock = json['stockMinStock'] != null
          ? (json['stockMinStock'] as num).toDouble()
          : null;
      stockUom = json['stockUom'];
      stockStatus = json['stockStatus'];
    } catch (e) {
      logger.safeLog('error $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'productType': productType,
      'productPrice': productPrice,
      'productLoc': productLoc,
      'productLocName': productLocName,
      'productState': productState,
      'pathImg': pathImg,
      'minRentPrd': minRentPrd,
      'isBooked': isBooked,
      'productRentType': productRentType,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'closeDate': closeDate?.toIso8601String(),
      'upcomingBookingsText': upcomingBookingsText,
      'productFlInventory': productFlInventory,
      'stockAvailable': stockAvailable,
      'stockMinStock': stockMinStock,
      'stockUom': stockUom,
      'stockStatus': stockStatus,
    };
  }
}
