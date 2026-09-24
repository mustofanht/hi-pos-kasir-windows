import 'package:flutter/material.dart';
import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/domain/entities/shift/shift_detail_entity.dart';

/// Satu baris rekap shift: keterangan di kiri, angka di kanan.
///
/// Dulu fungsi lokal di dalam `build` halaman Shift. Dikeluarkan supaya blok kas
/// di bawah — dan pratinjau untuk panduan kasir — memakai baris yang sama persis
/// dengan layar aslinya, bukan tiruannya.
Widget barisShift({
  required String key,
  String? value,
  required bool head,
  Color? colorValue,
  EdgeInsetsGeometry? paddingKey,
}) {
  return Container(
    padding: EdgeInsets.all(layoutStyle.defaultMargin / 2),
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(
          color: colorStyle.black,
          width: 1.0,
        ),
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: paddingKey ?? EdgeInsets.zero,
          child: Text(
            key,
            style: TextStyle(
              color: colorStyle.black,
              fontSize: fontSize.body,
              fontWeight: head ? fontWeight.bold : fontWeight.regular,
            ),
          ),
        ),
        Text(
          value ?? '',
          style: TextStyle(
            color: colorValue ?? colorStyle.black,
            fontSize: fontSize.body,
            fontWeight: fontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

/// Blok kas pada Rincian Shift: modal awal, penjualan tunai, kas seharusnya,
/// kas yang dihitung, dan selisihnya.
///
/// Kosong untuk lokasi yang tidak memakai modal kas — di sana kas seharusnya
/// dan selisih tidak punya arti.
List<Widget> blokKasShift(ShiftDetailEntity detail) {
  if (!detail.pakaiModal) return const [];

  return [
    barisShift(
      key: 'Kas',
      head: true,
    ),
    barisShift(
      key: 'Modal Awal',
      value: detail.modalAwal == null
          ? 'Belum diisi'
          : 'Rp.${common.currencyFormat(detail.modalAwal!)}',
      colorValue: detail.modalAwal == null ? colorStyle.red : null,
      head: false,
    ),
    if (detail.listPecahanModal != null)
      ...detail.listPecahanModal!.map(
        (e) => barisShift(
          key: '${common.currencyFormat(e.pecahan.toDouble())} x ${e.lembar}',
          value: 'Rp.${common.currencyFormat(e.jumlah)}',
          head: false,
          paddingKey: EdgeInsets.only(left: layoutStyle.defaultMargin),
        ),
      ),
    barisShift(
      key: 'Penjualan Tunai',
      value: 'Rp.${common.currencyFormat(detail.tunaiSum ?? 0)}',
      head: false,
    ),
    barisShift(
      key: 'Kas Seharusnya',
      value: 'Rp.${common.currencyFormat(detail.kasSeharusnya ?? 0)}',
      head: false,
    ),
    barisShift(
      key: 'Kas Dihitung',
      // Selama shift berjalan, kosongnya angka ini bukan kelalaian: uang di
      // laci masih berubah tiap transaksi dan baru dihitung saat tutup shift.
      // Kalimatnya dibedakan supaya kasir tidak mengira ada yang terlewat.
      value: detail.kasAkhir != null
          ? 'Rp.${common.currencyFormat(detail.kasAkhir!)}'
          : detail.shftEnd == null
              ? 'Dihitung saat tutup shift'
              : 'Belum dihitung',
      colorValue: detail.kasAkhir == null ? colorStyle.grey : null,
      head: false,
    ),
    if (detail.listPecahanAkhir != null)
      ...detail.listPecahanAkhir!.map(
        (e) => barisShift(
          key: '${common.currencyFormat(e.pecahan.toDouble())} x ${e.lembar}',
          value: 'Rp.${common.currencyFormat(e.jumlah)}',
          head: false,
          paddingKey: EdgeInsets.only(left: layoutStyle.defaultMargin),
        ),
      ),
    if (detail.selisihKas == null && detail.shftEnd == null)
      barisShift(
        key: 'Selisih',
        value: 'Setelah laci dihitung',
        colorValue: colorStyle.grey,
        head: false,
      ),
    if (detail.selisihKas != null)
      barisShift(
        key: detail.selisihKas! < 0
            ? 'Selisih (kurang)'
            : detail.selisihKas! > 0
                ? 'Selisih (lebih)'
                : 'Selisih',
        value: 'Rp.${common.currencyFormat(detail.selisihKas!.abs())}',
        colorValue: detail.selisihKas == 0 ? colorStyle.green : colorStyle.red,
        head: false,
      ),
  ];
}
