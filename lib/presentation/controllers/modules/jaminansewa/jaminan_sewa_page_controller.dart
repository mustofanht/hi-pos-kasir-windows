import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/app/utils/common/generate_jaminan_sewa_print_util.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/common/printer_util.dart';
import 'package:jaya_propertiy/app/utils/common/session_util.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/data/services/main_service.dart';
import 'package:jaya_propertiy/domain/entities/auth/user_entity.dart';
import 'package:jaya_propertiy/domain/entities/jaminansewa/jaminan_sewa_entity.dart';
import 'package:jaya_propertiy/domain/entities/sale/addon_entity.dart';
import 'package:jaya_propertiy/presentation/components/custom_alert.dart';
import 'package:jaya_propertiy/presentation/components/custom_dialog.dart';

/// Tipe mst_product yang dianggap "item sewa" untuk jaminan (syspos
/// FPConstants.TYPE_PRODUCT): S = Sewa Harian, H = Sewa Perjam.
const _tipeItemSewa = {'S', 'H'};

class JaminanSewaPageController extends GetxController {
  JaminanSewaPageController();

  final _service = MainService();
  final _authToken = Get.arguments[argConstant.authToken];

  final user = Rxn<UserEntity>();
  int? get _locationId => sessionUtil.getLocationId();

  // ===================================================================
  // Tab 1: Terima Jaminan (cash-in)
  // ===================================================================
  final itemSewaList = <AddonEntity>[].obs;
  final isLoadingItem = false.obs;
  final selectedItem = Rxn<AddonEntity>();

  final qtyController = TextEditingController(text: '1');
  final amountController = TextEditingController();
  final customerNameController = TextEditingController();
  final customerPhoneController = TextEditingController();
  final notesController = TextEditingController();
  final isSubmittingTerima = false.obs;

  // ===================================================================
  // Tab 2: Pengembalian (cash-out)
  // ===================================================================
  final searchController = TextEditingController();
  final outstandingList = <JaminanSewaEntity>[].obs;
  final isLoadingOutstanding = false.obs;
  final selectedJaminan = Rxn<JaminanSewaEntity>();
  final refundNotesController = TextEditingController();
  final isSubmittingRefund = false.obs;

  @override
  void onInit() {
    super.onInit();
    _muatUser();
    loadItemSewa();
    loadOutstanding();
  }

  @override
  void onClose() {
    qtyController.dispose();
    amountController.dispose();
    customerNameController.dispose();
    customerPhoneController.dispose();
    notesController.dispose();
    searchController.dispose();
    refundNotesController.dispose();
    super.onClose();
  }

  Future<void> _muatUser() async {
    try {
      user.value = await common.getUser(authToken: _authToken);
    } catch (e) {
      logger.safeLog(e);
    }
  }

  // ===================================================================
  // Terima Jaminan
  // ===================================================================

  Future<void> loadItemSewa() async {
    final locationId = _locationId;
    if (locationId == null) return;
    isLoadingItem.value = true;
    try {
      final result = await _service.sale.addonService.getAll(
        authToken: _authToken,
        paramsFilter: {
          'page': '0',
          'size': '200',
          'flMobile': 'Y',
          'locationId': locationId.toString(),
        },
      );
      result.fold(
        (l) => logger.safeLog(l),
        (r) {
          itemSewaList.value = (r.data ?? [])
              .where((e) =>
                  _tipeItemSewa.contains(e.productType) &&
                  e.productState != 'N')
              .toList();
        },
      );
    } catch (e) {
      logger.safeLog(e);
    }
    isLoadingItem.value = false;
    update();
  }

  void pilihItem(AddonEntity? item) {
    selectedItem.value = item;
    update();
  }

  Future<void> submitTerima() async {
    final locationId = _locationId;
    final item = selectedItem.value;
    if (locationId == null) {
      alert.error('Error', 'Lokasi kasir tidak dikenali.');
      return;
    }
    if (item?.productId == null) {
      alert.warning('Perhatian', 'Pilih item sewa dulu.');
      return;
    }
    final qty = double.tryParse(qtyController.text.trim()) ?? 0;
    if (qty <= 0) {
      alert.warning('Perhatian', 'Qty harus lebih dari 0.');
      return;
    }
    final amount =
        double.tryParse(amountController.text.replaceAll('.', '').trim()) ??
            0;
    if (amount <= 0) {
      alert.warning('Perhatian', 'Nominal jaminan harus lebih dari 0.');
      return;
    }

    isSubmittingTerima.value = true;
    update();
    try {
      final result = await _service.jaminanSewa.terima(
        authToken: _authToken,
        locationId: locationId,
        productId: item!.productId!,
        qty: qty,
        amount: amount,
        customerName: customerNameController.text,
        customerPhone: customerPhoneController.text,
        notes: notesController.text,
      );
      await result.fold(
        (l) async {
          alert.error('Gagal', l);
        },
        (r) async {
          await _cetakStrukTerima(r);
          _resetFormTerima();
          alert.success('Berhasil', 'Jaminan ${r.jmnNo} diterima.');
          loadOutstanding();
        },
      );
    } catch (e) {
      logger.safeLog(e);
      alert.error('Error', 'Terjadi kesalahan, silakan hubungi admin.');
    }
    isSubmittingTerima.value = false;
    update();
  }

  void _resetFormTerima() {
    selectedItem.value = null;
    qtyController.text = '1';
    amountController.clear();
    customerNameController.clear();
    customerPhoneController.clear();
    notesController.clear();
  }

  Future<void> _cetakStrukTerima(JaminanSewaEntity data) async {
    if (printerUtil.currPrinter == null) {
      alert.warning('Printer',
          'Jaminan sudah tersimpan (${data.jmnNo}), tapi printer belum terhubung. Sambungkan printer lalu cetak ulang dari layar Pengembalian.');
      return;
    }
    try {
      final bytes = await generateJaminanSewaPrintUtil.dataTerimaJaminanPrint(
        locationName: user.value?.locationName,
        locationAddress: user.value?.locationAddress,
        locationPhone: user.value?.locationPhone,
        paperSize: PaperSize.mm80,
        data: data,
      );
      await printerUtil.print(printerUtil.currPrinter!, bytes);
    } catch (e) {
      logger.safeLog(e);
    }
  }

  // ===================================================================
  // Pengembalian
  // ===================================================================

  Future<void> loadOutstanding() async {
    final locationId = _locationId;
    if (locationId == null) return;
    isLoadingOutstanding.value = true;
    try {
      final result = await _service.jaminanSewa.outstanding(
        authToken: _authToken,
        locationId: locationId,
        search: searchController.text,
      );
      result.fold(
        (l) => logger.safeLog(l),
        (r) => outstandingList.value = r,
      );
    } catch (e) {
      logger.safeLog(e);
    }
    isLoadingOutstanding.value = false;
    update();
  }

  void doSearch(String value) {
    loadOutstanding();
  }

  void pilihJaminan(JaminanSewaEntity? jaminan) {
    selectedJaminan.value = jaminan;
    refundNotesController.clear();
    update();
  }

  void konfirmasiRefund() {
    final jaminan = selectedJaminan.value;
    if (jaminan == null) return;
    dialog.dialogDelete(
      title: 'Pengembalian Dana',
      msg: 'Kembalikan jaminan ${jaminan.jmnNo} sebesar '
          '${common.currencyFormat(jaminan.amount ?? 0)}?',
      onYes: () {
        Get.back();
        submitRefund();
      },
    );
  }

  Future<void> submitRefund() async {
    final jaminan = selectedJaminan.value;
    if (jaminan?.jmnNo == null) return;

    isSubmittingRefund.value = true;
    update();
    try {
      final result = await _service.jaminanSewa.refund(
        authToken: _authToken,
        jmnNo: jaminan!.jmnNo!,
        refundNotes: refundNotesController.text,
      );
      await result.fold(
        (l) async {
          alert.error('Gagal', l);
        },
        (r) async {
          await _cetakStrukPengembalian(r);
          alert.success('Berhasil', 'Jaminan ${r.jmnNo} dikembalikan.');
          selectedJaminan.value = null;
          refundNotesController.clear();
          loadOutstanding();
        },
      );
    } catch (e) {
      logger.safeLog(e);
      alert.error('Error', 'Terjadi kesalahan, silakan hubungi admin.');
    }
    isSubmittingRefund.value = false;
    update();
  }

  Future<void> _cetakStrukPengembalian(JaminanSewaEntity data) async {
    if (printerUtil.currPrinter == null) {
      alert.warning('Printer',
          'Pengembalian ${data.jmnNo} sudah tersimpan, tapi printer belum terhubung.');
      return;
    }
    try {
      final bytes =
          await generateJaminanSewaPrintUtil.dataPengembalianJaminanPrint(
        locationName: user.value?.locationName,
        locationAddress: user.value?.locationAddress,
        locationPhone: user.value?.locationPhone,
        paperSize: PaperSize.mm80,
        data: data,
        bukaLaci: true,
      );
      await printerUtil.print(printerUtil.currPrinter!, bytes);
    } catch (e) {
      logger.safeLog(e);
    }
  }
}
