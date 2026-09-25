import 'package:flutter_test/flutter_test.dart';
import 'package:jaya_propertiy/app/utils/common/order_util.dart';

/// Jeda munculnya survei kepuasan (permintaan outlet, 25 September 2026).
///
/// Survei dulu muncul tepat saat kasir menekan cetak — pelanggan masih
/// menerima struk dan kembalian, belum memandang layar, lalu surveinya keburu
/// tergantikan keranjang transaksi berikutnya.
void main() {
  test('survei muncul lima detik setelah cetak', () {
    expect(OrderUtil.jedaSurvei, const Duration(seconds: 5));
  });

  test('jedanya tidak melebihi batas diam survei', () {
    // Survei menutup sendiri setelah 45 detik tanpa sentuhan. Jeda yang lebih
    // panjang dari itu akan membuat survei muncul lalu langsung pergi.
    expect(OrderUtil.jedaSurvei.inSeconds, lessThan(45));
  });
}
