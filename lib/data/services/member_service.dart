part of 'main_service.dart';

class MemberService {
  Future<Either<String, BaseResponse<List<MemberCard>>>> getMemberCardInq({
    required AuthToken authToken,
    required int page,
    String? search,
  }) async {
    var path = "member_card/inquiry?";
    path += 'size=${PAGINATIONS_CONSTANT.LIMIT_PAGE}';
    path += '&page=$page';
    if (search != null && path.isNotEmpty) {
      path += '&search=$search';
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
      BaseResponse<List<MemberCard>> result =
          BaseResponse<List<MemberCard>>.fromJson(
        json.decode(response.body),
        (data) =>
            common.fromJsonList(data, (item) => MemberCard.fromJson(item)),
      );
      return Right(result);
    } else {
      return Left(common.getMetadataMessages(response.body));
    }
  }

  Future<Either<String, BaseResponse<List<Membership>>>> getMembership({
    required AuthToken authToken,
    List<FilterQuery>? dataFilter,
    Map<String, dynamic>? paramsFilter,
  }) async {
    var path = "mst_membership";

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
      BaseResponse<List<Membership>> result =
          BaseResponse<List<Membership>>.fromJson(
        json.decode(response.body),
        (data) =>
            common.fromJsonList(data, (item) => Membership.fromJson(item)),
      );
      return Right(result);
    } else {
      return Left(common.getMetadataMessages(response.body));
    }
  }

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

  Future<Either<String, BaseResponse<MemberValid>>> memberValid({
    required AuthToken authToken,
    required String cardNo,
  }) async {
    var encodedCardNo = Uri.encodeComponent(cardNo);
    var path = "member_card/valid/$encodedCardNo";

    // var path = "member_card/valid/$cardNo";

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
      BaseResponse<MemberValid> result = BaseResponse<MemberValid>.fromJson(
        json.decode(response.body),
        (data) => MemberValid.fromJson(data),
      );
      return Right(result);
    } else {
      return Left(common.getMetadataMessages(response.body));
    }
  }

  Future<Either<String, BaseResponse<ResponseOrderEntity>>> createOrder({
    required AuthToken authToken,
    required OrderMemberModel body,
    String? reffNo,
  }) async {
    logger.safeLog('reffNo : $reffNo');
    var path = "trn_order/regmembership";

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
}
