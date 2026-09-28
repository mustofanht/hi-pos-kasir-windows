import 'package:flutter_test/flutter_test.dart';
import 'package:jaya_propertiy/app/utils/common/qr_tiket_util.dart';
import 'package:jaya_propertiy/domain/entities/order/response_create_ticket_no_entity.dart';
import 'package:jaya_propertiy/domain/entities/sale/ticket_entity.dart';

/// Tiket yang disetup **Tanpa Scan** (Setup Tiket → Aktivasi di TV) tidak
/// dicetak QR-nya — permintaan 28 September 2026.
///
/// Yang dijaga di sini adalah dua kesalahan yang sama-sama merugikan tapi
/// berlawanan arah: QR yang tetap keluar padahal tidak pernah dipindai, dan QR
/// yang hilang padahal gate membutuhkannya. Penyaringannya memakai nama tiket,
/// dan nama datang dari dua sumber berbeda (keranjang dan balasan server), jadi
/// perbedaan sekecil akhiran "(Pendamping)" pun harus tetap cocok.
void main() {
  TicketEntity tiket(String nama, {String? autoActive}) => TicketEntity(
        ticketName: nama,
        ticketFlAutoActive: autoActive,
      );

  ResponseCreateTicketNoEntity dibuat(String nama) =>
      ResponseCreateTicketNoEntity(ticketName: nama, ticketNo: '0001');

  List<String> namaDari(List<ResponseCreateTicketNoEntity> hasil) =>
      hasil.map((e) => e.ticketName ?? '').toList();

  group('penanda tanpa scan pada tiket', () {
    test('Y berarti tanpa scan', () {
      expect(tiket('Kolam Renang', autoActive: 'Y').tanpaScan, isTrue);
    });

    test('N, kosong, dan null berarti tetap perlu scan', () {
      expect(tiket('Kolam Renang', autoActive: 'N').tanpaScan, isFalse);
      expect(tiket('Kolam Renang', autoActive: '').tanpaScan, isFalse);
      expect(tiket('Kolam Renang').tanpaScan, isFalse);
    });

    test('huruf kecil dan spasi tepi tetap terbaca sebagai tanpa scan', () {
      // Nilainya datang dari kolom teks bebas di database, bukan enum.
      expect(tiket('Kolam Renang', autoActive: ' y ').tanpaScan, isTrue);
    });
  });

  group('memilih tiket yang QR-nya dicetak', () {
    test('tiket tanpa scan tidak ikut dicetak', () {
      final katalog = QrTiketUtil.namaTanpaScan([
        tiket('Tiket Kelas Renang', autoActive: 'Y'),
        tiket('Kolam Renang Dewasa', autoActive: 'N'),
      ]);

      final hasil = QrTiketUtil.perluQr(
        [dibuat('Tiket Kelas Renang'), dibuat('Kolam Renang Dewasa')],
        katalog,
      );

      expect(namaDari(hasil), ['Kolam Renang Dewasa']);
    });

    test('tiket pendamping ikut nasib tiket induknya', () {
      // Server mengirim balik nama pendamping sebagai "<nama> (Pendamping)".
      // Tanpa memotong akhiran itu, QR pendamping tetap keluar sendirian di
      // struk padahal induknya tidak pernah dipindai.
      final katalog =
          QrTiketUtil.namaTanpaScan([tiket('Playground 2 Jam', autoActive: 'Y')]);

      final hasil = QrTiketUtil.perluQr(
        [dibuat('Playground 2 Jam'), dibuat('Playground 2 Jam (Pendamping)')],
        katalog,
      );

      expect(hasil, isEmpty);
    });

    test('beda besar-kecil huruf dan spasi tepi tetap dikenali', () {
      final katalog =
          QrTiketUtil.namaTanpaScan([tiket('  Tiket Kelas Renang ', autoActive: 'Y')]);

      final hasil = QrTiketUtil.perluQr([dibuat('TIKET KELAS RENANG')], katalog);

      expect(hasil, isEmpty);
    });

    test('tanpa satu pun tiket tanpa scan, semuanya tetap dicetak', () {
      final katalog = QrTiketUtil.namaTanpaScan([
        tiket('Kolam Renang Dewasa', autoActive: 'N'),
        tiket('Kolam Renang Anak'),
      ]);

      final semua = [dibuat('Kolam Renang Dewasa'), dibuat('Kolam Renang Anak')];
      expect(QrTiketUtil.perluQr(semua, katalog), equals(semua));
    });

    test('tiket yang tidak ada di katalog tetap dicetak', () {
      // Katalog diambil per lokasi dan bisa tidak memuat tiket lama. Yang tidak
      // dikenali harus tetap ber-QR: pelanggan tidak boleh kehilangan tiket
      // karena setupnya tidak terbaca.
      final katalog =
          QrTiketUtil.namaTanpaScan([tiket('Tiket Kelas Renang', autoActive: 'Y')]);

      final hasil = QrTiketUtil.perluQr([dibuat('Tiket Lama')], katalog);

      expect(namaDari(hasil), ['Tiket Lama']);
    });

    test('tiket tanpa nama tidak menghapus apa pun', () {
      final katalog = QrTiketUtil.namaTanpaScan([tiket('', autoActive: 'Y')]);

      expect(katalog, isEmpty);
      expect(QrTiketUtil.perluQr([dibuat('Kolam Renang')], katalog).length, 1);
    });
  });
}
