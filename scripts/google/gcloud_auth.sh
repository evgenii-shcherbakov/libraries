#!/usr/bin/env bash

APP_NAME=${APP_NAME:-$1}
GOOGLE_PROJECT_ID=${GOOGLE_PROJECT_ID:-$2}

echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | sudo tee \
  -a /etc/apt/sources.list.d/google-cloud-sdk.list

curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key \
  --keyring /usr/share/keyrings/cloud.google.gpg \
  add -

sudo apt-get update
sudo apt-get install -y google-cloud-sdk

gcloud config set project "$GOOGLE_PROJECT_ID"

gcloud auth \
  activate-service-account \
  --key-file=<(cat "keystore/$APP_NAME/google/private-key.json") \
  --project="$GOOGLE_PROJECT_ID"

gcloud auth print-identity-token --audiences=https://pub.dev | dart pub token add https://pub.dev
dart pub publish --force
