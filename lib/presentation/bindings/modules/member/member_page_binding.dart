import 'package:get/get.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/member/member_page_controller.dart';

class MemberPageBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MemberPageController>(() => MemberPageController());
  }
}
