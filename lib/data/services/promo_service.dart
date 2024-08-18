part of 'main_service.dart';

class PromoService {
  Future<Either<String, BaseResponse<List<PromoEntity>>>> getPromoByLoc({
    required AuthToken authToken,
    required int locId,
  }) async {
    var path = "mst_promo/images/$locId/Y";

    final uri = source.baseUri(
      path: path,
    );

    final response = await http.get(
      uri,
      headers: common.generateHeader(
        sessionToken: authToken,
      ),
    );

    logger.responseLog(uri, response);

    if (response.statusCode == 200) {
      BaseResponse<List<PromoEntity>> result =
          BaseResponse<List<PromoEntity>>.fromJson(
        json.decode(response.body),
        (data) =>
            common.fromJsonList(data, (item) => PromoEntity.fromJson(item)),
      );
      return Right(result);
    } else {
      return Left(common.getMetadataMessages(response.body));
    }
  }
}
