part of 'main_service.dart';

class AuthService {
  Future<Either<String, AuthToken>> signIn({
    required SignInModel requestData,
  }) async {
    var path = "users/login";

    final Uri uri = source.baseUri(path: path);

    final response = await http.post(
      uri,
      body: json.encode(requestData.toJson()),
      headers: common.generateHeader(contentType: 'application/json'),
    );

    logger.responseLog(uri, response);

    if (response.statusCode == 200) {
      final result = AuthToken.fromJson(
        json.decode(response.body),
      );

      return Right(result);
    } else {
      return Left(common.getMetadataMessages(response.body));
    }
  }

  Future<Either<String, String>> lastLogout({
    required AuthToken authToken,
    required String userId,
  }) async {
    var path = "users/last_logout/${userId}";

    final Uri uri = source.baseUri(path: path);

    final response = await http.patch(
      uri,
      headers: common.generateHeader(sessionToken: authToken),
    );

    logger.responseLog(uri, response);

    if (response.statusCode == 200) {
      return Right(common.getMetadataMessages(response.body));
    } else {
      return Left(common.getMetadataMessages(response.body));
    }
  }

  /// Keterangan satu lokasi dari master lokasi.
  ///
  /// Alamat dan telepon dipakai kepala struk; logo serta teks sambutan dipakai
  /// bilah atas layar pelanggan. Semuanya datang dari satu permintaan yang sama
  /// karena sumbernya memang satu baris lokasi.
  Future<Either<String, ({String? alamat, String? telepon, String? logoPelanggan, String? teksPelanggan})>>
      getKontakLokasi({
    required AuthToken authToken,
    required int locId,
  }) async {
    final uri = source.baseUri(path: "mst_location/$locId");

    final response = await http.get(
      uri,
      headers: common.generateHeader(sessionToken: authToken),
    );

    logger.responseLog(uri, response);

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      if (data is! Map) return const Left('Data lokasi kosong');
      return Right((
        alamat: data['locAddress']?.toString(),
        telepon: data['locPhone']?.toString(),
        logoPelanggan: data['locCustLogoPath']?.toString(),
        teksPelanggan: data['locCustWelcomeText']?.toString(),
      ));
    } else {
      return Left(common.getMetadataMessages(response.body));
    }
  }

  Future<Either<String, BaseResponse<UserEntity>>> getUserInformation({
    required AuthToken authToken,
    required String userId,
  }) async {
    var path = "users/${userId}";

    final uri = source.baseUri(path: path);

    final response = await http.get(
      uri,
      headers: common.generateHeader(sessionToken: authToken),
    );

    logger.responseLog(uri, response);

    if (response.statusCode == 200) {
      BaseResponse<UserEntity> result = BaseResponse<UserEntity>.fromJson(
        json.decode(response.body),
        (data) => UserEntity.fromJson(data),
      );
      return Right(result);
    } else {
      return Left(common.getMetadataMessages(response.body));
    }
  }
}
