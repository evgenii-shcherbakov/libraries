#!/usr/bin/env bash

LIBRARY_NAME=${LIBRARY_NAME:-$1}
LIBRARY_ROOT=${LIBRARY_ROOT:-$2}
KEYSTORE_HOST=${KEYSTORE_HOST:-$3}
KEYSTORE_ACCESS_TOKEN=${KEYSTORE_ACCESS_TOKEN:-$4}

chmod +x ../../scripts/versioning/update_package_version.sh
chmod +x ../../scripts/github/update_git_branch.sh

update_version() {
  echo "Patch version for $LIBRARY_NAME..."
  ../../scripts/versioning/update_package_version.sh "dart" "$LIBRARY_ROOT" "../.." || exit 1
}

publish() {
  echo "Publish $LIBRARY_NAME..."
  dart pub publish --force || exit 1
}

main() {
  update_version
  publish
  cd ../..
  scripts/github/update_git_branch.sh "$LIBRARY_NAME" || exit 1
  cd "$LIBRARY_ROOT"
}

main
