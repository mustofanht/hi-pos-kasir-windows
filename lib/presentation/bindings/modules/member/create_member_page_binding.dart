import 'package:get/get.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/member/create_member_page_controller.dart';

class CreateMemberPageBinding implements Bindings {
@override
void dependencies() {
  Get.lazyPut<CreateMemberPageController>(() => CreateMemberPageController());
  }
}