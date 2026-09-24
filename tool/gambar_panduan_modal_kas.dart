import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/domain/entities/shift/shift_detail_entity.dart';
import 'package:jaya_propertiy/domain/entities/shift/shift_kas_pecahan_entity.dart';
import 'package:jaya_propertiy/presentation/views/modules/shift/blok_kas_shift.dart';
import 'package:jaya_propertiy/presentation/views/modules/shift/hitung_kas_dialog.dart';

/// Perekam gambar untuk panduan modal kas.
///
/// Bukan uji: berkas ini sengaja di luar folder `test/` supaya tidak ikut
/// berjalan pada `flutter test`. Jalankan sendiri ketika panduannya perlu
/// gambar baru:
///
/// ```
/// flutter test tool/gambar_panduan_modal_kas.dart
/// ```
///
/// Yang digambar adalah **widget aslinya**, bukan tiruan: layar yang sama yang
/// dilihat kasir. Kalau tampilannya berubah, jalankan ulang dan gambarnya ikut
/// berubah — panduan tidak akan diam-diam menjadi usang.
///
/// Fontnya diambil dari `assets/fonts` — sama dengan yang dipakai aplikasi.
/// Font untuk gaya teks bawaan tema: isian angka, kata "lembar", dan tombol.
///
/// Di perangkat asli bagian itu memakai font sistem (Roboto di Android); di
/// gambar panduan dipakai Poppins supaya satu rupa dan yang penting terbaca.
/// Bedanya hanya bentuk huruf — letak, ukuran, dan warnanya tetap apa adanya.
const String _fontBawaan = 'Poppins';

const String _folderKeluaran = 'D:/FLUTTER/HI-POS/dokumentasi/gambar/modal-kas';
Future<void> _muatFont() async {
  // Fontnya didaftarkan sendiri, tidak menunggu google_fonts: pemuatan oleh
  // google_fonts berjalan di belakang layar dan belum tentu selesai saat
  // gambarnya diambil — hasilnya tulisan berubah menjadi kotak hitam.
  GoogleFonts.config.allowRuntimeFetching = false;

  final varian = <String, String>{
    'Poppins_regular': 'assets/fonts/Poppins-Regular.ttf',
    'Poppins_500': 'assets/fonts/Poppins-Medium.ttf',
    'Poppins_600': 'assets/fonts/Poppins-SemiBold.ttf',
    'Poppins_700': 'assets/fonts/Poppins-Bold.ttf',
  };

  final semua = FontLoader('Poppins');
  for (final entri in varian.entries) {
    final berkas = File(entri.value);
    if (!berkas.existsSync()) {
      throw StateError('Font tidak ditemukan: ${entri.value}');
    }
    final isi = berkas.readAsBytesSync().buffer.asByteData();
    semua.addFont(Future.value(isi));
    await (FontLoader(entri.key)..addFont(Future.value(isi))).load();
  }
  await semua.load();
}

/// Tema aplikasi, dengan font bawaan perangkat dipasang tegas.
///
/// Aplikasi tidak menentukan font untuk gaya teks bawaan — di perangkat asli
/// yang dipakai font sistem. Di sini font itu harus disebutkan namanya supaya
/// isian dan tombol tergambar dengan huruf, bukan kotak.
ThemeData _tema() {
  final dasar = theme.light();
  // Daftar cadangan dikosongkan: bila tidak, cadangan bawaan lingkungan uji
  // (font kotak) yang dipakai dan huruf aslinya tidak pernah muncul.
  return dasar.copyWith(
    textTheme: dasar.textTheme
        .apply(fontFamily: _fontBawaan, fontFamilyFallback: const []),
    primaryTextTheme: dasar.primaryTextTheme
        .apply(fontFamily: _fontBawaan, fontFamilyFallback: const []),
  );
}

Future<void> _rekam(
  WidgetTester tester, {
  required String nama,
  required Widget isi,
  required double lebar,
  Color latar = Colors.white,
}) async {
  final kunci = GlobalKey();

  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _tema(),
      home: Builder(
        builder: (context) {
          // Halaman kasir memakai ukuran layar untuk semua jaraknya, jadi ini
          // harus dipanggil persis seperti di aplikasi.
          layoutStyle.init(context);
          return Scaffold(
            backgroundColor: const Color(0xFFEFEDF3),
            body: Center(
              child: RepaintBoundary(
                key: kunci,
                child: Container(
                  width: lebar,
                  color: latar,
                  padding: const EdgeInsets.all(16),
                  child: Material(color: latar, child: isi),
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
  // Bukan pumpAndSettle: layar ini punya animasi yang tidak pernah berhenti
  // (kursor isian berkedip), jadi menunggu "tenang" berarti menunggu selamanya.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  final batas =
      kunci.currentContext!.findRenderObject()! as RenderRepaintBoundary;

  // Penggambaran ke berkas adalah kerja nyata, bukan kerja semu milik uji:
  // tanpa runAsync, penantiannya tidak pernah selesai.
  ByteData? data;
  await tester.runAsync(() async {
    final gambar = await batas.toImage(pixelRatio: 2);
    data = await gambar.toByteData(format: ui.ImageByteFormat.png);
    gambar.dispose();
  });

  Directory(_folderKeluaran).createSync(recursive: true);
  File('$_folderKeluaran/$nama.png')
      .writeAsBytesSync(data!.buffer.asUint8List());
  // ignore: avoid_print
  print('tersimpan: $_folderKeluaran/$nama.png');
}

ShiftKasPecahanEntity _pecahan(int nilai, int lembar) => ShiftKasPecahanEntity(
      pecahan: nilai,
      lembar: lembar,
      jumlah: (nilai * lembar).toDouble(),
    );

void main() {
  setUpAll(() async {
    await _muatFont();
  });

  testWidgets('gambar panduan modal kas', timeout: const Timeout(Duration(minutes: 3)),
      (tester) async {
    tester.view.physicalSize = const Size(1600, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    // 1. Layar modal awal, masih kosong — yang pertama dilihat kasir.
    await _rekam(
      tester,
      nama: '1-modal-kasir-kosong',
      lebar: 720,
      isi: const HitungKasIsi(
        judul: 'Modal Kasir',
        keterangan: 'Hitung uang modal yang diterima di awal shift, '
            'isi jumlah lembar tiap pecahan.',
        labelSimpan: 'Simpan Modal',
        bolehBatal: true,
      ),
    );

    // 2. Layar yang sama setelah diisi: 100rb 1, 20rb 5, 10rb 10 = 300rb.
    await _rekam(
      tester,
      nama: '2-modal-kasir-terisi',
      lebar: 720,
      isi: const HitungKasIsi(
        judul: 'Modal Kasir',
        keterangan: 'Hitung uang modal yang diterima di awal shift, '
            'isi jumlah lembar tiap pecahan.',
        labelSimpan: 'Simpan Modal',
        bolehBatal: true,
        awal: {100000: 1, 20000: 5, 10000: 10},
      ),
    );

    // 3. Hitung laci saat tutup shift.
    await _rekam(
      tester,
      nama: '3-hitung-uang-di-laci',
      lebar: 720,
      isi: const HitungKasIsi(
        judul: 'Hitung Uang di Laci',
        keterangan: 'Hitung seluruh uang tunai di laci sebelum shift ditutup. '
            'Selisihnya dihitung terhadap modal awal ditambah penjualan tunai.',
        labelSimpan: 'Lanjut Tutup Shift',
        bolehBatal: true,
        awal: {100000: 9, 50000: 5, 20000: 5, 10000: 10, 5000: 10, 1000: 0},
      ),
    );

    // 4. Blok kas di Rincian Shift, contoh laci kurang 50rb.
    final detail = ShiftDetailEntity(
      shftDate: '2026-09-24',
      shftUserid: 'kasir01',
      pakaiModalKas: 'Y',
      modalAwal: 300000,
      tunaiSum: 1000000,
      kasSeharusnya: 1300000,
      kasAkhir: 1250000,
      selisihKas: -50000,
      listPecahanModal: [
        _pecahan(100000, 1),
        _pecahan(20000, 5),
        _pecahan(10000, 10),
      ],
      listPecahanAkhir: [
        _pecahan(100000, 9),
        _pecahan(50000, 5),
        _pecahan(20000, 5),
        _pecahan(10000, 10),
      ],
    );

    await _rekam(
      tester,
      nama: '4-rincian-shift-blok-kas',
      lebar: 640,
      isi: Column(
        mainAxisSize: MainAxisSize.min,
        children: blokKasShift(detail),
      ),
    );

    // 5. Shift yang sedang berjalan: modal sudah diisi, transaksi sudah ada,
    //    laci belum dihitung karena shiftnya memang belum ditutup.
    final berjalan = ShiftDetailEntity(
      shftDate: '2026-09-24',
      shftUserid: 'kasir01',
      pakaiModalKas: 'Y',
      modalAwal: 600000,
      tunaiSum: 948000,
      kasSeharusnya: 1548000,
      listPecahanModal: [
        _pecahan(100000, 1),
        _pecahan(50000, 5),
        _pecahan(20000, 5),
        _pecahan(10000, 10),
        _pecahan(5000, 10),
      ],
      listPecahanAkhir: const [],
    );

    await _rekam(
      tester,
      nama: '5-rincian-shift-sedang-berjalan',
      lebar: 640,
      isi: Column(
        mainAxisSize: MainAxisSize.min,
        children: blokKasShift(berjalan),
      ),
    );
  });
}
