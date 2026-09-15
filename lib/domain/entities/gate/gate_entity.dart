/// Ubah tanggal dari server menjadi waktu setempat.
///
/// `DateTime.parse` pada teks berzona waktu ("...+07:00") menghasilkan objek
/// **UTC**. Menampilkannya apa adanya membuat jam masuk tampil 7 jam lebih awal
/// dari kenyataan — dan yang paling menyesatkan, jam itu tidak cocok dengan
/// papan TV maupun struk.
DateTime? _waktuSetempat(dynamic nilai) {
  if (nilai == null) return null;
  final waktu = DateTime.tryParse(nilai.toString());
  return waktu?.toLocal();
}

/// Satu pilihan alasan keluar manual, dari katalog server.
class ManualExitReasonEntity {
  final String code;
  final String label;

  ManualExitReasonEntity({required this.code, required this.label});

  factory ManualExitReasonEntity.fromJson(Map<String, dynamic> json) {
    return ManualExitReasonEntity(
      code: json['code']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
    );
  }
}

/// Data satu tiket untuk dicetak ulang dari layar Keluar Manual.
class ManualExitTicketEntity {
  final String? ticketNo;
  final String? orderNo;
  final String? reffNo;
  final String? ticketName;
  final DateTime? activeDate;
  final String? isCompanion;
  final String? childName;
  final DateTime? orderDate;
  final bool alreadyTakeout;

  ManualExitTicketEntity({
    this.ticketNo,
    this.orderNo,
    this.reffNo,
    this.ticketName,
    this.activeDate,
    this.isCompanion,
    this.childName,
    this.orderDate,
    this.alreadyTakeout = false,
  });

  bool get pendamping => isCompanion == 'Y';

  factory ManualExitTicketEntity.fromJson(Map<String, dynamic> json) {
    return ManualExitTicketEntity(
      ticketNo: json['ticketNo']?.toString(),
      orderNo: json['orderNo']?.toString(),
      reffNo: json['reffNo']?.toString(),
      ticketName: json['ticketName']?.toString(),
      activeDate: _waktuSetempat(json['activeDate']),
      isCompanion: json['isCompanion']?.toString(),
      childName: json['childName']?.toString(),
      orderDate: _waktuSetempat(json['orderDate']),
      alreadyTakeout: json['alreadyTakeout'] == true,
    );
  }
}

/// Satu permintaan keluar manual beserta jejak persetujuannya.
class ManualExitEntity {
  final int? requestId;
  final String? ticketNo;
  final String? orderNo;
  final String? locationName;
  final String? reasonCode;
  final String? reasonLabel;
  final String? notes;
  final String? approvalCode;
  final DateTime? expiresDate;
  final String? requestedBy;
  final DateTime? requestedDate;
  final String? approvedBy;
  final DateTime? approvedDate;
  final String? status;
  final String? statusLabel;
  final int? approvalDuration;
  final String? rejectionReason;

  ManualExitEntity({
    this.requestId,
    this.ticketNo,
    this.orderNo,
    this.locationName,
    this.reasonCode,
    this.reasonLabel,
    this.notes,
    this.approvalCode,
    this.expiresDate,
    this.requestedBy,
    this.requestedDate,
    this.approvedBy,
    this.approvedDate,
    this.status,
    this.statusLabel,
    this.approvalDuration,
    this.rejectionReason,
  });

  bool get menunggu => status == 'P';

  /// Sisa waktu sebelum permintaan kedaluwarsa; negatif berarti sudah lewat.
  Duration get sisaWaktu => expiresDate == null
      ? Duration.zero
      : expiresDate!.difference(DateTime.now());

  factory ManualExitEntity.fromJson(Map<String, dynamic> json) {
    DateTime? tgl(String key) => _waktuSetempat(json[key]);

    return ManualExitEntity(
      requestId: json['requestId'] as int?,
      ticketNo: json['ticketNo']?.toString(),
      orderNo: json['orderNo']?.toString(),
      locationName: json['locationName']?.toString(),
      reasonCode: json['reasonCode']?.toString(),
      reasonLabel: json['reasonLabel']?.toString(),
      notes: json['notes']?.toString(),
      approvalCode: json['approvalCode']?.toString(),
      expiresDate: tgl('expiresDate'),
      requestedBy: json['requestedBy']?.toString(),
      requestedDate: tgl('requestedDate'),
      approvedBy: json['approvedBy']?.toString(),
      approvedDate: tgl('approvedDate'),
      status: json['status']?.toString(),
      statusLabel: json['statusLabel']?.toString(),
      approvalDuration: json['approvalDuration'] as int?,
      rejectionReason: json['rejectionReason']?.toString(),
    );
  }
}

/// Pelanggan yang sedang aktif / kandidat checkout lebih awal.
class TakeOutCustomerEntity {
  final String? ticketNo;
  final String? orderNo;
  final String? customerName;
  final String? ticketName;
  final String? locationName;
  final DateTime? checkinDate;
  final DateTime? expiredDate;
  final int? durationBooked;
  final int? durationUsed;
  final int? durationRemaining;
  final bool alreadyTakeout;
  final DateTime? takeoutDate;

  TakeOutCustomerEntity({
    this.ticketNo,
    this.orderNo,
    this.customerName,
    this.ticketName,
    this.locationName,
    this.checkinDate,
    this.expiredDate,
    this.durationBooked,
    this.durationUsed,
    this.durationRemaining,
    this.alreadyTakeout = false,
    this.takeoutDate,
  });

  factory TakeOutCustomerEntity.fromJson(Map<String, dynamic> json) {
    DateTime? tgl(String key) => _waktuSetempat(json[key]);

    return TakeOutCustomerEntity(
      ticketNo: json['ticketNo']?.toString(),
      orderNo: json['orderNo']?.toString(),
      customerName: json['customerName']?.toString(),
      ticketName: json['ticketName']?.toString(),
      locationName: json['locationName']?.toString(),
      checkinDate: tgl('checkinDate'),
      expiredDate: tgl('expiredDate'),
      durationBooked: json['durationBooked'] as int?,
      durationUsed: json['durationUsed'] as int?,
      durationRemaining: json['durationRemaining'] as int?,
      alreadyTakeout: json['alreadyTakeout'] == true,
      takeoutDate: tgl('takeoutDate'),
    );
  }
}

/// Hasil eksekusi takeout.
class TakeOutResultEntity {
  final String? ticketNo;
  final String? customerName;
  final int? durationBooked;
  final int? durationUsed;
  final int? durationUnused;

  TakeOutResultEntity({
    this.ticketNo,
    this.customerName,
    this.durationBooked,
    this.durationUsed,
    this.durationUnused,
  });

  factory TakeOutResultEntity.fromJson(Map<String, dynamic> json) {
    return TakeOutResultEntity(
      ticketNo: json['ticketNo']?.toString(),
      customerName: json['customerName']?.toString(),
      durationBooked: json['durationBooked'] as int?,
      durationUsed: json['durationUsed'] as int?,
      durationUnused: json['durationUnused'] as int?,
    );
  }
}

/// Format menit menjadi "2j 15m" — dipakai di beberapa layar sekaligus.
String formatMenit(int? menit) {
  if (menit == null) return '-';
  if (menit < 60) return '$menit menit';
  final jam = menit ~/ 60;
  final sisa = menit % 60;
  return sisa == 0 ? '$jam jam' : '$jam jam $sisa menit';
}
