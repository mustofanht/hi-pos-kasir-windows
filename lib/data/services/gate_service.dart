part of 'main_service.dart';

/// Poin 5 (keluar manual) & Poin 9 (takeout).
class GateService {
  // ── Keluar manual ────────────────────────────────────────────────────────

  Future<Either<String, BaseResponse<List<ManualExitReasonEntity>>>> manualExitReasons({
    required AuthToken authToken,
  }) async {
    final uri = source.baseUri(path: 'manual-exit/reasons');
    final response = await http.get(uri, headers: common.generateHeader(sessionToken: authToken));
    logger.responseLog(uri, response);

    if (response.statusCode == 200) {
      return Right(BaseResponse<List<ManualExitReasonEntity>>.fromJson(
        json.decode(response.body),
        (data) => common.fromJsonList(data, (i) => ManualExitReasonEntity.fromJson(i)),
      ));
    }
    return Left(common.getMetadataMessages(response.body));
  }

  Future<Either<String, BaseResponse<ManualExitEntity>>> requestManualExit({
    required AuthToken authToken,
    required String ticketNo,
    required String reasonCode,
    String? notes,
    String? deviceId,
  }) async {
    final uri = source.baseUri(path: 'manual-exit/request');
    final response = await http.post(
      uri,
      headers: common.generateHeader(sessionToken: authToken),
      body: json.encode({
        'ticketNo': ticketNo,
        'reasonCode': reasonCode,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
        if (deviceId != null && deviceId.isNotEmpty) 'deviceId': deviceId,
      }),
    );
    logger.responseLog(uri, response);
    return _satuManualExit(response);
  }

  Future<Either<String, BaseResponse<List<ManualExitEntity>>>> pendingManualExit({
    required AuthToken authToken,
    int? locationId,
  }) async {
    final uri = source.baseUri(
      path: 'manual-exit/pending${locationId != null ? '?locationId=$locationId' : ''}',
    );
    final response = await http.get(uri, headers: common.generateHeader(sessionToken: authToken));
    logger.responseLog(uri, response);

    if (response.statusCode == 200) {
      return Right(BaseResponse<List<ManualExitEntity>>.fromJson(
        json.decode(response.body),
        (data) => common.fromJsonList(data, (i) => ManualExitEntity.fromJson(i)),
      ));
    }
    return Left(common.getMetadataMessages(response.body));
  }

  Future<Either<String, BaseResponse<ManualExitEntity>>> decideManualExit({
    required AuthToken authToken,
    required int requestId,
    required String approvalCode,
    required bool approve,
    String? rejectionReason,
  }) async {
    final uri = source.baseUri(
      path: 'manual-exit/$requestId/${approve ? 'approve' : 'reject'}',
    );
    final response = await http.put(
      uri,
      headers: common.generateHeader(sessionToken: authToken),
      body: json.encode({
        'approvalCode': approvalCode,
        if (rejectionReason != null && rejectionReason.isNotEmpty)
          'rejectionReason': rejectionReason,
      }),
    );
    logger.responseLog(uri, response);
    return _satuManualExit(response);
  }

  // ── TakeOut ──────────────────────────────────────────────────────────────

  Future<Either<String, BaseResponse<List<TakeOutCustomerEntity>>>> activeCustomers({
    required AuthToken authToken,
    int? locationId,
  }) async {
    final uri = source.baseUri(
      path: 'takeout/active${locationId != null ? '?locationId=$locationId' : ''}',
    );
    final response = await http.get(uri, headers: common.generateHeader(sessionToken: authToken));
    logger.responseLog(uri, response);
    return _daftarPelanggan(response);
  }

  Future<Either<String, BaseResponse<List<TakeOutCustomerEntity>>>> searchCustomers({
    required AuthToken authToken,
    required String keyword,
    int? locationId,
  }) async {
    final params = <String, String>{'keyword': keyword};
    if (locationId != null) params['locationId'] = '$locationId';
    final uri = source
        .baseUri(path: 'takeout/search')
        .replace(queryParameters: params);
    final response = await http.get(uri, headers: common.generateHeader(sessionToken: authToken));
    logger.responseLog(uri, response);
    return _daftarPelanggan(response);
  }

  Future<Either<String, BaseResponse<TakeOutResultEntity>>> executeTakeOut({
    required AuthToken authToken,
    required String ticketNo,
    String? reason,
    String? deviceId,
  }) async {
    final uri = source.baseUri(path: 'takeout/execute');
    final response = await http.post(
      uri,
      headers: common.generateHeader(sessionToken: authToken),
      body: json.encode({
        'ticketNo': ticketNo,
        if (reason != null && reason.isNotEmpty) 'reason': reason,
        if (deviceId != null && deviceId.isNotEmpty) 'deviceId': deviceId,
      }),
    );
    logger.responseLog(uri, response);

    if (response.statusCode == 200) {
      return Right(BaseResponse<TakeOutResultEntity>.fromJson(
        json.decode(response.body),
        (data) => TakeOutResultEntity.fromJson(data),
      ));
    }
    return Left(common.getMetadataMessages(response.body));
  }

  // ── Internal ─────────────────────────────────────────────────────────────

  Either<String, BaseResponse<ManualExitEntity>> _satuManualExit(http.Response response) {
    if (response.statusCode == 200) {
      return Right(BaseResponse<ManualExitEntity>.fromJson(
        json.decode(response.body),
        (data) => ManualExitEntity.fromJson(data),
      ));
    }
    return Left(common.getMetadataMessages(response.body));
  }

  Either<String, BaseResponse<List<TakeOutCustomerEntity>>> _daftarPelanggan(
      http.Response response) {
    if (response.statusCode == 200) {
      return Right(BaseResponse<List<TakeOutCustomerEntity>>.fromJson(
        json.decode(response.body),
        (data) => common.fromJsonList(data, (i) => TakeOutCustomerEntity.fromJson(i)),
      ));
    }
    return Left(common.getMetadataMessages(response.body));
  }
}
