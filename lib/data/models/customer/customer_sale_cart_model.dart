import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/data/models/cart/cart_addon_model.dart';
import 'package:jaya_propertiy/data/models/cart/cart_ticket_mode.dart';
import 'package:jaya_propertiy/data/models/cart/cart_potongan_model.dart';
import 'package:jaya_propertiy/domain/entities/member/membership.dart';

class CustomerSaleCart {
  List<CartTicket>? ticketList = [];
  List<CartPotongan>? potonganList = [];
  List<CartAddon>? addonList = [];
  List<Membership>? memberList = [];
  double? totalOrder;
  double? paymentFee;

  CustomerSaleCart({
    this.ticketList,
    this.addonList,
    this.potonganList,
    this.memberList,
    this.totalOrder,
    this.paymentFee,
  });

  Map<String, dynamic> toJson() {
    return {
      'ticketList': ticketList?.map((e) => e.toJson()).toList(),
      'addonList': addonList?.map((e) => e.toJson()).toList(),
      'potonganList': potonganList?.map((e) => e.toJson2()).toList(),
      'memberList': memberList?.map((e) => e.toJson()).toList(),
      'totalOrder': totalOrder,
      'paymentFee': paymentFee,
    };
  }

  CustomerSaleCart.fromJson(Map<String, dynamic> json) {
    try {
      int indexTicket = 0;
      int indexVoucher = 0;
      int indexAddon = 0;
      int indexMember = 0;
      for (var e in json['ticketList']) {
        if (e is Map<Object?, Object?>) {
          Map<String, dynamic> result = common.convertToMapStringDynamic(e);
          CartTicket cartTicket = CartTicket.fromJson(result);
          ticketList?.insert(indexTicket, cartTicket);
          indexTicket++;
        } else {
          ticketList?.add(CartTicket.fromJson(e));
        }
      }
      for (var e in json['addonList']) {
        if (e is Map<Object?, Object?>) {
          Map<String, dynamic> result = common.convertToMapStringDynamic(e);
          CartAddon cartAddon = CartAddon.fromJson(result);
          addonList?.insert(indexAddon, cartAddon);
          indexAddon++;
        } else {
          addonList?.add(CartAddon.fromJson(e));
        }
      }
      for (var e in json['potonganList']) {
        if (e is Map<Object?, Object?>) {
          Map<String, dynamic> result = common.convertToMapStringDynamic(e);
          CartPotongan cartPotongan = CartPotongan.fromJson(result);
          potonganList?.insert(indexVoucher, cartPotongan);
          indexVoucher++;
        } else {
          potonganList?.add(CartPotongan.fromJson(e));
        }
      }
      for (var e in json['memberList']) {
        if (e is Map<Object?, Object?>) {
          Map<String, dynamic> result = common.convertToMapStringDynamic(e);
          Membership membership = Membership.fromJson(result);
          memberList?.insert(indexMember, membership);
          indexMember++;
        } else {
          memberList?.add(Membership.fromJson(e));
        }
      }
      totalOrder = json['totalOrder'] != null
          ? (json['totalOrder'] as num).toDouble()
          : null;
      paymentFee = json['paymentFee'] != null
          ? (json['paymentFee'] as num).toDouble()
          : null;
    } catch (e) {
      logger.safeLog('Error $e');
    }
  }
}
