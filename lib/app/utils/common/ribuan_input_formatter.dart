import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Format kotak input nominal rupiah dengan pemisah ribuan (titik) SAAT
/// DIKETIK, mis. "50000" tampil "50.000".
///
/// `TextEditingController.text` ikut berisi titik pemisah itu -- pemanggil
/// WAJIB membersihkannya dulu sebelum di-parse ke angka, lewat
/// [RibuanInputFormatter.bersihkan]. `double.tryParse` langsung akan salah
/// baca ("50.000" jadi 50.0, titik dibaca sebagai desimal).
class RibuanInputFormatter extends TextInputFormatter {
  static final _format = NumberFormat('###,###,###,###', 'id_ID');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final angka = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (angka.isEmpty) {
      return const TextEditingValue(text: '');
    }
    final baru = _format.format(int.parse(angka));
    return TextEditingValue(
      text: baru,
      selection: TextSelection.collapsed(offset: baru.length),
    );
  }

  /// Angka asli dari teks berpemisah ribuan, mis. "50.000" -> 50000.
  static double bersihkan(String teks) {
    return double.tryParse(teks.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }
}
