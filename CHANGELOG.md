# Changelog

## [0.1.0] - Unreleased

### Added
- Battery level display with freedesktop icon names
- Polling every 30 seconds via Plasma5Support DataSource
- Power-off button in popup (Bluetooth only)
- Graceful disconnected state — dims icon, no crash when controller absent
- Graceful error when `dualsensectl` is not installed
- Lightbar color picker (native color dialog → `dualsensectl lightbar R G B`)
- Auto-refresh of battery state when opening the full view
- `--refresh` / `-r` flag on `reinstall.sh` to clear Plasma cache and restart plasmashell

### Changed
- Icon switched to `qjoypad-tray`
- `metadata.json` is now the single source of truth for icon and title; QML views read `Plasmoid.icon` and `Plasmoid.title` instead of hardcoding strings

### Removed
- Manual "Refresh" button in the full view (replaced by auto-refresh on open)
