import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

part 'color_style.dart';
part 'text_tyle.dart';
part 'layout_style.dart';
part 'font_size_style.dart';
part 'font_wight_style.dart';
part 'font_style.dart';

class AppTheme {
  ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: Colors.amber,
    );
  }

  ThemeData light() {
    return ThemeData.light().copyWith(
      primaryColor: colorStyle.dark_blue,
      colorScheme: ColorScheme.light(
        primary: colorStyle.dark_blue,
        secondary: colorStyle.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorStyle.dark_blue,
        foregroundColor: colorStyle.black,
      ),
    );
  }
}

AppTheme theme = new AppTheme();
