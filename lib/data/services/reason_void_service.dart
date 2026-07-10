part of 'main_service.dart';

class ReasonVoidService {

  Future<Either<String, BaseResponse<List<ReasonVoidEntity>>>> getAll({
    required AuthToken authToken,
    List<FilterQuery>? dataFilter,
    Map<String, dynamic>? paramsFilter,
  }) async {
    var path = "mst_reason_void";

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
      BaseResponse<List<ReasonVoidEntity>> result =
          BaseResponse<List<ReasonVoidEntity>>.fromJson(
        json.decode(response.body),
        (data) =>
            common.fromJsonList(data, (item) => ReasonVoidEntity.fromJson(item)),
      );
      return Right(result);
    } else {
      return Left(common.getMetadataMessages(response.body));
    }
  }
}