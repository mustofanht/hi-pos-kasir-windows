/// Program kelas untuk tab Kelas kasir (endpoint `mst_ticket/kelas`), beserta
/// sesi-sesinya pada satu tanggal.
class KelasEntity {
  int? ticketId;
  String? ticketName;
  int? ticketLocation;
  String? ticketLocationName;
  String? roomName;
  int? capacity;
  String? pathImg;
  String? ticketDesc;
  List<KelasSesiEntity> sessions;

  KelasEntity({
    this.ticketId,
    this.ticketName,
    this.ticketLocation,
    this.ticketLocationName,
    this.roomName,
    this.capacity,
    this.pathImg,
    this.ticketDesc,
    this.sessions = const [],
  });

  factory KelasEntity.fromJson(Map<String, dynamic> json) {
    return KelasEntity(
      ticketId: json['ticketId'],
      ticketName: json['ticketName'],
      ticketLocation: json['ticketLocation'],
      ticketLocationName: json['ticketLocationName'],
      roomName: json['roomName'],
      capacity: json['capacity'],
      pathImg: json['pathImg'],
      ticketDesc: json['ticketDesc'],
      sessions: json['sessions'] is List
          ? (json['sessions'] as List)
              .whereType<Map>()
              .map((e) => KelasSesiEntity.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : [],
    );
  }
}

class KelasSesiEntity {
  int? sessionId;
  String? sessionName;
  String? startTime;
  String? endTime;
  double? price;
  int? capacity;

  /// Sisa kursi pada tanggal tsb. Kuota dipakai bersama dengan website.
  int? remaining;

  /// N = tersedia, Y = penuh, C = sudah selesai, B = ditutup admin.
  String? status;

  KelasSesiEntity({
    this.sessionId,
    this.sessionName,
    this.startTime,
    this.endTime,
    this.price,
    this.capacity,
    this.remaining,
    this.status,
  });

  bool get bisaDijual => status == 'N' && (remaining ?? 0) > 0;

  String get jam => endTime != null ? '$startTime - $endTime' : (startTime ?? '');

  String get labelStatus {
    switch (status) {
      case 'Y':
        return 'Penuh';
      case 'C':
        return 'Selesai';
      case 'B':
        return 'Ditutup';
      default:
        return 'Sisa ${remaining ?? 0}';
    }
  }

  factory KelasSesiEntity.fromJson(Map<String, dynamic> json) {
    return KelasSesiEntity(
      sessionId: json['sessionId'],
      sessionName: json['sessionName'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      price: (json['price'] as num?)?.toDouble(),
      capacity: json['capacity'],
      remaining: json['remaining'],
      status: json['status'],
    );
  }
}
