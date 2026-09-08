import 'package:get/get.dart';

/// Saluran data layar pelanggan versi simulasi.
///
/// Pada perangkat sungguhan, data dikirim ke layar kedua lewat method channel
/// (`transferDataToPresentation`). Saat disimulasikan, layar kedua itu hanyalah
/// jendela di dalam aplikasi yang sama — jadi datanya cukup dilewatkan lewat
/// saluran ini, dengan bentuk payload yang persis sama.
///
/// Menyamakan bentuk payload itu penting: kalau jendela simulasi menerima data
/// yang sudah "dirapikan" lebih dulu, ia berhenti membuktikan apa pun tentang
/// perangkat aslinya.
class CustomerDisplayBus {
  /// Data terakhir yang dikirim kasir. Diberi pembungkus supaya pengiriman
  /// dengan isi sama tetap terbaca sebagai kejadian baru.
  final terakhir = Rx<CustomerDisplayPayload?>(null);

  int _urutan = 0;

  void push(Object? data) {
    _urutan++;
    terakhir.value = CustomerDisplayPayload(urutan: _urutan, data: data);
  }

  void clear() {
    terakhir.value = null;
  }
}

class CustomerDisplayPayload {
  final int urutan;
  final Object? data;

  CustomerDisplayPayload({required this.urutan, required this.data});
}

CustomerDisplayBus customerDisplayBus = CustomerDisplayBus();
