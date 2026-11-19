import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/domain/entities/sale/addon_entity.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/jaminansewa/jaminan_sewa_page_controller.dart';

/// Menu "Jaminan Sewa": cash-in uang jaminan saat item sewa dipinjamkan, dan
/// cash-out (pengembalian dana) saat barang kembali dalam kondisi baik.
/// Kedua jenis transaksi wajib tunai dan mencetak struknya sendiri.
class JaminanSewaPage extends GetView<JaminanSewaPageController> {
  const JaminanSewaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const Material(
            color: Colors.white,
            child: TabBar(
              labelColor: Colors.black,
              tabs: [
                Tab(text: 'Terima Jaminan'),
                Tab(text: 'Pengembalian'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _TerimaJaminanTab(controller: controller),
                _PengembalianTab(controller: controller),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TerimaJaminanTab extends StatelessWidget {
  final JaminanSewaPageController controller;

  const _TerimaJaminanTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Item Sewa',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Obx(() {
            if (controller.isLoadingItem.value) {
              return const LinearProgressIndicator();
            }
            if (controller.itemSewaList.isEmpty) {
              // Dropdown Flutter otomatis nonaktif (tidak bisa diklik) saat
              // items kosong -- tanpa pesan ini kasir hanya melihat kotak
              // kosong yang diam saja tanpa tahu sebabnya.
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.orange),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Belum ada item sewa aktif (tipe Sewa Harian/Sewa Perjam) '
                        'di lokasi ini. Tambahkan dulu di Master Produk, lalu '
                        'tarik untuk muat ulang.',
                        style: TextStyle(color: Colors.orange.shade900),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: controller.loadItemSewa,
                    ),
                  ],
                ),
              );
            }
            return DropdownButtonFormField<AddonEntity>(
              value: controller.selectedItem.value,
              isExpanded: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '--Pilih item sewa--',
              ),
              items: controller.itemSewaList
                  .map(
                    (e) => DropdownMenuItem<AddonEntity>(
                      value: e,
                      child: Text(
                        '${e.productName ?? ''}'
                        '${e.productType == 'H' ? ' (Sewa Perjam)' : ' (Sewa Harian)'}',
                      ),
                    ),
                  )
                  .toList(),
              onChanged: controller.pilihItem,
            );
          }),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.qtyController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Qty',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: controller.amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Nominal Jaminan (Rp)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller.customerNameController,
            decoration: const InputDecoration(
              labelText: 'Nama Pelanggan (opsional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller.customerPhoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'No HP Pelanggan (opsional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller.notesController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Catatan (opsional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Jaminan sewa wajib tunai dan tercetak otomatis setelah disimpan.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Obx(
            () => SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: controller.isSubmittingTerima.value
                    ? null
                    : controller.submitTerima,
                child: controller.isSubmittingTerima.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Terima Jaminan & Cetak Struk'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PengembalianTab extends StatelessWidget {
  final JaminanSewaPageController controller;

  const _PengembalianTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: controller.searchController,
            decoration: InputDecoration(
              labelText: 'Cari No. Struk / Nama / No HP',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => controller.doSearch(
                  controller.searchController.text,
                ),
              ),
            ),
            onSubmitted: controller.doSearch,
          ),
        ),
        Expanded(
          child: Obx(
            () {
              if (controller.isLoadingOutstanding.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.outstandingList.isEmpty) {
                return const Center(
                  child: Text('Tidak ada jaminan yang belum dikembalikan.'),
                );
              }
              return ListView.builder(
                itemCount: controller.outstandingList.length,
                itemBuilder: (context, index) {
                  final item = controller.outstandingList[index];
                  final selected =
                      controller.selectedJaminan.value?.jmnNo == item.jmnNo;
                  return Card(
                    color: selected ? Colors.blue.shade50 : null,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    child: ListTile(
                      onTap: () => controller.pilihJaminan(item),
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
            },
          ),
        ),
        Obx(() {
          final jaminan = controller.selectedJaminan.value;
          if (jaminan == null) return const SizedBox.shrink();
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jaminan ${jaminan.jmnNo}: '
                  '${common.currencyFormat(jaminan.amount ?? 0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: controller.refundNotesController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Catatan kondisi barang (opsional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: controller.isSubmittingRefund.value
                        ? null
                        : controller.konfirmasiRefund,
                    child: controller.isSubmittingRefund.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Pengembalian Dana (Cash Out)'),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
