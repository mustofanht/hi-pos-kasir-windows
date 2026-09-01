/// Satu jam booking lapangan (1 elemen = 1 jam pada 1 court/tiket).
///
/// Dikirim di `OrderModel.trnOrderBookeds`. Backend (TrnOrderService) yang
/// menghitung harga otoritatif (`resolveBookPrice`), memvalidasi anti
/// dobel-booking, membuat nomor booking, dan menerbitkan e-tiket (QR). Mobile
/// cukup mengirim court, jam, dan tanggalnya.
class OrderBookedModel {
  int? bookTicketid;
  int? bookHour;
  DateTime? bookDate;

  OrderBookedModel({
    this.bookTicketid,
    this.bookHour,
    this.bookDate,
  });

  factory OrderBookedModel.fromJson(Map<String, dynamic> json) {
    return OrderBookedModel(
      bookTicketid: json['bookTicketid'],
      bookHour: json['bookHour'],
      bookDate: json['bookDate'] != null
          ? DateTime.parse(json['bookDate']).toLocal()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookTicketid': bookTicketid,
      'bookHour': bookHour,
      'bookDate': bookDate?.toIso8601String(),
    };
  }
}
