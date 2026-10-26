import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';

/// Kotak pencarian untuk daftar Tiket & Item di layar penjualan.
///
/// Pencariannya dikerjakan **server** (parameter `search`), bukan disaring dari
/// daftar yang kebetulan sudah termuat: daftarnya dimuat per halaman sambil
/// digulir, jadi penyaringan di layar hanya akan menemukan tiket yang sudah
/// terlanjur tampak — dan kasir menyimpulkan tiketnya tidak ada.
class KotakCari extends StatelessWidget {
  const KotakCari({
    super.key,
    required this.controller,
    required this.petunjuk,
    required this.onUbah,
    required this.onBersihkan,
    required this.adaIsi,
  });

  final TextEditingController controller;
  final String petunjuk;
  final ValueChanged<String> onUbah;
  final VoidCallback onBersihkan;

  /// Penanda kotaknya sedang terisi; hanya menentukan tombol silang muncul.
  final RxBool adaIsi;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        layoutStyle.defaultMargin,
        layoutStyle.defaultMargin,
        layoutStyle.defaultMargin,
        0,
      ),
      child: Obx(
        () => TextField(
          controller: controller,
          onChanged: onUbah,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            isDense: true,
            hintText: petunjuk,
            hintStyle: textStyle.greyText,
            prefixIcon: Icon(Icons.search, color: colorStyle.grey),
            suffixIcon: adaIsi.value
                ? IconButton(
                    icon: Icon(Icons.close, color: colorStyle.grey),
                    // Tombol silang bukan hiasan: tanpa itu kasir harus
                    // menghapus hurufnya satu per satu di tengah antrean.
                    onPressed: onBersihkan,
                  )
                : null,
            contentPadding: EdgeInsets.symmetric(
              horizontal: layoutStyle.defaultMargin,
              vertical: layoutStyle.defaultMargin,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(layoutStyle.defaultMargin),
              borderSide: BorderSide(color: colorStyle.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(layoutStyle.defaultMargin),
              borderSide: BorderSide(color: colorStyle.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(layoutStyle.defaultMargin),
              borderSide: BorderSide(color: colorStyle.primary),
            ),
          ),
        ),
      ),
    );
  }
}
