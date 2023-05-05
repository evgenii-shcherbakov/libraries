#!/usr/bin/env bash

TARGET_PATH="$1"

inject_license() {
  cp -rp LICENSE "$TARGET_PATH"
}

inject_license
