part of 'main_service.dart';

class RentalService {
  Future<Either<String, BaseResponse<double>>> getPriceRental({
    required AuthToken authToken,
    required int hours,
    required int productId,
    String? orderNoExtra,
  }) async {
    var path = "mst_product_time/range?";
    path += "productId=$productId&";
    path += "hour=$hours&";
    if (orderNoExtra != null) {
      path += "orderNoExtra=$orderNoExtra";
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
      // BaseResponse result = BaseResponse.fromJson(json.decode(response.body), );
      BaseResponse<double> result = BaseResponse<double>.fromJson(
        json.decode(response.body),
        (data) => (data is int) ? data.toDouble() : data as double,
      );

      return Right(result);
    } else {
      return Left(common.getMetadataMessages(response.body));
    }
  }
}
