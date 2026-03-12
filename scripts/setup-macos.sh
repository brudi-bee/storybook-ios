#!/usr/bin/env bash
set -euo pipefail

echo "[1/4] Check Xcode CLI tools"
xcode-select -p >/dev/null 2>&1 || xcode-select --install || true

echo "[2/4] Check Homebrew"
if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew fehlt. Installiere zuerst: https://brew.sh"
  exit 1
fi

echo "[3/4] Install xcodegen"
brew list xcodegen >/dev/null 2>&1 || brew install xcodegen

echo "[4/4] Generate Xcode project"
cd "$(dirname "$0")/.."
xcodegen generate

echo "✅ Fertig. Öffne jetzt: Storybook.xcodeproj"
