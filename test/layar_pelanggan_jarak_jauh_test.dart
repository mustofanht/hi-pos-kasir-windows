import 'package:flutter_test/flutter_test.dart';
import 'package:jaya_propertiy/app/utils/common/layar_pelanggan_jarak_jauh.dart';

List<EventSse> urai(String mentah) {
  final p = PenguraiSse();
  final hasil = <EventSse>[];
  for (final b in mentah.split('\n')) {
    final e = p.baris(b);
    if (e != null) hasil.add(e);
  }
  return hasil;
}

void main() {
  test('event bernama dari Spring SseEmitter', () {
    final e = urai('event:menunggu\ndata:{"kode":"123456"}\n\n'
        'event:data\ndata:{"key":"add-cart","value":{}}\n\n');
    expect(e.map((x) => x.nama), ['menunggu', 'data']);
    expect(e[0].data, '{"kode":"123456"}');
    expect(e[1].data, '{"key":"add-cart","value":{}}');
  });

  test('detak komentar diabaikan dan CRLF ditoleransi', () {
    final e = urai(':ping\n\n:ping\r\n\r\nevent:lepas\r\ndata:{}\r\n\r\n');
    expect(e.length, 1);
    expect(e.single.nama, 'lepas');
    expect(e.single.data, '{}');
  });

  test('data beberapa baris digabung dan spasi setelah titik dua dibuang', () {
    final e = urai('event: data\ndata: {"a":\ndata: 1}\n\n');
    expect(e.single.nama, 'data');
    expect(e.single.data, '{"a":\n1}');
  });

  test('event tanpa nama menjadi message, nama tidak bocor ke event berikutnya', () {
    final e = urai('event:terpasang\ndata:{}\n\ndata:x\n\n');
    expect(e[0].nama, 'terpasang');
    expect(e[1].nama, 'message');
  });
}
