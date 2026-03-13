// ignore_for_file: unnecessary_new

import 'package:jaya_propertiy/app/utils/constant/env_constant.dart';

class NetworkSource {
  // final Environment environment = Environment.local;
  final Environment environment = Environment.dev;
  // final Environment environment = Environment.production;
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
