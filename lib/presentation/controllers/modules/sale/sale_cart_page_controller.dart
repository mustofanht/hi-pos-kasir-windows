import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/display_util.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/data/models/cart/cart_addon_model.dart';
import 'package:jaya_propertiy/data/models/cart/cart_deposit_model.dart';
import 'package:jaya_propertiy/data/models/cart/cart_model.dart';
import 'package:jaya_propertiy/data/models/cart/cart_rent_model.dart';
import 'package:jaya_propertiy/data/models/cart/cart_ticket_mode.dart';
import 'package:jaya_propertiy/data/models/cart/cart_potongan_model.dart';
import 'package:jaya_propertiy/data/models/cart/cart_voucher_model.dart';
import 'package:jaya_propertiy/data/models/cart/voucher_unit.dart';
import 'package:jaya_propertiy/data/models/customer/customer_display_model.dart';
import 'package:jaya_propertiy/data/models/customer/customer_sale_cart_model.dart';
import 'package:jaya_propertiy/data/services/main_service.dart';
import 'package:jaya_propertiy/domain/entities/masterdata/mst_payment.dart';
import 'package:jaya_propertiy/domain/entities/member/member_valid.dart';
import 'package:jaya_propertiy/domain/entities/sale/addon_entity.dart';
import 'package:jaya_propertiy/domain/entities/sale/deposit_entity.dart';
import 'package:jaya_propertiy/domain/entities/sale/potongan_entity.dart';
import 'package:jaya_propertiy/domain/entities/sale/ticket_bundle_entity.dart';
import 'package:jaya_propertiy/domain/entities/sale/ticket_entity.dart';
import 'package:jaya_propertiy/domain/entities/sale/voucher_entity.dart';
import 'package:jaya_propertiy/presentation/components/custom_alert.dart';
import 'package:jaya_propertiy/presentation/components/custom_dialog.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/sale/sale_addon_page_controller.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/sale/sale_lapangan_page_controller.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/sale/sale_ticket_page_controller.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/sale/sale_voucher_page_controller.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/sale_page_controller.dart';

/// True hanya bila controller-nya SUDAH benar-benar dibuat.
///
/// `Get.isRegistered` juga bernilai true untuk `lazyPut` yang belum pernah
/// dipakai — dan memanggil `Get.find` dalam kondisi itu justru MEMBUAT
/// instance-nya saat itu juga. Itu berbahaya di sini, karena pembersihan
/// keranjang berjalan ketika dialog loading masih terbuka: pada saat itu
/// `Get.arguments` bukan lagi milik HomePage melainkan null, padahal seluruh
/// Sale*Controller membaca `Get.arguments[argConstant.authToken]` di field
/// initializer-nya. Akibatnya `NoSuchMethodError: []("token")` yang ditelan
/// try/catch, dan sisa `clearCartOrder()` — termasuk `openPayment(false)` —
/// batal dijalankan sehingga kasir tertinggal di form pembayaran.
///
/// Tab yang belum pernah dibuka juga memang tidak perlu dimuat ulang.
bool _sudahDibuat<T>() => Get.isRegistered<T>() && !Get.isPrepared<T>();

class SaleCartPageController extends GetxController {
  SaleCartPageController();
  final SalePageController salePageController = Get.find<SalePageController>();
  DisplayUtil displayUtil = DisplayUtil();
  final _service = MainService();
  final _authToken = Get.arguments[argConstant.authToken];

  var totalOrderAmnt = RxDouble(0);
  var finalTotalOrderAmt = RxDouble(0);
  var totalOrderQty = RxInt(0);

  final addonList = RxList<CartAddon>([]);
  final ticketList = RxList<CartTicket>([]);

  /// Merchandise yang otomatis ikut karena tiketnya dibundel (mst_ticket_bundle,
  /// tipe MANDATORY). Dipisah dari [addonList] supaya tidak bisa diubah/dihapus
  /// kasir — isinya selalu turunan dari tiket yang ada di keranjang.
  final bundleList = RxList<CartAddon>([]);

  /// Cache aturan bundling per tiket, agar keranjang tidak memanggil backend
  /// setiap kali qty tiket berubah. Hanya berlaku selama tiket itu ada di
  /// keranjang: diambil ulang saat tiket masuk keranjang, saat halaman Ticket
  /// di-refresh, dan sebelum membuka pembayaran (lihat [muatUlangBundle]) —
  /// perubahan aturan di back office tidak menunggu kasir logout.
  final Map<int, List<TicketBundleEntity>> _aturanBundle = {};
  final potonganList = RxList<CartPotongan>([]);
  final voucherList = RxList<CartVoucher>([]);
  final depositList = RxList<CartDeposit>([]);
  late var orderList = Cart(
    cartTicketList: ticketList,
    cartPotonganList: potonganList,
    cartVoucherList: voucherList,
    cartDepositList: depositList,
    addonList: addonList,
  ).obs;

  final selectedMstPayment = MstPayment().obs;

  final memberVoucher = false.obs;
  final memberValid = MemberValid().obs;

  final Map<int, TextEditingController> ticketControllers = {};

  TextEditingController getTicketController(int id, int qtyOrder) {
    if (!ticketControllers.containsKey(id)) {
      ticketControllers[id] = TextEditingController(text: qtyOrder.toString());
    }
    return ticketControllers[id]!;
  }

  /// Kotak qty untuk barang (addon), sejajar dengan tiket. Satu barang hanya
  /// pernah muncul sekali di keranjang (lihat `addAddonToCart`), jadi aman
  /// dikunci dengan productId.
  final Map<int, TextEditingController> addonControllers = {};

  TextEditingController getAddonController(int id, int qtyOrder) {
    if (!addonControllers.containsKey(id)) {
      addonControllers[id] = TextEditingController(text: qtyOrder.toString());
    }
    return addonControllers[id]!;
  }

  // ── Batas stok di keranjang ──────────────────────────────────────────────
  // Pengecekan di layar pilih barang saja tidak cukup: dari keranjang, tombol
  // "+" dan kotak qty bisa menaikkan jumlah tanpa melewati layar itu lagi.
  // Backend tetap memvalidasi ulang saat order disimpan; pemeriksaan di sini
  // supaya kasir tahu sebelum menagih, bukan setelahnya.

  /// Sisa stok yang boleh dipesan, atau null bila barangnya tidak dipantau.
  double? _sisaStok(AddonEntity? addon) {
    if (addon == null || !addon.isInventoryTracked) return null;
    return addon.stockAvailable ?? 0;
  }

  void _peringatanStok(AddonEntity addon, double sisa) {
    alert.warning(
      'Stok Tidak Cukup',
      'Sisa ${addon.productName} tinggal '
          '${sisa.toStringAsFixed(0)} ${addon.stockUom ?? 'pcs'}.',
    );
  }

  /// Samakan isi kotak qty dengan nilai sesungguhnya, tanpa memindahkan kursor
  /// ke awal — kalau kursornya melompat, mengetik angka dua digit jadi kacau.
  void _sinkronKotakAddon(CartAddon val) {
    final id = val.addon?.productId;
    if (id == null) return;
    final teks = (val.qtyOrder ?? 0).toString();
    final kotak = addonControllers[id];
    if (kotak == null || kotak.text == teks) return;
    kotak.value = TextEditingValue(
      text: teks,
      selection: TextSelection.collapsed(offset: teks.length),
    );
  }

  /// Qty diketik langsung di keranjang. Nilai yang melebihi sisa stok dipangkas
  /// ke sisa yang ada, bukan ditolak — operator sudah tahu mau berapa, yang
  /// perlu diberi tahu adalah batasnya.
  onChangeQtyAddonCart(CartAddon val, int qty) {
    if (qty < 1) return;
    final sisa = _sisaStok(val.addon);
    if (sisa != null && qty > sisa) {
      qty = sisa.toInt();
      _peringatanStok(val.addon!, sisa);
    }
    val.qtyOrder = qty;
    val.totalPrice = (val.addon?.productPrice ?? 0) * qty;
    _sinkronKotakAddon(val);
    calculateTotalOrder();
  }

  /// Dipanggil saat selesai mengetik: kotak yang dikosongkan dikembalikan ke 1
  /// supaya keranjang tidak pernah menyimpan baris berjumlah nol.
  onCompleteQtyAddonCart(CartAddon val) {
    final id = val.addon?.productId;
    final teks = id == null ? null : addonControllers[id]?.text;
    final qty = int.tryParse(teks ?? '') ?? 0;
    if (qty < 1) {
      val.qtyOrder = 1;
      val.totalPrice = val.addon?.productPrice ?? 0;
      _sinkronKotakAddon(val);
      calculateTotalOrder();
    }
  }

  // ── Playground: input nama anak per tiket ────────────────────────────────
  // Muncul HANYA untuk tiket berkategori PLGRD (playground), berapa pun qty-nya
  // (termasuk 1 tiket). Tiket non-playground TIDAK pernah minta nama anak,
  // walau qty > 1. Nama anak dikirim ke backend (childNames) dan ditampilkan
  // per gelang di papan TV.
  final List<TextEditingController> childNameControllers = [];

  bool get isPlaygroundCart =>
      ticketList.isNotEmpty && ticketList.any((e) => e.ticket?.isPlayground == true);

  int get totalTicketQty =>
      ticketList.fold(0, (sum, e) => sum + (e.qtyOrder ?? 0));

  // Jumlah unit tiket khusus kategori playground (non-playground diabaikan).
  int get playgroundTicketQty => ticketList
      .where((e) => e.ticket?.isPlayground == true)
      .fold(0, (sum, e) => sum + (e.qtyOrder ?? 0));

  bool get needChildNames => playgroundTicketQty > 0;

  // Grow-only: hindari dispose saat rebuild/focus. Dibersihkan di clearCartOrder.
  TextEditingController childNameControllerAt(int index) {
    while (childNameControllers.length <= index) {
      childNameControllers.add(TextEditingController());
    }
    return childNameControllers[index];
  }

  // Nama anak sepanjang jumlah tiket PLAYGROUND (urut sesuai ekspansi listTicket
  // di backend; backend hanya memetakan childNames saat lokasi order = PLGRD).
  List<String> get childNames =>
      List.generate(
          playgroundTicketQty, (i) => childNameControllerAt(i).text.trim());

  bool validateChildNames() {
    if (!needChildNames) return true;
    for (int i = 0; i < playgroundTicketQty; i++) {
      if (childNameControllerAt(i).text.trim().isEmpty) return false;
    }
    return true;
  }

  void _disposeChildNameControllers() {
    for (final c in childNameControllers) {
      c.dispose();
    }
    childNameControllers.clear();
  }

  // ── Tiket Bundling Merchandise ───────────────────────────────────────────
  // Sebagian tiket menempel merchandise (mis. snack / goodie bag). Kasir harus
  // menampilkan & menagihnya, karena bila hanya server yang menyisipkan, total
  // di layar kasir akan lebih kecil dari yang dibukukan untuk bundling BERBAYAR.
  // Harga tetap dihitung ulang backend; yang di sini semata agar angka di layar
  // sama dengan angka yang ditagih.

  /// Ambil (dan cache) aturan bundling satu tiket. [segarkan] melewati cache.
  Future<List<TicketBundleEntity>> _muatAturanBundle(
    int ticketId, {
    bool segarkan = false,
  }) async {
    final tersimpan = _aturanBundle[ticketId];
    if (tersimpan != null && !segarkan) return tersimpan;

    final hasil = await _service.sale.ticketBundleService.getByTicket(
      authToken: _authToken,
      ticketId: ticketId,
    );
    final aturan = hasil.fold<List<TicketBundleEntity>?>(
      (error) {
        // Bundling gagal dimuat bukan alasan menahan penjualan tiket: server
        // tetap menyisipkan merchandise wajibnya saat order disimpan.
        logger.safeLog('Gagal memuat bundling tiket $ticketId: $error');
        return null;
      },
      (response) => response.data ?? <TicketBundleEntity>[],
    );
    // Gagal memuat: pakai aturan terakhir yang diketahui, dan jangan simpan hasil
    // kosong — kalau disimpan, merchandise wajib hilang dari keranjang sampai
    // cache dibersihkan, padahal server tetap menagihnya.
    if (aturan == null) return tersimpan ?? <TicketBundleEntity>[];
    _aturanBundle[ticketId] = aturan;
    return aturan;
  }

  /// Jumlah tiket terbanyak yang masih bisa dijual dengan stok merchandise yang
  /// ada. null = tidak dibatasi stok.
  int? _batasTiketDariStok(List<TicketBundleEntity> aturan) {
    int? batas;
    for (final r in aturan) {
      if (!r.isMandatory) continue;
      final maks = r.maxTicketByStock();
      if (maks == null) continue;
      batas = batas == null || maks < batas ? maks : batas;
    }
    return batas;
  }

  /// true bila tiket boleh dijual sebanyak [qtyTiket]. Menampilkan peringatan
  /// dan mengembalikan false bila stok merchandise bundlingnya tidak cukup.
  Future<bool> _stokBundleCukup(TicketEntity ticket, int qtyTiket) async {
    final id = ticket.ticketId;
    if (id == null || qtyTiket <= 0) return true;
    final aturan = await _muatAturanBundle(id);
    final batas = _batasTiketDariStok(aturan);
    if (batas == null || qtyTiket <= batas) return true;

    final kurang = aturan.firstWhere(
      (r) => r.isMandatory && (r.maxTicketByStock() ?? 1 << 30) < qtyTiket,
      orElse: () => aturan.first,
    );
    alert.warning(
      'Stok Bundling Tidak Cukup',
      batas <= 0
          ? 'Stok ${kurang.bundleProductName} habis, sedangkan tiket '
              '${ticket.ticketName} wajib disertai item tersebut. '
              'Tiket ini belum bisa dijual.'
          : 'Stok ${kurang.bundleProductName} hanya cukup untuk $batas tiket '
              '${ticket.ticketName}.',
    );
    return false;
  }

  /// Ambil ulang aturan bundling semua tiket di keranjang dari server, lalu
  /// susun ulang [bundleList]. Mengembalikan true bila isi bundling berubah
  /// (merchandise, qty, atau nominalnya).
  Future<bool> muatUlangBundle() async {
    final idTiket = ticketList
        .map((t) => t.ticket?.ticketId)
        .whereType<int>()
        .toSet();
    _aturanBundle.removeWhere((id, _) => !idTiket.contains(id));
    if (idTiket.isEmpty) return false;

    final sebelum = _jejakBundle();
    await Future.wait(
      idTiket.map((id) => _muatAturanBundle(id, segarkan: true)),
    );
    await refreshBundle();
    return _jejakBundle() != sebelum;
  }

  String _jejakBundle() => bundleList
      .map((b) => '${b.addon?.productId}:${b.qtyOrder}:${b.totalPrice}')
      .join('|');

  /// Susun ulang [bundleList] dari isi keranjang tiket saat ini.
  ///
  /// Satu produk hanya boleh satu baris (kunci order+produk di backend), jadi
  /// merchandise yang sama dari dua tiket berbeda DIGABUNG qty & nominalnya.
  Future<void> refreshBundle() async {
    final Map<int, CartAddon> gabungan = {};

    for (final t in ticketList) {
      final ticketId = t.ticket?.ticketId;
      final qtyTiket = t.qtyOrder ?? 0;
      if (ticketId == null || qtyTiket <= 0) continue;

      for (final r in await _muatAturanBundle(ticketId)) {
        final productId = r.bundleProductId;
        if (!r.isMandatory || productId == null) continue;

        final qty = qtyTiket * (r.bundleQty ?? 1);
        final nominal = r.unitPrice * qty;
        final adaSebelumnya = gabungan[productId];
        if (adaSebelumnya == null) {
          gabungan[productId] = CartAddon(
            qtyOrder: qty,
            totalPrice: nominal,
            bundleId: r.bundleId,
            addon: AddonEntity(
              productId: productId,
              productName: r.bundleProductName,
              productType: 'J',
              productPrice: r.unitPrice,
              productFlInventory: r.bundleProductFlInventory,
              stockAvailable: r.bundleProductStock,
            ),
          );
        } else {
          adaSebelumnya.qtyOrder = (adaSebelumnya.qtyOrder ?? 0) + qty;
          adaSebelumnya.totalPrice = (adaSebelumnya.totalPrice ?? 0) + nominal;
        }
      }
    }

    bundleList.assignAll(gabungan.values.toList());
    calculateTotalOrder();
  }

  addTicket(TicketEntity ticket) async {
    // Tiket baru masuk keranjang: selalu pakai aturan bundling terbaru.
    if (ticket.ticketId != null) {
      await _muatAturanBundle(ticket.ticketId!, segarkan: true);
    }
    if (!await _stokBundleCukup(ticket, ticket.ticketMinimum ?? 1)) return;
    ticketList.add(
      CartTicket(
        qtyOrder: ticket.ticketMinimum,
        ticket: ticket,
        totalPrice: (ticket.ticketMinimum ?? 0) * ticket.ticketPrice!,
      ),
    );
    ticketControllers[ticket.ticketId]?.text = ticket.ticketMinimum.toString();
    checkQtyMemberVocuher();
    calculateTotalOrder();
    await refreshBundle();
  }

  onCompleteQtyTicketCart(CartTicket ticket) {
    logger.safeLog('QTY: ${ticketControllers[ticket.ticket?.ticketId]?.text}');
    logger.safeLog('MINIMUM: ${ticket.ticket?.ticketMinimum}');
    int qty = int.parse(ticketControllers[ticket.ticket?.ticketId]!.text);
    if (qty < (ticket.ticket?.ticketMinimum ?? 0)) {
      ticketControllers[ticket.ticket?.ticketId]?.text =
          ticket.ticket!.ticketMinimum.toString();
    }
    calculateTotalOrder();
  }

  onChangeQtyTicketCart(CartTicket ticket, int qty) async {
    logger.safeLog('QTY: ${qty}');
    logger.safeLog('MINIMUM: ${ticket.ticket?.ticketMinimum}');
    if (qty < (ticket.ticket?.ticketMinimum ?? 0)) {
      return;
    }
    if (!await _stokBundleCukup(ticket.ticket!, qty)) return;
    ticket.qtyOrder = qty;
    ticket.totalPrice = ((ticket.ticket!.ticketPrice ?? 0) * qty);
    calculateTotalOrder();
    await refreshBundle();
  }

  addTicketCart(CartTicket ticket) async {
    if (!await _stokBundleCukup(ticket.ticket!, (ticket.qtyOrder ?? 0) + 1)) {
      return;
    }
    ticket.qtyOrder = (ticket.qtyOrder ?? 0) + 1;
    ticket.totalPrice =
        ((ticket.totalPrice ?? 0) + (ticket.ticket!.ticketPrice ?? 0));
    ticketControllers[ticket.ticket?.ticketId]?.text =
        ticket.qtyOrder.toString();
    checkQtyMemberVocuher();
    calculateTotalOrder();
    await refreshBundle();
  }

  removeTicket(CartTicket ticket) {
    // logger.safeLog('voucherList LENGTH : ${voucherList.length}');
    // logger.safeLog(
    //     'voucherList.first.selectedMemberAnggota LENGTH : ${voucherList.first.selectedMemberAnggota?.length}');
    // if (memberVoucher.isTrue) {
    //   if (voucherList.isNotEmpty) {
    //     if (voucherList.first.selectedMemberAnggota != null &&
    //         voucherList.first.selectedMemberAnggota!.isNotEmpty) {
    //       int qtyCurr = (ticket.qtyOrder ?? 0) - 1;
    //       int totalQtyVoucher = 0;
    //       for (var element in voucherList) {
    //         totalQtyVoucher += (element.qtyOrder ?? 0);
    //       }
    //       if (qtyCurr < totalQtyVoucher) {
    //         alert.warning(
    //             'Warning', 'Qty Ticket tidak bisa kurang dari qty voucher!');
    //         return;
    //       }
    //     }
    //   }
    // }
    if (voucherList.isNotEmpty) {
      int qtyCurr = (ticket.qtyOrder ?? 0) - 1;
      int totalQtyVoucher = 0;
      for (var element in voucherList) {
        totalQtyVoucher += (element.qtyOrder ?? 0);
      }
      if (qtyCurr < totalQtyVoucher) {
        alert.warning(
            'Warning', 'Qty Ticket tidak bisa kurang dari qty voucher!');
        return;
      }
    }

    ticket.qtyOrder = (ticket.qtyOrder ?? 0) - 1;
    ticket.totalPrice =
        (ticket.totalPrice ?? 0) - (ticket.ticket!.ticketPrice ?? 0);
    if (ticket.qtyOrder == 0) {
      removeListTicket(ticket);
    }
    ticketControllers[ticket.ticket?.ticketId]?.text =
        ticket.qtyOrder.toString();
    checkQtyMemberVocuher();
    calculateTotalOrder();
    refreshBundle();
  }

  removeListTicket(CartTicket ticket) {
    ticketControllers[ticket.ticket?.ticketId]?.clear();
    ticketList.remove(ticket);
    calculateTotalOrder();
    refreshBundle();
  }

  addAddon(AddonEntity val) {
    addonList.add(
      CartAddon(
        qtyOrder: 1,
        totalPrice: val.productPrice ?? 0,
        addon: val,
      ),
    );
    calculateTotalOrder();
  }

  addAddonRent(AddonEntity val, CartRentModel rentModel) {
    addonList.add(
      CartAddon(
        qtyOrder: 1,
        totalPrice: val.productPrice!,
        addon: val,
        rentModel: rentModel,
      ),
    );
    calculateTotalOrder();
  }

  addAddonCart(CartAddon val) {
    if (val.rentModel != null) {
    } else {
      final sisa = _sisaStok(val.addon);
      if (sisa != null && (val.qtyOrder ?? 0) + 1 > sisa) {
        _peringatanStok(val.addon!, sisa);
        return;
      }
      val.qtyOrder = (val.qtyOrder ?? 0) + 1;
      val.totalPrice = (val.totalPrice ?? 0) + (val.addon!.productPrice ?? 0);
      _sinkronKotakAddon(val);
      calculateTotalOrder();
    }
  }

  removeAddon(CartAddon val) {
    val.qtyOrder = (val.qtyOrder ?? 0) - 1;
    val.totalPrice = (val.totalPrice ?? 0) - (val.addon!.productPrice ?? 0);
    if (val.qtyOrder == 0) {
      removeListAddon(val);
    } else {
      _sinkronKotakAddon(val);
    }
    calculateTotalOrder();
  }

  removeListAddon(CartAddon val) {
    addonControllers.remove(val.addon?.productId)?.dispose();
    addonList.remove(val);
    if (val.rentModel != null) {
      // Lepas juga pilihan jam pada tab Booking Lapangan.
      _lapanganController?.onCartRentRemoved(val);
    }
    calculateTotalOrder();
  }

  SaleLapanganPageController? get _lapanganController =>
      _sudahDibuat<SaleLapanganPageController>()
          ? Get.find<SaleLapanganPageController>()
          : null;

  /// Muat ulang daftar semua tab penjualan (Ticket, Lapangan, Potongan, Item)
  /// langsung dari server supaya status/stok/harga tersinkron tanpa perlu
  /// logout ulang. Dipanggil setiap transaksi selesai (lihat [clearCartOrder]):
  /// mis. status item aula berubah "Terpakai" atau slot lapangan jadi terisi
  /// akan langsung terlihat begitu order beres.
  void refreshSaleLists() {
    try {
      if (_sudahDibuat<SaleTicketPageController>()) {
        Get.find<SaleTicketPageController>().doPrepareList(page: 0);
      }
      if (_sudahDibuat<SaleLapanganPageController>()) {
        Get.find<SaleLapanganPageController>().doPrepareCourtList();
      }
      if (_sudahDibuat<SaleVoucherPageController>()) {
        Get.find<SaleVoucherPageController>().doPrepareList(page: 0);
      }
      if (_sudahDibuat<SaleAddonPageController>()) {
        final addonController = Get.find<SaleAddonPageController>();
        addonController.doPrepareList(
          page: 0,
          typeProduct: addonController.selectedTypeItemList.value.id ?? 'H',
        );
      }
    } catch (e) {
      logger.safeLog(e);
    }
  }

  addpotongan(PotonganEntity potongan) {
    if (memberVoucher.isTrue) {
      alert.warning('Warning', 'Potongan tidak bisa di gunakan!');
      return;
    }
    potonganList.add(
      CartPotongan(
        qtyOrder: 1,
        totalPrice: potongan.voucherUnitValue!,
        potongan: potongan,
      ),
    );
    calculateTotalOrder();
  }

  removeListpotongan(CartPotongan potongan) {
    potonganList.remove(potongan);
    calculateTotalOrder();
  }

  bool validateVoucher(int qtyOrder, VoucherEntity voucher) {
    bool isValid = true;
    if (memberVoucher.isTrue) {
      alert.warning('Warning', 'Voucher tidak bisa di gunakan!');
      isValid = false;
    }

    if ((qtyOrder + 1) > (voucher.vpLimit ?? 0)) {
      alert.warning(
        'Warning',
        'Limit Voucher tersisa ${voucher.vpLimit ?? 0}',
      );
      isValid = false;
    }

    if (voucherList.isNotEmpty) {
      // Unit eligible voucher = tiket + jam booking lapangan (1 voucher = 1 jam).
      int qtyAllTiket = countVoucherUnits(
        ticketList: ticketList,
        addonList: addonList,
      );
      int qtyAllVoucher = 0;
      for (var element in voucherList) {
        qtyAllVoucher += (element.qtyOrder ?? 0);
      }

      logger.safeLog('qtyAllVoucher : $qtyAllVoucher');
      logger.safeLog('qtyAllTiket : $qtyAllTiket');
      if ((qtyAllVoucher + 1) > qtyAllTiket) {
        alert.warning('Warning', 'Qty Voucher tidak bisa melebihi qty tiket');
        isValid = false;
      }
    }
    return isValid;
  }

  addvoucher(VoucherEntity voucher) {
    // if (memberVoucher.isTrue) {
    //   alert.warning('Warning', 'Voucher tidak bisa di gunakan!');
    //   return;
    // }
    // bool isValid = validateVoucher(1, voucher);
    bool isValid = validateVoucher(0, voucher);
    if (!isValid) return;

    voucherList.add(
      CartVoucher(
        qtyOrder: 1,
        totalPrice: 1 * voucher.vpUnitValue!,
        entity: voucher,
      ),
    );
    calculateTotalOrder();
  }

  addVoucherCart(CartVoucher voucher) {
    // if (memberVoucher.isTrue) {
    //   alert.warning('Warning', 'Voucher tidak bisa di gunakan!');
    //   return;
    // }

    // if (((voucher.qtyOrder ?? 0) + 1) > (voucher.entity?.vpLimit ?? 0)) {
    //   alert.warning(
    //     'Warning',
    //     'Limit Voucher tersisa ${voucher.entity?.vpLimit ?? 0}',
    //   );
    //   return;
    // }
    // if (voucherList.isNotEmpty) {
    //   int qtyAllTiket = 0;
    //   for (var element in ticketList) {
    //     qtyAllTiket += (element.qtyOrder ?? 0);
    //   }
    //   // logger.safeLog('voucher.qtyOrder : ${voucher.qtyOrder}');
    //   // logger.safeLog('qtyAllTiket : $qtyAllTiket');
    //   if (((voucher.qtyOrder ?? 0) + 1) > qtyAllTiket) {
    //     alert.warning('Warning', 'Qty Voucher tidak bisa melebihi qty tiket');
    //     return;
    //   }
    // }

    bool isValid = validateVoucher((voucher.qtyOrder ?? 0), voucher.entity!);
    if (!isValid) return;

    voucher.qtyOrder = (voucher.qtyOrder ?? 0) + 1;
    voucher.totalPrice =
        ((voucher.totalPrice ?? 0) + (voucher.entity!.vpUnitValue ?? 0));
    calculateTotalOrder();
  }

  removeListvoucher(CartVoucher voucher) {
    voucherList.remove(voucher);
    if (memberVoucher.isTrue) {
      memberVoucher.value = false;
      salePageController.memberNo.clear();
    }
    calculateTotalOrder();
  }

  removeVoucher(CartVoucher voucher) {
    voucher.qtyOrder = (voucher.qtyOrder ?? 0) - 1;
    voucher.totalPrice =
        (voucher.totalPrice ?? 0) - (voucher.entity!.vpUnitValue ?? 0);
    if (voucher.qtyOrder == 0) {
      removeListvoucher(voucher);
    }
    calculateTotalOrder();
  }

  adddeposit(DepositEntity deposit) {
    if (memberVoucher.isTrue) {
      alert.warning('Warning', 'Deposit tidak bisa di gunakan!');
      return;
    }
    depositList.add(
      CartDeposit(
        qtyOrder: 1,
        totalPrice: deposit.dpAmount ?? 0,
        deposit: deposit,
      ),
    );
    calculateTotalOrder();
  }

  removeListdeposit(CartDeposit deposit) {
    depositList.remove(deposit);
    calculateTotalOrder();
  }

  void calculateTotalOrder() {
    double totalAmntFinal = 0;
    double totalAmnt = 0;
    int ticketTotalQtyVal = 0;

    // if (ticketList.isNotEmpty) {
    //   totalAmnt += ticketList.fold(0, (sum, val) => sum + val.totalPrice!);
    //   ticketTotalQtyVal +=
    //       ticketList.fold(0, (sum, val) => sum + val.qtyOrder!);

    //   if (voucherList.isNotEmpty) {
    //     double discountAmount = 0;

    //     // List<CartTicket> sortedTicketList = List.from(ticketList);
    //     // sortedTicketList.sort((a, b) => b.totalPrice!.compareTo(a.totalPrice!));

    //     for (var element in voucherList) {
    //       int remainingVoucherQty = element.qtyOrder ?? 0;

    //       if (remainingVoucherQty > 0) {
    //         for (var ticket in ticketList) {
    //           if (remainingVoucherQty == 0) break;

    //           int applicableQty = ticket.qtyOrder! < remainingVoucherQty
    //               ? ticket.qtyOrder!
    //               : remainingVoucherQty;
    //           remainingVoucherQty -= applicableQty;

    //           if (element.entity!.vpUnitType == UnitType.PERCENT) {
    //             logger.safeLog(
    //                 'PERCENT HITUNG TIKET : ${ticket.ticket?.ticketName} -> VOUCHER : ${element.entity?.vpName}');
    //             discountAmount += applicableQty *
    //                 (ticket.totalPrice! / ticket.qtyOrder!) *
    //                 (element.entity!.vpUnitValue ?? 0) /
    //                 100;
    //           } else {
    //             logger.safeLog(
    //                 'NOT PERCENT HITUNG TIKET : ${ticket.ticket?.ticketName} -> VOUCHER : ${element.entity?.vpName}');
    //             discountAmount +=
    //                 applicableQty * (element.entity!.vpUnitValue ?? 0);
    //           }
    //         }
    //       }
    //     }
    //     logger.safeLog('VOUCHER AMOUNT : $discountAmount ');

    //     ticketTotalQtyVal +=
    //         voucherList.fold(0, (sum, val) => sum + val.qtyOrder!);

    //     totalAmnt = totalAmnt - discountAmount;
    //   }
    // }

    if (ticketList.isNotEmpty) {
      totalAmnt += ticketList.fold(0, (sum, val) => sum + val.totalPrice!);
      ticketTotalQtyVal +=
          ticketList.fold(0, (sum, val) => sum + val.qtyOrder!);
    }

    if (addonList.isNotEmpty) {
      totalAmnt += addonList.fold(0, (sum, val) => sum + val.totalPrice!);
      ticketTotalQtyVal += addonList.fold(0, (sum, val) => sum + val.qtyOrder!);
    }

    // Merchandise bundling. Ditambahkan SEBELUM voucher supaya voucher tetap
    // memotong nilai tiket saja — sama seperti perhitungan di e-ticketing.
    // Bundling gratis bernilai 0 sehingga tidak mengubah total sama sekali.
    if (bundleList.isNotEmpty) {
      totalAmnt += bundleList.fold(0, (sum, val) => sum + (val.totalPrice ?? 0));
      ticketTotalQtyVal +=
          bundleList.fold(0, (sum, val) => sum + (val.qtyOrder ?? 0));
    }

    // Diskon voucher berlaku untuk tiket DAN booking lapangan. 1 voucher = 1 unit
    // (1 tiket ATAU 1 jam booking lapangan). Pool digabung supaya voucher ikut
    // memotong harga booking lapangan, bukan hanya tiket (sebelumnya blok ini
    // dibungkus `if (ticketList.isNotEmpty)` sehingga lapangan tak pernah kena).
    if (voucherList.isNotEmpty) {
      final List<VoucherUnit> voucherUnits = buildVoucherUnits(
        ticketList: ticketList,
        addonList: addonList,
      );
      if (voucherUnits.isNotEmpty) {
        double discountAmount = 0;
        for (var element in voucherList) {
          int remainingVoucherQty = element.qtyOrder ?? 0;
          for (var unit in voucherUnits) {
            if (remainingVoucherQty == 0) break;
            if (unit.remaining == 0) continue;

            int applicableQty = unit.remaining < remainingVoucherQty
                ? unit.remaining
                : remainingVoucherQty;
            unit.remaining -= applicableQty;
            remainingVoucherQty -= applicableQty;

            if (element.entity!.vpUnitType == UnitType.PERCENT) {
              discountAmount += applicableQty *
                  unit.unitPrice *
                  (element.entity!.vpUnitValue ?? 0) /
                  100;
            } else {
              discountAmount +=
                  applicableQty * (element.entity!.vpUnitValue ?? 0);
            }
          }
        }

        ticketTotalQtyVal +=
            voucherList.fold(0, (sum, val) => sum + val.qtyOrder!);
        totalAmnt = totalAmnt - discountAmount;
      }
    }

    totalAmntFinal = totalAmnt;

    // logger.safeLog('POTONGAN JML : ${potonganList.length}');
    // logger.safeLog('TOTAL AMOUNT : $totalAmnt');
    // logger.safeLog('TOTAL AMOUNT FINAL : $totalAmntFinal');

    if (potonganList.isNotEmpty) {
      double discountAmount = 0;
      for (var element in potonganList) {
        if (element.potongan!.voucherUnitType == UnitType.PERCENT) {
          discountAmount +=
              totalAmnt * (element.potongan!.voucherUnitValue ?? 0) / 100;
        } else {
          discountAmount += element.potongan!.voucherUnitValue ?? 0;
        }
        logger.safeLog('POTONGAN AMOUNT : $discountAmount ');
      }

      ticketTotalQtyVal +=
          potonganList.fold(0, (sum, val) => sum + val.qtyOrder!);

      totalAmntFinal = totalAmntFinal - discountAmount;
    }

    // logger.safeLog('DEPOSIT JML : ${depositList.length}');
    // logger.safeLog('TOTAL AMOUNT : $totalAmnt');
    // logger.safeLog('TOTAL AMOUNT FINAL : $totalAmntFinal');

    if (depositList.isNotEmpty) {
      double discountAmount = 0;
      for (var element in depositList) {
        discountAmount += element.deposit!.dpAmount ?? 0;
        logger.safeLog('DEPOSIT AMOUNT : $discountAmount ');
      }

      ticketTotalQtyVal +=
          depositList.fold(0, (sum, val) => sum + val.qtyOrder!);

      totalAmntFinal = totalAmntFinal - discountAmount;
    }

    totalOrderAmnt.value = totalAmntFinal > 0 ? totalAmntFinal : 0;
    double paymentFee = getPricePayemntFee();
    logger.safeLog('TOTAL PAYMENT : ${totalOrderAmnt.value}');
    logger.safeLog('FEE PAYMENT : $paymentFee');
    finalTotalOrderAmt.value = (totalOrderAmnt.value + paymentFee);
    totalOrderQty.value = ticketTotalQtyVal;

    salePageController.totalOrderQty(totalOrderQty.value);
    salePageController.totalOrderAmnt(finalTotalOrderAmt.value);
    salePageController.addonList(addonList);
    salePageController.bundleList(bundleList);
    salePageController.potonganList(potonganList);
    salePageController.voucherList(voucherList);
    salePageController.depositList(depositList);
    salePageController.ticketList(ticketList);

    update();

    updateCustomer();
  }

  onPayment() async {
    // logger.safeLog('TOTAL AMT : ${finalTotalOrderAmt.value}');
    // logger.safeLog('TICKERT LIST : ${ticketList.length}');
    // logger.safeLog('TICKERT LIST : ${ticketList.isEmpty}');
    // logger.safeLog('potongan LIST : ${potonganList.length}');
    // logger.safeLog('potongan LIST : ${potonganList.isEmpty}');
    // logger.safeLog(
    //     'VALID TO PAYMENT  : ${(finalTotalOrderAmt.value < 0 && potonganList.isEmpty && ticketList.isEmpty)}');
    if (finalTotalOrderAmt.value < 0 ||
        (addonList.isEmpty && ticketList.isEmpty)) {
      alert.warning('warning', 'Order cannot empty');
      return;
    }

    logger.safeLog('OPEN PAYMENT 1 : ${salePageController.openPayment.value}');
    if (salePageController.openPayment.value) {
      salePageController.doPayment();
    } else {
      // Server menghitung ulang bundling saat order disimpan. Pastikan yang
      // ditagih kasir memakai aturan yang sama, dan beri tahu bila berubah
      // supaya kasir melihat totalnya dulu sebelum menerima pembayaran.
      if (await muatUlangBundle()) {
        alert.warning(
          'Bundling Diperbarui',
          'Aturan bundling tiket baru saja diubah di back office. '
              'Periksa kembali keranjang dan total sebelum lanjut ke pembayaran.',
        );
        return;
      }
      salePageController.doPrepared();
      salePageController.totalOrderQty(totalOrderQty.value);
      salePageController.totalOrderAmnt(finalTotalOrderAmt.value);
      salePageController.addonList(addonList);
      salePageController.bundleList(bundleList);
      salePageController.potonganList(potonganList);
      salePageController.voucherList(voucherList);
      salePageController.depositList(depositList);
      salePageController.ticketList(ticketList);
      salePageController.openPayment(true);
    }
    logger.safeLog('OPEN PAYMENT 2 : ${salePageController.openPayment.value}');
  }

  clearCartOrder() {
    try {
      memberVoucher.value = false;
      salePageController.memberNo.clear();
      selectedMstPayment.value = MstPayment();
      ticketList.clear();
      addonList.clear();
      bundleList.clear();
      _aturanBundle.clear();
      potonganList.clear();
      voucherList.clear();
      depositList.clear();
      _disposeChildNameControllers();
      _lapanganController?.onCartCleared();
      calculateTotalOrder();
      updateCustomer();
      // clear and back payment page
      salePageController.totalOrderQty(totalOrderQty.value);
      salePageController.totalOrderAmnt(finalTotalOrderAmt.value);
      salePageController.addonList(addonList);
      salePageController.bundleList(bundleList);
      salePageController.potonganList(potonganList);
      salePageController.voucherList(voucherList);
      salePageController.depositList(depositList);
      salePageController.ticketList(ticketList);
      salePageController.openPayment(false);
      salePageController.refreshForm();
      salePageController.update();
      // Transaksi selesai: muat ulang daftar semua tab agar status/stok/harga
      // langsung sinkron (mis. item aula jadi "Terpakai") tanpa perlu logout.
      refreshSaleLists();
    } catch (e) {
      logger.safeLog(e);
    }
    Get.back();
    update();
  }

  updateCustomer() {
    displayUtil.updateSecondDisplay(
      CustomerDisplay(
        key: CustomerDisplayAction.ADD_CART,
        value: CustomerSaleCart(
          ticketList: ticketList,
          addonList: addonList,
          // Tanpa ini layar pelanggan tidak pernah menampilkan merchandise bundling:
          // yang gratis tidak terlihat sama sekali, dan yang berbayar membuat total
          // di layar lebih besar dari jumlah barang yang terlihat.
          bundleList: bundleList,
          potonganList: potonganList,
          voucherList: voucherList,
          depositList: depositList,
          totalOrder: finalTotalOrderAmt.value,
          paymentFee: getPricePayemntFee(),
        ).toJson(),
      ).toJson(),
    );
  }

  double getPricePayemntFee() {
    if (selectedMstPayment.value.pymntFlBbnCust == 'Y') {
      if (selectedMstPayment.value.pymntTypeFee == UnitType.PERCENT) {
        return (totalOrderAmnt.value *
            (selectedMstPayment.value.pymntAdminFee ?? 0) /
            100);
      } else {
        return selectedMstPayment.value.pymntAdminFee ?? 0;
      }
    } else {
      return 0;
    }
  }

  onNextRental(
    CartRentModel cartRentModel,
    AddonEntity val,
    CartAddon? exists,
  ) async {
    Get.back();

    var result;
    val.productPrice = 0;

    if (exists != null) {
      addonList.remove(exists);
    }

    result = await _service.rental.getPriceRental(
      authToken: _authToken,
      hours: cartRentModel.totalHours!,
      productId: val.productId!,
      orderNoExtra: cartRentModel.transactionExtra?.orderNumber,
    );

    CartRentModel cartRentModelAdded = cartRentModel;

    result.fold(
      (l) {
        logger.safeLog(l);
      },
      (r) {
        logger.safeLog(r.data);
        if (ProductRentalType.HOURS == val.productType) {
          // if (cartRentModelAdded.isExtraTime!) {
          //   cartRentModelAdded.extraTimeBuyPrice = r.data;
          // } else {
          //   cartRentModelAdded.newBuyPrice = r.data;
          // }
          cartRentModelAdded.newBuyPrice = r.data;
        } else {}
        val.productPrice = r.data;

        addAddonRent(
          val,
          cartRentModelAdded,
        );
        update();
      },
    );
  }

  doUpdateRent(CartAddon cartAddOn) async {
    await dialog.selectHourRent(
      authToken: _authToken,
      entitiy: cartAddOn.addon!,
      detailModel: cartAddOn.rentModel,
      isExtraTime: cartAddOn.rentModel!.isExtraTime!,
      onNext: (cartRentModel) => onNextRental(
        cartRentModel,
        cartAddOn.addon!,
        cartAddOn,
      ),
    );
  }

  checkQtyMemberVocuher() {
    int qty = 1;
    int totalQtyTiket = 0;
    for (var tiket in ticketList) {
      totalQtyTiket += tiket.qtyOrder ?? 0;
    }

    if (memberValid.value.memberListResponses == null ||
        memberValid.value.memberListResponses!.isEmpty) {
      if (memberValid.value.mstMembership != null) {
        int maxKuota = (memberValid.value.mstMembership?.membKuota ?? 0) <
                (memberValid.value.mstMembership?.membMaxKuota ?? 0)
            ? (memberValid.value.mstMembership?.membKuota ?? 0)
            : (memberValid.value.mstMembership?.membMaxKuota ?? 0);

        if (totalQtyTiket <= maxKuota) {
          qty = totalQtyTiket;
        } else {
          qty = maxKuota;
        }

        if (voucherList.isNotEmpty) {
          CartVoucher cartSelected = voucherList.firstWhere(
            (element) =>
                element.entity?.vpId ==
                memberValid.value.mstMembership?.membVpId,
          );
          cartSelected.qtyOrder = qty;
        }
      }
    }
  }
}
