class VwOrderEntity {
  String? orderNumber;
  DateTime? orderDate;
  String? orderStatus;
  String? pymntStatus;
  String? otdtlStatus;
  String? countScan;
  String? pymntCode;
  String? ticketName;
  String? jumlahticket;
  String? locName;
  String? locId;
  String? unitName;
  String? unitId;
  String? statusCetak;

  VwOrderEntity({
    this.orderNumber,
    this.orderDate,
    this.orderStatus,
    this.pymntStatus,
    this.otdtlStatus,
    this.countScan,
    this.pymntCode,
    this.ticketName,
    this.jumlahticket,
    this.locName,
    this.locId,
    this.unitName,
    this.unitId,
    this.statusCetak,
  });

  factory VwOrderEntity.fromJson(Map<String, dynamic> json) {
    return VwOrderEntity(
      orderNumber: json['orderNumber'],
      orderDate: json['orderDate'] != null
          ? DateTime.parse(json['orderDate']).toLocal()
          : null,
      orderStatus: json['orderStatus'],
      pymntStatus: json['pymntStatus'],
      otdtlStatus: json['otdtlStatus'],
      countScan: json['countScan'],
      pymntCode: json['pymntCode'],
      ticketName: json['ticketName'],
      jumlahticket: json['jumlahticket'],
      locName: json['locName'],
      locId: json['locId'],
      unitName: json['unitName'],
      unitId: json['unitId'],
      statusCetak: json['statusCetak'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderNumber': orderNumber,
      'orderDate': orderDate?.toIso8601String(),
      'orderStatus': orderStatus,
      'pymntStatus': pymntStatus,
      'otdtlStatus': otdtlStatus,
      'countScan': countScan,
      'pymntCode': pymntCode,
      'ticketName': ticketName,
      'jumlahticket': jumlahticket,
      'locName': locName,
      'locId': locId,
      'unitName': unitName,
      'unitId': unitId,
      'statusCetak': statusCetak,
    };
  }
}
