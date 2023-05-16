#!/usr/bin/env bash

MODE="$1" # required parameter (publish | build)
KEYSTORE_HOST=${KEYSTORE_HOST:-$2}
KEYSTORE_ACCESS_TOKEN=${KEYSTORE_ACCESS_TOKEN:-$3}

NPM_AUTH_TOKEN=""

setup_github_environment() {
  echo Setup git...
  git config user.name "GitHub Action"
  git config user.email "action@github.com"

  echo Update npm...
  npm install npm@latest -g
}

setup_local_environment() {
  echo Setup local environment...
  export NODE_AUTH_TOKEN="$NODE_AUTH_TOKEN"
}

install_modules() {
  echo Install "$1" modules...
  npm i
}

prebuild() {
  echo Setup "$1" .npmrc file...
  npm ci

  echo Format "$1" code...
  npm run format
}

build() {
  echo Build "$1"...
  npm run build

  echo Successfull build of "$1"
}

publish() {
  echo Patch version for "$1"...
  npm version patch

  echo Publish "$1"...

  if [ -z "$GITHUB_ENV" ]
    then
      NODE_AUTH_TOKEN="$NPM_AUTH_TOKEN" npm publish --access public
    else
      NODE_AUTH_TOKEN="$NPM_AUTH_TOKEN" npm publish --access public --provenance
  fi

  echo Update main branch...
  git add .
  git commit -m "Update $LIBRARY_NAME version"
  git push

  echo Successfull publication of "$1"
}

main() {
  local CHANGED_FILES
  local TYPESCRIPT_LIBRARIES

  chmod +x scripts/helpers/inject_license.sh

  if [ -z "$GITHUB_ENV" ]
    then
      setup_local_environment
    else
      setup_github_environment
  fi

  CHANGED_FILES=$(git diff --name-only HEAD~1 HEAD)

  TYPESCRIPT_LIBRARIES=($(ls -d1 typescript/*))
  TYPESCRIPT_LIBRARIES=("${TYPESCRIPT_LIBRARIES[@]%/}")

  NPM_AUTH_TOKEN=$(
    curl \
      -X GET \
      -H "Authorization: Bearer $KEYSTORE_ACCESS_TOKEN" \
      --url "$KEYSTORE_HOST/applications/libraries/npm/access-token"
  )

  for LIBRARY in "${TYPESCRIPT_LIBRARIES[@]}"
    do
      LIBRARY_NAME="${LIBRARY/typescript\//}"

      if echo "${CHANGED_FILES[@]}" | grep -q "^typescript/$LIBRARY_NAME/"
        then
          echo Process "$LIBRARY_NAME"...

          scripts/helpers/inject_license.sh "typescript/$LIBRARY_NAME/LICENSE"

          cd "typescript/$LIBRARY_NAME/" || exit 1
          install_modules "$LIBRARY_NAME" || exit 1
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
