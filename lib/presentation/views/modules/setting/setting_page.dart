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
                        SizedBox(height: layoutStyle.defaultMargin),
                        _simulasiPerangkat(controller),
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
  /// lalu memotong sisanya diam-diam. Karena itu ada tombol cetak uji.
  Widget _printerGelang(SettingPageController controller) {
    return Obx(
      () => Container(
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
                  ? 'Belum diatur — QR tiket masih dicetak menyambung struk.'
                  : 'QR tiket dicetak sebagai gelang di perangkat ini (TSPL).',
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
            SizedBox(height: layoutStyle.defaultMargin / 2),
            Row(
              children: [
                _kotakAngka('Lebar (mm)', controller.lebarGelangController),
                _kotakAngka('Tinggi (mm)', controller.tinggiGelangController),
                _kotakAngka('Jarak (mm)', controller.jarakGelangController),
                _kotakAngka('Margin (mm)', controller.marginGelangController),
              ],
            ),
            SizedBox(height: layoutStyle.defaultMargin / 2),
            Row(
              children: [
                _kotakPilihan<int>(
                  'Resolusi',
                  controller.dpiGelang.value,
                  const [203, 300],
                  (v) => controller.dpiGelang.value = v,
                  teks: (v) => '$v dpi',
                ),
                _kotakPilihan<int>(
                  'Kerapatan',
                  controller.kerapatanGelang.value,
                  List<int>.generate(16, (i) => i),
                  (v) => controller.kerapatanGelang.value = v,
                ),
                _kotakPilihan<int>(
                  'Kecepatan',
                  controller.kecepatanGelang.value,
                  const [1, 2, 3, 4, 5, 6],
                  (v) => controller.kecepatanGelang.value = v,
                ),
                _kotakPilihan<int>(
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
                _kotakAngka('Geser X (mm)', controller.geserXGelangController),
                _kotakAngka('Geser Y (mm)', controller.geserYGelangController),
              ],
            ),
            SizedBox(height: layoutStyle.defaultMargin / 2),
            Row(
              children: [
                _kotakPilihan<ModePotong>(
                  'Pemisah gelang',
                  controller.potongGelang.value,
                  ModePotong.values,
                  (v) => controller.potongGelang.value = v,
                  teks: (v) => switch (v) {
                    ModePotong.sobek => 'Sobek manual (tanpa pemotong)',
                    ModePotong.tiapGelang => 'Potong tiap gelang',
                    ModePotong.akhirBatch => 'Potong di akhir cetakan',
                  },
                ),
              ],
            ),
            // Peringatan paling penting di kartu ini. Tanpanya, Cetak Uji
            // melaporkan berhasil sementara printer diam — dan yang dicurigai
            // orang pertama kali adalah kabelnya, bukan saklar simulasi.
            if (controller.simulatePrinter.value)
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(top: layoutStyle.defaultMargin / 2),
                padding: EdgeInsets.all(layoutStyle.defaultMargin / 3),
                color: colorStyle.yellow.withOpacity(0.25),
                child: Text(
                  'Simulasi Printer sedang menyala — cetakan ditangkap ke '
                  'Hasil Cetak, tidak ada kertas yang keluar. Matikan dulu '
                  'untuk mencetak sungguhan.',
                  style: textStyle.blackText.copyWith(fontSize: fontSize.small),
                ),
              ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              value: controller.putarIsiGelang.value,
              onChanged: controller.doTogglePutarIsi,
              title: Text('Putar isi 90 derajat', style: textStyle.blackText),
              subtitle: Text(
                controller.putarIsiGelang.value
                    ? 'Isi membaca menyusuri panjang gelang — huruf bisa jauh '
                        'lebih besar. Buktikan dengan Cetak Uji.'
                    : 'Isi membaca melintang pita. Pada pita sempit, huruf '
                        'terpaksa kecil dan teks panjang terpotong.',
                style: textStyle.greyText.copyWith(fontSize: fontSize.small),
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              value: controller.gelangPendamping.value,
              onChanged: controller.doToggleGelangPendamping,
              title: Text('Cetak gelang pendamping', style: textStyle.blackText),
              subtitle: Text(
                controller.gelangPendamping.value
                    ? 'Setiap tiket playground menghasilkan 2 gelang: anak + pendamping'
                    : 'Pendamping tidak dapat gelang; QR-nya dicetak di struk. '
                        'Nyalakan lagi sebelum outlet beroperasi.',
                style: textStyle.greyText.copyWith(fontSize: fontSize.small),
              ),
            ),
            SizedBox(height: layoutStyle.defaultMargin / 2),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: controller.doSimpanSetelanGelang,
                    icon: const Icon(Icons.save_outlined, size: 18),
                    label: const Text('Simpan Ukuran'),
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: controller.isLoadingTesGelang.value
                        ? null
                        : controller.doTesCetakGelang,
                    icon: const Icon(Icons.print_outlined, size: 18),
                    label: Text(controller.isLoadingTesGelang.value
                        ? 'Mengirim...'
                        : 'Cetak Uji'),
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: controller.isLoadingTesGelang.value
                        ? null
                        : controller.doCetakPenggaris,
                    icon: const Icon(Icons.straighten, size: 18),
                    label: const Text('Cetak Penggaris'),
                  ),
                ),
              ],
            ),
            Text(
              'Geser X mengikuti arah kolom Lebar, Geser Y mengikuti kolom '
              'Tinggi. Boleh negatif. Dipakai untuk menjauhkan cetakan dari '
              'perekat gelang; geseran yang membuat cetakan keluar lembar '
              'dipangkas otomatis.',
              style: textStyle.greyText.copyWith(fontSize: fontSize.small),
            ),
            Text(
              'Cetak penggaris menggambar dua sumbu bernomor (L dan T) dari '
              'sudut awal cetak. Baca angka terakhir yang masih terlihat di '
              'tiap sumbu — itulah ukuran cetak yang sebenarnya, dan sumbu mana '
              'yang menyusuri panjang gelang.',
              style: textStyle.greyText.copyWith(fontSize: fontSize.small),
            ),
            Text(
              'Cetak uji menggambar bingkai tepat di batas margin. Bila '
              'bingkainya terpotong, ukuran media di atas belum cocok dengan '
              'media yang terpasang.',
              style: textStyle.greyText.copyWith(fontSize: fontSize.small),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kotakAngka(String label, TextEditingController controller) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
          onChanged: (v) {
            if (v != null) onPilih(v);
          },
        ),
      ),
    );
  }

  /// Mode simulasi perangkat: printer gelang dan layar pelanggan bisa diuji
  /// tanpa perangkatnya. Ditaruh di menu Setting, bukan disembunyikan di balik
  /// gerakan rahasia, supaya siapa pun di tim bisa menyalakannya sendiri — dan
  /// supaya sama jelasnya saat harus dimatikan lagi.
  Widget _simulasiPerangkat(SettingPageController controller) {
    return Obx(
      () => Container(
        padding: EdgeInsets.all(layoutStyle.defaultMargin / 2),
        decoration: BoxDecoration(
          color: controller.simulatePrinter.value ||
                  controller.simulateCustomerDisplay.value
              ? colorStyle.yellow.withOpacity(0.15)
              : colorStyle.transparent,
          border: Border.all(color: colorStyle.grey.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(layoutStyle.defaultMargin / 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Simulasi Perangkat',
              style: textStyle.blackText.copyWith(fontSize: fontSize.subtitle),
            ),
            Text(
              'Untuk pengembangan tanpa printer & layar pelanggan. '
              'Matikan lagi sebelum dipakai di outlet.',
              style: textStyle.greyText.copyWith(fontSize: fontSize.small),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              value: controller.simulatePrinter.value,
              onChanged: controller.doToggleSimulatePrinter,
              title: Text('Simulasi Printer', style: textStyle.blackText),
              subtitle: Text(
                'Hasil cetak ditangkap, tidak dikirim ke perangkat',
                style: textStyle.greyText.copyWith(fontSize: fontSize.small),
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              value: controller.simulateCustomerDisplay.value,
              onChanged: controller.doToggleSimulateCustomerDisplay,
              title:
                  Text('Simulasi Layar Pelanggan', style: textStyle.blackText),
              subtitle: Text(
                'Layar kedua dibuka sebagai jendela di aplikasi ini',
                style: textStyle.greyText.copyWith(fontSize: fontSize.small),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: controller.doOpenPrintPreview,
                    icon: const Icon(Icons.receipt_long, size: 18),
                    label: const Text('Hasil Cetak'),
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: controller.doOpenCustomerSimulator,
                    icon: const Icon(Icons.desktop_windows, size: 18),
                    label: const Text('Layar Pelanggan'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
