import 'package:flutter_test/flutter_test.dart';
import 'package:jaya_propertiy/domain/entities/otorisasi/otorisasi_entity.dart';

/// Otorisasi kasir (syspos V136) dan blokir void yang belum disetujui.
///
/// Yang dikejar di sini dua keputusan yang mudah dilanggar tanpa menampakkan
/// error apa pun:
///
/// 1. **Izin tidak dihitung sendiri di aplikasi.** "Boleh jalan" datang dari
///    server lewat `bolehJalan`. Aplikasi terpasang tidak bisa diperbarui
///    secepat server, jadi aturan yang disalin ke sini (disetujui + belum
///    dipakai + belum kedaluwarsa) akan tertinggal — dan yang terjadi adalah
///    kasir mencetak atas izin yang sebenarnya sudah tidak berlaku.
/// 2. **Penolakan harus terbaca kasir.** Layar yang hanya bisa berkata
///    "menunggu" membuat kasir menunggu sesuatu yang tidak akan datang.
void main() {
  OtorisasiEntity dari(Map<String, dynamic> json) =>
      OtorisasiEntity.fromJson(json);

  group('OtorisasiEntity', () {
    test('membaca balasan server apa adanya', () {
      final o = dari({
        'id': 12,
        'jenis': 'CETAK_ULANG_STRUK',
        'jenisLabel': 'Cetak ulang struk',
        'ref': '22102624ORD0001',
        'keterangan': 'dede - Rp60.000',
        'status': 'A',
        'statusLabel': 'Disetujui',
        'requestedBy': 'kasir123',
        'approvedBy': 'spv1',
        'expiresDate': '2026-10-22T08:00:00+07:00',
        'bolehJalan': true,
      });

      expect(o.id, 12);
      expect(o.jenis, OtorisasiEntity.jenisCetakUlangStruk);
      expect(o.jenisLabel, 'Cetak ulang struk');
      expect(o.ref, '22102624ORD0001');
      expect(o.approvedBy, 'spv1');
      expect(o.bolehJalan, isTrue);
      expect(o.expiresDate, isNotNull);
    });

    test('status disetujui TANPA bolehJalan tetap tidak boleh dijalankan', () {
      // Inilah keadaan izin yang sudah dipakai atau sudah kedaluwarsa di
      // server. Kalau aplikasi menyimpulkan sendiri dari status 'A', kasir
      // akan mencetak ulang struk atas izin yang sudah habis.
      final o = dari({'id': 1, 'status': 'A', 'bolehJalan': false});
      expect(o.bolehJalan, isFalse);
    });

    test('id yang datang sebagai teks tetap terbaca', () {
      // Beberapa jalur server mengirim angka sebagai string. Id yang gagal
      // dibaca membuat penandaan "sudah dipakai" tidak pernah terkirim, dan
      // satu izin bisa dipakai berkali-kali.
      expect(dari({'id': '77'}).id, 77);
    });

    test('pesan untuk tiap keadaan bisa dibaca kasir', () {
      expect(dari({'status': 'P'}).pesan, contains('Menunggu'));
      expect(dari({'status': 'A', 'bolehJalan': true}).pesan,
          contains('silakan lanjutkan'));
      expect(dari({'status': 'U'}).pesan, contains('sudah dipakai'));
      expect(dari({'status': 'E'}).pesan, contains('kedaluwarsa'));
    });

    test('alasan penolakan ikut terbaca di layar kasir', () {
      final o = dari({
        'status': 'R',
        'rejectionReason': 'Deposit milik pelanggan lain',
      });
      expect(o.ditolak, isTrue);
      expect(o.bolehJalan, isFalse);
      expect(o.pesan, contains('Deposit milik pelanggan lain'));
    });

    test('penolakan tanpa alasan tetap memberi kalimat yang jelas', () {
      final o = dari({'status': 'R'});
      expect(o.pesan, contains('ditolak'));
      expect(o.pesan.trim(), isNotEmpty);
    });

    test('balasan kosong tidak membuat aplikasi mengira boleh jalan', () {
      final o = dari({});
      expect(o.bolehJalan, isFalse);
      expect(o.menunggu, isFalse);
      expect(o.pesan, isNotEmpty);
    });
  });

  group('VoidTertundaEntity', () {
    test('kasir dengan void tertunda ditandai terblokir beserta nomornya', () {
      final v = VoidTertundaEntity.fromJson({
        'kasir': 'kasir123',
        'jumlah': 2,
        'orderNumbers': ['22102624ORD0001', '22102624ORD0002'],
        'terblokir': true,
        'pesan': 'Masih ada 2 void yang belum disetujui leader',
      });

      expect(v.terblokir, isTrue);
      expect(v.jumlah, 2);
      expect(v.orderNumbers, hasLength(2));
      // Kalimatnya datang dari server supaya bunyi pesan di layar kasir sama
      // persis dengan penolakan yang nanti muncul dari server.
      expect(v.pesan, contains('belum disetujui'));
    });

    test('tanpa void tertunda, kasir tidak terblokir', () {
      final v = VoidTertundaEntity.fromJson({
        'kasir': 'kasir123',
        'jumlah': 0,
        'orderNumbers': <String>[],
        'terblokir': false,
      });
      expect(v.terblokir, isFalse);
      expect(v.orderNumbers, isEmpty);
      expect(v.pesan, isNull);
    });

    test('balasan yang bentuknya tidak terduga tidak memblokir penjualan', () {
      // Lebih baik satu transaksi lolos dan ditolak server daripada seluruh
      // loket berhenti karena balasan yang tidak bisa dibaca.
      final v = VoidTertundaEntity.fromJson({});
      expect(v.terblokir, isFalse);
      expect(v.jumlah, 0);
      expect(v.orderNumbers, isEmpty);
    });
  });
}
