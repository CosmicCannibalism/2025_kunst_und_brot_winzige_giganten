#!/usr/bin/env bash
# Copy the winzige_giganten_webapp folder into the built app bundle so the original
# (uncompressed) videos are included at build time.
#
# Usage: add this script as a Run Script build phase in Xcode (see README instructions).

set -euo pipefail

# Xcode provides SRCROOT (project root), TARGET_BUILD_DIR and UNLOCALIZED_RESOURCES_FOLDER_PATH
SRCROOT="${SRCROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"

WEBAPP_SRC="$SRCROOT/winzige_giganten_webapp"

if [ ! -d "$WEBAPP_SRC" ]; then
  echo "ERROR: webapp source folder not found at: $WEBAPP_SRC"
  exit 1
fi

DEST_DIR="${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/winzige_giganten_webapp"

echo "Copying webapp from $WEBAPP_SRC to $DEST_DIR"

# remove any previous copy
rm -rf "$DEST_DIR"

# preserve file modes and symlinks where possible; use rsync if available
if command -v rsync >/dev/null 2>&1; then
  rsync -a --delete --exclude='*.DS_Store' "$WEBAPP_SRC/" "$DEST_DIR/"
else
  mkdir -p "$DEST_DIR"
  cp -a "$WEBAPP_SRC/"* "$DEST_DIR/"
fi

echo "Webapp copied into app bundle resources."

# create a marker file so Xcode can use it as a declared output for the Run Script phase
MARKER_FILE="$DEST_DIR/.winzige_webapp_copied"
mkdir -p "$(dirname "$MARKER_FILE")"
touch "$MARKER_FILE"
echo "Wrote marker: $MARKER_FILE"

exit 0
    