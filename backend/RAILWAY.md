# Деплой Shortsy backend на Railway

1. Зарегистрируйтесь на https://railway.app (можно через GitHub).

2. Нажмите **New Project** → **Deploy from GitHub Repo**.

3. Выберите репозиторий, где лежит папка `backend` (например, ArtNevolko/Shortsy).

4. После деплоя откройте вкладку **Settings** → **Variables**.

5. Добавьте переменные:
   - `LIVEKIT_URL` — ваш LiveKit Cloud URL (например, `wss://your-project.livekit.cloud`)
   - `LIVEKIT_API_KEY` — ваш API Key из LiveKit Cloud
   - `LIVEKIT_API_SECRET` — ваш API Secret из LiveKit Cloud
   - `PORT` — `8787`

6. Railway автоматически установит зависимости и запустит сервер.

7. В разделе **Deployments** появится публичный адрес, например:
   - `https://shortsy-backend.up.railway.app`

8. В мобильном приложении откройте файл `lib/config.dart` и пропишите:
   ```dart
   static const livekitTokenEndpoint = 'https://shortsy-backend.up.railway.app/livekit/token';
   ```

9. Готово! Теперь эфиры будут работать для всех пользователей.

---

**LiveKit Cloud**: https://cloud.livekit.io
- Создайте проект, получите API Key и Secret.
- URL для LIVEKIT_URL: `wss://your-project.livekit.cloud`
