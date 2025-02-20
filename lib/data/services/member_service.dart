part of 'main_service.dart';

class MemberService {
  Future<Either<String, BaseResponse<List<Member>>>> getMember({
    required AuthToken authToken,
    List<FilterQuery>? dataFilter,
    Map<String, dynamic>? paramsFilter,
  }) async {
    var path = "member_list";

    apiFilterUtil.buildQuery(data: dataFilter, params: paramsFilter);

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
      BaseResponse<List<Member>> result = BaseResponse<List<Member>>.fromJson(
        json.decode(response.body),
        (data) => common.fromJsonList(data, (item) => Member.fromJson(item)),
      );
      return Right(result);
    } else {
      return Left(common.getMetadataMessages(response.body));
    }
  }
}
