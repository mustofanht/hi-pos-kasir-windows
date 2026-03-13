import 'package:flutter/widgets.dart';

class CustomTableData {
  String? id;
  String? columnName;
  double? width;
  AlignmentGeometry? alignment;
  String? defaultValue;

  CustomTableData({
    this.id,
    this.columnName,
    this.width,
    this.alignment,
    this.defaultValue,
  });
}
