import 'dart:async';

import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/common/session_util.dart';
import 'package:jaya_propertiy/app/utils/constant/date_format_constant.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/data/models/cart/cart_addon_model.dart';
import 'package:jaya_propertiy/data/models/cart/cart_rent_model.dart';
import 'package:jaya_propertiy/data/services/main_service.dart';
import 'package:jaya_propertiy/domain/entities/sale/addon_entity.dart';
import 'package:jaya_propertiy/domain/entities/sale/ticket_entity.dart';
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

  /// Jam buka & tutup jadwal sepenuhnya diturunkan dari setup harga tiket
  /// lapangan aktif (ticket_price_time): [startHour] = jam mulai paling awal,
  /// [closeHour] = jam tutup paling akhir. Tidak ada jadwal hardcode — bila
  /// tiket belum punya rentang harga, jadwal kosong ([totalSlot] = 0).
  int get startHour => _activeCourtHourRange()?[0] ?? 0;
  int get closeHour => _activeCourtHourRange()?[1] ?? 0;
  int get totalSlot => closeHour > startHour ? closeHour - startHour : 0;

  /// `[startHour, endHour]` dari rentang harga tiket lapangan aktif, atau `null`
  /// bila tidak ada. endHour bersifat eksklusif (jam tutup), sejalan dengan
  /// semantik harga `startHour <= jam < endHour` di [_calculateTicketPrice].
  List<int>? _activeCourtHourRange() {
    final productId = activeCourt?.productId;
    if (productId == null) return null;
    final priceTimes = _ticketPriceTimesMap[productId];
    if (priceTimes == null || priceTimes.isEmpty) return null;

    int? minStart;
    int? maxEnd;
    for (final pt in priceTimes) {
      final s = pt.startHour;
      final e = pt.endHour;
      if (s == null || e == null) continue;
      if (minStart == null || s < minStart) minStart = s;
      if (maxEnd == null || e > maxEnd) maxEnd = e;
    }
    if (minStart == null || maxEnd == null || maxEnd <= minStart) return null;
    return [minStart, maxEnd];
  }

  final courtList = <AddonEntity>[].obs;
  final activeCourtIndex = 0.obs;

  /// Mapping dari productId tiket lapangan ke ticketPriceTimes untuk kalkulasi harga.
  /// Key: ticketId (sama dengan productId di AddonEntity)
  /// Value: List<TicketPriceTimeEntity> dari TicketEntity
  final Map<int, List<TicketPriceTimeEntity>> _ticketPriceTimesMap = {};

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
    if (slotEndDate(index).isBefore(DateTime.now())) {
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

  /// Ambil semua lapangan (tiket dengan ticket_fl_lapangan='Y').
  Future<void> doPrepareCourtList() async {
    if (isLoading.value) return;
    isLoading.value = true;

    // HANYA ambil tiket lapangan (ticket_fl_lapangan='Y'); lapangan nempel di
    // tiket, bukan produk hourly.
    courtList.value = await _fetchLapanganTickets();

    isLoading.value = false;

    if (courtList.isNotEmpty) {
      if (activeCourtIndex.value >= courtList.length) {
        activeCourtIndex.value = 0;
      }
      await doPrepareSchedule();
    }
    update();
  }

  /// Ambil tiket lapangan (ticket_fl_lapangan='Y') dari mst_ticket.
  Future<List<AddonEntity>> _fetchLapanganTickets() async {
    final List<AddonEntity> collected = [];
    try {
      Map<String, dynamic> param = {
        'locationId': sessionUtil.getLocationIdsQueryParam(),
      };

      var result = await _service.sale.ticketService.getLapangan(
        authToken: _authToken,
        paramsFilter: param,
      );

      result.fold(
        (l) {
          logger.safeLog(l);
        },
        (r) {
          // Konversi TicketEntity ke AddonEntity
          final tickets = r.data ?? [];
          for (final ticket in tickets) {
            final addon = _convertTicketToAddon(ticket);
            collected.add(addon);
            
            // Simpan ticketPriceTimes untuk digunakan saat kalkulasi harga
            final ticketId = ticket.ticketId;
            final priceTimes = ticket.ticketPriceTimes;
            if (ticketId != null && priceTimes != null) {
              _ticketPriceTimesMap[ticketId] = priceTimes;
            }
          }
        },
      );
    } catch (e) {
      logger.safeLog(e);
    }
    return collected;
  }

  /// Konversi TicketEntity ke AddonEntity agar bisa dipakai di UI lapangan.
  AddonEntity _convertTicketToAddon(dynamic ticket) {
    return AddonEntity(
      productId: ticket.ticketId,
      productName: ticket.ticketName,
      productType: 'L', // L = Lapangan (dari tiket)
      productPrice: ticket.ticketPrice,
      productLoc: ticket.ticketLocation,
      productLocName: ticket.ticketLocationName,
      productState: ticket.ticketState,
      pathImg: ticket.pathImg,
      minRentPrd: ticket.ticketMinimum,
      productRentType: 'H', // Hourly
    );
  }

  /// Tandai slot yang sudah terisi untuk lapangan aktif pada hari ini.
  Future<void> doPrepareSchedule() async {
    final int? productId = activeCourt?.productId;
    if (productId == null) return;
    if (isLoadingSchedule.value) return;
    isLoadingSchedule.value = true;
    bookedSlot.clear();

    final List<int> bookedHours = await _fetchBookedHours(productId);

    bookedSlot
      ..clear()
      ..addAll(_hoursToSlotIndexes(bookedHours));

    _dropSelectionOnBookedSlot();
    isLoadingSchedule.value = false;
    update();
  }

  /// Ambil jam terisi court dari endpoint booking yang benar
  /// (`mst_ticket/lapangan/booked`, membaca `trn_order_booked`). Ini sumber
  /// yang tepat untuk booking berbasis tiket — endpoint rental-history lama
  /// menyasar `trn_order_addon` sehingga tak pernah menandai slot lapangan.
  Future<List<int>> _fetchBookedHours(int productId) async {
    try {
      final now = DateTime.now();
      final String date =
          '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      final result = await _service.sale.ticketService.getBookedHours(
        authToken: _authToken,
        ticketId: productId,
        date: date,
      );

      List<int> hours = <int>[];
      result.fold(
        (l) => logger.safeLog(l),
        (r) => hours = r,
      );
      return hours;
    } catch (e) {
      logger.safeLog(e);
      return <int>[];
    }
  }

  /// Konversi jam absolut dari server (mis. 15) ke index sel grid
  /// (`jam - startHour`). Jam di luar rentang jadwal aktif diabaikan.
  Set<int> _hoursToSlotIndexes(List<int> hours) {
    final booked = <int>{};
    for (final hour in hours) {
      final index = hour - startHour;
      if (index >= 0 && index < totalSlot) {
        booked.add(index);
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
      final double? price =
          await _fetchPriceRental(productId: productId, hours: hours);
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
  /// 
  /// Untuk produk (product_type='H'), ambil dari endpoint mst_product_time/range.
  /// Untuk tiket lapangan (product_type='L'), hitung dari ticketPriceTimes.
  Future<double?> _fetchPriceRental({
    required int productId,
    required int hours,
  }) async {
    double? price;
    
    // Cek apakah ini tiket lapangan atau produk hourly
    final court = courtList.firstWhere(
      (c) => c.productId == productId,
      orElse: () => AddonEntity(),
    );
    
    // Jika ini tiket lapangan (type='L'), hitung harga dari ticketPriceTimes
    if (court.productType == 'L') {
      price = _calculateTicketPrice(productId);
      if (price == null) {
        alert.error('Error', 'Harga untuk durasi $hours jam tidak ditemukan');
      }
      return price;
    }
    
    // Jika ini produk hourly, ambil dari backend seperti biasa
    try {
      final result = await _service.rental.getPriceRental(
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
  
  /// Hitung harga booking tiket lapangan berdasarkan jam yang dipilih.
  /// 
  /// Menggunakan data ticketPriceTimes yang sudah diambil dari backend.
  /// Logic mengikuti backend resolveBookPrice(): untuk setiap jam,
  /// cari rentang harga yang cocok (startHour <= hour < endHour).
  double? _calculateTicketPrice(int ticketId) {
    try {
      // Ambil ticketPriceTimes dari map
      final priceTimes = _ticketPriceTimesMap[ticketId];
      if (priceTimes == null || priceTimes.isEmpty) {
        logger.safeLog('ticketPriceTimes tidak ditemukan untuk ticket $ticketId');
        return null;
      }
      
      // Ambil slot yang dipilih
      final selectedSlots = selectionByCourt[ticketId] ?? [];
      if (selectedSlots.isEmpty) return null;
      
      double totalPrice = 0;
      
      // Loop setiap jam yang dipilih untuk menghitung harga
      for (final slotIndex in selectedSlots) {
        // Konversi slot index ke jam (0 = 06:00, 1 = 07:00, dst)
        final hour = startHour + slotIndex;
        
        // Cari harga yang cocok dengan jam ini
        double? hourPrice;
        for (final priceTime in priceTimes) {
          final startHourPrice = priceTime.startHour;
          final endHourPrice = priceTime.endHour;
          final priceValue = priceTime.price;
          
          if (startHourPrice == null || endHourPrice == null || priceValue == null) {
            continue;
          }
          
          // Semantik: hour cocok jika startHour <= hour < endHour
          if (startHourPrice <= hour && hour < endHourPrice) {
            hourPrice = priceValue;
            break;
          }
        }
        
        if (hourPrice == null) {
          logger.safeLog('Harga untuk jam $hour:00 tidak ditemukan di ticketPriceTimes');
          return null;
        }
        
        totalPrice += hourPrice;
      }
      
      return totalPrice;
    } catch (e) {
      logger.safeLog('Error calculating ticket price: $e');
      return null;
    }
  }
}
