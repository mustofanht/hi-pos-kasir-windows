class UserEntity {
  String? userId;
  String? userName;
  DateTime? userStartDate;
  DateTime? userEndDate;
  String? userDescription;
  DateTime? userLastLogon;
  String? userLastPassword;
  String? userPassNeedChg;
  String? userEnableSts;
  int? userUnit;
  int? userRoleid;
  String? userPhone;
  String? userEmail;
  DateTime? userLastLogout;

  UserEntity({
    this.userId,
    this.userName,
    this.userStartDate,
    this.userEndDate,
    this.userDescription,
    this.userLastLogon,
    this.userLastPassword,
    this.userPassNeedChg,
    this.userEnableSts,
    this.userUnit,
    this.userRoleid,
    this.userPhone,
    this.userEmail,
    this.userLastLogout,
  });

  UserEntity.empty();

  UserEntity.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    userName = json['userName'];
    userStartDate = json['userStartDate'] != null
        ? DateTime.parse(json['userStartDate']).toLocal()
        : null;
    userEndDate = json['userEndDate'] != null
        ? DateTime.parse(json['userEndDate']).toLocal()
        : null;
    // userStartDate = json['userStartDate'];
    // userEndDate = json['userEndDate'];
    userDescription = json['userDescription'];
    userLastLogon = json['userLastLogon'] != null
        ? DateTime.parse(json['userLastLogon']).toLocal()
        : null;
    // userLastLogon = json['userLastLogon'];
    userLastPassword = json['userLastPassword'];
    userPassNeedChg = json['userPassNeedChg'];
    userEnableSts = json['userEnableSts'];
    userUnit = json['userUnit'];
    userRoleid = json['userRoleid'];
    userPhone = json['userPhone'];
    userEmail = json['userEmail'];
    userLastLogout = json['userLastLogout'] != null
        ? DateTime.parse(json['userLastLogout']).toLocal()
        : null;
    // userLastLogout = json['userLastLogout'];
  }
}
