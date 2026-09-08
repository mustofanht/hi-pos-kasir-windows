part of '../main_service.dart';

class TicketBundleService {
  /// Aturan bundling merchandise milik satu tiket.
  ///
  /// `activeOnly` membuat backend hanya mengirim aturan berstatus aktif dan yang
  /// masa berlakunya mencakup hari ini — kasir tidak perlu menyaring sendiri.
  Future<Either<String, BaseResponse<List<TicketBundleEntity>>>> getByTicket({
    required AuthToken authToken,
    required int ticketId,
  }) async {
    final uri = source.baseUri(path: "mst_ticket_bundle/ticket/$ticketId").replace(
      queryParameters: {"activeOnly": "true"},
    );

    final response = await http.get(
      uri,
      headers: common.generateHeader(sessionToken: authToken),
    );

    logger.responseLog(uri, response);

    if (response.statusCode == 200) {
      BaseResponse<List<TicketBundleEntity>> result =
          BaseResponse<List<TicketBundleEntity>>.fromJson(
        json.decode(response.body),
        (data) => common.fromJsonList(
            data, (item) => TicketBundleEntity.fromJson(item)),
      );
      return Right(result);
    } else {
      return Left(common.getMetadataMessages(response.body));
    }
  }
}
