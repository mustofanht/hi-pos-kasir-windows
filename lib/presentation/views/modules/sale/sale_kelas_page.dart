import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/domain/entities/sale/kelas_entity.dart';
import 'package:jaya_propertiy/presentation/components/custom_loading.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/sale/sale_cart_page_controller.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/sale/sale_kelas_page_controller.dart';

/// Tab Kelas (on-site, hari ini saja seperti playground). Susunan mengikuti
/// halaman order kelas di website eticketing: kartu berjajar dalam grid sesuai
/// urutan, satu kartu per kelas dengan daftar sesi, status kuota, dan tombol Tambah / − +.
/// Setiap klik langsung masuk keranjang.
class SaleKelasPage extends GetView<SaleKelasPageController> {
  const SaleKelasPage({super.key});

  // Warna mengikuti tema kasir; susunan mengikuti website.
  Color get _utama => colorStyle.primary;
  Color get _headerBg => colorStyle.primary.withOpacity(0.08);
  Color get _cardBg => colorStyle.white;
  Color get _border => colorStyle.primary;
  Color get _hampir => colorStyle.yellow;
  Color get _merah => colorStyle.red;
  Color get _abu => colorStyle.grey;

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
          return label('Selesai', _abu);
        case 'Y':
          return penuh();
        default:
          if (sisa <= 0) return penuh();
          final hampir = sisa <= 3;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              label(hampir ? 'Hampir penuh' : 'Tersedia',
                  hampir ? _hampir : colorStyle.green),
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
              foregroundColor: _utama,
              side: BorderSide(color: onTap == null ? _border : _utama),
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: i > 0
                  ? Border(top: BorderSide(color: colorStyle.lightGrey))
                  : null,
            ),
            // Dua tingkat supaya muat di kartu sempit (grid 2-4 kolom):
            // atas = nama sesi + status, bawah = jam & harga + tombol.
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        sesi.sessionName ?? 'Sesi ${i + 1}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: fontSize.body,
                          fontWeight: FontWeight.w600,
                          color: colorStyle.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    statusSesi(sesi),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${sesi.startTime ?? ''}${sesi.endTime != null ? ' – ${sesi.endTime}' : ''}'
                        '\nRp ${common.currencyFormat(sesi.price ?? 0)}',
                        style: TextStyle(fontSize: fontSize.small, color: _abu),
                      ),
                    ),
                    if (sesi.bisaDijual) ...[
                      if (qty > 0) ...[
                        tombolKecil(Icons.remove, () => controller.kurang(sesi)),
                        SizedBox(
                          width: 26,
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
                          height: 32,
                          child: OutlinedButton(
                            onPressed: () => controller.tambah(kelas, sesi),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _utama,
                              side: BorderSide(color: _utama),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text('Tambah',
                                style: TextStyle(
                                  fontSize: fontSize.small,
                                  fontWeight: FontWeight.w500,
                                )),
                          ),
                        ),
                    ],
                  ],
                ),
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
      final harga =
          kelas.sessions.map((s) => s.price ?? 0).where((p) => p > 0).toList();
      final double mulai =
          harga.isEmpty ? 0.0 : harga.reduce((a, b) => a < b ? a : b);

      return Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: _cardBg,
          border: Border.all(color: _border),
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header kelas: gambar kecil (thumbnail) di samping nama, bukan
            // gambar 16:9 selebar kartu yang membuat kartu terlalu tinggi.
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _headerBg,
                border: Border(bottom: BorderSide(color: _border)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if ((kelas.pathImg ?? '').trim().isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: Image.network(
                          kelas.pathImg!.trim(),
                          fit: BoxFit.cover,
                          cacheWidth: 144,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            color: colorStyle.lightGrey,
                            alignment: Alignment.center,
                            child: Icon(Icons.image_not_supported,
                                size: 18, color: _abu),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(kelas.ticketName ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: fontSize.body,
                              fontWeight: FontWeight.bold,
                              color: _utama,
                            )),
                        if (deskripsi.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              // Ditampilkan utuh (boleh beberapa baris).
                              deskripsi.join(' · ').toUpperCase(),
                              style: TextStyle(fontSize: fontSize.superSmall),
                            ),
                          ),
                        const SizedBox(height: 2),
                        Text(
                          '${(kelas.roomName ?? '').trim().isNotEmpty ? '${kelas.roomName!.trim().toUpperCase()} · ' : ''}'
                          '${kelas.sessions.length} SESI'
                          '${mulai > 0 ? ' · MULAI DARI Rp ${common.currencyFormat(mulai)}' : ''}',
                          style: TextStyle(
                              fontSize: fontSize.superSmall, color: _abu),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (kelas.sessions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
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

    /// Semua kartu kelas dalam satu grid, berjajar kiri ke kanan sesuai
    /// urutan dari server (Urutan di Setup Tiket, lalu jam sesi pertama).
    /// Dulu dikelompokkan per ruangan dan tiap ruangan mulai baris baru,
    /// sehingga satu kelas per ruangan tampil satu kartu selebar halaman.
    Widget gridKelas(List<KelasEntity> daftar, double lebar) {
      // Area produk kasir sempit (ada keranjang di kanan): minimal 2 kolom,
      // kartu ~240 px, maksimal 4 kolom.
      final kolom = (lebar / 240).floor().clamp(2, 4);
      const jarak = 10.0;
      final lebarKartu = (lebar - jarak * (kolom - 1)) / kolom;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              alignment: WrapAlignment.end,
              spacing: 12,
              runSpacing: 4,
              children: [
                legenda('Tersedia', colorStyle.green, _abu),
                legenda('Hampir penuh', _hampir, _abu),
                legenda('Tidak tersedia', _merah, _abu),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: jarak,
            runSpacing: jarak,
            children: daftar
                .map((k) => SizedBox(width: lebarKartu, child: kartuKelas(k)))
                .toList(),
          ),
        ],
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
          return LayoutBuilder(
            builder: (context, c) {
              const pad = 12.0;
              final lebar = c.maxWidth - pad * 2;
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(pad),
                children: [gridKelas(controller.kelasList, lebar)],
              );
            },
          );
        }),
      ),
    );
  }
}
