#!/usr/bin/env bash

FOLDER="$1" # required parameter (typescript | dart | kotlin)
MODE="$2" # required parameter (publish | build)
KEYSTORE_HOST=${KEYSTORE_HOST:-$3}
KEYSTORE_ACCESS_TOKEN=${KEYSTORE_ACCESS_TOKEN:-$4}

chmod +x scripts/github/setup_git.sh
chmod +x scripts/helpers/inject_license.sh

main() {
  local PREBUILD_HANDLER="scripts/handlers/$FOLDER/prebuild.sh"
  local BUILD_HANDLER="scripts/handlers/$FOLDER/build.sh"
  local PUBLISH_HANDLER="scripts/handlers/$FOLDER/publish.sh"
  local LIBRARIES
  local CHANGED_FILES

  chmod +x "$PREBUILD_HANDLER"
  chmod +x "$BUILD_HANDLER"
  chmod +x "$PUBLISH_HANDLER"

  CHANGED_FILES=$(git diff --name-only HEAD~1 HEAD)

  if [[ "$GITHUB_ENV" != "" ]]
    then
      scripts/github/setup_git.sh
  fi

  LIBRARIES=($(ls -d1 "$FOLDER"/*))
  LIBRARIES=("${LIBRARIES[@]%/}")

  "$PREBUILD_HANDLER" "$KEYSTORE_HOST" "$KEYSTORE_ACCESS_TOKEN"

  echo "$FOLDER"

  for LIBRARY in "${LIBRARIES[@]}"
    do
      LIBRARY_ROOT="$LIBRARY"
      LIBRARY_NAME="${LIBRARY/"$FOLDER\/"/}"

      if echo "${CHANGED_FILES[@]}" | grep -q "^$LIBRARY_ROOT/"
        then
          echo Process "$LIBRARY_NAME"...

          scripts/helpers/inject_license.sh "$LIBRARY_ROOT/LICENSE" || exit 1

          cd "$LIBRARY_ROOT" || exit 1
          "../../$BUILD_HANDLER" "$LIBRARY_NAME" "$LIBRARY_ROOT" "$KEYSTORE_HOST" "$KEYSTORE_ACCESS_TOKEN"
          echo "Success build of $LIBRARY_NAME!"

          if [[ "$MODE" == "publish" ]]
            then
              "../../$PUBLISH_HANDLER" "$LIBRARY_NAME" "$LIBRARY_ROOT" "$KEYSTORE_HOST" "$KEYSTORE_ACCESS_TOKEN"
              echo "Success publication of $LIBRARY_NAME!"
          fi

          cd ../..
      fi
    done

  echo "Job finished!"
}

main
