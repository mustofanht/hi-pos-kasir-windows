import 'package:jaya_propertiy/domain/entities/shift/shift_detail_payment_entity.dart';
import 'package:jaya_propertiy/domain/entities/shift/shift_kas_pecahan_entity.dart';
import 'package:jaya_propertiy/domain/entities/shift/shift_detail_sum_potongan_entity.dart';
import 'package:jaya_propertiy/domain/entities/shift/shift_detail_sum_voucher_entity.dart';

class ShiftDetailEntity {
  final String? shftDate;
  final String? shftUserid;
  final DateTime? shftStart;
  final DateTime? shftEnd;

  /// shftStart/shftEnd sudah diformat backend ke zona waktu lokasi kasir ini
  /// (mst_location.loc_timezone), "dd-MM-yyyy HH:mm:ss". Struk cetak WAJIB
  /// memakai ini (lewat dateTimeUtil.parseLocalFormatted) — bukan shftStart/
  /// shftEnd mentah, yang ikut ter-toLocal() ke zona DEVICE kasir, bisa salah
  /// kalau device-nya diset ke WIB meski lokasinya WITA/WIT.
  final String? shftStartLocal;
  final String? shftEndLocal;
  final String? userFullName;
  final String? lokasiName;
  final int? tiketCount;
  final int? itemCount;
  final int? potonganCount;
  final int? voucherCount;
  final int? depositCount;
  final String? qrisSum;
  final String? edcSum;
  final String? travelokaSum;
  final String? ticketdotcomSum;
  final List<ShiftDetailPaymentEntity>? listSumPayment;
  final List<ShiftDetailSumVoucherEntity>? listSumVoucher;
  final List<ShiftDetailSumPotonganEntity>? listSumPotongan;

  /// Total deposit yang dipakai sebagai (sebagian) pembayaran selama shift,
  /// per metode deposit — sama bentuknya dengan listSumVoucher/listSumPotongan.
  final List<ShiftDetailSumVoucherEntity>? listSumDeposit;

  /// Runtutan order split payment (Campuran) per metode. Nilainya SUDAH
  /// termasuk di [listSumPayment]; hanya untuk pencocokan oleh kasir.
  final List<ShiftDetailPaymentEntity>? listSumSplitPayment;

  /// Jumlah & total order split payment selama shift.
  final int? splitCount;
  final double? splitTotal;

  // --- Kas shift ------------------------------------------------------------
  // Hanya terisi untuk lokasi yang memakai modal kas. Lokasi lain menerima
  // rekap yang sama persis seperti sebelumnya, dengan pakaiModalKas 'N'.

  /// 'Y' bila lokasi kasir ini memakai modal kas.
  final String? pakaiModalKas;

  /// Modal yang diterima kasir di awal shift; null = belum diisi.
  final double? modalAwal;

  /// Penjualan yang dibayar tunai selama shift.
  final double? tunaiSum;

  /// Jaminan sewa tunai diterima dikurangi dikembalikan selama shift ini --
  /// uang fisik di laci yang sama dengan penjualan tunai, tapi BUKAN
  /// penjualan. Bisa negatif. Null/0 bila tidak ada transaksi jaminan sewa.
  final double? jaminanSewaTunaiSum;

  /// Modal awal + penjualan tunai + jaminan sewa tunai: uang yang seharusnya
  /// ada di laci.
  final double? kasSeharusnya;

  /// Uang yang benar-benar dihitung kasir; null = belum dihitung.
  final double? kasAkhir;

  /// Kas dihitung - kas seharusnya. Negatif berarti kurang.
  final double? selisihKas;

  final List<ShiftKasPecahanEntity>? listPecahanModal;

  final List<ShiftKasPecahanEntity>? listPecahanAkhir;

  bool get pakaiModal => (pakaiModalKas ?? 'N').toUpperCase() == 'Y';

  bool get modalSudahDiisi => modalAwal != null;

  ShiftDetailEntity({
    this.shftDate,
    this.shftUserid,
    this.shftStart,
    this.shftEnd,
    this.shftStartLocal,
    this.shftEndLocal,
    this.userFullName,
    this.lokasiName,
    this.tiketCount,
    this.itemCount,
    this.potonganCount,
    this.voucherCount,
    this.depositCount,
    this.qrisSum,
    this.edcSum,
    this.travelokaSum,
    this.ticketdotcomSum,
    this.listSumPayment,
    this.listSumVoucher,
    this.listSumPotongan,
    this.listSumDeposit,
    this.listSumSplitPayment,
    this.splitCount,
    this.splitTotal,
    this.pakaiModalKas,
    this.modalAwal,
    this.tunaiSum,
    this.jaminanSewaTunaiSum,
    this.kasSeharusnya,
    this.kasAkhir,
    this.selisihKas,
    this.listPecahanModal,
    this.listPecahanAkhir,
  });

  static double? _angka(dynamic nilai) {
    if (nilai == null) return null;
    if (nilai is num) return nilai.toDouble();
    return double.tryParse(nilai.toString());
  }

  static List<ShiftKasPecahanEntity>? _pecahan(dynamic nilai) {
    if (nilai is! List) return null;
    return nilai
        .map((e) => ShiftKasPecahanEntity.fromJson(
            Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  factory ShiftDetailEntity.fromJson(Map<String, dynamic> json) {
    return ShiftDetailEntity(
      shftDate: json['shftDate'],
      shftUserid: json['shftUserid'],
      shftStart: json['shftStart'] != null
          ? DateTime.parse(json['shftStart']).toLocal()
          : null,
      shftEnd: json['shftEnd'] != null
          ? DateTime.parse(json['shftEnd']).toLocal()
          : null,
      shftStartLocal: json['shftStartLocal'],
      shftEndLocal: json['shftEndLocal'],
      userFullName: json['userFullName'],
      lokasiName: json['lokasiName'],
      tiketCount: json['tiketCount'],
      itemCount: json['itemCount'],
      potonganCount: json['potonganCount'],
      voucherCount: json['voucherCount'],
      depositCount: json['depositCount'],
      qrisSum: json['qrisSum'],
      edcSum: json['edcSum'],
      travelokaSum: json['travelokaSum'],
      ticketdotcomSum: json['ticketdotcomSum'],
      listSumPayment: json['listSumPayment'] != null
          ? (json['listSumPayment'] as List)
              .map((i) => ShiftDetailPaymentEntity.fromJson(i))
              .toList()
          : null,
      listSumVoucher: json['listSumVoucher'] != null
          ? (json['listSumVoucher'] as List)
              .map((i) => ShiftDetailSumVoucherEntity.fromJson(i))
              .toList()
          : null,
      listSumPotongan: json['listSumPotongan'] != null
          ? (json['listSumPotongan'] as List)
              .map((i) => ShiftDetailSumPotonganEntity.fromJson(i))
              .toList()
          : null,
      listSumDeposit: json['listSumDeposit'] != null
          ? (json['listSumDeposit'] as List)
              .map((i) => ShiftDetailSumVoucherEntity.fromJson(i))
              .toList()
          : null,
      listSumSplitPayment: json['listSumSplitPayment'] is List
          ? (json['listSumSplitPayment'] as List)
              .map((i) => ShiftDetailPaymentEntity.fromJson(
                  Map<String, dynamic>.from(i as Map)))
              .toList()
          : null,
      splitCount: json['splitCount'],
      splitTotal: _angka(json['splitTotal']),
      pakaiModalKas: json['pakaiModalKas'],
      modalAwal: _angka(json['modalAwal']),
      tunaiSum: _angka(json['tunaiSum']),
      jaminanSewaTunaiSum: _angka(json['jaminanSewaTunaiSum']),
      kasSeharusnya: _angka(json['kasSeharusnya']),
      kasAkhir: _angka(json['kasAkhir']),
      selisihKas: _angka(json['selisihKas']),
      listPecahanModal: _pecahan(json['listPecahanModal']),
      listPecahanAkhir: _pecahan(json['listPecahanAkhir']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shftDate': shftDate,
      'shftUserid': shftUserid,
      'shftStart': shftStart?.toIso8601String(),
      'shftEnd': shftEnd?.toIso8601String(),
      'userFullName': userFullName,
      'lokasiName': lokasiName,
      'tiketCount': tiketCount,
      'itemCount': itemCount,
      'potonganCount': potonganCount,
      'voucherCount': voucherCount,
      'depositCount': depositCount,
      'qrisSum': qrisSum,
      'edcSum': edcSum,
      'travelokaSum': travelokaSum,
      'ticketdotcomSum': ticketdotcomSum,
      'listSumPayment': listSumPayment?.map((e) => e.toJson()).toList(),
      'listSumVoucher': listSumVoucher?.map((e) => e.toJson()).toList(),
      'listSumPotongan': listSumPotongan?.map((e) => e.toJson()).toList(),
      'listSumDeposit': listSumDeposit?.map((e) => e.toJson()).toList(),
      'listSumSplitPayment':
          listSumSplitPayment?.map((e) => e.toJson()).toList(),
      'splitCount': splitCount,
      'splitTotal': splitTotal,
      'pakaiModalKas': pakaiModalKas,
      'modalAwal': modalAwal,
      'tunaiSum': tunaiSum,
      'jaminanSewaTunaiSum': jaminanSewaTunaiSum,
      'kasSeharusnya': kasSeharusnya,
      'kasAkhir': kasAkhir,
      'selisihKas': selisihKas,
      'listPecahanModal': listPecahanModal?.map((e) => e.toJson()).toList(),
      'listPecahanAkhir': listPecahanAkhir?.map((e) => e.toJson()).toList(),
    };
  }
}
