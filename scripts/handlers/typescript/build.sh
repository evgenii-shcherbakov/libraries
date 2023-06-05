#!/usr/bin/env bash

LIBRARY_NAME=${LIBRARY_NAME:-$1}
LIBRARY_ROOT=${LIBRARY_ROOT:-$2}
KEYSTORE_HOST=${KEYSTORE_HOST:-$3}
KEYSTORE_ACCESS_TOKEN=${KEYSTORE_ACCESS_TOKEN:-$4}

install_modules() {
  echo "Install $LIBRARY_NAME modules..."
  npm i || exit 1
}

prebuild() {
  echo "Setup $LIBRARY_NAME .npmrc file..."
  npm ci || exit 1

  echo "Format $LIBRARY_NAME code..."
  npm run format || exit 1
}

build() {
  echo "Build $LIBRARY_NAME..."
  npm run build || exit 1
}

main() {
  install_modules
  prebuild
  build
}

main
