import 'package:jaya_propertiy/data/models/cart/cart_addon_model.dart';
import 'package:jaya_propertiy/data/models/cart/cart_voucher_model.dart';
import 'package:jaya_propertiy/data/models/cart/cart_ticket_mode.dart';

class Cart {
  List<CartTicket> cartTicketList;
  List<CartVoucher> cartVoucherList;
  List<CartAddon> addonList;

  Cart({
    required this.cartTicketList,
    required this.cartVoucherList,
    required this.addonList,
  });

  Map<String, dynamic> toJson() {
    return {
      "orderTicketList": cartTicketList,
      "cartVoucherList": cartVoucherList,
      "addonList": addonList,
    };
  }
}
