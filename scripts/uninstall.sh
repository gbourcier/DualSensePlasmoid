#!/usr/bin/env bash
set -euo pipefail
if [[ $EUID -eq 0 && -n "${SUDO_USER:-}" ]]; then
    exec sudo -u "$SUDO_USER" "$0" "$@"
fi
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ID="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["KPlugin"]["Id"])' "$SCRIPT_DIR/../package/metadata.json")"
kpackagetool6 --type Plasma/Applet --remove "$PLUGIN_ID"
