import 'package:flutter_test/flutter_test.dart';
import 'package:jaya_propertiy/app/utils/common/qr_tiket_util.dart';

/// Pemeriksaan "ada yang perlu dicetak" — dipakai **sebelum** kasir meminta
/// izin leader di menu Cek Order (permintaan 23 Oktober 2026).
///
/// Dua kesalahan yang dijaga di sini berlawanan arah, dan keduanya terjadi di
/// lapangan:
///
/// 1. **Menghalangi cetak yang memang dibutuhkan.** Pelanggan pulang tanpa QR
///    dan tidak bisa masuk gate. Karena itu setiap keadaan yang tidak bisa
///    dipastikan — daftar nama kosong, katalog setup gagal diambil, nama tiket
///    tidak dikenali — harus menghasilkan `true`.
/// 2. **Meminta izin untuk pekerjaan yang tidak ada.** Kasir mengajukan, leader
///    menyetujui, lalu layarnya berkata tidak ada yang bisa dicetak. Satu
///    persetujuan terbuang, tercatat di jejak audit sebagai izin yang tak
///    pernah dipakai, dan kasir mengulanginya karena menyangka izinnya gagal.
///    Itulah yang terjadi pada order 23102630ORD0003 (izin id=123 disetujui,
///    tidak pernah dipakai).
void main() {
  group('ada yang perlu dicetak', () {
    test('seluruh tiket Tanpa Scan: tidak ada yang perlu dicetak', () {
      // Kasus nyata ORD0003: satu tiket, "Tiket Weekday Reguler", disetup
      // Tanpa Scan (ticket_fl_auto_active='Y').
      expect(
        QrTiketUtil.adaYangPerluDicetak(
          namaTiketOrder: ['Tiket Weekday Reguler'],
          namaTanpaScan: {'TIKET WEEKDAY REGULER'},
        ),
        isFalse,
      );
    });

    test('satu tiket biasa di antara tiket Tanpa Scan tetap dicetak', () {
      // Jangan sampai satu tiket tanpa scan membatalkan cetak QR tiket lain
      // dalam order yang sama.
      expect(
        QrTiketUtil.adaYangPerluDicetak(
          namaTiketOrder: ['Tiket Weekday Reguler', 'tiket 20 menit'],
          namaTanpaScan: {'TIKET WEEKDAY REGULER'},
        ),
        isTrue,
      );
    });

    test('tiket lapangan tetap dicetak walau bertanda Tanpa Scan', () {
      // Booking lapangan keluar sebagai struk penjualan (court + jam + harga),
      // bukan QR, jadi penanda Tanpa Scan tidak meniadakannya.
      expect(
        QrTiketUtil.adaYangPerluDicetak(
          namaTiketOrder: ['Lapangan A'],
          namaTanpaScan: {'LAPANGAN A'},
          namaLapangan: ['Lapangan A'],
        ),
        isTrue,
      );
    });

    test('tiket pendamping ikut nasib induknya', () {
      // Server membubuhkan akhiran "(Pendamping)". Tanpa memotongnya, nama
      // pendamping tidak pernah cocok dengan katalog dan hasilnya selalu
      // "perlu dicetak".
      expect(
        QrTiketUtil.adaYangPerluDicetak(
          namaTiketOrder: ['Tiket Anak', 'Tiket Anak (Pendamping)'],
          namaTanpaScan: {'TIKET ANAK'},
        ),
        isFalse,
      );
    });

    test('beda besar-kecil huruf dan spasi tepi tetap dikenali', () {
      // Nama datang dari dua sumber berbeda (rincian order & setup tiket),
      // masing-masing kolom teks bebas.
      expect(
        QrTiketUtil.adaYangPerluDicetak(
          namaTiketOrder: ['  tiket weekday reguler '],
          namaTanpaScan: {'TIKET WEEKDAY REGULER'},
        ),
        isFalse,
      );
    });

    group('berpihak pada mencetak bila tidak bisa dipastikan', () {
      test('katalog Tanpa Scan kosong (mis. gagal diambil) → dicetak', () {
        expect(
          QrTiketUtil.adaYangPerluDicetak(
            namaTiketOrder: ['Tiket Weekday Reguler'],
            namaTanpaScan: const {},
          ),
          isTrue,
        );
      });

      test('rincian tiket order kosong → dicetak', () {
        // Rincian order belum termuat bukan alasan menghalangi kasir; penyaring
        // sesudah nomor tiket terbit masih akan membuang yang tidak perlu.
        expect(
          QrTiketUtil.adaYangPerluDicetak(
            namaTiketOrder: const <String>[],
            namaTanpaScan: {'TIKET WEEKDAY REGULER'},
          ),
          isTrue,
        );
      });

      test('nama kosong/null diabaikan, sisanya yang menentukan', () {
        expect(
          QrTiketUtil.adaYangPerluDicetak(
            namaTiketOrder: [null, '  ', 'Tiket Weekday Reguler'],
            namaTanpaScan: {'TIKET WEEKDAY REGULER'},
          ),
          isFalse,
        );
        expect(
          QrTiketUtil.adaYangPerluDicetak(
            namaTiketOrder: [null, '  '],
            namaTanpaScan: {'TIKET WEEKDAY REGULER'},
          ),
          isTrue,
        );
      });

      test('nama tiket yang tidak dikenali katalog → dicetak', () {
        expect(
          QrTiketUtil.adaYangPerluDicetak(
            namaTiketOrder: ['Tiket Baru Belum Disetup'],
            namaTanpaScan: {'TIKET WEEKDAY REGULER'},
          ),
          isTrue,
        );
      });
    });

    test('sejalan dengan penyaring yang dipakai sesudah tiket terbit', () {
      // Dua keputusan ini harus sepakat: kalau [adaYangPerluDicetak] berkata
      // "ada" sementara [perluDicetak] membuang semuanya, kasir tetap sampai ke
      // layar "tidak ada yang perlu dicetak" SESUDAH mengganggu leader — tepat
      // keadaan yang hendak dihindari.
      final katalog = {'TIKET WEEKDAY REGULER'};
      const nama = ['Tiket Weekday Reguler'];
      expect(
        QrTiketUtil.adaYangPerluDicetak(
          namaTiketOrder: nama,
          namaTanpaScan: katalog,
        ),
        isFalse,
      );
    });
  });
}
