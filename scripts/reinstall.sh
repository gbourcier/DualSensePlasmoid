#!/usr/bin/env bash
set -euo pipefail
if [[ $EUID -eq 0 && -n "${SUDO_USER:-}" ]]; then
    exec sudo -u "$SUDO_USER" "$0" "$@"
fi

REFRESH=0
for arg in "$@"; do
    case "$arg" in
        -r|--refresh) REFRESH=1 ;;
        -h|--help)
            echo "Usage: $0 [--refresh]"
            echo "  --refresh, -r   Clear Plasma cache and restart plasmashell after upgrade"
            exit 0
            ;;
        *)
            echo "Unknown argument: $arg" >&2
            exit 1
            ;;
    esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
kpackagetool6 --type Plasma/Applet --upgrade "$SCRIPT_DIR/../package"

if [[ $REFRESH -eq 1 ]]; then
    rm -rf "$HOME/.cache/plasmashell" "$HOME/.cache/icon-cache.kcache"
    kquitapp6 plasmashell && kstart plasmashell
fi
