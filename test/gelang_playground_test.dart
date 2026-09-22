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

  group('Gelang pendamping', () {
    // Server mengirim balik nama tiket pendamping sebagai "<nama> (Pendamping)",
    // bukan nama aslinya. Kalau akhiran itu tidak dipotong, gelang pendamping
    // tertinggal di kertas struk sementara gelang berbayarnya keluar — padahal
    // keduanya dipakai anak yang sama masuk gate.
    ResponseCreateTicketNoEntity pendamping(String namaTiket) =>
        ResponseCreateTicketNoEntity(
          ticketNo: '300909260002',
          ticketName: '$namaTiket (Pendamping)',
          isCompanion: 'Y',
        );

    test('tiket pendamping playground ikut jadi gelang', () {
      final hasil = GelangUtil.pisahkan([
        tiket('Playground 2 Jam'),
        pendamping('Playground 2 Jam'),
      ], playground);

      expect(hasil.gelang, hasLength(2));
      expect(hasil.struk, isEmpty);
    });

    test('pendamping tiket non-playground tetap ke struk', () {
      final hasil = GelangUtil.pisahkan([
        pendamping('Kolam Renang Dewasa'),
      ], playground);

      expect(hasil.gelang, isEmpty);
      expect(hasil.struk, hasLength(1));
    });

    test('akhiran hanya dipotong pada tiket berpenanda pendamping', () {
      // Tiket berbayar yang kebetulan bernama begitu tidak boleh ikut dipotong;
      // nama katalognya memang mengandung kata itu.
      final hasil = GelangUtil.pisahkan([
        ResponseCreateTicketNoEntity(
          ticketNo: '300909260003',
          ticketName: 'Playground 2 Jam (Pendamping)',
          isCompanion: 'N',
        ),
      ], playground);

      expect(hasil.gelang, isEmpty, reason: 'namanya utuh, tidak ada di katalog');
      expect(hasil.struk, hasLength(1));
    });

    test('tiket pendamping playground selalu jadi gelang', () {
      final hasil = GelangUtil.pisahkan([
        pendamping('Playground 2 Jam'),
      ], playground);
      expect(hasil.gelang, hasLength(1));
    });

    test('namaDasar mengembalikan nama katalog', () {
      expect(GelangUtil.namaDasar(pendamping('Tiket 1 jam weekday')),
          'Tiket 1 jam weekday');
      expect(GelangUtil.namaDasar(tiket('Tiket 1 jam weekday')),
          'Tiket 1 jam weekday');
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

  group('Baris nama di gelang', () {
    ResponseCreateTicketNoEntity t(
      String no, {
      bool pendamping = false,
      String? anak,
      String tiket = 'Tiket 1 jam weekday',
    }) =>
        ResponseCreateTicketNoEntity(
          ticketNo: no,
          // Server membubuhkan akhiran ini pada tiket pendamping yang baru dibuat.
          ticketName: pendamping ? '$tiket (Pendamping)' : tiket,
          isCompanion: pendamping ? 'Y' : 'N',
          childName: pendamping ? 'Pendamping' : anak,
        );

    test('tiket anak berisi nama anak, pendamping berisi Pendamping (nama anak)',
        () {
      final b = GelangUtil.barisNama([
        t('301009260015', anak: 'rita'),
        t('301009260016', pendamping: true),
      ]);
      expect(b['301009260015'], 'rita');
      expect(b['301009260016'], 'Pendamping (rita)');
    });

    test('dua anak: tiap pendamping dipasangkan dengan anaknya sendiri', () {
      final b = GelangUtil.barisNama([
        t('301009260015', anak: 'rita'),
        t('301009260016', pendamping: true),
        t('301009260017', anak: 'budi'),
        t('301009260018', pendamping: true),
      ]);
      expect(b['301009260016'], 'Pendamping (rita)');
      expect(b['301009260018'], 'Pendamping (budi)');
    });

    test('urutan balasan server diabaikan — dipasangkan menurut nomor tiket', () {
      // Cetak ulang membaca tiket tanpa ORDER BY sambil memperbarui statusnya;
      // urutan yang datang bisa teracak.
      final b = GelangUtil.barisNama([
        t('301009260018', pendamping: true),
        t('301009260015', anak: 'rita'),
        t('301009260017', anak: 'budi'),
        t('301009260016', pendamping: true),
      ]);
      expect(b['301009260016'], 'Pendamping (rita)');
      expect(b['301009260018'], 'Pendamping (budi)');
    });

    test('cetak ulang: nama tiket pendamping tanpa akhiran tetap dipasangkan', () {
      // Jalur tiket-sudah-ada di server mengirim nama katalog apa adanya.
      final b = GelangUtil.barisNama([
        ResponseCreateTicketNoEntity(
            ticketNo: '301009260015',
            ticketName: 'Tiket 1 jam weekday',
            isCompanion: 'N',
            childName: 'rita'),
        ResponseCreateTicketNoEntity(
            ticketNo: '301009260016',
            ticketName: 'Tiket 1 jam weekday',
            isCompanion: 'Y',
            childName: 'Pendamping'),
      ]);
      expect(b['301009260016'], 'Pendamping (rita)');
    });

    test('nama anak kosong: dipakai nama pemesan, seperti papan TV', () {
      final b = GelangUtil.barisNama([
        t('301009260015'),
        t('301009260016', pendamping: true),
      ], pembeli: 'rita');
      expect(b['301009260015'], 'rita');
      expect(b['301009260016'], 'Pendamping (rita)');
    });

    test('tanpa nama sama sekali: pendamping tetap bertanda', () {
      final b = GelangUtil.barisNama([
        t('301009260015'),
        t('301009260016', pendamping: true),
      ]);
      expect(b['301009260015'], isNull);
      expect(b['301009260016'], 'Pendamping');
    });

    test('pendamping tidak dipasangkan dengan anak dari tiket berbeda', () {
      final b = GelangUtil.barisNama([
        t('301009260015', anak: 'rita', tiket: 'Tiket 1 jam weekday'),
        t('301009260016', anak: 'budi', tiket: 'Tiket 2 jam weekday'),
        t('301009260017', pendamping: true, tiket: 'Tiket 1 jam weekday'),
      ]);
      expect(b['301009260017'], 'Pendamping (rita)');
    });

    test('nama anak panjang dipotong tanpa kehilangan kurung penutup', () {
      final b = GelangUtil.barisNama([
        t('301009260015', anak: 'Muhammad Rizky Pratama Putra'),
        t('301009260016', pendamping: true),
      ]);
      expect(b['301009260016'], endsWith(')'));
      expect(b['301009260016']!.length, lessThanOrEqualTo(32));
    });
  });
}
