import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

Item {
    id: compactRoot

    // Access parent PlasmoidItem state through the plasmoid singleton
    readonly property var p: plasmoid

    implicitWidth:  row.implicitWidth
    implicitHeight: row.implicitHeight

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: Kirigami.Units.smallSpacing

        Kirigami.Icon {
            id: controllerIcon
            source: plasmoid.icon
            opacity: root.controllerPresent ? 1.0 : 0.4
            Layout.preferredWidth:  Kirigami.Units.iconSizes.small
            Layout.preferredHeight: Kirigami.Units.iconSizes.small
        }

        PlasmaComponents.Label {
            id: percentLabel
            visible: root.controllerPresent
            text:    root.batteryPercent + "%"
            font.pointSize: Kirigami.Theme.smallFont.pointSize
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.expanded = !root.expanded
    }
}
