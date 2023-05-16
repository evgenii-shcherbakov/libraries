#!/usr/bin/env bash

MODE="$1" # required parameter (publish | build)
KEYSTORE_HOST=${KEYSTORE_HOST:-$2}
KEYSTORE_ACCESS_TOKEN=${KEYSTORE_ACCESS_TOKEN:-$3}

update_pubspec_version() {
  awk \
    -v old="$1" \
    -v new="$2" \
    '{ gsub("version: "old, "version: "new) }1' pubspec.yaml > tmp && mv tmp pubspec.yaml
}

patch_version() {
  local PREV_VERSION
  local NEW_VERSION
  local MAJOR
  local MINOR
  local PATCH

  PREV_VERSION=$(grep 'version:' pubspec.yaml | awk '{print $2}')

  # Split the version number into MAJOR, MINOR, and PATCH
  IFS='.' read -ra VERSION_PARTS <<< "$PREV_VERSION"
  MAJOR=${VERSION_PARTS[0]}
  MINOR=${VERSION_PARTS[1]}
  PATCH=${VERSION_PARTS[2]}

  # Increment the PATCH number by 1
  PATCH=$((PATCH+1))
  NEW_VERSION="$MAJOR.$MINOR.$PATCH"

  update_pubspec_version "$PREV_VERSION" "$NEW_VERSION"

  if [[ "$GITHUB_ENV" != "" ]]
    then
      echo "LIBRARY_VERSION=$NEW_VERSION" >> "$GITHUB_ENV"
  fi
}

setup_github_environment() {
  echo Setup git...
  git config user.name "GitHub Action"
  git config user.email "action@github.com"
}

install_dependencies() {
  echo Install "$1" dependencies...
  dart pub get
}

prebuild() {
  echo Upgrade "$1" dependencies...
  dart pub upgrade

  echo Test "$1" code...
  dart test

  echo Generate "$1" documentation...
  dart doc
}

build() {
  echo Prepare "$1" package...
  dart pub publish --dry-run
}

publish() {
  echo Patch version for "$1"...
  patch_version

  echo Update main branch...
  git add .
  git commit -m "Update $LIBRARY_NAME version"
  git push

  echo Inject google temporary token...
  curl \
    -X POST \
    -H "Authorization: Bearer $KEYSTORE_ACCESS_TOKEN" \
    -d "{\"url\":\"https://pub.dev\",\"account\":\"pub-dev\"}" \
    --url "$KEYSTORE_HOST/google/temporary-token" | dart pub token add https://pub.dev

  echo Publish "$1"...
  dart pub publish --force

  echo Successfull publication of "$1"
}

main() {
  local CHANGED_FILES
  local DART_LIBRARIES

  if [[ "$GITHUB_ENV" != "" ]]
    then
      setup_github_environment
  fi

  chmod +x scripts/helpers/inject_license.sh

  CHANGED_FILES=$(git diff --name-only HEAD~1 HEAD)

  DART_LIBRARIES=($(ls -d1 dart/*))
  DART_LIBRARIES=("${DART_LIBRARIES[@]%/}")

  for LIBRARY in "${DART_LIBRARIES[@]}"
    do
      LIBRARY_NAME="${LIBRARY/dart\//}"

      if echo "${CHANGED_FILES[@]}" | grep -q "^dart/$LIBRARY_NAME/"
        then
          echo Process "$LIBRARY_NAME"...

          scripts/helpers/inject_license.sh "dart/$LIBRARY_NAME/LICENSE"

          cd "dart/$LIBRARY_NAME/" || exit 1
          install_dependencies "$LIBRARY_NAME" || exit 1
          prebuild "$LIBRARY_NAME" || exit 1
          build "$LIBRARY_NAME" || exit 1

          if [[ "$MODE" == "publish" ]]
            then
              publish "$LIBRARY_NAME" || exit 1
          fi

          cd ../..
      fi
    done

    echo Job finished!
}

main
