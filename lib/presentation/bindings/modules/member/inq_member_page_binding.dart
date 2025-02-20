import 'package:get/get.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/member/inq_member_page_controller.dart';

class InqMemberPageBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InqMemberPageController>(() => InqMemberPageController());
  }
}
