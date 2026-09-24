import 'package:jaya_propertiy/domain/entities/shift/shift_detail_payment_entity.dart';
import 'package:jaya_propertiy/domain/entities/shift/shift_kas_pecahan_entity.dart';
import 'package:jaya_propertiy/domain/entities/shift/shift_detail_sum_potongan_entity.dart';
import 'package:jaya_propertiy/domain/entities/shift/shift_detail_sum_voucher_entity.dart';

class ShiftDetailEntity {
  final String? shftDate;
  final String? shftUserid;
  final DateTime? shftStart;
  final DateTime? shftEnd;
  final String? userFullName;
  final String? lokasiName;
  final int? tiketCount;
  final int? itemCount;
  final int? potonganCount;
  final int? voucherCount;
  final String? qrisSum;
  final String? edcSum;
  final String? travelokaSum;
  final String? ticketdotcomSum;
  final List<ShiftDetailPaymentEntity>? listSumPayment;
  final List<ShiftDetailSumVoucherEntity>? listSumVoucher;
  final List<ShiftDetailSumPotonganEntity>? listSumPotongan;

  // --- Kas shift ------------------------------------------------------------
  // Hanya terisi untuk lokasi yang memakai modal kas. Lokasi lain menerima
  // rekap yang sama persis seperti sebelumnya, dengan pakaiModalKas 'N'.

  /// 'Y' bila lokasi kasir ini memakai modal kas.
  final String? pakaiModalKas;

  /// Modal yang diterima kasir di awal shift; null = belum diisi.
  final double? modalAwal;

  /// Penjualan yang dibayar tunai selama shift.
  final double? tunaiSum;

  /// Modal awal + penjualan tunai: uang yang seharusnya ada di laci.
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
    this.userFullName,
    this.lokasiName,
    this.tiketCount,
    this.itemCount,
    this.potonganCount,
    this.voucherCount,
    this.qrisSum,
    this.edcSum,
    this.travelokaSum,
    this.ticketdotcomSum,
    this.listSumPayment,
    this.listSumVoucher,
    this.listSumPotongan,
    this.pakaiModalKas,
    this.modalAwal,
    this.tunaiSum,
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
      userFullName: json['userFullName'],
      lokasiName: json['lokasiName'],
      tiketCount: json['tiketCount'],
      itemCount: json['itemCount'],
      potonganCount: json['potonganCount'],
      voucherCount: json['voucherCount'],
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
      pakaiModalKas: json['pakaiModalKas'],
      modalAwal: _angka(json['modalAwal']),
      tunaiSum: _angka(json['tunaiSum']),
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
      'qrisSum': qrisSum,
      'edcSum': edcSum,
      'travelokaSum': travelokaSum,
      'ticketdotcomSum': ticketdotcomSum,
      'listSumPayment': listSumPayment?.map((e) => e.toJson()).toList(),
      'listSumVoucher': listSumVoucher?.map((e) => e.toJson()).toList(),
      'listSumPotongan': listSumPotongan?.map((e) => e.toJson()).toList(),
      'pakaiModalKas': pakaiModalKas,
      'modalAwal': modalAwal,
      'tunaiSum': tunaiSum,
      'kasSeharusnya': kasSeharusnya,
      'kasAkhir': kasAkhir,
      'selisihKas': selisihKas,
      'listPecahanModal': listPecahanModal?.map((e) => e.toJson()).toList(),
      'listPecahanAkhir': listPecahanAkhir?.map((e) => e.toJson()).toList(),
    };
  }
}
