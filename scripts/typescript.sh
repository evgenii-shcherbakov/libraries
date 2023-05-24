#!/usr/bin/env bash

MODE="$1" # required parameter (publish | build)
KEYSTORE_HOST=${KEYSTORE_HOST:-$2}
KEYSTORE_ACCESS_TOKEN=${KEYSTORE_ACCESS_TOKEN:-$3}

chmod +x scripts/helpers/inject_license.sh
chmod +x scripts/github/setup_git.sh
chmod +x scripts/github/update_git_branch.sh

NPM_AUTH_TOKEN=""

update_package_version() {
  if grep -qE ".*\"version\": .*" package.json
    then
      git diff HEAD~ HEAD --unified=0 -- package.json | grep -q "+.*\"version\": .*" &&
        echo "Parameter 'version' in package.json already updated, skip auto-patching..." ||
        npm version patch &&
          echo "Parameter 'version' in package.json automatically updated..." ||
          exit 1
  fi
}

setup_github_environment() {
  scripts/github/setup_git.sh

  echo Update npm...
  npm install npm@latest -g || exit 1
}

setup_local_environment() {
  echo Setup local environment...
  export NODE_AUTH_TOKEN="$NODE_AUTH_TOKEN"
}

install_modules() {
  echo Install "$1" modules...
  npm i || exit 1
}

prebuild() {
  echo Setup "$1" .npmrc file...
  npm ci || exit 1

  echo Format "$1" code...
  npm run format || exit 1
}

build() {
  echo Build "$1"...
  npm run build || exit 1

  echo Successfull build of "$1"
}

publish() {
  echo Patch version for "$1"...
  update_package_version "$1" || exit 1

  echo Publish "$1"...

  if [ -z "$GITHUB_ENV" ]
    then
      NODE_AUTH_TOKEN="$NPM_AUTH_TOKEN" npm publish --access public || exit 1
    else
      NODE_AUTH_TOKEN="$NPM_AUTH_TOKEN" npm publish --access public --provenance || exit 1
  fi

  scripts/github/update_git_branch.sh "$1" || exit 1

  echo Successfull publication of "$1"
}

main() {
  local CHANGED_FILES
  local TYPESCRIPT_LIBRARIES

  if [ -z "$GITHUB_ENV" ]
    then
      setup_local_environment || exit 1
    else
      setup_github_environment || exit 1
  fi

  CHANGED_FILES=($(git diff --name-only HEAD~1 HEAD))

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

          scripts/helpers/inject_license.sh "typescript/$LIBRARY_NAME/LICENSE" || exit 1

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
