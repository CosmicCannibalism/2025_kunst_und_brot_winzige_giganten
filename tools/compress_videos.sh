#!/usr/bin/env bash
# Simple helper to create lower-bitrate variants of the two videos
# Requires ffmpeg to be installed: brew install ffmpeg

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
VIDEOS_DIR="$ROOT_DIR/winzige_giganten_webapp/videos"

if [ ! -d "$VIDEOS_DIR" ]; then
  echo "Cannot find videos folder at $VIDEOS_DIR"
  exit 1
fi

for src in "$VIDEOS_DIR"/main.mp4 "$VIDEOS_DIR"/teaser.mp4; do
  if [ ! -f "$src" ]; then
    echo "Source not found: $src"
    continue
  fi

  base="$(basename "$src" .mp4)"
  echo "Processing $base"

  # 720p (recommended for tablets)
  ffmpeg -y -i "$src" -c:v libx264 -preset slow -crf 23 -vf scale=1280:-2 -c:a aac -b:a 128k "$VIDEOS_DIR/${base}_720.mp4"

  # 360p (smallest fallback)
  ffmpeg -y -i "$src" -c:v libx264 -preset fast -crf 28 -vf scale=640:-2 -c:a aac -b:a 96k "$VIDEOS_DIR/${base}_360.mp4"

done

echo "Finished. Check $VIDEOS_DIR for _720.mp4 and _360.mp4 variants."
