#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR/.."
PACKAGE_DIR="$PROJECT_ROOT/package"
RELEASE_DIR="$PROJECT_ROOT/release"

VERSION=$(python3 -c "import json,sys; print(json.load(open('$PACKAGE_DIR/metadata.json'))['KPlugin']['Version'])")
OUTPUT="$RELEASE_DIR/dualsense-plasmoid-${VERSION}.plasmoid"

mkdir -p "$RELEASE_DIR"
rm -f "$OUTPUT"

if command -v zip >/dev/null 2>&1; then
    (cd "$PACKAGE_DIR" && zip -qr "$OUTPUT" .)
elif command -v 7z >/dev/null 2>&1; then
    (cd "$PACKAGE_DIR" && 7z a -tzip "$OUTPUT" . >/dev/null)
else
    echo "error: install 'zip' or '7z' to build the plasmoid archive" >&2
    exit 1
fi

echo "Built: $OUTPUT"
