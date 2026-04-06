part of 'main_service.dart';

class MessageService {
  Future<Either<String, bool>> sendWa({
    required AuthToken authToken,
    required String orderNo,
    required int phoneNumber,
    String? message,
  }) async {
    var path = "trn_order/buktipembayaran";
    var body = {
      "orderNo": orderNo,
      "typeSender": "WA",
      "sendTo": phoneNumber
    };
    logger.safeLog('body : $body');
    final uri = source.baseUri(path: path);
    final response = await http.post(
      uri,
      body: json.encode(body),
      headers: common.generateHeader(
        sessionToken: authToken,
      ),
    );
    logger.responseLog(uri, response);
    if (response.statusCode == 200) {
      return const Right(true);
    } else {
      return Left(common.getMetadataMessages(response.body));
    }
  }

  Future<Either<String, bool>> sendEmail({
    required AuthToken authToken,
    required String orderNo,
    required String mailTo,
    String? message,
  }) async {
    var path = "trn_order/buktipembayaran";
    var body = {"orderNo": orderNo, "typeSender": "EMAIL", "sendTo": mailTo};
    logger.safeLog('body : $body');
    final uri = source.baseUri(path: path);
    final response = await http.post(
      uri,
      body: json.encode(body),
      headers: common.generateHeader(
        sessionToken: authToken,
      ),
    );
    logger.responseLog(uri, response);
    if (response.statusCode == 200) {
      return const Right(true);
    } else {
      return Left(common.getMetadataMessages(response.body));
    }
  }
}
