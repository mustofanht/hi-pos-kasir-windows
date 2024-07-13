import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:logger/logger.dart';

class AppLogerUtil {
  safeLog(dynamic message) {
    if (kDebugMode) {
      return Logger().d(message);
    } else {
      return null;
    }
  }

  responseLog(dynamic uri, Response response) {
    if (kDebugMode) {
      appLog.w("URI ====> $uri");
      appLog.v("Status Code ====> ${response.statusCode}");
      appLog.d("response ===> ");
      appLog.i(json.decode(response.body));
    }
  }

  responseMultipartLog(
      dynamic uri, StreamedResponse response, String responseData) {
    if (kDebugMode) {
      appLog.w("URI ====> $uri");
      appLog.v("Status Code ====> ${response.statusCode}");
      appLog.d("response ===> ");
      appLog.i(json.decode(responseData));
    }
  }
}

AppLogerUtil logger = new AppLogerUtil();
Logger appLog = new Logger();
