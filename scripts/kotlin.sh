#!/usr/bin/env bash

MODE="$1" # required parameter (publish | build)
KEYSTORE_HOST=${KEYSTORE_HOST:-$2}
KEYSTORE_ACCESS_TOKEN=${KEYSTORE_ACCESS_TOKEN:-$3}

chmod +x scripts/helpers/inject_license.sh
chmod +x scripts/github/setup_git.sh
chmod +x scripts/github/update_git_branch.sh
chmod +x scripts/versioning/patch_version.sh
chmod +x scripts/versioning/increment_build_number.sh

update_package_gradle_properties() {
  local GRADLE_PROPERTIES_FILES

  GRADLE_PROPERTIES_FILES=($(find . -type f -name "gradle.properties"))

  for FILE in "${GRADLE_PROPERTIES_FILES[@]}"
    do
      if grep -qE "VERSION_NAME=.*" "$FILE"
        then
          git diff HEAD~ HEAD --unified=0 -- "$FILE" | grep -q "+.*VERSION_NAME=.*" &&
            echo "Parameter 'VERSION_NAME' in $FILE already updated, skip auto-patching..." ||
            ../../scripts/versioning/patch_version.sh "VERSION_NAME=" "$FILE" &&
              echo "Parameter 'VERSION_NAME' in $FILE automatically updated..." ||
              exit 1
      fi

      if grep -qE "BUILD_NUMBER=.*" "$FILE"
        then
          git diff HEAD~ HEAD --unified=0 -- "$FILE" | grep -q "+.*BUILD_NUMBER=.*" &&
            echo "Parameter 'BUILD_NUMBER' in $FILE already updated, skip auto-patching..." ||
            ../../scripts/versioning/increment_build_number.sh "BUILD_NUMBER=" "$FILE" &&
              echo "Parameter 'BUILD_NUMBER' in $FILE automatically updated..." ||
              exit 1
      fi
    done
}

build() {
  echo Build "$1"...
  ./gradlew build || exit 1

  echo Successfull build of "$1"
}

publish() {
  local ORIGINAL_GRADLE_PROPERTIES

  echo Patch version for "$1"...
  update_package_gradle_properties "kotlin/$1" || exit 1

  echo Publish "$1"...
  ORIGINAL_GRADLE_PROPERTIES=$(<gradle.properties)
  echo "" >> gradle.properties
  echo "$2" | tr -d '"' >> gradle.properties
  ./gradlew publishAllPublicationsToMavenCentral --no-configuration-cache || exit 1
  echo "$ORIGINAL_GRADLE_PROPERTIES" > gradle.properties

  scripts/github/update_git_branch.sh "$1" || exit 1

  echo Successfull publication of "$1"
}

main() {
  local CHANGED_FILES
  local TYPESCRIPT_LIBRARIES
  local PUBLISH_ENV_DECLARATION

  if [[ "$GITHUB_ENV" != "" ]]
    then
      scripts/github/setup_git.sh || exit 1
  fi

  CHANGED_FILES=($(git diff --name-only HEAD~1 HEAD))

  KOTLIN_LIBRARIES=($(ls -d1 kotlin/*))
  KOTLIN_LIBRARIES=("${KOTLIN_LIBRARIES[@]%/}")

  PUBLISH_PROPERTIES=$(
    curl \
      -X POST \
      -H "Authorization: Bearer $KEYSTORE_ACCESS_TOKEN" \
      -d "{\"format\":\"gradle-properties\"}" \
      --url "$KEYSTORE_HOST/applications/libraries/publishing/maven-central"
  )

  for LIBRARY in "${KOTLIN_LIBRARIES[@]}"
    do
      LIBRARY_NAME="${LIBRARY/kotlin\//}"

      if echo "${CHANGED_FILES[@]}" | grep -q "^kotlin/$LIBRARY_NAME/"
        then
          echo Process "$LIBRARY_NAME"...

          scripts/helpers/inject_license.sh "kotlin/$LIBRARY_NAME/LICENSE" || exit 1

          cd "kotlin/$LIBRARY_NAME/" || exit 1
          chmod +x ./gradlew || exit 1
          build "$LIBRARY_NAME" || exit 1

          if [[ "$MODE" == "publish" ]]
            then
              publish "$LIBRARY_NAME" "$PUBLISH_PROPERTIES" || exit 1
          fi

          cd ../..
      fi
    done

    echo Job finished!
}

main
