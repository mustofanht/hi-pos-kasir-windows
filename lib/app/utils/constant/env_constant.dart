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
        return "http://192.168.18.195:8080/syspos-service/api/v1";
        break;
      case Environment.dev:
        return "http://194.238.23.222:8080/syspos-service/api/v1";
        break;
      case Environment.production:
        return "http://103.150.92.131:8080/syspos-service/api/v1";
        break;
      case Environment.chatbot:
        return "https://chatbot.com/";
        break;
      default:
        return "";
    }
  }
}
