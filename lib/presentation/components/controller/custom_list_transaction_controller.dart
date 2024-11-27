import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/domain/entities/transaction/transaction_entity.dart';

class CustomListTransactionController extends GetxController {
  CustomListTransactionController();

  final searchController = TextEditingController();

  final selectedTransaction = Rxn<TransactionEntity>(null);

  final listData = <TransactionEntity>[];

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    for (int i = 1; i <= 10; i++) {
      listData.add(TransactionEntity(
        id: i,
        name: 'Transaksi $i',
        location: 'Lokasi $i',
        duration: 'Durasi $i',
      ));
    }
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  doSelected(TransactionEntity data){
    selectedTransaction.value = data;
  }
}
