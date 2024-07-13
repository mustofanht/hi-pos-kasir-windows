import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';

class AppAssetConstant {
  final String appLogo = "${constant.pathImages}";
  final String imgLogoSvg = "${constant.pathImagesSvg}img-logo.svg";
  final String imgLogo = "${constant.pathImages}img-logo.png";

  // Icons
  final String icUser = "${constant.pathIcons}ic-user.png";
  final String icEmail = "${constant.pathIcons}ic-user.png";
  final String icInputCalendar = "${constant.pathIcons}ic-input-calendar.png";
  final String icInformationDialog =
      "${constant.pathIcons}ic-information-dialog.png";
  final String icPlus = "${constant.pathIcons}ic-plus.png";
  final String icMinus = "${constant.pathIcons}ic-minus.png";
  final String icDelete = "${constant.pathIcons}ic-delete.png";
  final String icQris = "${constant.pathIcons}ic-qris.png";
  final String icQrisSVg = "${constant.pathIconsSvg}ic-qris.svg";
  final String icPaymentSuccess =
      "${constant.pathIconsSvg}ic-payment-success.svg";

  final String imgEdc = "${constant.pathImages}edc-img.png";
  final String imgUnderConstruction =
      "${constant.pathImages}under-construction.png";
  final String imgExampleBarcode = "${constant.pathImages}example-barcode.png";
}

AppAssetConstant assetsConstant = new AppAssetConstant();
