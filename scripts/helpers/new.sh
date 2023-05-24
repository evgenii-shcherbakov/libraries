#!/usr/bin/env bash

TYPE="$1" #required parameter
NAME="$2" #required parameter

bootstrap_library() {
  chmod +x scripts/helpers/inject_license.sh

  case "$LANGUAGE" in
    --typescript)
      mkdir -p typescript
      cp -rp templates/typescript "typescript/$NAME"
      scripts/helpers/inject_license.sh "typescript/$NAME/LICENSE"
    ;;
    --dart)
      mkdir -p dart
      cp -rp templates/dart "dart/$NAME"
      scripts/helpers/inject_license.sh "dart/$NAME/LICENSE"
    ;;
    --android)
      mkdir -p kotlin
      cp -rp templates/kotlin/android "kotlin/$NAME"
      scripts/helpers/inject_license.sh "kotlin/$NAME/LICENSE"
    ;;
    *)
      echo "Exception: language not supported yet" && exit 1
    ;;
  esac
}

bootstrap_library
