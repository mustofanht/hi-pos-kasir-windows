class MemberCard {
  int? cardLocId;
  String? cardNo;
  String? cardName;
  String? membName;
  DateTime? expiredDate;
  String? status;
  int? cardKuota;
  String? regResetPeriod;
  String? resetPeriodName;
  DateTime? cardCreatedDate;
  String? membState;

  MemberCard({
    this.cardLocId,
    this.cardNo,
    this.cardName,
    this.membName,
    this.expiredDate,
    this.status,
    this.cardKuota,
    this.regResetPeriod,
    this.resetPeriodName,
    this.cardCreatedDate,
    this.membState,
  });

  factory MemberCard.fromJson(Map<String, dynamic> json) {
    return MemberCard(
      cardLocId: json['cardLocId'],
      cardNo: json['cardNo'],
      cardName: json['cardName'],
      membName: json['membName'],
      expiredDate: json['expiredDate'] != null
          ? DateTime.parse(json['expiredDate']).toLocal()
          : null,
      status: json['status'],
      cardKuota: json['cardKuota'],
      regResetPeriod: json['regResetPeriod'],
      resetPeriodName: json['resetPeriodName'],
      cardCreatedDate: json['cardCreatedDate'] != null
          ? DateTime.parse(json['cardCreatedDate']).toLocal()
          : null,
      membState: json['membState'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cardLocId': cardLocId,
      'cardNo': cardNo,
      'cardName': cardName,
      'membName': membName,
      'expiredDate': expiredDate?.toIso8601String(),
      'status': status,
      'cardKuota': cardKuota,
      'regResetPeriod': regResetPeriod,
      'resetPeriodName': resetPeriodName,
      'cardCreatedDate': cardCreatedDate?.toIso8601String(),
      'membState': membState,
    };
  }
}
