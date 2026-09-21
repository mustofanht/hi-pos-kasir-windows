import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/gate/manual_exit_page_controller.dart';

/// Keluar manual (PRD Poin 5): satu formulir, langsung berlaku.
///
/// Persetujuan supervisor sudah dihapus — begitu operator menekan tombolnya,
/// server menutup sesi tiket saat itu juga. Yang menggantikan kontrol dua orang
/// adalah jejak audit: setiap keluar manual tercatat lengkap (tiket, alasan,
/// catatan, operator, perangkat, IP) dan bisa ditinjau di back-office pada menu
/// Gate > Keluar Manual.
class ManualExitPage extends StatefulWidget {
  const ManualExitPage({super.key});

  @override
  State<ManualExitPage> createState() => _ManualExitPageState();
}

class _ManualExitPageState extends State<ManualExitPage> {
  final _tiketController = TextEditingController();
  final _catatanController = TextEditingController();

  @override
  void dispose() {
    _tiketController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    layoutStyle.init(context);
    final controller = Get.put(ManualExitPageController());

    return Container(
      padding: EdgeInsets.all(layoutStyle.defaultMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tiket Keluar Manual',
              style: textStyle.blackText.copyWith(fontSize: fontSize.header)),
          Text(
            'Untuk pelanggan yang tidak bisa keluar lewat scan. '
            'Langsung berlaku tanpa persetujuan, dan semuanya tercatat.',
            style: textStyle.greyText.copyWith(fontSize: fontSize.small),
          ),
          SizedBox(height: layoutStyle.defaultMargin),
          Expanded(child: _formPengajuan(controller)),
        ],
      ),
    );
  }

  Widget _formPengajuan(ManualExitPageController controller) {
    return Obx(() {
      return SingleChildScrollView(
        // Ruang setinggi keyboard ditambahkan di bawah isi formulir.
        //
        // HomePage memakai `resizeToAvoidBottomInset: false` (keyboard menimpa
        // layar, tidak memampatkannya), jadi tinggi area ini tidak berubah saat
        // keyboard muncul. Tanpa ruang tambahan, isi formulir masih lebih pendek
        // daripada areanya sehingga tidak ada yang bisa digulir sama sekali —
        // kolom Catatan dan tombol Ajukan tertutup keyboard tanpa jalan keluar.
        //
        // Dengan ruang ini formulir menjadi lebih tinggi dari areanya, sehingga
        // bisa digulir, dan Flutter juga bisa menggeser sendiri kolom yang
        // sedang difokuskan ke atas keyboard.
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Keluar Manual',
                style: textStyle.blackText
                    .copyWith(fontSize: fontSize.subtitle, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _tiketController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Nomor Tiket *',
                hintText: 'Ketik atau pindai nomor gelang',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: controller.reasonCode.value,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Alasan *',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              hint: const Text('Pilih alasan...'),
              items: controller.reasons
                  .map((r) => DropdownMenuItem(value: r.code, child: Text(r.label)))
                  .toList(),
              onChanged: (v) => controller.reasonCode.value = v,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _catatanController,
              maxLines: 3,
              maxLength: 200,
              decoration: const InputDecoration(
                labelText: 'Catatan (opsional)',
                hintText: 'mis. tiket basah, 3x scan gagal',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: controller.isProcessing.value
                    ? null
                    : () async {
                        final berhasil = await controller.ajukan(
                          ticketNo: _tiketController.text,
                          catatan: _catatanController.text,
                        );
                        // Formulir hanya dikosongkan kalau tiketnya benar-benar
                        // keluar — kegagalan tidak boleh menghapus isian operator.
                        if (berhasil) {
                          _tiketController.clear();
                          _catatanController.clear();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorStyle.primary,
                  foregroundColor: colorStyle.white,
                ),
                child: Text(controller.isProcessing.value
                    ? 'Memproses...'
                    : 'Proses Keluar Manual'),
              ),
            ),
            const SizedBox(height: 10),
            _tombolCetakUlang(controller, () => _tiketController.text),
          ],
        ),
      );
    });
  }

  /// Cetak ulang QR tiket di printer struk, memakai nomor tiket yang sedang diisi.
  Widget _tombolCetakUlang(
      ManualExitPageController controller, String Function() nomorTiket) {
    return Obx(() => SizedBox(
          width: double.infinity,
          height: 46,
          child: OutlinedButton.icon(
            onPressed: controller.isPrinting.value
                ? null
                : () => controller.cetakUlangTiket(nomorTiket()),
            icon: const Icon(Icons.print_outlined),
            label: Text(controller.isPrinting.value
                ? 'Mencetak...'
                : 'Cetak Ulang Tiket (printer struk)'),
          ),
        ));
  }

}
