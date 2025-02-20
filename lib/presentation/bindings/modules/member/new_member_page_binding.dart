import 'package:get/get.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/member/new_member_page_controller.dart';

class NewMemberPageBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NewMemberPageController>(() => NewMemberPageController());
  }
}
