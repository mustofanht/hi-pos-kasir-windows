part of '../main_service.dart';

class AddOnService {
  Future<Either<String, BaseResponse<List<AddonEntity>>>> getAll({
    required AuthToken authToken,
    List<FilterQuery>? dataFilter,
    Map<String, dynamic>? paramsFilter,
  }) async {
    var path = "mst_product";

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
      BaseResponse<List<AddonEntity>> result =
          BaseResponse<List<AddonEntity>>.fromJson(
        json.decode(response.body),
        (data) =>
            common.fromJsonList(data, (item) => AddonEntity.fromJson(item)),
      );
      return Right(result);
    } else {
      return Left(common.getMetadataMessages(response.body));
    }
  }

  Future<Either<String, BaseResponse<List<AddonEntity>>>> getHourly({
    required AuthToken authToken,
    int? locationId,
    int page = 0,
    String? search,
    String? orderBy,
  }) async {
    var path =
        "mst_product/hourly?page=$page&size=${PAGINATIONS_CONSTANT.LIMIT_PAGE.toString()}&";

    if (locationId != null) {
      path += "locationId=$locationId&";
    }
    if (search != null) {
      path += "search=$search&";
    }

    final uri = source.baseUri(path: path);

    final response = await http.get(
      uri,
      headers: common.generateHeader(
        sessionToken: authToken,
      ),
    );

    logger.responseLog(uri, response);

    if (response.statusCode == 200) {
      BaseResponse<List<AddonEntity>> result =
          BaseResponse<List<AddonEntity>>.fromJson(
        json.decode(response.body),
        (data) =>
            common.fromJsonList(data, (item) => AddonEntity.fromJson(item)),
      );
      return Right(result);
    } else {
      return Left(common.getMetadataMessages(response.body));
    }
  }

  Future<Either<String, BaseResponse<Object>>> closedRent({
    required AuthToken authToken,
    int? orderAddId,
  }) async {
    var path = "trn_order_addon/$orderAddId";

    final uri = source.baseUri(path: path);

    final response = await http.post(
      uri,
      headers: common.generateHeader(
        sessionToken: authToken,
      ),
    );

    logger.responseLog(uri, response);

    if (response.statusCode == 200) {
      return Right(json.decode(response.body));
    } else {
      return Left(common.getMetadataMessages(response.body));
    }
  }

  Future<Either<String, BaseResponse<Object>>> cekhour({
    required AuthToken authToken,
    required int orderAddId,
    required String startDate,
    required String endDate,
  }) async {
    var path = "trn_order_addon/cekhour?";

    path += "ordad_addon_id=$orderAddId";
    path += "&startDate=$startDate";
    path += "&endDate=$endDate";

    final uri = source.baseUri(path: path);

    final response = await http.post(
      uri,
      headers: common.generateHeader(
        sessionToken: authToken,
      ),
    );

    logger.responseLog(uri, response);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      final parsedResponse = BaseResponse<Object>.fromJson(
        jsonResponse,
        (data) => data,
      );

      return Right(parsedResponse);
    } else {
      return Left(common.getMetadataMessages(response.body));
    }
  }
}
