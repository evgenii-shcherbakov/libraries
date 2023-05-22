#!/usr/bin/env bash

MODE="$1" # required parameter (publish | build)
KEYSTORE_HOST=${KEYSTORE_HOST:-$2}
KEYSTORE_ACCESS_TOKEN=${KEYSTORE_ACCESS_TOKEN:-$3}

#PUBLISH_ENV_DECLARATION=""

#MAVEN_CENTRAL_CREDENTIALS="{}"
#
#SONATYPE_PASSWORD=""
#SONATYPE_USERNAME=""
#GPG_KEY_PASSWORD=""
#GPG_KEY_ID=""
#GPG_KEY=""

#get_env_declaration() {
#  local CREDENTIALS
#
#  PUBLISH_ENV_DECLARATION=$(
#    curl \
#      -X GET \
#      -H "Authorization: Bearer $KEYSTORE_ACCESS_TOKEN" \
#      --url "$KEYSTORE_HOST/applications/libraries/maven-central/credentials"
#  )

#  SONATYPE_PASSWORD=$(echo "$CREDENTIALS" | jq -d '.sonatype.password')
#  SONATYPE_USERNAME=$(echo "$CREDENTIALS" | jq -d '.sonatype.username')
#}

#publish() {
##  local SONATYPE_PASSWORD
##  local SONATYPE_USERNAME
##  local GPG_KEY_PASSWORD
##  local GPG_KEY_ID
##  local GPG_KEY
##
##  echo "Get Maven Central credentials from keystore..."
#
#  echo "Publish $1 to Maven Central..."
##  ORG_GRADLE_PROJECT_mavenCentralPassword="$SONATYPE_PASSWORD" \
##  ORG_GRADLE_PROJECT_mavenCentralUsername="$SONATYPE_USERNAME" \
##  ORG_GRADLE_PROJECT_signingInMemoryKeyPassword="$GPG_KEY_PASSWORD" \
##  ORG_GRADLE_PROJECT_signingInMemoryKeyId="$GPG_KEY_ID" \
##  ORG_GRADLE_PROJECT_signingInMemoryKey="$GPG_KEY" \
#  chmod +x ./gradlew
#  $(echo "$2" | tr -d '"') ./gradlew publishAllPublicationsToMavenCentral --no-configuration-cache
#}

#install_modules() {
#  echo Install "$1" modules...
#  npm i
#}
#
#prebuild() {
#  echo Setup "$1" .npmrc file...
#  npm ci
#
#  echo Format "$1" code...
#  npm run format
#}

build() {
  echo Build "$1"...
  ./gradlew build

  echo Successfull build of "$1"
}

publish() {
  echo Patch version for "$1"...
#  npm version patch
# TODO: implement version patching later

  echo Publish "$1"...
  $(echo "$2" | tr -d '"') ./gradlew publishAllPublicationsToMavenCentral --no-configuration-cache

  scripts/github/update_git_branch.sh "$1"

  echo Successfull publication of "$1"
}

main() {
  local CHANGED_FILES
  local TYPESCRIPT_LIBRARIES
  local PUBLISH_ENV_DECLARATION

  chmod +x scripts/helpers/inject_license.sh
  chmod +x scripts/github/setup_git.sh
  chmod +x scripts/github/update_git_branch.sh

  if [[ "$GITHUB_ENV" != "" ]]
    then
      scripts/github/setup_git.sh
  fi

  CHANGED_FILES=$(git diff --name-only HEAD~1 HEAD)

  KOTLIN_LIBRARIES=($(ls -d1 kotlin/*))
  KOTLIN_LIBRARIES=("${KOTLIN_LIBRARIES[@]%/}")

  PUBLISH_ENV_DECLARATION=$(
    curl \
      -X POST \
      -H "Authorization: Bearer $KEYSTORE_ACCESS_TOKEN" \
      -d "{\"format\":\"maven-env-string\"}" \
      --url "$KEYSTORE_HOST/applications/libraries/publishing/maven-central"
  )

  for LIBRARY in "${KOTLIN_LIBRARIES[@]}"
    do
      LIBRARY_NAME="${LIBRARY/kotlin\//}"

      if echo "${CHANGED_FILES[@]}" | grep -q "^kotlin/$LIBRARY_NAME/"
        then
          echo Process "$LIBRARY_NAME"...

          scripts/helpers/inject_license.sh "kotlin/$LIBRARY_NAME/LICENSE"

          cd "kotlin/$LIBRARY_NAME/" || exit 1
          chmod +x ./gradlew
#          install_modules "$LIBRARY_NAME" || exit 1
#          prebuild "$LIBRARY_NAME" || exit 1
          build "$LIBRARY_NAME" || exit 1

          if [[ "$MODE" == "publish" ]]
            then
              publish "$LIBRARY_NAME" "$PUBLISH_ENV_DECLARATION" || exit 1
          fi

          cd ../..
      fi
    done

    echo Job finished!
}

main

#chmod +x ./gradlew
#
#ORG_GRADLE_PROJECT_mavenCentralPassword="$SONATYPE_PASSWORD" \
#ORG_GRADLE_PROJECT_mavenCentralUsername="$SONATYPE_USERNAME" \
#ORG_GRADLE_PROJECT_signingInMemoryKeyPassword="$GPG_KEY_PASSWORD" \
#ORG_GRADLE_PROJECT_signingInMemoryKeyId="$GPG_KEY_ID" \
#ORG_GRADLE_PROJECT_signingInMemoryKey="$GPG_KEY" \
#  ./gradlew publishAllPublicationsToMavenCentral --no-configuration-cache
