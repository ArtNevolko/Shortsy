#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

read -rp "LIVEKIT_URL (например wss://YOUR-PROJECT.livekit.cloud): " LIVEKIT_URL
read -rp "LIVEKIT_API_KEY: " LIVEKIT_API_KEY
read -rp "LIVEKIT_API_SECRET: " LIVEKIT_API_SECRET
PORT=${PORT:-8787}

cat > .env <<EOF
LIVEKIT_URL=${LIVEKIT_URL}
LIVEKIT_API_KEY=${LIVEKIT_API_KEY}
LIVEKIT_API_SECRET=${LIVEKIT_API_SECRET}
PORT=${PORT}
EOF

echo ".env создан. Запуск: npm i && npm run dev"
