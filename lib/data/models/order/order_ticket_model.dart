class OrderTicketModel {
  int? ordtcTicketId;
  int totalTicket;
  double totalAmount;

  OrderTicketModel({
    this.ordtcTicketId,
    required this.totalTicket,
    required this.totalAmount,
  });

  factory OrderTicketModel.fromJson(Map<String, dynamic> json) {
    return OrderTicketModel(
      ordtcTicketId: json['ordtcTicketId'],
      totalTicket: json['totalTicket'],
      totalAmount: json['totalAmount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "ordtcTicketId": ordtcTicketId,
      "totalTicket": totalTicket,
      "totalAmount": totalAmount,
    };
  }
}
