import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/domain/entities/auth/auth_token.dart';
import 'package:intl/intl.dart';

class AppCommon {
  String randomString(int length) {
    const chars =
        "AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890";

    Random random = Random();

    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(
          random.nextInt(chars.length),
        ),
      ),
    );
  }

  String setMaxLength({required String data, required int length}) {
    String result = "";

    if (data.length > length) {
      result = "${data.substring(0, length - 1)}...";
    } else {
      result = data;
    }

    return result;
  }

  String getMetadataMessages(String jsonData) {
    String messages = "";
    if (jsonData.isNotEmpty) {
      if (json.decode(jsonData)["message"].runtimeType == List) {
        messages = json.decode(jsonData)["message"].first;
      } else {
        messages = json.decode(jsonData)["message"];
      }
    } else {
      messages = "gagal ambil data!";
    }
    return messages;
  }

  Map<String, String> generateHeader({
    AuthToken? sessionToken,
    String? contentType,
  }) {
    if (sessionToken != null) {
      return {
        "Authorization": "Bearer ${sessionToken.token}",
        "Accept": "application/json",
        "Content-Type":
            (contentType != null) ? contentType : "application/json",
      };
    } else {
      return {
        "Accept": "application/json",
        "Content-Type":
            (contentType != null) ? contentType : "application/json",
      };
    }
  }

  String maxLengthFileName({required String value, required int maxCount}) {
    if (value.length > maxCount) {
      String finalName = "";
      String ext = ".${value.split(".").last}";
      finalName = "${value.substring(0, maxCount - 1)}... $ext";

      return finalName;
    } else {
      return value;
    }
  }

  String generateNameImage() {
    return 'IMG-${DateFormat("yyyyMMddHHmmss").format(DateTime.now())}';
  }

  bool isNullOrEmpty(dynamic data) {
    // logger.safeLog("$data is ${data.runtimeType}");
    bool isEmpty = false;

    if (data == null) {
      isEmpty = true;
    }

    if (data.runtimeType == List) {
      if (!isEmpty && data != null && data.isEmpty) {
        isEmpty = true;
      }

      if (!isEmpty && data == []) {
        isEmpty = true;
      }
    }

    // if (data.runtimeType == Map) {
    //   if (data.isEmpty) {
    //     isEmpty = true;
    //   }

    //   if (data == {}) {
    //     isEmpty = true;
    //   }
    // }

    if (data.runtimeType == String) {
      if (data.isEmpty) {
        isEmpty = true;
      }

      if (!isEmpty && data == "") {
        isEmpty = true;
      }

      if (!isEmpty && data == "-") {
        isEmpty = true;
      }
    }

    // logger.safeLog(isEmpty);

    return isEmpty;
  }

  Widget generateAvatar({required String name, double? fs}) {
    if (name.contains(" ")) {
      var splitName = name.toUpperCase().split(" ");
      return CircleAvatar(
        child: Text(
          splitName[0][0] + splitName[1][0],
          style: GoogleFonts.poppins(
            fontSize: fs ?? fontSize.title,
            fontWeight: fontWeight.bold,
          ),
        ),
      );
    } else {
      return CircleAvatar(
        child: Text(
          name.toUpperCase()[0] + name.toUpperCase()[1],
          style: GoogleFonts.poppins(
            fontSize: fs ?? fontSize.title,
            fontWeight: fontWeight.bold,
          ),
        ),
      );
    }
  }

  String currencyFormat(double value) {
    String result = "";

    try {
      var format = NumberFormat("###,###,###,###", "id_ID");

      result = format.format(value);
    } catch (e) {
      logger.safeLog(e);
    }

    return result;
  }

  List<T> fromJsonList<T>(
      List<dynamic> jsonList, T Function(dynamic) fromJsonT) {
    return jsonList.map((e) => fromJsonT(e)).toList();
  }

  Map<String, dynamic> convertToMapStringDynamic(
      Map<Object?, Object?> original) {
    return original.map((key, value) => MapEntry(key.toString(), value));
  }
}

AppCommon common = new AppCommon();
