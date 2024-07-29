part of '../main_service.dart';

class OrderTicketService {
  Future<Either<String, BaseResponse<ResponseOrderEntity>>> createOrder({
    required AuthToken authToken,
    required OrderModel body,
    String? reffNo,
  }) async {
    logger.safeLog('reffNo : $reffNo');
    var path = "trn_order/createOrder";
    if (reffNo != null) {
      path += '?orderNo=$reffNo';
    }

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

  Future<Either<String, BaseResponse<List<ResponseCreateTicketNoEntity>>>>
      createTicketNo({
    required AuthToken authToken,
    String? reffNo,
  }) async {
    var path = "trn_order/createTicketNo";
    if (reffNo != null) {
      path += '?orderNo=$reffNo';
    }

    final uri = source.baseUri(path: path);

    final response = await http.post(
      uri,
      headers: common.generateHeader(
        sessionToken: authToken,
      ),
    );

    logger.responseLog(uri, response);

    if (response.statusCode == 200) {
      BaseResponse<List<ResponseCreateTicketNoEntity>> result =
          BaseResponse<List<ResponseCreateTicketNoEntity>>.fromJson(
        json.decode(response.body),
        (data) => common.fromJsonList(
          data,
          (item) => ResponseCreateTicketNoEntity.fromJson(
            item,
          ),
        ),
      );
      logger.safeLog(result.data!);
      return Right(result);
    } else {
      return Left(common.getMetadataMessages(response.body));
    }
  }

  Future<Either<String, BaseResponse<List<TrnOrderEntity>>>> getAllOrder({
    required AuthToken authToken,
    List<FilterQuery>? dataFilter,
    Map<String, dynamic>? paramsFilter,
    String? reffNo,
  }) async {
    var path = "trn_order";

    apiFilterUtil.buildQuery(
      data: dataFilter,
      params: paramsFilter,
    );

    logger.safeLog('paramsFilter : ${paramsFilter}');

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

    logger.responseLog(uri, response);

    if (response.statusCode == 200) {
      var bodyData = json.decode(response.body);
      BaseResponse<List<TrnOrderEntity>> result =
          BaseResponse<List<TrnOrderEntity>>.fromJson(
        bodyData,
        (data) => common.fromJsonList(
          data,
          (item) => TrnOrderEntity.fromJson(
            item,
          ),
        ),
      );
      return Right(result);
    } else {
      return Left(common.getMetadataMessages(response.body));
    }
  }

  Future<Either<String, BaseResponse<TrnDetailOrderEntity>>> getDetailOrder(
      {required AuthToken authToken, required String? orderNo}) async {
    var path = "trn_order/orderInquiry";

    if (orderNo != null) {
      path += '?numberParam=$orderNo';
    }

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
      var bodyData = json.decode(response.body);
      BaseResponse<TrnDetailOrderEntity> result =
          BaseResponse<TrnDetailOrderEntity>.fromJson(
              bodyData, (data) => TrnDetailOrderEntity.fromJson(data));
      return Right(result);
    } else {
      return Left(common.getMetadataMessages(response.body));
    }
  }
}
