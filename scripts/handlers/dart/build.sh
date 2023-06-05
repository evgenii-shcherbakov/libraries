#!/usr/bin/env bash

LIBRARY_NAME=${LIBRARY_NAME:-$1}
LIBRARY_ROOT=${LIBRARY_ROOT:-$2}
KEYSTORE_HOST=${KEYSTORE_HOST:-$3}
KEYSTORE_ACCESS_TOKEN=${KEYSTORE_ACCESS_TOKEN:-$4}

install_dependencies() {
  echo "Install $LIBRARY_NAME dependencies..."
  dart pub get || exit 1
}

test_code() {
  echo "Test $LIBRARY_NAME code..."
  dart test || exit 1
}

generate_docs() {
  echo "Generate $LIBRARY_NAME documentation..."
  dart doc || exit 1
}

fake_publish() {
  echo "Fake publish $LIBRARY_NAME..."
  dart pub publish --dry-run || exit 1
}

main() {
  install_dependencies
  test_code
  generate_docs
  fake_publish
}

main
