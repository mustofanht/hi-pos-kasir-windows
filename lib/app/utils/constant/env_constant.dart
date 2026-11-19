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
        return "https://new-api.hi-pos.id/syspos-service/api/v1";
        break;
      case Environment.chatbot:
        return "https://chatbot.com/";
        break;
      default:
        return "";
    }
  }
}

/// Environment aktif ditentukan SAAT BUILD lewat: --dart-define=ENV=<nilai>
/// Contoh: --dart-define=ENV=production  |  --dart-define=ENV=dev
/// Tanpa flag (mis. `flutter run` biasa) default-nya `dev`, jadi
/// development tidak akan pernah nyasar ke server produksi.
Environment resolveEnvironment() {
  const env = String.fromEnvironment('ENV', defaultValue: 'dev');
  switch (env) {
    case 'production':
    case 'prod':
      return Environment.production;
    case 'local':
      return Environment.local;
    case 'chatbot':
      return Environment.chatbot;
    case 'dev':
    default:
      return Environment.dev;
  }
}
