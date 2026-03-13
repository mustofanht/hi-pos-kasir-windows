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
    };
  }
}
