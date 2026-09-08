/// Satu pilihan alasan kurang puas, diambil dari katalog server.
///
/// Sengaja tidak ditulis ulang sebagai daftar tetap di aplikasi: kalau
/// daftarnya berbeda dengan yang divalidasi backend, jawaban pelanggan akan
/// ditolak justru pada saat mereka sedang berdiri menunggu.
class SurveyReasonEntity {
  final String code;
  final String label;

  SurveyReasonEntity({required this.code, required this.label});

  factory SurveyReasonEntity.fromJson(Map<String, dynamic> json) {
    return SurveyReasonEntity(
      code: json['code']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'code': code, 'label': label};
}
