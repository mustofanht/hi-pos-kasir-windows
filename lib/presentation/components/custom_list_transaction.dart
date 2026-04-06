import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/domain/entities/auth/auth_token.dart';
import 'package:jaya_propertiy/domain/entities/sale/addon_entity.dart';
import 'package:jaya_propertiy/domain/entities/transaction/transaction_entity.dart';
import 'package:jaya_propertiy/presentation/components/controller/custom_list_transaction_controller.dart';
import 'package:jaya_propertiy/presentation/components/custom_alert.dart';
import 'package:jaya_propertiy/presentation/components/custom_button.dart';
import 'package:jaya_propertiy/presentation/components/custom_card_transaction.dart';
import 'package:jaya_propertiy/presentation/components/custom_loading.dart';
import 'package:jaya_propertiy/presentation/components/custom_text_box.dart';

class CustomListTransaction extends StatefulWidget {
  final Function(TransactionEntity selected) onNext;
  final AddonEntity entitiy;
  final AuthToken authToken;
  const CustomListTransaction({
    super.key,
    required this.onNext,
    required this.entitiy,
    required this.authToken,
  });

  @override
  State<CustomListTransaction> createState() => _CustomListTransactionState();
}

class _CustomListTransactionState extends State<CustomListTransaction> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CustomListTransactionController(
      entitiy: widget.entitiy,
      authToken: widget.authToken,
    ));

    List<Widget> headerSection() {
      return [
        Container(
          padding: EdgeInsets.symmetric(
            vertical: layoutStyle.defaultMargin / 2,
            horizontal: layoutStyle.defaultMargin,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'List Transaksi',
                  style: textStyle.blackText.copyWith(
                    fontWeight: fontWeight.bold,
                    fontSize: fontSize.header,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: Icon(
                  Icons.close,
                  color: colorStyle.red,
                ),
              ),
            ],
          ),
        ),
        CustomTextBox(
          height: layoutStyle.blockVertical * 6.5,
          margin: EdgeInsets.symmetric(
            vertical: layoutStyle.defaultMargin / 2,
            horizontal: layoutStyle.defaultMargin,
          ),
          obscureText: false,
          border: Border.all(
            color: colorStyle.grey,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(
            layoutStyle.defaultMargin / 2,
          ),
          controller: controller.searchController,
          decoration: InputDecoration(
            isCollapsed: true,
            contentPadding: EdgeInsets.symmetric(
              vertical: layoutStyle.blockVertical * 1.5,
              horizontal: layoutStyle.blockHorizontal * 2,
            ),
            prefix: SizedBox(
              width: layoutStyle.defaultMargin / 2,
            ),
            prefixIconConstraints: BoxConstraints(
              maxWidth: layoutStyle.blockHorizontal * 6.5,
              maxHeight: layoutStyle.blockHorizontal * 6.5,
            ),
            hintText: 'Cari Data',
            hintStyle: textStyle.greyText,
            border: InputBorder.none,
            prefixIcon: Icon(
              Icons.search,
              color: colorStyle.grey,
            ),
          ),
          onChanged: (val) {
            controller.doPrepered(page: 0, search: val);
          },
        ),
        Container(
          width: layoutStyle.screenWidth,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: colorStyle.lightGrey,
                width: 1,
              ),
            ),
          ),
        ),
      ];
    }

    Widget actionSection() {
      return Container(
        padding: EdgeInsets.all(layoutStyle.defaultMargin),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: CustomButton(
                margin: EdgeInsets.symmetric(
                  vertical: layoutStyle.defaultMargin / 2,
                  horizontal: layoutStyle.defaultMargin,
                ),
                onPressed: () {
                  Get.back();
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith(
                    (states) => colorStyle.white,
                  ),
                  overlayColor: MaterialStateProperty.resolveWith(
                    (states) => colorStyle.black.withOpacity(0.1),
                  ),
                  shape: MaterialStateProperty.resolveWith(
                    (states) => RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        layoutStyle.defaultMargin / 2,
                      ),
                    ),
                  ),
                  side: MaterialStatePropertyAll(
                    BorderSide(
                      color: colorStyle.blue,
                      width: 1,
                    ),
                  ),
                  elevation: const MaterialStatePropertyAll(0),
                ),
                label: Text(
                  'Batal',
                  style: textStyle.blueText,
                ),
                height: layoutStyle.blockVertical * 6.5,
              ),
            ),
            Expanded(
              child: CustomButton(
                margin: EdgeInsets.symmetric(
                  vertical: layoutStyle.defaultMargin / 2,
                  horizontal: layoutStyle.defaultMargin,
                ),
                onPressed: () {
                  if (controller.selectedTransaction.value != null) {
                    widget.onNext(controller.selectedTransaction.value!);
                  } else {
                    alert.warning('Warning', 'Silahkan pilih transaksi');
                  }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith(
                    (states) => colorStyle.primary,
                  ),
                  overlayColor: MaterialStateProperty.resolveWith(
                    (states) => colorStyle.black.withOpacity(0.1),
                  ),
                  shape: MaterialStateProperty.resolveWith(
                    (states) => RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        layoutStyle.defaultMargin / 2,
                      ),
                    ),
                  ),
                  elevation: const MaterialStatePropertyAll(0),
                ),
                label: Text(
                  'Lanjutkan',
                  style: textStyle.whiteText,
                ),
                height: layoutStyle.blockVertical * 6.5,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        ...headerSection(),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(layoutStyle.defaultMargin),
            child: Obx(
              () => controller.isLoading.value
                  ? loading.simpleLoading()
                  : SingleChildScrollView(
                      controller: controller.scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: controller.listData
                            .map(
                              (e) => CustomCardTransaction(
                                data: e,
                                onSelect: controller.doSelected,
                                selectedData:
                                    controller.selectedTransaction.value,
                              ),
                            )
                            .toList(),
                      ),
                    ),
            ),
          ),
        ),
        actionSection(),
      ],
    );
  }
}
