import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/date_time_util.dart';
import 'package:jaya_propertiy/app/utils/constant/date_format_constant.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/domain/entities/gate/gate_entity.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/gate/take_out_page_controller.dart';

/// Layar TakeOut / Checkout pelanggan (PRD Poin 9).
class TakeOutPage extends StatefulWidget {
  const TakeOutPage({super.key});

  @override
  State<TakeOutPage> createState() => _TakeOutPageState();
}

class _TakeOutPageState extends State<TakeOutPage> {
  final _cariController = TextEditingController();

  @override
  void dispose() {
    _cariController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    layoutStyle.init(context);
    final controller = Get.put(TakeOutPageController());

    return Container(
      padding: EdgeInsets.all(layoutStyle.defaultMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TakeOut / Checkout Pelanggan',
              style: textStyle.blackText.copyWith(fontSize: fontSize.header)),
          Text(
            'Untuk pelanggan yang pulang sebelum waktunya habis. '
            'Gelangnya langsung hilang dari papan TV.',
            style: textStyle.greyText.copyWith(fontSize: fontSize.small),
          ),
          SizedBox(height: layoutStyle.defaultMargin),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _cariController,
                  decoration: InputDecoration(
                    hintText: 'Cari no tiket / no order / nama...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    isDense: true,
                  ),
                  onSubmitted: controller.cari,
                ),
              ),
              SizedBox(width: layoutStyle.defaultMargin / 2),
              OutlinedButton.icon(
                onPressed: () {
                  _cariController.clear();
                  controller.muatAktif();
                },
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Aktif'),
              ),
            ],
          ),
          SizedBox(height: layoutStyle.defaultMargin / 2),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.daftar.isEmpty) {
                return _kosong(controller.modeCari.value);
              }
              return ListView.separated(
                itemCount: controller.daftar.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) => _kartu(controller, controller.daftar[i]),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _kosong(bool modeCari) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_outline, size: 48, color: colorStyle.grey),
          const SizedBox(height: 8),
          Text(
            modeCari ? 'Tidak ada yang cocok' : 'Belum ada pelanggan aktif',
            style: textStyle.blackText,
          ),
          const SizedBox(height: 4),
          Text(
            modeCari
                ? 'Coba nomor tiket, nomor order, atau nama.'
                : 'Daftar ini berisi gelang yang sedang berjalan di lokasi Anda.',
            textAlign: TextAlign.center,
            style: textStyle.greyText.copyWith(fontSize: fontSize.small),
          ),
        ],
      ),
    );
  }

  Widget _kartu(TakeOutPageController controller, TakeOutCustomerEntity c) {
    final sudah = c.alreadyTakeout;
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        title: Text(c.customerName ?? '(tanpa nama)',
            style: textStyle.blackText.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${c.ticketNo}  ·  ${c.ticketName ?? '-'}',
                style: textStyle.greyText.copyWith(fontSize: fontSize.small)),
            if (c.checkinDate != null)
              Text(
                'Masuk ${dateTimeUtil.getFormattedDate(date: c.checkinDate!, format: dateFormat.onlyTime)}'
                '  ·  terpakai ${formatMenit(c.durationUsed)}'
                '  ·  sisa ${formatMenit(c.durationRemaining)}',
                style: textStyle.greyText.copyWith(fontSize: fontSize.superSmall),
              ),
          ],
        ),
        trailing: sudah
            ? Chip(
                label: Text('Sudah keluar',
                    style: TextStyle(fontSize: fontSize.superSmall)),
                backgroundColor: colorStyle.lightGrey,
              )
            : ElevatedButton(
                onPressed: () => _konfirmasi(controller, c),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorStyle.primary,
                  foregroundColor: colorStyle.white,
                ),
                child: const Text('Checkout'),
              ),
      ),
    );
  }

  /// Konfirmasi menampilkan sisa waktu yang akan hangus. Angka itu satu-satunya
  /// hal yang bisa membuat kasir berhenti sejenak sebelum menekan tombol, dan
  /// checkout tidak bisa dibatalkan.
  void _konfirmasi(TakeOutPageController controller, TakeOutCustomerEntity c) {
    final alasanController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Checkout Pelanggan'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _baris('Nama', c.customerName ?? '-'),
              _baris('Tiket', c.ticketNo ?? '-'),
              _baris('Order', c.orderNo ?? '-'),
              _baris('Jenis', c.ticketName ?? '-'),
              const Divider(),
              _baris('Dibeli', formatMenit(c.durationBooked)),
              _baris('Terpakai', formatMenit(c.durationUsed)),
              _baris('Akan hangus', formatMenit(c.durationRemaining),
                  tebal: true),
              const SizedBox(height: 12),
              TextField(
                controller: alasanController,
                maxLength: 200,
                decoration: const InputDecoration(
                  labelText: 'Alasan (opsional)',
                  hintText: 'mis. anak sudah selesai bermain',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              Text(
                'Checkout tidak bisa dibatalkan.',
                style: TextStyle(fontSize: 11, color: colorStyle.red),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Batal')),
          Obx(() => ElevatedButton(
                onPressed: controller.isProcessing.value
                    ? null
                    : () async {
                        final hasil = await controller.checkout(
                            c.ticketNo!, alasanController.text);
                        Get.back();
                        if (hasil != null) {
                          _hasil(hasil);
                        }
                      },
                child: Text(controller.isProcessing.value
                    ? 'Memproses...'
                    : 'Konfirmasi Checkout'),
              )),
        ],
      ),
    );
  }

  void _hasil(TakeOutResultEntity r) {
    Get.dialog(
      AlertDialog(
        title: const Text('Checkout Berhasil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _baris('Nama', r.customerName ?? '-'),
            _baris('Tiket', r.ticketNo ?? '-'),
            _baris('Terpakai', formatMenit(r.durationUsed)),
            _baris('Tidak terpakai', formatMenit(r.durationUnused)),
            const SizedBox(height: 8),
            Text('Gelang sudah hilang dari papan TV.',
                style: textStyle.greyText.copyWith(fontSize: fontSize.small)),
          ],
        ),
        actions: [
          ElevatedButton(onPressed: Get.back, child: const Text('Selesai')),
        ],
      ),
    );
  }

  Widget _baris(String label, String nilai, {bool tebal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: textStyle.greyText.copyWith(fontSize: fontSize.small)),
          ),
          Expanded(
            child: Text(
              nilai,
              style: textStyle.blackText.copyWith(
                fontSize: fontSize.small,
                fontWeight: tebal ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
