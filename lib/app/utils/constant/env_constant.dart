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
        return "https://dev.hi-pos.id/syspos-service/api/v1";
        break;
      case Environment.dev:
        return "https://dev.hi-pos.id/syspos-service/api/v1";
        break;
      case Environment.production:
        return "https://dev.hi-pos.id/syspos-service/api/v1";
        break;
      case Environment.chatbot:
        return "https://chatbot.com/";
        break;
      default:
        return "";
    }
  }
}
