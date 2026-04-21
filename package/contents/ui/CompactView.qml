import QtQuick
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami

Item {
    id: compactRoot

    implicitWidth:  controllerIcon.implicitWidth
    implicitHeight: controllerIcon.implicitHeight

    Kirigami.Icon {
        id: controllerIcon
        anchors.fill: parent
        source: Plasmoid.icon
        isMask: true
        opacity: root.controllerPresent ? 1.0 : 0.4
        color: {
            if (!root.controllerPresent) return Kirigami.Theme.textColor
            if (root.batteryPercent < 5)  return Kirigami.Theme.negativeTextColor
            if (root.batteryPercent < 30) return Kirigami.Theme.neutralTextColor
            return Kirigami.Theme.textColor
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.expanded = !root.expanded
    }
}
