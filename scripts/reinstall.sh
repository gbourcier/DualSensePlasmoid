#!/usr/bin/env bash
set -euo pipefail
if [[ $EUID -eq 0 && -n "${SUDO_USER:-}" ]]; then
    exec sudo -u "$SUDO_USER" "$0" "$@"
fi
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
kpackagetool6 --type Plasma/Applet --upgrade "$SCRIPT_DIR/../package"
