import 'dart:async';

import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/common/session_util.dart';
import 'package:jaya_propertiy/app/utils/constant/date_format_constant.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/data/dummy/lapangan_dummy.dart';
import 'package:jaya_propertiy/data/models/cart/cart_addon_model.dart';
import 'package:jaya_propertiy/data/models/cart/cart_rent_model.dart';
import 'package:jaya_propertiy/data/services/main_service.dart';
import 'package:jaya_propertiy/domain/entities/sale/addon_entity.dart';
import 'package:jaya_propertiy/domain/entities/transaction/transaction_entity.dart';
import 'package:jaya_propertiy/presentation/components/custom_alert.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/sale/sale_cart_page_controller.dart';

/// Status satu sel jadwal (satu sel = satu jam) pada tab Booking Lapangan.
enum LapanganSlotStatus {
  tersedia,
  dipilih,
  terisi,
  lewat,
}

class SaleLapanganPageController extends GetxController {
  SaleLapanganPageController();
  final _service = MainService();
  final _authToken = Get.arguments[argConstant.authToken];

  /// Jadwal dibuka jam 06:00, slot terakhir 22:00 - 23:00.
  static const int startHour = 6;
  static const int closeHour = 23;
  static const int totalSlot = closeHour - startHour;

  /// Batas halaman yang ditarik saat mengambil daftar lapangan / riwayat rental.
  static const int _maxPage = 6;

  final courtList = <AddonEntity>[].obs;
  final activeCourtIndex = 0.obs;

  /// Index slot yang sudah dibooking (dari server) untuk lapangan aktif.
  final bookedSlot = <int>{}.obs;

  /// Index slot yang sedang dipilih kasir, disimpan per lapangan (productId)
  /// supaya pindah chip tidak menghapus pesanan lapangan lain di keranjang.
  final selectionByCourt = <int, List<int>>{}.obs;

  final isLoading = false.obs;
  final isLoadingSchedule = false.obs;
  final isSyncingCart = false.obs;

  Timer? _syncDebounce;

  @override
  void onInit() {
    super.onInit();
    doPrepareCourtList();
  }

  @override
  void onClose() {
    _syncDebounce?.cancel();
    super.onClose();
  }

  SaleCartPageController get _cartController {
    if (Get.isRegistered<SaleCartPageController>()) {
      return Get.find<SaleCartPageController>();
    }
    return Get.put(SaleCartPageController());
  }

  AddonEntity? get activeCourt {
    if (courtList.isEmpty) return null;
    if (activeCourtIndex.value >= courtList.length) return null;
    return courtList[activeCourtIndex.value];
  }

  String get courtLabel => activeCourt?.productName ?? '-';

  double get pricePerHour => activeCourt?.productPrice ?? 0;

  /// Contoh: "Selasa, 14 Jul 2026".
  String get dateLabel {
    final now = DateTime.now();
    return '${dateFormat.onlyDays.format(now)}, ${dateFormat.dateWithoutTime.format(now)}';
  }

  List<int> get selectedSlot {
    final productId = activeCourt?.productId;
    if (productId == null) return const [];
    return selectionByCourt[productId] ?? const [];
  }

  int get totalHours => selectedSlot.length;

  /// Pecah pilihan jadi blok-blok jam yang berurutan.
  ///
  /// Kasir boleh memilih jam yang meloncat (mis. 15:00 dan 20:00), dan tiap
  /// blok jadi satu baris tersendiri di keranjang.
  List<List<int>> _groupContiguous(List<int> slotList) {
    final sorted = slotList.toList()..sort();
    final groups = <List<int>>[];
    for (final index in sorted) {
      if (groups.isNotEmpty && index == groups.last.last + 1) {
        groups.last.add(index);
      } else {
        groups.add([index]);
      }
    }
    return groups;
  }

  String slotStartLabel(int index) =>
      '${(startHour + index).toString().padLeft(2, '0')}:00';

  String slotEndLabel(int index) =>
      '${(startHour + index + 1).toString().padLeft(2, '0')}:00';

  String slotTimeLabel(int index) =>
      '${slotStartLabel(index)} - ${slotEndLabel(index)}';

  DateTime slotStartDate(int index) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, startHour + index);
  }

  DateTime slotEndDate(int index) =>
      slotStartDate(index).add(const Duration(hours: 1));

  LapanganSlotStatus slotStatus(int index) {
    if (bookedSlot.contains(index)) return LapanganSlotStatus.terisi;
    if (selectedSlot.contains(index)) return LapanganSlotStatus.dipilih;
    // Saat mode dummy, seluruh jam dibiarkan terbuka supaya desain tetap bisa
    // ditinjau kapan pun tanpa separuh grid berubah jadi "Lewat".
    if (!LapanganDummy.enabled && slotEndDate(index).isBefore(DateTime.now())) {
      return LapanganSlotStatus.lewat;
    }
    return LapanganSlotStatus.tersedia;
  }

  String slotStatusLabel(int index) {
    switch (slotStatus(index)) {
      case LapanganSlotStatus.dipilih:
        return 'Dipilih';
      case LapanganSlotStatus.terisi:
        return 'Terisi';
      case LapanganSlotStatus.lewat:
        return 'Lewat';
      case LapanganSlotStatus.tersedia:
        return 'Tersedia';
    }
  }

  /// Ambil semua lapangan (produk sewa per jam) sebagai chip.
  Future<void> doPrepareCourtList() async {
    if (isLoading.value) return;
    isLoading.value = true;

    courtList.value = LapanganDummy.enabled
        ? lapanganDummy.courtList()
        : await _fetchCourtList();
    isLoading.value = false;

    if (courtList.isNotEmpty) {
      if (activeCourtIndex.value >= courtList.length) {
        activeCourtIndex.value = 0;
      }
      await doPrepareSchedule();
    }
    update();
  }

  Future<List<AddonEntity>> _fetchCourtList() async {
    final List<AddonEntity> collected = [];
    try {
      int page = 0;
      int totalPage = 1;
      while (page < totalPage && page < _maxPage) {
        var result;
        result = await _service.sale.addonService.getHourly(
          authToken: _authToken,
          locationId: sessionUtil.getLocationId(),
          page: page,
        );

        bool stop = false;
        result.fold(
          (l) {
            logger.safeLog(l);
            stop = true;
          },
          (r) {
            collected.addAll(r.data ?? <AddonEntity>[]);
            totalPage = r.pagination?.totalPage ?? 1;
          },
        );
        if (stop) break;
        page++;
      }
    } catch (e) {
      logger.safeLog(e);
    }
    return collected;
  }

  /// Tandai slot yang sudah terisi untuk lapangan aktif pada hari ini.
  Future<void> doPrepareSchedule() async {
    final int? productId = activeCourt?.productId;
    if (productId == null) return;
    if (isLoadingSchedule.value) return;
    isLoadingSchedule.value = true;
    bookedSlot.clear();

    final List<TransactionEntity> collected = LapanganDummy.enabled
        ? lapanganDummy.bookedTransactionList(productId)
        : await _fetchBookedTransactionList(productId);

    bookedSlot
      ..clear()
      ..addAll(_mapBookedSlot(collected));

    _dropSelectionOnBookedSlot();
    isLoadingSchedule.value = false;
    update();
  }

  Future<List<TransactionEntity>> _fetchBookedTransactionList(
    int productId,
  ) async {
    final List<TransactionEntity> collected = [];
    try {
      int page = 0;
      int totalPage = 1;
      while (page < totalPage && page < _maxPage) {
        var result;
        result = await _service.transaction.getTransactionRentalHistory(
          authToken: _authToken,
          locId: sessionUtil.getLocationId()!,
          prodId: productId,
          page: page,
        );

        bool stop = false;
        result.fold(
          (l) {
            logger.safeLog(l);
            stop = true;
          },
          (r) {
            collected.addAll(r.data ?? <TransactionEntity>[]);
            totalPage = r.pagination?.totalPage ?? 1;
          },
        );
        if (stop) break;
        page++;
      }
    } catch (e) {
      logger.safeLog(e);
    }
    return collected;
  }

  /// Sebuah slot dianggap terisi bila beririsan dengan salah satu transaksi.
  Set<int> _mapBookedSlot(List<TransactionEntity> transactionList) {
    final booked = <int>{};
    for (final trx in transactionList) {
      final start = trx.startDate;
      final end = trx.endDate;
      if (start == null || end == null) continue;
      for (var index = 0; index < totalSlot; index++) {
        final slotStart = slotStartDate(index);
        final slotEnd = slotEndDate(index);
        if (start.isBefore(slotEnd) && end.isAfter(slotStart)) {
          booked.add(index);
        }
      }
    }
    return booked;
  }

  /// Kalau jadwal terbaru ternyata sudah dibooking orang lain, buang dari pilihan.
  void _dropSelectionOnBookedSlot() {
    final productId = activeCourt?.productId;
    if (productId == null) return;
    final current = selectionByCourt[productId];
    if (current == null || current.isEmpty) return;

    final cleaned = current.where((e) => !bookedSlot.contains(e)).toList()
      ..sort();
    if (cleaned.length == current.length) return;

    selectionByCourt[productId] = cleaned;
    _scheduleSyncCart(activeCourt!);
  }

  void doSelectCourt(int index) {
    if (index == activeCourtIndex.value) return;
    // Tulis dulu pilihan lapangan lama ke keranjang sebelum pindah chip.
    _flushSyncCart();
    activeCourtIndex.value = index;
    update();
    doPrepareSchedule();
  }

  /// Jam bebas dipilih, tidak harus berurutan — kasir boleh mengambil
  /// 15:00 - 16:00 lalu meloncat ke 20:00 - 21:00 dalam satu transaksi.
  void doToggleSlot(int index) {
    final productId = activeCourt?.productId;
    if (productId == null) return;

    final status = slotStatus(index);
    if (status == LapanganSlotStatus.terisi ||
        status == LapanganSlotStatus.lewat) {
      return;
    }

    final current = List<int>.from(selectedSlot);
    if (current.contains(index)) {
      current.remove(index);
    } else {
      current.add(index);
    }
    current.sort();
    selectionByCourt[productId] = current;

    selectionByCourt.refresh();
    update();
    _scheduleSyncCart(activeCourt!);
  }

  /// Dipanggil dari keranjang saat satu baris sewa dihapus lewat tombol hapus.
  ///
  /// Hanya jam pada baris itu yang dilepas — blok lain di lapangan yang sama
  /// tetap terpilih.
  void onCartRentRemoved(CartAddon val) {
    final productId = val.addon?.productId;
    final startDate = val.rentModel?.startDate;
    final endDate = val.rentModel?.endDate;
    if (productId == null || startDate == null || endDate == null) return;

    final current = selectionByCourt[productId];
    if (current == null || current.isEmpty) return;

    selectionByCourt[productId] = current
        .where((index) =>
            !(startDate.isBefore(slotEndDate(index)) &&
                endDate.isAfter(slotStartDate(index))))
        .toList();
    selectionByCourt.refresh();
    update();
  }

  /// Dipanggil dari keranjang saat seluruh pesanan dibersihkan (Batal / selesai bayar).
  void onCartCleared() {
    _syncDebounce?.cancel();
    _pendingCourt = null;
    selectionByCourt.clear();
    update();
    doPrepareSchedule();
  }

  /// Lapangan yang sedang menunggu ditulis ke keranjang oleh [_syncDebounce].
  AddonEntity? _pendingCourt;

  void _scheduleSyncCart(AddonEntity court) {
    _flushSyncCart();
    _pendingCourt = court;
    _syncDebounce = Timer(
      const Duration(milliseconds: 400),
      () => doSyncCart(court),
    );
  }

  /// Jalankan sinkronisasi yang masih tertunda sekarang juga.
  void _flushSyncCart() {
    if (_syncDebounce?.isActive != true) return;
    _syncDebounce!.cancel();
    final court = _pendingCourt;
    _pendingCourt = null;
    if (court != null) doSyncCart(court);
  }

  /// Tulis pilihan jam sebuah lapangan ke keranjang yang sudah ada
  /// (dipakai ulang oleh alur Bayar milik SaleCartPage).
  Future<void> doSyncCart(AddonEntity court) async {
    final productId = court.productId;
    if (productId == null) return;
    if (identical(court, _pendingCourt)) _pendingCourt = null;

    final cart = _cartController;
    // Satu lapangan bisa punya beberapa baris (jam yang meloncat), jadi buang
    // semuanya dulu sebelum ditulis ulang.
    cart.addonList.removeWhere(
      (e) => e.rentModel != null && e.addon?.productId == productId,
    );

    final groups = _groupContiguous(selectionByCourt[productId] ?? const []);
    if (groups.isEmpty) {
      cart.calculateTotalOrder();
      update();
      return;
    }

    isSyncingCart.value = true;
    for (final group in groups) {
      final hours = group.length;
      final double? price = LapanganDummy.enabled
          ? lapanganDummy.priceRental(hours: hours)
          : await _fetchPriceRental(productId: productId, hours: hours);
      if (price == null) continue;

      // Pakai salinan entity supaya harga per jam pada chip tidak ikut tertimpa.
      final AddonEntity booked = AddonEntity.fromJson(court.toJson())
        ..productPrice = price;

      cart.addAddonRent(
        booked,
        CartRentModel(
          startDate: slotStartDate(group.first),
          endDate: slotEndDate(group.last),
          isExtraTime: false,
          totalHours: hours,
          newBuyPrice: price,
        ),
      );
    }
    isSyncingCart.value = false;
    cart.calculateTotalOrder();
    cart.update();
    update();
  }

  /// Harga total untuk [hours] jam, `null` bila gagal diambil.
  Future<double?> _fetchPriceRental({
    required int productId,
    required int hours,
  }) async {
    double? price;
    try {
      var result;
      result = await _service.rental.getPriceRental(
        authToken: _authToken,
        hours: hours,
        productId: productId,
      );

      result.fold(
        (l) {
          logger.safeLog(l);
          alert.error('Terjadi Kesalahan!', l);
        },
        (r) {
          price = (r.data ?? 0).toDouble();
        },
      );
    } catch (e) {
      logger.safeLog(e);
    }
    return price;
  }
}
