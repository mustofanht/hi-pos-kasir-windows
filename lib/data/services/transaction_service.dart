part of 'main_service.dart';

class TransactionService {
  Future<Either<String, BaseResponse<List<TransactionEntity>>>>
      getTransactionRentalHistory({
    required AuthToken authToken,
    String? search,
    required int locId,
    int? prodId,
    required int page,
  }) async {
    var path = "trn_order_addon/transaction-rental-history?";
    if (search != null && search.isNotEmpty) {
      path += "search=$search&";
    }
    if (prodId != null) {
      path += "prodId=$prodId&";
    }
    path += "locId=$locId&";
    path += "page=$page&size=${PAGINATIONS_CONSTANT.LIMIT_PAGE.toString()}";

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
      BaseResponse<List<TransactionEntity>> result =
          BaseResponse<List<TransactionEntity>>.fromJson(
        json.decode(response.body),
        (data) => common.fromJsonList(
            data, (item) => TransactionEntity.fromJson(item)),
      );
      return Right(result);
    } else {
      return Left(common.getMetadataMessages(response.body));
    }
  }

  Future<Either<String, BaseResponse<DateTime>>> getLastDateTransactionProduct({
    required AuthToken authToken,
    required int productId,
  }) async {
    var path = "trn_order_addon/transaction-rental-history-last?";
    path += "prodId=$productId&";

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
      try {
        BaseResponse<DateTime> result = BaseResponse<DateTime>.fromJson(
          json.decode(response.body),
          (data) {
            return DateTime.parse(data).toLocal();
          },
        );
        return Right(result);
      } catch (e) {
        return Left("Error parsing the response: ${e.toString()}");
      }
    } else {
      return Left(common.getMetadataMessages(response.body));
    }
  }
}
