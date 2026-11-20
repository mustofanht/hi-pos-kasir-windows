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

  /// Alamat, telepon, email, dan logo lokasi utama user, untuk kepala struk.
  /// Tidak dikirim endpoint `users/{id}`; diisi [AppCommon.getUser] dari
  /// master lokasi.
  String? locationAddress;
  String? locationPhone;
  String? locationEmail;
  String? locationLogoPath;

  /// Jenis kode nomor tiket di struk kertas dan di gelang playground, dari
  /// master lokasi: `QR` atau `BARCODE` (CODE128). Selalu salah satu; kosong
  /// (server lama, atau lokasi gagal dimuat) dianggap QR.
  String? locationTicketCodeType;
  String? locationWristbandCodeType;

  bool get tiketPakaiBarcode =>
      (locationTicketCodeType ?? '').trim().toUpperCase() == 'BARCODE';
  bool get gelangPakaiBarcode =>
      (locationWristbandCodeType ?? '').trim().toUpperCase() == 'BARCODE';
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
    this.locationAddress,
    this.locationPhone,
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
    locationAddress = json['locationAddress'];
    locationPhone = json['locationPhone'];
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
