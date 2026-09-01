part of 'main_service.dart';

class PromoService {
  Future<Either<String, BaseResponse<List<PromoEntity>>>> getPromoByLoc({
    required AuthToken authToken,
    // Daftar lokasi siap-kirim, mis. "1,2,5". Memakai endpoint query-param
    // multi-lokasi yang baru; endpoint path-param lama (satu lokasi) ditinggalkan.
    required String locParam,
  }) async {
    var path = "mst_promo/images?locId=$locParam&isActive=Y";

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
