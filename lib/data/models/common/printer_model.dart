import 'package:thermal_printer/thermal_printer.dart';

class PrinterModel {
  int? id;
  String? deviceName;
  String? address;
  String? port;
  String? vendorId;
  String? productId;
  bool? isBle;

  PrinterType typePrinter;
  bool? state;

  PrinterModel({
    this.id,
    this.deviceName,
    this.address,
    this.port,
    this.state,
    this.vendorId,
    this.productId,
    this.typePrinter = PrinterType.bluetooth,
    this.isBle = false,
  });

Map<String, dynamic> toJson() {
  return {
    'id': id,
    'deviceName': deviceName,
    'address': address,
    'port': port,
    'vendorId': vendorId,
    'productId': productId,
    'isBle': isBle,
    'typePrinter': typePrinter.toString().split('.').last,
    'state': state,
  };
}
}
