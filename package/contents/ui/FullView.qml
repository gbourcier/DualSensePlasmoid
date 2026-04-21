import QtQuick
import QtQuick.Layouts
import QtQuick.Dialogs
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
                source: Plasmoid.icon
                isMask: true
                opacity: root.controllerPresent ? 1.0 : 0.4
                color: {
                    if (!root.controllerPresent) return Kirigami.Theme.textColor
                    if (root.batteryPercent < 5)  return Kirigami.Theme.negativeTextColor
                    if (root.batteryPercent < 30) return Kirigami.Theme.neutralTextColor
                    return Kirigami.Theme.textColor
                }
                Layout.preferredWidth:  Kirigami.Units.iconSizes.medium
                Layout.preferredHeight: Kirigami.Units.iconSizes.medium
            }

            ColumnLayout {
                spacing: 0
                Layout.fillWidth: true

                PlasmaComponents.Label {
                    text: Plasmoid.title
                    font.weight: Font.Medium
                }

                PlasmaComponents.Label {
                    text: {
                        if (!root.controllerPresent)
                            return "Not connected"
                        var s = root.batteryPercent + "%"
                        if (root.isCharging) s += " — charging"
                        return s
                    }
                    font.pointSize: Kirigami.Theme.smallFont.pointSize
                    opacity: 0.7
                }
            }
        }

        // ── Battery bar ───────────────────────────────────────────────────
        PlasmaComponents.ProgressBar {
            visible: root.controllerPresent
            Layout.fillWidth: true
            value: root.controllerPresent
                   ? root.batteryPercent / 100.0
                   : 0
        }

        // ── Error message ─────────────────────────────────────────────────
        PlasmaComponents.Label {
            visible: root.lastError !== ""
            text:    root.lastError
            color:   Kirigami.Theme.negativeTextColor
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            font.pointSize: Kirigami.Theme.smallFont.pointSize
        }

        // ── Lightbar color ────────────────────────────────────────────────
        PlasmaComponents.Button {
            Layout.fillWidth: true
            text: "Lightbar Color"
            icon.name: "color-picker"
            enabled: root.controllerPresent
            onClicked: colorDialog.open()
        }

        // ── Power-off button ──────────────────────────────────────────────
        PlasmaComponents.Button {
            Layout.fillWidth: true
            text: "Power Off Controller"
            icon.name: "system-shutdown"
            enabled: root.controllerPresent
            onClicked: {
                root.lastError = ""
                powerOffSource.powerOff()
                root.expanded = false
            }

            Plasma5Support.DataSource {
                id: powerOffSource
                engine: "executable"
                connectedSources: []

                onNewData: function(source, data) {
                    powerOffSource.disconnectSource(source)
                    var exit = data["exit code"] !== undefined ? data["exit code"] : 0
                    if (exit !== 0) {
                        root.lastError =
                            "power-off failed — is the controller on Bluetooth?"
                    } else {
                        root.lastError = ""
                    }
                }

                function powerOff() {
                    powerOffSource.connectSource("dualsensectl power-off")
                }
            }
        }

        ColorDialog {
            id: colorDialog
            onAccepted: lightbarSource.setColor(selectedColor)
        }

        Plasma5Support.DataSource {
            id: lightbarSource
            engine: "executable"
            connectedSources: []
            onNewData: function(source, data) { lightbarSource.disconnectSource(source) }
            function setColor(c) {
                var r = Math.round(c.r * 255)
                var g = Math.round(c.g * 255)
                var b = Math.round(c.b * 255)
                lightbarSource.connectSource("dualsensectl lightbar " + r + " " + g + " " + b)
            }
        }

    }
}
