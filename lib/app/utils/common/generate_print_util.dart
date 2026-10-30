import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:image/image.dart' as img;
import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/app/utils/common/date_time_util.dart';
import 'package:jaya_propertiy/app/utils/common/kas_util.dart';
import 'package:jaya_propertiy/app/utils/common/kepala_struk_util.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/constant/date_format_constant.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/data/models/order/order_addon_model.dart';
import 'package:jaya_propertiy/data/models/order/order_model.dart';
import 'package:jaya_propertiy/domain/entities/shift/shift_detail_entity.dart';
// import 'package:jaya_propertiy/data/models/order/order_ticket_model.dart';

/// Nama pembeli untuk dicetak; yang kosong ditulis "-".
///
/// Ditulis "-", bukan dibiarkan kosong: baris berlabel yang isinya hampa
/// terbaca sebagai cetakan yang terpotong, dan petugas mencetaknya lagi.
String _namaPembeli(String? nama) {
  final bersih = (nama ?? '').trim();
  return bersih.isEmpty ? '-' : bersih;
}

/// Keterangan voucher yang layak dicetak, atau `null` bila tidak ada.
///
/// Berbeda dari nama pembeli, baris ini **dihilangkan** saat kosong — bukan
/// ditulis "-". Nama pembeli selalu relevan; keterangan voucher hanya ada pada
/// transaksi yang memakai voucher, dan baris "Ket. Voucher : -" pada setiap
/// struk hanya memanjangkan kertas tanpa menjelaskan apa pun.
///
/// Layar penjualan mengirim spasi untuk isian kosong
/// (`keteranganVoucher.text.isEmpty ? ' ' : ...`), jadi memeriksa `isEmpty`
/// saja tidak cukup — tanpa `trim()` setiap struk mendapat baris kosong
/// berlabel.
String? _keteranganVoucher(String? teks) {
  final bersih = (teks ?? '').trim();
  if (bersih.isEmpty || bersih == '-') return null;
  return bersih;
}

class GeneratePrintUtil {
  List<int> buildListRentalPayment(
    Generator generator,
    OrderAddonModel element,
  ) {
    List<int> bytes = [];
    bytes += generator.row(
      [
        PosColumn(
          text: element.addOn?.productName ?? '',
          width: 12,
          styles: const PosStyles(
            align: PosAlign.left,
          ),
        ),
      ],
    );
    bytes += generator.row(
      [
        PosColumn(
          text:
              '(${element.rentHdrDtl?.startDate != null && element.rentHdrDtl?.endDate != null ? '${dateTimeUtil.getFormattedDate(date: element.rentHdrDtl!.startDate!, format: dateFormat.hourMinutes)} - ${dateTimeUtil.getFormattedDate(date: element.rentHdrDtl!.endDate!, format: dateFormat.hourMinutes)}' : ''}) (${element.rentHdrDtl?.hour} Jam)',
          width: 7,
          styles: const PosStyles(
            align: PosAlign.left,
          ),
        ),
        PosColumn(
          text: common.currencyFormat(element.ordadTotalAmount),
          width: 5,
          styles: const PosStyles(
            align: PosAlign.right,
          ),
        )
      ],
    );
    return bytes;
  }

  /// Struk penjualan — dan, dengan [strukVoid] true, struk PEMBATALAN.
  ///
  /// Keduanya satu fungsi dengan sengaja: struk void harus memperlihatkan
  /// barang dan nilai yang dibatalkan, persis seperti struk aslinya. Dua fungsi
  /// terpisah akan berakhir dengan dua bentuk yang berbeda, dan pelanggan
  /// memegang kertas yang tidak bisa dicocokkan dengan struk pembeliannya.
  Future<List<int>> dataPaymentTiketPrint({
    String? locationName,
    String? locationAddress,
    String? locationPhone,
    String? kasirName,
    required PaperSize paperSize,
    required OrderModel body,
    bool strukVoid = false,
    String? alasanVoid,
    String? disetujuiOleh,
    /// true = struk ini CETAK ULANG, bukan cetakan pertama.
    ///
    /// Pelanggan maupun pemeriksa kas tidak bisa membedakan struk kedua dari
    /// struk asli: isinya sama persis, termasuk nomor transaksi dan nominalnya.
    /// Satu transaksi dengan dua lembar struk tanpa tanda adalah dua bukti
    /// pembayaran yang sama sahnya - dan itu jalan termudah menggandakan bukti.
    bool cetakUlang = false,
  }) async {
    List<int> bytes = [];
    // Using default profile
    final profile = await CapabilityProfile.load();
    final generator = Generator(paperSize, profile);
    bytes += generator.setGlobalFont(PosFontType.fontA);
    bytes += generator.reset();

    // final ByteData data = await rootBundle.load(assetsConstant.imgLogo);
    // final Uint8List bytesImg = data.buffer.asUint8List();
    // img.Image? image = img.decodeImage(bytesImg);

    // if (image != null) {
    //   if (image.width > PaperSize.mm80.width) {
    //     image = img.copyResize(image, width: PaperSize.mm80.width);
    //   }
    //   image = img.grayscale(image);
    //   bytes += generator.image(image);
    // }

    // Location Name
    bytes += KepalaStruk.cetak(
      generator,
      nama: locationName,
      alamat: locationAddress,
      telepon: locationPhone,
    );

    // Penanda CETAK ULANG ditaruh paling atas bersama penanda pembatalan:
    // penanda yang tersembunyi di kaki struk tidak terbaca siapa pun yang
    // hanya melihat lembarnya sekilas.
    if (cetakUlang) {
      bytes += generator.text(
        '*** CETAK ULANG ***',
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      );
      bytes += generator.text(
        'BUKAN STRUK ASLI',
        styles: const PosStyles(align: PosAlign.center, bold: true),
      );
      bytes += generator.text(
        'Dicetak ulang: ${dateTimeUtil.now(format: dateFormat.fullTimePrinted)}',
        styles: const PosStyles(align: PosAlign.center),
      );
      bytes += generator.hr();
    }

    // Penanda pembatalan ditaruh PALING ATAS, besar, sebelum nomor apa pun.
    // Struk void yang bentuknya sama dengan struk pembelian dan hanya berbeda
    // satu baris di bawah akan dibaca sebagai bukti pembayaran yang sah.
    if (strukVoid) {
      bytes += generator.text(
        '*** VOID / PEMBATALAN ***',
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      );
      bytes += generator.text(
        'Transaksi ini DIBATALKAN',
        styles: const PosStyles(align: PosAlign.center, bold: true),
      );
      bytes += generator.hr();
    }

    // Print Store Information
    bytes += generator.text(
      'No Reff. ${body.orderReffno ?? ''}',
      styles: const PosStyles(
        align: PosAlign.left,
        bold: true,
      ),
    );
    bytes += generator.text(
      'Order ID : ${body.orderNumber ?? ''}',
      styles: const PosStyles(
        align: PosAlign.left,
        bold: true,
      ),
    );
    bytes += generator.text(
      'Kasir :  $kasirName',
      styles: const PosStyles(
        align: PosAlign.left,
        bold: true,
      ),
    );
    bytes += generator.text(
      body.paymentDate != null
          ? dateTimeUtil.getFormattedDate(
              date: body.paymentDate!,
              format: dateFormat.fullTimePrinted,
            )
          : dateTimeUtil.now(
              format: dateFormat.fullTimePrinted,
            ),
      styles: const PosStyles(
        align: PosAlign.left,
        bold: true,
      ),
    );
    // Nama pembeli DIBERI LABEL dan satu baris sendiri (22 Okt 2026).
    // Sebelumnya ia dicetak tanpa keterangan di ujung kanan baris tanggal,
    // sehingga terbaca seperti potongan nama kasir atau nama tiket — dan pada
    // nama panjang ia terpotong oleh kolom tanggal di sebelahnya.
    bytes += generator.text(
      'Nama Pembeli : ${_namaPembeli(body.orderName)}',
      styles: const PosStyles(
        align: PosAlign.left,
        bold: true,
      ),
    );
    // Keterangan Voucher yang diketik kasir di menu Pembayaran (26 Okt 2026).
    // Sebelumnya hanya tersimpan di `trn_order.order_voucher_desc` dan hanya
    // terlihat di back office — pelanggan maupun kasir tidak punya bukti
    // voucher mana yang dipakai pada transaksi itu.
    final ketVoucher = _keteranganVoucher(body.orderVoucherDesc);
    if (ketVoucher != null) {
      bytes += generator.text(
        'Ket. Voucher : $ketVoucher',
        styles: const PosStyles(
          align: PosAlign.left,
          bold: true,
        ),
      );
    }
    bytes += generator.hr();

    // double totalBayar = 0;
    // List Ticket Order
    for (var element in body.listTicket) {
      // totalBayar += element.totalAmount;
      bytes += generator.text(
        element.ticket?.ticketName ?? '',
        styles: const PosStyles(
          align: PosAlign.left,
        ),
      );
      bytes += generator.row(
        [
          PosColumn(
            text: 'Rp',
            width: 2,
          ),
          PosColumn(
            text: element.ticket?.ticketPrice != null
                ? common.currencyFormat(element.ticket!.ticketPrice!)
                : '',
            width: 3,
          ),
          // PosColumn(
          //   text: '( 0% )',
          //   width: 2,
          // ),
          PosColumn(
            text: 'x ${element.totalTicket}',
            width: 2,
          ),
          PosColumn(
            text: common.currencyFormat(element.totalAmount),
            width: 5,
            styles: const PosStyles(
              align: PosAlign.right,
            ),
          )
        ],
      );
    }
    // List item Order
    for (var element in body.listProduct) {
      // totalBayar += element.ordadTotalAmount;
      logger.safeLog('PRODUCT TO PRINT : ${element.toJson()}');
      if (element.rentHdrDtl != null) {
        bytes += buildListRentalPayment(generator, element);
      } else {
        bytes += generator.text(
          element.addOn?.productName ?? '',
          styles: const PosStyles(
            align: PosAlign.left,
          ),
        );
        bytes += generator.row(
          [
            PosColumn(
              text: 'Rp',
              width: 2,
            ),
            PosColumn(
              text: element.addOn?.productPrice != null
                  ? common.currencyFormat(element.addOn!.productPrice!)
                  : '',
              width: 3,
            ),
            PosColumn(
              text: 'x ${element.ordadTotalAddon}',
              width: 2,
            ),
            PosColumn(
              text: common.currencyFormat(element.ordadTotalAmount),
              width: 5,
              styles: const PosStyles(
                align: PosAlign.right,
              ),
            )
          ],
        );
      }
    }
    // Booking lapangan: dicetak dengan format yang SAMA seperti sewa item
    // (nama court + rentang jam + durasi + harga) lewat buildListRentalPayment.
    for (var element in body.lapanganPrintLines ?? <OrderAddonModel>[]) {
      bytes += buildListRentalPayment(generator, element);
    }
    // Kelas: nama kelas + sesi + tanggal, lalu harga x jumlah anak.
    for (var element in body.kelasPrintLines ?? <OrderAddonModel>[]) {
      bytes += generator.text(
        element.addOn?.productName ?? '',
        styles: const PosStyles(
          align: PosAlign.left,
        ),
      );
      bytes += generator.row(
        [
          PosColumn(
            text: 'Rp',
            width: 2,
          ),
          PosColumn(
            text: element.addOn?.productPrice != null
                ? common.currencyFormat(element.addOn!.productPrice!)
                : '',
            width: 3,
          ),
          PosColumn(
            text: 'x ${element.ordadTotalAddon}',
            width: 2,
          ),
          PosColumn(
            text: common.currencyFormat(element.ordadTotalAmount),
            width: 5,
            styles: const PosStyles(
              align: PosAlign.right,
            ),
          )
        ],
      );
    }
    // List voucher Order
    // double totalPotongan = 0;
    for (var element in body.listVoucher) {
      bytes += generator.text(
        element.voucher?.voucherName ?? '',
        styles: const PosStyles(
          align: PosAlign.left,
        ),
      );
      if (element.voucher!.voucherUnitType == UnitType.PERCENT) {
        bytes += generator.row(
          [
            PosColumn(
              text: '%',
              width: 2,
            ),
            PosColumn(
              text: element.voucher?.voucherUnitValue != null
                  ? common.currencyFormat(element.voucher!.voucherUnitValue!)
                  : '',
              width: 4,
            ),
            PosColumn(
              text: '- ${common.currencyFormat(element.ordvcTotalAmount)}',
              width: 6,
              styles: const PosStyles(
                align: PosAlign.right,
              ),
            )
          ],
        );
      } else {
        bytes += generator.row(
          [
            PosColumn(
              text: 'Rp',
              width: 2,
            ),
            PosColumn(
              text: element.voucher?.voucherUnitValue != null
                  ? common.currencyFormat(element.voucher!.voucherUnitValue!)
                  : '',
              width: 4,
            ),
            PosColumn(
              text: '- ${common.currencyFormat(element.ordvcTotalAmount)}',
              width: 6,
              styles: const PosStyles(
                align: PosAlign.right,
              ),
            )
          ],
        );
      }
    }
    // double totalPotongan = 0;
    for (var element in body.listVoucherPrice) {
      bytes += generator.text(
        element.entity?.vpName ?? '',
        styles: const PosStyles(
          align: PosAlign.left,
        ),
      );
      if (element.entity!.vpUnitType == UnitType.PERCENT) {
        bytes += generator.row(
          [
            PosColumn(
              text: '%',
              width: 2,
            ),
            PosColumn(
              text: element.entity?.vpUnitValue != null
                  ? common.currencyFormat(element.entity!.vpUnitValue!)
                  : '',
              width: 4,
            ),
            PosColumn(
              text: '- ${common.currencyFormat(element.ovpTotalAmount)}',
              width: 6,
              styles: const PosStyles(
                align: PosAlign.right,
              ),
            )
          ],
        );
      } else {
        bytes += generator.row(
          [
            PosColumn(
              text: 'Rp',
              width: 2,
            ),
            PosColumn(
              text: element.entity?.vpUnitValue != null
                  ? common.currencyFormat(element.entity!.vpUnitValue!)
                  : '',
              width: 4,
            ),
            PosColumn(
              text: '- ${common.currencyFormat(element.ovpTotalAmount)}',
              width: 6,
              styles: const PosStyles(
                align: PosAlign.right,
              ),
            )
          ],
        );
      }
    }
    // double totalPotongan = 0;
    for (var element in body.listDepositUse) {
      bytes += generator.text(
        element.entity?.dpName ?? '',
        styles: const PosStyles(
          align: PosAlign.left,
        ),
      );
      bytes += generator.row(
        [
          PosColumn(
            text: 'Rp',
            width: 2,
          ),
          PosColumn(
            text: element.entity?.dpAmount != null
                ? common.currencyFormat(element.entity!.dpAmount!)
                : '',
            width: 4,
          ),
          PosColumn(
            text: '- ${common.currencyFormat(element.odpTotalAmount)}',
            width: 6,
            styles: const PosStyles(
              align: PosAlign.right,
            ),
          )
        ],
      );
    }
    bytes += generator.hr();
    if (body.adminFeeAmt > 0) {
      bytes += generator.row(
        [
          PosColumn(
            text: 'Biaya Admin',
            width: 6,
          ),
          PosColumn(
            text: common.currencyFormat(body.adminFeeAmt),
            width: 6,
            styles: const PosStyles(
              align: PosAlign.right,
            ),
          ),
        ],
      );
    }
    // if (totalPotongan > 0) {
    //   bytes += generator.row(
    //     [
    //       PosColumn(
    //         text: 'Potongan',
    //         width: 6,
    //       ),
    //       PosColumn(
    //         text: '- ${common.currencyFormat(totalPotongan)}',
    //         width: 6,
    //         styles: const PosStyles(
    //           align: PosAlign.right,
    //         ),
    //       ),
    //     ],
    //   );
    // }
    // Split payment: 1 baris per metode (nama + nominal leg masing-masing).
    // Order normal tetap 1 baris seperti semula.
    if (body.splitPayments != null && body.splitPayments!.isNotEmpty) {
      for (final leg in body.splitPayments!) {
        bytes += generator.row(
          [
            PosColumn(
              text: leg.paymentName ?? leg.paymentCode ?? '-',
              width: 6,
            ),
            PosColumn(
              text: common.currencyFormat(leg.amount ?? 0),
              width: 6,
              styles: const PosStyles(
                align: PosAlign.right,
              ),
            ),
          ],
        );
      }
    } else {
      bytes += generator.row(
        [
          PosColumn(
            // text: MapPaymentMethod[body.orderPaidBy] ?? '',
            text: body.orderPaidByName,
            width: 6,
          ),
          PosColumn(
            text: common.currencyFormat(body.orderTotalAmt),
            width: 6,
            styles: const PosStyles(
              align: PosAlign.right,
            ),
          ),
        ],
      );
    }
    // Print Total
    int totalPak =
        body.listCreateTicket == null ? 0 : body.listCreateTicket!.length;
    bytes += generator.row(
      [
        PosColumn(
          text: 'TOTAL',
          width: 4,
        ),
        PosColumn(
          text: '$totalPak PAK',
          width: 2,
        ),
        PosColumn(
          text: common.currencyFormat(body.orderTotalAmt),
          width: 6,
          styles: const PosStyles(
            align: PosAlign.right,
          ),
        ),
      ],
    );
    // Uang Diterima & Kembalian -- hanya terisi untuk pembayaran TUNAI
    // tunggal (lihat OrderController.doOrderPayment); order split atau non-
    // tunai tidak pernah mengisi field ini, jadi baris ini otomatis terlewat.
    if (body.uangDiterima != null) {
      bytes += generator.row(
        [
          PosColumn(
            text: 'Uang Diterima',
            width: 6,
          ),
          PosColumn(
            text: common.currencyFormat(body.uangDiterima!),
            width: 6,
            styles: const PosStyles(
              align: PosAlign.right,
            ),
          ),
        ],
      );
      bytes += generator.row(
        [
          PosColumn(
            text: 'Kembalian',
            width: 6,
          ),
          PosColumn(
            text: common.currencyFormat(body.kembalian ?? 0),
            width: 6,
            styles: const PosStyles(
              align: PosAlign.right,
            ),
          ),
        ],
      );
    }
    if (cetakUlang) {
      // Diulang di bawah dengan sengaja: struk yang panjang sering dipotong
      // atau difoto sebagian, dan bagian atasnya hilang.
      bytes += generator.hr();
      bytes += generator.text(
        '*** CETAK ULANG - BUKAN STRUK ASLI ***',
        styles: const PosStyles(align: PosAlign.center, bold: true),
      );
    }

    if (strukVoid) {
      bytes += generator.hr();
      bytes += generator.text(
        'Alasan : ${(alasanVoid ?? '').trim().isEmpty ? '-' : alasanVoid!.trim()}',
        styles: const PosStyles(align: PosAlign.left),
      );
      // Penyetuju ikut tercetak: inilah yang membedakan pembatalan yang sah
      // dari kertas yang dibuat kasir sendiri.
      bytes += generator.text(
        'Disetujui : ${(disetujuiOleh ?? '').trim().isEmpty ? '-' : disetujuiOleh!.trim()}',
        styles: const PosStyles(align: PosAlign.left),
      );
      bytes += generator.text(
        'Uang dikembalikan sesuai ketentuan outlet.',
        styles: const PosStyles(align: PosAlign.left),
      );
    }

    bytes += generator.hr();
    // Print Thank You Message
    bytes += generator.text(
      '>>>PERHATIAN<<<',
      styles: const PosStyles(
        align: PosAlign.left,
        bold: true,
      ),
    );
    bytes += generator.text(
      '1.Jagalah barang-barang anda',
      styles: const PosStyles(
        align: PosAlign.left,
      ),
    );
    bytes += generator.text(
      '2.Harap struk ini disimpan dengan baik',
      styles: const PosStyles(
        align: PosAlign.left,
      ),
    );
    bytes += generator.emptyLines(1);
    bytes += generator.text(
      'TIKET YANG SUDAH DI BELI',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.text(
      'TIDAK DAPAT DITUKAR/DIKEMBALIKAN',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.text(
      'TERIMA KASIH ATAS KUNJUNGAN ANDA',
      styles: const PosStyles(
        align: PosAlign.center,
      ),
    );
    // bytes += generator.emptyLines(1);
    bytes += generator.cut();

    return bytes;
  }

  Future<List<int>> dataGatePrint({
    String? locationName,
    required PaperSize paperSize,
    required String orderNo,
    required String reffNo,
    /// Nama pembeli, dicetak di bawah Order ID (22 Okt 2026).
    ///
    /// Tiket QR tidak membawa nama siapa pun sebelum ini. Saat selembar tiket
    /// tertinggal di meja atau tertukar antar-rombongan, tidak ada cara
    /// mengembalikannya kepada pemiliknya — dan di gate, petugas tidak punya
    /// pegangan untuk mencocokkan tiket dengan orang yang membawanya.
    String? namaPembeli,
    required int pakOf,
    required int pakTotal,
    required String qrCode,
    DateTime? paymentDate,
    required String expiredAt,
    // required OrderTicketModel ticketModel,
    String? ticketName,
    String? isCompanion, // Y = pendamping, N = berbayar
  }) async {
    List<int> bytes = [];
    // Using default profile
    final profile = await CapabilityProfile.load();
    final generator = Generator(paperSize, profile);
    bytes += generator.setGlobalFont(PosFontType.fontA);
    bytes += generator.reset();

    // Location Name -- dipecah per baris kalau panjang, lihat KepalaStruk.cetakNama
    if (locationName != null) {
      bytes += KepalaStruk.cetakNama(generator, locationName);
      bytes += generator.emptyLines(1);
    }

    // Print Store Information
    bytes += generator.text(
      'No Reff. $reffNo',
      styles: const PosStyles(
        align: PosAlign.left,
        bold: true,
      ),
    );
    bytes += generator.text(
      'Order ID : $orderNo',
      styles: const PosStyles(
        align: PosAlign.left,
        bold: true,
      ),
    );
    bytes += generator.text(
      'Nama Pembeli : ${_namaPembeli(namaPembeli)}',
      styles: const PosStyles(
        align: PosAlign.left,
        bold: true,
      ),
    );
    bytes += generator.text(
      paymentDate != null
          ? dateTimeUtil.getFormattedDate(
              date: paymentDate,
              format: dateFormat.fullTimePrinted,
            )
          : dateTimeUtil.now(
              format: dateFormat.fullTimePrinted,
            ),
      styles: const PosStyles(
        align: PosAlign.left,
        bold: true,
      ),
    );
    bytes += generator.hr();

    bytes += generator.text(
      ticketName ?? '',
      styles: const PosStyles(
        align: PosAlign.center,
      ),
    );

    // Tambahkan text "TIKET PENDAMPING (GRATIS)" jika ini QR pendamping.
    // Font NORMAL (bukan size2) -- di lebar ganda, teks 25 karakter ini
    // melebihi kapasitas satu baris (24 karakter di kertas 80mm) dan
    // tanda kurung tutup ")" terlempar ke baris berikutnya saat dicetak.
    if (isCompanion == 'Y') {
      bytes += generator.text(
        'TIKET PENDAMPING (GRATIS)',
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
        ),
      );
    }

    bytes += generator.text(
      '$pakOf of $pakTotal PAK',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
      ),
    );

    bytes += generator.emptyLines(1);
// QRCODE
    bytes += generator.qrcode(
      qrCode,
      align: PosAlign.center,
      size: QRSize.Size8,
    );
    bytes += generator.emptyLines(1);
    bytes += generator.text(
      'Berlaku $expiredAt',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
      ),
    );
    // bytes += generator.emptyLines(1);
    bytes += generator.cut();

    return bytes;
  }

  /// Struk settlement/tutup shift, formatnya mengikuti contoh "Cashier
  /// Report" (`print_out.png`): kepala struk (nama, alamat, telepon, email,
  /// logo — dari master lokasi), hitungan uang laci per pecahan (SEMUA
  /// pecahan, termasuk yang nol lembar — bukan cuma yang terisi), ringkasan
  /// pembayaran per metode, rincian penjualan (termasuk total yang dibayar
  /// pakai voucher/potongan/deposit), lalu rincian laci tunai sampai total
  /// tunai. TIDAK ada lagi rekonsiliasi Aktual vs Komputer per metode
  /// (dihapus atas permintaan — dianggap tidak perlu di struk).
  ///
  /// HANYA dipanggil untuk lokasi yang memakai modal kas ([ShiftDetailEntity.
  /// pakaiModal]) — pemanggil (lihat [ShiftPageController.doPrintSettlement])
  /// sudah menjaga ini; dipastikan lagi di sini supaya fungsi ini sendiri
  /// tidak pernah menghasilkan struk yang section kasnya kosong/tidak relevan.
  ///
  /// Dibangun dari field yang sudah ada di [ShiftDetailEntity] (API yang sama
  /// dipakai layar Shift) — tidak ada angka yang direka; bagian yang
  /// datanya tidak pernah dihitung di aplikasi ini (mis. kas masuk/keluar,
  /// retur, custom price — ada di contoh `print_out.png` tapi itu dari sistem
  /// POS lain) sengaja tidak ditampilkan, bukan ditulis nol.
  Future<List<int>> dataSettlementPrint({
    String? locationName,
    String? locationAddress,
    String? locationPhone,
    String? locationEmail,
    img.Image? logo,
    required PaperSize paperSize,
    required ShiftDetailEntity detail,
  }) async {
    List<int> bytes = [];
    final profile = await CapabilityProfile.load();
    final generator = Generator(paperSize, profile);
    bytes += generator.setGlobalFont(PosFontType.fontA);
    bytes += generator.reset();

    bytes += KepalaStruk.cetak(
      generator,
      nama: locationName,
      alamat: locationAddress,
      telepon: locationPhone,
      email: locationEmail,
      logo: logo,
    );

    final tanggal = detail.shftEnd ?? detail.shftStart;
    bytes += generator.text(
      'CASHIER REPORT'
      '${detail.lokasiName != null ? ' (${detail.lokasiName})' : ''}',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.emptyLines(1);
    bytes += generator.row([
      PosColumn(text: 'Kasir', width: 4),
      PosColumn(text: ': ${detail.userFullName ?? '-'}', width: 8),
    ]);
    bytes += generator.row([
      PosColumn(text: 'Tanggal', width: 4),
      PosColumn(
        text:
            ': ${tanggal != null ? dateTimeUtil.getFormattedDate(date: tanggal, format: dateFormat.dateWithoutTime) : '-'}',
        width: 8,
      ),
    ]);
    bytes += generator.hr();

    // Hitungan uang laci saat tutup shift — SEMUA pecahan yang dikenal
    // aplikasi (KasUtil.pecahan), bukan cuma yang lembarnya diisi, supaya
    // bentuknya sama seperti contoh (tiap pecahan selalu tampil, 0 pun
    // ditulis apa adanya).
    if (detail.pakaiModal) {
      final lembarPerPecahan = <int, int>{
        for (final p in detail.listPecahanAkhir ?? const [])
          p.pecahan: p.lembar,
      };
      bytes += generator.text(
        'HITUNGAN UANG LACI',
        styles: const PosStyles(align: PosAlign.left, bold: true),
      );
      for (final pecahan in KasUtil.pecahan) {
        final lembar = lembarPerPecahan[pecahan] ?? 0;
        final jumlah = (pecahan * lembar).toDouble();
        bytes += generator.row([
          PosColumn(
            text: '${common.currencyFormat(pecahan.toDouble())} x $lembar ',
            width: 8,
          ),
          PosColumn(
            text: common.currencyFormat(jumlah),
            width: 4,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]);
      }
      bytes += generator.hr();
    }

    // Ringkasan pembayaran per metode, persis seperti yang dijumlahkan server
    // (listSumPayment) — satu sumber yang sama dengan layar Rincian Shift.
    final listPembayaran = detail.listSumPayment ?? [];
    double totalPembayaran = 0;
    for (final p in listPembayaran) {
      totalPembayaran += p.amount ?? 0;
      bytes += generator.row([
        PosColumn(text: p.name ?? '-', width: 7),
        PosColumn(
          text: common.currencyFormat(p.amount ?? 0),
          width: 5,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }
    bytes += generator.hr();
    bytes += generator.row([
      PosColumn(text: 'Total', width: 7, styles: const PosStyles(bold: true)),
      PosColumn(
        text: common.currencyFormat(totalPembayaran),
        width: 5,
        styles: const PosStyles(align: PosAlign.right, bold: true),
      ),
    ]);
    bytes += generator.hr();

    // Rincian penjualan: total netto (= total pembayaran di atas, karena
    // voucher/potongan/deposit sudah dipotong sebelum tersimpan sebagai
    // pembayaran), lalu voucher, potongan, & deposit sebagai informasi jumlah
    // yang terpakai.
    bytes += generator.text(
      'RINCIAN TRANSAKSI',
      styles: const PosStyles(align: PosAlign.left, bold: true),
    );
    final jmlTransaksi = (detail.tiketCount ?? 0) + (detail.itemCount ?? 0);
    bytes += generator.row([
      PosColumn(text: 'Total Penjualan (${jmlTransaksi}x)', width: 8),
      PosColumn(
        text: common.currencyFormat(totalPembayaran),
        width: 4,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);
    if (detail.listSumVoucher != null && detail.listSumVoucher!.isNotEmpty) {
      final totalVoucher = detail.listSumVoucher!
          .fold<double>(0, (jumlah, v) => jumlah + (v.amount ?? 0));
      bytes += generator.row([
        PosColumn(text: 'Voucher (${detail.voucherCount ?? 0}x)', width: 8),
        PosColumn(
          text: common.currencyFormat(totalVoucher),
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }
    if (detail.listSumPotongan != null && detail.listSumPotongan!.isNotEmpty) {
      final totalPotongan = detail.listSumPotongan!
          .fold<double>(0, (jumlah, p) => jumlah + (p.amount ?? 0));
      bytes += generator.row([
        PosColumn(text: 'Potongan (${detail.potonganCount ?? 0}x)', width: 8),
        PosColumn(
          text: common.currencyFormat(totalPotongan),
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }
    if (detail.listSumDeposit != null && detail.listSumDeposit!.isNotEmpty) {
      final totalDeposit = detail.listSumDeposit!
          .fold<double>(0, (jumlah, d) => jumlah + (d.amount ?? 0));
      bytes += generator.row([
        PosColumn(text: 'Deposit (${detail.depositCount ?? 0}x)', width: 8),
        PosColumn(
          text: common.currencyFormat(totalDeposit),
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }
    bytes += generator.hr();

    // Rincian laci tunai: penjualan netto dikurangi tiap metode nontunai,
    // menyisakan bagian tunainya saja, ditambah modal awal — hasilnya adalah
    // kas yang seharusnya ada di laci (sama dengan kasSeharusnya di atas).
    if (detail.pakaiModal) {
      bytes += generator.text(
        'RINCIAN LACI TUNAI',
        styles: const PosStyles(align: PosAlign.left, bold: true),
      );
      bytes += generator.row([
        PosColumn(text: 'Penjualan Netto', width: 8),
        PosColumn(
          text: common.currencyFormat(totalPembayaran),
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
      for (final p in listPembayaran) {
        final isTunai = (p.name ?? '').trim().toLowerCase() == 'tunai';
        if (isTunai) continue;
        bytes += generator.row([
          PosColumn(text: '(-) ${p.name ?? '-'}', width: 8),
          PosColumn(
            text: common.currencyFormat(p.amount ?? 0),
            width: 4,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]);
      }
      bytes += generator.row([
        PosColumn(
            text: 'Penjualan Tunai',
            width: 8,
            styles: const PosStyles(bold: true)),
        PosColumn(
          text: common.currencyFormat(detail.tunaiSum ?? 0),
          width: 4,
          styles: const PosStyles(align: PosAlign.right, bold: true),
        ),
      ]);
      bytes += generator.row([
        PosColumn(text: 'Modal Awal', width: 8),
        PosColumn(
          text: common.currencyFormat(detail.modalAwal ?? 0),
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
      bytes += generator.hr();
      bytes += generator.row([
        PosColumn(
            text: 'TOTAL TUNAI', width: 8, styles: const PosStyles(bold: true)),
        PosColumn(
          text: common.currencyFormat(detail.kasSeharusnya ?? 0),
          width: 4,
          styles: const PosStyles(align: PosAlign.right, bold: true),
        ),
      ]);
      bytes += generator.hr();
    }

    bytes += generator.row([
      PosColumn(text: 'Tiket', width: 8),
      PosColumn(
        text: '${detail.tiketCount ?? 0}',
        width: 4,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'Item', width: 8),
      PosColumn(
        text: '${detail.itemCount ?? 0}',
        width: 4,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.hr();

    bytes += generator.text(
      'Printed : ${dateTimeUtil.now(format: dateFormat.fullTimePrinted)}',
      styles: const PosStyles(align: PosAlign.left),
    );
    bytes += generator.emptyLines(2);
    bytes += generator.row([
      PosColumn(
        text: 'Dibuat Oleh,',
        width: 6,
        styles: const PosStyles(align: PosAlign.center),
      ),
      PosColumn(
        text: 'Mengetahui,',
        width: 6,
        styles: const PosStyles(align: PosAlign.center),
      ),
    ]);
    bytes += generator.emptyLines(3);
    bytes += generator.row([
      PosColumn(
        text: '( .............. )',
        width: 6,
        styles: const PosStyles(align: PosAlign.center),
      ),
      PosColumn(
        text: '( .............. )',
        width: 6,
        styles: const PosStyles(align: PosAlign.center),
      ),
    ]);
    bytes += generator.emptyLines(1);
    if (locationName != null) {
      bytes += generator.text(
        locationName,
        styles: const PosStyles(align: PosAlign.center, bold: true),
      );
    }
    bytes += generator.hr();
    bytes += generator.cut();

    return bytes;
  }

  testPrint({
    required PaperSize paperSize,
  }) async {
    List<int> bytes = [];
    // Using default profile
    final profile = await CapabilityProfile.load();
    final generator = Generator(paperSize, profile);
    bytes += generator.setGlobalFont(PosFontType.fontA);
    bytes += generator.reset();

    bytes += generator.text(
      'Ready',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
      ),
    );

    bytes += generator.text(
      'At ${dateTimeUtil.now()}',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
      ),
    );

    bytes += generator.cut();

    return bytes;
  }

  /// Cetak tiket booking lapangan pada alur REPRINT (menu Cek Order) dengan
  /// format yang SAMA seperti struk penjualan — nama court + rentang jam +
  /// durasi + harga — dan TANPA QR. Booking lapangan tidak perlu QR gate,
  /// konsisten dengan alur penjualan biasa yang mengecualikan lapangan dari
  /// cetak QR.
  Future<List<int>> dataLapanganTicketPrint({
    String? locationName,
    String? locationAddress,
    String? locationPhone,
    required PaperSize paperSize,
    required String orderNo,
    required String reffNo,
    DateTime? paymentDate,
    required List<LapanganPrintLine> lines,
    String? namaPembeli,
  }) async {
    List<int> bytes = [];
    final profile = await CapabilityProfile.load();
    final generator = Generator(paperSize, profile);
    bytes += generator.setGlobalFont(PosFontType.fontA);
    bytes += generator.reset();

    bytes += KepalaStruk.cetak(
      generator,
      nama: locationName,
      alamat: locationAddress,
      telepon: locationPhone,
    );

    bytes += generator.text(
      'No Reff. $reffNo',
      styles: const PosStyles(align: PosAlign.left, bold: true),
    );
    bytes += generator.text(
      'Order ID : $orderNo',
      styles: const PosStyles(align: PosAlign.left, bold: true),
    );
    bytes += generator.text(
      'Nama Pembeli : ${_namaPembeli(namaPembeli)}',
      styles: const PosStyles(align: PosAlign.left, bold: true),
    );
    bytes += generator.text(
      paymentDate != null
          ? dateTimeUtil.getFormattedDate(
              date: paymentDate,
              format: dateFormat.fullTimePrinted,
            )
          : dateTimeUtil.now(format: dateFormat.fullTimePrinted),
      styles: const PosStyles(align: PosAlign.left, bold: true),
    );
    bytes += generator.hr();
    bytes += generator.text(
      'BOOKING LAPANGAN',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.emptyLines(1);

    for (final line in lines) {
      bytes += generator.row(
        [
          PosColumn(
            text: line.courtName,
            width: 12,
            styles: const PosStyles(align: PosAlign.left),
          ),
        ],
      );
      bytes += generator.row(
        [
          PosColumn(
            text:
                '(${dateTimeUtil.getFormattedDate(date: line.startDate, format: dateFormat.hourMinutes)} - ${dateTimeUtil.getFormattedDate(date: line.endDate, format: dateFormat.hourMinutes)}) (${line.hours} Jam)',
            width: 7,
            styles: const PosStyles(align: PosAlign.left),
          ),
          PosColumn(
            text: common.currencyFormat(line.price),
            width: 5,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ],
      );
    }

    bytes += generator.hr();
    // Print Thank You Message (sama seperti struk penjualan biasa)
    bytes += generator.text(
      '>>>PERHATIAN<<<',
      styles: const PosStyles(
        align: PosAlign.left,
        bold: true,
      ),
    );
    bytes += generator.text(
      '1.Jagalah barang-barang anda',
      styles: const PosStyles(
        align: PosAlign.left,
      ),
    );
    bytes += generator.text(
      '2.Harap struk ini disimpan dengan baik',
      styles: const PosStyles(
        align: PosAlign.left,
      ),
    );
    bytes += generator.emptyLines(1);
    bytes += generator.text(
      'TIKET YANG SUDAH DI BELI',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.text(
      'TIDAK DAPAT DITUKAR/DIKEMBALIKAN',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.text(
      'TERIMA KASIH ATAS KUNJUNGAN ANDA',
      styles: const PosStyles(
        align: PosAlign.center,
      ),
    );
    bytes += generator.cut();

    return bytes;
  }
}

/// Satu baris booking lapangan untuk cetak reprint: satu blok jam berurutan
/// pada satu court (nama court, rentang jam, durasi, dan total harga blok).
class LapanganPrintLine {
  final String courtName;
  final DateTime startDate;
  final DateTime endDate;
  final int hours;
  final double price;

  LapanganPrintLine({
    required this.courtName,
    required this.startDate,
    required this.endDate,
    required this.hours,
    required this.price,
  });
}

GeneratePrintUtil generatePrintUtil = GeneratePrintUtil();
