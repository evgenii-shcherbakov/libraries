#!/usr/bin/env bash

MODE="$1" # required parameter (publish | build)
KEYSTORE_HOST=${KEYSTORE_HOST:-$2}
KEYSTORE_ACCESS_TOKEN=${KEYSTORE_ACCESS_TOKEN:-$3}

chmod +x scripts/helpers/inject_license.sh
chmod +x scripts/github/setup_git.sh
chmod +x scripts/github/update_git_branch.sh
chmod +x scripts/versioning/patch_version.sh

update_package_version() {
  if grep -qE "version: .*" pubspec.yaml
    then
      git diff HEAD~ HEAD --unified=0 -- pubspec.yaml | grep -q "+.*version: .*" &&
        echo "Parameter 'version' in pubspec.yaml already updated, skip auto-patching..." ||
        ../../scripts/versioning/patch_version.sh "version: " pubspec.yaml &&
          echo "Parameter 'version' in pubspec.yaml automatically updated..." ||
          exit 1
  fi
}

install_dependencies() {
  echo Install "$1" dependencies...
  dart pub get || exit 1
}

prebuild() {
  echo Upgrade "$1" dependencies...
  dart pub upgrade || exit 1

  echo Test "$1" code...
  dart test || exit 1

  echo Generate "$1" documentation...
  dart doc || exit 1
}

build() {
  echo Prepare "$1" package...
  dart pub publish --dry-run || exit 1
}

publish() {
  echo Patch version for "$1"...
  update_package_version || exit 1

  echo Inject google temporary token...
  curl \
    -X POST \
    -H "Authorization: Bearer $KEYSTORE_ACCESS_TOKEN" \
    -d "{\"url\":\"https://pub.dev\",\"account\":\"pub-dev\"}" \
    --url "$KEYSTORE_HOST/google/temporary-token" | dart pub token add https://pub.dev || exit 1

  echo Publish "$1"...
  dart pub publish --force || exit 1

  scripts/github/update_git_branch.sh "$1" || exit 1

  echo Successfull publication of "$1"
}

main() {
  local CHANGED_FILES
  local DART_LIBRARIES

  if [[ "$GITHUB_ENV" != "" ]]
    then
      scripts/github/setup_git.sh || exit 1
  fi

  CHANGED_FILES=($(git diff --name-only HEAD~1 HEAD))

  DART_LIBRARIES=($(ls -d1 dart/*))
  DART_LIBRARIES=("${DART_LIBRARIES[@]%/}")

  for LIBRARY in "${DART_LIBRARIES[@]}"
    do
      LIBRARY_NAME="${LIBRARY/dart\//}"

      if echo "${CHANGED_FILES[@]}" | grep -q "^dart/$LIBRARY_NAME/"
        then
          echo Process "$LIBRARY_NAME"...

          scripts/helpers/inject_license.sh "dart/$LIBRARY_NAME/LICENSE" || exit 1

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
