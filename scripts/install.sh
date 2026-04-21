#!/usr/bin/env bash
set -euo pipefail
kpackagetool6 --type Plasma/Applet --install "$(dirname "$0")/../package"
