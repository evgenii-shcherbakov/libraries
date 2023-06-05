#!/usr/bin/env bash

LIBRARY="$1"

update_git_branch() {
  echo Update main branch...
  git add .
  git commit -m "Update $LIBRARY version"
  git status
  git pull origin main
  git push origin main
  git status
}

update_git_branch
