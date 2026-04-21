import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.kirigami as Kirigami

Item {
    id: fullRoot

    implicitWidth:  Kirigami.Units.gridUnit * 14
    implicitHeight: layout.implicitHeight + Kirigami.Units.largeSpacing * 2

    ColumnLayout {
        id: layout
        anchors {
            left:   parent.left
            right:  parent.right
            top:    parent.top
            margins: Kirigami.Units.largeSpacing
        }
        spacing: Kirigami.Units.smallSpacing

        // ── Header row ────────────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            Kirigami.Icon {
                source: plasmoid.icon
                opacity: plasmoid.rootItem.controllerPresent ? 1.0 : 0.4
                Layout.preferredWidth:  Kirigami.Units.iconSizes.medium
                Layout.preferredHeight: Kirigami.Units.iconSizes.medium
            }

            ColumnLayout {
                spacing: 0
                Layout.fillWidth: true

                PlasmaComponents.Label {
                    text: "DualSense"
                    font.weight: Font.Medium
                }

                PlasmaComponents.Label {
                    text: {
                        if (!plasmoid.rootItem.controllerPresent)
                            return "Not connected"
                        var s = plasmoid.rootItem.batteryPercent + "%"
                        if (plasmoid.rootItem.isCharging) s += " — charging"
                        return s
                    }
                    font.pointSize: Kirigami.Theme.smallFont.pointSize
                    opacity: 0.7
                }
            }
        }

        // ── Battery bar ───────────────────────────────────────────────────
        PlasmaComponents.ProgressBar {
            visible: plasmoid.rootItem.controllerPresent
            Layout.fillWidth: true
            value: plasmoid.rootItem.controllerPresent
                   ? plasmoid.rootItem.batteryPercent / 100.0
                   : 0
        }

        // ── Error message ─────────────────────────────────────────────────
        PlasmaComponents.Label {
            visible: plasmoid.rootItem.lastError !== ""
            text:    plasmoid.rootItem.lastError
            color:   Kirigami.Theme.negativeTextColor
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            font.pointSize: Kirigami.Theme.smallFont.pointSize
        }

        // ── Power-off button ──────────────────────────────────────────────
        PlasmaComponents.Button {
            Layout.fillWidth: true
            text: "Power Off Controller"
            icon.name: "system-shutdown"
            enabled: plasmoid.rootItem.controllerPresent
            onClicked: {
                plasmoid.rootItem.lastError = ""
                powerOffSource.powerOff()
                plasmoid.expanded = false
            }

            // Access the power-off DataSource from main.qml via rootItem
            Plasma5Support.DataSource {
                id: powerOffSource
                engine: "executable"
                connectedSources: []

                onNewData: function(source, data) {
                    disconnectSource(source)
                    var exit = data["exit code"] !== undefined ? data["exit code"] : 0
                    if (exit !== 0) {
                        plasmoid.rootItem.lastError =
                            "power-off failed — is the controller on Bluetooth?"
                    } else {
                        plasmoid.rootItem.lastError = ""
                    }
                }

                function powerOff() {
                    connectSource("dualsensectl power-off")
                }
            }
        }

        // ── Refresh button ────────────────────────────────────────────────
        PlasmaComponents.Button {
            Layout.fillWidth: true
            text: "Refresh"
            icon.name: "view-refresh"
            onClicked: plasmoid.rootItem.pollNow()
        }
    }
}
