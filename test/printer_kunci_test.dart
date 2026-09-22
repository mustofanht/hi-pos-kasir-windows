import 'package:flutter_test/flutter_test.dart';
import 'package:jaya_propertiy/data/models/common/printer_model.dart';
import 'package:thermal_printer/thermal_printer.dart';

/// Kunci pilihan printer struk di Setting.
///
/// Dilaporkan 22 September 2026: di kasir Windows, printer thermal 80 mm yang
/// drivernya sudah terpasang tidak bisa dipilih — yang muncul selalu "please
/// select active printer". Plugin thermal_printer di Windows hanya mengisi nama
/// antrean cetak; vendorId, productId, dan alamatnya kosong. Dropdown dulu
/// memakai `vendorId ?? address` sebagai id, jadi setiap printer Windows
/// mendapat id null dan pilihan apa pun dianggap "belum memilih".
void main() {
  PrinterModel windows(String nama) =>
      PrinterModel(deviceName: nama, typePrinter: PrinterType.usb);

  test('printer Windows (hanya bernama) tetap punya kunci', () {
    final p = windows('POS-80 Printer');
    expect(p.vendorId ?? p.address, isNull,
        reason: 'beginilah plugin melaporkan printer di Windows');
    expect(p.kunci, isNotEmpty);
    expect(p.kunci, contains('POS-80 Printer'));
  });

  test('printer Windows yang berbeda nama mendapat kunci berbeda', () {
    final daftar = [
      windows('POS-80 Printer'),
      windows('Microsoft Print to PDF'),
      windows('OneNote (Desktop)'),
    ];
    expect(daftar.map((e) => e.kunci).toSet(), hasLength(3));
  });

  test('printer Android & Bluetooth tetap dibedakan seperti sebelumnya', () {
    final usb = PrinterModel(
      deviceName: 'Printer',
      vendorId: '1155',
      productId: '22304',
      typePrinter: PrinterType.usb,
    );
    final bt = PrinterModel(
      deviceName: 'Printer',
      address: '00:11:22:33:44:55',
      typePrinter: PrinterType.bluetooth,
    );
    expect(usb.kunci, isNot(bt.kunci));
  });
}
