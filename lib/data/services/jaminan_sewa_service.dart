part of 'main_service.dart';

/// Jaminan sewa item (syspos V159): cash-in saat barang disewakan, cash-out
/// (pengembalian dana) saat barang kembali dalam kondisi baik.
///
/// Sejak V162, Cash-In boleh Tunai/QRIS/EDC — [paymentCode] dikirim dari sini,
/// tapi backend yang memvalidasi kode itu benar-benar aktif di lokasinya.
/// Kosongkan untuk perilaku lama (otomatis tunai). Cash-Out (refund) TETAP
/// wajib tunai, tidak berubah.
class JaminanSewaService {
  Future<Either<String, JaminanSewaEntity>> terima({
    required AuthToken authToken,
    required int locationId,
    required int productId,
    required double qty,
    required double amount,
    String? paymentCode,
    String? paymentRefNo,
    String? customerName,
    String? customerPhone,
    String? notes,
  }) async {
    final uri = source.baseUri(path: 'jaminan-sewa');
    final response = await http.post(
      uri,
      headers: common.generateHeader(sessionToken: authToken),
      body: json.encode({
        'locationId': locationId,
        'productId': productId,
        'qty': qty,
        'amount': amount,
        if (paymentCode != null && paymentCode.trim().isNotEmpty)
          'paymentCode': paymentCode.trim(),
        if (paymentRefNo != null && paymentRefNo.trim().isNotEmpty)
          'paymentRefNo': paymentRefNo.trim(),
        if (customerName != null && customerName.trim().isNotEmpty)
          'customerName': customerName.trim(),
        if (customerPhone != null && customerPhone.trim().isNotEmpty)
          'customerPhone': customerPhone.trim(),
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      }),
    );
    logger.responseLog(uri, response);
    return _satu(response);
  }

  /// Cek status QRIS untuk baris Waiting — dipanggil berulang (polling) sampai
  /// gateway mengonfirmasi lunas (`needsPayment` berubah jadi false).
  Future<Either<String, JaminanSewaEntity>> cekStatusQris({
    required AuthToken authToken,
    required String jmnNo,
  }) async {
    final uri = source
        .baseUri(path: 'jaminan-sewa/${Uri.encodeComponent(jmnNo)}/qris-status');
    final response = await http.post(
      uri,
      headers: common.generateHeader(sessionToken: authToken),
    );
    logger.responseLog(uri, response);
    return _satu(response);
  }

  /// Jaminan yang belum dikembalikan di satu lokasi, untuk layar Pengembalian.
  Future<Either<String, List<JaminanSewaEntity>>> outstanding({
    required AuthToken authToken,
    required int locationId,
    String? search,
  }) async {
    var path = 'jaminan-sewa/outstanding?locationId=$locationId';
    final kata = search?.trim();
    if (kata != null && kata.isNotEmpty) {
      path += '&search=${Uri.encodeQueryComponent(kata)}';
    }
    final uri = source.baseUri(path: path);
    final response = await http.get(
      uri,
      headers: common.generateHeader(sessionToken: authToken),
    );
    logger.responseLog(uri, response);

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      final daftar = data is List ? data : const <dynamic>[];
      return Right(
        daftar.map((e) => JaminanSewaEntity.fromJson(e)).toList(),
      );
    }
    return Left(common.getMetadataMessages(response.body));
  }

  Future<Either<String, JaminanSewaEntity>> detail({
    required AuthToken authToken,
    required String jmnNo,
  }) async {
    final uri =
        source.baseUri(path: 'jaminan-sewa/${Uri.encodeComponent(jmnNo)}');
    final response = await http.get(
      uri,
      headers: common.generateHeader(sessionToken: authToken),
    );
    logger.responseLog(uri, response);
    return _satu(response);
  }

  /// Pengembalian dana (cash-out). Hanya boleh untuk jaminan yang masih outstanding.
  Future<Either<String, JaminanSewaEntity>> refund({
    required AuthToken authToken,
    required String jmnNo,
    String? refundNotes,
  }) async {
    final uri = source
        .baseUri(path: 'jaminan-sewa/${Uri.encodeComponent(jmnNo)}/refund');
    final response = await http.post(
      uri,
      headers: common.generateHeader(sessionToken: authToken),
      body: json.encode({
        if (refundNotes != null && refundNotes.trim().isNotEmpty)
          'refundNotes': refundNotes.trim(),
      }),
    );
    logger.responseLog(uri, response);
    return _satu(response);
  }

  Either<String, JaminanSewaEntity> _satu(http.Response response) {
    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final data = body['data'];
      if (data == null) {
        return Left(body['message']?.toString() ?? 'Terjadi Kesalahan');
      }
      return Right(JaminanSewaEntity.fromJson(data));
    }
    return Left(common.getMetadataMessages(response.body));
  }
}
