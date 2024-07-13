part of '../main_service.dart';

class VoucherService {
  Future<Either<String, BaseResponse<List<VoucherEntity>>>> getAll({
    required AuthToken authToken,
    List<FilterQuery>? dataFilter,
    Map<String, dynamic>? paramsFilter,
  }) async {
    var path = "mst_voucher";

    apiFilterUtil.buildQuery(data: dataFilter, params: paramsFilter);

    final uri =
        source.baseUri(path: path).replace(queryParameters: paramsFilter);

    final response = await http.get(
      uri,
      headers: common.generateHeader(
        sessionToken: authToken,
      ),
    );

    logger.responseLog(uri, response);

    if (response.statusCode == 200) {
      BaseResponse<List<VoucherEntity>> result =
          BaseResponse<List<VoucherEntity>>.fromJson(
        json.decode(response.body),
        (data) =>
            common.fromJsonList(data, (item) => VoucherEntity.fromJson(item)),
      );

      return Right(result);
    } else {
      return Left(common.getMetadataMessages(response.body));
    }
  }
}
