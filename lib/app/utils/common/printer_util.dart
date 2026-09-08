import 'dart:async';
import 'dart:io';

import 'package:jaya_propertiy/app/utils/common/device_simulation_util.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/common/print_capture_util.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/data/models/common/printer_model.dart';
import 'package:jaya_propertiy/data/models/common/wristband_config_model.dart';
import 'package:thermal_printer/thermal_printer.dart';

class PrinterUtil {
  var printerManager = PrinterManager.instance;
  StreamSubscription<PrinterDevice>? _subscription;
  StreamSubscription<BTStatus>? _subscriptionBtStatus;
  StreamSubscription<USBStatus>? _subscriptionUsbStatus;
  // USBStatus _currentUsbStatus = USBStatus.none;
  BTStatus _currentStatus = BTStatus.none;
  List<int>? pendingTask;
  var defaultPrinterType = PrinterType.usb;
  PrinterModel? currPrinter;
  bool _isConnected = false;
  final _isBle = false;
  final _reconnect = false;
  List<PrinterModel> printerList = [];

  static final GetStorage _store = GetStorage("sessions");

  /// Printer gelang — perangkat kedua, terpisah dari printer struk.
  ///
  /// Berbeda dari printer struk yang dipilih ulang tiap aplikasi dijalankan
  /// (`connectPrinterFirst`), pilihan ini **disimpan**: satu outlet punya dua
  /// printer sekaligus, dan menebak mana yang mana setiap pagi adalah cara pasti
  /// mencetak gelang di atas kertas struk.
  ///
  /// Null berarti belum diatur — alur cetak kembali ke perilaku lama, yaitu QR
  /// dicetak sebagai sambungan struk. Itu penting supaya outlet yang belum punya
  /// printer gelang tidak berhenti bisa mencetak tiket.
  PrinterModel? wristbandPrinter;

  WristbandConfigModel wristbandConfig = WristbandConfigModel();

  bool get punyaPrinterGelang => wristbandPrinter != null;

  /// Membaca setelan gelang yang tersimpan. Dipanggil sekali saat aplikasi mulai.
  void muatSetelanGelang() {
    try {
      final printer = _store.read(constant.wristbandPrinter);
      if (printer is Map) wristbandPrinter = PrinterModel.fromJson(printer);
      final config = _store.read(constant.wristbandConfig);
      if (config is Map) wristbandConfig = WristbandConfigModel.fromJson(config);
    } catch (e) {
      // Setelan rusak tidak boleh menggagalkan aplikasi mulai; kembali ke
      // bawaan, dan kasir tinggal memilih ulang printernya.
      logger.safeLog('Setelan gelang gagal dibaca : $e');
      wristbandPrinter = null;
      wristbandConfig = WristbandConfigModel();
    }
    logger.safeLog('PRINTER GELANG : ${wristbandPrinter?.deviceName ?? "(belum diatur)"}');
  }

  void simpanPrinterGelang(PrinterModel? printer) {
    wristbandPrinter = printer;
    if (printer == null) {
      _store.remove(constant.wristbandPrinter);
    } else {
      _store.write(constant.wristbandPrinter, printer.toJson());
    }
    logger.safeLog('PRINTER GELANG DISIMPAN : ${printer?.deviceName ?? "(dihapus)"}');
  }

  void simpanSetelanGelang(WristbandConfigModel config) {
    wristbandConfig = config;
    _store.write(constant.wristbandConfig, config.toJson());
    logger.safeLog('SETELAN GELANG : ${config.toJson()}');
  }

  Future<void> init() async {
    logger.safeLog(' ---- PRINTER ---- ');
    //  PrinterManager.instance.stateUSB is only supports on Android
    _subscriptionUsbStatus = PrinterManager.instance.stateUSB.listen((status) {
      logger.safeLog(
        ' ----------------- status usb $status ------------------ ',
      );
      // _currentUsbStatus = status;
      if (Platform.isAndroid) {
        if (status == USBStatus.connected && pendingTask != null) {
          Future.delayed(const Duration(milliseconds: 1000), () {
            PrinterManager.instance.send(
              type: PrinterType.usb,
              bytes: pendingTask!,
            );
            pendingTask = null;
          });
        }
      }
    });
  }

  Future<void> initBt() async {
    logger.safeLog(' ---- PRINTER BT ---- ');
    // subscription to listen change status of bluetooth connection
    _subscriptionBtStatus =
        PrinterManager.instance.stateBluetooth.listen((status) {
      logger.safeLog(
        ' ----------------- status bt $status ------------------ ',
      );
      _currentStatus = status;
      if (status == BTStatus.connected) {
        _isConnected = true;
      }
      if (status == BTStatus.none) {
        _isConnected = false;
      }
      if (status == BTStatus.connected && pendingTask != null) {
        if (Platform.isAndroid) {
          Future.delayed(const Duration(milliseconds: 1000), () {
            PrinterManager.instance
                .send(type: PrinterType.bluetooth, bytes: pendingTask!);
            pendingTask = null;
          });
        } else if (Platform.isIOS) {
          PrinterManager.instance
              .send(type: PrinterType.bluetooth, bytes: pendingTask!);
          pendingTask = null;
        }
      }
    });
  }

  Future<void> connect(PrinterModel selectedPrinter) async {
    logger.safeLog('CONNECT TO : ${selectedPrinter.toJson()}');
    if (isSimulated(selectedPrinter)) {
      currPrinter = selectedPrinter;
      _isConnected = true;
      return;
    }
    switch (selectedPrinter.typePrinter) {
      case PrinterType.usb:
        await printerManager.connect(
            type: selectedPrinter.typePrinter,
            model: UsbPrinterInput(
                name: selectedPrinter.deviceName,
                productId: selectedPrinter.productId,
                vendorId: selectedPrinter.vendorId));
        currPrinter = selectedPrinter;
        _isConnected = true;
        break;
      case PrinterType.bluetooth:
        var isConnected = await printerManager.connect(
          type: selectedPrinter.typePrinter,
          model: BluetoothPrinterInput(
            name: selectedPrinter.deviceName,
            address: selectedPrinter.address!,
            isBle: selectedPrinter.isBle ?? false,
            autoConnect: _reconnect,
          ),
        );
        currPrinter = selectedPrinter;
        if (isConnected) _currentStatus = BTStatus.connected;
        break;
      case PrinterType.network:
        await printerManager.connect(
            type: selectedPrinter.typePrinter,
            model: TcpPrinterInput(ipAddress: selectedPrinter.address!));
        _isConnected = true;
        break;
      default:
    }
  }

  Future<void> disconnect(PrinterModel selectedPrinter) async {
    if (isSimulated(selectedPrinter)) {
      currPrinter = null;
      _isConnected = false;
      return;
    }
    printerManager.disconnect(type: selectedPrinter.typePrinter);
    _isConnected = false;
    pendingTask = null;
    _currentStatus = BTStatus.none;
  }

  Future<void> disconnectAll() async {
    currPrinter = null;
    var listPrinter = await getListDevices();
    for (var element in listPrinter) {
      var isDisconnect =
          await printerManager.disconnect(type: element.typePrinter);
      logger.safeLog('${element.deviceName} : $isDisconnect');
    }
    _isConnected = false;
    pendingTask = null;
    _currentStatus = BTStatus.none;
  }

  Future<List<PrinterModel>> getListDevices() async {
    List<PrinterModel> deviceList = [];
    // Ditaruh paling depan supaya jadi pilihan pertama saat mengembangkan tanpa
    // perangkat; pemindaian USB/Bluetooth tetap jalan agar printer sungguhan
    // yang kebetulan terpasang tidak hilang dari daftar.
    if (deviceSimulation.printer) {
      deviceList.add(simulatedPrinter);
    }
    _subscription = printerManager
        .discovery(type: defaultPrinterType, isBle: _isBle)
        .listen((device) {
      // logger.safeLog('DEVICE NAME : ${device.name} ');
      deviceList.add(PrinterModel(
        deviceName: device.name,
        address: device.address,
        isBle: _isBle,
        vendorId: device.vendorId,
        productId: device.productId,
        typePrinter: defaultPrinterType,
      ));
    });
    await _subscription?.asFuture();
    await _subscription?.cancel();
    _subscription = printerManager
        .discovery(type: PrinterType.bluetooth, isBle: _isBle)
        .listen((device) {
      // logger.safeLog('DEVICE NAME : ${device.name} ');
      deviceList.add(PrinterModel(
        deviceName: device.name,
        address: device.address,
        isBle: _isBle,
        vendorId: device.vendorId,
        productId: device.productId,
        typePrinter: PrinterType.bluetooth,
      ));
    });
    await _subscription?.asFuture();
    await _subscription?.cancel();
    logger.safeLog('deviceList : $deviceList');
    return deviceList;
  }

  Future<List<PrinterModel>> getListDevicesUsb() async {
    List<PrinterModel> deviceList = [];
    if (deviceSimulation.printer) {
      deviceList.add(simulatedPrinter);
    }
    _subscription = printerManager
        .discovery(type: defaultPrinterType, isBle: _isBle)
        .listen((device) {
      // logger.safeLog('DEVICE NAME : ${device.name} ');
      deviceList.add(PrinterModel(
        deviceName: device.name,
        address: device.address,
        isBle: _isBle,
        vendorId: device.vendorId,
        productId: device.productId,
        typePrinter: defaultPrinterType,
      ));
    });
    await _subscription?.asFuture();
    await _subscription?.cancel();
    logger.safeLog('deviceList : $deviceList');
    return deviceList;
  }

  Future<void> stopSubscription() async {
    _subscription?.cancel();
    _subscriptionUsbStatus?.cancel();
    _subscriptionBtStatus?.cancel();
  }

  Future<bool> connectPrinter() async {
    logger.safeLog('printerList.length : ${printerList.length}');
    // // List<PrinterModel> printers = await getListDevices();
    // if (printerList.length == 1) {
    //   currPrinter = printerList.first;
    //   logger.safeLog('NAME : ${currPrinter?.deviceName}');
    //   await disconnect(currPrinter!);
    //   await connect(currPrinter!);

    //   // stoped subsciption
    //   _subscription?.cancel();
    //   _subscriptionUsbStatus?.cancel();
    //   _subscriptionBtStatus?.cancel();

    //   logger.safeLog('IS CONNECTED : $_isConnected');
    //   return Future.value(_isConnected);
    // } else {
    //   currPrinter = null;
    //   return Future.value(false);
    // }
    // currPrinter = null;
    // return Future.value(false);
    if (currPrinter == null) {
      return connectPrinterFirst();
    } else {
      return Future.value(_isConnected);
    }
  }

  // connect default is usb
  Future<bool> connectPrinterFirst() async {
    List<PrinterModel> printers = await getListDevicesUsb();
    logger.safeLog('printerList.length : ${printerList.length}');
    printerList = printers;
    // if (printers.length == 1) {
    //   if (currPrinter?.typePrinter == PrinterType.usb) {
    //     currPrinter = printers.first;
    //     logger.safeLog('NAME : ${currPrinter?.deviceName}');
    //     await disconnect(currPrinter!);
    //     await connect(currPrinter!);

    //     // stoped subsciption
    //     _subscription?.cancel();
    //     _subscriptionUsbStatus?.cancel();
    //     _subscriptionBtStatus?.cancel();

    //     logger.safeLog('IS CONNECTED : $_isConnected');
    //     return Future.value(_isConnected);
    //   } else {
    //     currPrinter = null;
    //     return Future.value(false);
    //   }
    // } else {
    //   for (var element in printers) {
    //     if (element.typePrinter == PrinterType.usb) {
    //       currPrinter = element;
    //       logger.safeLog('NAME : ${element.deviceName}');
    //       await disconnect(element);
    //       await connect(element);

    //       // stoped subsciption
    //       _subscription?.cancel();
    //       _subscriptionUsbStatus?.cancel();
    //       _subscriptionBtStatus?.cancel();

    //       logger.safeLog('IS CONNECTED : $_isConnected');
    //       return Future.value(_isConnected);
    //     }
    //   }
    //   currPrinter = null;
    //   return Future.value(false);
    // }

    if (printers.isNotEmpty) {
      for (var element in printers) {
        if (element.typePrinter == PrinterType.usb) {
          currPrinter = element;
          logger.safeLog('NAME : ${element.deviceName}');
          await disconnect(element);
          await connect(element);
          break;
        }
      }
    }

    // stoped subsciption
    _subscription?.cancel();
    _subscriptionUsbStatus?.cancel();
    _subscriptionBtStatus?.cancel();
    logger.safeLog('IS CONNECTED : $_isConnected');
    return Future.value(_isConnected);
  }

  /// Printer tiruan yang ditawarkan saat mode simulasi menyala, supaya alur
  /// "pilih printer lalu cetak" bisa dijalani utuh tanpa perangkat.
  static final PrinterModel simulatedPrinter = PrinterModel(
    deviceName: 'Printer Simulasi',
    address: 'simulasi',
    typePrinter: PrinterType.network,
    state: true,
  );

  static bool isSimulated(PrinterModel? printer) =>
      printer?.address == simulatedPrinter.address;

  Future<void> print(PrinterModel selectedPrinter, List<int> bytes) async {
    // Mode simulasi memutus jalur ke perangkat sepenuhnya: byte-nya ditangkap,
    // tidak ada yang dikirim ke USB/Bluetooth/TCP. Diperiksa paling awal supaya
    // tidak ada cabang di bawah yang bisa lolos ke perangkat.
    if (deviceSimulation.printer || isSimulated(selectedPrinter)) {
      await printCapture.capture(bytes);
      return;
    }

    // logger.safeLog('_currentStatus : $_currentStatus');
    // logger.safeLog('selectedPrinter : ${selectedPrinter.typePrinter}');
    // logger.safeLog('Platform.isAndroid : ${Platform.isAndroid}');
    // logger.safeLog('printerManager : ${printerManager.currentStatusUSB}');
    // logger.safeLog('printerManager : ${printerManager.currentStatusBT}');
    // logger.safeLog('printerManager : ${printerManager.currentStatusTCP}');
    await _kirim(selectedPrinter, bytes);
  }

  Future<void> _kirim(PrinterModel selectedPrinter, List<int> bytes) async {
    if (selectedPrinter.typePrinter == PrinterType.bluetooth &&
        Platform.isAndroid) {
      // logger.safeLog('PRINT USB 1 ----- ');
      // logger.safeLog(
      //     'TO PRINT READY : ${(_currentStatus == BTStatus.connected)}');
      // logger.safeLog('_currentStatus BT : $_currentStatus');
      if (_currentStatus == BTStatus.connected) {
        // logger.safeLog('PRINT USB 2 ----- ');
        var isPrinted = await printerManager.send(
            type: selectedPrinter.typePrinter, bytes: bytes);
        pendingTask = null;
        if (Platform.isAndroid) pendingTask = bytes;
        logger.safeLog('IS PRINT : $isPrinted ');
      }
    } else {
      // logger.safeLog('PRINT ${selectedPrinter.typePrinter} ----- ');
      var isPrinted = await printerManager.send(
          type: selectedPrinter.typePrinter, bytes: bytes);
      logger.safeLog('IS PRINT : $isPrinted ');
    }
  }

  /// Mencetak ke printer gelang, lalu mengembalikan sambungan ke printer struk.
  ///
  /// Perlu tarian sambung–putus karena `PrinterManager` menyimpan **satu**
  /// sambungan per jenis: dua printer USB tidak bisa tersambung bersamaan, dan
  /// `send(type: usb)` akan pergi ke printer USB mana pun yang sedang aktif.
  /// Kalau printer gelang dan printer struk berbeda jenis (mis. struk USB,
  /// gelang jaringan), tidak ada yang perlu diputus dan jalurnya lebih cepat.
  ///
  /// Mengembalikan false bila printer gelang belum diatur — pemanggil memakai
  /// itu untuk jatuh kembali ke cetak QR di kertas struk.
  Future<bool> printWristband(List<int> bytes) async {
    final target = wristbandPrinter;
    if (target == null) return false;

    if (deviceSimulation.printer || isSimulated(target)) {
      await printCapture.capture(bytes);
      return true;
    }

    final printerStruk = currPrinter;
    final bentrok = printerStruk != null &&
        printerStruk.typePrinter == target.typePrinter &&
        printerStruk.kunci != target.kunci;

    try {
      if (bentrok) await disconnect(printerStruk);
      await connect(target);
      await _kirim(target, bytes);
      if (bentrok) {
        await disconnect(target);
        await connect(printerStruk);
      }
      return true;
    } catch (e) {
      logger.safeLog('CETAK GELANG GAGAL : $e');
      return false;
    } finally {
      // `connect()` menggeser penanda printer aktif; kembalikan ke printer struk
      // supaya cetakan struk berikutnya tidak diam-diam pergi ke printer gelang.
      currPrinter = printerStruk;
    }
  }
}

PrinterUtil printerUtil = PrinterUtil();
