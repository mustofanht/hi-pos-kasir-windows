class UserEntity {
  String? userName;
  String? userFullName;
  DateTime? userStartDate;
  DateTime? userEndDate;
  String? userDescription;
  DateTime? userLastLogon;
  String? userLastPassword;
  String? userPassNeedChg;
  String? userEnableSts;
  int? userLocId;
  String? locationName;
  int? userUnitId;
  String? unitName;
  int? userRoleid;
  String? roleName;
  String? userPhone;
  String? userEmail;
  DateTime? userLastLogout;

  UserEntity({
    this.userName,
    this.userFullName,
    this.userStartDate,
    this.userEndDate,
    this.userDescription,
    this.userLastLogon,
    this.userLastPassword,
    this.userPassNeedChg,
    this.userEnableSts,
    this.userLocId,
    this.locationName,
    this.userUnitId,
    this.unitName,
    this.userRoleid,
    this.roleName,
    this.userPhone,
    this.userEmail,
    this.userLastLogout,
  });

  UserEntity.empty();

  UserEntity.fromJson(Map<String, dynamic> json) {
    userName = json['userName'];
    userFullName = json['userFullName'];
    userStartDate = json['userStartDate'] != null
        ? DateTime.parse(json['userStartDate']).toLocal()
        : null;
    userEndDate = json['userEndDate'] != null
        ? DateTime.parse(json['userEndDate']).toLocal()
        : null;
    userDescription = json['userDescription'];
    userLastLogon = json['userLastLogon'] != null
        ? DateTime.parse(json['userLastLogon']).toLocal()
        : null;
    userLastPassword = json['userLastPassword'];
    userPassNeedChg = json['userPassNeedChg'];
    userEnableSts = json['userEnableSts'];
    userLocId = json['userLocId'];
    locationName = json['locationName'];
    userUnitId = json['userUnitId'];
    unitName = json['unitName'];
    userRoleid = json['userRoleid'];
    roleName = json['roleName'];
    userPhone = json['userPhone'];
    userEmail = json['userEmail'];
    userLastLogout = json['userLastLogout'] != null
        ? DateTime.parse(json['userLastLogout']).toLocal()
        : null;
  }
}
