# Shortsy Backend

Выдаёт LiveKit JWT-токены для комнаты `shortsy_global`.

## Конфиг

Создайте файл `.env` по образцу `.env.example`:

```
LIVEKIT_URL=wss://YOUR-PROJECT.livekit.cloud
LIVEKIT_API_KEY=YOUR_API_KEY
LIVEKIT_API_SECRET=YOUR_API_SECRET
PORT=8787
```

## Запуск

```
cd backend
npm i
npm run dev
```

Эндпоинт токена:

```
GET http://localhost:8787/livekit/token?identity=alice&room=shortsy_global&publish=1
```

- `publish=1` для ведущего, `publish=0` для зрителей.
