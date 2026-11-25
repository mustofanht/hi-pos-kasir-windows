import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/ribuan_input_formatter.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/domain/entities/masterdata/mst_payment.dart';
import 'package:jaya_propertiy/domain/entities/sale/addon_entity.dart';
import 'package:jaya_propertiy/presentation/components/custom_button.dart';
import 'package:jaya_propertiy/presentation/components/custom_text_box.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/jaminansewa/jaminan_cashin_dialog_controller.dart';

/// Cash-In jaminan sewa — dibuka dari tab Item, sub-tab "Jaminan Sewa" (di
/// samping "Jual"). Pengganti Tab 1 "Terima Jaminan" di layar standalone lama,
/// kini mendukung Tunai/QRIS/EDC (V162).
void showJaminanCashInDialog({
  required AddonEntity item,
  required VoidCallback onSelesai,
}) {
  Get.put(
    JaminanCashInDialogController(item: item, onSelesai: onSelesai),
    tag: item.productId?.toString(),
  );

  Get.dialog(
    barrierDismissible: false,
    AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: Container(
        width: layoutStyle.blockHorizontal * 95,
        decoration: BoxDecoration(
          color: colorStyle.white,
          borderRadius: BorderRadius.circular(layoutStyle.defaultMargin),
        ),
        child: GetBuilder<JaminanCashInDialogController>(
          tag: item.productId?.toString(),
          builder: (c) => SingleChildScrollView(
            padding: EdgeInsets.all(layoutStyle.defaultMargin),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Jaminan Sewa',
                  style: TextStyle(
                    fontSize: fontSize.title,
                    fontWeight: fontWeight.bold,
                  ),
                ),
                Text(
                  item.productName ?? '-',
                  style: textStyle.greyText,
                ),
                SizedBox(height: layoutStyle.defaultMargin / 2),
                // Dua kolom berdampingan (bukan satu kolom penuh ke bawah) supaya
                // seluruh form + tombol muat tanpa perlu geser untuk klik "Terima".
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: CustomTextBox(
                        height: layoutStyle.blockVertical * 6.5,
                        margin: EdgeInsets.symmetric(
                          vertical: layoutStyle.defaultMargin / 4,
                        ),
                        obscureText: false,
                        border: Border.all(color: colorStyle.grey, width: 1),
                        borderRadius: BorderRadius.circular(
                          layoutStyle.defaultMargin / 2,
                        ),
                        label: Text('Nominal Jaminan',
                            style: textStyle.greyText
                                .copyWith(fontSize: fontSize.small)),
                        controller: c.amountController,
                        decoration: InputDecoration(
                          hintText: 'mis. 20.000',
                          hintStyle: textStyle.greyText,
                          border: InputBorder.none,
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [RibuanInputFormatter()],
                        onChanged: (_) => c.update(),
                        isMandatory: true,
                      ),
                    ),
                    SizedBox(width: layoutStyle.defaultMargin / 2),
                    Expanded(
                      child: CustomTextBox(
                        height: layoutStyle.blockVertical * 6.5,
                        margin: EdgeInsets.symmetric(
                          vertical: layoutStyle.defaultMargin / 4,
                        ),
                        obscureText: false,
                        border: Border.all(color: colorStyle.grey, width: 1),
                        borderRadius: BorderRadius.circular(
                          layoutStyle.defaultMargin / 2,
                        ),
                        label: Text('Nama Pelanggan',
                            style: textStyle.greyText
                                .copyWith(fontSize: fontSize.small)),
                        controller: c.customerNameController,
                        decoration: InputDecoration(
                          hintText: 'mis. Budi',
                          hintStyle: textStyle.greyText,
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
                // Nominal yang paling sering dipakai: sekali ketuk mengisi kolom
                // Nominal Jaminan, tetap bisa diketik manual untuk nominal lain.
                Wrap(
                  spacing: layoutStyle.defaultMargin / 4,
                  runSpacing: layoutStyle.defaultMargin / 4,
                  children: [
                    for (final n in JaminanCashInDialogController.pilihanNominal)
                      ChoiceChip(
                        key: Key('nominal-jaminan-$n'),
                        label: Text('${n ~/ 1000}rb'),
                        selected: c.nominalTerpilih == n,
                        selectedColor: colorStyle.primary,
                        labelStyle: TextStyle(
                          color: c.nominalTerpilih == n
                              ? colorStyle.white
                              : colorStyle.black,
                        ),
                        showCheckmark: false,
                        onSelected: (_) => c.pilihNominal(n),
                      ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: CustomTextBox(
                        height: layoutStyle.blockVertical * 6.5,
                        margin: EdgeInsets.symmetric(
                          vertical: layoutStyle.defaultMargin / 4,
                        ),
                        obscureText: false,
                        border: Border.all(color: colorStyle.grey, width: 1),
                        borderRadius: BorderRadius.circular(
                          layoutStyle.defaultMargin / 2,
                        ),
                        label: Text('No. HP',
                            style: textStyle.greyText
                                .copyWith(fontSize: fontSize.small)),
                        controller: c.customerPhoneController,
                        decoration: InputDecoration(
                          hintText: 'mis. 081234567890',
                          hintStyle: textStyle.greyText,
                          border: InputBorder.none,
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                    SizedBox(width: layoutStyle.defaultMargin / 2),
                    Expanded(
                      child: CustomTextBox(
                        height: layoutStyle.blockVertical * 6.5,
                        margin: EdgeInsets.symmetric(
                          vertical: layoutStyle.defaultMargin / 4,
                        ),
                        obscureText: false,
                        border: Border.all(color: colorStyle.grey, width: 1),
                        borderRadius: BorderRadius.circular(
                          layoutStyle.defaultMargin / 2,
                        ),
                        label: Text('Catatan (opsional)',
                            style: textStyle.greyText
                                .copyWith(fontSize: fontSize.small)),
                        controller: c.notesController,
                        decoration: InputDecoration(
                          hintText: 'mis. KTP ditahan',
                          hintStyle: textStyle.greyText,
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: layoutStyle.defaultMargin / 4),
                Text('Metode Pembayaran',
                    style:
                        textStyle.greyText.copyWith(fontSize: fontSize.small)),
                SizedBox(height: layoutStyle.defaultMargin / 4),
                c.isLoadingPayment.value
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: layoutStyle.defaultMargin / 2,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: colorStyle.grey, width: 1),
                          borderRadius: BorderRadius.circular(
                            layoutStyle.defaultMargin / 2,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButtonFormField<MstPayment>(
                            value: c.selectedPayment.value,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                            ),
                            items: c.paymentList
                                .map((p) => DropdownMenuItem<MstPayment>(
                                      value: p,
                                      child: Text(p.pymntName ?? p.pymntCode ?? '-'),
                                    ))
                                .toList(),
                            onChanged: c.pilihMetodeBayar,
                          ),
                        ),
                      ),
                SizedBox(height: layoutStyle.defaultMargin),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        margin: EdgeInsets.symmetric(
                          horizontal: layoutStyle.defaultMargin / 4,
                        ),
                        height: layoutStyle.blockVertical * 6.5,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorStyle.white,
                          side: BorderSide(color: colorStyle.grey),
                        ),
                        onPressed: () => Get.back(),
                        label: Text('Batal',
                            style: TextStyle(color: colorStyle.black)),
                      ),
                    ),
                    Expanded(
                      child: CustomButton(
                        margin: EdgeInsets.symmetric(
                          horizontal: layoutStyle.defaultMargin / 4,
                        ),
                        height: layoutStyle.blockVertical * 6.5,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorStyle.primary,
                        ),
                        onPressed: c.isSubmitting.value ? () {} : c.submit,
                        label: c.isSubmitting.value
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text('Terima Jaminan',
                                style: TextStyle(color: colorStyle.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  ).whenComplete(() {
    Get.delete<JaminanCashInDialogController>(tag: item.productId?.toString());
  });
}
