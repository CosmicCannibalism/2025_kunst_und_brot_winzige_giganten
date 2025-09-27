#!/usr/bin/env bash
# Inspect code signature, entitlements and embedded provisioning profile of a built .app
# Usage: ./inspect_codesign.sh [path/to/Your.app]

set -euo pipefail

APP_PATH="${1:-}"

if [ -z "$APP_PATH" ]; then
  # try to locate the app in DerivedData (Debug-iphoneos)
  echo "No .app path provided — trying to find built app in DerivedData..."
  APP_PATH=$(ls -d "$HOME/Library/Developer/Xcode/DerivedData"/*/Build/Products/*-iphoneos/*.app 2>/dev/null | head -n1 || true)
  if [ -z "$APP_PATH" ]; then
    echo "Could not locate a built .app in DerivedData. Provide the path as the first argument." >&2
    exit 2
  fi
fi

echo "Inspecting app: $APP_PATH"

if [ ! -d "$APP_PATH" ]; then
  echo "ERROR: not a directory: $APP_PATH" >&2
  exit 3
fi

INFO_PLIST="$APP_PATH/Info.plist"
EMBEDDED_PROV="$APP_PATH/embedded.mobileprovision"

echo "\n--- Info.plist (CFBundleIdentifier + CFBundleVersion) ---"
defaults read "$INFO_PLIST" CFBundleIdentifier 2>/dev/null || plutil -p "$INFO_PLIST" | grep CFBundleIdentifier || true
defaults read "$INFO_PLIST" CFBundleVersion 2>/dev/null || plutil -p "$INFO_PLIST" | grep CFBundleVersion || true

echo "\n--- codesign summary (short) ---"
codesign -vvv "$APP_PATH" 2>&1 || true

echo "\n--- codesign details (long) ---"
codesign -d --entitlements :- "$APP_PATH" 2>&1 || true

if [ -f "$EMBEDDED_PROV" ]; then
  echo "\n--- embedded.mobileprovision present; extracting summary ---"
  security cms -D -i "$EMBEDDED_PROV" > /tmp/_embedded_plist.xml 2>/dev/null || true
  /usr/libexec/PlistBuddy -c "Print :UUID" /tmp/_embedded_plist.xml 2>/dev/null || true
  /usr/libexec/PlistBuddy -c "Print :Entitlements" /tmp/_embedded_plist.xml 2>/dev/null || true
  /usr/libexec/PlistBuddy -c "Print :Name" /tmp/_embedded_plist.xml 2>/dev/null || true
  echo "(full embedded.mobileprovision written to /tmp/_embedded_plist.xml)"
else
  echo "\n--- No embedded.mobileprovision found in the .app (this is normal for development builds installed via Xcode using automatic signing) ---"
fi

echo "\n--- codesigning identities available on this Mac (short) ---"
security find-identity -p codesigning -v || true

echo "\n--- Done ---"

exit 0
