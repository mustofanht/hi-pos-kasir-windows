import 'package:jaya_propertiy/app/utils/translation/languages/languages.dart';
import 'package:get/get.dart';

class AppTranslation extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': languages.enUS,
        'id_ID': languages.idID,
      };
}
