import 'dart:io';
import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/escpos_decoder_util.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/common/tspl_decoder_util.dart';
import 'package:jaya_propertiy/data/models/common/print_capture_model.dart';
import 'package:path_provider/path_provider.dart';

/// Penampung hasil cetak saat mode simulasi printer menyala.
///
/// Menyimpan dua bentuk sekaligus dan itu disengaja:
/// - **terjemahan baris** untuk dibaca langsung di layar saat mengembangkan;
/// - **byte mentah** ke berkas `.bin`, karena hanya byte asli yang bisa
///   dicocokkan dengan printer sungguhan nanti. Terjemahan bisa saja keliru;
///   byte tidak pernah bohong.
///
/// Daftar di memori dibatasi supaya sesi pengembangan panjang tidak menggerus
/// memori; berkasnya tetap tersimpan.
class PrintCaptureUtil {
  static const int _maksTersimpan = 30;

  final captures = <PrintCaptureModel>[].obs;
  int _urutan = 0;
  Directory? _folder;

  /// Folder tempat byte mentah disimpan. Null bila perangkat menolak akses.
  String? get folderPath => _folder?.path;

  Future<void> capture(List<int> bytes) async {
    _urutan++;
    // Struk memakai ESC/POS, gelang memakai TSPL. Bahasanya dikenali dari isi
    // byte-nya, bukan dari siapa yang memanggil — supaya pratinjau tetap benar
    // dari jalur mana pun cetakan itu datang.
    final tspl = TsplDecoder.sepertinyaTspl(bytes);
    final baris = tspl ? TsplDecoder.decode(bytes) : EscPosDecoder.decode(bytes);
    final berkas = await _tulisBerkas(_urutan, bytes);

    final item = PrintCaptureModel(
      id: _urutan,
      waktu: DateTime.now(),
      jumlahByte: bytes.length,
      baris: baris,
      ringkasan:
          tspl ? TsplDecoder.ringkasan(bytes) : EscPosDecoder.ringkasan(bytes),
      bahasa: tspl ? 'TSPL' : 'ESC/POS',
      berkas: berkas,
    );

    captures.insert(0, item);
    if (captures.length > _maksTersimpan) {
      captures.removeRange(_maksTersimpan, captures.length);
    }

    logger.safeLog(
        'CETAK SIMULASI #${item.id} : ${item.bahasa}, ${item.jumlahByte} byte -> ${berkas ?? "(tanpa berkas)"}');
  }

  void clear() {
    captures.clear();
  }

  /// Gagal menulis berkas tidak boleh menggagalkan simulasi cetak — pratinjau di
  /// layar tetap jauh lebih berguna daripada tidak ada apa-apa.
  Future<String?> _tulisBerkas(int urutan, List<int> bytes) async {
    try {
      _folder ??= await _siapkanFolder();
      if (_folder == null) return null;
      final nama =
          'cetak-${DateTime.now().millisecondsSinceEpoch}-$urutan.bin';
      final file = File('${_folder!.path}/$nama');
      await file.writeAsBytes(Uint8List.fromList(bytes), flush: true);
      return file.path;
    } catch (e) {
      logger.safeLog('Gagal menulis berkas cetak simulasi : $e');
      return null;
    }
  }

  Future<Directory?> _siapkanFolder() async {
    try {
      final base = await getApplicationDocumentsDirectory();
      final dir = Directory('${base.path}/cetak-simulasi');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      return dir;
    } catch (e) {
      logger.safeLog('Gagal menyiapkan folder cetak simulasi : $e');
      return null;
    }
  }
}

PrintCaptureUtil printCapture = PrintCaptureUtil();
