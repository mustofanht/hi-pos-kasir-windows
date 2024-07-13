class ProofOfPaymentModel {
  final String? id;
  final String? transactionId;
  final String? paymentMethod;
  final String? paymentDate;
  final String? amount;
  final String? status;
  final String? paymentType;

  ProofOfPaymentModel({
    this.id,
    this.transactionId,
    this.paymentMethod,
    this.paymentDate,
    this.amount,
    this.status,
    this.paymentType,
  });

  factory ProofOfPaymentModel.fromJson(Map<String?, dynamic> json) {
    return ProofOfPaymentModel(
      id: json['id'],
      transactionId: json['transactionId'],
      paymentMethod: json['paymentMethod'],
      paymentDate: json['paymentDate'],
      amount: json['amount'],
      status: json['status'],
      paymentType: json['paymentType'],
    );
  }
}
