#!/usr/bin/env bash

KEYSTORE_HOST=${KEYSTORE_HOST:-$1}
KEYSTORE_ACCESS_TOKEN=${KEYSTORE_ACCESS_TOKEN:-$2}

load_publish_properties() {
  local PUBLISH_PROPERTIES

  echo "Load gradle properties for publishing..."
  PUBLISH_PROPERTIES=$(
    curl \
      -X "POST" \
      -H "Authorization: Bearer $KEYSTORE_ACCESS_TOKEN" \
      -d "{\"format\":\"gradle-properties\"}" \
      --url "$KEYSTORE_HOST/applications/libraries/publishing/maven-central"
  )

  echo "Save publish properties to temp file..."
  echo "$PUBLISH_PROPERTIES" > ci.env || exit 1
}

main() {
  load_publish_properties
}

main
