import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/domain/entities/sale/kelas_entity.dart';
import 'package:jaya_propertiy/presentation/components/custom_loading.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/sale/sale_cart_page_controller.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/sale/sale_kelas_page_controller.dart';

/// Tab Kelas (on-site, hari ini saja seperti playground): atur jumlah anak per sesi. Setiap klik +/-
/// langsung masuk keranjang. Sesi penuh, sudah selesai, atau ditutup admin
/// tampil tetapi tidak bisa dipilih.
class SaleKelasPage extends GetView<SaleKelasPageController> {
  const SaleKelasPage({super.key});

  @override
  Widget build(BuildContext context) {
    Widget judulTanggal() {
      return Padding(
        padding: EdgeInsets.all(layoutStyle.defaultMargin),
        child: Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_month, size: 18, color: colorStyle.primary),
              const SizedBox(width: 8),
              Text(
                'Kelas hari ini, ${SaleKelasPageController.labelTanggal(controller.tanggal.value)}',
                style: TextStyle(
                  fontSize: fontSize.subtitle,
                  fontWeight: FontWeight.bold,
                  color: colorStyle.primary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget barisSesi(KelasEntity kelas, KelasSesiEntity sesi) {
      return GetBuilder<SaleCartPageController>(
        builder: (_) {
          final qty = controller.qtyDiKeranjang(sesi);
          final bisa = sesi.bisaDijual;
          return Container(
            margin: const EdgeInsets.only(top: 6),
            padding: EdgeInsets.symmetric(
              horizontal: layoutStyle.defaultMargin,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: bisa ? colorStyle.white : colorStyle.lightGrey,
              border: Border.all(
                color: qty > 0 ? colorStyle.primary : colorStyle.lightGrey,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${sesi.sessionName ?? 'Sesi'}  ${sesi.jam}',
                        style: TextStyle(
                          fontSize: fontSize.body,
                          fontWeight: FontWeight.bold,
                          color: bisa ? colorStyle.black : colorStyle.grey,
                        ),
                      ),
                      Text(
                        'Rp ${common.currencyFormat(sesi.price ?? 0)}  ·  ${sesi.labelStatus}',
                        style: TextStyle(
                          fontSize: fontSize.small,
                          color: sesi.status == 'N'
                              ? colorStyle.green
                              : colorStyle.red,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Kurangi',
                  onPressed: qty > 0 ? () => controller.kurang(sesi) : null,
                  icon: Icon(Icons.remove_circle,
                      color: qty > 0 ? colorStyle.primary : colorStyle.grey),
                ),
                SizedBox(
                  width: 28,
                  child: Text(
                    '$qty',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: fontSize.title,
                      fontWeight: FontWeight.bold,
                      color: colorStyle.primary,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Tambah',
                  onPressed: bisa && qty < (sesi.remaining ?? 0)
                      ? () => controller.tambah(kelas, sesi)
                      : null,
                  icon: Icon(Icons.add_circle,
                      color: bisa && qty < (sesi.remaining ?? 0)
                          ? colorStyle.primary
                          : colorStyle.grey),
                ),
              ],
            ),
          );
        },
      );
    }

    Widget kartuKelas(KelasEntity kelas) {
      final keterangan = [
        if ((kelas.roomName ?? '').isNotEmpty) kelas.roomName!,
        if ((kelas.ticketLocationName ?? '').isNotEmpty)
          kelas.ticketLocationName!,
        'Kapasitas ${kelas.capacity ?? 0}',
      ].join('  ·  ');
      return Container(
        margin: EdgeInsets.only(bottom: layoutStyle.defaultMargin),
        padding: EdgeInsets.all(layoutStyle.defaultMargin),
        decoration: BoxDecoration(
          border: Border.all(color: colorStyle.primary),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          color: colorStyle.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              kelas.ticketName ?? '',
              style: TextStyle(
                fontSize: fontSize.subtitle,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              keterangan,
              style: TextStyle(fontSize: fontSize.small, color: colorStyle.grey),
            ),
            if (kelas.sessions.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Belum ada sesi.',
                  style:
                      TextStyle(fontSize: fontSize.small, color: colorStyle.grey),
                ),
              ),
            ...kelas.sessions.map((s) => barisSesi(kelas, s)),
          ],
        ),
      );
    }

    return SizedBox(
      width: layoutStyle.screenWidth,
      height: layoutStyle.screenHeight,
      child: Column(
        children: [
          judulTanggal(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.muat,
              child: Obx(
                () => controller.isLoading.value
                    ? loading.simpleLoading()
                    : controller.kelasList.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    top: layoutStyle.defaultMargin * 4),
                                child: Text(
                                  'Tidak ada kelas hari ini.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: fontSize.subtitle,
                                    color: colorStyle.grey,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.all(layoutStyle.defaultMargin),
                            children:
                                controller.kelasList.map(kartuKelas).toList(),
                          ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
