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
import 'package:jaya_propertiy/domain/entities/auth/auth_token.dart';
import 'package:jaya_propertiy/domain/entities/auth/user_entity.dart';
import 'package:jaya_propertiy/domain/entities/jaminansewa/jaminan_sewa_entity.dart';
import 'package:jaya_propertiy/presentation/components/custom_alert.dart';
import 'package:jaya_propertiy/presentation/components/custom_dialog.dart';

/// Cash-Out jaminan sewa (pengembalian dana) dari tab Item, sub-tab "Jaminan
/// Sewa" — pengganti Tab 2 "Pengembalian" di layar standalone lama.
///
/// WAJIB TUNAI — tidak ada pilihan metode pembayaran sama sekali di sini
/// (beda dengan Cash-In sejak V162). Backend (`TrnJaminanSewaService
/// .kembalikan`) juga tidak pernah menerima kode pembayaran untuk refund,
/// jadi aturan ini tidak bisa dilewati dari sisi klien.
///
/// Integrasi ke laporan kas shift & Revenue Summary SENGAJA belum dikerjakan
/// di sini (diminta ditunda — "report dan settlement kasir nanti saja").
class JaminanCashOutDialogController extends GetxController {
  final _service = MainService();
  late final AuthToken _authToken = Get.arguments[argConstant.authToken];

  final user = Rxn<UserEntity>();
  int? get _locationId => sessionUtil.getLocationId();

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
    loadOutstanding();
  }

  @override
  void onClose() {
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

  void doSearch(String value) => loadOutstanding();

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
          '${common.currencyFormat(jaminan.amount ?? 0)} secara TUNAI?',
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
      );
      await printerUtil.print(printerUtil.currPrinter!, bytes);
    } catch (e) {
      logger.safeLog(e);
    }
  }
}
