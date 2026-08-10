// ignore_for_file: dead_code

enum Environment {
  local,
  dev,
  production,
  chatbot,
}

extension EnvironmentExt on Environment {
  String get url {
    switch (this) {
      case Environment.local:
        return "http://localhost:8080/syspos-service/api/v1";
        break;
      case Environment.dev:
        return "http://localhost:8080/syspos-service/api/v1";
        break;
      case Environment.production:
        return "http://localhost:8080/syspos-service/api/v1";
        break;
      case Environment.chatbot:
        return "https://chatbot.com/";
        break;
      default:
        return "";
    }
  }
}
