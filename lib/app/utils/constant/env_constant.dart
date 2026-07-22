// ignore_for_file: dead_code

enum Environment {
  local,
  dev,
  production,
  chatbot,
}

extension EnvironmentExt on Environment {
  // CATATAN: local, dev, dan production sengaja menunjuk host yang sama karena
  // saat ini backend-nya memang tunggal. Begitu server produksi berdiri
  // sendiri, ketiganya harus dipisah — sekaligus ganti cara pemilihan
  // environment di network_source.dart, yang sekarang masih berupa baris
  // komentar yang ditukar manual sehingga build dev bisa ter-commit dalam
  // keadaan menunjuk produksi.
  String get url {
    switch (this) {
      case Environment.local:
        return "https://be-jaya.nht01.cloud/syspos-service/api/v1";
        break;
      case Environment.dev:
        return "https://be-jaya.nht01.cloud/syspos-service/api/v1";
        break;
      case Environment.production:
        return "https://be-jaya.nht01.cloud/syspos-service/api/v1";
        break;
      case Environment.chatbot:
        return "https://chatbot.com/";
        break;
      default:
        return "";
    }
  }
}
