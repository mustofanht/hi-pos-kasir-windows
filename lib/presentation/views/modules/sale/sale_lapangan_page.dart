import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/app/utils/constant/assets_constant.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/presentation/components/custom_loading.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/sale/sale_lapangan_page_controller.dart';

class SaleLapanganPage extends GetView<SaleLapanganPageController> {
  const SaleLapanganPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color borderColor = colorStyle.grey.withOpacity(0.25);

    Widget emptyData() {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              assetsConstant.imgEmptyBox,
              width: layoutStyle.safeBlockHorizontal * 12,
              height: layoutStyle.safeBlockVertical * 12,
              fit: BoxFit.contain,
              errorBuilder: (BuildContext context, Object exception,
                  StackTrace? stackTrace) {
                return const Text('Img Not Found');
              },
            ),
            SizedBox(
              height: layoutStyle.defaultMargin,
            ),
            Text(
              'Belum Ada Lapangan',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSize.title,
                fontWeight: fontWeight.bold,
              ),
            ),
            SizedBox(
              height: layoutStyle.defaultMargin / 2,
            ),
            Text(
              'Belum ada lapangan sewa per jam pada lokasi ini',
              textAlign: TextAlign.center,
              style: textStyle.greyText.copyWith(fontSize: fontSize.small),
            ),
          ],
        ),
      );
    }

    /// Satu baris chip lapangan, digeser horizontal (bukan grid yang membungkus).
    Widget courtChips() {
      return SizedBox(
        height: layoutStyle.defaultMargin * 2.2,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: controller.courtList.length,
          separatorBuilder: (context, index) => SizedBox(
            width: layoutStyle.defaultMargin / 2,
          ),
          itemBuilder: (context, index) {
            final bool isActive = controller.activeCourtIndex.value == index;
            return GestureDetector(
              onTap: () {
                controller.doSelectCourt(index);
              },
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(
                  horizontal: layoutStyle.defaultMargin,
                  vertical: layoutStyle.defaultMargin / 4,
                ),
                decoration: BoxDecoration(
                  color: isActive ? colorStyle.primary : colorStyle.white,
                  borderRadius: BorderRadius.circular(
                    layoutStyle.defaultMargin,
                  ),
                  border: Border.all(
                    color: isActive ? colorStyle.primary : borderColor,
                    width: 1,
                  ),
                ),
                child: Text(
                  controller.courtList[index].productName ?? '-',
                  style: (isActive ? textStyle.whiteText : textStyle.greyText)
                      .copyWith(
                    fontSize: fontSize.small,
                    fontWeight: fontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    /// Tanggal statis: kasir hanya boleh membooking untuk hari ini.
    Widget datePill() {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: layoutStyle.defaultMargin / 1.5,
          vertical: layoutStyle.defaultMargin / 3,
        ),
        decoration: BoxDecoration(
          color: colorStyle.white,
          borderRadius: BorderRadius.circular(layoutStyle.defaultMargin / 1.6),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: fontSize.subtitle,
              color: colorStyle.primary,
            ),
            SizedBox(
              width: layoutStyle.defaultMargin / 2.5,
            ),
            Text(
              '${controller.dateLabel} · Hari ini',
              style: textStyle.blackText.copyWith(
                fontSize: fontSize.small,
                fontWeight: fontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    Widget legendItem(String label, Color color, {Color? border}) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: fontSize.small,
            height: fontSize.small,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: border ?? color, width: 1),
            ),
          ),
          SizedBox(
            width: layoutStyle.defaultMargin / 3,
          ),
          Text(
            label,
            style: textStyle.greyText.copyWith(fontSize: fontSize.small),
          ),
        ],
      );
    }

    Widget legendRow() {
      return Row(
        children: [
          legendItem('Tersedia', colorStyle.white, border: borderColor),
          SizedBox(width: layoutStyle.defaultMargin),
          legendItem('Dipilih', colorStyle.primary),
          SizedBox(width: layoutStyle.defaultMargin),
          legendItem('Terisi', colorStyle.lightGrey),
          const Spacer(),
          Text.rich(
            TextSpan(
              text: 'Harga ',
              style: textStyle.greyText.copyWith(fontSize: fontSize.small),
              children: [
                TextSpan(
                  text: 'Rp ${common.currencyFormat(controller.pricePerHour)}',
                  style: textStyle.blackText.copyWith(
                    fontSize: fontSize.small,
                    fontWeight: fontWeight.bold,
                  ),
                ),
                const TextSpan(text: ' / jam'),
              ],
            ),
          ),
        ],
      );
    }

    Widget slotCell(int index) {
      final status = controller.slotStatus(index);
      final bool isSelected = status == LapanganSlotStatus.dipilih;
      final bool isDisabled = status == LapanganSlotStatus.terisi ||
          status == LapanganSlotStatus.lewat;

      final Color background = isSelected
          ? colorStyle.primary
          : isDisabled
              ? colorStyle.lightGrey
              : colorStyle.white;
      final Color foreground = isSelected
          ? colorStyle.white
          : isDisabled
              ? colorStyle.grey
              : colorStyle.black;

      return GestureDetector(
        onTap: isDisabled
            ? null
            : () {
                controller.doToggleSlot(index);
              },
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(
            horizontal: layoutStyle.defaultMargin / 4,
            vertical: layoutStyle.defaultMargin / 3,
          ),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(layoutStyle.defaultMargin / 2),
            border: Border.all(
              color: isSelected ? colorStyle.primary : borderColor,
              width: 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: colorStyle.primary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                controller.slotTimeLabel(index),
                style: TextStyle(
                  color: foreground,
                  fontSize: fontSize.small,
                  fontWeight: fontWeight.semiBold,
                ),
              ),
              SizedBox(
                height: layoutStyle.defaultMargin / 5,
              ),
              Text(
                controller.slotStatusLabel(index),
                style: TextStyle(
                  color: foreground.withOpacity(0.75),
                  fontSize: fontSize.superSmall,
                  fontWeight: fontWeight.semiBold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget scheduleGrid() {
      if (controller.isLoadingSchedule.value) {
        return loading.simpleLoading();
      }
      return RefreshIndicator(
        onRefresh: () async {
          await controller.doPrepareSchedule();
        },
        child: GridView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          primary: false,
          padding: EdgeInsets.only(bottom: layoutStyle.defaultMargin),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 150,
            mainAxisExtent: 64,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: controller.totalSlot,
          itemBuilder: (context, index) => slotCell(index),
        ),
      );
    }

    return GetBuilder(
      init: controller,
      tag: 'SaleLapanganPage',
      builder: (controller) {
        return Obx(
          () => Container(
            width: layoutStyle.screenWidth,
            height: layoutStyle.screenHeight,
            padding: EdgeInsets.all(layoutStyle.defaultMargin),
            child: controller.isLoading.value
                ? loading.simpleLoading()
                : controller.courtList.isEmpty
                    ? emptyData()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          courtChips(),
                          SizedBox(
                            height: layoutStyle.defaultMargin / 1.5,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Pilih jam & durasi untuk ${controller.courtLabel}',
                                  style: textStyle.greyText.copyWith(
                                    fontSize: fontSize.small,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: layoutStyle.defaultMargin / 2,
                              ),
                              datePill(),
                            ],
                          ),
                          SizedBox(
                            height: layoutStyle.defaultMargin / 1.5,
                          ),
                          legendRow(),
                          SizedBox(
                            height: layoutStyle.defaultMargin / 1.5,
                          ),
                          Expanded(
                            child: scheduleGrid(),
                          ),
                        ],
                      ),
          ),
        );
      },
    );
  }
}
