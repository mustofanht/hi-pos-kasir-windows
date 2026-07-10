import 'package:jaya_propertiy/data/models/cart/cart_addon_model.dart';
import 'package:jaya_propertiy/data/models/cart/cart_deposit_model.dart';
import 'package:jaya_propertiy/data/models/cart/cart_potongan_model.dart';
import 'package:jaya_propertiy/data/models/cart/cart_ticket_mode.dart';
import 'package:jaya_propertiy/data/models/cart/cart_voucher_model.dart';

class Cart {
  List<CartTicket> cartTicketList;
  List<CartPotongan> cartPotonganList;
  List<CartVoucher> cartVoucherList;
  List<CartDeposit> cartDepositList;
  List<CartAddon> addonList;

  Cart({
    required this.cartTicketList,
    required this.cartPotonganList,
    required this.cartVoucherList,
    required this.cartDepositList,
    required this.addonList,
  });

  Map<String, dynamic> toJson() {
    return {
      "orderTicketList": cartTicketList,
      "cartPotonganList": cartPotonganList,
      "cartVoucherList": cartVoucherList,
      "cartDepositList": cartDepositList,
      "addonList": addonList,
    };
  }
}
