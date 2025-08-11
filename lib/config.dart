class AppConfig {
  // Замените на ваш LiveKit Cloud/Server URL, например: wss://your-project.livekit.cloud
  static const livekitUrl = 'wss://REPLACE.livekit.cloud';
  // HTTP эндпоинт вашего бэкенда, который выдаёт JWT-токен для LiveKit
  static const livekitTokenEndpoint =
      'http://31.144.137.110:8787/livekit/token';
  // Глобальная публичная комната для эфира «как в TikTok» (один ведущий, много зрителей)
  static const liveRoom = 'shortsy_global';
}
