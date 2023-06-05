#!/usr/bin/env bash

TARGETS=("typescript" "dart" "kotlin")

expose_output() {
  local TARGET="$1"

  echo "Directory $TARGET contains git changes!"
  echo "$TARGET=true" >> "$GITHUB_OUTPUT"
}

check_changed_dirs() {
  local CHANGED_FILES

  CHANGED_FILES=$(git diff --name-only HEAD~1 HEAD)

  for TARGET in "${TARGETS[@]}"
    do
      if echo "${CHANGED_FILES[@]}" | grep -q "^$TARGET/"
        then
          expose_output "$TARGET"
      fi
    done
}

check_changed_dirs
