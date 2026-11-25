import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:jaya_propertiy/domain/entities/sale/addon_entity.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/jaminansewa/jaminan_cashin_dialog_controller.dart';

/// Tombol nominal cepat Jaminan Sewa (10rb–100rb) mengisi kolom Nominal
/// Jaminan dan menandai tombol yang sesuai isi kolom.
void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await initializeDateFormatting('id_ID');
  });

  JaminanCashInDialogController buat() =>
      JaminanCashInDialogController(item: AddonEntity(productId: 1), onSelesai: () {});

  test('pilihan nominal sesuai permintaan', () {
    expect(JaminanCashInDialogController.pilihanNominal,
        [10000, 20000, 30000, 40000, 50000, 100000]);
  });

  test('ketuk 50rb mengisi kolom dengan format ribuan dan menandai 50rb', () {
    final c = buat();
    c.pilihNominal(50000);
    expect(c.amountController.text, '50.000');
    expect(c.nominalTerpilih, 50000);
    c.pilihNominal(100000);
    expect(c.amountController.text, '100.000');
    expect(c.nominalTerpilih, 100000);
  });

  test('nominal diketik manual di luar pilihan: tidak ada tombol aktif', () {
    final c = buat();
    c.amountController.text = '25.000';
    expect(c.nominalTerpilih, isNull);
    c.amountController.text = '20.000';
    expect(c.nominalTerpilih, 20000);
  });
}
