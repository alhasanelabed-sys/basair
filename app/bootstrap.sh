#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
command -v flutter >/dev/null || { echo 'Install Flutter stable (>=3.24) first: https://docs.flutter.dev/get-started/install'; exit 1; }
if [[ ! -d android || ! -d ios ]]; then
  scaffold_dir=$(mktemp -d "${TMPDIR:-/tmp}/basair-scaffold.XXXXXX")
  flutter create --no-pub --platforms=android,ios --org app.basair --project-name basair "$scaffold_dir"
  for platform in android ios; do
    if [[ ! -d "$platform" ]]; then cp -R "$scaffold_dir/$platform" "$platform"; fi
  done
  rm -rf "$scaffold_dir"
fi
command -v node >/dev/null || { echo "Node.js is required for configuring the shared app bundle."; exit 1; }
node ../tools/configure-platforms.cjs
flutter pub get
flutter analyze --no-fatal-infos
flutter test
printf '%s\n' 'Ready. Connect a device, then run: flutter run'
