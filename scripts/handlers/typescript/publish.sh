#!/usr/bin/env bash

LIBRARY_NAME=${LIBRARY_NAME:-$1}
LIBRARY_ROOT=${LIBRARY_ROOT:-$2}
KEYSTORE_HOST=${KEYSTORE_HOST:-$3}
KEYSTORE_ACCESS_TOKEN=${KEYSTORE_ACCESS_TOKEN:-$4}

chmod +x ../../scripts/github/update_git_branch.sh
chmod +x ../../scripts/versioning/update_package_version.sh

NPM_AUTH_TOKEN=""

load_npm_token() {
  echo "Load npm access token..."
  NPM_AUTH_TOKEN="$(sed -n "s/^NPM_AUTH_TOKEN=\(.*\)/\1/p" ../../ci.env)"
}

patch_version() {
  echo "Patch version for $LIBRARY_NAME..."
  ../../scripts/versioning/update_package_version.sh "typescript" "$LIBRARY_ROOT" "../.." || exit 1
}

publish() {
  echo "Publish $LIBRARY_NAME..."

  if [ -z "$GITHUB_ENV" ]
    then
      NODE_AUTH_TOKEN="$NPM_AUTH_TOKEN" npm publish --access public || exit 1
    else
      NODE_AUTH_TOKEN="$NPM_AUTH_TOKEN" npm publish --access public --provenance || exit 1
  fi
}

main() {
  load_npm_token
  patch_version
  publish
  cd ../..
  scripts/github/update_git_branch.sh "$LIBRARY_NAME" || exit 1
  cd "$LIBRARY_ROOT"
}

main
