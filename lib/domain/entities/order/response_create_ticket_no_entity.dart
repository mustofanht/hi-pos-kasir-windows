class ResponseCreateTicketNoEntity {
  String? ticketNo;
  DateTime? ticketActiveDate;

  /// ticketActiveDate sudah diformat backend ke zona waktu lokasi tiket ini
  /// (mst_location.loc_timezone), "dd-MM-yyyy HH:mm:ss". Struk/QR cetak WAJIB
  /// memakai ini (lewat dateTimeUtil.parseLocalFormatted) — bukan
  /// ticketActiveDate mentah, yang ikut ter-toLocal() ke zona DEVICE kasir,
  /// bisa salah kalau device-nya diset ke WIB meski lokasinya WITA/WIT.
  String? ticketActiveDateLocal;
  String? ticketName;
  String? isCompanion; // Y = pendamping, N = berbayar
  String? childName; // Nama anak atau "Pendamping"

  ResponseCreateTicketNoEntity({
    this.ticketNo,
    this.ticketActiveDate,
    this.ticketActiveDateLocal,
    this.ticketName,
    this.isCompanion,
    this.childName,
  });

  factory ResponseCreateTicketNoEntity.fromJson(Map<String, dynamic> json) {
    return ResponseCreateTicketNoEntity(
      ticketNo: json['ticketNo'],
      ticketActiveDate: json['ticketActiveDate'] != null
          ? DateTime.parse(json['ticketActiveDate']).toLocal()
          : null,
      ticketActiveDateLocal: json['ticketActiveDateLocal']?.toString(),
      ticketName: json['ticketName'],
      isCompanion: json['isCompanion'],
      childName: json['childName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ticketNo': ticketNo,
      'ticketActiveDate': ticketActiveDate,
      'ticketActiveDateLocal': ticketActiveDateLocal,
      'ticketName': ticketName,
      'isCompanion': isCompanion,
      'childName': childName,
    };
  }
}
