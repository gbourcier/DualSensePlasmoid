#!/usr/bin/env bash
set -euo pipefail
kpackagetool6 --type Plasma/Applet --upgrade "$(dirname "$0")/../package"
