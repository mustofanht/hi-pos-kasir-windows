// ignore_for_file: non_constant_identifier_names, unnecessary_new, constant_identifier_names, dead_code

import 'package:table_calendar/table_calendar.dart';

class AppStringConstant {
  final String authentication = "authentication";
  final String locale = "id_ID";
  final String none = "None";
  final String all = "All";
  final String sessionInformation = "session_information";
  final String pathImages = "assets/images/";
  final String pathImagesSvg = "assets/images/svg/";
  final String pathIcons = "assets/icons/";
  final String pathIconsSvg = "assets/icons/svg/";
  final String pathTranslations = "assets/translations/";
  final bool testingMode = true;
}

class ArgumentsConstant {
  final String authToken = "token";
  final String username = "username";
}

enum DateTimePickerType {
  Default,
  OnlyYear,
}

enum DocumentSource {
  camera,
  document,
}

class AppRequestContentType {
  final String applicationOctetStream = "application/octet-stream";
}

extension CalendarFormatExt on CalendarFormat {
  String get name {
    switch (this) {
      case CalendarFormat.month:
        return "Month";
        break;
      case CalendarFormat.week:
        return "Week";
        break;
      case CalendarFormat.twoWeeks:
        return "2 Weeks";
        break;
      default:
        return "";
    }
  }
}

class UnitType {
  static String PERCENT = 'PERCENTAGE';
  static String PRICE = 'PRICE';
}

class CustomerDisplayAction {
  static String ADD_CART = 'add-cart';
  static String PAYMENT = 'payment';
}

class PaymentMethod {
  static String QRIS = 'QR';
  static String EDC = 'ED';
  static String TRAVELOKA = 'TR';
  static String TICKET = 'TC'; // Ticket.Com
}

final Map<String, String> MapPaymentMethod = {
  PaymentMethod.QRIS: 'QRIS',
  PaymentMethod.EDC: 'EDC',
  PaymentMethod.TRAVELOKA: 'TRAVELOKA',
  PaymentMethod.TICKET: 'TICKET',
};

class PaymentStatus {
  static String Pending = '01';
  static String Success = '02';
}

AppStringConstant constant = new AppStringConstant();
ArgumentsConstant argConstant = new ArgumentsConstant();
AppRequestContentType contentType = new AppRequestContentType();
