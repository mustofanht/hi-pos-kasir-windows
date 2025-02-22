import 'package:jaya_propertiy/domain/entities/member/membership.dart';
import 'dart:convert';

class CartMemberModel {
  double? totalPrice;
  Membership? membership;
  CartMemberModel({this.totalPrice, this.membership});

  factory CartMemberModel.fromJson(Map<String, dynamic> json) {
    return CartMemberModel(
      totalPrice: json['totalPrice'],
      membership: Membership.fromJson(json['membership']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalPrice': totalPrice,
      'membership': membership?.toJson(),
    };
  }
}
