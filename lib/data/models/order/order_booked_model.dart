/// Satu jam booking lapangan (1 elemen = 1 jam pada 1 court/tiket).
///
/// Dikirim di `OrderModel.trnOrderBookeds`. Backend (TrnOrderService) yang
/// menghitung harga otoritatif (`resolveBookPrice`), memvalidasi anti
/// dobel-booking, membuat nomor booking, dan menerbitkan e-tiket (QR). Mobile
/// cukup mengirim court, jam, dan tanggalnya.
///
/// Booking sesi KELAS memakai model yang sama: [bookSessionid] + [bookQty]
/// (jumlah anak) + [bookDate], tanpa [bookHour]. Backend memeriksa kuota
/// (dipakai bersama website), mengambil harga dari master sesi, dan
/// menerbitkan 1 QR per anak.
class OrderBookedModel {
  int? bookTicketid;
  int? bookHour;
  DateTime? bookDate;
  int? bookSessionid;
  int? bookQty;

  OrderBookedModel({
    this.bookTicketid,
    this.bookHour,
    this.bookDate,
    this.bookSessionid,
    this.bookQty,
  });

  factory OrderBookedModel.fromJson(Map<String, dynamic> json) {
    return OrderBookedModel(
      bookTicketid: json['bookTicketid'],
      bookHour: json['bookHour'],
      bookSessionid: json['bookSessionid'],
      bookQty: json['bookQty'],
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
      if (bookSessionid != null) 'bookSessionid': bookSessionid,
      if (bookQty != null) 'bookQty': bookQty,
    };
  }
}
