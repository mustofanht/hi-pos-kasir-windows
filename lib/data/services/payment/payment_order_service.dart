part of '../main_service.dart';

class PaymentOrderSercvice {
  Future<Either<String, BaseResponse<ResponseCekPaymentEntity>>> cekPaymnet({
    required AuthToken authToken,
    required String orderNo,
  }) async {
    var path = "trn_payment/$orderNo";

    final uri = source.baseUri(path: path);

    final response = await http.get(
      uri,
      headers: common.generateHeader(
        sessionToken: authToken,
      ),
    );

    logger.responseLog(uri, response);

    if (response.statusCode == 200) {
      BaseResponse<ResponseCekPaymentEntity> result =
          BaseResponse<ResponseCekPaymentEntity>.fromJson(
        json.decode(response.body),
        (data) => ResponseCekPaymentEntity.fromJson(data),
      );
      logger.safeLog(result.data!.toJson());
      return Right(result);
    } else {
      return Left(common.getMetadataMessages(response.body));
    }
  }
}
