part of '../main_service.dart';

class TicketService {
  Future<Either<String, BaseResponse<List<TicketEntity>>>> getAll({
    required AuthToken authToken,
    List<FilterQuery>? dataFilter,
    Map<String, dynamic>? paramsFilter,
  }) async {
    var path = "mst_ticket";

    apiFilterUtil.buildQuery(data: dataFilter, params: paramsFilter);

    final uri =
        source.baseUri(path: path).replace(queryParameters: paramsFilter);

    // logger.safeLog('uri :${uri.toString()}');

    final response = await http.get(
      uri,
      headers: common.generateHeader(
        sessionToken: authToken,
      ),
    );

    logger.responseLog(uri, response);

    if (response.statusCode == 200) {
      BaseResponse<List<TicketEntity>> result =
          BaseResponse<List<TicketEntity>>.fromJson(
        json.decode(response.body),
        (data) =>
            common.fromJsonList(data, (item) => TicketEntity.fromJson(item)),
      );
      return Right(result);
    } else {
      return Left(common.getMetadataMessages(response.body));
    }
  }
}
