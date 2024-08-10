import 'dart:async';
import 'dart:io';

import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/data/models/common/printer_model.dart';
import 'package:thermal_printer/thermal_printer.dart';

class PrinterUtil {
  var printerManager = PrinterManager.instance;
  StreamSubscription<PrinterDevice>? _subscription;
  StreamSubscription<USBStatus>? _subscriptionUsbStatus;
  // USBStatus _currentUsbStatus = USBStatus.none;
  BTStatus _currentStatus = BTStatus.none;
  List<int>? pendingTask;
  var defaultPrinterType = PrinterType.usb;
  PrinterModel? currPrinter;
  bool _isConnected = false;
  final _isBle = false;
  final _reconnect = false;

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

  Future<void> connect(PrinterModel selectedPrinter) async {
    switch (selectedPrinter.typePrinter) {
      case PrinterType.usb:
        await printerManager.connect(
            type: selectedPrinter.typePrinter,
            model: UsbPrinterInput(
                name: selectedPrinter.deviceName,
                productId: selectedPrinter.productId,
                vendorId: selectedPrinter.vendorId));
        _isConnected = true;
        break;
      case PrinterType.bluetooth:
        await printerManager.connect(
          type: selectedPrinter.typePrinter,
          model: BluetoothPrinterInput(
            name: selectedPrinter.deviceName,
            address: selectedPrinter.address!,
            isBle: selectedPrinter.isBle ?? false,
            autoConnect: _reconnect,
          ),
        );
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
    printerManager.disconnect(type: selectedPrinter.typePrinter);
    _isConnected = false;
  }

  Future<List<PrinterModel>> getListDevices() async {
    List<PrinterModel> deviceList = [];
    _subscription = printerManager
        .discovery(type: defaultPrinterType, isBle: _isBle)
        .listen((device) {
      logger.safeLog('DEVICE NAME : ${device.name} ');
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
  }

  Future<bool> connectPrinter() async {
    List<PrinterModel> printers = await getListDevices();
    if (printers.length == 1) {
      currPrinter = printers.first;
      logger.safeLog('NAME : ${currPrinter?.deviceName}');
      await disconnect(currPrinter!);
      await connect(currPrinter!);

      // stoped subsciption
      _subscription?.cancel();
      _subscriptionUsbStatus?.cancel();

      logger.safeLog('IS CONNECTED : $_isConnected');
      return Future.value(_isConnected);
    } else {
      currPrinter = null;
      return Future.value(false);
    }
  }

  Future<void> print(PrinterModel selectedPrinter, List<int> bytes) async {
    if (selectedPrinter.typePrinter == PrinterType.bluetooth &&
        Platform.isAndroid) {
      if (_currentStatus == BTStatus.connected) {
        printerManager.send(type: selectedPrinter.typePrinter, bytes: bytes);
        pendingTask = null;
      }
    } else {
      printerManager.send(type: selectedPrinter.typePrinter, bytes: bytes);
    }
  }
}

PrinterUtil printerUtil = PrinterUtil();
