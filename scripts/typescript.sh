#!/usr/bin/env bash

MODE="$1" # required parameter (publish | build)
GIT_USERNAME=${GIT_USERNAME:-$2}
GIT_EMAIL=${GIT_EMAIL:-$3}
NODE_AUTH_TOKEN=${NODE_AUTH_TOKEN:-$(cat keystore/global/npm/token.txt || echo "$4")}

setup_github_environment() {
  echo Setup git...
  git config user.name "$GIT_USERNAME"
  git config user.email "$GIT_EMAIL"

  echo Setup github environment...
  echo "NODE_AUTH_TOKEN=$NODE_AUTH_TOKEN" >> "$GITHUB_ENV"
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
  npm publish

  echo Update main branch...
  git push

  echo Successfull publication of "$1"
}

typescript() {
  local CHANGED_FILES
  local TYPESCRIPT_LIBRARIES

  if [ -z "$GITHUB_ENV" ]
    then
      setup_local_environment
    else
      setup_github_environment
  fi

  CHANGED_FILES=$(git diff --name-only HEAD~1 HEAD)
  TYPESCRIPT_LIBRARIES=$(ls -d typescript/)

  for LIBRARY in "${TYPESCRIPT_LIBRARIES[@]}"
    do
      if echo "${CHANGED_FILES[@]}" | grep -q "^typescript/$LIBRARY/"
        then
          cd "typescript/$LIBRARY/" || exit 1
          install_modules "$LIBRARY"
          prebuild "$LIBRARY"
          build "$LIBRARY"

          if [[ "$MODE" == "publish" ]]
            then
              publish "$LIBRARY"
          fi

          cd ../..
      fi
    done

    echo Job finished!
}

typescript
