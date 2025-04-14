part of '../main_service.dart';

class OrderTicketService {
  Future<Either<String, BaseResponse<ResponseOrderEntity>>> preCreateOrder({
    required AuthToken authToken,
    required OrderModel body,
    String? check,
  }) async {
    logger.safeLog('reffNo : $check');
    var path = "trn_order/praCreateOrder";
    if (check != null) {
      path += '?check=$check';
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
      var respMsg = json.decode(response.body)['message'];
      return Left(respMsg.toString());
    }
  }

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
      var respMsg = json.decode(response.body)['message'];
      return Left(respMsg.toString());
    }
  }

  Future<Either<String, List<ResponseCreateTicketNoEntity>>> createTicketNo({
    required AuthToken authToken,
    String? reffNo,
    String? reason,
    required String status,
  }) async {
    var path = "trn_order/createTicketNo";
    if (reffNo != null) {
      path += '?orderNo=$reffNo';
    }

    final uri = source.baseUri(path: path);

    var body = json.encode({
      "orderActivationReason": reason,
      // "orderActivationPath": "",
      "orderStatus": status
    });

    logger.safeLog('BODY CREATE TICKET : $body');

    final response = await http.post(
      uri,
      body: body,
      headers: common.generateHeader(
        sessionToken: authToken,
      ),
    );

    logger.responseLog(uri, response);

    if (response.statusCode == 200) {
      List<dynamic> listTicketData =
          json.decode(response.body)['data']['listTicket'];

      List<ResponseCreateTicketNoEntity> result = listTicketData
          .map((e) => ResponseCreateTicketNoEntity.fromJson(e))
          .toList();

      logger.safeLog(result);
      return Right(result);
    } else {
      var err = json.decode(response.body)['error'];
      var msg = json.decode(response.body)['error'];
      return Left(
        common.getMetadataMessages(
          err ?? msg ?? 'Terjadi Kesalahan',
        ),
      );
    }
  }

  Future<Either<String, String>> voidOrder({
    required AuthToken authToken,
    required String orderNo,
    required String voidReason,
  }) async {
    var path = "trn_order/void";
    path += '?orderNo=$orderNo&';
    path += 'voidReason=$voidReason';

    final uri = source.baseUri(path: path);

    final response = await http.post(
      uri,
      headers: common.generateHeader(
        sessionToken: authToken,
      ),
    );

    logger.responseLog(uri, response);

    if (response.statusCode == 200) {
      var msg = json.decode(response.body)['message'];
      return Right(msg ?? 'void pembayaran berhasil');
    } else {
      var err = json.decode(response.body)['error'];
      var msg = json.decode(response.body)['message'];
      return Left(
        common.getMetadataMessages(
          err ?? msg ?? 'Terjadi Kesalahan',
        ),
      );
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

  Future<Either<String, BaseResponse<List<VwOrderEntity>>>> getVwOrderTicket({
    required AuthToken authToken,
    List<FilterQuery>? dataFilter,
    Map<String, dynamic>? paramsFilter,
    String? reffNo,
  }) async {
    var path = "vw_order_ticket";

    apiFilterUtil.buildQuery(
      data: dataFilter,
      params: paramsFilter,
    );

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
      BaseResponse<List<VwOrderEntity>> result =
          BaseResponse<List<VwOrderEntity>>.fromJson(
        bodyData,
        (data) => common.fromJsonList(
          data,
          (item) => VwOrderEntity.fromJson(
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
