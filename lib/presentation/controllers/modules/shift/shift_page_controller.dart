import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:jaya_propertiy/app/utils/common/api_filter_util.dart';
import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/app/utils/common/date_time_util.dart';
import 'package:jaya_propertiy/app/utils/common/generate_print_util.dart';
import 'package:jaya_propertiy/app/utils/common/kas_util.dart';
import 'package:jaya_propertiy/app/utils/common/kepala_struk_util.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/common/printer_util.dart';
import 'package:jaya_propertiy/app/utils/common/session_util.dart';
import 'package:jaya_propertiy/app/utils/constant/date_format_constant.dart';
import 'package:jaya_propertiy/app/utils/constant/filter_constant.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/data/models/common/filter_model.dart';
import 'package:jaya_propertiy/data/services/main_service.dart';
import 'package:jaya_propertiy/domain/entities/auth/user_entity.dart';
import 'package:jaya_propertiy/domain/entities/common/pagination.dart';
import 'package:jaya_propertiy/domain/entities/shift/shift_detail_entity.dart';
import 'package:jaya_propertiy/domain/entities/shift/shift_entity.dart';
import 'package:jaya_propertiy/domain/entities/shift/shift_kas_pecahan_entity.dart';
import 'package:jaya_propertiy/presentation/components/custom_alert.dart';
import 'package:jaya_propertiy/presentation/components/custom_dialog.dart';
import 'package:jaya_propertiy/presentation/views/modules/shift/hitung_kas_dialog.dart';

class ShiftPageController extends GetxController {
  ShiftPageController();
  final _service = MainService();
  final _authToken = Get.arguments[argConstant.authToken];
  final selectedShift = ShiftEntity().obs;
  final shiftCurrent = ShiftEntity().obs;
  final dataListShiftEnded = <ShiftEntity>[].obs;
  final shiftDetail = ShiftDetailEntity().obs;

  final isLoadingShiftEnded = false.obs;
  final isLoadingShiftCurrent = false.obs;
  final isLoadingShiftDetail = false.obs;
  final isPrintingSettlement = false.obs;

  final scrollController = ScrollController();
  final pagination = Pagination().obs;

  doPrepared() async {
    dataListShiftEnded.value = [];
    shiftCurrent.value = ShiftEntity();
    selectedShift.value = ShiftEntity();
    shiftDetail.value = ShiftDetailEntity();
    await _getShiftCurrent();
    await _getShiftEnded(page: 0);

    // Sesudah shift ditutup, tidak ada lagi shift berjalan. Dulu yang dipilih
    // tetap shift berjalan yang sudah kosong, dan pemilihannya gagal diam-diam
    // di tengah jalan: panel kanan tinggal kosong, seolah halamannya tidak
    // ter-refresh. Yang ditampilkan sekarang shift terakhir yang baru ditutup.
    final berjalan = shiftCurrent.value;
    final terpilih = berjalan.shftDate != null
        ? berjalan
        : (dataListShiftEnded.isNotEmpty ? dataListShiftEnded.first : null);
    if (terpilih != null) doSelectedShift(terpilih);
    update();
  }

  doSelectedShift(ShiftEntity? val) {
    // Shift tanpa tanggal tidak punya rincian yang bisa diminta; dulu keadaan
    // ini melempar kesalahan yang tertelan catch, dan layarnya diam saja.
    if (val == null || val.shftDate == null) {
      selectedShift.value = ShiftEntity();
      shiftDetail.value = ShiftDetailEntity();
      update();
      return;
    }
    selectedShift.value = val;
    _getDetailShift(val);
  }

  _getDetailShift(ShiftEntity? val) async {
    isLoadingShiftDetail.value = true;

    try {
      // Tanggal dan user wajib ada: keduanya kunci rincian shift, dan tanpa
      // penjagaan ini tanda seru di bawah melempar kesalahan yang berakhir
      // sebagai layar kosong tanpa penjelasan.
      if (val != null && val.shftDate != null && val.shftUserid != null) {
        var result;
        result = await _service.shift.detail(
          authToken: _authToken,
          shiftDate: dateTimeUtil.getFormattedDate(
              date: dateTimeUtil.convertToDateTime(val.shftDate!),
              format: dateFormat.yyyyMMdd),
          userId: val.shftUserid!,
        );
        result.fold((l) {
          logger.safeLog(l);
          isLoadingShiftDetail.value = false;
        }, (r) {
          if (r.data! != null) {
            shiftDetail.value = r.data!;
          }
          isLoadingShiftDetail.value = false;
        });
      }
    } catch (e) {
      logger.safeLog(e);
      isLoadingShiftDetail.value = false;
    }
    update();
  }

  _getShiftEnded({required int page}) async {
    isLoadingShiftEnded.value = true;

    try {
      var result;
      List<FilterQuery> dataFilter = [];
      Map<String, dynamic> param = {
        'page': page.toString(),
        'size': PAGINATIONS_CONSTANT.LIMIT_PAGE.toString(),
        SORTING_CONSTANT.DESC: 'shftStart',
      };

      dataFilter.add(
        apiFilterUtil.addSearch(
          'shftEnd',
          OPERATOR_CONSTANTS.EQUALS,
          OPERATOR_CONSTANTS.IS_NOT_NULL,
        )!,
      );
      dataFilter.add(
        apiFilterUtil.addSearch(
          'shftUserid',
          OPERATOR_CONSTANTS.EQUALS,
          sessionUtil.getUserName(),
        )!,
      );

      result = await _service.shift.getAll(
        authToken: _authToken,
        dataFilter: dataFilter,
        paramsFilter: param,
      );
      result.fold((l) {
        logger.safeLog(l);
        isLoadingShiftEnded.value = false;
      }, (r) {
        if (r.data != null) {
          if (page == 0) {
            dataListShiftEnded.value = r.data!;
          } else {
            dataListShiftEnded.addAll(r.data!);
          }
        } else {
          dataListShiftEnded.value = [];
        }
        pagination.value = r.pagination!;
        isLoadingShiftEnded.value = false;
      });
    } catch (e) {
      logger.safeLog(e);
      isLoadingShiftEnded.value = false;
    }
    update();
  }

  _getShiftCurrent() async {
    isLoadingShiftCurrent.value = true;

    try {
      var result;
      // List<FilterQuery> dataFilter = [];
      // Map<String, dynamic> param = {
      //   'page': '0',
      //   'size': PAGINATIONS_CONSTANT.LIMIT_PAGE.toString(),
      //   SORTING_CONSTANT.DESC: 'shftStart',
      // };

      // dataFilter.add(
      //   apiFilterUtil.addSearch(
      //     'shftEnd',
      //     OPERATOR_CONSTANTS.EQUALS,
      //     OPERATOR_CONSTANTS.IS_NULL,
      //   )!,
      // );
      // dataFilter.add(
      //   apiFilterUtil.addSearch(
      //     'shftUserid',
      //     OPERATOR_CONSTANTS.EQUALS,
      //     sessionUtil.getUserName(),
      //   )!,
      // );

      // result = await _service.shift.getAll(
      //   authToken: _authToken,
      //   dataFilter: dataFilter,
      //   paramsFilter: param,
      // );
      result = await _service.shift.getCurrentShift(
        authToken: _authToken,
      );
      result.fold((l) {
        logger.safeLog(l);
        isLoadingShiftCurrent.value = false;
      }, (r) {
        if (r != null) {
          shiftCurrent.value = r;
        }
        isLoadingShiftCurrent.value = false;
      });
    } catch (e) {
      logger.safeLog(e);
      isLoadingShiftCurrent.value = false;
    }
    update();
  }

  /// Mengisi atau meralat modal awal shift yang sedang berjalan.
  ///
  /// Dialog modal saat buka kasir hanya muncul sekali — begitu tersimpan, kasir
  /// tidak punya jalan lain untuk memperbaiki salah hitung. Tombol ini jalan
  /// masuknya, dan sengaja hanya untuk shift yang belum ditutup: setelah shift
  /// ditutup, modalnya sudah dipakai menghitung selisih.
  Future<void> doUbahModal(ShiftDetailEntity? val) async {
    if (val == null || val.shftUserid == null || val.shftDate == null) return;

    final lembar = await tampilkanHitungKas(
      judul: val.modalSudahDiisi ? 'Ubah Modal Kasir' : 'Isi Modal Kasir',
      keterangan: 'Hitung uang modal awal shift ini, isi jumlah lembar tiap '
          'pecahan. Angka yang tersimpan akan dipakai menghitung selisih kas '
          'saat shift ditutup.',
      labelSimpan: 'Simpan Modal',
      awal: kasTersimpan(val.listPecahanModal),
    );
    if (lembar == null) return;

    isLoadingShiftDetail.value = true;
    final hasil = await _service.shift.simpanModal(
      authToken: _authToken,
      shiftDate: dateTimeUtil.getFormattedDate(
        date: dateTimeUtil.convertToDateTime(val.shftDate!),
        format: dateFormat.yyyyMMdd,
      ),
      userId: val.shftUserid!,
      pecahan: lembar,
    );
    isLoadingShiftDetail.value = false;

    hasil.fold(
      (l) => alert.error('Modal Kasir', l),
      (r) => alert.success(
        'Modal Kasir',
        'Modal Rp ${common.currencyFormat(r.modalAwal ?? 0)} tersimpan.',
      ),
    );
    await doPrepared();
    update();
  }

  /// Menahan sentuhan kedua pada tombol Akhiri Shift.
  ///
  /// Dua sentuhan cepat membuka dua dialog bertumpuk, dan penutupannya nanti
  /// ikut menutup halaman di belakangnya — kasir melihat layar kosong.
  bool _sedangTutupShift = false;

  doShiftEnded(ShiftDetailEntity? val) async {
    if (val == null || _sedangTutupShift) {
      return;
    }
    _sedangTutupShift = true;
    try {
      await _tutupShift(val);
    } finally {
      _sedangTutupShift = false;
    }
  }

  Future<void> _tutupShift(ShiftDetailEntity val) async {

    // Lokasi yang memakai modal kas menghitung laci dulu: rekap selisih hanya
    // ada artinya kalau hitungannya diambil sebelum shift ditutup, bukan
    // sesudah uangnya diserahkan.
    Map<int, int>? pecahanAkhir;
    if (val.pakaiModal) {
      pecahanAkhir = await tampilkanHitungKas(
        judul: 'Hitung Uang di Laci',
        keterangan: 'Hitung seluruh uang tunai di laci sebelum shift ditutup. '
            'Selisihnya dihitung terhadap modal awal ditambah penjualan tunai.',
        labelSimpan: 'Lanjut Tutup Shift',
        awal: kasTersimpan(val.listPecahanAkhir),
      );
      if (pecahanAkhir == null) {
        // Kasir membatalkan hitungan: shift dibiarkan tetap terbuka.
        return;
      }
    }

    // Ditunggu sampai dialognya tertutup: selama masih terbuka, tombol Akhiri
    // Shift di belakangnya tidak boleh membuka dialog kedua.
    await dialog.dialogCustomerLeftRight(
      title: 'Shift Ended',
      msg: val.pakaiModal
          ? 'Uang di laci Rp ${common.currencyFormat(KasUtil.total(pecahanAkhir!).toDouble())}. Akhiri shift?'
          : 'Are you sure?',
      labelLeft: 'Batal',
      labelRight: 'Akhiri Shift',
      onLeft: () {
        if (Get.isDialogOpen ?? false) Get.back();
      },
      onRight: () async {
        // Dialog ditutup DULU, baru pekerjaan jaringannya dijalankan.
        // Sebelumnya urutannya terbalik: dialog tetap terbuka selama dua
        // panggilan jaringan, dan bila kasir menekan tombol kembali sambil
        // menunggu, Get.back() yang menyusul kemudian menutup halamannya —
        // layar jadi kosong.
        if (Get.isDialogOpen ?? false) Get.back();
        await _shiftEnded(val, pecahanAkhir: pecahanAkhir);
        // Dicetak otomatis begitu shift ditutup — "print out saat settlement"
        // — HANYA untuk lokasi yang memakai modal kas. Lokasi yang tidak
        // memakai modal tetap memakai jalur lama: email rekap dari backend
        // (endShift mengirimnya sendiri), tanpa struk settlement; struknya
        // memang isinya rekonsiliasi kas, tidak relevan tanpa modal.
        if (val.pakaiModal) {
          // shiftDetail SETELAH _shiftEnded TIDAK CUKUP untuk dicetak:
          // endpoint tutup shift (trn_shift_kasir, POST) di backend cuma
          // mengembalikan entity mentah, tanpa listSumPayment/listSumVoucher/
          // listSumPotongan maupun rekap kas (pakaiModalKas, modalAwal,
          // kasSeharusnya, dst) — rekap lengkap itu cuma dihitung untuk badan
          // email internal, tidak ikut dikirim ke aplikasi. Rincian struk
          // jadi kosong kalau langsung dicetak dari situ. _getDetailShift
          // (endpoint /detail) adalah yang benar-benar menghitung semuanya —
          // sama seperti yang dipakai layar Rincian Shift — jadi diminta
          // ulang di sini sebelum mencetak.
          await _getDetailShift(
            ShiftEntity(shftDate: val.shftDate, shftUserid: val.shftUserid),
          );
          await doPrintSettlement(shiftDetail.value);
        }
        await doPrepared();
      },
    );
  }

  /// Mencetak struk settlement (laporan tutup shift) ke printer struk yang
  /// sedang tersambung.
  ///
  /// Dipanggil otomatis begitu shift ditutup, dan juga tersedia sebagai
  /// tombol cetak ulang untuk shift yang sudah berakhir — kertas bisa macet
  /// atau habis tepat saat cetak otomatis, dan kasir perlu jalan untuk
  /// mencetak ulang tanpa membuka shift baru.
  ///
  /// HANYA untuk lokasi yang memakai modal kas: isi struknya adalah
  /// rekonsiliasi kas (hitungan laci, aktual vs komputer, dst), yang tidak
  /// punya arti tanpa modal. Dijaga di sini juga — bukan cuma di pemanggil —
  /// supaya method ini sendiri tidak pernah mencetak struk yang kosong/tidak
  /// relevan, siapa pun yang memanggilnya nanti.
  Future<void> doPrintSettlement(ShiftDetailEntity? detail) async {
    if (detail == null ||
        detail.shftDate == null ||
        !detail.pakaiModal ||
        isPrintingSettlement.value) {
      return;
    }
    isPrintingSettlement.value = true;
    update();
    try {
      await printerUtil.connectPrinter();
      if (printerUtil.currPrinter == null) {
        alert.error('Cetak Settlement', 'Printer belum tersambung.');
        return;
      }

      final UserEntity? user = await common.getUser(authToken: _authToken);

      // Logo dicetak dari master lokasi (loc_logo_path); gagal diunduh tidak
      // boleh menggagalkan seluruh struk, cukup dicetak tanpa logo.
      img.Image? logo;
      final logoUrl = user?.locationLogoPath;
      if (logoUrl != null && logoUrl.isNotEmpty) {
        try {
          final response = await http.get(Uri.parse(logoUrl));
          if (response.statusCode == 200) {
            logo = KepalaStruk.siapkanLogo(response.bodyBytes);
          }
        } catch (e) {
          logger.safeLog('Logo settlement gagal dimuat : $e');
        }
      }

      final data = await generatePrintUtil.dataSettlementPrint(
        locationName: user?.locationName,
        locationAddress: user?.locationAddress,
        locationPhone: user?.locationPhone,
        locationEmail: user?.locationEmail,
        logo: logo,
        paperSize: PaperSize.mm80,
        detail: detail,
      );
      await printerUtil.print(printerUtil.currPrinter!, data);
    } catch (e) {
      logger.safeLog('Cetak settlement gagal : $e');
      alert.error('Cetak Settlement', 'Gagal mencetak struk settlement.');
    } finally {
      isPrintingSettlement.value = false;
      update();
    }
  }

  /// Hitungan yang sudah pernah tersimpan, sebagai isian awal dialog.
  ///
  /// Kasir yang mengulang perhitungan tidak perlu mengetik ulang seluruh laci.
  Map<int, int>? kasTersimpan(List<ShiftKasPecahanEntity>? list) {
    if (list == null || list.isEmpty) return null;
    return {for (final e in list) e.pecahan: e.lembar};
  }

  _shiftEnded(ShiftDetailEntity val, {Map<int, int>? pecahanAkhir}) async {
    isLoadingShiftDetail.value = true;
    try {
      var result;

      result = await _service.shift.shiftEnded(
        authToken: _authToken,
        shiftDate: DateTime.now().toLocal().toIso8601String(),
        userId: val.shftUserid!,
        pecahanAkhir: pecahanAkhir,
      );
      result.fold((l) {
        logger.safeLog(l);
        isLoadingShiftDetail.value = false;
      }, (r) {
        shiftDetail.value = r.data!;
        isLoadingShiftDetail.value = false;
      });
    } catch (e) {
      logger.safeLog(e);
      isLoadingShiftDetail.value = false;
    }
    update();
  }

  String formatShiftDate(DateTime date) {
    return '${dateTimeUtil.getFormattedDate(
      date: date,
      format: dateFormat.onlyDays,
    )}, ${dateTimeUtil.getFormattedDate(
      date: date,
      format: dateFormat.dateWithoutTime,
    )} | ${dateTimeUtil.getFormattedDate(
      date: date,
      format: dateFormat.hourMinutes,
    )}';
  }
}
