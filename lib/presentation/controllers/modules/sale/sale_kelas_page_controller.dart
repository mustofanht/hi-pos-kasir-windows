import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/common/session_util.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/data/models/cart/cart_addon_model.dart';
import 'package:jaya_propertiy/data/services/main_service.dart';
import 'package:jaya_propertiy/domain/entities/sale/addon_entity.dart';
import 'package:jaya_propertiy/domain/entities/sale/kelas_entity.dart';
import 'package:jaya_propertiy/presentation/components/custom_alert.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/sale/sale_cart_page_controller.dart';

/// Tab Kelas: kasir memilih tanggal, lalu menambah/mengurangi jumlah anak per
/// sesi. Setiap klik langsung tercatat di keranjang sebagai baris kelas
/// ([CartAddon.isKelas]); kuota dipakai bersama dengan website sehingga sisa
/// kursi selalu dimuat ulang dari server.
class SaleKelasPageController extends GetxController {
  SaleKelasPageController();
  final _service = MainService();
  final _authToken = Get.arguments[argConstant.authToken];

  final isLoading = false.obs;
  final kelasList = <KelasEntity>[].obs;

  /// Tanggal kelas yang sedang dilihat (tanpa jam).
  final tanggal = _hariIni().obs;

  static DateTime _hariIni() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  static String formatTanggal(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static String labelTanggal(DateTime d) {
    const bulan = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    const hari = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return '${hari[d.weekday - 1]}, ${d.day} ${bulan[d.month - 1]} ${d.year}';
  }

  SaleCartPageController get _cart => Get.find<SaleCartPageController>();

  @override
  void onInit() {
    super.onInit();
    muat();
  }

  Future<void> muat() async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      final result = await _service.sale.ticketService.getKelas(
        authToken: _authToken,
        locationIds: sessionUtil.getLocationIdsQueryParam(),
        date: formatTanggal(tanggal.value),
      );
      result.fold(
        (l) {
          logger.safeLog(l);
          alert.error('Terjadi Kesalahan!', l);
        },
        (r) => kelasList.value = r,
      );
    } catch (e) {
      logger.safeLog(e);
    }
    isLoading.value = false;
  }

  void gantiTanggal(DateTime d) {
    final baru = DateTime(d.year, d.month, d.day);
    if (baru.isBefore(_hariIni())) return;
    tanggal.value = baru;
    muat();
  }

  bool get bisaMundur => tanggal.value.isAfter(_hariIni());

  CartAddon? _barisKeranjang(KelasSesiEntity sesi) =>
      _cart.addonList.firstWhereOrNull(
        (e) => e.isKelas && e.kelasSessionId == sesi.sessionId,
      );

  /// Jumlah anak di keranjang untuk sesi ini pada tanggal yang sedang dilihat.
  int qtyDiKeranjang(KelasSesiEntity sesi) {
    final baris = _barisKeranjang(sesi);
    if (baris == null || baris.kelasDate == null) return 0;
    return _samaHari(baris.kelasDate!, tanggal.value) ? (baris.qtyOrder ?? 0) : 0;
  }

  static bool _samaHari(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void tambah(KelasEntity kelas, KelasSesiEntity sesi) {
    if (!sesi.bisaDijual) return;
    final baris = _barisKeranjang(sesi);
    if (baris != null && baris.kelasDate != null && !_samaHari(baris.kelasDate!, tanggal.value)) {
      alert.error(
        'Sesi Sudah di Keranjang',
        '${kelas.ticketName} - ${sesi.sessionName ?? ''} sudah ada di keranjang untuk '
            '${labelTanggal(baris.kelasDate!)}. Selesaikan atau hapus dulu dari keranjang.',
      );
      return;
    }
    final sisa = sesi.remaining ?? 0;
    if (baris == null) {
      final harga = sesi.price ?? 0;
      _cart.addonList.add(
        CartAddon(
          qtyOrder: 1,
          totalPrice: harga,
          addon: AddonEntity(
            productId: -(sesi.sessionId ?? 0),
            productName:
                '${kelas.ticketName} - ${sesi.sessionName ?? 'Sesi'} (${sesi.jam}) ${labelTanggal(tanggal.value)}',
            productType: 'K',
            productPrice: harga,
            productLoc: kelas.ticketLocation,
            productLocName: kelas.ticketLocationName,
            pathImg: kelas.pathImg,
          ),
          kelasTicketId: kelas.ticketId,
          kelasSessionId: sesi.sessionId,
          kelasDate: tanggal.value,
          kelasSisa: sisa,
        ),
      );
      _cart.calculateTotalOrder();
    } else {
      baris.kelasSisa = sisa;
      _cart.addAddonCart(baris);
    }
    _cart.update();
  }

  void kurang(KelasSesiEntity sesi) {
    final baris = _barisKeranjang(sesi);
    if (baris == null || qtyDiKeranjang(sesi) == 0) return;
    _cart.removeAddon(baris);
    _cart.update();
  }
}
