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

  Future<Either<String, BaseResponse<ShiftDetailEntity>>> shiftEnded({
    required AuthToken authToken,
    required String shiftDate,
    required String userId,
  }) async {
    var path = "trn_shift_kasir";

    final uri = source.baseUri(
      path: path,
    );

    var bodyRequest = json.encode({
      'shftDate': shiftDate,
      'shftUserid': userId,
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
