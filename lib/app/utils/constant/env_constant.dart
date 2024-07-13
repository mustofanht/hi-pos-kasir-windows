// ignore_for_file: dead_code

enum Environment {
  dev,
  production,
  chatbot,
}

extension EnvironmentExt on Environment {
  String get url {
    switch (this) {
      case Environment.dev:
        return "http://194.238.23.222:8080/syspos-service/api/v1";
        break;
      case Environment.production:
        return "https://prod.com/api/";
        break;
      case Environment.chatbot:
        return "https://chatbot.com/";
        break;
      default:
        return "";
    }
  }
}
