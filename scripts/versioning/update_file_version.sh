#!/usr/bin/env bash

TYPE="$1"
SEARCH_PATTERN="$2"
READ_PATTERN="$3"
REPLACE_PATTERN="$4"
FILE="$5"

READER="${READ_PATTERN/\&/"$SEARCH_PATTERN"}"

update_version_name() {
  local UPDATE_TYPE="$1"
  local VERSION_PARTS
  local NEW_VALUE
  local MAJOR
  local MINOR
  local PATCH
  local REPLACER

  IFS='.' read -ra VERSION_PARTS <<< "$(printf "%s\n" "$READER" "q" | ed -s "$FILE")"

  MAJOR=${VERSION_PARTS[0]}
  MINOR=${VERSION_PARTS[1]}
  PATCH=${VERSION_PARTS[2]}

  case "$UPDATE_TYPE" in
    patch)
      PATCH=$((PATCH+1))
    ;;
    minor)
      MINOR=$((MINOR+1))
    ;;
    major)
      MAJOR=$((MAJOR+1))
    ;;
    *)
      echo "Exception: update version name type not supported yet" && exit 1
    ;;
  esac

  NEW_VALUE="$MAJOR.$MINOR.$PATCH"
  REPLACER="${REPLACE_PATTERN/\&/"$NEW_VALUE"}"

  printf "%s\n" "H" "/$SEARCH_PATTERN.*" "s//$REPLACER/" "wq" | ed -s "$FILE"
}

increment_build_number() {
  local VERSION_PARTS
  local NEW_VALUE
  local REPLACER

  IFS='.' read -ra VERSION_PARTS <<< "$(printf "%s\n" "$READER" "q" | ed -s "$FILE")"
  NEW_VALUE=$((VERSION_PARTS[0] + 1))
  REPLACER="${REPLACE_PATTERN/\&/"$NEW_VALUE"}"

  printf "%s\n" "H" "/$SEARCH_PATTERN.*" "s//$REPLACER/" "wq" | ed -s "$FILE"
}

update_version_in_file() {
  case "$TYPE" in
    patch)
      update_version_name "patch"
    ;;
    minor)
      update_version_name "minor"
    ;;
    major)
      update_version_name "major"
    ;;
    increment)
      increment_build_number
    ;;
    *)
      echo "Exception: type not supported yet" && exit 1
    ;;
  esac
}

update_version_in_file
