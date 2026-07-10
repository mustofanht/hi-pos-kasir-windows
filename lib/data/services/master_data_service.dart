part of 'main_service.dart';

class MasterDataService {
  Future<Either<String, BaseResponse<List<MstPayment>>>> getAll({
    required AuthToken authToken,
    List<FilterQuery>? dataFilter,
    Map<String, dynamic>? paramsFilter,
  }) async {
    var path = "mst_payment";

    apiFilterUtil.buildQuery(data: dataFilter, params: paramsFilter);

    // logger.safeLog('paramsFilter : ${paramsFilter}');

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

    // logger.responseLog(uri, response);

    if (response.statusCode == 200) {
      BaseResponse<List<MstPayment>> result =
          BaseResponse<List<MstPayment>>.fromJson(
        json.decode(response.body),
        (data) =>
            common.fromJsonList(data, (item) => MstPayment.fromJson(item)),
      );
      return Right(result);
    } else {
      return Left(common.getMetadataMessages(response.body));
    }
  }
} 