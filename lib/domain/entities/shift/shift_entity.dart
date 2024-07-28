class ShiftEntity {
  final String? shftDate;
  final String? shftUserid;
  final DateTime? shftStart;
  final DateTime? shftEnd;
  final String? userFullName;
  final String? lokasiName;
  final int? tiketCount;
  final int? itemCount;
  final double? qrisSum;
  final double? edcSum;
  final double? travelokaSum;
  final double? ticketdotcomSum;

  ShiftEntity({
    this.shftDate,
    this.shftUserid,
    this.shftStart,
    this.shftEnd,
    this.userFullName,
    this.lokasiName,
    this.tiketCount,
    this.itemCount,
    this.qrisSum,
    this.edcSum,
    this.travelokaSum,
    this.ticketdotcomSum,
  });

  factory ShiftEntity.fromJson(Map<String, dynamic> json) {
    return ShiftEntity(
      shftDate: json['shftDate'],
      shftUserid: json['shftUserid'],
      shftStart: json['shftStart'] != null ? DateTime.parse(json['shftStart']).toLocal() : null,
      shftEnd: json['shftEnd'] != null ? DateTime.parse(json['shftEnd']).toLocal() : null,
      userFullName: json['userFullName'],
      lokasiName: json['lokasiName'],
      tiketCount: json['tiketCount'],
      itemCount: json['itemCount'],
      qrisSum: json['qrisSum'] != null ? double.parse(json['qrisSum'].toString()) : null,
      edcSum: json['edcSum'] != null ? double.parse(json['edcSum'].toString()) : null,
      travelokaSum: json['travelokaSum'] != null ? double.parse(json['travelokaSum'].toString()) : null,
      ticketdotcomSum: json['ticketdotcomSum'] != null ? double.parse(json['ticketdotcomSum'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shftDate': shftDate,
      'shftUserid': shftUserid,
      'shftStart': shftStart?.toIso8601String(),
      'shftEnd': shftEnd?.toIso8601String(),
      'userFullName': userFullName,
      'lokasiName': lokasiName,
      'tiketCount': tiketCount,
      'itemCount': itemCount,
      'qrisSum': qrisSum,
      'edcSum': edcSum,
      'travelokaSum': travelokaSum,
      'ticketdotcomSum': ticketdotcomSum,
    };
  }
}