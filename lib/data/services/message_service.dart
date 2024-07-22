part of 'main_service.dart';

class MessageService {
  Future<Either<String, bool>> sendWa({
    required AuthToken authToken,
    required int phoneNumber,
    String? message,
  }) async {
    var path = "trn_message_wa";
    var body = {'phone_no': phoneNumber, 'message': message ?? ''};
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
