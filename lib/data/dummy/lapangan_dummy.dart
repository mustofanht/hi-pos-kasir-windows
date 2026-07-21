// ignore_for_file: unnecessary_new

import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/domain/entities/sale/addon_entity.dart';
import 'package:jaya_propertiy/domain/entities/transaction/transaction_entity.dart';

/// Data contekan untuk tab "Booking Lapangan" selama backend belum siap.
///
/// Angkanya mengikuti prototipe pada `design_handoff_booking_lapangan/`.
/// Matikan [enabled] kalau sudah mau memakai data asli dari API
/// (`mst_product/hourly`, `trn_order_addon/transaction-rental-history`,
/// dan `mst_product_time/range`) — tidak ada kode lain yang perlu diubah.
class LapanganDummy {
  /// Saklar tunggal: `true` = pakai data dummy, `false` = pakai API.
  static const bool enabled = true;

  /// Jadwal dibuka jam 06:00, sama dengan SaleLapanganPageController.
  static const int _startHour = 6;

  /// Harga flat semua lapangan, sesuai prototipe.
  static const double hourPrice = 100000;

  /// Nama lapangan beserta index jam yang sudah terisi (0 = 06:00 - 07:00).
  static const List<Map<String, Object>> _courts = [
    {
      'name': 'Lapangan 1 Badminton',
      'booked': [3, 4, 8, 13],
    },
    {
      'name': 'Lapangan 2 Badminton',
      'booked': [0, 1, 6, 7, 15],
    },
    {
      'name': 'Lapangan 3 Badminton',
      'booked': [5, 9, 10, 11, 14, 16],
    },
    {
      'name': 'Lapangan 1 Futsal',
      'booked': [2, 3, 9, 10, 11],
    },
    {
      'name': 'Lapangan 2 Futsal',
      'booked': [6, 7, 14],
    },
    {
      'name': 'Lapangan 1 Padel',
      'booked': [1, 2, 12, 13],
    },
    {
      'name': 'Lapangan 2 Padel',
      'booked': [8, 9, 10],
    },
    {
      'name': 'Lapangan 1 Tenis',
      'booked': [0, 5, 6, 15, 16],
    },
    {
      'name': 'Lapangan 2 Tenis',
      'booked': [3, 4, 11],
    },
    {
      'name': 'Lapangan 1 Basket',
      'booked': [4, 5, 12, 13],
    },
    {
      'name': 'Lapangan 1 Voli',
      'booked': [2, 3, 10, 16],
    },
  ];

  /// Pengganti `mst_product/hourly`. productId dimulai dari 1.
  List<AddonEntity> courtList() {
    return List.generate(_courts.length, (index) {
      return AddonEntity(
        productId: index + 1,
        productName: _courts[index]['name'] as String,
        productType: ProductRentalType.HOURS,
        productPrice: hourPrice,
        productState: 'A',
        minRentPrd: 1,
      );
    });
  }

  /// Pengganti `trn_order_addon/transaction-rental-history`.
  ///
  /// Index jam dibungkus jadi TransactionEntity supaya controller tetap
  /// memakai logika pemetaan slot yang sama dengan data asli nanti.
  List<TransactionEntity> bookedTransactionList(int productId) {
    final index = productId - 1;
    if (index < 0 || index >= _courts.length) return [];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final booked = _courts[index]['booked'] as List<Object>;

    return booked.map((slot) {
      final hour = _startHour + (slot as int);
      return TransactionEntity(
        orderNumber: 'DUMMY-$productId-$slot',
        product: _courts[index]['name'] as String,
        startDate: today.add(Duration(hours: hour)),
        endDate: today.add(Duration(hours: hour + 1)),
        totalHours: 1,
      );
    }).toList();
  }

  /// Pengganti `mst_product_time/range` — harga flat per jam.
  double priceRental({required int hours}) => hours * hourPrice;
}

LapanganDummy lapanganDummy = new LapanganDummy();
