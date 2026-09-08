part of 'main_service.dart';

/// Survei kepuasan pelanggan.
///
/// Dipanggil dari layar pelanggan. Pada perangkat dual-screen sungguhan, layar
/// itu berjalan di engine Flutter terpisah dan tidak punya jalur balik ke sisi
/// kasir — jadi pengirimannya memang harus dilakukan dari sana, memakai token
/// yang sama dari penyimpanan sesi.
class SurveyService {
  Future<Either<String, BaseResponse<List<SurveyReasonEntity>>>> getReasons({
    required AuthToken authToken,
  }) async {
    final uri = source.baseUri(path: 'customer-survey/reasons');

    final response = await http.get(
      uri,
      headers: common.generateHeader(sessionToken: authToken),
    );

    logger.responseLog(uri, response);

    if (response.statusCode == 200) {
      BaseResponse<List<SurveyReasonEntity>> result =
          BaseResponse<List<SurveyReasonEntity>>.fromJson(
        json.decode(response.body),
        (data) => common.fromJsonList(
            data, (item) => SurveyReasonEntity.fromJson(item)),
      );
      return Right(result);
    }
    return Left(common.getMetadataMessages(response.body));
  }

  Future<Either<String, BaseResponse<dynamic>>> submit({
    required AuthToken authToken,
    required int locationId,
    required int rating,
    String? reasonCode,
    String? comment,
    String? orderNo,
    String? cashier,
  }) async {
    final uri = source.baseUri(path: 'customer-survey');

    final body = <String, dynamic>{
      'locationId': locationId,
      'rating': rating,
      if (reasonCode != null && reasonCode.isNotEmpty) 'reasonCode': reasonCode,
      if (comment != null && comment.isNotEmpty) 'comment': comment,
      if (orderNo != null && orderNo.isNotEmpty) 'orderNo': orderNo,
      if (cashier != null && cashier.isNotEmpty) 'cashier': cashier,
    };

    final response = await http.post(
      uri,
      headers: common.generateHeader(sessionToken: authToken),
      body: json.encode(body),
    );

    logger.responseLog(uri, response);

    if (response.statusCode == 200) {
      return Right(BaseResponse<dynamic>.fromJson(
        json.decode(response.body),
        (data) => data,
      ));
    }
    return Left(common.getMetadataMessages(response.body));
  }
}
