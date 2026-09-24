/// Satu baris hitungan uang kasir: pecahan, banyak lembar, dan hasil kalinya.
class ShiftKasPecahanEntity {
  final int pecahan;
  final int lembar;
  final double jumlah;

  ShiftKasPecahanEntity({
    required this.pecahan,
    required this.lembar,
    required this.jumlah,
  });

  factory ShiftKasPecahanEntity.fromJson(Map<String, dynamic> json) {
    final pecahan = _angka(json['pecahan']).round();
    final lembar = _angka(json['lembar']).round();
    return ShiftKasPecahanEntity(
      pecahan: pecahan,
      lembar: lembar,
      // Server selalu mengirim hasil kalinya, tapi rekap tidak boleh kosong
      // hanya karena satu baris lama tidak punya angka itu.
      jumlah: json['jumlah'] != null
          ? _angka(json['jumlah'])
          : (pecahan * lembar).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'pecahan': pecahan,
        'lembar': lembar,
        'jumlah': jumlah,
      };

  static double _angka(dynamic nilai) {
    if (nilai == null) return 0;
    if (nilai is num) return nilai.toDouble();
    return double.tryParse(nilai.toString()) ?? 0;
  }
}
