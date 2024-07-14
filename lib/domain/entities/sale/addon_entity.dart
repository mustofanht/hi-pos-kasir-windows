import 'package:jaya_propertiy/app/utils/common/logger_util.dart';

class AddonEntity {
  int? productId;
  String? productName;
  String? productType;
  int? productUnit;
  int? productLoc;
  double? productPrice;
  String? productDesc;
  String? productState;
  String? productImgPath;
  String? productFlMember;
  String? productFlWebsite;
  String? productFlTicket;

  AddonEntity({
    this.productId,
    this.productName,
    this.productType,
    this.productUnit,
    this.productLoc,
    this.productPrice,
    this.productDesc,
    this.productState,
    this.productImgPath,
    this.productFlMember,
    this.productFlWebsite,
    this.productFlTicket,
  });

  AddonEntity.fromJson(Map<String, dynamic> json) {
    try {
      productId = json['productId'];
      productName = json['productName'];
      productType = json['productType'];
      productUnit = json['productUnit'];
      productLoc = json['productLoc'];
      productPrice = json['productPrice'] != null
          ? (json['productPrice'] as num).toDouble()
          : null;
      productDesc = json['productDesc'];
      productState = json['productState'];
      productImgPath = json['productImgPath'];
      productFlMember = json['productFlMember'];
      productFlWebsite = json['productFlWebsite'];
      productFlTicket = json['productFlTicket'];
    } catch (e) {
      logger.safeLog('error $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "productId": productId,
      "productName": productName,
      "productType": productType,
      "productUnit": productUnit,
      "productLoc": productLoc,
      "productPrice": productPrice,
      "productDesc": productDesc,
      "productState": productState,
      "productImgPath": productImgPath,
      "productFlMember": productFlMember,
      "productFlWebsite": productFlWebsite,
      "productFlTicket": productFlTicket,
    };
  }
}
