// ignore_for_file: unnecessary_new

import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:intl/intl.dart';

class DateTimeUtil {
  String getFormattedDate({
    required DateTime date,
    required DateFormat format,
    dynamic prefix,
    dynamic suffix,
  }) {
    DateTime newDate = DateTime.parse(date.toIso8601String());

    return format.format(newDate);
  }

  String now({
    DateFormat? format,
  }) {
    DateTime date = DateTime.now();

    if (format != null) {
      return format.format(date);
    } else {
      return date.toIso8601String();
    }
  }

  String getNameOfTime() {
    var date = DateTime.now();

    double newDate =
        double.parse(DateFormat("H.m", constant.locale).format(date));

    if (newDate >= 4 && newDate <= 10) {
      return "Pagi";
    } else if (newDate >= 10 && newDate <= 14) {
      return "Siang";
    } else if (newDate >= 14 && newDate <= 18.30) {
      return "Sore";
    } else if (newDate >= 18.30 || newDate <= 4) {
      return "Malam";
    } else {
      return "";
    }
  }

  String fullFormatted(DateTime date) {
    String newDate = DateFormat("dd MMMM Hyyyy H:mm:ss", constant.locale)
        .format(DateTime.parse(date.toIso8601String()));
    String newDay = DateFormat("EEEE", constant.locale)
        .format(DateTime.parse(date.toIso8601String()));

    String finalDate = "$newDay, $newDate";

    return finalDate;
  }

  String simpleFullFormatted(DateTime date) {
    String newDate = DateFormat("dd MMM yyyy HH:mm:ss", constant.locale)
        .format(DateTime.parse(date.toIso8601String()));
    String newDay = DateFormat("EEEE", constant.locale)
        .format(DateTime.parse(date.toIso8601String()));

    String finalDate = "$newDay, $newDate";

    return finalDate;
  }

  String onlyDateTime(DateTime date) {
    String newDate = DateFormat("dd MMMM yyyy HH:mm:ss", constant.locale)
        .format(DateTime.parse(date.toIso8601String()));

    return newDate;
  }

  String dateWithDay(DateTime date) {
    String newDate = DateFormat("dd MMMM yyyy", constant.locale)
        .format(DateTime.parse(date.toIso8601String()));
    String newDay = DateFormat("EEEE", constant.locale)
        .format(DateTime.parse(date.toIso8601String()));

    String finalDate = "$newDay, $newDate";

    return finalDate;
  }

  String onlyDate(DateTime date) {
    String newDate = DateFormat("dd MMM yyyy", constant.locale)
        .format(DateTime.parse(date.toIso8601String()));

    return newDate;
  }

  String onlyDay(DateTime date) {
    String newDate = DateFormat("dd", constant.locale)
        .format(DateTime.parse(date.toIso8601String()));

    return newDate;
  }

  String onlyMonth(DateTime date) {
    String newDate = DateFormat("MMM", constant.locale)
        .format(DateTime.parse(date.toIso8601String()));

    return newDate;
  }

  String onlyYear(DateTime date) {
    String newDate = DateFormat("yyyy", constant.locale)
        .format(DateTime.parse(date.toIso8601String()));

    return newDate;
  }

  String onlyTime(DateTime date) {
    String newTime = DateFormat("HH:mm:ss", constant.locale)
        .format(DateTime.parse(date.toIso8601String()));

    return newTime;
  }

  String dateFormat(DateTime date, String format) {
    // logger.safeLog("dateeeee $date");
    String newTime = DateFormat(format).format(date);
    // logger.safeLog("newdateeeee $newTime");
    return newTime;
  }

  String getRealTime(DateTime date) {
    // logger.safeLog(date);
    date = DateTime(
      date.year,
      date.month,
      date.day,
      date.hour,
      date.minute,
      date.second,
    );
    String res = "";
    int second = DateTime.now().difference(date).inSeconds;
    int minute = DateTime.now().difference(date).inMinutes;
    int hour = DateTime.now().difference(date).inHours;
    int day = DateTime.now().difference(date).inDays;
    // logger.safeLog("date ==> $date");
    // logger.safeLog("now ==> ${DateTime.now()}");
    // logger.safeLog("second ==> $second");
    // logger.safeLog("minute ==> $minute");
    // logger.safeLog("hour ==> $hour");
    // logger.safeLog("day ==> $day");

    if (second == 0) {
      res = "now";
    }

    if (second > 0 && second <= 59) {
      res = "$second second ago";
    }

    if (minute >= 1 && minute <= 59) {
      res = "$minute minutes ago";
    }

    if (hour >= 1 && hour <= 24) {
      res = "$hour hours ago";
    }

    if (day >= 1 && day <= 30) {
      res = "$day days ago";
    }

    if (day > 30) {
      res = onlyDateTime(date);
    }

    return res;
  }

  DateTime convertToDateTime(String date) {
    if (date.length != 8) {
      throw FormatException("Format tanggal tidak valid");
    }
    int day = int.parse(date.substring(0, 2));
    int month = int.parse(date.substring(2, 4));
    int year = int.parse(date.substring(4, 8));
    DateTime dateTime = DateTime(year, month, day);
    return dateTime;
  }
}

DateTimeUtil dateTimeUtil = new DateTimeUtil();
