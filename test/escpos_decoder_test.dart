import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart';
import 'package:jaya_propertiy/app/utils/common/escpos_decoder_util.dart';
import 'package:jaya_propertiy/app/utils/common/generate_print_util.dart';
import 'package:jaya_propertiy/app/utils/common/print_capture_util.dart';

/// Menguji penerjemah ESC/POS dengan byte yang dibuat oleh generator yang sama
/// dipakai aplikasi. Kalau penerjemahnya salah baca, pratinjau di mode simulasi
/// akan menyesatkan — dan simulasi yang menyesatkan lebih buruk daripada tidak
/// ada simulasi sama sekali.
void main() {
  late Generator generator;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final profile = await CapabilityProfile.load();
    generator = Generator(PaperSize.mm80, profile);
  });

  List<String> terjemahkan(List<int> bytes) => EscPosDecoder.decode(bytes);

  group('EscPosDecoder', () {
    test('teks biasa terbaca apa adanya', () {
      expect(terjemahkan(generator.text('TIKET MASUK')), contains('TIKET MASUK'));
    });

    test('beberapa baris tetap berurutan', () {
      final bytes = <int>[
        ...generator.text('BARIS SATU'),
        ...generator.text('BARIS DUA'),
        ...generator.text('BARIS TIGA'),
      ];

      final teks = terjemahkan(bytes)
          .where((b) => b.isNotEmpty && !b.startsWith('['))
          .toList();

      expect(teks, ['BARIS SATU', 'BARIS DUA', 'BARIS TIGA']);
    });

    test('perataan tengah muncul sebagai penanda, bukan hilang', () {
      final hasil = terjemahkan(generator.text(
        'JUDUL',
        styles: const PosStyles(align: PosAlign.center),
      ));

      expect(hasil.any((b) => b.contains('rata: tengah')), isTrue,
          reason: 'perataan harus terlihat supaya tata letak bisa diperiksa');
      expect(hasil, contains('JUDUL'));
    });

    test('potong kertas terdeteksi', () {
      expect(terjemahkan(generator.cut()), contains('[potong kertas]'));
    });

    test('reset printer terdeteksi', () {
      final hasil = terjemahkan(generator.reset());
      expect(hasil.any((b) => b.contains('reset printer')), isTrue);
    });

    test('byte tak dikenal tidak menghentikan pembacaan sisa struk', () {
      final bytes = <int>[
        ...generator.text('SEBELUM'),
        0x1B, 0x7E, // perintah ESC yang tidak ditangani
        ...generator.text('SESUDAH'),
      ];

      final hasil = terjemahkan(bytes);
      expect(hasil, contains('SEBELUM'));
      expect(hasil, contains('SESUDAH'),
          reason: 'satu perintah asing tidak boleh membuang sisa struk');
    });

    test('ringkasan memakai baris teks pertama', () {
      final bytes = <int>[
        ...generator.reset(),
        ...generator.text('NHT BEKASI'),
        ...generator.text('Tiket #123'),
      ];

      expect(EscPosDecoder.ringkasan(bytes), 'NHT BEKASI');
    });

    test('struk tanpa teks diberi keterangan, bukan string kosong', () {
      expect(EscPosDecoder.ringkasan(generator.cut()), contains('tanpa teks'));
    });
  });

  group('Jalur cetak QR gelang (BXRink Phase 1)', () {
    test('QR yang dicetak sebagai raster dikenali dan ukurannya terbaca', () {
      // QR pada struk dicetak sebagai gambar raster, bukan teks. Penerjemah
      // harus melewati ribuan byte gambar itu dengan hitungan yang tepat —
      // kalau meleset, teks di bawah QR ikut hancur.
      final gambar = Image(width: 64, height: 64);
      fill(gambar, color: ColorRgb8(0, 0, 0));

      final bytes = <int>[
        ...generator.text('TIKET GELANG'),
        ...generator.imageRaster(gambar),
        ...generator.text('NHT BEKASI'),
      ];

      final hasil = terjemahkan(bytes);

      expect(hasil.any((b) => b.contains('gambar raster')), isTrue,
          reason: 'QR harus terlihat sebagai gambar, bukan hilang diam-diam');
      expect(hasil.any((b) => b.contains('64')), isTrue,
          reason: 'ukuran QR ikut ditampilkan supaya bisa dicocokkan');
      expect(hasil, contains('NHT BEKASI'),
          reason: 'teks setelah QR harus tetap utuh');
    });

    test('struk lengkap tidak menyisakan karakter kendali di teksnya', () async {
      final bytes = await generatePrintUtil.testPrint(paperSize: PaperSize.mm80);
      final hasil = terjemahkan(bytes);
      final teks = hasil.where((b) => !b.startsWith('[')).join();

      expect(hasil.any((b) => b.contains('Ready')), isTrue);
      expect(teks.codeUnits.every((c) => c >= 0x20 || c == 0x0A), isTrue,
          reason: 'byte kendali tidak boleh bocor ke teks yang dibaca operator');
    });
  });

  group('PrintCaptureUtil', () {
    setUp(printCapture.clear);

    test('hasil cetak tersimpan dengan terjemahan dan jumlah byte', () async {
      final bytes = <int>[
        ...generator.reset(),
        ...generator.text('TIKET GELANG'),
        ...generator.cut(),
      ];

      await printCapture.capture(bytes);

      expect(printCapture.captures.length, 1);
      final item = printCapture.captures.first;
      expect(item.jumlahByte, bytes.length);
      expect(item.ringkasan, 'TIKET GELANG');
      expect(item.baris, contains('[potong kertas]'));
    });

    test('cetak terbaru berada di urutan paling atas', () async {
      await printCapture.capture(generator.text('PERTAMA'));
      await printCapture.capture(generator.text('KEDUA'));

      expect(printCapture.captures.first.ringkasan, 'KEDUA');
      expect(printCapture.captures.last.ringkasan, 'PERTAMA');
    });

    test('daftar dibatasi supaya sesi panjang tidak menggerus memori', () async {
      for (var i = 0; i < 35; i++) {
        await printCapture.capture(generator.text('CETAK $i'));
      }
      expect(printCapture.captures.length, 30);
      expect(printCapture.captures.first.ringkasan, 'CETAK 34');
    });
  });
}
