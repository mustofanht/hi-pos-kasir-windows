// ignore_for_file: unnecessary_new

import 'package:jaya_propertiy/app/utils/constant/env_constant.dart';

class NetworkSource {
  // Environment ditentukan saat build via --dart-define=ENV=... (lihat env_constant.dart).
  // Default 'dev' bila flag tidak diberikan.
  final Environment environment = resolveEnvironment();
  Uri baseUri({required String path}) {
    return Uri.parse(
      '${environment.url}/$path',
    );
  }

  Uri whatsappMessageUri({required String number, required String message}) {
    return Uri.parse('https://wa.me/$number?text=$message');
  }
}

NetworkSource source = new NetworkSource();
