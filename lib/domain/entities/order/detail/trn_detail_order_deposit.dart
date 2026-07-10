class TrnDetailOrderDeposit {
  double? depositAmount;
  String? depositName;

  TrnDetailOrderDeposit({
    this.depositAmount,
    this.depositName,
  });

  factory TrnDetailOrderDeposit.fromJson(Map<String, dynamic> json) {
    return TrnDetailOrderDeposit(
      depositAmount: json['depositAmount'] != null
          ? (json['depositAmount'] as num).toDouble()
          : null,
      depositName: json['depositName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'depositAmount': depositAmount,
      'depositName': depositName,
    };
  }
}
