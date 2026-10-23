part of 'main_service.dart';

/// Otorisasi leader/SPV atas aksi kasir — cetak ulang struk, cetak tiket di
/// menu Cek Order, dan pemakaian deposit (syspos V136).
///
/// Ketiganya memakai alur yang sama dengan void: ajukan → leader menyetujui di
/// back office → baru boleh dijalankan.
class OtorisasiService {
  /// Mengajukan otorisasi. Permintaan yang masih hidup untuk aksi yang sama
  /// dipakai ulang oleh server, jadi menekan tombolnya dua kali tidak
  /// melahirkan dua izin.
  Future<Either<String, OtorisasiEntity>> ajukan({
    required AuthToken authToken,
    required String jenis,
    required String ref,
    String? keterangan,
    int? locationId,
  }) async {
    final uri = source.baseUri(path: 'otorisasi-kasir/ajukan');
    final response = await http.post(
      uri,
      headers: common.generateHeader(sessionToken: authToken),
      body: json.encode({
        'jenis': jenis,
        'ref': ref,
        if (keterangan != null && keterangan.isNotEmpty) 'keterangan': keterangan,
        if (locationId != null) 'locationId': locationId,
      }),
    );
    logger.responseLog(uri, response);
    return _satu(response);
  }

  /// Keadaan permintaan terakhir milik kasir ini untuk satu aksi.
  ///
  /// Mengembalikan `null` di sisi kanan bila belum pernah mengajukan — itu
  /// BUKAN kegagalan, dan layar harus bisa membedakan keduanya.
  Future<Either<String, OtorisasiEntity?>> periksa({
    required AuthToken authToken,
    required String jenis,
    required String ref,
  }) async {
    final uri = source.baseUri(
      path: 'otorisasi-kasir/periksa'
          '?jenis=${Uri.encodeQueryComponent(jenis)}'
          '&ref=${Uri.encodeQueryComponent(ref)}',
    );
    final response = await http.get(
      uri,
      headers: common.generateHeader(sessionToken: authToken),
    );
    logger.responseLog(uri, response);

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      if (data == null) return const Right(null);
      return Right(OtorisasiEntity.fromJson(data));
    }
    return Left(common.getMetadataMessages(response.body));
  }

  /// Menandai persetujuan sudah dipakai. Dipanggil SESUDAH aksinya berhasil.
  Future<Either<String, OtorisasiEntity>> pakai({
    required AuthToken authToken,
    required int id,
  }) async {
    final uri = source.baseUri(path: 'otorisasi-kasir/$id/pakai');
    final response = await http.post(
      uri,
      headers: common.generateHeader(sessionToken: authToken),
    );
    logger.responseLog(uri, response);
    return _satu(response);
  }

  /// Void milik kasir ini yang belum disetujui leader.
  Future<Either<String, VoidTertundaEntity>> voidTertunda({
    required AuthToken authToken,
  }) async {
    final uri = source.baseUri(path: 'trn_order/void-tertunda');
    final response = await http.get(
      uri,
      headers: common.generateHeader(sessionToken: authToken),
    );
    logger.responseLog(uri, response);

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      return Right(data == null
          ? VoidTertundaEntity()
          : VoidTertundaEntity.fromJson(data));
    }
    return Left(common.getMetadataMessages(response.body));
  }

  Future<Either<String, OtorisasiEntity>> _satu(http.Response response) async {
    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final data = body['data'];
      if (data == null) {
        return Left(body['message']?.toString() ?? 'Terjadi Kesalahan');
      }
      return Right(OtorisasiEntity.fromJson(data));
    }
    return Left(common.getMetadataMessages(response.body));
  }
}
