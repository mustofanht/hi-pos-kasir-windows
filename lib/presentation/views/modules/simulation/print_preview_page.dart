import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/date_time_util.dart';
import 'package:jaya_propertiy/app/utils/constant/date_format_constant.dart';
import 'package:jaya_propertiy/app/utils/common/print_capture_util.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/data/models/common/print_capture_model.dart';

/// Hasil cetak yang ditangkap mode simulasi printer.
///
/// Ditampilkan sebagai struk, bukan sebagai daftar byte, karena pertanyaan yang
/// muncul saat mengembangkan selalu berbentuk "apakah nomor tiketnya benar" —
/// bukan "byte ke-40 isinya apa". Byte mentahnya tetap tersimpan sebagai berkas
/// untuk saat pertanyaan itu memang muncul.
class PrintPreviewPage extends StatelessWidget {
  const PrintPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    layoutStyle.init(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorStyle.primary,
        foregroundColor: colorStyle.white,
        title: const Text('Hasil Cetak (Simulasi)'),
        actions: [
          IconButton(
            tooltip: 'Kosongkan daftar',
            onPressed: printCapture.clear,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: Obx(() {
        final items = printCapture.captures;
        if (items.isEmpty) {
          return _kosong();
        }
        return Column(
          children: [
            if (printCapture.folderPath != null)
              Container(
                width: double.infinity,
                color: colorStyle.lightGrey,
                padding: EdgeInsets.all(layoutStyle.defaultMargin / 2),
                child: Text(
                  'Byte mentah disimpan di: ${printCapture.folderPath}',
                  style: TextStyle(fontSize: 11, color: colorStyle.grey),
                ),
              ),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.all(layoutStyle.defaultMargin / 2),
                itemCount: items.length,
                separatorBuilder: (_, __) =>
                    SizedBox(height: layoutStyle.defaultMargin / 2),
                itemBuilder: (_, i) => _kartu(items[i]),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _kosong() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long, size: 48, color: colorStyle.grey),
            const SizedBox(height: 12),
            Text(
              'Belum ada hasil cetak',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorStyle.black,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Nyalakan "Simulasi Printer" di menu Setting, lalu lakukan cetak '
              'seperti biasa. Hasilnya akan muncul di sini tanpa perlu printer.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: colorStyle.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kartu(PrintCaptureModel item) {
    final jam = dateTimeUtil.getFormattedDate(
      date: item.waktu,
      format: dateFormat.dateTime,
    );

    return Card(
      margin: EdgeInsets.zero,
      child: ExpansionTile(
        title: Text(
          item.ringkasan,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '#${item.id} · $jam · ${item.jumlahByte} byte'
          '${item.adaQr ? " · berisi QR" : ""}',
          style: TextStyle(fontSize: 11, color: colorStyle.grey),
        ),
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorStyle.white,
              border: Border.all(color: colorStyle.grey.withOpacity(0.4)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: SelectableText(
              item.baris.join('\n'),
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ),
          if (item.berkas != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: SelectableText(
                'Berkas: ${item.berkas}',
                style: TextStyle(fontSize: 10, color: colorStyle.grey),
              ),
            ),
        ],
      ),
    );
  }
}
