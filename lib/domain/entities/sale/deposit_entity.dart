class DepositEntity {
  int? dpId;
  String? dpName;
  String? dpNoHp;
  String? dpReceiveBy;
  String? dpReffno;
  String? dpState;
  int? dpAmount;
  int? dpLocId;
  DateTime? dpTrxdate;

  DepositEntity({
    this.dpId,
    this.dpName,
    this.dpNoHp,
    this.dpReceiveBy,
    this.dpReffno,
    this.dpState,
    this.dpAmount,
    this.dpLocId,
    this.dpTrxdate,
  });

  DepositEntity.fromJson(Map<String?, dynamic> json) {
    dpId = json['dpId'];
    dpName = json['dpName'];
    dpNoHp = json['dpNoHp'];
    dpReceiveBy = json['dpReceiveBy'];
    dpReffno = json['dpReffno'];
    dpState = json['dpState'];
    dpAmount = json['dpAmount'];
    dpLocId = json['dpLocId'];
    dpTrxdate = json['dpTrxdate'] != null
        ? DateTime.parse(json['dpTrxdate']).toLocal()
        : null;
  }

  Map<String?, dynamic> toJson() {
    return {
      'dpId': dpId,
      'dpName': dpName,
      'dpNoHp': dpNoHp,
      'dpReceiveBy': dpReceiveBy,
      'dpReffno': dpReffno,
      'dpState': dpState,
      'dpAmount': dpAmount,
      'dpLocId': dpLocId,
      'dpTrxdate': dpTrxdate != null ? dpTrxdate!.toIso8601String() : null,
    };
  }
}