import 'package:get/get.dart';

class PrintTicketPageController extends GetxController {
  PrintTicketPageController();

  final columns = ["Column1", "Column2", "Column3"];
  List<bool> selectedRows = List<bool>.generate(100, (index) => false);

  void selectAll(bool? checked) {
    if (checked == null) return;

    for (int i = 0; i < selectedRows.length; i++) {
      selectedRows[i] = checked;
    }
  }

  selectData(bool? selected, int index) {
    selectedRows[index] = selected ?? false;
    update();
  }
}
