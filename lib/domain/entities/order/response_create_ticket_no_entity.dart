class ResponseCreateTicketNoEntity {
  String? ticketNo;
  DateTime? ticketActiveDate;
  String? ticketName;
  String? isCompanion; // Y = pendamping, N = berbayar
  String? childName; // Nama anak atau "Pendamping"

  ResponseCreateTicketNoEntity({
    this.ticketNo,
    this.ticketActiveDate,
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
      ticketName: json['ticketName'],
      isCompanion: json['isCompanion'],
      childName: json['childName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ticketNo': ticketNo,
      'ticketActiveDate': ticketActiveDate,
      'ticketName': ticketName,
      'isCompanion': isCompanion,
      'childName': childName,
    };
  }
}
