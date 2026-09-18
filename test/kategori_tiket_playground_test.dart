import 'package:flutter_test/flutter_test.dart';
import 'package:jaya_propertiy/domain/entities/sale/ticket_entity.dart';

/// Lokasi multi-kategori: perlakuan tiket ditentukan kategori TIKETNYA.
///
/// Dilaporkan 18 September 2026: di lokasi berkategori lebih dari satu, memilih
/// tiket playground tidak memunculkan input nama anak. Penyebabnya kasir memakai
/// kategori LOKASI, yang untuk satu terminal hanya berisi satu nilai — jadi tiket
/// playground di lokasi yang kategori utamanya kolam renang tidak terdeteksi, dan
/// sebaliknya tiket kolam di lokasi playground malah ikut diminta nama anak.
void main() {
  TicketEntity tiket({String? kategoriTiket, String? kategoriLokasi}) =>
      TicketEntity(
        ticketId: 1,
        ticketName: 'Tiket',
        ticketCategory: kategoriTiket,
        ticketLocationCategory: kategoriLokasi,
      );

  group('Kategori tiket playground', () {
    test('tiket playground di lokasi berkategori lain tetap terdeteksi', () {
      // Kasus yang dilaporkan: Club House menjual playground + kolam + lapangan,
      // kategori lokasinya hanya menyimpan salah satunya.
      expect(
        tiket(kategoriTiket: 'PLGRD', kategoriLokasi: 'KLMRG').isPlayground,
        isTrue,
      );
    });

    test('tiket kolam di lokasi playground tidak dianggap playground', () {
      // Sisi sebaliknya: dulu seluruh tiket ikut diminta nama anak hanya karena
      // kategori lokasinya playground.
      expect(
        tiket(kategoriTiket: 'KLMRG', kategoriLokasi: 'PLGRD').isPlayground,
        isFalse,
      );
    });

    test('tiket lama tanpa kategori memakai kategori lokasi', () {
      expect(tiket(kategoriLokasi: 'PLGRD').isPlayground, isTrue);
      expect(tiket(kategoriLokasi: 'LPNGN').isPlayground, isFalse);
    });

    test('kategori kosong atau spasi dianggap belum diisi', () {
      expect(tiket(kategoriTiket: '  ', kategoriLokasi: 'PLGRD').isPlayground,
          isTrue);
      expect(tiket(kategoriTiket: '', kategoriLokasi: 'KLMRG').isPlayground,
          isFalse);
      expect(tiket().isPlayground, isFalse);
      expect(tiket().kategoriEfektif, isNull);
    });

    test('besar-kecil huruf dan spasi tidak mengubah hasil', () {
      expect(tiket(kategoriTiket: ' plgrd ').isPlayground, isTrue);
      expect(tiket(kategoriTiket: ' plgrd ').kategoriEfektif, 'PLGRD');
    });

    test('kategori dibaca dari balasan server apa adanya', () {
      final dari = TicketEntity.fromJson({
        'ticketId': 164,
        'ticketName': 'Tiket gogoplay',
        'ticketCategory': 'PLGRD',
        'ticketLocationCategory': 'KLMRG',
      });
      expect(dari.isPlayground, isTrue);
    });
  });
}
