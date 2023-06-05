#!/usr/bin/env bash

LIBRARY_NAME=${LIBRARY_NAME:-$1}
LIBRARY_ROOT=${LIBRARY_ROOT:-$2}
KEYSTORE_HOST=${KEYSTORE_HOST:-$3}
KEYSTORE_ACCESS_TOKEN=${KEYSTORE_ACCESS_TOKEN:-$4}

test_code() {
  echo "Test $LIBRARY_NAME code..."
  ./gradlew test || exit 1
}

build() {
  echo "Build $LIBRARY_NAME..."
  ./gradlew build || exit 1
}

main() {
  chmod +x ./gradlew || exit 1
  test_code
  build
}

main
