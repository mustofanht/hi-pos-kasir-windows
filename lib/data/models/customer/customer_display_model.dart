import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';

class CustomerDisplay {
  String? key;
  Map<String, dynamic>? value;

  CustomerDisplay({
    this.key,
    this.value,
  });

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'value': value,
    };
  }

  CustomerDisplay.fromJson(Map<String, dynamic> json) {
    try {
      key = json['key'];

      if (json['value'] is Map<Object?, Object?>) {
        value = common.convertToMapStringDynamic(json['value']);
      } else {
        value = json['value'];
      }
    } catch (e) {
      logger.safeLog('Error $e');
    }
  }
}
