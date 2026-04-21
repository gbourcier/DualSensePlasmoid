---
name: DualSense Plasmoid project context
description: Architecture decisions, v0.1 scope, and what's intentionally excluded
type: project
---

Plasma 6 plasmoid that polls `dualsensectl battery` every 30s and exposes a power-off button.

Plugin ID: `com.github.gabriel.dualsense`

**Key decisions:**
- Plasma5Support DataSource (executable engine) for shelling out — no C++, no compile step
- -1 batteryPercent = disconnected/unknown; compact view dims icon in that state
- Power-off button always enabled when controller present; shows error if command fails (USB vs BT can't be told from battery output alone)
- `pollNow()` function on root PlasmoidItem exposes poll trigger to FullView

**Why:** pure QML means kpackagetool6 install, no build toolchain needed.

**Out of scope for v0.1:** multiple controllers, lightbar/LEDs/mic, trigger effects, firmware updates.

**How to apply:** don't add C++ or build steps; don't add multi-controller UI without a separate milestone discussion.
