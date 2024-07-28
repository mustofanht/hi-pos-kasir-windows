class ShiftDetailEntity{
  final String? shftDate;
  final String? shftUserid;
  final DateTime? shftStart;
  final DateTime? shftEnd;
  final String? userFullName;
  final String? lokasiName;
  final int? tiketCount;
  final int? itemCount;
  final String? qrisSum;
  final String? edcSum;
  final String? travelokaSum;
  final String? ticketdotcomSum;

  ShiftDetailEntity({
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

  factory ShiftDetailEntity.fromJson(Map<String, dynamic> json) {
    return ShiftDetailEntity(
      shftDate: json['shftDate'],
      shftUserid: json['shftUserid'],
      shftStart: json['shftStart'] != null ? DateTime.parse(json['shftStart']).toLocal() : null,
      shftEnd: json['shftEnd'] != null ? DateTime.parse(json['shftEnd']).toLocal() : null,
      userFullName: json['userFullName'],
      lokasiName: json['lokasiName'],
      tiketCount: json['tiketCount'],
      itemCount: json['itemCount'],
      qrisSum: json['qrisSum'],
      edcSum: json['edcSum'],
      travelokaSum: json['travelokaSum'],
      ticketdotcomSum: json['ticketdotcomSum'],
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