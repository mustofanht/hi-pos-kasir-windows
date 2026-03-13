class ResponseCreateTicketNoEntity {
  String? ticketNo;
  DateTime? ticketActiveDate;
  String? ticketName;

  ResponseCreateTicketNoEntity({
    this.ticketNo,
    this.ticketActiveDate,
    this.ticketName,
  });

  factory ResponseCreateTicketNoEntity.fromJson(Map<String, dynamic> json) {
    return ResponseCreateTicketNoEntity(
      ticketNo: json['ticketNo'],
      ticketActiveDate: json['ticketActiveDate'] != null
          ? DateTime.parse(json['ticketActiveDate']).toLocal()
          : null,
      ticketName: json['ticketName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ticketNo': ticketNo,
      'ticketActiveDate': ticketActiveDate,
      'ticketName': ticketName,
    };
  }
}
