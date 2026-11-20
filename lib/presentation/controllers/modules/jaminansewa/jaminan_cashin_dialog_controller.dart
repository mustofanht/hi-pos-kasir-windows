import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/app/utils/common/generate_jaminan_sewa_print_util.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/common/printer_util.dart';
import 'package:jaya_propertiy/app/utils/common/ribuan_input_formatter.dart';
import 'package:jaya_propertiy/app/utils/common/session_util.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/data/services/main_service.dart';
import 'package:jaya_propertiy/domain/entities/auth/auth_token.dart';
import 'package:jaya_propertiy/domain/entities/auth/user_entity.dart';
import 'package:jaya_propertiy/domain/entities/jaminansewa/jaminan_sewa_entity.dart';
import 'package:jaya_propertiy/domain/entities/masterdata/mst_payment.dart';
import 'package:jaya_propertiy/domain/entities/sale/addon_entity.dart';
import 'package:jaya_propertiy/presentation/components/custom_alert.dart';
import 'package:jaya_propertiy/presentation/components/custom_dialog.dart';

/// Cash-In jaminan sewa dari tab Item (sub-tab "Jaminan Sewa", di samping
/// Jual) — pengganti Tab 1 "Terima Jaminan" di layar standalone lama.
///
/// Sejak V162, boleh Tunai/QRIS/EDC: metode yang terintegrasi payment
/// gateway (mst_payment.pymntCodePayGateway terisi) menampilkan QR dan
/// menunggu konfirmasi lunas sebelum struk dicetak; metode lain (Tunai/EDC/
/// QRIS statis) langsung dianggap lunas begitu disubmit, sama seperti
/// sebelumnya.
class JaminanCashInDialogController extends GetxController {
  JaminanCashInDialogController({required this.item, required this.onSelesai});

  final AddonEntity item;
  final VoidCallback onSelesai;

  final _service = MainService();
  late final AuthToken _authToken = Get.arguments[argConstant.authToken];

  final user = Rxn<UserEntity>();
  int? get _locationId => sessionUtil.getLocationId();

  final amountController = TextEditingController();
  final customerNameController = TextEditingController();
  final customerPhoneController = TextEditingController();
  final notesController = TextEditingController();

  final isLoadingPayment = false.obs;
  final paymentList = <MstPayment>[].obs;
  final selectedPayment = Rxn<MstPayment>();

  final isSubmitting = false.obs;
  final isCheckingQris = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (item.productPrice != null && item.productPrice! > 0) {
      amountController.text = item.productPrice!.toStringAsFixed(0);
    }
    _muatUser();
    _muatMetodeBayar();
  }

  @override
  void onClose() {
    // Controller ini dihapus dari whenComplete Get.dialog, yaitu SAAT dialog
    // mulai ditutup -- animasi tutupnya masih berjalan beberapa ratus ms dan
    // masih membangun ulang TextField-nya. Dispose langsung di sini membuat
    // layar merah "TextEditingController was used after being disposed".
    // Jadi dispose ditunda sampai animasinya pasti selesai.
    final isian = [
      amountController,
      customerNameController,
      customerPhoneController,
      notesController,
    ];
    Future.delayed(const Duration(seconds: 1), () {
      for (final c in isian) {
        c.dispose();
      }
    });
    super.onClose();
  }

  Future<void> _muatUser() async {
    try {
      user.value = await common.getUser(authToken: _authToken);
    } catch (e) {
      logger.safeLog(e);
    }
  }

  Future<void> _muatMetodeBayar() async {
    isLoadingPayment.value = true;
    try {
      final result = await _service.masterData.getAll(
        authToken: _authToken,
        paramsFilter: {'page': '0', 'size': '999', 'flMobile': 'Y'},
      );
      result.fold(
        (l) => logger.safeLog(l),
        (r) {
          paymentList.value =
              (r.data ?? []).where((p) => p.pymntStatus == 'Y').toList();
          if (paymentList.isNotEmpty) {
            selectedPayment.value = paymentList.first;
          }
        },
      );
    } catch (e) {
      logger.safeLog(e);
    }
    isLoadingPayment.value = false;
    update();
  }

  void pilihMetodeBayar(MstPayment? p) {
    selectedPayment.value = p;
    update();
  }

  /// true bila metode terpilih lewat payment gateway (QR harus digenerate &
  /// ditunggu) — bukan sekadar kategorinya QRIS, karena QRIS statis/EDC di
  /// lokasi yang belum pasang gateway tidak boleh ikut menunggu.
  bool get metodeLewatGateway =>
      (selectedPayment.value?.pymntCodePayGateway ?? '').trim().isNotEmpty;

  /// true bila metode terpilih berkategori Tunai (CS) — dipakai memilih antara
  /// minta "Uang Diterima" (+ kembalian) atau minta nomor referensi manual.
  bool get isCash => selectedPayment.value?.pymntCategory == PaymentMethod.CASH;

  Future<void> submit() async {
    final locationId = _locationId;
    if (locationId == null) {
      alert.error('Error', 'Lokasi kasir tidak dikenali.');
      return;
    }
    if (item.productId == null) {
      alert.error('Error', 'Item sewa tidak valid.');
      return;
    }
    final amount = RibuanInputFormatter.bersihkan(amountController.text);
    if (amount <= 0) {
      alert.warning('Perhatian', 'Nominal jaminan harus lebih dari 0.');
      return;
    }
    final metode = selectedPayment.value;
    if (metode?.pymntCode == null) {
      alert.warning('Perhatian', 'Pilih metode pembayaran dulu.');
      return;
    }

    // Dibaca sebelum form (mungkin) ditutup -- TextEditingController-nya
    // di-dispose begitu dialog form ini ditutup (whenComplete di
    // jaminan_cashin_dialog.dart), jadi tidak aman dibaca lagi sesudahnya.
    final paymentCode = metode!.pymntCode!;
    final customerName = customerNameController.text;
    final customerPhone = customerPhoneController.text;
    final notes = notesController.text;

    if (metodeLewatGateway) {
      // QRIS lewat gateway: form masih dibutuhkan untuk spinner tombol
      // selagi QR digenerate, jadi ditutup belakangan (lihat _kirimKeBackend).
      isSubmitting.value = true;
      update();
      await _kirimKeBackend(
        locationId: locationId,
        amount: amount,
        paymentCode: paymentCode,
        customerName: customerName,
        customerPhone: customerPhone,
        notes: notes,
        formMasihTerbuka: true,
      );
      return;
    }

    // Tunai/EDC/QRIS statis: minta "Uang Diterima" (+ kembalian otomatis)
    // atau nomor referensi manual DULU, baru dikirim ke backend -- pola yang
    // sama dengan OrderPaymentController.doOrderPayment di alur penjualan
    // biasa (lihat dialog.waitingPaymentEdc).
    final bool isCashNow = isCash;
    Get.back(); // tutup form SEKARANG; controller tetap dipakai untuk
    // melanjutkan proses, tapi JANGAN panggil update()/sentuh
    // TextEditingController form ini lagi sesudah titik ini.
    bool diproses = false;
    dialog.waitingPaymentEdc(
      title: 'Konfirmasi Pembayaran',
      msg: isCashNow
          ? 'Masukkan uang yang diterima, lalu lanjutkan.'
          : 'Silakan isi nomor referensi.',
      showReffInput: !isCashNow,
      showUangDiterima: isCashNow,
      totalTagihan: amount,
      onNext: (reffNo, uangDiterima) async {
        if (diproses) return;
        if (isCashNow) {
          if (uangDiterima == null || uangDiterima < amount) {
            alert.error(
              'Uang Diterima Kurang',
              'Uang yang diterima harus minimal sebesar jaminan '
                  '(${common.currencyFormat(amount)}).',
            );
            return;
          }
        } else if (reffNo.trim().isEmpty) {
          alert.error('Error', 'Nomor Reference wajib diisi.');
          return;
        }
        diproses = true;
        await _kirimKeBackend(
          locationId: locationId,
          amount: amount,
          paymentCode: paymentCode,
          customerName: customerName,
          customerPhone: customerPhone,
          notes: notes,
          paymentRefNo: isCashNow ? null : reffNo.trim(),
          uangDiterima: isCashNow ? uangDiterima : null,
          kembalian: isCashNow ? (uangDiterima! - amount) : null,
          formMasihTerbuka: false,
        );
        diproses = false;
      },
    );
  }

  /// Dipanggil setelah metode gateway dipilih (langsung) ATAU setelah kasir
  /// mengisi uang diterima/nomor referensi lewat [dialog.waitingPaymentEdc]
  /// (lihat [submit]).
  ///
  /// [formMasihTerbuka] menandai apakah dialog form Jaminan Sewa masih
  /// terbuka di belakang -- hanya untuk kasus itu `isSubmitting`/`update()`
  /// boleh disentuh saat gagal. Untuk jalur Tunai/EDC/QRIS statis, form itu
  /// sudah ditutup sebelum sampai sini (lihat [submit]), jadi `update()`
  /// TIDAK pernah dipanggil lagi -- itulah yang dulu menabrak controller yang
  /// sudah disposed (layar merah "used after being disposed").
  Future<void> _kirimKeBackend({
    required int locationId,
    required double amount,
    required String paymentCode,
    required String customerName,
    required String customerPhone,
    required String notes,
    required bool formMasihTerbuka,
    String? paymentRefNo,
    double? uangDiterima,
    double? kembalian,
  }) async {
    try {
      final result = await _service.jaminanSewa.terima(
        authToken: _authToken,
        locationId: locationId,
        productId: item.productId!,
        qty: 1,
        amount: amount,
        paymentCode: paymentCode,
        paymentRefNo: paymentRefNo,
        customerName: customerName,
        customerPhone: customerPhone,
        notes: notes,
      );
      await result.fold(
        (l) async {
          alert.error('Gagal', l);
          if (formMasihTerbuka) {
            isSubmitting.value = false;
            update();
          }
        },
        (r) async {
          // Dialog yang sedang terbuka saat ini -- form (gateway) ATAU
          // konfirmasi uang diterima/referensi (non-gateway) -- selalu tepat
          // satu, jadi satu Get.back() ini menutup yang benar di kedua jalur.
          Get.back();
          if (r.needsPayment) {
            _tungguQris(r);
          } else {
            await _cetakStrukTerima(r, uangDiterima: uangDiterima, kembalian: kembalian);
            alert.success('Berhasil', 'Jaminan ${r.jmnNo} diterima.');
            onSelesai();
          }
        },
      );
    } catch (e) {
      logger.safeLog(e);
      alert.error('Error', 'Terjadi kesalahan, silakan hubungi admin.');
      if (formMasihTerbuka) {
        isSubmitting.value = false;
        update();
      }
    }
  }

  void _tungguQris(JaminanSewaEntity data) {
    dialog.waitingPaymentWithQr(
      title: 'Menunggu Pembayaran',
      msg: 'Jaminan ${data.jmnNo} menunggu pembayaran QRIS sebesar '
          '${common.currencyFormat(data.amount ?? 0)}.\nTekan "Cek" setelah '
          'pelanggan selesai membayar.',
      qrCode: data.qrUrl,
      onCancle: () {
        Get.back();
        // Baris tetap tersimpan berstatus Waiting (belum dianggap diterima) —
        // kasir bisa membuka lagi lewat layar Pengembalian/riwayat bila perlu.
      },
      onCheck: () async {
        if (isCheckingQris.value) return;
        isCheckingQris.value = true;
        try {
          final hasil = await _service.jaminanSewa.cekStatusQris(
            authToken: _authToken,
            jmnNo: data.jmnNo!,
          );
          await hasil.fold(
            (l) async => alert.error('Gagal', l),
            (r) async {
              if (r.needsPayment) {
                alert.warning('Menunggu', 'Pembayaran belum terkonfirmasi.');
                return;
              }
              Get.back();
              await _cetakStrukTerima(r);
              alert.success('Berhasil', 'Jaminan ${r.jmnNo} diterima.');
              onSelesai();
            },
          );
        } catch (e) {
          logger.safeLog(e);
          alert.error('Error', 'Gagal cek status pembayaran.');
        }
        isCheckingQris.value = false;
      },
    );
  }

  Future<void> _cetakStrukTerima(
    JaminanSewaEntity data, {
    double? uangDiterima,
    double? kembalian,
  }) async {
    if (printerUtil.currPrinter == null) {
      alert.warning('Printer',
          'Jaminan sudah tersimpan (${data.jmnNo}), tapi printer belum terhubung. Sambungkan printer lalu cetak ulang dari layar Pengembalian.');
      return;
    }
    try {
      final bytes = await generateJaminanSewaPrintUtil.dataTerimaJaminanPrint(
        locationName: user.value?.locationName,
        locationAddress: user.value?.locationAddress,
        locationPhone: user.value?.locationPhone,
        paperSize: PaperSize.mm80,
        data: data,
        uangDiterima: uangDiterima,
        kembalian: kembalian,
        // Uang diterima hanya diisi untuk pembayaran tunai.
        bukaLaci: uangDiterima != null,
      );
      await printerUtil.print(printerUtil.currPrinter!, bytes);
    } catch (e) {
      logger.safeLog(e);
    }
  }
}
