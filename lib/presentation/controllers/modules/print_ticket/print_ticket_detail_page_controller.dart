import 'package:either_dart/either.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/app/utils/common/date_time_util.dart';
import 'package:jaya_propertiy/app/utils/common/generate_print_util.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/common/gelang_util.dart';
import 'package:jaya_propertiy/app/utils/common/printer_util.dart';
import 'package:jaya_propertiy/app/utils/common/session_util.dart';
import 'package:jaya_propertiy/app/utils/constant/date_format_constant.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/data/models/common/custom_table_data.dart';
import 'package:jaya_propertiy/data/services/main_service.dart';
import 'package:jaya_propertiy/domain/entities/auth/user_entity.dart';
import 'package:jaya_propertiy/domain/entities/order/detail/trn_detail_order_entity.dart';
import 'package:jaya_propertiy/domain/entities/order/response_create_ticket_no_entity.dart';
import 'package:jaya_propertiy/domain/entities/sale/ticket_entity.dart';
import 'package:jaya_propertiy/domain/entities/order/vw_order_entity.dart';
import 'package:jaya_propertiy/presentation/components/custom_alert.dart';
import 'package:jaya_propertiy/presentation/components/custom_dialog.dart';
import 'package:jaya_propertiy/presentation/components/custom_loading.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/print_ticket/print_ticket_page_controller.dart';

class PrintTicketDetailPageController extends GetxController {
  final PrintTicketPageController parentController;
  PrintTicketDetailPageController({required this.parentController});

  final _service = MainService();
  final _authToken = Get.arguments[argConstant.authToken];

  final statusPembayaran = RxString('N');
  final statusCetak = RxString('N');

  // final parentController = Get.find<PrintTicketPageController>();

  final detailListColumnHeader = <CustomTableData>[].obs;
  // var selected = <TrnDetailOrder>[].obs;
  // var selectAll = false.obs;
  final isLoading = false.obs;

  final parentModel = VwOrderEntity().obs;

  final model = TrnDetailOrderEntity().obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    doPrepared();
  }

  doPrepared() async {
    isLoading.value = true;
    await setListHeaderColumn();
    parentModel.value = parentController.selectedData.value;
    await getDetail();
    isLoading.value = false;

    statusPembayaran.value = parentModel.value.pymntStatus ?? 'N';
    statusCetak.value = parentModel.value.statusCetak ?? 'N';

    logger.safeLog('ORD NO : ${parentModel.value.orderNumber}');
    logger.safeLog('STS PAYMENT : ${statusPembayaran.value}');
    logger.safeLog('STS PRINT : ${statusCetak.value}');
    update();
  }

  getDetail() async {
    try {
      var result;
      result = await _service.order.orderService.getDetailOrder(
        authToken: _authToken,
        orderNo: parentModel.value.orderNumber,
      );
      result.fold((l) {
        logger.safeLog(l);
      }, (r) {
        model.value = r.data;
      });
    } catch (e) {
      logger.safeLog(e);
    }
    update();
  }

  // void toggleSelectAll(bool? value) {
  //   selectAll.value = value ?? false;
  //   selected.clear();
  //   if (value!) {
  //     for (var element in model.value.detailOrderModels!) {
  //       selected.add(element);
  //     }
  //   }
  //   update();
  // }

  // void toggleSelect(TrnDetailOrder modelSelected, bool? value) {
  //   if (value!) {
  //     selected.add(modelSelected);
  //   } else {
  //     selected.remove(modelSelected);
  //   }
  //   selectAll.value = selected.length == model.value.detailOrderModels!.length;
  //   update();
  // }

  setListHeaderColumn() {
    detailListColumnHeader.clear();
    detailListColumnHeader.add(
      CustomTableData(
        id: 'productName',
        columnName: 'Tiket',
        alignment: Alignment.centerLeft,
      ),
    );
    detailListColumnHeader.add(
      CustomTableData(
        id: 'quantity',
        columnName: 'Quantity',
        alignment: Alignment.center,
      ),
    );
    detailListColumnHeader.add(
      CustomTableData(
        id: 'price',
        columnName: 'Item Price',
        alignment: Alignment.centerRight,
      ),
    );
    // detailListColumnHeader.add(
    //   CustomTableData(
    //     id: 'Discount',
    //     columnName: 'Discount',
    //     alignment: Alignment.centerRight,
    //   ),
    // );
    detailListColumnHeader.add(
      CustomTableData(
        id: 'total',
        columnName: 'Total',
        alignment: Alignment.centerRight,
      ),
    );
    update();
  }

  doBack() {
    logger.safeLog('BACK TO INQ');
    // final parentController = Get.find<PrintTicketPageController>();
    parentController.openDetail.value = false;
    parentController.doSearch();
    // parentController.doRefresh();
    // parentController.searchController.text = '';
    parentModel.value = VwOrderEntity();
    parentController.update();
  }

  doSendEmail() {
    dialog.paymentSendProofOfPayment(
      title: 'Send Email WA',
      labelButton: 'Close',
      onSendEmail: (val) {
        loading.popUpLoading();
        logger.safeLog('Email : $val');
        try {
          var result = _service.message.sendEmail(
            authToken: _authToken,
            orderNo: model.value.orderNumber ?? '',
            mailTo: val,
            message: _buildBodyMessage(),
          );
          result.fold(
            (left) {
              if (Get.isDialogOpen == true) Get.back();
              alert.error('Error', left);
            },
            (right) {
              if (Get.isDialogOpen == true) Get.back();
              alert.success('Success', 'Send Email Sucess');
            },
          );
        } catch (e) {
          if (Get.isDialogOpen == true) Get.back();
          alert.error('Error', 'Send Email Internal Server Error');
        }
      },
      onSendWa: (val) {
        loading.popUpLoading();
        logger.safeLog('WA : $val');
        try {
          var result = _service.message.sendWa(
            authToken: _authToken,
            orderNo: model.value.orderNumber ?? '',
            phoneNumber: int.parse(val),
            message: _buildBodyMessage(),
          );
          result.fold(
            (left) {
              if (Get.isDialogOpen == true) Get.back();
              alert.error('Error', left);
            },
            (right) {
              if (Get.isDialogOpen == true) Get.back();
              alert.success('Success', 'Send Wa Sucess');
            },
          );
        } catch (e) {
          if (Get.isDialogOpen == true) Get.back();
          alert.error('Error', 'Send Wa Internal Server Error');
        }
      },
      onNewOrder: () {
        Get.back();
      },
    );
  }

  String _buildBodyMessage() {
    String bodyMsg = '';
    bodyMsg += 'Your Ticket';
    // for (var element in selected) {
    //   bodyMsg += 'Product Name : ${element.productName}';
    // }
    return bodyMsg;
  }

  doActiveTicket() {
    // if (model.value.paymentDetail?.pymntStatus == 'P' ||
    //     model.value.orderStatus == 'C') {
    if (parentModel.value.otdtlStatus == 'Y') {
      alert.warning('Warning', 'Sudah melakukan aktifasi tiket');
    } else {
      dialog.dialogActiovcationTicket(
        title: 'Aktivasi Tiket',
        msg: 'Apakah anda yakin akan aktivasi?',
        onNext: (reasonVal) async {
          try {
            if (model.value.orderNumber != null) {
              await createTicketNo(
                orderNo: model.value.orderNumber!,
                reason: reasonVal,
                status: 'P',
              );
              Get.back();
              doBack();
              // await doPrepared();
              alert.success('Success', 'Berhasil Aktivasi Tiket');
            } else {
              alert.error('Error', 'Terjadi Kesalahan , hubungi admin');
            }
          } catch (e) {
            logger.safeLog(e);
            alert.error('Error', 'Terjadi Kesalahan , hubungi admin');
          }
        },
      );
      // dialog.dialogCustomerLeftRight(
      //   title: 'Aktivasi Tiket',
      //   msg: 'Apakah anda yakin akan aktivasi?',
      //   labelLeft: 'No',
      //   labelRight: 'Yes',
      //   onLeft: () {
      //     Get.back();
      //   },
      //   onRight: () async {
      //     Get.back();
      //     try {
      //       if (model.value.orderNumber != null) {
      //         await createTicketNo(model.value.orderNumber!);
      //         await doPrepared();
      //         alert.success('Success', 'Berhasil Aktivasi Tiket');
      //       } else {
      //         alert.error('Error', 'Terjadi Kesalahan , hubungi admin');
      //       }
      //     } catch (e) {
      //       logger.safeLog(e);
      //       alert.error('Error', 'Terjadi Kesalahan , hubungi admin');
      //     }
      //   },
      // );
    }
  }

  doVerifiedPrintTicket() {
    bool isValid = true;
    // if (model.value.paymentDetail?.pymntStatus != 'P' &&
    //     model.value.orderStatus != 'C') {
    if (parentModel.value.otdtlStatus != 'Y') {
      alert.warning('Warning',
          'Tidak bisa melakukan print tiket, Karena tiket belum aktif');
      isValid = false;
    }
    return isValid;
  }

  doPrintTicket() async {
    try {
      if (doVerifiedPrintTicket()) {
        if (printerUtil.currPrinter != null) {
          List<ResponseCreateTicketNoEntity> listCreateTicket = [];
          if (model.value.orderNumber != null) {
            listCreateTicket = await createTicketNo(
              orderNo: model.value.orderNumber!,
              status: 'C',
            );
          } else {
            alert.error('Error', 'Terjadi Kesalahan , silahkan hubungi admin');
            return;
          }

          if (listCreateTicket.isEmpty) {
            alert.error('Error', 'Data Empty');
            return;
          }

          String locationName = "";
          UserEntity? user = await common.getUser(
            authToken: _authToken,
          );
          if (user != null) {
            locationName = user.locationName!;
          }

          // Ambil daftar tiket lapangan (ticket_fl_lapangan='Y') beserta setup
          // harga per jam, untuk memisahkan booking lapangan dari tiket gate.
          // Booking lapangan dicetak seperti struk penjualan (court + jam +
          // durasi + harga) TANPA QR; hanya tiket non-lapangan yang ber-QR.
          final lapanganPriceTimes = await _fetchLapanganPriceTimes();

          final String reffNo = model.value.paymentDetail?.pymntReffno ?? '';
          final String orderNo = parentModel.value.orderNumber ?? '';
          final DateTime paymentDate =
              parentModel.value.orderDate ?? DateTime.now();

          final lapanganTickets = listCreateTicket
              .where((e) => lapanganPriceTimes.containsKey(e.ticketName))
              .toList();
          final gateTickets = listCreateTicket
              .where((e) => !lapanganPriceTimes.containsKey(e.ticketName))
              .toList();

          List<int> data = [];

          // Tiket non-lapangan -> QR gate. Bila printer gelang sudah diatur,
          // QR-nya keluar di sana; kalau belum, tetap ikut tercetak di struk
          // seperti perilaku lama.
          final gelangTercetak = await gelangUtil.cetak(gateTickets);

          int count = 1;
          int totalPak = gateTickets.length;
          // Sudah keluar sebagai gelang -> tidak diulang di kertas struk.
          final tiketDiStruk = gelangTercetak
              ? <ResponseCreateTicketNoEntity>[]
              : gateTickets;
          for (var element in tiketDiStruk) {
            List<int> dataPrint = await generatePrintUtil.dataGatePrint(
              locationName: locationName,
              paperSize: PaperSize.mm80,
              orderNo: orderNo,
              reffNo: reffNo,
              pakOf: count,
              pakTotal: totalPak,
              qrCode: element.ticketNo!,
              expiredAt: dateTimeUtil.getFormattedDate(
                date: element.ticketActiveDate!.toLocal(),
                format: dateFormat.dateDDMMMMYYYY,
              ),
              ticketName: element.ticketName,
              isCompanion: element.isCompanion, // Pass flag pendamping
              paymentDate: paymentDate,
            );
            data.addAll(dataPrint);
            count++;
          }

          // Booking lapangan → format struk penjualan, tanpa QR.
          final lapanganLines =
              _buildLapanganPrintLines(lapanganTickets, lapanganPriceTimes);
          if (lapanganLines.isNotEmpty) {
            data.addAll(
              await generatePrintUtil.dataLapanganTicketPrint(
                locationName: locationName,
                paperSize: PaperSize.mm80,
                orderNo: orderNo,
                reffNo: reffNo,
                paymentDate: paymentDate,
                lines: lapanganLines,
              ),
            );
          }

          if (data.isEmpty) {
            // Tidak ada yang perlu keluar di printer struk. Itu hasil yang benar
            // bila seluruh tiketnya sudah tercetak sebagai gelang; hanya di luar
            // itu ia berarti tidak ada data.
            if (!gelangTercetak) alert.error('Error', 'Data Empty');
            return;
          }
          await printerUtil.print(printerUtil.currPrinter!, data);
        } else {
          alert.error('Error', 'please check connection printer');
          printerUtil.connectPrinter();
        }
      }
    } catch (e) {
      logger.safeLog(e);
      alert.error('Error', 'Terjadi Kesalahan , hubungi admin');
    }
  }

  /// Ambil tiket lapangan (ticket_fl_lapangan='Y') untuk lokasi kasir aktif,
  /// dipetakan dari nama tiket ke setup harga per jam (ticket_price_time).
  /// Dipakai untuk mengenali baris booking lapangan pada order dan menghitung
  /// harganya saat cetak reprint.
  Future<Map<String, List<TicketPriceTimeEntity>>>
      _fetchLapanganPriceTimes() async {
    final Map<String, List<TicketPriceTimeEntity>> map = {};
    try {
      final Map<String, dynamic> param = {
        'locationId': sessionUtil.getLocationIdsQueryParam(),
      };
      final result = await _service.sale.ticketService.getLapangan(
        authToken: _authToken,
        paramsFilter: param,
      );
      result.fold(
        (l) => logger.safeLog(l),
        (r) {
          for (final TicketEntity t in (r.data ?? <TicketEntity>[])) {
            if (t.ticketName != null) {
              map[t.ticketName!] =
                  t.ticketPriceTimes ?? <TicketPriceTimeEntity>[];
            }
          }
        },
      );
    } catch (e) {
      logger.safeLog(e);
    }
    return map;
  }

  /// Susun baris cetak booking lapangan dari daftar slot (tiap slot = 1 jam,
  /// dikenali dari [ResponseCreateTicketNoEntity.ticketActiveDate]). Slot
  /// dikelompokkan per court lalu dipecah menjadi blok jam yang berurutan,
  /// sehingga jam yang meloncat menghasilkan baris terpisah — konsisten dengan
  /// alur penjualan. Harga tiap blok dijumlah dari setup harga per jam.
  List<LapanganPrintLine> _buildLapanganPrintLines(
    List<ResponseCreateTicketNoEntity> tickets,
    Map<String, List<TicketPriceTimeEntity>> priceTimesByName,
  ) {
    final List<LapanganPrintLine> lines = [];

    final Map<String, List<ResponseCreateTicketNoEntity>> byCourt = {};
    for (final t in tickets) {
      if (t.ticketName == null || t.ticketActiveDate == null) continue;
      byCourt.putIfAbsent(t.ticketName!, () => []).add(t);
    }

    byCourt.forEach((courtName, slots) {
      slots.sort(
        (a, b) => a.ticketActiveDate!.compareTo(b.ticketActiveDate!),
      );
      final priceTimes = priceTimesByName[courtName] ?? const [];

      List<ResponseCreateTicketNoEntity> group = [];
      void flush() {
        if (group.isEmpty) return;
        final start = group.first.ticketActiveDate!.toLocal();
        final end = group.last.ticketActiveDate!.toLocal().add(
              const Duration(hours: 1),
            );
        double price = 0;
        for (final s in group) {
          price += _priceAtHour(priceTimes, s.ticketActiveDate!.toLocal().hour) ??
              0;
        }
        lines.add(
          LapanganPrintLine(
            courtName: courtName,
            startDate: start,
            endDate: end,
            hours: group.length,
            price: price,
          ),
        );
        group = [];
      }

      for (final s in slots) {
        if (group.isEmpty) {
          group.add(s);
        } else {
          final prev = group.last.ticketActiveDate!.toLocal();
          final curr = s.ticketActiveDate!.toLocal();
          // Berurutan bila selisih tepat 1 jam.
          if (curr.difference(prev).inMinutes == 60) {
            group.add(s);
          } else {
            flush();
            group.add(s);
          }
        }
      }
      flush();
    });

    return lines;
  }

  /// Harga satu jam dari setup ticket_price_time; null bila tak ada rentang
  /// yang cocok. Semantik: startHour <= hour <= endHour (sama dengan backend).
  double? _priceAtHour(List<TicketPriceTimeEntity> priceTimes, int hour) {
    for (final pt in priceTimes) {
      final s = pt.startHour;
      final e = pt.endHour;
      if (s == null || e == null || pt.price == null) continue;
      if (s <= hour && hour <= e) return pt.price;
    }
    return null;
  }

  Future<List<ResponseCreateTicketNoEntity>> createTicketNo({
    required String orderNo,
    String? reason,
    required String status,
  }) async {
    try {
      List<ResponseCreateTicketNoEntity> dataList = [];
      var result = await _service.order.orderService.createTicketNo(
        authToken: _authToken,
        reffNo: orderNo,
        status: status,
      );

      result.fold(
        (l) {
          logger.safeLog(l);
          logger.safeLog('Create Ticket No Error 1');
          alert.error('Error', 'Terjadi Kesalahan!');
        },
        (r) {
          logger.safeLog('Create Ticket No Success');
          logger.safeLog(r);
          dataList = r;
        },
      );
      return dataList;
    } catch (e) {
      logger.safeLog('Create Ticket No Error 2');
      logger.safeLog(e.toString());
      return [];
    }
  }
}
