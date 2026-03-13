import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/api_filter_util.dart';
import 'package:jaya_propertiy/app/utils/common/date_time_util.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/common/session_util.dart';
import 'package:jaya_propertiy/app/utils/constant/date_format_constant.dart';
import 'package:jaya_propertiy/app/utils/constant/filter_constant.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/data/models/common/filter_model.dart';
import 'package:jaya_propertiy/data/services/main_service.dart';
import 'package:jaya_propertiy/domain/entities/common/pagination.dart';
import 'package:jaya_propertiy/domain/entities/shift/shift_detail_entity.dart';
import 'package:jaya_propertiy/domain/entities/shift/shift_entity.dart';
import 'package:jaya_propertiy/presentation/components/custom_dialog.dart';

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

  final scrollController = ScrollController();
  final pagination = Pagination().obs;

  doPrepared() async {
    dataListShiftEnded.value = [];
    shiftCurrent.value = ShiftEntity();
    selectedShift.value = ShiftEntity();
    shiftDetail.value = ShiftDetailEntity();
    await _getShiftCurrent();
    await _getShiftEnded(page: 0);
    doSelectedShift(shiftCurrent.value);
  }

  doSelectedShift(ShiftEntity? val) {
    selectedShift.value = val!;
    _getDetailShift(val);
  }

  _getDetailShift(ShiftEntity? val) async {
    isLoadingShiftDetail.value = true;

    try {
      if (val != null) {
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

  doShiftEnded(ShiftDetailEntity? val) async {
    if (val == null) {
      return;
    }

    dialog.dialogCustomerLeftRight(
      title: 'Shift Ended',
      msg: 'Are you sure?',
      labelLeft: 'Batal',
      labelRight: 'Akhiri Shift',
      onLeft: () {
        Get.back();
      },
      onRight: () async {
        await _shiftEnded(val);
        await doPrepared();
        Get.back();
      },
    );
  }

  _shiftEnded(ShiftDetailEntity val) async {
    isLoadingShiftDetail.value = true;
    try {
      var result;

      result = await _service.shift.shiftEnded(
        authToken: _authToken,
        shiftDate: DateTime.now().toLocal().toIso8601String(),
        userId: val.shftUserid!,
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
