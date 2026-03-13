class TrnDetailOrderCustomer {
  int? custId;
  String? custName;
  String? custPhone;
  String? custEmail;
  DateTime? custUpdatedDate;
  DateTime? custCreatedDate;
  String? custCreatedBy;
  String? custUpdatedBy;

  TrnDetailOrderCustomer({
    this.custId,
    this.custName,
    this.custPhone,
    this.custEmail,
    this.custUpdatedDate,
    this.custCreatedDate,
    this.custCreatedBy,
    this.custUpdatedBy,
  });

  factory TrnDetailOrderCustomer.fromJson(Map<String, dynamic> json) {
    return TrnDetailOrderCustomer(
      custId: json['custId'],
      custName: json['custName'],
      custPhone: json['custPhone'],
      custEmail: json['custEmail'],
      custUpdatedDate: json['custUpdatedDate'] != null
          ? DateTime.parse(json['custUpdatedDate']).toLocal()
          : null,
      custCreatedDate: json['custCreatedDate'] != null
          ? DateTime.parse(json['custCreatedDate']).toLocal()
          : null,
      custCreatedBy: json['custCreatedBy'],
      custUpdatedBy: json['custUpdatedBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'custId': custId,
      'custName': custName,
      'custPhone': custPhone,
      'custEmail': custEmail,
      'custUpdatedDate': custUpdatedDate?.toIso8601String(),
      'custCreatedDate': custCreatedDate?.toIso8601String(),
      'custCreatedBy': custCreatedBy,
      'custUpdatedBy': custUpdatedBy,
    };
  }
}
