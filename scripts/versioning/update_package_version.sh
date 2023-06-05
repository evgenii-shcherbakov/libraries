#!/usr/bin/env bash

STRATEGY="$1" # required parameter (typescript | dart | kotlin)
LIBRARY_ROOT="$2" # required parameter
ROOT_PATH=$([[ "$3" != "" ]] && echo "$3" || echo ".")

STRATEGY_PARAMS=()
CHANGED_FILES=()
UPDATE_VERSION_IN_FILE_HANDLER="$ROOT_PATH/scripts/versioning/update_file_version.sh"

load_strategy() {
  STRATEGY_PARAMS=($(cat "$ROOT_PATH/versioning-strategy.json" | jq -r ".$STRATEGY[] | @base64"))
}

handle_strategy_params() {
  for PARAMS in "${STRATEGY_PARAMS[@]}"
    do
      PARAMS=$(echo "$PARAMS" | base64 -d)

      FILES=($(echo "$PARAMS" | jq -r '.files[]'))
      SEARCH_PATTERN="$(echo "$PARAMS" | jq -r '.pattern.search')"
      READ_PATTERN="$(echo "$PARAMS" | jq -r '.pattern.read')"
      REPLACE_PATTERN="$(echo "$PARAMS" | jq -r '.pattern.replace')"
      PUBLIC="$(echo "$PARAMS" | jq -r '.public')"
      TYPE="$(echo "$PARAMS" | jq -r '.type')"

      for FILE in "${FILES[@]}"
        do
          MATCHES=($(find . -type f -not -path "./node_modules/*" -name "$FILE"))

          for MATCH in "${MATCHES[@]}"
            do
              SUBDIRECTORY="$(dirname "$MATCH" | tr -d "./")"
              MATCH_DIRECTORY="$LIBRARY_ROOT/$([[ "$SUBDIRECTORY" != "" ]] && echo "$SUBDIRECTORY/" || echo "")"

              if echo "${CHANGED_FILES[@]}" | grep -q "^$MATCH_DIRECTORY"
                then
                  handle_match "$MATCH" "$SEARCH_PATTERN" "$READ_PATTERN" "$REPLACE_PATTERN" "$PUBLIC" "$TYPE"
              fi
            done
        done
    done
}

handle_match() {
  local MATCHED_FILE="$1"
  local SEARCH_PATTERN="$2"
  local READ_PATTERN="$3"
  local REPLACE_PATTERN="$4"
  local PUBLIC="$5"
  local TYPE="$6"

  if grep -qE ".*$SEARCH.*" "$MATCHED_FILE"
    then
      if git diff HEAD~ HEAD --unified=0 -- "$MATCHED_FILE" | grep -q "+.*$SEARCH.*"
        then
          echo "Parameter '$PUBLIC' in $MATCHED_FILE already updated, skip auto-patching..."
        else
          "$UPDATE_VERSION_IN_FILE_HANDLER" "$TYPE" "$SEARCH_PATTERN" "$READ_PATTERN" "$REPLACE_PATTERN" "$MATCHED_FILE" &&
            echo "Parameter '$PUBLIC' in $MATCHED_FILE automatically updated..." ||
            exit 1
      fi
  fi
}

update_package_version() {
  chmod +x "$UPDATE_VERSION_IN_FILE_HANDLER"

  CHANGED_FILES=$(git diff --name-only HEAD~1 HEAD)

  load_strategy
  handle_strategy_params
}

update_package_version
