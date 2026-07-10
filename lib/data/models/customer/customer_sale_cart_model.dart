import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/data/models/cart/cart_addon_model.dart';
import 'package:jaya_propertiy/data/models/cart/cart_deposit_model.dart';
import 'package:jaya_propertiy/data/models/cart/cart_ticket_mode.dart';
import 'package:jaya_propertiy/data/models/cart/cart_potongan_model.dart';
import 'package:jaya_propertiy/data/models/cart/cart_voucher_model.dart';
import 'package:jaya_propertiy/domain/entities/member/membership.dart';

class CustomerSaleCart {
  List<CartTicket>? ticketList = [];
  List<CartPotongan>? potonganList = [];
  List<CartVoucher>? voucherList = [];
  List<CartDeposit>? depositList = [];
  List<CartAddon>? addonList = [];
  List<Membership>? memberList = [];
  double? totalOrder;
  double? paymentFee;

  CustomerSaleCart({
    this.ticketList,
    this.addonList,
    this.potonganList,
    this.voucherList,
    this.depositList,
    this.memberList,
    this.totalOrder,
    this.paymentFee,
  });

  Map<String, dynamic> toJson() {
    return {
      'ticketList': ticketList?.map((e) => e.toJson()).toList(),
      'addonList': addonList?.map((e) => e.toJson()).toList(),
      'potonganList': potonganList?.map((e) => e.toJson2()).toList(),
      'voucherList': voucherList?.map((e) => e.toJson2()).toList(),
      'depositList': depositList?.map((e) => e.toJson2()).toList(),
      'memberList': memberList?.map((e) => e.toJson()).toList(),
      'totalOrder': totalOrder,
      'paymentFee': paymentFee,
    };
  }

  CustomerSaleCart.fromJson(Map<String, dynamic> json) {
    try {
      int indexTicket = 0;
      int indexPotongan = 0;
      int indexVoucher = 0;
      int indexDeposit = 0;
      int indexAddon = 0;
      int indexMember = 0;
      if (json['ticketList'] != null) {
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
      }
      if (json['addonList'] != null) {
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
      }
      if (json['potonganList'] != null) {
        for (var e in json['potonganList']) {
          if (e is Map<Object?, Object?>) {
            Map<String, dynamic> result = common.convertToMapStringDynamic(e);
            CartPotongan cartPotongan = CartPotongan.fromJson(result);
            potonganList?.insert(indexPotongan, cartPotongan);
            indexPotongan++;
          } else {
            potonganList?.add(CartPotongan.fromJson(e));
          }
        }
      }
      if (json['voucherList'] != null) {
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
      }
      if (json['depositList'] != null) {
        for (var e in json['depositList']) {
          if (e is Map<Object?, Object?>) {
            Map<String, dynamic> result = common.convertToMapStringDynamic(e);
            CartDeposit cartDeposit = CartDeposit.fromJson(result);
            depositList?.insert(indexDeposit, cartDeposit);
            indexDeposit++;
          } else {
            depositList?.add(CartDeposit.fromJson(e));
          }
        }
      }
      if (json['memberList'] != null) {
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
