part of '../main_service.dart';

class TicketService {
  Future<Either<String, BaseResponse<List<TicketEntity>>>> getAll({
    required AuthToken authToken,
    List<FilterQuery>? dataFilter,
    Map<String, dynamic>? paramsFilter,
  }) async {
    var path = "mst_ticket";

    apiFilterUtil.buildQuery(data: dataFilter, params: paramsFilter);

    final uri =
        source.baseUri(path: path).replace(queryParameters: paramsFilter);

    // logger.safeLog('uri :${uri.toString()}');

    final response = await http.get(
      uri,
      headers: common.generateHeader(
        sessionToken: authToken,
      ),
    );

    logger.responseLog(uri, response);

    if (response.statusCode == 200) {
      BaseResponse<List<TicketEntity>> result =
          BaseResponse<List<TicketEntity>>.fromJson(
        json.decode(response.body),
        (data) =>
            common.fromJsonList(data, (item) => TicketEntity.fromJson(item)),
      );
      return Right(result);
    } else {
      return Left(common.getMetadataMessages(response.body));
    }
  }

  /// Ambil tiket lapangan (ticket_fl_lapangan = 'Y') untuk tab Lapangan di kasir.
  Future<Either<String, BaseResponse<List<TicketEntity>>>> getLapangan({
    required AuthToken authToken,
    List<FilterQuery>? dataFilter,
    Map<String, dynamic>? paramsFilter,
  }) async {
    var path = "mst_ticket/lapangan";

    apiFilterUtil.buildQuery(data: dataFilter, params: paramsFilter);

    final uri =
        source.baseUri(path: path).replace(queryParameters: paramsFilter);

    final response = await http.get(
      uri,
      headers: common.generateHeader(
        sessionToken: authToken,
      ),
    );

    logger.responseLog(uri, response);

    if (response.statusCode == 200) {
      BaseResponse<List<TicketEntity>> result =
          BaseResponse<List<TicketEntity>>.fromJson(
        json.decode(response.body),
        (data) =>
            common.fromJsonList(data, (item) => TicketEntity.fromJson(item)),
      );
      return Right(result);
    } else {
      return Left(common.getMetadataMessages(response.body));
    }
  }

  /// Ambil jam-jam yang sudah terisi (booked) untuk satu court/tiket lapangan
  /// pada tanggal tertentu. Sumber kebenaran: tabel `trn_order_booked`.
  ///
  /// [date] format `yyyy-MM-dd`. Mengembalikan daftar jam absolut (mis. 15, 16).
  Future<Either<String, List<int>>> getBookedHours({
    required AuthToken authToken,
    required int ticketId,
    required String date,
  }) async {
    final path = "mst_ticket/lapangan/booked?ticketId=$ticketId&date=$date";

    final uri = source.baseUri(path: path);

    final response = await http.get(
      uri,
      headers: common.generateHeader(
        sessionToken: authToken,
      ),
    );

    logger.responseLog(uri, response);

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      final List<int> hours = data is List
          ? data
              .map((e) => e is int ? e : int.tryParse('$e'))
              .whereType<int>()
              .toList()
          : <int>[];
      return Right(hours);
    } else {
      return Left(common.getMetadataMessages(response.body));
    }
  }
}
