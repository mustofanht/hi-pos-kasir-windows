import 'dart:io';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jaya_propertiy/app/utils/common/local_storage_util.dart';

class SettingPageController extends GetxController {
  SettingPageController();

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    loadImages();
  }

  final ImagePicker _picker = ImagePicker();
  List<File> images = [];

  Future<void> pickImage() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      images.addAll(
          pickedFiles.map((pickedFile) => File(pickedFile.path)).toList());
      update();
    }
  }

  void loadImages() {
    localStorage.getSavedImages().then((List<File> val) {
      images.addAll(val);
    });
    update();
  }
}
