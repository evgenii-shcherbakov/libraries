#!/usr/bin/env bash

PATTERN="$1"
FILE="$2"

increment_build_number() {
  local PREV_BUILD_NUMBER
  local NEW_BUILD_NUMBER

  PREV_BUILD_NUMBER=$(sed -n "s/^$PATTERN\(.*\)/\1/p" "$FILE")
  NEW_BUILD_NUMBER=$((PREV_BUILD_NUMBER+1))

  printf "%s\n" "H" "/^${PATTERN}.*" "s//${PATTERN}${NEW_BUILD_NUMBER}/" "wq" | ed -s "$FILE"
}

increment_build_number
