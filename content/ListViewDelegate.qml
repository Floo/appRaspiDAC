import QtQuick 2.4

Item {
    id: root
    width: parent.width
    height: 100
    property alias bezeichner: bezeichner.text
    property bool selected: false
    property int leftTextMargin: 45
    signal clicked

    Rectangle {
        anchors.fill: parent
        color: myMouse.pressed ? "lightgrey" : "transparent"

        Text {
            id: bezeichner
            anchors.left: parent.left
            anchors.leftMargin: root.leftTextMargin
            anchors.verticalCenter: parent.verticalCenter
            font.family: "Abel"
            font.pointSize: 16
            font.bold: selected
            color: "black"
            //color: root.enabled ? "black" : "grey"
            text: ""
        }

        Rectangle {
            width: parent.width
            height: 2
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            border.color: "grey"
            border.width: 1
        }

        MouseArea {
            id: myMouse
            anchors.fill: parent
            onClicked: root.clicked()
        }
    }
}

