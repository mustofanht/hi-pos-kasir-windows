/// Satu hasil cetak yang ditangkap mode simulasi.
class PrintCaptureModel {
  final int id;
  final DateTime waktu;
  final int jumlahByte;

  /// Baris hasil terjemahan ESC/POS, siap ditampilkan apa adanya.
  final List<String> baris;

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
    this.berkas,
  });

  bool get adaGambar => baris.any((b) => b.startsWith('[gambar'));

  bool get adaQr =>
      baris.any((b) => b.contains('QR'));
}
