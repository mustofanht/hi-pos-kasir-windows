import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/customer/customer_survey_controller.dart';

/// Panel survei kepuasan di layar pelanggan.
///
/// Dibuat besar dan sedikit: lima wajah, satu baris alasan, satu tombol. Yang
/// mengisi sedang berdiri di depan kasir dengan antrean di belakangnya — setiap
/// isian tambahan menukar satu jawaban yang masuk dengan satu orang yang
/// menyerah di tengah jalan.
class CustomerSurveyPanel extends StatelessWidget {
  const CustomerSurveyPanel({super.key});

  static const List<_Wajah> _wajah = [
    _Wajah(1, '😠', 'Sangat\nkecewa'),
    _Wajah(2, '🙁', 'Kecewa'),
    _Wajah(3, '😐', 'Biasa saja'),
    _Wajah(4, '🙂', 'Puas'),
    _Wajah(5, '😍', 'Sangat\npuas'),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = CustomerSurveyController.instance;
    layoutStyle.init(context);

    return Obx(() {
      if (!controller.tampil.value) return const SizedBox.shrink();

      return Container(
        color: colorStyle.black.withOpacity(0.72),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 720),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: colorStyle.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: controller.selesai.value
                ? _terimaKasih()
                : _pertanyaan(controller),
          ),
        ),
      );
    });
  }

  Widget _terimaKasih() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('🙏', style: TextStyle(fontSize: 56)),
        const SizedBox(height: 12),
        Text(
          'Terima kasih!',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: colorStyle.black,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Masukan Anda membantu kami menjadi lebih baik.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, color: colorStyle.grey),
        ),
      ],
    );
  }

  Widget _pertanyaan(CustomerSurveyController controller) {
    final nilai = controller.rating.value;
    final perluAlasan = nilai != null && nilai <= 3;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Bagaimana pengalaman Anda hari ini?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: colorStyle.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Cukup pilih satu wajah di bawah ini',
          style: TextStyle(fontSize: 14, color: colorStyle.grey),
        ),
        const SizedBox(height: 20),
        // Wrap, bukan Row: lima wajah berdampingan tidak muat di layar sempit,
        // dan Row akan melimpah alih-alih turun baris. Layar pelanggan bisa
        // berupa monitor lebar maupun tablet tegak — keduanya harus jalan.
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: _wajah
              .map((w) => _tombolWajah(controller, w, nilai == w.nilai))
              .toList(),
        ),
        if (perluAlasan) ...[
          const SizedBox(height: 22),
          Divider(color: colorStyle.grey.withOpacity(0.3)),
          const SizedBox(height: 12),
          Text(
            'Mohon maaf. Apa yang paling mengganggu?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colorStyle.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Boleh dilewati',
            style: TextStyle(fontSize: 12, color: colorStyle.grey),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: controller.reasons
                .map((r) => _chipAlasan(
                      controller,
                      r.code,
                      r.label,
                      controller.reasonCode.value == r.code,
                    ))
                .toList(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: controller.mengirim.value ? null : controller.kirim,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorStyle.primary,
                foregroundColor: colorStyle.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                controller.mengirim.value ? 'Mengirim...' : 'Kirim',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
        const SizedBox(height: 10),
        TextButton(
          onPressed: controller.tutup,
          child: Text(
            'Lewati',
            style: TextStyle(fontSize: 14, color: colorStyle.grey),
          ),
        ),
      ],
    );
  }

  Widget _tombolWajah(
    CustomerSurveyController controller,
    _Wajah wajah,
    bool terpilih,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: controller.mengirim.value
          ? null
          : () => controller.pilihNilai(wajah.nilai),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 96,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: terpilih
              ? colorStyle.primary.withOpacity(0.12)
              : colorStyle.transparent,
          border: Border.all(
            color: terpilih ? colorStyle.primary : colorStyle.grey.withOpacity(0.35),
            width: terpilih ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(wajah.emoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 6),
            Text(
              wajah.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                height: 1.2,
                fontWeight: terpilih ? FontWeight.w700 : FontWeight.w400,
                color: terpilih ? colorStyle.primary : colorStyle.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chipAlasan(
    CustomerSurveyController controller,
    String code,
    String label,
    bool terpilih,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => controller.pilihAlasan(code),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: terpilih ? colorStyle.primary : colorStyle.lightGrey,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: terpilih ? FontWeight.w600 : FontWeight.w400,
            color: terpilih ? colorStyle.white : colorStyle.black,
          ),
        ),
      ),
    );
  }
}

class _Wajah {
  final int nilai;
  final String emoji;
  final String label;

  const _Wajah(this.nilai, this.emoji, this.label);
}
