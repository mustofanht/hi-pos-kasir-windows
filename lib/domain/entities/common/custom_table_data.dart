import 'package:flutter/widgets.dart';

class CustomTableData {
  String? id;
  String? columnName;
  Widget? data;
  AlignmentGeometry? alignment;

  CustomTableData({
    this.id,
    this.columnName,
    this.data,
    this.alignment,
  });

  CustomTableData.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? "";
    columnName = json['columnName'] ?? "";
    data = json['data'];
    alignment = json['alignment'];
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "columnName": columnName,
      "data": data,
      "alignment": alignment,
    };
  }
}
