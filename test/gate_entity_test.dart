import 'package:flutter_test/flutter_test.dart';
import 'package:jaya_propertiy/domain/entities/gate/gate_entity.dart';

/// Menguji penanganan waktu pada layar TakeOut & Keluar Manual.
///
/// Bug yang ditangkap di sini nyata dan pernah terlihat di layar: jam masuk
/// tampil 7 jam lebih awal dari kenyataan, sehingga tidak cocok dengan papan TV
/// maupun struk.
void main() {
  group('Waktu dari server', () {
    test('tanggal berzona +07:00 dibaca sebagai waktu setempat, bukan UTC', () {
      final c = TakeOutCustomerEntity.fromJson({
        'ticketNo': '290809260005',
        'checkinDate': '2026-09-08T14:00:00.000+07:00',
      });

      expect(c.checkinDate, isNotNull);
      expect(c.checkinDate!.isUtc, isFalse,
          reason: 'DateTime.parse pada teks berzona menghasilkan objek UTC; '
              'tanpa toLocal(), jam yang ditampilkan meleset sebesar offset');

      // Dibandingkan terhadap saat yang sama, bukan terhadap angka jam tetap —
      // uji ini harus tetap benar di zona waktu mana pun mesin CI berada.
      expect(
        c.checkinDate!.isAtSameMomentAs(
            DateTime.utc(2026, 9, 8, 7, 0)),
        isTrue,
      );
    });

    test('tanggal kosong tetap null, bukan melempar error', () {
      final c = TakeOutCustomerEntity.fromJson({'ticketNo': 'X'});
      expect(c.checkinDate, isNull);
      expect(c.expiredDate, isNull);
      expect(c.takeoutDate, isNull);
    });

    test('tanggal tidak terbaca diperlakukan sebagai kosong', () {
      final c = TakeOutCustomerEntity.fromJson({
        'ticketNo': 'X',
        'checkinDate': 'bukan tanggal',
      });
      expect(c.checkinDate, isNull);
    });

    test('batas waktu permintaan keluar manual juga waktu setempat', () {
      final e = ManualExitEntity.fromJson({
        'requestId': 1,
        'expiresDate': '2026-09-08T14:05:00.000+07:00',
        'requestedDate': '2026-09-08T14:00:00.000+07:00',
      });
      expect(e.expiresDate!.isUtc, isFalse);
      expect(e.requestedDate!.isUtc, isFalse);
      expect(e.expiresDate!.difference(e.requestedDate!).inMinutes, 5);
    });
  });

  group('formatMenit', () {
    test('di bawah satu jam ditulis dalam menit', () {
      expect(formatMenit(0), '0 menit');
      expect(formatMenit(45), '45 menit');
    });

    test('tepat sejam tidak menyertakan sisa menit', () {
      expect(formatMenit(60), '1 jam');
      expect(formatMenit(180), '3 jam');
    });

    test('lebih dari sejam ditulis jam + menit', () {
      expect(formatMenit(75), '1 jam 15 menit');
      expect(formatMenit(200), '3 jam 20 menit');
    });

    test('null ditulis strip, bukan angka palsu', () {
      expect(formatMenit(null), '-');
    });
  });

  group('Kandidat takeout', () {
    test('alreadyTakeout terbaca dari server', () {
      final belum = TakeOutCustomerEntity.fromJson({'ticketNo': 'A'});
      final sudah = TakeOutCustomerEntity.fromJson(
          {'ticketNo': 'B', 'alreadyTakeout': true});
      expect(belum.alreadyTakeout, isFalse);
      expect(sudah.alreadyTakeout, isTrue);
    });
  });

  group('Sisa waktu permintaan', () {
    test('permintaan yang sudah lewat menghasilkan sisa negatif', () {
      final e = ManualExitEntity.fromJson({
        'requestId': 1,
        'expiresDate':
            DateTime.now().subtract(const Duration(minutes: 1)).toIso8601String(),
      });
      expect(e.sisaWaktu.isNegative, isTrue);
    });

    test('tanpa batas waktu dianggap nol, bukan error', () {
      final e = ManualExitEntity.fromJson({'requestId': 1});
      expect(e.sisaWaktu, Duration.zero);
    });
  });
}
