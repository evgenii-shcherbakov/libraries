#!/usr/bin/env bash

LIBRARY="$1"

update_git_branch() {
  echo Update main branch...
  git add .
  git commit -m "Update $LIBRARY version"
  git push
}

update_git_branch
