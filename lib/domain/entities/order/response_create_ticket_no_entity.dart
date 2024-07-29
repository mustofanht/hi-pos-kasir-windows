class ResponseCreateTicketNoEntity {
  String? ticketNo;
  String? ticketName;

  ResponseCreateTicketNoEntity({
    this.ticketNo,
    this.ticketName,
  });

  factory ResponseCreateTicketNoEntity.fromJson(Map<String, dynamic> json) {
    return ResponseCreateTicketNoEntity(
      ticketNo: json['ticketNo'],
      ticketName: json['ticketName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ticketNo': ticketNo,
      'ticketName': ticketName,
    };
  }
}