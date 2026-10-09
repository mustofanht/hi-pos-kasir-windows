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

  Future<List<int>> dataPaymentTiketPrint({
    String? locationName,
    String? locationAddress,
    String? locationPhone,
    String? kasirName,
    required PaperSize paperSize,
    required OrderModel body,
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
    bytes += generator.row(
      [
        PosColumn(
          text: body.paymentDate != null
              ? dateTimeUtil.getFormattedDate(
                  date: body.paymentDate!,
                  format: dateFormat.fullTimePrinted,
                )
              : dateTimeUtil.now(
                  format: dateFormat.fullTimePrinted,
                ),
          width: 6,
        ),
        PosColumn(
          text: body.orderName ?? '',
          width: 6,
          styles: const PosStyles(
            align: PosAlign.right,
          ),
        ),
      ],
    );
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

    // Location Name
    if (locationName != null) {
      bytes += generator.text(
        locationName,
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          width: PosTextSize.size2,
          height: PosTextSize.size2,
        ),
      );
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

    // Tambahkan text "TIKET PENDAMPING (GRATIS)" jika ini QR pendamping
    if (isCompanion == 'Y') {
      bytes += generator.text(
        'TIKET PENDAMPING (GRATIS)',
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          width: PosTextSize.size2,
          height: PosTextSize.size2,
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
  /// pembayaran per metode, rekonsiliasi kas per metode (Aktual/Komputer/
  /// Selisih), rincian penjualan, lalu rincian laci tunai sampai total tunai.
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

    // Rekonsiliasi per metode pembayaran: Aktual / Komputer / Selisih.
    // Tunai BENAR-BENAR direkonsiliasi (kasAkhir = uang yang dihitung kasir,
    // kasSeharusnya = modal + penjualan tunai menurut sistem, selisihnya bisa
    // tidak nol). Metode lain (EDC/QRIS/dst) tidak pernah dihitung ulang
    // manual di aplikasi ini — settlement-nya otomatis lewat sistem
    // pembayaran itu sendiri — jadi Aktual = Komputer = nilainya di
    // listSumPayment, Selisih selalu nol. Ini BUKAN disamakan asal-asalan:
    // memang tidak ada proses hitung-ulang manual untuk metode nontunai.
    if (detail.pakaiModal && listPembayaran.isNotEmpty) {
      bytes += generator.text(
        'REKONSILIASI (AKTUAL VS KOMPUTER)',
        styles: const PosStyles(align: PosAlign.left, bold: true),
      );
      bytes += generator.row([
        PosColumn(text: '', width: 4),
        PosColumn(
          text: 'Aktual',
          width: 4,
          styles: const PosStyles(align: PosAlign.right, bold: true),
        ),
        PosColumn(
          text: 'Komputer',
          width: 4,
          styles: const PosStyles(align: PosAlign.right, bold: true),
        ),
      ]);
      double totalAktual = 0;
      double totalKomputer = 0;
      for (final p in listPembayaran) {
        final isTunai = (p.name ?? '').trim().toLowerCase() == 'tunai';
        final aktual = isTunai ? (detail.kasAkhir ?? 0) : (p.amount ?? 0);
        final komputer =
            isTunai ? (detail.kasSeharusnya ?? 0) : (p.amount ?? 0);
        totalAktual += aktual;
        totalKomputer += komputer;
        bytes += generator.text(p.name ?? '-');
        bytes += generator.row([
          PosColumn(text: '', width: 4),
          PosColumn(
            text: common.currencyFormat(aktual),
            width: 4,
            styles: const PosStyles(align: PosAlign.right),
          ),
          PosColumn(
            text: common.currencyFormat(komputer),
            width: 4,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]);
      }
      bytes += generator.hr();
      final selisihTotal = totalAktual - totalKomputer;
      bytes += generator.text('Total', styles: const PosStyles(bold: true));
      bytes += generator.row([
        PosColumn(text: '', width: 4),
        PosColumn(
          text: common.currencyFormat(totalAktual),
          width: 4,
          styles: const PosStyles(align: PosAlign.right, bold: true),
        ),
        PosColumn(
          text: common.currencyFormat(totalKomputer),
          width: 4,
          styles: const PosStyles(align: PosAlign.right, bold: true),
        ),
      ]);
      bytes += generator.row([
        PosColumn(
          text: selisihTotal < 0
              ? 'Selisih (Kurang)'
              : selisihTotal > 0
                  ? 'Selisih (Lebih)'
                  : 'Selisih',
          width: 8,
          styles: const PosStyles(bold: true),
        ),
        PosColumn(
          text: common.currencyFormat(selisihTotal.abs()),
          width: 4,
          styles: const PosStyles(align: PosAlign.right, bold: true),
        ),
      ]);
      bytes += generator.hr();
    }

    // Rincian penjualan: total netto (= total pembayaran di atas, karena
    // voucher/potongan sudah dipotong sebelum tersimpan sebagai pembayaran),
    // lalu voucher & potongan sebagai informasi jumlah yang terpakai.
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
