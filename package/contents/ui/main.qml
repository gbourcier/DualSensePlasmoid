import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.plasma.core as PlasmaCore

PlasmoidItem {
    id: root

    // ── State ──────────────────────────────────────────────────────────────
    property int    batteryPercent:     -1   // -1 = unknown / disconnected
    property bool   isCharging:         false
    property bool   controllerPresent:  false
    property string lastError:          ""

    // ── Representations ───────────────────────────────────────────────────
    compactRepresentation: CompactView { }
    fullRepresentation:    FullView    { }

    // ── Battery poll ──────────────────────────────────────────────────────
    Plasma5Support.DataSource {
        id: batterySource
        engine: "executable"
        connectedSources: []

        onNewData: function(source, data) {
            var exit = data["exit code"] !== undefined ? data["exit code"] : 0
            var out  = (data["stdout"] || "").trim()
            batterySource.disconnectSource(source)

            if (exit !== 0 || out === "") {
                root.controllerPresent = false
                root.batteryPercent    = -1
                root.isCharging        = false
                return
            }

            // dualsensectl battery output: "95 discharging" (newer) or "Battery level: 72%, discharging" (older)
            var m = out.match(/(\d+)\s*%?/)
            if (!m) {
                root.controllerPresent = false
                root.batteryPercent    = -1
                return
            }

            root.batteryPercent   = parseInt(m[1], 10)
            // \b word boundary avoids matching "discharging"
            root.isCharging       = /\bcharging\b/i.test(out)
            root.controllerPresent = true
            root.lastError        = ""
        }

        function poll() {
            batterySource.connectSource("dualsensectl battery")
        }
    }

    // ── Power-off command ─────────────────────────────────────────────────
    Plasma5Support.DataSource {
        id: powerOffSource
        engine: "executable"
        connectedSources: []

        onNewData: function(source, data) {
            powerOffSource.disconnectSource(source)
            var exit = data["exit code"] !== undefined ? data["exit code"] : 0
            if (exit !== 0) {
                root.lastError = "power-off failed (is controller on Bluetooth?)"
            } else {
                root.lastError = ""
                // Give hardware a moment, then re-poll
                pollTimer.restart()
            }
        }

        function powerOff() {
            powerOffSource.connectSource("dualsensectl power-off")
        }
    }

    // ── Poll timer ────────────────────────────────────────────────────────
    Timer {
        id: pollTimer
        interval: 30000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: batterySource.poll()
    }

    // ── Tooltip ───────────────────────────────────────────────────────────
    toolTipMainText: Plasmoid.title
    toolTipSubText: {
        if (!root.controllerPresent) return "Controller not connected"
        var s = root.batteryPercent + "%"
        if (root.isCharging) s += " — charging"
        return s
    }
    Plasmoid.status: root.controllerPresent
                     ? PlasmaCore.Types.ActiveStatus
                     : PlasmaCore.Types.PassiveStatus

    onExpandedChanged: if (expanded) pollNow()

    function pollNow() { batterySource.poll() }
}
