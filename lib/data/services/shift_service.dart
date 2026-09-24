part of 'main_service.dart';

class ShiftService {
  Future<Either<String, ShiftEntity?>> getCurrentShift({
    required AuthToken authToken,
  }) async {
    List<FilterQuery> dataFilter = [];
    Map<String, dynamic> paramsFilter = {
      'page': '0',
      'size': PAGINATIONS_CONSTANT.LIMIT_PAGE.toString(),
      SORTING_CONSTANT.DESC: 'shftStart',
    };

    dataFilter.add(
      apiFilterUtil.addSearch(
        'shftEnd',
        OPERATOR_CONSTANTS.EQUALS,
        OPERATOR_CONSTANTS.IS_NULL,
      )!,
    );
    dataFilter.add(
      apiFilterUtil.addSearch(
        'shftUserid',
        OPERATOR_CONSTANTS.EQUALS,
        sessionUtil.getUserName(),
      )!,
    );

    var path = "trn_shift_kasir";

    apiFilterUtil.buildQuery(data: dataFilter, params: paramsFilter);

    logger.safeLog('paramsFilter : ${paramsFilter}');

    final uri = source
        .baseUri(
          path: path,
        )
        .replace(
          queryParameters: paramsFilter,
        );

    final response = await http.get(
      uri,
      headers: common.generateHeader(
        sessionToken: authToken,
      ),
    );

    logger.responseLog(uri, response);

    if (response.statusCode == 200) {
      BaseResponse<List<ShiftEntity>> result =
          BaseResponse<List<ShiftEntity>>.fromJson(
        json.decode(response.body),
        (data) =>
            common.fromJsonList(data, (item) => ShiftEntity.fromJson(item)),
      );
      if (result.data != null && result.data!.isNotEmpty) {
        return Right(result.data!.first);
      } else {
        return Right(null);
      }
    } else {
      return Left(common.getMetadataMessages(response.body));
    }
  }

  Future<Either<String, BaseResponse<List<ShiftEntity>>>> getAll({
    required AuthToken authToken,
    List<FilterQuery>? dataFilter,
    Map<String, dynamic>? paramsFilter,
  }) async {
    var path = "trn_shift_kasir";

    apiFilterUtil.buildQuery(data: dataFilter, params: paramsFilter);

    logger.safeLog('paramsFilter : ${paramsFilter}');

    final uri = source
        .baseUri(
          path: path,
        )
        .replace(
          queryParameters: paramsFilter,
        );

    final response = await http.get(
      uri,
      headers: common.generateHeader(
        sessionToken: authToken,
      ),
    );

    logger.responseLog(uri, response);

    if (response.statusCode == 200) {
      BaseResponse<List<ShiftEntity>> result =
          BaseResponse<List<ShiftEntity>>.fromJson(
        json.decode(response.body),
        (data) =>
            common.fromJsonList(data, (item) => ShiftEntity.fromJson(item)),
      );
      return Right(result);
    } else {
      return Left(common.getMetadataMessages(response.body));
    }
  }

  Future<Either<String, BaseResponse<ShiftDetailEntity>>> detail({
    required AuthToken authToken,
    required String shiftDate,
    required String userId,
  }) async {
    var path = "trn_shift_kasir/detail";

    final uri = source.baseUri(
      path: path,
    );

    final response = await http.post(
      uri,
      body: json.encode({
        'shftDate': shiftDate,
        'shftUserid': userId,
      }),
      headers: common.generateHeader(
        sessionToken: authToken,
      ),
    );

    logger.responseLog(uri, response);

    if (response.statusCode == 200) {
      BaseResponse<ShiftDetailEntity> result =
          BaseResponse<ShiftDetailEntity>.fromJson(
        json.decode(response.body),
        (data) => ShiftDetailEntity.fromJson(data),
      );
      return Right(result);
    } else {
      return Left(common.getMetadataMessages(response.body));
    }
  }

  /// Keadaan kas shift hari ini: apakah lokasi memakai modal, dan apakah
  /// modalnya sudah diisi.
  ///
  /// Dipanggil setiap kasir membuka menu Penjualan, jadi sengaja ringan —
  /// tidak ikut menjumlahkan tiket, voucher, dan potongan seperti [detail].
  Future<Either<String, ShiftDetailEntity>> getKas({
    required AuthToken authToken,
    required String shiftDate,
    required String userId,
  }) async {
    final uri = source.baseUri(path: "trn_shift_kasir/kas");

    final response = await http.post(
      uri,
      body: json.encode({
        'shftDate': shiftDate,
        'shftUserid': userId,
      }),
      headers: common.generateHeader(sessionToken: authToken),
    );

    logger.responseLog(uri, response);

    if (response.statusCode == 200) {
      BaseResponse<ShiftDetailEntity> result =
          BaseResponse<ShiftDetailEntity>.fromJson(
        json.decode(response.body),
        (data) => ShiftDetailEntity.fromJson(data),
      );
      return Right(result.data ?? ShiftDetailEntity());
    } else {
      return Left(common.getMetadataMessages(response.body));
    }
  }

  /// Menyimpan modal awal yang dihitung kasir saat buka kasir.
  ///
  /// Yang dikirim hanya rincian lembarnya; totalnya dihitung server dari
  /// rincian itu supaya angka yang tersimpan tidak pernah berbeda dengan
  /// lembaran yang dipertanggungjawabkan kasir.
  Future<Either<String, ShiftDetailEntity>> simpanModal({
    required AuthToken authToken,
    required String shiftDate,
    required String userId,
    required Map<int, int> pecahan,
  }) async {
    final uri = source.baseUri(path: "trn_shift_kasir/modal");

    final response = await http.post(
      uri,
      body: json.encode({
        'shftDate': shiftDate,
        'shftUserid': userId,
        'listPecahan': KasUtil.terisi(pecahan)
            .entries
            .map((e) => {'pecahan': e.key, 'lembar': e.value})
            .toList(),
      }),
      headers: common.generateHeader(sessionToken: authToken),
    );

    logger.responseLog(uri, response);

    if (response.statusCode == 200) {
      BaseResponse<ShiftDetailEntity> result =
          BaseResponse<ShiftDetailEntity>.fromJson(
        json.decode(response.body),
        (data) => ShiftDetailEntity.fromJson(data),
      );
      return Right(result.data ?? ShiftDetailEntity());
    } else {
      return Left(common.getMetadataMessages(response.body));
    }
  }

  /// Menutup shift, sekalian menyimpan hitungan laci bila kasir menghitungnya.
  Future<Either<String, BaseResponse<ShiftDetailEntity>>> shiftEnded({
    required AuthToken authToken,
    required String shiftDate,
    required String userId,
    Map<int, int>? pecahanAkhir,
  }) async {
    var path = "trn_shift_kasir";

    final uri = source.baseUri(
      path: path,
    );

    var bodyRequest = json.encode({
      'shftDate': shiftDate,
      'shftUserid': userId,
      if (pecahanAkhir != null)
        'listPecahan': KasUtil.terisi(pecahanAkhir)
            .entries
            .map((e) => {'pecahan': e.key, 'lembar': e.value})
            .toList(),
    });

    logger.safeLog('bodyRequest : $bodyRequest');

    final response = await http.post(
      uri,
      body: bodyRequest,
      headers: common.generateHeader(
        sessionToken: authToken,
      ),
    );

    logger.responseLog(uri, response);

    if (response.statusCode == 200) {
      BaseResponse<ShiftDetailEntity> result =
          BaseResponse<ShiftDetailEntity>.fromJson(
        json.decode(response.body),
        (data) => ShiftDetailEntity.fromJson(data),
      );
      return Right(result);
    } else {
      return Left(common.getMetadataMessages(response.body));
    }
  }
}
