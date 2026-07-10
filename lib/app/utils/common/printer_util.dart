import 'dart:async';
import 'dart:io';

import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/data/models/common/printer_model.dart';
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

  Future<void> print(PrinterModel selectedPrinter, List<int> bytes) async {
    // logger.safeLog('_currentStatus : $_currentStatus');
    // logger.safeLog('selectedPrinter : ${selectedPrinter.typePrinter}');
    // logger.safeLog('Platform.isAndroid : ${Platform.isAndroid}');
    // logger.safeLog('printerManager : ${printerManager.currentStatusUSB}');
    // logger.safeLog('printerManager : ${printerManager.currentStatusBT}');
    // logger.safeLog('printerManager : ${printerManager.currentStatusTCP}');
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
}

PrinterUtil printerUtil = PrinterUtil();
