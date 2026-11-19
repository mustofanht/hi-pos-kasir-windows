import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:jaya_propertiy/data/models/cart/cart_addon_model.dart';
import 'package:jaya_propertiy/data/models/cart/cart_rent_model.dart';
import 'package:jaya_propertiy/domain/entities/sale/addon_entity.dart';

/// Keranjang dikirim ke layar pelanggan sebagai JSON lalu dibaca ulang.
CartAddon bolakBalik(CartAddon a) =>
    CartAddon.fromJson(jsonDecode(jsonEncode(a.toJson())) as Map<String, dynamic>);

void main() {
  test('barang biasa tetap barang biasa (bukan sewa) setelah dikirim', () {
    final hasil = bolakBalik(CartAddon(
      qtyOrder: 3,
      totalPrice: 30000,
      addon: AddonEntity(productId: 1, productName: 'Kaos Kaki', productPrice: 10000),
    ));
    expect(hasil.rentModel, isNull);
    expect(hasil.qtyOrder, 3);
    expect(hasil.addon?.productName, 'Kaos Kaki');
  });

  test('barang sewa tetap membawa jamnya', () {
    final mulai = DateTime(2026, 11, 19, 10);
    final hasil = bolakBalik(CartAddon(
      qtyOrder: 1,
      totalPrice: 50000,
      addon: AddonEntity(productId: 2, productName: 'Lapangan A'),
      rentModel: CartRentModel(
        startDate: mulai,
        endDate: mulai.add(const Duration(hours: 2)),
        totalHours: 2,
        isExtraTime: false,
      ),
    ));
    expect(hasil.rentModel, isNotNull);
    expect(hasil.rentModel!.startDate, mulai);
    expect(hasil.rentModel!.totalHours, 2);
    expect(hasil.addon?.productName, 'Lapangan A');
  });
}
