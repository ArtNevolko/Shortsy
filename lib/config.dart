class AppConfig {
  // Замените на ваш LiveKit Cloud/Server URL, например: wss://your-project.livekit.cloud
  static const livekitUrl = 'wss://shortsy-w9ww1jsp.livekit.cloud';
  // HTTP эндпоинт вашего бэкенда, который выдаёт JWT-токен для LiveKit
  static const livekitTokenEndpoint =
      'https://shortsy-production.up.railway.app/livekit/token';
  // Глобальная публичная комната для эфира «как в TikTok» (один ведущий, много зрителей)
  static const liveRoom = 'shortsy_global';
}
