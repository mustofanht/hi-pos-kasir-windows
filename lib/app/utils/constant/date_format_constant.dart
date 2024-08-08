// ignore_for_file: unnecessary_new

import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:intl/intl.dart';

class DateFormatConstant {
  final DateFormat onlyDays = DateFormat("EEEE", constant.locale);
  final DateFormat onlyDate = DateFormat("dd-MMM-yyyy", constant.locale);
  final DateFormat onlyTime = DateFormat("HH:mm:ss", constant.locale);
  final DateFormat dateTime =
      DateFormat("dd MMM yyyy HH:mm:ss", constant.locale);
  final DateFormat dateWithoutTime = DateFormat("dd MMM yyyy", constant.locale);
  final DateFormat dateDDMMMMYYYY = DateFormat("dd MMMM yyyy", constant.locale);
  final DateFormat withoutSecond =
      DateFormat("dd-MMM-yyyy HH:mm", constant.locale);
  final DateFormat dateStripedYYYYMMDDHHMMSS =
      DateFormat("yyyy-MM-dd HH:mm:ss", constant.locale);
  final DateFormat fullTimePrinted =
      DateFormat("dd/MM/yyyy HH:mm", constant.locale);
  final DateFormat hourMinutes =
      DateFormat("HH:mm", constant.locale);
  final DateFormat yyyyMMdd =
      DateFormat("yyyy-MM-dd", constant.locale);
}

DateFormatConstant dateFormat = new DateFormatConstant();
