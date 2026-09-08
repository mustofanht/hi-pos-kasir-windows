/// Satu hasil cetak yang ditangkap mode simulasi.
class PrintCaptureModel {
  final int id;
  final DateTime waktu;
  final int jumlahByte;

  /// Baris hasil terjemahan, siap ditampilkan apa adanya.
  final List<String> baris;

  /// Bahasa perintah cetaknya: `ESC/POS` untuk struk, `TSPL` untuk gelang.
  /// Ditampilkan di pratinjau karena keduanya keluar di daftar yang sama, dan
  /// keliru membaca yang satu sebagai yang lain menyesatkan.
  final String bahasa;

  /// Baris pertama yang berisi teks — dipakai sebagai judul di daftar.
  final String ringkasan;

  /// Lokasi berkas byte mentah, bila berhasil ditulis. Berguna untuk dikirim
  /// ke vendor printer saat mencocokkan perilaku perangkat sungguhan.
  final String? berkas;

  PrintCaptureModel({
    required this.id,
    required this.waktu,
    required this.jumlahByte,
    required this.baris,
    required this.ringkasan,
    this.bahasa = 'ESC/POS',
    this.berkas,
  });

  bool get adaGambar => baris.any((b) => b.startsWith('[gambar'));

  bool get adaQr => baris.any((b) => b.contains('QR'));

  bool get gelang => bahasa == 'TSPL';
}
