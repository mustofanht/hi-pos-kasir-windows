part of '../main_service.dart';

class PaymentOrderSercvice {
  Future<Either<String, BaseResponse<ResponsePaymentEntity>>> payment({
    required AuthToken authToken,
    required PaymentModel body,
  }) async {
    var path = "trn_order/createOrder";

    final uri = source.baseUri(path: path);

    logger.safeLog('BODY : ${json.encode(body.toJson())}');

    final response = await http.post(
      uri,
      body: json.encode(body.toJson()),
      headers: common.generateHeader(
        sessionToken: authToken,
      ),
    );

    logger.responseLog(uri, response);

    if (response.statusCode == 200) {
      BaseResponse<ResponsePaymentEntity> result =
          BaseResponse<ResponsePaymentEntity>.fromJson(
        json.decode(response.body),
        (data) => ResponsePaymentEntity.fromJson(data),
      );
      logger.safeLog(result.data!.toJson());
      return Right(result);
    } else {
      return Left(common.getMetadataMessages(response.body));
    }
  }
}
