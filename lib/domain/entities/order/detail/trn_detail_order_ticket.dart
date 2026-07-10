class TrnDetailOrderTicket{
  String? ticketName;
  int? ticketQty;
  double? ticketTtlAmount;
  double? ticketPrice;

  TrnDetailOrderTicket({
    this.ticketName,
    this.ticketQty,
    this.ticketTtlAmount,
    this.ticketPrice,
  });

  factory TrnDetailOrderTicket.fromJson(Map<String, dynamic> json) {
    return TrnDetailOrderTicket(
      ticketName: json['ticketName'],
      ticketQty: json['ticketQty'],
      ticketTtlAmount: json['ticketTtlAmount'] != null ? (json['ticketTtlAmount'] as num).toDouble() : null,
      ticketPrice: json['ticketPrice'] != null ? (json['ticketPrice'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ticketName': ticketName,
      'ticketQty': ticketQty,
      'ticketTtlAmount': ticketTtlAmount,
      'ticketPrice': ticketPrice,
    };
  }
}