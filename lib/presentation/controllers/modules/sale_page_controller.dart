import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/date_time_util.dart';
import 'package:jaya_propertiy/app/utils/common/display_util.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/common/session_util.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/data/models/cart/cart_addon_model.dart';
import 'package:jaya_propertiy/data/models/cart/cart_deposit_model.dart';
import 'package:jaya_propertiy/data/models/cart/cart_ticket_mode.dart';
import 'package:jaya_propertiy/data/models/cart/cart_potongan_model.dart';
import 'package:jaya_propertiy/data/models/cart/cart_voucher_model.dart';
import 'package:jaya_propertiy/data/models/common/filter_model.dart';
import 'package:jaya_propertiy/data/models/order/order_addon_model.dart';
import 'package:jaya_propertiy/data/models/order/order_deposit_model.dart';
import 'package:jaya_propertiy/data/models/order/order_model.dart';
import 'package:jaya_propertiy/data/models/order/order_rental_model.dart';
import 'package:jaya_propertiy/data/models/order/order_ticket_model.dart';
import 'package:jaya_propertiy/data/models/order/order_potongan_model.dart';
import 'package:jaya_propertiy/data/models/order/order_voucher_model.dart';
import 'package:jaya_propertiy/data/services/main_service.dart';
import 'package:jaya_propertiy/domain/entities/common/custom_id_name_entity.dart';
import 'package:jaya_propertiy/domain/entities/masterdata/mst_payment.dart';
import 'package:jaya_propertiy/domain/entities/member/member_list.dart';
import 'package:jaya_propertiy/domain/entities/member/member_valid.dart';
// import 'package:jaya_propertiy/domain/entities/member/membership.dart';
import 'package:jaya_propertiy/domain/entities/order/response_order_entity.dart';
import 'package:jaya_propertiy/domain/entities/sale/voucher_entity.dart';
import 'package:jaya_propertiy/presentation/components/custom_alert.dart';
import 'package:jaya_propertiy/presentation/components/custom_dialog.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/order/order_controller.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/sale/sale_cart_page_controller.dart';

class SalePageController extends GetxController
    with SingleGetTickerProviderMixin {
  SalePageController();
  final _service = MainService();
  final _authToken = Get.arguments[argConstant.authToken];
  DisplayUtil displayUtil = DisplayUtil();

  final scrollController = ScrollController();

  TabController? tabController;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
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

  final openPayment = false.obs;

  var tabIndex = 0.obs;
  void changeTabIndex(int index) {
    tabIndex.value = index;
  }

  final orderNameController = TextEditingController();
  final emailController = TextEditingController();
  final noWaController = TextEditingController();
  final referenceIdController = TextEditingController();
  final alamatController = TextEditingController();
  final keteranganVoucher = TextEditingController();
  final paymentType = <CustomIdNameEntity>[].obs;
  final selectedPaymentType = CustomIdNameEntity().obs;
  final totalOrderQty = RxInt(0);
  final totalOrderAmnt = RxDouble(0);
  final addonList = RxList<CartAddon>([]);
  final ticketList = RxList<CartTicket>([]);
  final potonganList = RxList<CartPotongan>([]);
  final voucherList = RxList<CartVoucher>([]);
  final depositList = RxList<CartDeposit>([]);

  final memberNo = TextEditingController();

  var orderEntity = Rxn<ResponseOrderEntity>(null);

  final orderNo = Rxn<String>(null);

  final isLoadingPayment = false.obs;
  final mstPayments = <MstPayment>[].obs;

  doBackPayment() {
    openPayment.value = !openPayment.value;
    final SaleCartPageController saleCartPageController =
        Get.find<SaleCartPageController>();
    saleCartPageController.selectedMstPayment.value = MstPayment();
    saleCartPageController.calculateTotalOrder();
    update();
  }

  refreshForm() {
    orderNo.value = null;
    orderNameController.text = '';
    emailController.text = '';
    noWaController.text = '';
    alamatController.text = '';
    keteranganVoucher.text = '';
    memberNo.text = '';
    doInitialValueDropdown();
    doSelectPaymentType(
      CustomIdNameEntity(
        id: null,
        name: ' --- Pilih Pembayaran --- ',
      ),
    );
  }

  doSelectPaymentType(CustomIdNameEntity value) {
    selectedPaymentType.value = value;

    MstPayment mstPayment = mstPayments.firstWhere(
      (e) => e.pymntCode == value.id,
    );
    final SaleCartPageController saleCartPageController =
        Get.find<SaleCartPageController>();
    saleCartPageController.selectedMstPayment.value = mstPayment;
    saleCartPageController.calculateTotalOrder();
    update();
  }

  doPrepared() {
    doInitialValueDropdown();
  }

  doInitialValueDropdown() async {
    paymentType.clear();
    // paymentType.insert(
    //   0,
    //   CustomIdNameEntity(
    //     id: null,
    //     name: ' --- Pilih Pembayaran --- ',
    //   ),
    // );

    var result;
    List<FilterQuery> dataFilter = [];
    Map<String, dynamic> param = {
      'page': '0',
      'size': '999',
      'flMobile': 'Y',
    };

    isLoadingPayment.value = true;
    try {
      result = await _service.masterData.getAll(
        authToken: _authToken,
        dataFilter: dataFilter,
        paramsFilter: param,
      );

      result.fold((l) {
        logger.safeLog(l);
        isLoadingPayment.value = false;
      }, (r) {
        if (r.data != null) {
          mstPayments.value = r.data;
          for (var element in mstPayments) {
            paymentType.add(
              CustomIdNameEntity(
                id: element.pymntCode,
                name: element.pymntName,
              ),
            );
          }
        }
        isLoadingPayment.value = false;
      });
    } catch (e) {
      isLoadingPayment.value = false;
      logger.safeLog(e);
    }
    // selectedPaymentType.value = paymentType.first;
    update();
  }

  bool doVerifyRequest() {
    bool isValid = true;
    // if (isValid && orderNameController.text.isEmpty) {
    //   isValid = false;
    //   alert.error(
    //       "Terjadi Kesalahan!", messagesConstant.requiredField("Name Pemesan"));
    // }
    // if (isValid && emailController.text.isEmpty) {
    //   isValid = false;
    //   alert.error(
    //       "Terjadi Kesalahan!", messagesConstant.requiredField("Email"));
    // }
    // if (isValid && noWaController.text.isEmpty) {
    //   isValid = false;
    //   alert.error(
    //       "Terjadi Kesalahan!", messagesConstant.requiredField("No Wa"));
    // }
    if (isValid && selectedPaymentType.value.id == null) {
      isValid = false;
      alert.error('Warning', 'Pilih Pembayaran terlebih dahulu!');
    }
    return isValid;
  }

  doPayment() {
    if (doVerifyRequest()) {
      // logger.safeLog('orderNo.value : ${orderNo.value}');
      final OrderController orderController = Get.put(OrderController());
      final OrderPaymentController orderPayment =
          Get.put(OrderPaymentController());

      MstPayment mstPayment = mstPayments.firstWhere(
        (e) => e.pymntCode == selectedPaymentType.value.id,
      );
      if (mstPayment.pymntCategory == PaymentMethod.QRIS) {
        OrderModel body =
            getBodyOrder(mstPayment.pymntCode!, mstPayment.pymntName!);
        logger.safeLog('ORDER BODY : ${body.toJson()}');
        orderController.doPaymentQris(
          body: body,
          orderNo: orderNo,
        );
      } else if (mstPayment.pymntCategory != PaymentMethod.QRIS) {
        OrderModel body =
            getBodyOrder(mstPayment.pymntCode!, mstPayment.pymntName!);
        logger.safeLog('ORDER BODY : ${body.toJson()}');
        orderPayment.doOrderPayment(
          body: body,
          orderNo: orderNo,
        );
      }
      // if (selectedPaymentType.value.id == PaymentMethod.QRIS) {
      //   orderController.doPaymentQris(
      //     body: getBodyOrder(),
      //     orderNo: orderNo,
      //   );
      // } else if (selectedPaymentType.value.id == PaymentMethod.EDC) {
      //   OrderModel body = getBodyOrder();
      //   body.orderPaidBy = PaymentMethod.EDC;
      //   orderPayment.doOrderPayment(
      //     body: body,
      //     orderNo: orderNo,
      //   );
      // } else if (selectedPaymentType.value.id == PaymentMethod.TRAVELOKA) {
      //   OrderModel body = getBodyOrder();
      //   body.orderPaidBy = PaymentMethod.TRAVELOKA;
      //   orderPayment.doOrderPayment(
      //     body: body,
      //     orderNo: orderNo,
      //   );
      // } else if (selectedPaymentType.value.id == PaymentMethod.TICKET) {
      //   OrderModel body = getBodyOrder();
      //   body.orderPaidBy = PaymentMethod.TICKET;
      //   orderPayment.doOrderPayment(
      //     body: body,
      //     orderNo: orderNo,
      //   );
      // } else {
      //   alert.error('Error', 'Please please select payment method');
      // }
    }
  }

  OrderModel getBodyOrder(String? paymentMethod, String? paymentMethodName) {
    List<OrderTicketModel> listTicket = [];
    List<OrderAddonModel> listProduct = [];
    List<OrderPotonganModel> listPotongan = [];
    List<OrderVoucherModel> listVoucher = [];
    List<OrderDepositModel> listDeposit = [];

    double totalPrice = 0;
    int countTotal = 0;

    if (ticketList.isNotEmpty) {
      listTicket.addAll(
        ticketList.map(
          (element) {
            totalPrice += element.totalPrice!;
            countTotal += element.qtyOrder ?? 0;
            return OrderTicketModel(
              ticket: element.ticket,
              ordtcTicketId: element.ticket?.ticketId,
              totalTicket: element.qtyOrder!,
              totalAmount: element.totalPrice!,
            );
          },
        ),
      );
    }
    if (addonList.isNotEmpty) {
      listProduct.addAll(
        addonList.map(
          (element) {
            totalPrice += element.totalPrice!;
            countTotal += element.qtyOrder ?? 0;
            return OrderAddonModel(
              addOn: element.addon,
              ordadAddonId: element.addon?.productId,
              ordadTotalAddon: element.qtyOrder!,
              ordadTotalAmount: element.totalPrice!,
              rentHdrDtl: element.rentModel == null
                  ? null
                  : OrderRentalModel(
                      hour: element.rentModel!.totalHours!,
                      amount: element.rentModel!.newBuyPrice,
                      startDate: element.rentModel!.startDate,
                      endDate: element.rentModel!.endDate,
                      orderNumberExtra:
                          element.rentModel!.transactionExtra?.orderNumber,
                    ),
            );
          },
        ),
      );
    }
    // if (voucherList.isNotEmpty) {
    //   int count = 0;
    //   listVoucher.addAll(
    //     voucherList.map(
    //       (element) {
    //         int countRemaining = 0;
    //         CartTicket ticket = ticketList[count];
    //         ticket.qtyOrder ;

    //         // double total = element.totalPrice!;
    //         // if (element.entity != null &&
    //         //     element.entity?.vpUnitType == UnitType.PERCENT) {
    //         //   total = (totalTicketProduct * (element.totalPrice ?? 0) / 100);
    //         // }

    //         return OrderVoucherModel(
    //           entity: element.entity,
    //           ovpVoucherId: element.entity?.vpId,
    //           ovpTotalAmount: total,
    //           ovpTotalVoucher: element.qtyOrder ?? 0,
    //         );
    //       },
    //     ),
    //   );
    // }

    // if (voucherList.isNotEmpty) {
    //   // double discountAmount = 0;
    //   double totalDiscountAmount = 0;

    //   for (var element in voucherList) {
    //     int remainingVoucherQty = element.qtyOrder ?? 0;
    //     double voucherDiscountAmount = 0;

    //     if (remainingVoucherQty > 0) {
    //       for (var ticket in ticketList) {
    //         if (remainingVoucherQty == 0) break;

    //         int applicableQty = ticket.qtyOrder! < remainingVoucherQty
    //             ? ticket.qtyOrder!
    //             : remainingVoucherQty;
    //         remainingVoucherQty -= applicableQty;

    //         // logger.safeLog('applicableQty : $applicableQty');
    //         // logger.safeLog('remainingVoucherQty : $remainingVoucherQty');

    //         double discountPerUnit = 0;
    //         if (element.entity!.vpUnitType == UnitType.PERCENT) {
    //           // logger.safeLog('ticket.totalPrice : ${ticket.totalPrice}');
    //           // logger.safeLog(
    //           //     'ticket.ticket.ticketPrice : ${ticket.ticket?.ticketPrice}');
    //           // logger.safeLog('ticket.qtyOrder : ${ticket.qtyOrder}');
    //           // logger.safeLog(
    //           //     'element.entity!.vpUnitValue : ${element.entity!.vpUnitValue}');

    //           // discountAmount = applicableQty *
    //           //     (ticket.ticket?.ticketPrice ?? 0) *
    //           //     (element.entity!.vpUnitValue ?? 0) /
    //           //     100;

    //           discountPerUnit = (ticket.ticket?.ticketPrice ?? 0) *
    //               (element.entity!.vpUnitValue ?? 0) /
    //               100;
    //         } else {
    //           // discountAmount =
    //           //     applicableQty * (element.entity!.vpUnitValue ?? 0);
    //           discountPerUnit = element.entity!.vpUnitValue ?? 0;
    //         }

    //         double discountAmount = applicableQty * discountPerUnit;
    //         voucherDiscountAmount += discountAmount;
    //         totalPrice -= discountAmount;
    //       }

    //       totalDiscountAmount += voucherDiscountAmount;

    //       // totalDiscountAmount += discountAmount;
    //       // totalPrice -= discountAmount;
    //       listVoucher.add(OrderVoucherModel(
    //         entity: element.entity,
    //         ovpVoucherId: element.entity?.vpId,
    //         // ovpTotalAmount: totalDiscountAmount,
    //         ovpTotalAmount: voucherDiscountAmount,
    //         ovpTotalVoucher: element.qtyOrder ?? 0,
    //       ));
    //     }
    //   }
    //   logger.safeLog('VOUCHER AMOUNT : $totalDiscountAmount ');
    // }
    if (voucherList.isNotEmpty) {
      double totalDiscountAmount = 0;
      final Map<CartTicket, int> remainingTicketQtyMap = {
        for (var ticket in ticketList) ticket: ticket.qtyOrder!
      };

      for (var element in voucherList) {
        int remainingVoucherQty = element.qtyOrder ?? 0;
        double voucherDiscountAmount = 0;

        if (remainingVoucherQty > 0) {
          for (var ticket in ticketList) {
            int remainingTicketQty = remainingTicketQtyMap[ticket] ?? 0;
            if (remainingVoucherQty == 0 || remainingTicketQty == 0) continue;

            int applicableQty = remainingTicketQty < remainingVoucherQty
                ? remainingTicketQty
                : remainingVoucherQty;

            remainingTicketQtyMap[ticket] = remainingTicketQty - applicableQty;
            remainingVoucherQty -= applicableQty;

            double discountPerUnit = 0;
            if (element.entity!.vpUnitType == UnitType.PERCENT) {
              logger.safeLog(
                'PERCENT HITUNG TIKET : ${ticket.ticket?.ticketName} -> VOUCHER : ${element.entity?.vpName}',
              );
              discountPerUnit = (ticket.ticket?.ticketPrice ?? 0) *
                  (element.entity!.vpUnitValue ?? 0) /
                  100;
            } else {
              logger.safeLog(
                'NOT PERCENT HITUNG TIKET : ${ticket.ticket?.ticketName} -> VOUCHER : ${element.entity?.vpName}',
              );
              discountPerUnit = element.entity!.vpUnitValue ?? 0;
            }
            double discountAmount = applicableQty * discountPerUnit;
            voucherDiscountAmount += discountAmount;
            totalPrice -= discountAmount;
          }
        }

        totalDiscountAmount += voucherDiscountAmount;

        listVoucher.add(OrderVoucherModel(
          entity: element.entity,
          ovpVoucherId: element.entity?.vpId,
          ovpTotalAmount: voucherDiscountAmount,
          ovpTotalVoucher: element.qtyOrder ?? 0,
        ));
      }
      logger.safeLog('VOUCHER AMOUNT : $totalDiscountAmount ');
    }
    if (potonganList.isNotEmpty) {
      listPotongan.addAll(
        potonganList.map(
          (element) {
            double totalPotongan = element.totalPrice!;
            if (element.potongan != null &&
                element.potongan?.voucherUnitType == UnitType.PERCENT) {
              totalPotongan = (totalPrice * (element.totalPrice ?? 0) / 100);
            }
            return OrderPotonganModel(
              voucher: element.potongan,
              ordvcVoucherId: element.potongan?.voucherId,
              ordvcTotalVoucher: element.qtyOrder!,
              ordvcTotalAmount: totalPotongan,
            );
          },
        ),
      );
    }
    if (depositList.isNotEmpty) {
      listDeposit.addAll(
        depositList.map(
          (element) {
            // double total = element.totalPrice!;
            return OrderDepositModel(
              entity: element.deposit,
              odpOrderNumber: '',
              odpDpId: element.deposit!.dpId!,
              odpTotalAmount: element.deposit!.dpAmount!,
            );
          },
        ),
      );
    }

    final SaleCartPageController saleCartPageController =
        Get.find<SaleCartPageController>();

    return OrderModel(
      orderName:
          orderNameController.text.isEmpty ? ' ' : orderNameController.text,
      orderPhoneNumber: noWaController.text.isEmpty ? ' ' : noWaController.text,
      orderEmail: emailController.text.isEmpty ? ' ' : emailController.text,
      orderReffno: null,
      orderMemberNo: memberNo.text,
      orderTotalItem: countTotal,
      custAddres: alamatController.text.isEmpty ? ' ' : alamatController.text,
      orderVoucherDesc:
          keteranganVoucher.text.isEmpty ? ' ' : keteranganVoucher.text,
      // orderTotalItem: totalOrderQty.value,
      orderTotalAmt: totalOrderAmnt.value,
      adminFeeAmt: saleCartPageController.getPricePayemntFee(),
      orderUnitId: sessionUtil.getUnitId()!,
      orderLoacationId: 1,
      orderPaidBy: paymentMethod ?? '',
      orderPaidByName: paymentMethodName ?? '',
      orderStatus: 'N',
      listTicket: listTicket,
      listProduct: listProduct,
      listVoucher: listPotongan,
      listVoucherPrice: listVoucher,
      listDepositUse: listDeposit,
    );
  }

  Future<bool> validationPraCreateOrder() async {
    final OrderPaymentController orderPayment =
        Get.put(OrderPaymentController());
    final body = getBodyOrder(null, null);
    // validation on create order service
    bool isSuccess = await orderPayment.doPreCreateOrderPayment(
      body: body,
      check: 'Y',
    );
    return isSuccess;
  }

  onCheckMember() async {
    if (memberNo.text.isEmpty) {
      alert.warning('Warning', 'Harap isi No Member terlebih dahulu!');
      return;
    }

    bool isSuccess = await validationPraCreateOrder();
    if (!isSuccess) return;

    try {
      var result;
      result = await _service.member.memberValid(
        authToken: _authToken,
        cardNo: memberNo.text,
      );
      result.fold(
        (l) {
          logger.safeLog(l);
          alert.warning('Warning', l);
          // alert.warning('Warning', 'No Member tidak valid!');
        },
        (r) async {
          logger.safeLog('> Exists Member');
          MemberValid memberValid = r.data;
          if (memberValid.mstMembership?.membKuota == 0) {
            alert.warning('Warning', 'Kuota sudah habis');
            return;
          }

          final effTo = memberValid.memberDetail?.regEffTo;
          logger.safeLog('EXPIRED AT : $effTo');
          if (effTo != null) {
            final now = DateTime.now();
            logger.safeLog('CURR AT : $now');
            if (now.isAfter(effTo)) {
              alert.warning('Warning',
                  'Member Expired. Masa berlaku Member telah berakhir pada ${dateTimeUtil.dateFormat(effTo, 'yyyy-MM-dd')}.');
              return;
            }
          }

          logger.safeLog('DATA : ${memberValid.toJson()}');

          await dialog.paymentMember(
            onNext: (selectedMemberAnggotas) async {
              String memberNoStr = memberNo.text;
              // logger.safeLog(
              //   'qtyVoucher ==========================================================> $qtyVoucher',
              // );
              if (memberValid.mstMembership != null &&
                  memberValid.mstMembership!.membVpId != null) {
                VoucherEntity? vpEntity = await getVoucherEntity(
                  memberValid.mstMembership!.membVpId!,
                );
                if (vpEntity != null) {
                  logger.safeLog(
                    'DATA MEMBERSHIP: ${memberValid.mstMembership?.toJson()}',
                  );

                  int qtyVoucher =
                      memberValid.mstMembership?.membCheckName == 'Y'
                          ? qtyVoucherMemberCheckName(
                              memberValid,
                              selectedMemberAnggotas.length,
                            )
                          : qtyVoucherMember(memberValid);

                  int maxQty = (memberValid.mstMembership?.membKuota ?? 0) <
                          (memberValid.mstMembership?.membMaxKuota ?? 0)
                      ? (memberValid.mstMembership?.membKuota ?? 0)
                      : (memberValid.mstMembership?.membMaxKuota ?? 0);

                  logger.safeLog('qtyVoucher: $qtyVoucher');
                  logger.safeLog('maxQty: $maxQty');
                  if (qtyVoucher > maxQty) {
                    alert.warning(
                      'Warning',
                      'Tidak bisa melebihi kuota tersedia',
                    );
                    return;
                  }

                  await clearVoucherToCart(vpEntity);
                  // logger.safeLog('ADD VOUCHER MEMBER NO 1 : ${memberNo.text}');
                  // logger.safeLog('ADD VOUCHER MEMBER NO 1 : $memberNoStr');
                  await addVoucherToCart(
                    vpEntity,
                    qtyVoucher,
                    memberNoStr,
                    selectedMemberAnggotas,
                  );

                  final SaleCartPageController saleCartPageController =
                      Get.find<SaleCartPageController>();
                  saleCartPageController.memberValid.value = memberValid;
                  saleCartPageController.calculateTotalOrder();
                }
              }
              memberNo.text = memberNoStr;
            },
            authToken: _authToken,
            memberValid: memberValid,
            memberNo: memberNo.text,
          );
        },
      );
    } catch (e) {
      logger.safeLog(e);
    }
  }

  int qtyVoucherMember(MemberValid memberValid) {
    int qty = 1;

    final SaleCartPageController saleCartPageController =
        Get.find<SaleCartPageController>();
    int totalQtyTiket = 0;
    for (var tiket in saleCartPageController.ticketList) {
      totalQtyTiket += tiket.qtyOrder ?? 0;
    }

    int maxKuota = (memberValid.mstMembership?.membKuota ?? 0) <
            (memberValid.mstMembership?.membMaxKuota ?? 0)
        ? (memberValid.mstMembership?.membKuota ?? 0)
        : (memberValid.mstMembership?.membMaxKuota ?? 0);

    if (totalQtyTiket <= maxKuota) {
      qty = totalQtyTiket;
    } else {
      qty = maxKuota;
    }
    return qty;
  }

  int qtyVoucherMemberCheckName(
      MemberValid memberValid, int qtySelectedMember) {
    int qty = 1;

    final SaleCartPageController saleCartPageController =
        Get.find<SaleCartPageController>();

    int totalQtyTiket = 0;
    for (var tiket in saleCartPageController.ticketList) {
      totalQtyTiket += tiket.qtyOrder ?? 0;
    }

    if (totalQtyTiket <= qtySelectedMember) {
      qty = totalQtyTiket;
    } else {
      qty = qtySelectedMember;
    }
    return qty;
  }

  Future<VoucherEntity?> getVoucherEntity(int vpId) async {
    VoucherEntity? vpEntity;
    try {
      var result;
      result = await _service.sale.voucherService
          .getVoucherById(authToken: _authToken, vpId: vpId);

      result.fold((l) {
        logger.safeLog(l);
      }, (r) {
        vpEntity = r.data;
      });
    } catch (e) {
      logger.safeLog(e);
    }
    return vpEntity;
  }

  addVoucherToCart(
    VoucherEntity entity,
    int qtyVoucher,
    String? memberNo,
    List<MemberListResponse>? selectedMemberAnggota,
  ) async {
    // logger.safeLog('Member addVoucherToCart : $qtyVoucher');
    final SaleCartPageController saleCartPageController =
        Get.find<SaleCartPageController>();

    saleCartPageController.potonganList.clear();
    saleCartPageController.voucherList.clear();
    saleCartPageController.depositList.clear();

    logger.safeLog('ADD VOUCHER MEMBER NO 2 : $memberNo');

    final cartVoucher = CartVoucher(
      qtyOrder: qtyVoucher,
      totalPrice: qtyVoucher * entity.vpUnitValue!,
      entity: entity,
      memberNo: memberNo,
      selectedMemberAnggota: selectedMemberAnggota,
    );
    saleCartPageController.voucherList.add(cartVoucher);
    saleCartPageController.memberVoucher.value = true;
    saleCartPageController.update();
    update();
  }

  clearVoucherToCart(VoucherEntity entity) async {
    final SaleCartPageController saleCartPageController =
        Get.find<SaleCartPageController>();

    if (saleCartPageController.voucherList.isNotEmpty) {
      CartVoucher? existingTicket = saleCartPageController.voucherList
          .firstWhereOrNull((e) => e.entity!.vpId == entity.vpId);
      if (existingTicket != null) {
        await saleCartPageController.removeListvoucher(existingTicket);
      }
    }
    saleCartPageController.memberVoucher.value = false;
    saleCartPageController.update();
    update();
  }

  clearAllVoucherToCart() async {
    final SaleCartPageController saleCartPageController =
        Get.find<SaleCartPageController>();

    if (saleCartPageController.voucherList.isNotEmpty) {
      saleCartPageController.voucherList.clear();
    }
    saleCartPageController.memberVoucher.value = false;
    saleCartPageController.update();
    update();
  }
}
