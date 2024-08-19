import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/data/models/cart/cart_addon_model.dart';
import 'package:jaya_propertiy/data/models/cart/cart_ticket_mode.dart';
import 'package:jaya_propertiy/data/models/cart/cart_voucher_model.dart';

class CustomerSaleCart {
  List<CartTicket>? ticketList = [];
  List<CartVoucher>? voucherList = [];
  List<CartAddon>? addonList = [];
  double? totalOrder;
  double? paymentFee;

  CustomerSaleCart({
    this.ticketList,
    this.addonList,
    this.voucherList,
    this.totalOrder,
    this.paymentFee,
  });

  Map<String, dynamic> toJson() {
    return {
      'ticketList': ticketList?.map((e) => e.toJson()).toList(),
      'addonList': addonList?.map((e) => e.toJson()).toList(),
      'voucherList': voucherList?.map((e) => e.toJson2()).toList(),
      'totalOrder': totalOrder,
      'paymentFee': paymentFee,
    };
  }

  CustomerSaleCart.fromJson(Map<String, dynamic> json) {
    try {
      int indexTicket = 0;
      int indexVoucher = 0;
      int indexAddon = 0;
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
      for (var e in json['voucherList']) {
        if (e is Map<Object?, Object?>) {
          Map<String, dynamic> result = common.convertToMapStringDynamic(e);
          CartVoucher cartVoucher = CartVoucher.fromJson(result);
          voucherList?.insert(indexVoucher, cartVoucher);
          indexVoucher++;
        } else {
          voucherList?.add(CartVoucher.fromJson(e));
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
