#!/bin/bash
set -euo pipefail
DEVECO_DIR="${DEVECO_DIR:-/Applications/DevEco-Studio.app/Contents}"
export NODE_HOME="$DEVECO_DIR/tools/node"
export JAVA_HOME="$DEVECO_DIR/jbr/Contents/Home"
export PATH="$NODE_HOME/bin:$DEVECO_DIR/tools/ohpm/bin:$PATH"
export DEVECO_SDK_HOME="$DEVECO_DIR/sdk"
cd "$(dirname "$0")"
for required in libs/AgoraRtcSdk.har entry/src/main/resources/rawfile/AgoraBeautyMaterial.zip \
  entry/src/main/ets/config/LocalConfig.ets build-profile.json5; do
  if [[ ! -f "$required" ]]; then
    printf 'Missing %s\nRun: node tools/setup.mjs /path/to/AgoraRtcSdk.har /path/to/AgoraBeautyMaterial.zip\nSee README.md for App ID and signing configuration.\n' "$required" >&2
    exit 1
  fi
done
ohpm install
"$DEVECO_DIR/tools/hvigor/bin/hvigorw" --mode module -p product=default -p module=entry@default -p buildMode=debug assembleHap --no-daemon
