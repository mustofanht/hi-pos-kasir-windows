import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:jaya_propertiy/app/utils/common/local_storage_util.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/common/session_util.dart';
import 'package:jaya_propertiy/data/resources/network_source.dart';
import 'package:jaya_propertiy/domain/entities/survey/survey_reason_entity.dart';

/// Layar pelanggan di **perangkat terpisah** (tablet Android / PC Windows),
/// direlai lewat server syspos (V165).
///
/// Dua sisi, dua kelas:
/// - [LayarPelangganKasir] — di perangkat kasir yang login. Memasangkan tablet
///   dengan kode 6 angka yang tampil di tablet, lalu mengirim setiap pembaruan
///   layar ke server.
/// - [LayarPelangganPerangkat] — di perangkat pelanggan, tanpa login. Meminta
///   kode pairing, lalu mendengarkan server lewat SSE.
///
/// Muatannya persis sama dengan jalur layar kedua (Presentation Android /
/// jendela kedua Windows): `CustomerDisplay.toJson()` atau string seperti
/// `refreshAds`. Halaman pelanggan tidak perlu tahu datanya lewat jalur mana.
///
/// Setelan disimpan di kotak `perangkat`, bukan `sessions`: kotak sesi
/// dihapus setiap logout, padahal pemasangan tablet harus tetap ada.

const String _kotak = 'perangkat';

/// Aksi khusus jalur jarak jauh: daftar alamat gambar iklan.
///
/// Tablet tidak login, jadi tidak bisa mengambil iklan lokasinya sendiri;
/// kasir yang mengirim alamatnya dan tablet mengunduhnya. Tidak dikirim lewat
/// layar kedua karena engine itu berbagi folder dengan kasir — kasir sudah
/// mengunduhnya ke sana.
const String aksiPromoJarakJauh = 'promo-jarak-jauh';

// =====================================================================
// Sisi kasir
// =====================================================================

class LayarPelangganKasir {
  static const _kunciId = 'lpj_kasir_id';
  static const _kunciNama = 'lpj_kasir_nama';
  static const _kunciPromo = 'lpj_kasir_promo';

  final GetStorage _store = GetStorage(_kotak);

  /// Antrean kiriman: urutan keranjang harus sampai di tablet sesuai urutan.
  Future<void> _antrean = Future.value();

  int? get lpId {
    final v = _store.read(_kunciId);
    return v is int ? v : int.tryParse('${v ?? ''}');
  }

  String? get namaLayar => _store.read(_kunciNama)?.toString();

  bool get terpasang => lpId != null;

  Map<String, String>? _header() {
    try {
      final token = sessionUtil.getToken().token;
      if (token == null || token.isEmpty) return null;
      return {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };
    } catch (_) {
      // Belum login: sesi kosong.
      return null;
    }
  }

  /// Pasangkan tablet. Mengembalikan pesan gagal, atau `null` bila berhasil.
  Future<String?> klaim(String kode) async {
    final header = _header();
    final locId = sessionUtil.getLocationId();
    if (header == null || locId == null) return 'Login dulu sebelum memasangkan layar pelanggan';
    String label;
    try {
      label = '${sessionUtil.getUserName()} (${Platform.operatingSystem})';
    } catch (_) {
      label = Platform.operatingSystem;
    }
    try {
      final res = await http
          .post(
            source.baseUri(path: 'layar-pelanggan/klaim'),
            headers: header,
            body: jsonEncode({'kode': kode.trim(), 'locId': locId, 'kasirLabel': label}),
          )
          .timeout(const Duration(seconds: 15));
      final isi = _json(res.body);
      if (res.statusCode != 200) return _pesan(isi) ?? 'Gagal memasangkan (${res.statusCode})';
      final data = isi is Map ? isi['data'] : null;
      if (data is! Map || data['lpId'] == null) return 'Balasan server tidak dikenal';
      await _store.write(_kunciId, data['lpId']);
      await _store.write(_kunciNama, data['nama']?.toString() ?? 'Layar pelanggan');
      return null;
    } catch (e) {
      logger.safeLog('LAYAR JAUH klaim gagal : $e');
      return 'Server tidak bisa dihubungi';
    }
  }

  /// Status pemasangan di server: jumlah koneksi tablet yang sedang terbuka,
  /// `null` bila tidak bisa diperiksa, `-1` bila sudah dilepas.
  Future<int?> cekOnline() async {
    final id = lpId;
    final header = _header();
    if (id == null || header == null) return null;
    try {
      final res = await http
          .get(source.baseUri(path: 'layar-pelanggan/$id'), headers: header)
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 404) {
        await lupakan();
        return -1;
      }
      final data = (_json(res.body) as Map?)?['data'];
      return data is Map ? (data['online'] as num?)?.toInt() : null;
    } catch (_) {
      return null;
    }
  }

  Future<String?> lepas() async {
    final id = lpId;
    final header = _header();
    if (id == null) return null;
    if (header != null) {
      try {
        final res = await http
            .delete(source.baseUri(path: 'layar-pelanggan/$id'), headers: header)
            .timeout(const Duration(seconds: 10));
        if (res.statusCode != 200 && res.statusCode != 404) {
          return _pesan(_json(res.body)) ?? 'Gagal melepas (${res.statusCode})';
        }
      } catch (e) {
        return 'Server tidak bisa dihubungi';
      }
    }
    await lupakan();
    return null;
  }

  Future<void> lupakan() async {
    await _store.remove(_kunciId);
    await _store.remove(_kunciNama);
  }

  /// Kirim satu pembaruan layar. Tidak pernah melempar dan tidak perlu
  /// ditunggu: kasir tidak boleh tertahan karena tablet atau jaringan.
  Future<void> kirim(Object? data) {
    if (data == null || !terpasang) return Future.value();
    final String muatan;
    try {
      muatan = jsonEncode(data);
    } catch (e) {
      logger.safeLog('LAYAR JAUH muatan tidak bisa dikirim : $e');
      return Future.value();
    }
    _antrean = _antrean.then((_) => _kirimSekarang(muatan));
    return _antrean;
  }

  Future<void> _kirimSekarang(String muatan) async {
    final id = lpId;
    final header = _header();
    if (id == null || header == null) return;
    try {
      final res = await http
          .post(source.baseUri(path: 'layar-pelanggan/$id/kirim'), headers: header, body: muatan)
          .timeout(const Duration(seconds: 8));
      if (res.statusCode == 404) {
        // Dilepas dari back office atau dari tablet: berhenti mengirim.
        logger.safeLog('LAYAR JAUH sudah dilepas, pemasangan dilupakan');
        await lupakan();
      } else if (res.statusCode != 200) {
        logger.safeLog('LAYAR JAUH kirim gagal ${res.statusCode} : ${res.body}');
      }
    } catch (e) {
      logger.safeLog('LAYAR JAUH kirim gagal : $e');
    }
  }

  /// Simpan alamat iklan lokasi (dipanggil setiap kasir menyegarkan iklan),
  /// lalu kirim ke tablet.
  Future<void> simpanDanKirimPromo(List<String> alamat) async {
    await _store.write(_kunciPromo, alamat);
    await kirimPromo();
  }

  Future<void> kirimPromo() async {
    final v = _store.read(_kunciPromo);
    if (v is! List) return;
    await kirim({
      'key': aksiPromoJarakJauh,
      'value': {'gambar': v.map((e) => e.toString()).toList()},
    });
  }
}

LayarPelangganKasir layarPelangganKasir = LayarPelangganKasir();

// =====================================================================
// Sisi perangkat pelanggan
// =====================================================================

enum StatusLayarJauh { mulai, memintaKode, menunggu, terpasang, terputus }

/// Satu event SSE.
class EventSse {
  final String nama;
  final String data;
  const EventSse(this.nama, this.data);

  @override
  String toString() => 'EventSse($nama, $data)';
}

/// Pengurai baris SSE (`event:` / `data:` / baris kosong / `:komentar`).
class PenguraiSse {
  String _nama = 'message';
  final List<String> _data = [];

  /// Masukkan satu baris; mengembalikan event bila baris itu menutupnya.
  EventSse? baris(String b) {
    if (b.endsWith('\r')) b = b.substring(0, b.length - 1);
    if (b.isEmpty) {
      if (_data.isEmpty) {
        _nama = 'message';
        return null;
      }
      final e = EventSse(_nama, _data.join('\n'));
      _nama = 'message';
      _data.clear();
      return e;
    }
    if (b.startsWith(':')) return null;
    final i = b.indexOf(':');
    final kolom = i < 0 ? b : b.substring(0, i);
    var nilai = i < 0 ? '' : b.substring(i + 1);
    if (nilai.startsWith(' ')) nilai = nilai.substring(1);
    if (kolom == 'event') {
      _nama = nilai;
    } else if (kolom == 'data') {
      _data.add(nilai);
    }
    return null;
  }
}

class LayarPelangganPerangkat {
  static const _kunciPeran = 'lpj_peran';
  static const _kunciToken = 'lpj_token';
  static const _kunciNama = 'lpj_nama';
  static const _header = 'X-Layar-Token';

  /// Tanpa satu baris pun (termasuk detak 25 detik) selama ini, koneksi
  /// dianggap mati dan dibuka ulang.
  static const _batasSepi = Duration(seconds: 70);

  final GetStorage _store = GetStorage(_kotak);

  final status = StatusLayarJauh.mulai.obs;
  final kode = RxnString();
  final berlakuSampai = Rxn<DateTime>();
  final namaLokasi = RxnString();
  final pesan = RxnString();

  bool _jalan = false;
  // Naik setiap mulai(): putaran lama yang masih menunggu jeda/HTTP berhenti
  // sendiri, jadi tidak pernah ada dua putaran sekaligus.
  int _generasi = 0;
  http.Client? _klien;
  int _gagalBeruntun = 0;

  void Function(Object? data)? _penerima;
  final List<Object?> _tertunda = [];

  bool get modeAktif => _store.read(_kunciPeran) == 'pelanggan';

  String? get _token => _store.read(_kunciToken)?.toString();

  String get namaPerangkat =>
      _store.read(_kunciNama)?.toString() ??
      (Platform.isWindows ? 'PC Layar Pelanggan' : 'Tablet Layar Pelanggan');

  Future<void> aktifkan({String? nama}) async {
    await _store.write(_kunciPeran, 'pelanggan');
    if (nama != null && nama.trim().isNotEmpty) {
      await _store.write(_kunciNama, nama.trim());
    }
  }

  /// Keluar dari mode layar pelanggan. Pemasangannya ikut dilepas di server
  /// supaya kasir tidak terus mengirim ke perangkat yang sudah bukan layar.
  Future<void> nonaktifkan() async {
    berhenti();
    final token = _token;
    // Dihapus dulu sebelum memanggil server: pemanggil tidak menunggu fungsi
    // ini, dan perangkat bisa langsung dijadikan layar lagi dari login.
    await _store.remove(_kunciToken);
    await _store.remove(_kunciPeran);
    kode.value = null;
    status.value = StatusLayarJauh.mulai;
    if (token != null) {
      try {
        await http
            .post(source.baseUri(path: 'layar-pelanggan/perangkat/lepas'), headers: {_header: token})
            .timeout(const Duration(seconds: 8));
      } catch (_) {
        // Tetap keluar walau server tak terjangkau.
      }
    }
  }

  /// Halaman pelanggan mendaftarkan diri sebagai penerima. Kiriman yang datang
  /// sebelum halaman siap (mis. putar ulang tepat setelah terpasang) disimpan
  /// dulu lalu diserahkan sekarang.
  void pasangPenerima(void Function(Object? data) penerima) {
    _penerima = penerima;
    final antre = List<Object?>.from(_tertunda);
    _tertunda.clear();
    for (final d in antre) {
      penerima(d);
    }
  }

  void lepasPenerima() => _penerima = null;

  void mulai() {
    if (_jalan) return;
    _jalan = true;
    _putaran(++_generasi);
  }

  void berhenti() {
    _jalan = false;
    _klien?.close();
    _klien = null;
  }

  Future<void> _putaran(int gen) async {
    bool aktif() => _jalan && gen == _generasi;
    while (aktif()) {
      if (_token == null) {
        final ok = await _mintaKode();
        if (!aktif()) break;
        if (!ok) {
          await _jeda();
          continue;
        }
      }
      await _dengarkan();
      if (!aktif()) break;
      if (status.value == StatusLayarJauh.terpasang) {
        status.value = StatusLayarJauh.terputus;
      }
      await _jeda();
    }
  }

  Future<void> _jeda() async {
    _gagalBeruntun = (_gagalBeruntun + 1).clamp(1, 6);
    // 2, 4, 8, ... maksimal 30 detik.
    final detik = (1 << _gagalBeruntun).clamp(2, 30);
    await Future.delayed(Duration(seconds: detik));
  }

  Future<bool> _mintaKode() async {
    status.value = StatusLayarJauh.memintaKode;
    try {
      final res = await http
          .post(
            source.baseUri(path: 'layar-pelanggan/perangkat/daftar'),
            headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
            body: jsonEncode({'nama': namaPerangkat, 'platform': Platform.operatingSystem}),
          )
          .timeout(const Duration(seconds: 15));
      final isi = _json(res.body);
      final data = isi is Map ? isi['data'] : null;
      if (res.statusCode != 200 || data is! Map || data['token'] == null) {
        pesan.value = _pesan(isi) ?? 'Gagal meminta kode (${res.statusCode})';
        return false;
      }
      await _store.write(_kunciToken, data['token'].toString());
      kode.value = data['kode']?.toString();
      berlakuSampai.value = DateTime.tryParse(data['berlakuSampai']?.toString() ?? '');
      pesan.value = null;
      // Kode sudah di tangan: tampilkan sekarang, jangan menunggu event
      // 'menunggu' dari SSE (bisa tertahan buffer proxy).
      if (kode.value != null) status.value = StatusLayarJauh.menunggu;
      return true;
    } catch (e) {
      pesan.value = 'Server tidak bisa dihubungi. Periksa internet perangkat ini.';
      return false;
    }
  }

  Future<void> _dengarkan() async {
    final token = _token;
    if (token == null) return;
    final klien = http.Client();
    _klien = klien;
    try {
      final req = http.Request('GET', source.baseUri(path: 'layar-pelanggan/perangkat/stream'))
        ..headers[_header] = token
        ..headers['Accept'] = 'text/event-stream'
        ..headers['Cache-Control'] = 'no-cache';
      final res = await klien.send(req).timeout(const Duration(seconds: 20));
      if (res.statusCode != 200) {
        pesan.value = 'Server menolak sambungan (${res.statusCode})';
        return;
      }
      final pengurai = PenguraiSse();
      await for (final b in res.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .timeout(_batasSepi)) {
        if (!_jalan) break;
        final e = pengurai.baris(b);
        if (e != null) _tangani(e);
      }
    } catch (e) {
      logger.safeLog('LAYAR JAUH sambungan putus : $e');
    } finally {
      klien.close();
      if (identical(_klien, klien)) _klien = null;
    }
  }

  void _tangani(EventSse e) {
    switch (e.nama) {
      case 'menunggu':
        final isi = _json(e.data);
        if (isi is Map) {
          kode.value = isi['kode']?.toString() ?? kode.value;
          berlakuSampai.value = DateTime.tryParse(isi['berlakuSampai']?.toString() ?? '') ?? berlakuSampai.value;
        }
        status.value = StatusLayarJauh.menunggu;
        _gagalBeruntun = 0;
        break;
      case 'terpasang':
        final isi = _json(e.data);
        if (isi is Map) namaLokasi.value = isi['locName']?.toString();
        kode.value = null;
        pesan.value = null;
        status.value = StatusLayarJauh.terpasang;
        _gagalBeruntun = 0;
        break;
      case 'data':
        final isi = _json(e.data);
        if (isi == null) return;
        final p = _penerima;
        if (p == null) {
          _tertunda.add(isi);
          if (_tertunda.length > 20) _tertunda.removeAt(0);
        } else {
          p(isi);
        }
        break;
      case 'lepas':
      case 'ditolak':
        final isi = _json(e.data);
        pesan.value = e.nama == 'lepas'
            ? 'Layar ini dilepas dari kasir. Pasangkan ulang dengan kode baru.'
            : (isi is Map ? isi['pesan']?.toString() : null);
        _store.remove(_kunciToken);
        kode.value = null;
        status.value = StatusLayarJauh.memintaKode;
        _gagalBeruntun = 0;
        _klien?.close();
        break;
    }
  }

  // ------------------------------------------------------------ survei

  Future<List<SurveyReasonEntity>> alasanSurvei() async {
    final token = _token;
    if (token == null) return [];
    try {
      final res = await http
          .get(source.baseUri(path: 'layar-pelanggan/perangkat/survei/alasan'),
              headers: {_header: token, 'Accept': 'application/json'})
          .timeout(const Duration(seconds: 10));
      final data = (_json(res.body) as Map?)?['data'];
      if (res.statusCode != 200 || data is! List) return [];
      return data
          .whereType<Map>()
          .map((m) => SurveyReasonEntity.fromJson(Map<String, dynamic>.from(m)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Lokasi diisi server dari pemasangan, jadi tidak dikirim dari sini.
  Future<bool> kirimSurvei({
    required int rating,
    String? reasonCode,
    String? comment,
    String? orderNo,
    String? cashier,
  }) async {
    final token = _token;
    if (token == null) return false;
    try {
      final res = await http
          .post(
            source.baseUri(path: 'layar-pelanggan/perangkat/survei'),
            headers: {_header: token, 'Content-Type': 'application/json', 'Accept': 'application/json'},
            body: jsonEncode({
              // Wajib menurut validasi; nilainya diganti server.
              'locationId': 0,
              'rating': rating,
              if (reasonCode != null && reasonCode.isNotEmpty) 'reasonCode': reasonCode,
              if (comment != null && comment.isNotEmpty) 'comment': comment,
              if (orderNo != null && orderNo.isNotEmpty) 'orderNo': orderNo,
              if (cashier != null && cashier.isNotEmpty) 'cashier': cashier,
            }),
          )
          .timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) logger.safeLog('SURVEI tablet gagal ${res.statusCode} : ${res.body}');
      return res.statusCode == 200;
    } catch (e) {
      logger.safeLog('SURVEI tablet gagal : $e');
      return false;
    }
  }

  // ------------------------------------------------------------ iklan

  /// Unduh ulang gambar iklan dari daftar alamat yang dikirim kasir.
  Future<void> simpanPromo(List<String> alamat) async {
    try {
      final folder = await localStorage.deleteDirPromo();
      for (final a in alamat) {
        await localStorage.downloadAndSaveImagePromo(a, folder);
      }
    } catch (e) {
      logger.safeLog('LAYAR JAUH gagal mengunduh iklan : $e');
    }
  }
}

LayarPelangganPerangkat layarPelangganPerangkat = LayarPelangganPerangkat();

Object? _json(String s) {
  try {
    return jsonDecode(s);
  } catch (_) {
    return null;
  }
}

String? _pesan(Object? isi) {
  if (isi is Map) {
    final m = isi['message'] ?? isi['messages'] ?? isi['error'];
    if (m is List) return m.isNotEmpty ? m.first.toString() : null;
    if (m != null && m.toString().isNotEmpty) return m.toString();
  }
  return null;
}
