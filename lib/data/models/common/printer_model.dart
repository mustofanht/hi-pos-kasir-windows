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

  /// Membaca kembali printer yang disimpan di setelan.
  ///
  /// `typePrinter` disimpan sebagai nama ('usb'/'bluetooth'/'network'); nilai
  /// yang tidak dikenali jatuh ke usb, jenis yang paling umum dipakai di kasir.
  factory PrinterModel.fromJson(Map<dynamic, dynamic> json) {
    return PrinterModel(
      id: json['id'] is int ? json['id'] as int : null,
      deviceName: json['deviceName']?.toString(),
      address: json['address']?.toString(),
      port: json['port']?.toString(),
      vendorId: json['vendorId']?.toString(),
      productId: json['productId']?.toString(),
      isBle: json['isBle'] == true,
      typePrinter: PrinterType.values.firstWhere(
        (e) => e.toString().split('.').last == json['typePrinter'],
        orElse: () => PrinterType.usb,
      ),
      state: json['state'] == true,
    );
  }

  /// Penanda satu perangkat. Printer USB dikenali dari vendorId, printer
  /// jaringan/bluetooth dari alamatnya — dipakai untuk mencocokkan pilihan yang
  /// tersimpan dengan perangkat yang terdeteksi saat ini.
  String get kunci => vendorId ?? address ?? deviceName ?? '';

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
