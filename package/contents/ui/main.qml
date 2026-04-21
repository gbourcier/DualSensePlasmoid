import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as Plasma5Support

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
            disconnectSource(source)

            if (exit !== 0 || out === "") {
                root.controllerPresent = false
                root.batteryPercent    = -1
                root.isCharging        = false
                return
            }

            // dualsensectl battery output:  "Battery level: 72%, discharging"
            var m = out.match(/(\d+)%/)
            if (!m) {
                root.controllerPresent = false
                root.batteryPercent    = -1
                return
            }

            root.batteryPercent   = parseInt(m[1], 10)
            root.isCharging       = /charg/i.test(out)
            root.controllerPresent = true
            root.lastError        = ""
        }

        function poll() {
            connectSource("dualsensectl battery")
        }
    }

    // ── Power-off command ─────────────────────────────────────────────────
    Plasma5Support.DataSource {
        id: powerOffSource
        engine: "executable"
        connectedSources: []

        onNewData: function(source, data) {
            disconnectSource(source)
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
            connectSource("dualsensectl power-off")
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
    Plasmoid.toolTipMainText: "DualSense"
    Plasmoid.toolTipSubText: {
        if (!root.controllerPresent) return "Controller not connected"
        var s = root.batteryPercent + "%"
        if (root.isCharging) s += " — charging"
        return s
    }
    Plasmoid.icon: batteryIconName()

    function pollNow() { batterySource.poll() }

    function batteryIconName() {
        if (!root.controllerPresent) return "input-gaming"

        var pct = root.batteryPercent
        var suffix = root.isCharging ? "-charging" : ""
        var level

        if      (pct > 80) level = "full"
        else if (pct > 55) level = "good"
        else if (pct > 30) level = "medium"
        else if (pct > 10) level = "low"
        else               level = "caution"

        return "battery-" + level + suffix + "-symbolic"
    }
}
