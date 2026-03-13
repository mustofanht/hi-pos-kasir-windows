import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

class AppLogerUtil {
  Logger appLog = Logger();

  Future<String> _getLogFilePath() async {
    final directory = await getExternalStorageDirectory();
    final path = '${directory?.path}/Jaya-POS';
    final logFileName =
        '${DateTime.now().toString().split(' ')[0].replaceAll('-', '')}.log';
    final logFilePath = '$path/$logFileName';
    return logFilePath;
  }

  Future<File> _getLogFile() async {
    final filePath = await _getLogFilePath();
    final file = File(filePath);
    if (!await file.exists()) {
      await file.create(recursive: true);
    }
    return file;
  }

  Future<void> _writeLog(String message) async {
    // final file = await _getLogFile();
    // await file.writeAsString(message, mode: FileMode.append, flush: true);
  }

  safeLog(dynamic message) async {
    if (kDebugMode) {
      await _writeLog(message == null ? 'null' : message.toString());
      return Logger().d(message);
    } else {
      return null;
    }
  }

  responseLog(dynamic uri, Response response) async {
    if (kDebugMode) {
      appLog.w("URI ====> $uri");
      appLog.v("Status Code ====> ${response.statusCode}");
      appLog.d("response ===> ");
      appLog.i(json.decode(response.body));

      await _writeLog("URI ====> $uri\n");
      await _writeLog("Status Code ====> ${response.statusCode}\n");
      await _writeLog("response ===> \n");
      await _writeLog("${json.decode(response.body)}\n");
    }
  }

  responseMultipartLog(
      dynamic uri, StreamedResponse response, String responseData) async {
    if (kDebugMode) {
      appLog.w("URI ====> $uri");
      appLog.v("Status Code ====> ${response.statusCode}");
      appLog.d("response ===> ");
      appLog.i(json.decode(responseData));

      await _writeLog("URI ====> $uri\n");
      await _writeLog("Status Code ====> ${response.statusCode}\n");
      await _writeLog("response ===> \n");
      await _writeLog("${json.decode(responseData)}\n");
    }
  }
}

AppLogerUtil logger = new AppLogerUtil();
Logger appLog = new Logger();
