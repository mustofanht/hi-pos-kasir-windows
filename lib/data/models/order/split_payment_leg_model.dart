/// Satu metode bayar dalam transaksi split payment (kasir), misal setengah
/// QRIS setengah cash — lihat [OrderModel.splitPayments].
///
/// Dipakai dua arah: saat DIKIRIM ke backend hanya [paymentCode], [amount],
/// [reffno] yang terisi; saat DITERIMA balik lewat ResponseOrderEntity,
/// backend mengisi [paymentNo]/[pymntStatus]/[qrisUrl] juga (reffno/amount
/// yang dikirim balik tidak dipakai, cukup field barunya).
class SplitPaymentLegModel {
  String? paymentCode;
  double? amount;

  /// Wajib untuk metode selain QRIS/VA — sama aturan dengan pembayaran tunggal.
  String? reffno;

  /// Nama metode untuk struk — diisi client-side (mst_payment.pymntName) saat
  /// konstruksi request, TIDAK dikirim ke backend (lihat [toJson]).
  String? paymentName;

  // ── Hanya terisi di response ─────────────────────────────────────────
  String? paymentNo;
  String? pymntStatus;
  String? qrisUrl;

  SplitPaymentLegModel({
    this.paymentCode,
    this.amount,
    this.reffno,
    this.paymentNo,
    this.pymntStatus,
    this.qrisUrl,
    this.paymentName,
  });

  factory SplitPaymentLegModel.fromJson(Map<String, dynamic> json) {
    return SplitPaymentLegModel(
      paymentCode: json['paymentCode'],
      amount: json['amount'] != null ? (json['amount'] as num).toDouble() : null,
      pymntStatus: json['pymntStatus'],
      qrisUrl: json['qrisUrl'],
      paymentNo: json['paymentNo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "paymentCode": paymentCode,
      "amount": amount,
      "reffno": reffno,
    };
  }
}
