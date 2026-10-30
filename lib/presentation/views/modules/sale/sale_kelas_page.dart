import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/domain/entities/sale/kelas_entity.dart';
import 'package:jaya_propertiy/presentation/components/custom_loading.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/sale/sale_cart_page_controller.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/sale/sale_kelas_page_controller.dart';

/// Tab Kelas (on-site, hari ini saja seperti playground). Susunan mengikuti
/// halaman order kelas di website eticketing: dikelompokkan per ruangan, satu
/// kartu per kelas dengan daftar sesi, status kuota, dan tombol Tambah / − +.
/// Setiap klik langsung masuk keranjang.
class SaleKelasPage extends GetView<SaleKelasPageController> {
  const SaleKelasPage({super.key});

  // Warna disamakan dengan website eticketing.
  static const _olive = Color(0xFFA19E12);
  static const _headerBg = Color(0xFFE4E1CE);
  static const _cardBg = Color(0xFFFBF8F1);
  static const _border = Color(0xFFD8D3B6);
  static const _sky = Color(0xFF0EA5E9);
  static const _merah = Color(0xFFEF4444);
  static const _abu = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    Widget titik(Color warna) => Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(right: 4),
          decoration: BoxDecoration(color: warna, shape: BoxShape.circle),
        );

    Widget legenda(String label, Color warna, Color teks) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            titik(warna),
            Text(label.toUpperCase(),
                style: TextStyle(fontSize: fontSize.superSmall, color: teks)),
          ],
        );

    Widget statusSesi(KelasSesiEntity sesi) {
      final cap = sesi.capacity ?? 0;
      final sisa = sesi.remaining ?? 0;
      final terisi = (cap - sisa).clamp(0, cap);
      Widget kuota(String teks) => Text(
            'KUOTA $teks',
            style: TextStyle(
              fontSize: fontSize.superSmall,
              fontWeight: FontWeight.w600,
              color: _abu,
            ),
          );
      Widget label(String teks, Color warna) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              titik(warna),
              Text(teks,
                  style: TextStyle(
                    fontSize: fontSize.small,
                    fontWeight: FontWeight.w500,
                    color: warna,
                  )),
            ],
          );
      Widget penuh() => Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [label('Penuh', _merah), kuota('$cap/$cap')],
          );

      switch (sesi.status) {
        case 'B':
          return label('Tidak tersedia', _abu);
        case 'C':
          return label('Selesai', Colors.grey.shade400);
        case 'Y':
          return penuh();
        default:
          if (sisa <= 0) return penuh();
          final hampir = sisa <= 3;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              label(hampir ? 'Hampir penuh' : 'Tersedia',
                  hampir ? _sky : _olive),
              kuota('$terisi/$cap'),
            ],
          );
      }
    }

    Widget tombolKecil(IconData ikon, VoidCallback? onTap) => SizedBox(
          width: 32,
          height: 32,
          child: OutlinedButton(
            onPressed: onTap,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.zero,
              foregroundColor: _olive,
              side: BorderSide(color: onTap == null ? _border : _olive),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
            ),
            child: Icon(ikon, size: 14),
          ),
        );

    Widget barisSesi(KelasEntity kelas, KelasSesiEntity sesi, int i) {
      return GetBuilder<SaleCartPageController>(
        builder: (_) {
          final qty = controller.qtyDiKeranjang(sesi);
          final sisa = sesi.remaining ?? 0;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: i > 0
                  ? const Border(top: BorderSide(color: Color(0xFFEDEBDA)))
                  : null,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sesi.sessionName ?? 'Sesi ${i + 1}',
                        style: TextStyle(
                          fontSize: fontSize.body,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${sesi.startTime ?? ''}${sesi.endTime != null ? ' – ${sesi.endTime}' : ''}'
                        '  ·  Rp ${common.currencyFormat(sesi.price ?? 0)}',
                        style: TextStyle(fontSize: fontSize.small, color: _abu),
                      ),
                    ],
                  ),
                ),
                statusSesi(sesi),
                if (sesi.bisaDijual) ...[
                  const SizedBox(width: 12),
                  if (qty > 0) ...[
                    tombolKecil(Icons.remove, () => controller.kurang(sesi)),
                    SizedBox(
                      width: 28,
                      child: Text(
                        '$qty',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: fontSize.body,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    tombolKecil(
                      Icons.add,
                      qty < sisa ? () => controller.tambah(kelas, sesi) : null,
                    ),
                  ] else
                    SizedBox(
                      height: 36,
                      child: OutlinedButton(
                        onPressed: () => controller.tambah(kelas, sesi),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _olive,
                          side: const BorderSide(color: _olive),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text('Tambah',
                            style: TextStyle(
                              fontSize: fontSize.body,
                              fontWeight: FontWeight.w500,
                            )),
                      ),
                    ),
                ],
              ],
            ),
          );
        },
      );
    }

    Widget kartuKelas(KelasEntity kelas) {
      final deskripsi = (kelas.ticketDesc ?? '')
          .split(',')
          .map((d) => d.trim())
          .where((d) => d.isNotEmpty)
          .toList();
      final harga = kelas.sessions
          .map((s) => s.price ?? 0)
          .where((p) => p > 0)
          .toList();
      final double mulai = harga.isEmpty ? 0.0 : harga.reduce((a, b) => a < b ? a : b);

      return Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: _cardBg,
          border: Border.all(color: _border),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header kelas
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: _headerBg,
                border: Border(bottom: BorderSide(color: _border)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(kelas.ticketName ?? '',
                      style: TextStyle(fontSize: fontSize.subtitle)),
                  if (deskripsi.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        deskripsi.join(' · ').toUpperCase(),
                        style: TextStyle(fontSize: fontSize.superSmall),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${kelas.sessions.length} SESI'
                      '${mulai > 0 ? ' · MULAI DARI Rp ${common.currencyFormat(mulai)}' : ''}',
                      style: TextStyle(fontSize: fontSize.superSmall),
                    ),
                  ),
                ],
              ),
            ),
            if (kelas.sessions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Belum ada sesi.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: fontSize.body, color: _abu),
                ),
              ),
            for (var i = 0; i < kelas.sessions.length; i++)
              barisSesi(kelas, kelas.sessions[i], i),
          ],
        ),
      );
    }

    Widget grupRuangan(
        String ruangan, List<KelasEntity> daftar, bool pertama, double lebar) {
      final kolom = lebar >= 1000 ? 3 : (lebar >= 600 ? 2 : 1);
      const jarak = 16.0;
      final lebarKartu = (lebar - jarak * (kolom - 1)) / kolom;
      return Padding(
        padding: EdgeInsets.only(top: pertama ? 0 : 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header ruangan: judul besar olive + legenda status kuota
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.end,
              spacing: 8,
              runSpacing: 4,
              children: [
                Text(ruangan,
                    style: TextStyle(fontSize: fontSize.header, color: _olive)),
                Wrap(
                  spacing: 12,
                  children: [
                    legenda('Tersedia', _olive, _olive),
                    legenda('Hampir penuh', _sky, Colors.grey.shade600),
                    legenda('Tidak tersedia', _merah, Colors.grey.shade600),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: jarak,
              runSpacing: jarak,
              children: daftar
                  .map((k) => SizedBox(width: lebarKartu, child: kartuKelas(k)))
                  .toList(),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: layoutStyle.screenWidth,
      height: layoutStyle.screenHeight,
      child: RefreshIndicator(
        onRefresh: controller.muat,
        child: Obx(() {
          if (controller.isLoading.value) return loading.simpleLoading();
          if (controller.kelasList.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Padding(
                  padding: EdgeInsets.only(top: layoutStyle.defaultMargin * 4),
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
            );
          }
          // Kelompokkan per ruangan, urutan sesuai data dari server.
          final grup = <String, List<KelasEntity>>{};
          for (final k in controller.kelasList) {
            final r = (k.roomName ?? '').trim();
            grup.putIfAbsent(r.isEmpty ? 'Kelas' : r, () => []).add(k);
          }
          final entri = grup.entries.toList();
          return LayoutBuilder(
            builder: (context, c) {
              const pad = 16.0;
              final lebar = c.maxWidth - pad * 2;
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(pad),
                children: [
                  for (var i = 0; i < entri.length; i++)
                    grupRuangan(entri[i].key, entri[i].value, i == 0, lebar),
                ],
              );
            },
          );
        }),
      ),
    );
  }
}
