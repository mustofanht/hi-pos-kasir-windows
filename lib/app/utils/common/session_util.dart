import 'dart:convert';

import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/data/models/auth/sign_in_model.dart';
import 'package:jaya_propertiy/domain/entities/auth/auth_token.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AppSessionUtil {
  static final GetStorage _store = GetStorage("sessions");

  save(SignInModel r) {
    _store.write(constant.sessionInformation, r.toJson());
  }

  clear() async {
    await _store.erase();
  }

  bool isActive() {
    // return true;
    return _store.read(constant.sessionInformation) != null;
  }

  SignInModel getSession() {
    Map<String, dynamic> data = _store.read(constant.sessionInformation);
    return SignInModel.fromJson(data);
  }

  updateToken(AuthToken authToken) {
    if (_store.read(constant.authentication) != null) {
      _store.remove(constant.authentication);
    }

    // Hanya dipanggil saat login, jadi aman membuang pilihan lokasi di sini:
    // tanpa ini, lokasi aktif milik user sebelumnya terbawa ke user yang baru
    // masuk di perangkat yang sama.
    _store.remove(constant.activeLocation);

    logger.safeLog(
        'JWT updateToken : ${JwtDecoder.decode(authToken.token ?? "")}');
    _store.write(constant.authentication, authToken.toJson());
  }

  String getUserName() {
    String name = "";
    try {
      Map<String, dynamic> data = _store.read(constant.authentication);
      AuthToken authToken = AuthToken.fromJson(data);

      logger.safeLog(
          'JWT getUserName : ${JwtDecoder.decode(authToken.token ?? "")}');

      name = JwtDecoder.decode(authToken.token ?? "")['sub'];
    } catch (e) {
      logger.safeLog(e);
    }
    return name;
  }

  int? getUnitId() {
    int? unitId = null;
    try {
      Map<String, dynamic> data = _store.read(constant.authentication);
      AuthToken authToken = AuthToken.fromJson(data);

      logger.safeLog(
          'JWT getUnitId : ${JwtDecoder.decode(authToken.token ?? "")}');

      unitId = JwtDecoder.decode(authToken.token ?? "")['user']['unitId'];
    } catch (e) {
      logger.safeLog(e);
    }
    return unitId;
  }

  /// Lokasi yang dipakai seluruh pemanggilan API.
  ///
  /// Ini satu-satunya sumber lokasi di aplikasi — 12 pemanggil di berbagai
  /// modul semuanya lewat sini. Karena itu dukungan multi-lokasi cukup
  /// diterapkan dengan mengganti isi fungsi ini, tanpa menyentuh pemanggilnya
  /// satu per satu.
  ///
  /// Urutannya: lokasi aktif pilihan kasir bila ada dan sah, selain itu
  /// lokasi utama dari token.
  int? getLocationId() {
    return getActiveLocationId() ?? getDefaultLocationId();
  }

  /// Lokasi utama (`locId`) dari token — perilaku aplikasi sebelum ada
  /// konsep lokasi aktif.
  int? getDefaultLocationId() {
    int? unitId = null;
    try {
      Map<String, dynamic> data = _store.read(constant.authentication);
      AuthToken authToken = AuthToken.fromJson(data);

      logger.safeLog(
          'JWT getLocationId : ${JwtDecoder.decode(authToken.token ?? "")}');

      unitId = JwtDecoder.decode(authToken.token ?? "")['user']['locId'];
    } catch (e) {
      logger.safeLog(e);
    }
    return unitId;
  }

  /// Apakah user yang login berwenang menyetujui (mis. keluar manual).
  ///
  /// Dibaca dari klaim JWT, bukan ditebak dari nama role: daftar nama role bisa
  /// berubah kapan saja lewat halaman Data Roles, sedangkan flag ini memang
  /// dibuat untuk menandai kewenangan itu. Super admin selalu berwenang.
  ///
  /// Server tetap memeriksa hal yang sama saat permintaan disetujui — pemeriksaan
  /// di sini hanya untuk menyembunyikan tombol yang pasti ditolak, supaya tidak
  /// ada yang menekannya di depan pelanggan lalu mendapat penolakan.
  bool isVerificator() {
    try {
      Map<String, dynamic> data = _store.read(constant.authentication);
      AuthToken authToken = AuthToken.fromJson(data);
      final user = JwtDecoder.decode(authToken.token ?? "")['user'];
      if (user == null) return false;
      final superAdmin = user['isSuperAdmin'];
      if (superAdmin is String && superAdmin.toUpperCase() == 'Y') return true;
      if (superAdmin is bool && superAdmin) return true;
      return user['isVerificator'] == true;
    } catch (e) {
      logger.safeLog(e);
      // Ragu berarti tidak berwenang: menyembunyikan tombol yang seharusnya ada
      // hanya merepotkan, menampilkan tombol yang seharusnya tidak ada memberi
      // kesan wewenang yang tidak dimiliki.
      return false;
    }
  }

  /// Seluruh lokasi yang boleh diakses user (`locIds`).
  ///
  /// Daftar kosong berarti tanpa pembatasan — bukan berarti user tidak punya
  /// lokasi. Perbedaan ini menentukan arti kembalian [isLocationAllowed].
  List<int> getAllowedLocationIdList() {
    List<int> locationIdList = [];
    try {
      Map<String, dynamic> data = _store.read(constant.authentication);
      AuthToken authToken = AuthToken.fromJson(data);

      final dynamic claim =
          JwtDecoder.decode(authToken.token ?? "")['user']['locIds'];
      if (claim is List) {
        for (final dynamic item in claim) {
          final int? value = item is int ? item : int.tryParse('$item');
          if (value != null) {
            locationIdList.add(value);
          }
        }
      }
    } catch (e) {
      logger.safeLog(e);
    }
    return locationIdList;
  }

  bool isLocationAllowed(int locationId) {
    final List<int> allowed = getAllowedLocationIdList();
    // Daftar kosong = tanpa pembatasan, jadi lokasi mana pun sah.
    return allowed.isEmpty || allowed.contains(locationId);
  }

  /// Daftar lokasi yang dikirim ke endpoint pembacaan multi-lokasi (kasir).
  ///
  /// Untuk menampilkan data seluruh lokasi milik user sekaligus, kirim daftar
  /// dari klaim `locIds`. Bila user tidak dibatasi (`locIds` kosong), aplikasi
  /// tidak dapat menyebut "semua lokasi" satu per satu, jadi jatuh ke lokasi
  /// utama saja. Backend tetap memotong daftar ini terhadap hak akses user
  /// (lihat BACKEND_MULTI_LOKASI.md bagian 5).
  List<int> getLocationIdListForQuery() {
    final List<int> allowed = getAllowedLocationIdList();
    if (allowed.isNotEmpty) return allowed;
    final int? fallback = getDefaultLocationId();
    return fallback != null ? [fallback] : [];
  }

  /// Bentuk siap-kirim daftar lokasi sebagai satu query param, mis. `"1,2,5"`.
  ///
  /// Backend (`List<Integer> locationId`) menerima format koma ini. Untuk user
  /// satu lokasi hasilnya sama seperti sebelumnya (`"5"`), jadi aman dipakai
  /// menggantikan pengiriman lokasi tunggal pada endpoint query-param.
  String getLocationIdsQueryParam() {
    return getLocationIdListForQuery().join(",");
  }

  /// Lokasi aktif yang dipilih kasir, atau null bila belum memilih.
  ///
  /// Pilihan yang tidak lagi sah — misalnya hak akses user dicabut sejak
  /// terakhir memilih — sengaja diabaikan dan ikut dibersihkan, supaya
  /// aplikasi jatuh kembali ke lokasi utama alih-alih memakai lokasi
  /// terlarang secara diam-diam.
  int? getActiveLocationId() {
    try {
      final dynamic stored = _store.read(constant.activeLocation);
      if (stored == null) return null;

      final int? locationId =
          stored is int ? stored : int.tryParse('$stored');
      if (locationId == null) return null;

      if (!isLocationAllowed(locationId)) {
        _store.remove(constant.activeLocation);
        return null;
      }
      return locationId;
    } catch (e) {
      logger.safeLog(e);
      return null;
    }
  }

  void setActiveLocationId(int? locationId) {
    if (locationId == null) {
      _store.remove(constant.activeLocation);
      return;
    }
    if (!isLocationAllowed(locationId)) {
      logger.safeLog('Lokasi $locationId di luar hak akses user, diabaikan.');
      return;
    }
    _store.write(constant.activeLocation, locationId);
  }

  int? getRoleId() {
    int? roleId = null;
    try {
      Map<String, dynamic> data = _store.read(constant.authentication);
      AuthToken authToken = AuthToken.fromJson(data);

      logger.safeLog(
          'JWT getRoleId : ${JwtDecoder.decode(authToken.token ?? "")}');

      roleId = JwtDecoder.decode(authToken.token ?? "")['user']['roleId'];
    } catch (e) {
      logger.safeLog(e);
    }
    return roleId;
  }

  AuthToken getToken() {
    Map<String, dynamic> data = _store.read(constant.authentication);
    return AuthToken.fromJson(data);
  }

  bool isAvailableInList(String userIds) {
    List usersId = json.decode(userIds);
    List<String> users = usersId.map((e) => e.toString()).toList();
    Map<String, dynamic> data = _store.read(constant.authentication);
    AuthToken authToken = AuthToken.fromJson(data);

    String uid = JwtDecoder.decode(authToken.token ?? "")['user_id'];

    if (users.contains(uid)) {
      return true;
    } else {
      return false;
    }
  }
}

AppSessionUtil sessionUtil = new AppSessionUtil();
