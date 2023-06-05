#!/usr/bin/env bash

KEYSTORE_HOST=${KEYSTORE_HOST:-$1}
KEYSTORE_ACCESS_TOKEN=${KEYSTORE_ACCESS_TOKEN:-$2}

load_npm_token() {
  echo "Load npm access token..."
  NPM_AUTH_TOKEN=$(
    curl \
      -X "GET" \
      -H "Authorization: Bearer $KEYSTORE_ACCESS_TOKEN" \
      --url "$KEYSTORE_HOST/applications/libraries/npm/access-token"
  )

  echo "Save npm access token to temp file..."
  echo "NPM_AUTH_TOKEN=$NPM_AUTH_TOKEN" >> ci.env || exit 1
}

update_npm() {
  echo "Update npm..."
  npm install npm@latest -g || exit 1
}

main() {
  load_npm_token

  if [[ "$GITHUB_ENV" != "" ]]
    then
      update_npm
  fi
}

main
