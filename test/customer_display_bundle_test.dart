import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:jaya_propertiy/data/models/cart/cart_addon_model.dart';
import 'package:jaya_propertiy/data/models/customer/customer_sale_cart_model.dart';
import 'package:jaya_propertiy/domain/entities/sale/addon_entity.dart';

void main() {
  group('Bundling tiket di layar pelanggan', () {
    CartAddon bundle({required double total}) => CartAddon(
          qtyOrder: 2,
          totalPrice: total,
          bundleId: 3,
          addon: AddonEntity(
            productId: 205,
            productName: 'Pop Mie',
            productType: 'J',
            productPrice: total / 2,
          ),
        );

    test('bundling gratis ikut terkirim dan tetap Rp0', () {
      final kirim = CustomerSaleCart(
        ticketList: [],
        addonList: [],
        bundleList: [bundle(total: 0)],
        potonganList: [],
        voucherList: [],
        depositList: [],
        totalOrder: 0,
        paymentFee: 0,
      ).toJson();

      final terima = CustomerSaleCart.fromJson(
          jsonDecode(jsonEncode(kirim)) as Map<String, dynamic>);

      expect(terima.bundleList, hasLength(1));
      final b = terima.bundleList!.single;
      expect(b.totalPrice, 0);
      expect(b.qtyOrder, 2);
      expect(b.addon?.productName, 'Pop Mie');
      expect(b.isBundle, isTrue);
    });

    test('harga int 0 dari kanal layar kedua tidak menghilangkan baris', () {
      final json = bundle(total: 0).toJson()..['totalPrice'] = 0;
      final b = CartAddon.fromJson(
          jsonDecode(jsonEncode(json)) as Map<String, dynamic>);
      expect(b.totalPrice, 0.0);
      expect(b.addon?.productName, 'Pop Mie');
    });

    test('bundling berbayar tetap membawa nominalnya', () {
      final json = CustomerSaleCart(bundleList: [bundle(total: 14000)]).toJson();
      final terima = CustomerSaleCart.fromJson(
          jsonDecode(jsonEncode(json)) as Map<String, dynamic>);
      expect(terima.bundleList!.single.totalPrice, 14000);
    });
  });
}
