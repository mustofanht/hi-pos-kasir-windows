import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/data/models/common/wristband_config_model.dart';
import 'package:jaya_propertiy/domain/entities/common/custom_id_name_entity.dart';
import 'package:jaya_propertiy/presentation/components/custom_button.dart';
import 'package:jaya_propertiy/presentation/components/custom_dropdown_button.dart';
import 'package:jaya_propertiy/presentation/components/custom_loading.dart';
import 'package:jaya_propertiy/presentation/components/custom_text_box.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/setting/setting_page_controller.dart';

class SettingPage extends GetView<SettingPageController> {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    layoutStyle.init(context);

    return GetBuilder(
      init: controller,
      tag: 'SettingPage',
      initState: (state) {
        controller;
      },
      builder: (controller) {
        // return Column(
        //   children: <Widget>[
        //     Container(
        //       width: layoutStyle.screenWidth,
        //       color: colorStyle.lightGrey,
        //       child: Container(
        //         padding: EdgeInsets.symmetric(
        //           horizontal: layoutStyle.screenWidth / 4,
        //         ),
        //         child: TabBar(
        //           controller: controller.tabController,
        //           indicator: BoxDecoration(
        //               color: colorStyle.white,
        //               border: Border(
        //                 bottom: BorderSide(
        //                   color: colorStyle.primary,
        //                   width: 1.0,
        //                 ),
        //               )),
        //           labelColor: colorStyle.primary,
        //           unselectedLabelColor: colorStyle.black,
        //           tabs: const [
        //             Tab(text: 'User Info'),
        //             Tab(text: 'Server Info'),
        //             Tab(text: 'Customer Display'),
        //             Tab(text: 'Print Setting'),
        //           ],
        //         ),
        //       ),
        //     ),
        //     Expanded(
        //       child: TabBarView(
        //         controller: controller.tabController,
        //         children: const [
        //           UserInfo(),
        //           ServerInfo(),
        //           CustomerDisplay(),
        //           PrintSetting(),
        //         ],
        //       ),
        //     ),
        //   ],
        // );
        return Obx(
          () => Container(
            width: layoutStyle.screenWidth,
            height: layoutStyle.screenHeight,
            padding: EdgeInsets.all(layoutStyle.defaultMargin),
            child: Row(
              children: [
                Expanded(
                  child: controller.isLoading.value
                      ? loading.simpleLoading()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'User Information',
                              style: textStyle.blackText.copyWith(
                                fontSize: fontSize.header,
                              ),
                            ),
                            Container(
                              width: layoutStyle.screenWidth,
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: colorStyle.grey,
                                    width: 1,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: layoutStyle.defaultMargin,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: CustomTextBox(
                                    height: layoutStyle.blockVertical * 6.5,
                                    obscureText: false,
                                    margin: EdgeInsets.symmetric(
                                      horizontal: layoutStyle.defaultMargin,
                                      vertical: layoutStyle.defaultMargin / 4,
                                    ),
                                    border: Border.all(
                                      color: colorStyle.grey,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      layoutStyle.defaultMargin / 2,
                                    ),
                                    label: Text(
                                      'Unit',
                                      style: textStyle.greyText.copyWith(
                                        fontSize: fontSize.small,
                                      ),
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Unit',
                                      hintStyle: textStyle.greyText,
                                      border: InputBorder.none,
                                    ),
                                    controller: controller.unitController,
                                    isDisabled: true,
                                  ),
                                ),
                                Expanded(
                                  child: CustomTextBox(
                                    height: layoutStyle.blockVertical * 6.5,
                                    obscureText: false,
                                    margin: EdgeInsets.symmetric(
                                      horizontal: layoutStyle.defaultMargin,
                                      vertical: layoutStyle.defaultMargin / 4,
                                    ),
                                    border: Border.all(
                                      color: colorStyle.grey,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      layoutStyle.defaultMargin / 2,
                                    ),
                                    label: Text(
                                      'Last Login',
                                      style: textStyle.greyText.copyWith(
                                        fontSize: fontSize.small,
                                      ),
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Last Login',
                                      hintStyle: textStyle.greyText,
                                      border: InputBorder.none,
                                    ),
                                    controller: controller.lastLoginController,
                                    isDisabled: true,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: CustomTextBox(
                                    height: layoutStyle.blockVertical * 6.5,
                                    obscureText: false,
                                    margin: EdgeInsets.symmetric(
                                      horizontal: layoutStyle.defaultMargin,
                                      vertical: layoutStyle.defaultMargin / 4,
                                    ),
                                    border: Border.all(
                                      color: colorStyle.grey,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      layoutStyle.defaultMargin / 2,
                                    ),
                                    label: Text(
                                      'Nama',
                                      style: textStyle.greyText.copyWith(
                                        fontSize: fontSize.small,
                                      ),
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Nama',
                                      hintStyle: textStyle.greyText,
                                      border: InputBorder.none,
                                    ),
                                    controller: controller.nameController,
                                    isDisabled: true,
                                  ),
                                ),
                                Expanded(
                                  child: CustomTextBox(
                                    height: layoutStyle.blockVertical * 6.5,
                                    obscureText: false,
                                    margin: EdgeInsets.symmetric(
                                      horizontal: layoutStyle.defaultMargin,
                                      vertical: layoutStyle.defaultMargin / 4,
                                    ),
                                    border: Border.all(
                                      color: colorStyle.grey,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      layoutStyle.defaultMargin / 2,
                                    ),
                                    label: Text(
                                      'Role',
                                      style: textStyle.greyText.copyWith(
                                        fontSize: fontSize.small,
                                      ),
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Role',
                                      hintStyle: textStyle.greyText,
                                      border: InputBorder.none,
                                    ),
                                    controller: controller.roleController,
                                    isDisabled: true,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: CustomTextBox(
                                    height: layoutStyle.blockVertical * 6.5,
                                    obscureText: false,
                                    margin: EdgeInsets.symmetric(
                                      horizontal: layoutStyle.defaultMargin,
                                      vertical: layoutStyle.defaultMargin / 4,
                                    ),
                                    border: Border.all(
                                      color: colorStyle.grey,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      layoutStyle.defaultMargin / 2,
                                    ),
                                    label: Text(
                                      'No Telepon',
                                      style: textStyle.greyText.copyWith(
                                        fontSize: fontSize.small,
                                      ),
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'No Telepon',
                                      hintStyle: textStyle.greyText,
                                      border: InputBorder.none,
                                    ),
                                    controller: controller.noTelpController,
                                    isDisabled: true,
                                  ),
                                ),
                                Expanded(
                                  child: CustomTextBox(
                                    height: layoutStyle.blockVertical * 6.5,
                                    obscureText: false,
                                    margin: EdgeInsets.symmetric(
                                      horizontal: layoutStyle.defaultMargin,
                                      vertical: layoutStyle.defaultMargin / 4,
                                    ),
                                    border: Border.all(
                                      color: colorStyle.grey,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      layoutStyle.defaultMargin / 2,
                                    ),
                                    label: Text(
                                      'Email',
                                      style: textStyle.greyText.copyWith(
                                        fontSize: fontSize.small,
                                      ),
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Email',
                                      hintStyle: textStyle.greyText,
                                      border: InputBorder.none,
                                    ),
                                    controller: controller.emailController,
                                    isDisabled: true,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                ),
                SizedBox(
                  width: layoutStyle.defaultMargin,
                ),
                Expanded(
                  // Kolom ini tingginya terkunci setinggi layar. Tanpa dibuat
                  // bisa digulir, isian yang paling bawah terpotong di layar
                  // pendek dan tampak seperti tidak ada.
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Others Information',
                          style: textStyle.blackText.copyWith(
                            fontSize: fontSize.header,
                          ),
                        ),
                        Container(
                          width: layoutStyle.screenWidth,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: colorStyle.grey,
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: layoutStyle.defaultMargin,
                        ),
                        // CustomDropdownButton<CustomIdNameEntity>(
                        //   height: layoutStyle.blockVertical * 6.5,
                        //   items: controller.listScreens
                        //       .map(
                        //         (e) => DropdownMenuItem(
                        //           value: e,
                        //           child: Text("${e.name}"),
                        //         ),
                        //       )
                        //       .toList(),
                        //   value: controller.selectedScreens.value,
                        //   label: Text(
                        //     'List Screen Connect',
                        //     style: textStyle.greyText.copyWith(
                        //       fontSize: fontSize.small,
                        //     ),
                        //   ),
                        //   border: Border.all(
                        //     color: colorStyle.lightGrey,
                        //     width: 1,
                        //   ),
                        //   margin: EdgeInsets.symmetric(
                        //     vertical: layoutStyle.defaultMargin / 4,
                        //     horizontal: layoutStyle.defaultMargin,
                        //   ),
                        //   onChanged: (val) {
                        //     controller.selectedCurrPrinter.value = val!;
                        //     controller.update();
                        //   },
                        // ),
                        CustomButton(
                          margin: EdgeInsets.symmetric(
                            vertical: layoutStyle.defaultMargin / 2,
                            horizontal: layoutStyle.defaultMargin,
                          ),
                          onPressed: () {
                            controller.doRefreshCustomerPage();
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.resolveWith(
                              (states) => colorStyle.blue,
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
                          ),
                          prefixIcon:
                              controller.isLoadingRefreshCustScreeen.value
                                  ? Container()
                                  : Icon(Icons.refresh_outlined,
                                      color: colorStyle.white),
                          label: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: layoutStyle.defaultMargin,
                            ),
                            child: controller.isLoadingRefreshCustScreeen.value
                                ? loading.buttonLoading()
                                : Text(
                                    'Refresh Customer Page',
                                    style: textStyle.whiteText,
                                  ),
                          ),
                          height: layoutStyle.blockVertical * 6.5,
                        ),
                        // controller.isLoadingPrinter.value
                        //     ? Center(
                        //         child: SizedBox(
                        //           width: layoutStyle.blockVertical * 6.5,
                        //           height: layoutStyle.blockVertical * 6.5,
                        //           child: loading.simpleLoading(),
                        //         ),
                        //       )
                        //     :
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Obx(
                                () => CustomDropdownButton<CustomIdNameEntity>(
                                  isLoading: controller.isLoadingPrinter.value,
                                  height: layoutStyle.blockVertical * 6.5,
                                  items: controller.listPrinter
                                      .map(
                                        (e) => DropdownMenuItem(
                                          value: e,
                                          child: Text("${e.name}"),
                                        ),
                                      )
                                      .toList(),
                                  value: controller.selectedCurrPrinter.value,
                                  label: Text(
                                    'Pilih Printer',
                                    style: textStyle.greyText.copyWith(
                                      fontSize: fontSize.small,
                                    ),
                                  ),
                                  border: Border.all(
                                    color: colorStyle.lightGrey,
                                    width: 1,
                                  ),
                                  margin: EdgeInsets.symmetric(
                                    vertical: layoutStyle.defaultMargin / 4,
                                    horizontal: layoutStyle.defaultMargin,
                                  ),
                                  onChanged:
                                      controller.isLoadingConnectPrinter.value
                                          ? null
                                          : controller.doUpdateConnectedPrinter,
                                ),
                              ),
                            ),
                            CustomButton(
                              width: layoutStyle.blockVertical * 6.5,
                              height: layoutStyle.blockVertical * 6.5,
                              margin: EdgeInsets.symmetric(
                                vertical: layoutStyle.defaultMargin / 2,
                                horizontal: layoutStyle.defaultMargin / 5,
                              ),
                              onPressed: () {
                                controller.doInitializePrinter();
                              },
                              style: ButtonStyle(
                                minimumSize:
                                    MaterialStateProperty.all(Size.zero),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                padding:
                                    MaterialStateProperty.all(EdgeInsets.zero),
                                backgroundColor:
                                    MaterialStateProperty.resolveWith(
                                  (states) => colorStyle.blue,
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
                              ),
                              label:
                                  Icon(Icons.refresh, color: colorStyle.white),
                            ),
                            CustomButton(
                              width: layoutStyle.blockVertical * 6.5,
                              height: layoutStyle.blockVertical * 6.5,
                              margin: EdgeInsets.symmetric(
                                vertical: layoutStyle.defaultMargin / 2,
                                horizontal: layoutStyle.defaultMargin / 5,
                              ),
                              onPressed: () {
                                controller.testPrint();
                              },
                              style: ButtonStyle(
                                minimumSize:
                                    MaterialStateProperty.all(Size.zero),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                padding:
                                    MaterialStateProperty.all(EdgeInsets.zero),
                                backgroundColor:
                                    MaterialStateProperty.resolveWith(
                                  (states) => colorStyle.blue,
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
                              ),
                              label: Icon(Icons.print, color: colorStyle.white),
                              // suffixIcon: const Icon(Icons.print),
                              // prefixIcon: const Icon(Icons.print),
                              // label: controller.isLoading.value
                              //     ? loading.buttonLoading()
                              //     : Padding(
                              //         padding: EdgeInsets.symmetric(
                              //           horizontal: layoutStyle.defaultMargin,
                              //         ),
                              //         child: Text(
                              //           'Test',
                              //           style: textStyle.whiteText,
                              //         ),
                              //       ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: layoutStyle.defaultMargin / 5,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Obx(
                                  () => Text(
                                    'Printer Connected : ${controller.currentPrinterConnect}',
                                    style: textStyle.blackText,
                                  ),
                                ),
                              ),
                              CustomButton(
                                width: layoutStyle.blockVertical * 6.5,
                                height: layoutStyle.blockVertical * 6.5,
                                margin: EdgeInsets.symmetric(
                                  vertical: layoutStyle.defaultMargin / 2,
                                  horizontal: layoutStyle.defaultMargin / 5,
                                ),
                                onPressed: () {
                                  controller.doDisconnectPrinter();
                                },
                                style: ButtonStyle(
                                  minimumSize:
                                      MaterialStateProperty.all(Size.zero),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  padding: MaterialStateProperty.all(
                                      EdgeInsets.zero),
                                  backgroundColor:
                                      MaterialStateProperty.resolveWith(
                                    (states) => colorStyle.blue,
                                  ),
                                  overlayColor:
                                      MaterialStateProperty.resolveWith(
                                    (states) =>
                                        colorStyle.black.withOpacity(0.1),
                                  ),
                                  shape: MaterialStateProperty.resolveWith(
                                    (states) => RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        layoutStyle.defaultMargin / 2,
                                      ),
                                    ),
                                  ),
                                ),
                                label: controller.isLoadingPrinterDiconect.value
                                    ? Container(
                                        alignment: Alignment.center,
                                        padding: EdgeInsets.all(
                                          layoutStyle.defaultMargin / 10,
                                        ),
                                        width: layoutStyle.blockHorizontal * 3,
                                        height: layoutStyle.blockVertical * 3,
                                        child: CircularProgressIndicator(
                                          color: colorStyle.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Icon(Icons.link_off,
                                        color: colorStyle.white),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: layoutStyle.defaultMargin),
                        _printerGelang(controller),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Printer gelang — perangkat kedua di samping printer struk.
  ///
  /// Ukuran medianya bisa diubah di sini karena tidak ada satu ukuran yang
  /// benar: label 50x25mm dan gulungan gelang 25x220mm sama-sama dipakai, dan
  /// printer yang salah setelan ukurannya tidak mengeluh — ia mencetak sebagian
  /// lalu memotong sisanya diam-diam. Setelan yang sudah terbukti sebaiknya
  /// dikunci.
  Widget _printerGelang(SettingPageController controller) {
    return Obx(() {
      // Kunci hanya berlaku untuk Setelan lanjutan. Pilihan printer diatur per
      // perangkat, jadi selalu bisa diubah.
      final aktif = !controller.terkunciGelang.value;
      final bawaan = controller.setelanGelangBawaan;
      return Container(
        padding: EdgeInsets.all(layoutStyle.defaultMargin / 2),
        decoration: BoxDecoration(
          border: Border.all(color: colorStyle.grey.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(layoutStyle.defaultMargin / 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Printer Gelang',
              style: textStyle.blackText.copyWith(fontSize: fontSize.subtitle),
            ),
            Text(
              controller.selectedPrinterGelang.value.id == null
                  ? 'Belum ada printer gelang. QR tiket dicetak di kertas struk.'
                  : 'QR tiket dicetak di gelang lewat printer ini.',
              style: textStyle.greyText.copyWith(fontSize: fontSize.small),
            ),
            SizedBox(height: layoutStyle.defaultMargin / 2),
            DropdownButtonFormField<String?>(
              value: controller.selectedPrinterGelang.value.id?.toString(),
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Perangkat',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: controller.listPrinterGelang
                  .map((e) => DropdownMenuItem<String?>(
                        value: e.id?.toString(),
                        child: Text('${e.name}'),
                      ))
                  .toList(),
              onChanged: (val) => controller.doPilihPrinterGelang(
                controller.listPrinterGelang.firstWhere(
                  (e) => e.id?.toString() == val,
                  orElse: () => CustomIdNameEntity(id: null),
                ),
              ),
            ),
            // Setelan media disembunyikan: bawaannya sudah terbukti di printer
            // outlet, dan salah ubah membuat gelang tercetak di posisi yang salah
            // tanpa printer mengeluh. Tetap bisa dibuka tanpa update aplikasi
            // untuk printer atau media yang berbeda.
            ExpansionTile(
              shape: const Border(),
              collapsedShape: const Border(),
              tilePadding: EdgeInsets.zero,
              childrenPadding: EdgeInsets.zero,
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              leading: Icon(
                controller.terkunciGelang.value
                    ? Icons.lock_outline
                    : Icons.lock_open_outlined,
              ),
              title: Text('Setelan lanjutan', style: textStyle.blackText),
              subtitle: Text(
                '${bawaan ? "Memakai setelan standar" : "Setelan sudah diubah dari standar"}'
                ' · ${controller.terkunciGelang.value ? "terkunci" : "tidak terkunci"}',
                style: textStyle.greyText.copyWith(fontSize: fontSize.small),
              ),
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  secondary: Icon(
                    controller.terkunciGelang.value
                        ? Icons.lock_outline
                        : Icons.lock_open_outlined,
                  ),
                  value: controller.terkunciGelang.value,
                  onChanged: controller.doToggleKunciGelang,
                  title: Text('Kunci setelan', style: textStyle.blackText),
                  subtitle: Text(
                    controller.terkunciGelang.value
                        ? 'Setelan di bawah tidak bisa diubah. Matikan kunci '
                            'hanya kalau memang perlu mengubahnya.'
                        : 'Setelan bisa diubah. Nyalakan lagi kunci setelah '
                            'selesai supaya tidak berubah tanpa sengaja.',
                    style:
                        textStyle.greyText.copyWith(fontSize: fontSize.small),
                  ),
                ),
                Row(
                  children: [
                    _kotakAngka('Lebar (mm)', controller.lebarGelangController,
                        aktif: aktif),
                    _kotakAngka(
                        'Tinggi (mm)', controller.tinggiGelangController,
                        aktif: aktif),
                    _kotakAngka('Jarak (mm)', controller.jarakGelangController,
                        aktif: aktif),
                    _kotakAngka(
                        'Margin (mm)', controller.marginGelangController,
                        aktif: aktif),
                  ],
                ),
                SizedBox(height: layoutStyle.defaultMargin / 2),
                Row(
                  children: [
                    _kotakPilihan<int>(
                      aktif: aktif,
                      'Resolusi',
                      controller.dpiGelang.value,
                      const [203, 300],
                      (v) => controller.dpiGelang.value = v,
                      teks: (v) => '$v dpi',
                    ),
                    _kotakPilihan<int>(
                      aktif: aktif,
                      'Kerapatan',
                      controller.kerapatanGelang.value,
                      List<int>.generate(16, (i) => i),
                      (v) => controller.kerapatanGelang.value = v,
                    ),
                    _kotakPilihan<int>(
                      aktif: aktif,
                      'Kecepatan',
                      controller.kecepatanGelang.value,
                      const [1, 2, 3, 4, 5, 6],
                      (v) => controller.kecepatanGelang.value = v,
                    ),
                    _kotakPilihan<int>(
                      aktif: aktif,
                      'Arah',
                      controller.arahGelang.value,
                      const [0, 1],
                      (v) => controller.arahGelang.value = v,
                    ),
                  ],
                ),
                SizedBox(height: layoutStyle.defaultMargin / 2),
                Row(
                  children: [
                    _kotakAngka(
                        'QR maks (mm)', controller.qrMaksGelangController,
                        aktif: aktif),
                    _kotakAngka(
                        'Geser X (mm)', controller.geserXGelangController,
                        aktif: aktif),
                    _kotakAngka(
                        'Geser Y (mm)', controller.geserYGelangController,
                        aktif: aktif),
                    _kotakAngka(
                        'Geser lembar (mm)', controller.shiftGelangController,
                        aktif: aktif),
                  ],
                ),
                SizedBox(height: layoutStyle.defaultMargin / 2),
                Row(
                  children: [
                    _kotakPilihan<SensorMedia>(
                      aktif: aktif,
                      'Sensor media',
                      controller.sensorGelang.value,
                      SensorMedia.values,
                      (v) => controller.sensorGelang.value = v,
                      teks: (v) => switch (v) {
                        SensorMedia.menerus => 'Tanpa penanda',
                        SensorMedia.celah => 'Celah di antara gelang',
                        SensorMedia.tandaHitam => 'Garis hitam di balik gelang',
                      },
                    ),
                    _kotakPilihan<PosisiIsi>(
                      aktif: aktif,
                      'Posisi isi',
                      controller.posisiGelang.value,
                      PosisiIsi.values,
                      (v) => controller.posisiGelang.value = v,
                      teks: (v) => switch (v) {
                        PosisiIsi.atas => 'Di ujung awal',
                        PosisiIsi.tengah => 'Di tengah',
                        PosisiIsi.bawah => 'Di ujung akhir',
                      },
                    ),
                    _kotakPilihan<ModePotong>(
                      aktif: aktif,
                      'Pemisah gelang',
                      controller.potongGelang.value,
                      ModePotong.values,
                      (v) => controller.potongGelang.value = v,
                      teks: (v) => switch (v) {
                        ModePotong.sobek => 'Disobek tangan',
                        ModePotong.tiapGelang =>
                          'Dipotong tiap gelang (perlu pisau)',
                        ModePotong.akhirBatch =>
                          'Dipotong di akhir (perlu pisau)',
                        ModePotong.tanpaMaju => 'Tidak dimajukan',
                      },
                    ),
                  ],
                ),
                SizedBox(height: layoutStyle.defaultMargin / 2),
                Wrap(
                  children: [
                    TextButton.icon(
                      onPressed:
                          aktif ? controller.doSimpanSetelanGelang : null,
                      icon: const Icon(Icons.save_outlined, size: 18),
                      label: const Text('Simpan Setelan'),
                    ),
                    TextButton.icon(
                      onPressed: aktif && !bawaan
                          ? controller.doPakaiSetelanBawaan
                          : null,
                      icon: const Icon(Icons.restore, size: 18),
                      label: const Text('Kembalikan ke Standar'),
                    ),
                  ],
                ),
                SizedBox(height: layoutStyle.defaultMargin / 2),
                _panduanGelang(),
              ],
            ),
          ],
        ),
      );
    });
  }

  /// Arti setiap setelan lanjutan, untuk kasir yang baru pertama kali memegang
  /// printer gelang. Bahasanya sengaja tanpa istilah printer: yang dibutuhkan
  /// di outlet adalah "kalau begini, ubah yang ini", bukan cara kerja TSPL.
  Widget _panduanGelang() {
    const panduan = <(String, String)>[
      ('Lebar', 'Lebar pita gelang. Standar 25 mm.'),
      (
        'Tinggi',
        'Panjang bagian gelang yang dipakai untuk mencetak. '
            'Standar 200 mm.'
      ),
      ('Jarak', 'Tebal garis hitam di balik gelang. Standar 3 mm.'),
      ('Margin', 'Ruang kosong di pinggir cetakan. Standar 0.'),
      (
        'Resolusi',
        'Ketajaman printer, tertulis di label printer. '
            'Standar 203 dpi.'
      ),
      (
        'Kerapatan',
        'Tingkat hitam cetakan. Naikkan kalau QR pucat atau '
            'tidak terbaca di pintu masuk. Standar 12.'
      ),
      (
        'Kecepatan',
        'Kecepatan mencetak. Makin pelan, makin hitam. '
            'Standar 2.'
      ),
      ('Arah', 'Ganti kalau tulisan di gelang tercetak terbalik. Standar 1.'),
      ('QR maks', 'Ukuran QR paling besar. Standar 19 mm.'),
      ('Geser X / Geser Y', 'Menggeser cetakan sedikit. Biarkan 0.'),
      (
        'Geser lembar',
        'Jarak cetakan dari ujung gelang. Tambah angkanya '
            'kalau cetakan terlalu dekat ke ujung, kurangi kalau terlalu jauh. '
            'Standar 25 mm.'
      ),
      (
        'Sensor media',
        'Cara printer mengenali batas satu gelang. Gelang '
            'kita punya garis hitam di baliknya, jadi pilih "Garis hitam di '
            'balik gelang". Jangan pilih "Celah": printer akan terus menggulung '
            'gelang tanpa berhenti.'
      ),
      ('Posisi isi', 'Letak cetakan di gelang. Standar "Di ujung awal".'),
      (
        'Pemisah gelang',
        'Printer kita tidak punya pisau, jadi pilih '
            '"Disobek tangan".'
      ),
    ];
    final kecil = textStyle.greyText.copyWith(fontSize: fontSize.small);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Arti setiap setelan',
            style: textStyle.blackText.copyWith(fontSize: fontSize.small)),
        SizedBox(height: layoutStyle.defaultMargin / 4),
        for (final (judul, isi) in panduan)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text.rich(
              TextSpan(children: [
                TextSpan(
                  text: '$judul: ',
                  style: kecil.copyWith(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: isi),
              ]),
              style: kecil,
            ),
          ),
        SizedBox(height: layoutStyle.defaultMargin / 4),
        Text(
          'Setelah mengubah, tekan Simpan Setelan lalu coba satu transaksi. '
          'Kalau hasilnya jadi aneh atau gelang tidak keluar, tekan '
          'Kembalikan ke Standar.',
          style: textStyle.blackText.copyWith(fontSize: fontSize.small),
        ),
      ],
    );
  }

  Widget _kotakAngka(String label, TextEditingController controller,
      {bool aktif = true}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: TextField(
          controller: controller,
          enabled: aktif,
          // signed: true supaya papan tombol angka ikut menyediakan tanda minus.
          // Kolom Geser X/Y memang menerima nilai negatif, dan tanpa ini
          // operator harus berganti papan tombol untuk mengetiknya.
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: true,
          ),
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            isDense: true,
          ),
        ),
      ),
    );
  }

  Widget _kotakPilihan<T>(
    String label,
    T nilai,
    List<T> pilihan,
    void Function(T) onPilih, {
    String Function(T)? teks,
    bool aktif = true,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: DropdownButtonFormField<T>(
          value: nilai,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            isDense: true,
          ),
          items: pilihan
              .map((e) => DropdownMenuItem<T>(
                    value: e,
                    child: Text(teks == null ? '$e' : teks(e)),
                  ))
              .toList(),
          onChanged: !aktif
              ? null
              : (v) {
                  if (v != null) onPilih(v);
                },
        ),
      ),
    );
  }


}
