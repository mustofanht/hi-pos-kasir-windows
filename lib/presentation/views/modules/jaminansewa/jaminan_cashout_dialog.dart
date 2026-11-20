import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/presentation/components/custom_button.dart';
import 'package:jaya_propertiy/presentation/components/custom_text_box.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/jaminansewa/jaminan_cashout_dialog_controller.dart';

/// Cash-Out jaminan sewa (pengembalian dana) — dibuka dari tab Item, sub-tab
/// "Jaminan Sewa" (tombol "Pengembalian Jaminan" di samping daftar item).
/// WAJIB TUNAI — tidak ada pilihan metode pembayaran di dialog ini sama
/// sekali (beda dengan Cash-In).
void showJaminanCashOutDialog() {
  Get.put(JaminanCashOutDialogController(), tag: 'jaminanCashOut');

  Get.dialog(
    AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: Container(
        width: layoutStyle.blockHorizontal * 95,
        height: layoutStyle.blockVertical * 75,
        decoration: BoxDecoration(
          color: colorStyle.white,
          borderRadius: BorderRadius.circular(layoutStyle.defaultMargin),
        ),
        child: GetBuilder<JaminanCashOutDialogController>(
          tag: 'jaminanCashOut',
          builder: (c) => LayoutBuilder(builder: (context, box) {
            // Saat papan ketik terbuka (mengisi catatan kondisi barang atau
            // mencari), tinggi dialog tinggal ~300 px: kepala + pencarian +
            // panel catatan saja sudah tidak muat, dan Column tetap meluap
            // walaupun daftarnya mengecil ke 0. Di tinggi sesempit itu
            // seluruh isi dibuat bergulir dan daftarnya diberi tinggi tetap.
            final pendek = box.maxHeight < 480;
            final daftar = _daftarOutstanding(c);
            final isi = <Widget>[
              Padding(
                padding: EdgeInsets.all(layoutStyle.defaultMargin),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Pengembalian Jaminan (Cash Out)',
                        style: TextStyle(
                          fontSize: fontSize.title,
                          fontWeight: fontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: layoutStyle.defaultMargin,
                ),
                child: CustomTextBox(
                  height: layoutStyle.blockVertical * 6.5,
                  obscureText: false,
                  border: Border.all(color: colorStyle.grey, width: 1),
                  borderRadius: BorderRadius.circular(
                    layoutStyle.defaultMargin / 2,
                  ),
                  controller: c.searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari No. Struk / Nama / No HP',
                    hintStyle: textStyle.greyText,
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () => c.doSearch(c.searchController.text),
                    ),
                  ),
                  onSubmit: c.doSearch,
                ),
              ),
              if (pendek)
                SizedBox(height: 160, child: daftar)
              else
                Expanded(child: daftar),
              if (c.selectedJaminan.value != null)
                Container(
                  padding: EdgeInsets.all(layoutStyle.defaultMargin),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: colorStyle.lightGrey),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Jaminan ${c.selectedJaminan.value!.jmnNo}: '
                        '${common.currencyFormat(c.selectedJaminan.value!.amount ?? 0)} '
                        '(wajib tunai)',
                        style: TextStyle(fontWeight: fontWeight.bold),
                      ),
                      SizedBox(height: layoutStyle.defaultMargin / 2),
                      CustomTextBox(
                        height: layoutStyle.blockVertical * 6.5,
                        obscureText: false,
                        border: Border.all(color: colorStyle.grey, width: 1),
                        borderRadius: BorderRadius.circular(
                          layoutStyle.defaultMargin / 2,
                        ),
                        label: Text('Catatan kondisi barang (opsional)',
                            style: textStyle.greyText
                                .copyWith(fontSize: fontSize.small)),
                        controller: c.refundNotesController,
                        decoration: InputDecoration(
                          hintText: 'mis. Kondisi baik',
                          hintStyle: textStyle.greyText,
                          border: InputBorder.none,
                        ),
                      ),
                      SizedBox(height: layoutStyle.defaultMargin / 2),
                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          height: layoutStyle.blockVertical * 6.5,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorStyle.primary,
                          ),
                          onPressed: c.isSubmittingRefund.value
                              ? () {}
                              : c.konfirmasiRefund,
                          label: c.isSubmittingRefund.value
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text('Kembalikan Dana (Tunai)',
                                  style: TextStyle(color: colorStyle.white)),
                        ),
                      ),
                    ],
                  ),
                ),
            ];
            if (!pendek) return Column(children: isi);
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(mainAxisSize: MainAxisSize.min, children: isi),
            );
          }),
        ),
      ),
    ),
  ).whenComplete(() {
    Get.delete<JaminanCashOutDialogController>(tag: 'jaminanCashOut');
  });
}

Widget _daftarOutstanding(JaminanCashOutDialogController c) {
  return c.isLoadingOutstanding.value
      ? const Center(child: CircularProgressIndicator())
      : c.outstandingList.isEmpty
          ? const Center(
              child: Text('Tidak ada jaminan yang belum dikembalikan.'),
            )
          : ListView.builder(
              padding: EdgeInsets.symmetric(
                horizontal: layoutStyle.defaultMargin / 2,
              ),
              itemCount: c.outstandingList.length,
              itemBuilder: (context, index) {
                final item = c.outstandingList[index];
                final selected = c.selectedJaminan.value?.jmnNo == item.jmnNo;
                return Card(
                  color: selected ? colorStyle.primary.withOpacity(0.08) : null,
                  margin: EdgeInsets.symmetric(
                    horizontal: layoutStyle.defaultMargin / 2,
                    vertical: layoutStyle.defaultMargin / 4,
                  ),
                  child: ListTile(
                    onTap: () => c.pilihJaminan(item),
                    title: Text('${item.jmnNo} — ${item.itemName ?? ''}'),
                    subtitle: Text(
                      '${common.currencyFormat(item.amount ?? 0)}  •  '
                      '${item.customerName ?? '-'}  •  ${item.customerPhone ?? '-'}',
                    ),
                    trailing: Text(item.statusLabel ?? ''),
                  ),
                );
              },
            );
}
