import 'package:flutter_test/flutter_test.dart';
import 'package:jaya_propertiy/app/utils/common/gelang_util.dart';
import 'package:jaya_propertiy/domain/entities/order/response_create_ticket_no_entity.dart';

/// Menguji aturan siapa yang dapat gelang dan siapa yang dapat QR di struk.
///
/// Salah di sini tidak terlihat di kasir — strukmya keluar, gelangnya keluar,
/// semuanya tampak normal. Ketahuannya nanti, saat ada orang berdiri di gate
/// tanpa QR di tangannya.
void main() {
  ResponseCreateTicketNoEntity tiket(String nama, {String? no}) =>
      ResponseCreateTicketNoEntity(
        ticketNo: no ?? '2908092600${nama.hashCode.abs() % 100}',
        ticketName: nama,
        ticketActiveDate: DateTime(2026, 9, 8),
      );

  List<String> nama(List<ResponseCreateTicketNoEntity> l) =>
      l.map((e) => e.ticketName ?? '').toList();

  const playground = {'Playground 2 Jam', 'Playground 1 Jam'};

  test('hanya tiket playground yang jadi gelang', () {
    final hasil = GelangUtil.pisahkan([
      tiket('Playground 2 Jam'),
      tiket('Kolam Renang Dewasa'),
      tiket('Playground 1 Jam'),
    ], playground);

    expect(nama(hasil.gelang), ['Playground 2 Jam', 'Playground 1 Jam']);
    expect(nama(hasil.struk), ['Kolam Renang Dewasa']);
  });

  test('order tanpa playground: tidak ada yang jadi gelang', () {
    final hasil = GelangUtil.pisahkan([
      tiket('Kolam Renang Dewasa'),
      tiket('Kelas Renang Anak'),
    ], playground);

    expect(hasil.gelang, isEmpty);
    expect(hasil.struk, hasLength(2));
  });

  test('order playground penuh: tidak ada QR tersisa untuk struk', () {
    final hasil = GelangUtil.pisahkan([
      tiket('Playground 2 Jam'),
      tiket('Playground 2 Jam'),
    ], playground);

    expect(hasil.gelang, hasLength(2));
    expect(hasil.struk, isEmpty);
  });

  test('katalog playground kosong: semuanya ke struk, bukan semuanya ke gelang',
      () {
    // Terjadi bila pengambilan katalog tiket gagal saat cetak ulang. Jatuh ke
    // perilaku lama itu aman; kebalikannya mencetak gelang untuk tiket kolam.
    final hasil = GelangUtil.pisahkan([
      tiket('Playground 2 Jam'),
      tiket('Kolam Renang Dewasa'),
    ], const {});

    expect(hasil.gelang, isEmpty);
    expect(hasil.struk, hasLength(2));
  });

  test('nama tiket tidak dicocokkan sebagian', () {
    // 'Playground' bukan 'Playground 2 Jam'; pencocokan harus persis, kalau
    // tidak, tiket lain yang namanya mirip ikut tercetak sebagai gelang.
    final hasil = GelangUtil.pisahkan([
      tiket('Playground'),
      tiket('Paket Playground 2 Jam + Makan'),
    ], playground);

    expect(hasil.gelang, isEmpty);
    expect(hasil.struk, hasLength(2));
  });

  group('Tiket yang datanya tidak lengkap', () {
    test('nomor tiket kosong tetap ke struk, tidak dibuang diam-diam', () {
      final hasil = GelangUtil.pisahkan([
        tiket('Playground 2 Jam', no: ''),
        tiket('Playground 2 Jam', no: '   '),
      ], playground);

      expect(hasil.gelang, isEmpty);
      expect(hasil.struk, hasLength(2),
          reason: 'tiket tanpa nomor menandakan ada yang salah di hulu; '
              'menghilangkannya hanya menyembunyikan masalahnya');
    });

    test('nama tiket kosong tidak pernah cocok', () {
      final hasil = GelangUtil.pisahkan(
        [ResponseCreateTicketNoEntity(ticketNo: '290809260005')],
        playground,
      );
      expect(hasil.gelang, isEmpty);
      expect(hasil.struk, hasLength(1));
    });
  });

  test('urutan asli dipertahankan di kedua daftar', () {
    // Nomor "1 of 3" pada struk dan urutan gelang mengikuti urutan ini.
    final hasil = GelangUtil.pisahkan([
      tiket('Playground 2 Jam', no: 'A1'),
      tiket('Kolam Renang Dewasa', no: 'B1'),
      tiket('Playground 2 Jam', no: 'A2'),
      tiket('Kolam Renang Dewasa', no: 'B2'),
    ], playground);

    expect(hasil.gelang.map((e) => e.ticketNo), ['A1', 'A2']);
    expect(hasil.struk.map((e) => e.ticketNo), ['B1', 'B2']);
  });

  test('tidak ada tiket yang hilang atau terhitung dua kali', () {
    final semua = [
      tiket('Playground 2 Jam'),
      tiket('Kolam Renang Dewasa'),
      tiket('Playground 1 Jam'),
      ResponseCreateTicketNoEntity(ticketName: 'Playground 2 Jam'),
    ];
    final hasil = GelangUtil.pisahkan(semua, playground);

    expect(hasil.gelang.length + hasil.struk.length, semua.length);
    for (final t in semua) {
      expect(hasil.gelang.contains(t) ^ hasil.struk.contains(t), isTrue,
          reason: 'tiket "${t.ticketName}" harus ada di tepat satu daftar');
    }
  });
}
