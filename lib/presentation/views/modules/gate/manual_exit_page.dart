import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/date_time_util.dart';
import 'package:jaya_propertiy/app/utils/constant/date_format_constant.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/domain/entities/gate/gate_entity.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/gate/manual_exit_page_controller.dart';

/// Keluar manual (PRD Poin 5): pengajuan di kiri, antrean persetujuan di kanan.
///
/// Keduanya dalam satu layar dan itu disengaja. Di lapangan operator dan
/// supervisor sering berdiri di meja yang sama; memisahkannya menjadi dua menu
/// hanya menambah langkah tanpa menambah keamanan — pengamanannya ada pada
/// aturan server (role penyetuju, kode, larangan menyetujui permintaan sendiri),
/// bukan pada layar mana yang dibuka.
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
            'Perlu persetujuan, dan semuanya tercatat.',
            style: textStyle.greyText.copyWith(fontSize: fontSize.small),
          ),
          SizedBox(height: layoutStyle.defaultMargin),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _formPengajuan(controller)),
                SizedBox(width: layoutStyle.defaultMargin),
                Expanded(child: _antreanPersetujuan(controller)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _formPengajuan(ManualExitPageController controller) {
    return Obx(() {
      final diajukan = controller.terakhirDiajukan.value;
      if (diajukan != null) {
        return _kartuKode(controller, diajukan);
      }
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('1. Ajukan',
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
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: controller.isProcessing.value
                    ? null
                    : () => controller.ajukan(
                          ticketNo: _tiketController.text,
                          catatan: _catatanController.text,
                        ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorStyle.primary,
                  foregroundColor: colorStyle.white,
                ),
                child: Text(controller.isProcessing.value
                    ? 'Mengirim...'
                    : 'Ajukan Persetujuan'),
              ),
            ),
          ],
        ),
      );
    });
  }

  /// Kode ditampilkan besar karena harus dibacakan lewat radio, dan hitung
  /// mundurnya ada karena permintaan hangus setelah 5 menit.
  Widget _kartuKode(ManualExitPageController controller, ManualExitEntity e) {
    final sisa = controller.sisaDetik.value;
    final menit = (sisa ~/ 60).toString().padLeft(2, '0');
    final detik = (sisa % 60).toString().padLeft(2, '0');
    final habis = sisa <= 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: habis ? colorStyle.lightGrey : colorStyle.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: habis ? colorStyle.grey : colorStyle.primary,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(habis ? 'Permintaan kedaluwarsa' : 'Sebutkan kode ini ke supervisor',
              style: textStyle.blackText.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Center(
            child: Text(
              e.approvalCode ?? '-',
              style: TextStyle(
                fontSize: 44,
                letterSpacing: 8,
                fontWeight: FontWeight.bold,
                color: habis ? colorStyle.grey : colorStyle.primary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              habis ? 'Ajukan ulang bila masih diperlukan' : 'Berlaku $menit:$detik lagi',
              style: textStyle.greyText,
            ),
          ),
          const SizedBox(height: 16),
          Text('Tiket: ${e.ticketNo}', style: textStyle.blackText),
          Text('Alasan: ${e.reasonLabel ?? '-'}', style: textStyle.greyText),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                _tiketController.clear();
                _catatanController.clear();
                controller.bersihkanPengajuan();
              },
              child: const Text('Ajukan yang lain'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _antreanPersetujuan(ManualExitPageController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('2. Menunggu Persetujuan',
                  style: textStyle.blackText.copyWith(
                      fontSize: fontSize.subtitle, fontWeight: FontWeight.bold)),
            ),
            IconButton(
              tooltip: 'Segarkan',
              onPressed: controller.muatPending,
              icon: const Icon(Icons.refresh, size: 20),
            ),
          ],
        ),
        Expanded(
          child: Obx(() {
            if (controller.pending.isEmpty) {
              return Center(
                child: Text('Tidak ada permintaan menunggu',
                    style: textStyle.greyText),
              );
            }
            return ListView.separated(
              itemCount: controller.pending.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _kartuPending(controller, controller.pending[i]),
            );
          }),
        ),
      ],
    );
  }

  Widget _kartuPending(ManualExitPageController controller, ManualExitEntity e) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(e.ticketNo ?? '-',
                style: textStyle.blackText.copyWith(fontWeight: FontWeight.w600)),
            Text('${e.reasonLabel ?? '-'} · diajukan ${e.requestedBy ?? '-'}',
                style: textStyle.greyText.copyWith(fontSize: fontSize.small)),
            if (e.notes != null && e.notes!.isNotEmpty)
              Text(e.notes!,
                  style: textStyle.greyText.copyWith(fontSize: fontSize.superSmall)),
            if (e.requestedDate != null)
              Text(
                dateTimeUtil.getFormattedDate(
                    date: e.requestedDate!, format: dateFormat.onlyTime),
                style: textStyle.greyText.copyWith(fontSize: fontSize.superSmall),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _dialogKeputusan(controller, e, false),
                    child: const Text('Tolak'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _dialogKeputusan(controller, e, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorStyle.green,
                      foregroundColor: colorStyle.white,
                    ),
                    child: const Text('Setujui'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _dialogKeputusan(
      ManualExitPageController controller, ManualExitEntity e, bool setuju) {
    final kodeController = TextEditingController();
    final alasanController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text(setuju ? 'Setujui Keluar Manual' : 'Tolak Permintaan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tiket ${e.ticketNo}', style: textStyle.blackText),
            Text(e.reasonLabel ?? '-', style: textStyle.greyText),
            const SizedBox(height: 12),
            TextField(
              controller: kodeController,
              textCapitalization: TextCapitalization.characters,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'Kode dari operator *',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            if (!setuju)
              TextField(
                controller: alasanController,
                maxLength: 200,
                decoration: const InputDecoration(
                  labelText: 'Alasan penolakan *',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
          ],
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Batal')),
          Obx(() => ElevatedButton(
                onPressed: controller.isProcessing.value
                    ? null
                    : () async {
                        final ok = await controller.putuskan(
                          permintaan: e,
                          kode: kodeController.text,
                          setuju: setuju,
                          alasanTolak: alasanController.text,
                        );
                        if (ok) Get.back();
                      },
                child: Text(setuju ? 'Setujui' : 'Tolak'),
              )),
        ],
      ),
    );
  }
}
