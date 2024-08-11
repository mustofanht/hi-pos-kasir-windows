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

  int? getLocationId() {
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
