/// Satu transaksi jaminan sewa item: uang tunai yang dititipkan pelanggan saat
/// menyewa barang, dikembalikan penuh saat barang kembali dalam kondisi baik.
///
/// Status `O` = Outstanding (uang masih dipegang kasir), `R` = Returned
/// (sudah dikembalikan/cash-out). Lihat syspos V159.
class JaminanSewaEntity {
  static const String statusOutstanding = 'O';
  static const String statusReturned = 'R';

  final int? id;
  final String? jmnNo;
  final int? locationId;
  final String? locationName;
  final int? productId;
  final String? itemName;
  final double? qty;
  final double? amount;
  final String? paymentCode;
  final String? paymentName;

  /// Nomor referensi manual (mesin EDC/QRIS statis) — kosong untuk Tunai &
  /// metode yang lewat payment gateway.
  final String? paymentRefNo;
  final String? customerName;
  final String? customerPhone;
  final String? notes;
  final String? status;
  final String? statusLabel;
  final String? refundNotes;
  final String? createdBy;
  final DateTime? createdDate;
  final String? updatedBy;
  final DateTime? updatedDate;

  /// Diisi hanya saat status Waiting — kasir tampilkan QR ini & tunggu lunas.
  final String? qrUrl;

  /// true = status Waiting, belum boleh dianggap uang diterima.
  final bool needsPayment;

  JaminanSewaEntity({
    this.id,
    this.jmnNo,
    this.locationId,
    this.locationName,
    this.productId,
    this.itemName,
    this.qty,
    this.amount,
    this.paymentCode,
    this.paymentName,
    this.paymentRefNo,
    this.customerName,
    this.customerPhone,
    this.notes,
    this.status,
    this.statusLabel,
    this.refundNotes,
    this.createdBy,
    this.createdDate,
    this.updatedBy,
    this.updatedDate,
    this.qrUrl,
    this.needsPayment = false,
  });

  bool get outstanding => status == statusOutstanding;

  factory JaminanSewaEntity.fromJson(Map<String, dynamic> json) {
    double? toDouble(dynamic v) => v == null
        ? null
        : (v is num ? v.toDouble() : double.tryParse(v.toString()));
    int? toInt(dynamic v) =>
        v == null ? null : (v is int ? v : int.tryParse(v.toString()));
    DateTime? toDate(dynamic v) =>
        v == null ? null : DateTime.tryParse(v.toString())?.toLocal();

    return JaminanSewaEntity(
      id: toInt(json['id']),
      jmnNo: json['jmnNo']?.toString(),
      locationId: toInt(json['locationId']),
      locationName: json['locationName']?.toString(),
      productId: toInt(json['productId']),
      itemName: json['itemName']?.toString(),
      qty: toDouble(json['qty']),
      amount: toDouble(json['amount']),
      paymentCode: json['paymentCode']?.toString(),
      paymentName: json['paymentName']?.toString(),
      paymentRefNo: json['paymentRefNo']?.toString(),
      customerName: json['customerName']?.toString(),
      customerPhone: json['customerPhone']?.toString(),
      notes: json['notes']?.toString(),
      status: json['status']?.toString(),
      statusLabel: json['statusLabel']?.toString(),
      refundNotes: json['refundNotes']?.toString(),
      createdBy: json['createdBy']?.toString(),
      createdDate: toDate(json['createdDate']),
      updatedBy: json['updatedBy']?.toString(),
      updatedDate: toDate(json['updatedDate']),
      qrUrl: json['qrUrl']?.toString(),
      needsPayment: json['needsPayment'] == true,
    );
  }
}
