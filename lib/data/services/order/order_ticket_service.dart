part of '../main_service.dart';

class OrderTicketService {
  Future<Either<String, BaseResponse<ResponseOrderEntity>>> createOrder({
    required AuthToken authToken,
    required OrderModel body,
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
      BaseResponse<ResponseOrderEntity> result =
          BaseResponse<ResponseOrderEntity>.fromJson(
        json.decode(response.body),
        (data) => ResponseOrderEntity.fromJson(data),
      );
      logger.safeLog(result.data!.toJson());
      return Right(result);
    } else {
      return Left(common.getMetadataMessages(response.body));
    }
  }
}
