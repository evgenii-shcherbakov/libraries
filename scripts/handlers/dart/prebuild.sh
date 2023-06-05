#!/usr/bin/env bash

KEYSTORE_HOST=${KEYSTORE_HOST:-$1}
KEYSTORE_ACCESS_TOKEN=${KEYSTORE_ACCESS_TOKEN:-$2}

setup_dart() {
  local PUB_DEV_TOKEN

  echo "Load google temporary token..."
  PUB_DEV_TOKEN=$(
    curl \
      -X "POST" \
      -H "Authorization: Bearer $KEYSTORE_ACCESS_TOKEN" \
      -d "{\"url\":\"https://pub.dev\",\"account\":\"pub-dev\"}" \
      --url "$KEYSTORE_HOST/google/temporary-token"
  )

  echo "Attach google temporary token to dart pub..."
  echo "$PUB_DEV_TOKEN" | dart pub token add "https://pub.dev" || exit 1
}

main() {
  setup_dart
}

main
