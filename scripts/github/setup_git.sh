#!/usr/bin/env bash

setup_git() {
  echo Setup git...
  git config user.name "GitHub Action"
  git config user.email "action@github.com"
  git config pull.rebase true
}

setup_git
