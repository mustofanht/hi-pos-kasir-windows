import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/app/utils/common/kas_util.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';

/// Layar hitung uang per pecahan.
///
/// Dipakai dua kali dengan aturan yang sama: mengisi modal saat buka kasir, dan
/// menghitung isi laci saat tutup shift. Yang membedakan hanya judul dan boleh
/// tidaknya dibatalkan — modal awal menahan penjualan sampai diisi, sedangkan
/// hitungan laci boleh ditunda.
///
/// Mengembalikan hitungan lembar per pecahan, atau null bila kasir membatalkan.
Future<Map<int, int>?> tampilkanHitungKas({
  required String judul,
  required String keterangan,
  String labelSimpan = 'Simpan',
  Map<int, int>? awal,
  bool bolehBatal = true,
}) {
  return Get.dialog<Map<int, int>>(
    Dialog(
      insetPadding: EdgeInsets.all(layoutStyle.defaultMargin),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(layoutStyle.defaultMargin / 2),
      ),
      child: _HitungKasIsi(
        judul: judul,
        keterangan: keterangan,
        labelSimpan: labelSimpan,
        awal: awal,
        bolehBatal: bolehBatal,
      ),
    ),
    // Ditutup lewat tombol saja: kasir sering menyenggol layar sambil
    // memegang uang, dan hitungan yang hilang di tengah jalan berarti
    // menghitung ulang seluruh laci.
    barrierDismissible: false,
  );
}

class _HitungKasIsi extends StatefulWidget {
  const _HitungKasIsi({
    required this.judul,
    required this.keterangan,
    required this.labelSimpan,
    required this.bolehBatal,
    this.awal,
  });

  final String judul;
  final String keterangan;
  final String labelSimpan;
  final bool bolehBatal;
  final Map<int, int>? awal;

  @override
  State<_HitungKasIsi> createState() => _HitungKasIsiState();
}

class _HitungKasIsiState extends State<_HitungKasIsi> {
  final Map<int, TextEditingController> _isian = {};
  final Map<int, int> _lembar = {};

  @override
  void initState() {
    super.initState();
    for (final pecahan in KasUtil.pecahan) {
      final lembar = widget.awal?[pecahan] ?? 0;
      _lembar[pecahan] = lembar;
      _isian[pecahan] =
          TextEditingController(text: lembar > 0 ? lembar.toString() : '');
    }
  }

  @override
  void dispose() {
    for (final c in _isian.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _ubah(int pecahan, String teks) {
    setState(() => _lembar[pecahan] = KasUtil.bacaLembar(teks));
  }

  @override
  Widget build(BuildContext context) {
    final total = KasUtil.total(_lembar);

    return Container(
      width: layoutStyle.blockHorizontal * 55,
      padding: EdgeInsets.all(layoutStyle.defaultMargin),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.judul,
            style: textStyle.blackText.copyWith(
              fontSize: fontSize.header,
              fontWeight: fontWeight.bold,
            ),
          ),
          SizedBox(height: layoutStyle.defaultMargin / 4),
          Text(
            widget.keterangan,
            style: textStyle.greyText.copyWith(fontSize: fontSize.small),
          ),
          SizedBox(height: layoutStyle.defaultMargin / 2),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (final pecahan in KasUtil.pecahan)
                    _baris(pecahan),
                ],
              ),
            ),
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: textStyle.blackText.copyWith(
                  fontSize: fontSize.subtitle,
                  fontWeight: fontWeight.bold,
                ),
              ),
              Text(
                'Rp ${common.currencyFormat(total.toDouble())}',
                style: textStyle.blackText.copyWith(
                  fontSize: fontSize.subtitle,
                  fontWeight: fontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: layoutStyle.defaultMargin / 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (widget.bolehBatal)
                TextButton(
                  onPressed: () => Get.back<Map<int, int>>(result: null),
                  child: const Text('Batal'),
                ),
              SizedBox(width: layoutStyle.defaultMargin / 2),
              ElevatedButton(
                onPressed: () =>
                    Get.back<Map<int, int>>(result: Map<int, int>.from(_lembar)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorStyle.primary,
                  foregroundColor: colorStyle.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: layoutStyle.defaultMargin,
                    vertical: layoutStyle.defaultMargin / 2,
                  ),
                ),
                child: Text(widget.labelSimpan),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _baris(int pecahan) {
    final lembar = _lembar[pecahan] ?? 0;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: layoutStyle.defaultMargin / 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'Rp ${common.currencyFormat(pecahan.toDouble())}',
              style: textStyle.blackText,
            ),
          ),
          Expanded(
            flex: 2,
            child: TextField(
              controller: _isian[pecahan],
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
                hintText: '0',
                suffixText: 'lembar',
              ),
              onChanged: (teks) => _ubah(pecahan, teks),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.only(left: layoutStyle.defaultMargin / 2),
              child: Text(
                lembar > 0
                    ? 'Rp ${common.currencyFormat((pecahan * lembar).toDouble())}'
                    : '-',
                textAlign: TextAlign.right,
                style: textStyle.greyText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
