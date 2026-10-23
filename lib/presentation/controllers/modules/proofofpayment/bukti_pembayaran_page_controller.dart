import 'package:either_dart/either.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/api_filter_util.dart';
import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/app/utils/common/date_time_util.dart';
import 'package:jaya_propertiy/app/utils/common/generate_member_print_util.dart';
import 'package:jaya_propertiy/app/utils/common/generate_print_util.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/common/message_util.dart';
import 'package:jaya_propertiy/app/utils/common/otorisasi_util.dart';
import 'package:jaya_propertiy/app/utils/common/printer_util.dart';
import 'package:jaya_propertiy/app/utils/common/session_util.dart';
import 'package:jaya_propertiy/app/utils/constant/date_format_constant.dart';
import 'package:jaya_propertiy/app/utils/constant/filter_constant.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/data/models/common/filter_model.dart';
import 'package:jaya_propertiy/data/models/order/order_addon_model.dart';
import 'package:jaya_propertiy/data/models/order/order_deposit_model.dart';
import 'package:jaya_propertiy/data/models/order/order_member_model.dart';
import 'package:jaya_propertiy/data/models/order/order_model.dart';
import 'package:jaya_propertiy/data/models/order/order_rental_model.dart';
import 'package:jaya_propertiy/data/models/order/order_ticket_model.dart';
import 'package:jaya_propertiy/data/models/order/order_potongan_model.dart';
import 'package:jaya_propertiy/data/models/order/order_voucher_model.dart';
import 'package:jaya_propertiy/data/services/main_service.dart';
import 'package:jaya_propertiy/domain/entities/auth/auth_token.dart';
import 'package:jaya_propertiy/domain/entities/auth/user_entity.dart';
import 'package:jaya_propertiy/domain/entities/common/custom_id_name_entity.dart';
import 'package:jaya_propertiy/domain/entities/common/pagination.dart';
import 'package:jaya_propertiy/domain/entities/member/membership.dart';
import 'package:jaya_propertiy/domain/entities/order/detail/trn_detail_order_entity.dart';
import 'package:jaya_propertiy/domain/entities/order/response_create_ticket_no_entity.dart';
import 'package:jaya_propertiy/domain/entities/order/trn_order_entity.dart';
import 'package:jaya_propertiy/domain/entities/otorisasi/otorisasi_entity.dart';
import 'package:jaya_propertiy/domain/entities/reasonvoid/reason_void_entity.dart';
import 'package:jaya_propertiy/domain/entities/sale/addon_entity.dart';
import 'package:jaya_propertiy/domain/entities/sale/deposit_entity.dart';
import 'package:jaya_propertiy/domain/entities/sale/potongan_entity.dart';
import 'package:jaya_propertiy/domain/entities/sale/ticket_entity.dart';
import 'package:jaya_propertiy/domain/entities/sale/voucher_entity.dart';
import 'package:jaya_propertiy/presentation/components/custom_alert.dart';
import 'package:jaya_propertiy/presentation/components/custom_dialog.dart';

import '../../../components/custom_loading.dart';

class BuktiPembayaranPageController extends GetxController
    with GetSingleTickerProviderStateMixin {
  BuktiPembayaranPageController();
  final _service = MainService();
  final _authToken = Get.arguments[argConstant.authToken];
  final searchController = TextEditingController();
  final selectedData = TrnOrderEntity().obs;

  final dataList = <TrnOrderEntity>[].obs;
  final detailModel = TrnDetailOrderEntity().obs;
  final isLoadMore = false.obs;
  final isLoading = false.obs;
  final isLoadingDetail = false.obs;
  final visibleLoadMore = false.obs;

  final ScrollController scrollController = ScrollController();
  late AnimationController animationController;

  final pagination = Pagination().obs;

  @override
  Future<void> onInit() async {
    scrollController.addListener(_onScroll);
    animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    await doRefresh();

    super.onInit();
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    animationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      // logger.safeLog('CURR PAGE : ${pagination.value.currentPage}');
      // logger.safeLog('DATA LIST : ${dataList.length}');
      if (dataList.isNotEmpty &&
          pagination.value.currentPage! < dataList.length) {
        loadNextPage();
      }
    }
  }

  loadNextPage() async {
    isLoading.value = true;
    animationController.repeat(reverse: true);
    logger.safeLog("NEXT PAGE : ${((pagination.value.currentPage ?? 0) + 1)}");
    doPrepareList(
        page: ((pagination.value.currentPage ?? 0) + 1),
        search: searchController.text);
    isLoading.value = false;
    update();
  }

  doSearch(String search) {
    dataList.clear();
    detailModel.value = TrnDetailOrderEntity();
    doPrepareList(page: 0, search: search);
    update();
  }

  doRefresh() {
    dataList.clear();
    detailModel.value = TrnDetailOrderEntity();
    doPrepareList(page: 0);
    update();
  }

  doPrepareList({required int page, String? search}) async {
    detailModel.value = TrnDetailOrderEntity();
    selectedData.value = TrnOrderEntity();
    if (page > 0) {
      isLoadMore.value = true;
    } else {
      isLoading.value = true;
    }

    try {
      var result;
      List<FilterQuery> dataFilter = [];
      Map<String, dynamic> param = {
        'page': page.toString(),
        'size': PAGINATIONS_CONSTANT.LIMIT_PAGE.toString(),
        'desc': 'orderDate',
      };

      // Filter lokasi lewat param khusus `locationId` (backend memecahnya jadi
      // List<Integer>), bukan lewat `filter` — koma pada IN dipotong Spring dan
      // memicu 400. Kosong = seluruh lokasi hak akses user
      // (REKAP_PENYESUAIAN_MOBILE.md §2).
      final locationIds = sessionUtil.getLocationIdsQueryParam();
      if (locationIds.isNotEmpty) {
        param['locationId'] = locationIds;
      }

      dataFilter.add(
        apiFilterUtil.addSearch(
          'orderDate',
          OPERATOR_CONSTANTS.GREATHER_THAN_OR_EQUALS,
          dateTimeUtil.getFormattedDate(
            date: DateTime(DateTime.now().year, DateTime.now().month,
                    DateTime.now().day, 0, 0, 0)
                .toLocal(),
            format: dateFormat.dateStripedYYYYMMDDHHMMSS,
          ),
        )!,
      );

      dataFilter.add(
        apiFilterUtil.addSearch(
          'orderDate',
          OPERATOR_CONSTANTS.LESS_THAN_OR_EQUALS,
          dateTimeUtil.getFormattedDate(
            date: DateTime(DateTime.now().year, DateTime.now().month,
                    DateTime.now().day + 1, 0, 0, 0)
                .toLocal(),
            format: dateFormat.dateStripedYYYYMMDDHHMMSS,
          ),
        )!,
      );
      if (search != '' && search != null) {
        dataFilter.add(
          apiFilterUtil.addSearch(
            'orderNumber',
            OPERATOR_CONSTANTS.LIKE,
            search,
          )!,
        );
      }

      result = await _service.order.orderService.getAllOrder(
        authToken: _authToken,
        dataFilter: dataFilter,
        paramsFilter: param,
      );
      result.fold((l) {
        logger.safeLog(l);
        isLoading.value = false;
        isLoadMore.value = false;
        // Tampilkan pesan backend (mis. 403 akses lokasi) saat load awal.
        if (page == 0) alert.warning('Perhatian', l.toString());
      }, (r) {
        // if (page == 0) {
        //   dataList.value = r.data!;
        // } else {
        //   dataList.addAll(r.data!);
        // }
        dataList.addAll(r.data!);
        pagination.value = r.pagination!;
        isLoading.value = false;
        isLoadMore.value = false;
        visibleLoadMore.value = false;
      });
    } catch (e) {
      logger.safeLog(e);
      isLoading.value = false;
      isLoadMore.value = false;
    }
    update();
  }

  doSelectedOrder(TrnOrderEntity val) {
    selectedData.value = val;
    detailModel.value = TrnDetailOrderEntity();
    _getDetailOrder();
    update();
  }

  _getDetailOrder() async {
    isLoadingDetail.value = true;
    try {
      var result;
      result = await _service.order.orderService.getDetailOrder(
        authToken: _authToken,
        orderNo: selectedData.value.orderNumber,
      );
      result.fold((l) {
        logger.safeLog(l);
      }, (r) {
        detailModel.value = r.data;
      });
    } catch (e) {
      logger.safeLog(e);
    }
    isLoadingDetail.value = false;
    update();
  }

  doSendMessage() {
    dialog.paymentSendProofOfPayment(
      title: 'Send Email WA',
      labelButton: 'Close',
      onSendEmail: (val) {
        loading.popUpLoading();
        logger.safeLog('Email : $val');
        try {
          var result = _service.message.sendEmail(
            authToken: _authToken,
            orderNo: detailModel.value.orderNumber ?? '',
            mailTo: val,
            message: messageUtil.buildBodyMessageDetailOrder([]),
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
            orderNo: detailModel.value.orderNumber ?? '',
            phoneNumber: int.parse(val),
            message: messageUtil.buildBodyMessageDetailOrder([]),
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

  /// Cetak ulang struk — perlu otorisasi leader/SPV lebih dulu.
  ///
  /// Cetak ulang struk adalah jalan paling mudah menggandakan bukti
  /// pembayaran, dan sebelum ini tidak ada satu baris pun yang mencatat siapa
  /// melakukannya. Alurnya dibuat sama seperti void: ajukan, leader menyetujui
  /// di back office, baru tercetak — dan satu izin hanya berlaku untuk satu
  /// cetakan.
  doPrintTicket() async {
    final orderNo = selectedData.value.orderNumber;
    if (orderNo == null || orderNo.isEmpty) {
      alert.error('Error', 'Order belum dipilih.');
      return;
    }

    final izin = await otorisasiUtil.minta(
      authToken: _authToken,
      jenis: OtorisasiEntity.jenisCetakUlangStruk,
      ref: orderNo,
      // Keterangan dibaca leader di back office. Tanpa nama pembeli dan
      // nominalnya, yang terlihat hanya nomor order — dan yang terjadi di
      // lapangan adalah leader menyetujui tanpa membuka menu lain.
      keterangan: _keteranganOtorisasi(),
    );
    if (izin == null) return;

    final tercetak = await _cetakUlangStruk();
    // Ditandai SESUDAH struknya keluar: kalau printer macet, kasir tidak
    // kehilangan izinnya untuk pekerjaan yang belum terjadi.
    if (tercetak) {
      await otorisasiUtil.tandaiDipakai(authToken: _authToken, id: izin);
    }
  }

  /// Rincian singkat untuk dibaca penyetuju: nama pembeli dan nominalnya.
  String _keteranganOtorisasi() {
    final nama = (selectedData.value.orderName ?? '').trim();
    final nominal = selectedData.value.orderTotalAmt;
    final bagian = <String>[];
    if (nama.isNotEmpty) bagian.add(nama);
    if (nominal != null) bagian.add('Rp${common.currencyFormat(nominal)}');
    return bagian.isEmpty ? 'Cetak ulang struk' : bagian.join(' - ');
  }

  /// Struk PEMBATALAN, dicetak sesudah void disetujui leader.
  ///
  /// Tidak perlu otorisasi lagi: void-nya sendiri sudah melewati persetujuan
  /// leader, dan struk ini adalah bukti pembatalan untuk pelanggan. Hanya bisa
  /// dicetak untuk order yang statusnya memang sudah VOID — selama void masih
  /// menunggu persetujuan (status S), tidak ada yang boleh dicetak: pelanggan
  /// yang memegang kertas "VOID" padahal leader masih bisa menolaknya akan
  /// menuntut uangnya kembali atas transaksi yang masih sah.
  doCetakStrukVoid() async {
    final status = selectedData.value.orderStatus;
    if (status != 'V') {
      alert.warning(
        'Belum Bisa Dicetak',
        status == 'S'
            ? 'Void ini masih menunggu persetujuan leader. Struk pembatalan '
                'baru bisa dicetak setelah disetujui.'
            : 'Order ini tidak dalam keadaan void.',
      );
      return;
    }
    await _cetakUlangStruk(strukVoid: true);
  }

  /// Mencetak struknya. true bila kertasnya benar-benar keluar.
  ///
  /// [strukVoid] true menghasilkan struk PEMBATALAN dari data yang sama —
  /// bukan bentuk kertas yang lain — supaya pelanggan bisa mencocokkannya
  /// dengan struk pembeliannya baris demi baris.
  Future<bool> _cetakUlangStruk({bool strukVoid = false}) async {
    try {
      if (printerUtil.currPrinter != null) {
        String locationName = "";
        UserEntity? user = await common.getUser(
          authToken: _authToken,
        );
        if (user != null) {
          locationName = user.locationName!;
        }

        logger.safeLog('PRINT DETAIL MODEL : ${detailModel.value.toJson()}');
        if (detailModel.value.trnOrderMember != null &&
            detailModel.value.trnOrderMember!.memberNo != null) {
          // Layar ini memang layar BUKTI pembayaran: struknya sudah tercetak
          // saat transaksi. Apa pun yang dicetak dari sini adalah cetakan
          // kedua - kecuali struk pembatalan, yang memang baru dicetak sekali
          // dan sudah punya penandanya sendiri.
          await doPrintMember(locationName, user, cetakUlang: !strukVoid);
          Get.back();
          return true;
        } else {
          await _createTicket(
            _authToken,
            null,
            selectedData.value.orderNumber,
            'C',
          );

          List<OrderTicketModel> ticketList =
              detailModel.value.trnOrderTicket == null
                  ? []
                  : detailModel.value.trnOrderTicket!
                      .map(
                        (e) => OrderTicketModel(
                          totalTicket: e.ticketQty!,
                          totalAmount: e.ticketTtlAmount!,
                          ticket: TicketEntity(
                            ticketName: e.ticketName,
                            ticketPrice: e.ticketPrice,
                          ),
                        ),
                      )
                      .toList();
          List<OrderAddonModel> productList =
              detailModel.value.trnOrderItem == null
                  ? []
                  : detailModel.value.trnOrderItem!
                      .map(
                        (e) => OrderAddonModel(
                          ordadTotalAddon: e.prodQty!,
                          ordadTotalAmount: e.prodTtlAmount!,
                          addOn: AddonEntity(
                            productName: e.prodName,
                            productPrice: e.prodPrice,
                          ),
                          rentHdrDtl: OrderRentalModel(
                            amount: e.prodTtlAmount,
                            hour: e.hour,
                            startDate: e.startDate,
                            endDate: e.endDate,
                          ),
                        ),
                      )
                      .toList();
          List<OrderPotonganModel> potonganList =
              detailModel.value.trnOrderVouchers == null
                  ? []
                  : detailModel.value.trnOrderVouchers!
                      .map(
                        (e) => OrderPotonganModel(
                          ordvcTotalVoucher: 1,
                          ordvcTotalAmount: e.voucherUnitCalcValue!,
                          voucher: PotonganEntity(
                            voucherUnitType: e.voucherUnitType,
                            voucherUnitValue: e.voucherUnitValue,
                            voucherName: e.voucherName,
                            voucherCode: e.voucherCode,
                          ),
                        ),
                      )
                      .toList();
          List<OrderVoucherModel> voucherList =
              detailModel.value.trnOrderVoucherPrice == null
                  ? []
                  : detailModel.value.trnOrderVoucherPrice!
                      .map(
                        (e) => OrderVoucherModel(
                          ovpTotalVoucher: 1,
                          ovpTotalAmount: e.voucherUnitCalcValue!,
                          entity: VoucherEntity(
                            vpUnitType: e.voucherUnitType,
                            vpUnitValue: e.voucherUnitValue,
                            vpName: e.voucherName,
                            vpCode: e.voucherCode,
                          ),
                        ),
                      )
                      .toList();
          List<OrderDepositModel> depositList =
              detailModel.value.trnOrderDeposit == null
                  ? []
                  : detailModel.value.trnOrderDeposit!
                      .map(
                        (e) => OrderDepositModel(
                          odpTotalAmount: e.depositAmount ?? 0,
                          odpOrderNumber: null,
                          odpDpId: null,
                          entity: DepositEntity(
                            dpName: e.depositName,
                            dpAmount: e.depositAmount,
                          ),
                        ),
                      )
                      .toList();

          OrderModel orderModel = OrderModel(
            orderNumber: selectedData.value.orderNumber ?? '',
            // Nama pembeli HARUS diisi di sini. Model struk ini dirakit ulang
            // dari data layar, dan sebelum ini kolomnya dilewatkan — sehingga
            // baris "Nama Pembeli" pada struk cetak ulang selalu tercetak "-"
            // meski namanya ada di order.
            orderName: detailModel.value.orderName ?? selectedData.value.orderName,
            orderReffno: selectedData.value.paymentDetail?.pymntReffno ?? '',
            orderTotalItem: detailModel.value.orderTotalItem!,
            orderTotalAmt: detailModel.value.orderTotalAmt!,
            adminFeeAmt: detailModel.value.paymentDetail?.pymntAdminFee ??
                selectedData.value.paymentDetail?.pymntAdminFee ??
                0,
            orderUnitId: 0,
            orderLoacationId: 0,
            orderPaidBy: detailModel.value.orderPaidBy!,
            orderPaidByName: detailModel.value.orderPaidByName!,
            orderStatus: detailModel.value.orderStatus!,
            paymentDate: detailModel.value.orderDate ??
                detailModel.value.paymentDetail?.pymntDate ??
                selectedData.value.orderDate ??
                selectedData.value.paymentDetail?.pymntDate ??
                DateTime.now(),
            listTicket: ticketList,
            listProduct: productList,
            listVoucher: potonganList,
            listVoucherPrice: voucherList,
            listDepositUse: depositList,
          );

          // logger.safeLog('DATA PRINT : ${orderModel.toJson()}');
          // logger.safeLog('DATA PRINT : ${orderModel.listTicket.length}');
          // logger.safeLog('DATA PRINT : ${orderModel.listProduct.length}');
          // logger.safeLog('DATA PRINT : ${orderModel.listVoucher.length}');

          List<int> data = [];
          data = await generatePrintUtil.dataPaymentTiketPrint(
            locationName: locationName,
            locationAddress: user?.locationAddress,
            locationPhone: user?.locationPhone,
            paperSize: PaperSize.mm80,
            body: orderModel,
            kasirName: detailModel.value.paymentDetail == null
                ? ''
                : detailModel.value.paymentDetail!.pymntCreatedBy ?? '',
            strukVoid: strukVoid,
            alasanVoid: detailModel.value.orderVoidReason,
            disetujuiOleh: detailModel.value.orderVoidbySpv,
            cetakUlang: !strukVoid,
          );

          logger.safeLog('==============================> PRINT EXISTING ');
          await printerUtil.print(printerUtil.currPrinter!, data);
          Get.back();
          return true;
        }
      } else {
        alert.error('Error', 'please check connection printer');
        printerUtil.connectPrinter();
        return false;
      }
    } catch (e) {
      logger.safeLog(e);
      alert.error('Error', 'Terjadi Kesalahan , hubungi admin');
      return false;
    }
  }

  /// Struk membership. [cetakUlang] menandai lembar kedua.
  doPrintMember(String locationName, UserEntity? user,
      {bool cetakUlang = false}) async {
    OrderMemberModel orderMemberModel = OrderMemberModel(
      orderName: detailModel.value.trnOrderMember?.memberName,
      orderMemberNo: detailModel.value.trnOrderMember?.memberNo,
      orderMemberExpiredDate:
          detailModel.value.trnOrderMember?.memberExpiredDate,
      orderPhoneNumber: detailModel.value.trnOrderMember?.memberPhone,
      orderEmail: detailModel.value.trnOrderMember?.memberEmail,
      orderReffno: detailModel.value.paymentDetail?.pymntReffno,
      orderPaidBy: detailModel.value.paymentDetail?.pymntCreatedBy,
      totalPrice: detailModel.value.trnOrderMember?.membershipTtlAmount,
      adminFeeAmt: detailModel.value.paymentDetail?.pymntAdminFee,
      membership: Membership(
        membName: detailModel.value.trnOrderMember?.membershipName,
        membRegPrice: detailModel.value.trnOrderMember?.membershipPrice,
      ),
      listMember: detailModel.value.trnOrderMember?.memberList,
    );

    // logger.safeLog('DATA PRINT MEMBER : ${orderMemberModel.toJson()}');

    List<int> data = [];
    data = await generateMemberPrintUtil.paymentPrint(
      body: orderMemberModel,
      paymentDate: detailModel.value.orderDate,
      locationName: locationName,
      locationAddress: user?.locationAddress,
      locationPhone: user?.locationPhone,
      paperSize: PaperSize.mm80,
      kasirName: detailModel.value.paymentDetail == null
          ? ''
          : detailModel.value.paymentDetail!.pymntCreatedBy ?? '',
      cetakUlang: cetakUlang,
    );

    logger.safeLog('==============================> PRINT MEMBER ');
    await printerUtil.print(printerUtil.currPrinter!, data);
  }

  Future<void> _createTicket(
    AuthToken authToken,
    OrderModel? body,
    String? orderNo,
    String status,
  ) async {
    if (orderNo != null) {
      List<ResponseCreateTicketNoEntity> listCreateTicket =
          await createTicketNo(
        authToken,
        orderNo,
        status,
      );
      if (body != null) {
        body.paymentDate = DateTime.now();
        body.orderNumber = orderNo;
        body.listCreateTicket = listCreateTicket;
      }
    }
  }

  Future<List<ResponseCreateTicketNoEntity>> createTicketNo(
      AuthToken authToken, String orderNo, String status) async {
    try {
      List<ResponseCreateTicketNoEntity> dataList = [];
      var result = await _service.order.orderService.createTicketNo(
          authToken: authToken, reffNo: orderNo, status: status);

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

  final selectReasonRx = Rxn<CustomIdNameEntity>(null);
  final etcReason = false.obs;

  doVoidPayment() async {
    var reasons = await getListReasonVoid();
    selectReasonRx.value = reasons.first;
    etcReason.value = false;
    update();
    logger.safeLog('reasons : ${reasons.length}');
    dialog.dialogVoidTicket(
      title: 'Void',
      msg: 'Apakah anda yakin akan melakukan void pembayaran ini?',
      selectReason: selectReasonRx,
      etcReason: etcReason,
      listReason: reasons,
      onNext: (reasonVal) async {
        try {
          if (selectedData.value.orderNumber != null) {
            // await createTicketNo(
            //   orderNo: selectedData.value.orderNumber!,
            //   reason: reasonVal,
            //   status: 'V',
            // );
            var result = await _service.order.orderService.voidOrder(
              authToken: _authToken,
              orderNo: selectedData.value.orderNumber!,
              voidReason: reasonVal,
            );

            Get.back();
            result.fold(
              (l) {
                logger.safeLog(l);
                alert.error('Error', l);
              },
              (r) async {
                logger.safeLog(r);
                alert.success('Success', r);
                TrnOrderEntity selectDetailB4 = selectedData.value;
                await doRefresh();
                await doSelectedOrder(selectDetailB4);
              },
            );
          } else {
            alert.error('Error', 'Terjadi Kesalahan , silahkan hubungi admin');
          }
        } catch (e) {
          logger.safeLog(e);
          alert.error('Error', 'Terjadi Kesalahan , silahkan hubungi admin');
        }
      },
    );
  }

  Future<List<CustomIdNameEntity>> getListReasonVoid() async {
    List<CustomIdNameEntity> reasons = [];
    reasons.add(
      CustomIdNameEntity(
        id: null,
        name: ' --- select reason --- ',
      ),
    );
    try {
      var result;
      result = await _service.reasonVoid.getAll(authToken: _authToken);
      result.fold((l) {
        logger.safeLog(l);
      }, (r) {
        logger.safeLog('REASONS : ${r.data!.length}');

        if (r.data != null) {
          List<ReasonVoidEntity> reasonList = r.data! as List<ReasonVoidEntity>;
          for (var element in reasonList) {
            reasons.add(
              CustomIdNameEntity(
                id: element.reasonCode,
                name: element.reasonName,
              ),
            );
          }
        }
      });
    } catch (e) {
      logger.safeLog(e);
    }
    reasons.add(
      CustomIdNameEntity(
        id: 'LN',
        name: 'Lainnya',
      ),
    );
    return reasons;
  }
}
