#!/usr/bin/env bash

LIBRARY_NAME=${LIBRARY_NAME:-$1}
LIBRARY_ROOT=${LIBRARY_ROOT:-$2}
KEYSTORE_HOST=${KEYSTORE_HOST:-$3}
KEYSTORE_ACCESS_TOKEN=${KEYSTORE_ACCESS_TOKEN:-$4}

chmod +x ../../scripts/versioning/update_package_version.sh
chmod +x ../../scripts/github/update_git_branch.sh

ORIGINAL_PROPERTIES=""
PUBLISH_PROPERTIES=""

load_publish_properties() {
  echo "Load publish gradle properties..."
  PUBLISH_PROPERTIES="$(<../../ci.env)"
}

add_publish_properties() {
  echo "Add publish gradle properties..."
  ORIGINAL_PROPERTIES="$(<gradle.properties)"
  echo "" >> gradle.properties || exit 1
  echo "$PUBLISH_PROPERTIES" >> gradle.properties || exit 1
}

restore_original_properties() {
  echo "Restore original gradle properties..."
  echo "$ORIGINAL_PROPERTIES" > gradle.properties || exit 1
}

update_version() {
  echo "Patch version for $LIBRARY_NAME..."
  ../../scripts/versioning/update_package_version.sh "kotlin" "$LIBRARY_ROOT" "../.." || exit 1
}

publish() {
  echo "Publish $LIBRARY_NAME..."
  ./gradlew publishAllPublicationsToMavenCentralRepository --no-configuration-cache || exit 1
}

main() {
  chmod +x ./gradlew || exit 1
  update_version
  load_publish_properties
  add_publish_properties
  publish
  restore_original_properties
  cd ../..
  scripts/github/update_git_branch.sh "$LIBRARY_NAME" || exit 1
  cd "$LIBRARY_ROOT"
}

main
