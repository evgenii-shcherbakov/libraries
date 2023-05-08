#!/usr/bin/env bash

MODE="$1" # required parameter (publish | build)
GIT_USERNAME=${GIT_USERNAME:-$2}
GIT_EMAIL=${GIT_EMAIL:-$3}
GIT_TAG_NAME=${GIT_TAG_NAME:-$4}

update_pubspec_version() {
  awk \
    -v old="$1" \
    -v new="$2" \
    '{ gsub("version: "old, "version: "new) }1' pubspec.yaml > tmp && mv tmp pubspec.yaml
}

patch_version_from_pubspec() {
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

patch_version_from_git_tag() {
  local PREV_VERSION
  local NEW_VERSION

  PREV_VERSION=$(grep 'version:' pubspec.yaml | awk '{print $2}')
  NEW_VERSION=$(echo "$GIT_TAG_NAME" | sed -e "s/^$1-//")

  update_pubspec_version "$PREV_VERSION" "$NEW_VERSION"
}

setup_github_environment() {
  echo Setup git...
  git config user.name "$GIT_USERNAME"
  git config user.email "$GIT_EMAIL"
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

  if [[ "$GIT_TAG_NAME" != "" ]]
    then
      patch_version_from_git_tag "$1"
    else
      patch_version_from_pubspec
  fi

  echo Update main branch...
  git add .
  git commit -m "Update $LIBRARY_NAME version"
  git push

  if [[ "$GITHUB_ENV" != "" && "$GIT_TAG_NAME" == "" ]]
    then
      git tag "${LIBRARY_NAME}-$LIBRARY_VERSION"
      git push --tags
  fi

  echo Publish "$1"...
  dart pub publish -f

  echo Successfull publication of "$1"
}

force_publish() {
  local LIBRARY_NAME

  LIBRARY_NAME="$(echo "$GIT_TAG_NAME" | sed -e "s/-[0-9]*.[0-9]*.[0-9]*$//")"

  echo Process "$LIBRARY_NAME"...

  scripts/helpers/inject_license.sh "dart/$LIBRARY_NAME/LICENSE"

  cd "dart/$LIBRARY_NAME/" || exit 1
  install_dependencies "$LIBRARY_NAME" || exit 1
  prebuild "$LIBRARY_NAME" || exit 1
  build "$LIBRARY_NAME" || exit 1
  publish "$LIBRARY_NAME" || exit 1
}

main() {
  local CHANGED_FILES
  local DART_LIBRARIES

  if [[ "$GITHUB_ENV" != "" ]]
    then
      setup_github_environment
  fi

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

chmod +x scripts/helpers/inject_license.sh

if [[ "$GIT_TAG_NAME" != "" && "$GITHUB_ENV" != "" ]]
  then
    force_publish
  else
    main
fi
