import 'package:flutter_test/flutter_test.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/sale_page_controller.dart';

/// Nomor telepon pelanggan wajib diisi di order kasir (permintaan 23 Sep 2026).
///
/// Nomor ini dipakai menghubungi pelanggan bila ada tiket tertinggal atau
/// keluhan, dan menjadi penghubung ke survei kepuasan yang diisi di layar
/// pelanggan. Dulu boleh kosong dan disimpan sebagai satu spasi.
void main() {
  group('Nomor telepon order', () {
    test('nomor wajar diterima apa pun awalannya', () {
      for (final nomor in [
        '081234567890',
        '6281234567890',
        '+6281234567890',
        '0812 3456 7890',
        '0812-3456-7890',
        '(021) 5551234',
      ]) {
        expect(SalePageController.nomorTelpSah(nomor), isTrue, reason: nomor);
      }
    });

    test('kosong dan terlalu pendek ditolak', () {
      for (final nomor in ['', '   ', '08', '0812-345', '-']) {
        expect(SalePageController.nomorTelpSah(nomor), isFalse, reason: nomor);
      }
    });

    test('terlalu panjang ditolak', () {
      expect(SalePageController.nomorTelpSah('0812345678901234'), isFalse);
    });

    test('pemisah dibuang, awalan dipertahankan apa adanya', () {
      expect(SalePageController.nomorTelpBersih('0812 3456-7890'), '081234567890');
      expect(SalePageController.nomorTelpBersih(' +62 812 3456 7890 '), '+6281234567890');
      expect(SalePageController.nomorTelpBersih('(021) 555.1234'), '0215551234');
    });
  });
}
