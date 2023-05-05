#!/usr/bin/env bash

MODE="$1" # required parameter (publish | build)
GIT_USERNAME=${GIT_USERNAME:-$2}
GIT_EMAIL=${GIT_EMAIL:-$3}
NODE_AUTH_TOKEN=${NODE_AUTH_TOKEN:-$(cat keystore/global/npm/token.txt || echo "$4")}

install_modules() {
  echo Install modules...
  npm i
}

setup_git() {
  echo Setup git...

  git config user.name "$GIT_USERNAME"
  git config user.email "$GIT_EMAIL"
}

prebuild() {
  echo Setup .npmrc file...
  npm ci

  echo Format code...
  npm run format
}

build() {
  echo Build...
  npm run build
}

publish() {
  echo Patch version...
  npm version patch

  echo Publish...
  npm publish

  echo Update main branch...
  git push

  echo Successfull publication
}

install_modules
setup_git
prebuild
build
[[ "$MODE" == "publish" ]] && publish
