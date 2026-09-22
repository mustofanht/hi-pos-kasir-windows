import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/app/utils/common/date_time_util.dart';
import 'package:jaya_propertiy/app/utils/common/display_util.dart';
import 'package:jaya_propertiy/app/utils/common/generate_print_util.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/common/printer_util.dart';
import 'package:jaya_propertiy/app/utils/common/session_util.dart';
import 'package:jaya_propertiy/app/utils/constant/date_format_constant.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/data/models/common/printer_model.dart';
import 'package:thermal_printer/thermal_printer.dart';
import 'package:jaya_propertiy/data/models/common/wristband_config_model.dart';
import 'package:jaya_propertiy/data/services/main_service.dart';
import 'package:jaya_propertiy/domain/entities/auth/user_entity.dart';
import 'package:jaya_propertiy/domain/entities/common/custom_id_name_entity.dart';
import 'package:jaya_propertiy/presentation/components/custom_alert.dart';
import 'package:presentation_displays/display.dart';

class SettingPageController extends GetxController
    with SingleGetTickerProviderMixin {
  SettingPageController();
  // var printController = Get.find<PrintController>();

  final _service = MainService();
  final _authToken = Get.arguments[argConstant.authToken];
  final isLoading = false.obs;
  final isLoadingPrinter = false.obs;
  final isLoadingPrinterDiconect = false.obs;
  final isLoadingConnectPrinter = false.obs;
  final isLoadingRefreshCustScreeen = false.obs;

  TabController? tabController;
  var tabIndex = 0.obs;

  final unitController = TextEditingController();
  final lastLoginController = TextEditingController();
  final nameController = TextEditingController();
  final roleController = TextEditingController();
  final noTelpController = TextEditingController();
  final emailController = TextEditingController();

  final model = UserEntity().obs;

  final listPrinter = <CustomIdNameEntity>[].obs;
  final printers = <PrinterModel>[].obs;
  final selectedCurrPrinter = CustomIdNameEntity().obs;
  final listScreens = <CustomIdNameEntity>[].obs;
  final selectedScreens = CustomIdNameEntity().obs;

  final currentPrinterConnect = RxString('');

  // --- Printer gelang -------------------------------------------------------
  // Perangkat kedua, memakai bahasa TSPL, terpisah dari printer struk.
  final selectedPrinterGelang = CustomIdNameEntity().obs;

  final lebarGelangController = TextEditingController();
  final tinggiGelangController = TextEditingController();
  final jarakGelangController = TextEditingController();
  final marginGelangController = TextEditingController();
  final qrMaksGelangController = TextEditingController();
  final geserXGelangController = TextEditingController();
  final geserYGelangController = TextEditingController();
  final shiftGelangController = TextEditingController();
  final dpiGelang = 203.obs;
  final kerapatanGelang = 8.obs;
  final kecepatanGelang = 4.obs;
  final arahGelang = 1.obs;
  final potongGelang = ModePotong.sobek.obs;
  final terkunciGelang = false.obs;

  /// Setelan media tersimpan sama dengan setelan terbukti. Diperbarui setiap
  /// formulir dimuat ulang dan setiap setelan disimpan.
  final _gelangBawaan = true.obs;
  bool get setelanGelangBawaan => _gelangBawaan.value;
  final putarIsiGelang = false.obs;
  final posisiGelang = PosisiIsi.tengah.obs;
  final sensorGelang = SensorMedia.menerus.obs;

  @override
  Future<void> onInit() async {
    doPrepared();
    await doInitializeScreen();
    await doInitializePrinter();
    super.onInit();
    muatSetelanGelang();
    tabController = TabController(length: 4, vsync: this);
    tabController!.addListener(_handleTabSelection);
    currentPrinterConnect.value = printerUtil.currPrinter?.deviceName ?? '';
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

  void changeTabIndex(int index) {
    tabIndex.value = index;
  }

  doPrepared() async {
    isLoading.value = true;
    try {
      var result;
      result = await _service.auth.getUserInformation(
          authToken: _authToken, userId: sessionUtil.getUserName());
      result.fold((l) {
        logger.safeLog(l);
        isLoading.value = false;
      }, (r) {
        model.value = r.data;
        unitController.text = model.value.unitName!;
        lastLoginController.text = dateTimeUtil.getFormattedDate(
          date: model.value.userLastLogon!,
          format: dateFormat.dateTime,
        );
        nameController.text = model.value.userFullName!;
        roleController.text = model.value.roleName ?? '';
        noTelpController.text = model.value.userPhone!;
        emailController.text = model.value.userEmail!;
        isLoading.value = false;
      });
    } catch (e) {
      logger.safeLog(e);
      isLoading.value = false;
    }
    update();
  }

  doInitializePrinter() async {
    isLoadingConnectPrinter.value = false;
    isLoadingPrinter.value = true;
    var noneSelectedPrint = CustomIdNameEntity(
      id: null,
      name: '--- Select Printer ---',
    );
    selectedCurrPrinter.value = noneSelectedPrint;
    listPrinter.clear();
    listPrinter.insert(0, noneSelectedPrint);

    // List<PrinterModel> printers = await printerUtil.getListDevices();
    await printerUtil.init();
    await printerUtil.initBt();
    printers.value = await printerUtil.getListDevices();
    printerUtil.printerList = printers;
    logger.safeLog('PRINTERS : ${printers.length}');

    for (var element in printers) {
      logger.safeLog('PRINTER : ${element.toJson()}');
      // Kuncinya [PrinterModel.kunci], bukan vendorId/alamat. Di Windows printer
      // dikenali dari nama antrean cetaknya saja — vendorId, productId, dan
      // alamatnya selalu kosong — sehingga semua printer dulu mendapat id null
      // dan memilih salah satunya selalu berakhir "please select active
      // printer". Kunci yang sama sudah dipakai pilihan printer gelang.
      listPrinter.add(
        CustomIdNameEntity(
          id: element.kunci,
          name: element.deviceName,
        ),
      );
    }

    final aktif = printerUtil.currPrinter;
    if (aktif != null) {
      selectedCurrPrinter.value = listPrinter.firstWhere(
        (element) => element.id == aktif.kunci,
        orElse: () => CustomIdNameEntity(id: null, name: '--- Select Printer ---'),
      );
    }
    // logger.safeLog('LIST PRINTER : ${listPrinter.length}');

    isLoadingPrinter.value = false;

    currentPrinterConnect.value = printerUtil.currPrinter?.deviceName ?? '';

    update();
  }

  doInitializeScreen() async {
    displayUtil.getDisplay();
    var noneSelectedScreen = CustomIdNameEntity(
      id: null,
      name: '--- None ---',
    );
    selectedScreens.value = noneSelectedScreen;
    listScreens.clear();
    listScreens.add(noneSelectedScreen);
    List<Display?> screens = displayUtil.displays;
    for (var element in screens) {
      logger.safeLog('SCREENS : ${element!.a}');
      listScreens.add(
        CustomIdNameEntity(
          id: element.a.toString(),
          name: '${element.a} - ${element.b} - ${element.c} - ${element.d}',
        ),
      );
    }
    update();
  }

  doUpdateConnectedPrinter(CustomIdNameEntity? val) async {
    if (val != null && val.id != null) {
      isLoadingConnectPrinter.value = true;
      // List<PrinterModel> printers = await printerUtil.getListDevices();
      final selected = printers.firstWhereOrNull((element) => element.kunci == val.id);
      if (selected != null) {
        // await printerUtil.init();
        // await printerUtil.disconnect(selected);
        await printerUtil.disconnectAll();
        await printerUtil.connect(selected);
        await printerUtil.stopSubscription();
        // logger.safeLog("CONNECTED CURR : ${printerUtil.currPrinter?.toJson()}");
        // logger.safeLog("listPrinter : ${listPrinter.length}");
        selectedCurrPrinter.value = listPrinter.firstWhere(
          (element) => element.id == printerUtil.currPrinter?.kunci,
          orElse: () => CustomIdNameEntity(
            id: null,
            name: '--- Select Printer ---',
          ),
        );
        alert.success('Success', 'Set Printer ${val.name} Active');
        isLoadingConnectPrinter.value = false;
      } else {
        // Daftar perangkat berubah sejak dropdown dibuat (printer dicabut atau
        // daftar disegarkan). Dulu kondisi ini melempar error dari firstWhere
        // dan tombolnya berputar terus tanpa pesan.
        alert.error('Error', 'Printer tidak ditemukan, segarkan daftar printer.');
        isLoadingConnectPrinter.value = false;
      }
    } else {
      alert.error('Error', 'please select active printer');
      isLoadingConnectPrinter.value = false;
    }

    currentPrinterConnect.value = printerUtil.currPrinter?.deviceName ?? '';

    update();
  }

  doRefreshCustomerPage() async {
    isLoadingRefreshCustScreeen.value = true;
    // displayUtil.showDisplay(selectedScreens.value.id);
    await common.doRefreshAds(_authToken);
    // await common.getImagePromo(_authToken);
    // await displayUtil.updateSecondDisplay(constant.refreshAds);
    // await orderUtil.doRefreshCustomerDisplay(paymentMethod: PaymentMethod.QRIS);
    isLoadingRefreshCustScreeen.value = false;
    update();
  }

  testPrint() async {
    try {
      logger.safeLog('TEST PRINT TO : ${printerUtil.currPrinter?.toJson()}');
      if (printerUtil.currPrinter != null) {
        List<int> data = [];
        data = await generatePrintUtil.testPrint(
          paperSize: PaperSize.mm80,
        );
        // await printerUtil.init();
        await printerUtil.print(printerUtil.currPrinter!, data);
        Get.back();
      } else {
        alert.error('Error', 'please check connection printer');
        printerUtil.connectPrinter();
      }
    } catch (e) {
      logger.safeLog(e);
      alert.error('Error', 'Terjadi Kesalahan , hubungi admin');
    }
  }

  // --- Printer gelang -------------------------------------------------------

  /// Menampilkan setelan gelang yang tersimpan ke dalam formulir.
  void muatSetelanGelang() {
    final c = printerUtil.wristbandConfig;
    lebarGelangController.text = _angka(c.widthMm);
    tinggiGelangController.text = _angka(c.heightMm);
    jarakGelangController.text = _angka(c.gapMm);
    marginGelangController.text = _angka(c.marginMm);
    qrMaksGelangController.text = _angka(c.qrMaksMm);
    geserXGelangController.text = _angka(c.geserXMm);
    geserYGelangController.text = _angka(c.geserYMm);
    shiftGelangController.text = _angka(c.shiftMm);
    dpiGelang.value = c.dpi;
    kerapatanGelang.value = c.density;
    kecepatanGelang.value = c.speed;
    arahGelang.value = c.direction;
    potongGelang.value = c.potong;
    putarIsiGelang.value = c.putarIsi;
    terkunciGelang.value = printerUtil.setelanGelangTerkunci;
    _gelangBawaan.value = c.samaDenganTerbukti;
    posisiGelang.value = c.posisi;
    sensorGelang.value = c.sensor;

    final tersimpan = printerUtil.wristbandPrinter;
    selectedPrinterGelang.value = tersimpan == null
        ? CustomIdNameEntity(id: null, name: '--- Belum diatur ---')
        : CustomIdNameEntity(
            id: tersimpan.kunci,
            name: '${tersimpan.deviceName} (${_jenisPrinter(tersimpan)})',
          );
  }

  String _angka(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  /// Daftar pilihan printer gelang: perangkat yang sama yang terdeteksi untuk
  /// printer struk, ditambah pilihan kosong untuk melepasnya kembali.
  List<CustomIdNameEntity> get listPrinterGelang => [
        CustomIdNameEntity(id: null, name: '--- Belum diatur ---'),
        // Jenis sambungannya ikut ditampilkan. Printer struk dan printer gelang
        // bisa berbeda jenis, dan nama perangkat saja tidak memberi tahu yang
        // mana — padahal jenis itulah yang menentukan cara menyambungkannya.
        ...printers.map(
          (e) => CustomIdNameEntity(
            id: e.kunci,
            name: '${e.deviceName} (${_jenisPrinter(e)})',
          ),
        ),
      ];

  String _jenisPrinter(PrinterModel p) {
    switch (p.typePrinter) {
      case PrinterType.usb:
        return 'USB';
      case PrinterType.bluetooth:
        return 'Bluetooth';
      case PrinterType.network:
        return 'Jaringan';
      default:
        return '?';
    }
  }

  void doPilihPrinterGelang(CustomIdNameEntity? val) {
    if (val == null || val.id == null) {
      printerUtil.simpanPrinterGelang(null);
      selectedPrinterGelang.value =
          CustomIdNameEntity(id: null, name: '--- Belum diatur ---');
      alert.success('Tersimpan',
          'Printer gelang dilepas. QR kembali dicetak menyambung struk.');
      update();
      return;
    }

    final pilihan = printers.firstWhereOrNull((e) => e.kunci == val.id);
    if (pilihan == null) {
      alert.error('Error', 'Printer tidak ditemukan, coba segarkan daftarnya.');
      return;
    }

    // Printer gelang dan printer struk tidak boleh perangkat yang sama —
    // gelang akan keluar di atas kertas struk dan sebaliknya.
    if (printerUtil.currPrinter != null &&
        printerUtil.currPrinter!.kunci == pilihan.kunci) {
      alert.warning('Perangkat Sama',
          'Printer ini sudah dipakai untuk struk. Pilih printer gelang yang lain.');
      return;
    }

    printerUtil.simpanPrinterGelang(pilihan);
    selectedPrinterGelang.value = val;
    alert.success('Tersimpan',
        'Printer gelang : ${pilihan.deviceName} (${_jenisPrinter(pilihan)})');
    update();
  }

  /// Menyimpan ukuran media. Nilai yang tidak masuk akal ditolak di sini juga,
  /// bukan hanya saat dibaca ulang — kasir berhak tahu angkanya salah saat itu
  /// juga, bukan menemukannya lewat printer yang diam tak mencetak.
  void doSimpanSetelanGelang() {
    if (_gelangTerkunci()) return;
    final lebar = double.tryParse(lebarGelangController.text.replaceAll(',', '.'));
    final tinggi = double.tryParse(tinggiGelangController.text.replaceAll(',', '.'));
    final jarak = double.tryParse(jarakGelangController.text.replaceAll(',', '.'));
    final margin = double.tryParse(marginGelangController.text.replaceAll(',', '.'));
    final qrMaks = double.tryParse(qrMaksGelangController.text.replaceAll(',', '.'));
    final shift = double.tryParse(shiftGelangController.text.replaceAll(',', '.'));
    final geserX = double.tryParse(geserXGelangController.text.replaceAll(',', '.'));
    final geserY = double.tryParse(geserYGelangController.text.replaceAll(',', '.'));

    if (lebar == null || lebar < 10 || lebar > 200) {
      alert.warning('Ukuran Salah', 'Lebar media harus 10-200 mm.');
      return;
    }
    if (tinggi == null || tinggi < 10 || tinggi > 400) {
      alert.warning('Ukuran Salah', 'Tinggi media harus 10-400 mm.');
      return;
    }
    if (jarak == null || jarak < 0 || jarak > 20) {
      alert.warning('Ukuran Salah', 'Jarak antar label harus 0-20 mm.');
      return;
    }
    if (margin == null || margin < 0 || margin > 20) {
      alert.warning('Ukuran Salah', 'Margin harus 0-20 mm.');
      return;
    }

    if (shift == null || shift < -100 || shift > 100) {
      alert.warning('Ukuran Salah', 'Geser lembar harus -100 sampai 100 mm.');
      return;
    }
    if (qrMaks == null || qrMaks < 0 || qrMaks > 50) {
      alert.warning('Ukuran Salah', 'QR maks harus 0-50 mm (0 = otomatis).');
      return;
    }
    if (geserX == null || geserX < -100 || geserX > 100) {
      alert.warning('Ukuran Salah', 'Geser X harus -100 sampai 100 mm.');
      return;
    }
    if (geserY == null || geserY < -100 || geserY > 100) {
      alert.warning('Ukuran Salah', 'Geser Y harus -100 sampai 100 mm.');
      return;
    }

    printerUtil.simpanSetelanGelang(WristbandConfigModel(
      dpi: dpiGelang.value,
      widthMm: lebar,
      heightMm: tinggi,
      gapMm: jarak,
      marginMm: margin,
      density: kerapatanGelang.value,
      speed: kecepatanGelang.value,
      direction: arahGelang.value,
      potong: potongGelang.value,
      qrMaksMm: qrMaks,
      geserXMm: geserX,
      geserYMm: geserY,
      putarIsi: putarIsiGelang.value,
      posisi: posisiGelang.value,
      sensor: sensorGelang.value,
      shiftMm: shift,
    ));
    _gelangBawaan.value = printerUtil.wristbandConfig.samaDenganTerbukti;
    alert.success('Tersimpan', 'Setelan printer gelang disimpan.');
    update();
  }

  /// Kembali ke setelan media yang terbukti ([WristbandConfigModel.terbukti]).
  Future<void> doPakaiSetelanBawaan() async {
    if (_gelangTerkunci()) return;
    final yakin = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Kembalikan ke Standar?'),
        content: const Text(
            'Semua setelan lanjutan dikembalikan ke setelan standar yang sudah '
            'dicoba dan berhasil untuk gelang 25 mm. Perubahan yang pernah '
            'disimpan akan hilang.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Kembalikan'),
          ),
        ],
      ),
    );
    if (yakin != true) return;
    printerUtil.simpanSetelanGelang(WristbandConfigModel.terbukti());
    muatSetelanGelang();
    alert.success('Tersimpan', 'Setelan printer gelang kembali ke standar.');
    update();
  }

  /// Menolak perubahan setelan gelang selama terkunci.
  ///
  /// Tampilan sudah menonaktifkan semua kontrolnya, jadi ini jarang terpicu.
  /// Tetap dipasang di setiap pintu masuk karena tampilan bukan satu-satunya
  /// pemanggil — dan kunci yang hanya ada di tampilan hanya berlaku sampai ada
  /// yang memanggil handler-nya dari tempat lain.
  bool _gelangTerkunci() {
    if (!terkunciGelang.value) return false;
    alert.warning('Setelan Terkunci',
        'Matikan Kunci setelan di Setelan lanjutan dulu untuk mengubahnya.');
    return true;
  }

  /// Saklar kunci setelan gelang.
  ///
  /// Mengunci langsung berlaku. Membuka meminta konfirmasi, karena justru di
  /// situlah perubahan tak sengaja dimulai.
  ///
  /// Saat dikunci, formulir dimuat ulang dari setelan tersimpan. Tanpa itu,
  /// angka yang sempat diketik tapi belum disimpan tetap terlihat di kolom yang
  /// terkunci — seolah-olah itulah setelan yang berlaku, padahal bukan.
  Future<void> doToggleKunciGelang(bool kunci) async {
    if (!kunci) {
      final yakin = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Buka Kunci Setelan?'),
          content: const Text(
              'Setelan ini sudah dicoba dan berhasil. Kalau salah ubah, '
              'cetakan bisa bergeser atau gelang tidak keluar sama sekali. '
              'Buka kunci hanya kalau memang perlu.'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Buka Kunci'),
            ),
          ],
        ),
      );
      if (yakin != true) return;
    }
    printerUtil.kunciSetelanGelang(kunci);
    terkunciGelang.value = kunci;
    if (kunci) muatSetelanGelang();
    update();
  }

  doDisconnectPrinter() async {
    isLoadingPrinterDiconect.value = true;
    await printerUtil.disconnectAll();
    await printerUtil.stopSubscription();
    currentPrinterConnect.value = printerUtil.currPrinter?.deviceName ?? '';
    var noneSelectedScreen = CustomIdNameEntity(
      id: null,
      name: '--- None ---',
    );
    selectedScreens.value = noneSelectedScreen;
    isLoadingPrinterDiconect.value = false;
    update();
  }
}
