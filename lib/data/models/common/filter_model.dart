import 'package:jaya_propertiy/app/utils/constant/filter_constant.dart';

class FilterQuery {
  Connectors? connector;
  String? field;
  String? operator;
  String? operator2;
  dynamic value;
  List<FilterQuery>? group;

  FilterQuery({
    this.connector,
    this.field,
    this.operator,
    this.operator2,
    this.value,
    this.group,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['connector'] = this.connector;
    data['field'] = this.field;
    data['operator'] = this.operator;
    data['operator2'] = this.operator2;
    data['value'] = this.value;
    data['group'] =
        this.group != null ? this.group!.map((e) => e.toJson()).toList() : [];
    return data;
  }
}
