
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingPageController extends GetxController with SingleGetTickerProviderMixin {
  SettingPageController();
  
  TabController? tabController;
  var tabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 4, vsync: this);
    tabController!.addListener(_handleTabSelection);
  }

  @override
  void dispose() {
    tabController?.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (!tabController!.indexIsChanging) {
      changeTabIndex(tabController!.index);
    }
  }
  void changeTabIndex(int index) {
    tabIndex.value = index;
  }
}
