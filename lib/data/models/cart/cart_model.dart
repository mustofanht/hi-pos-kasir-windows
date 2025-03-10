import 'package:jaya_propertiy/data/models/cart/cart_addon_model.dart';
import 'package:jaya_propertiy/data/models/cart/cart_potongan_model.dart';
import 'package:jaya_propertiy/data/models/cart/cart_ticket_mode.dart';

class Cart {
  List<CartTicket> cartTicketList;
  List<CartPotongan> cartPotonganList;
  List<CartAddon> addonList;

  Cart({
    required this.cartTicketList,
    required this.cartPotonganList,
    required this.addonList,
  });

  Map<String, dynamic> toJson() {
    return {
      "orderTicketList": cartTicketList,
      "cartPotonganList": cartPotonganList,
      "addonList": addonList,
    };
  }
}
