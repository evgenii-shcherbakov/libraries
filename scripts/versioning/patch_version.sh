#!/usr/bin/env bash

PATTERN="$1"
FILE="$2"

patch_version() {
  local PREV_VERSION
  local NEW_VERSION
  local MAJOR
  local MINOR
  local PATCH

  PREV_VERSION=$(sed -n "s/^$PATTERN\(.*\)/\1/p" "$FILE")

  # Split the version number into MAJOR, MINOR, and PATCH
  IFS='.' read -ra VERSION_PARTS <<< "$PREV_VERSION"
  MAJOR=${VERSION_PARTS[0]}
  MINOR=${VERSION_PARTS[1]}
  PATCH=${VERSION_PARTS[2]}

  # Increment the PATCH number by 1
  PATCH=$((PATCH+1))
  NEW_VERSION="$MAJOR.$MINOR.$PATCH"

  printf "%s\n" "H" "/^${PATTERN}.*" "s//${PATTERN}${NEW_VERSION}/" "wq" | ed -s "$FILE"
}

patch_version
