import QtQuick 2.4
import QtQuick.Controls 1.3

import "../javascript/raspiDAC.js" as RaspiDAC

Rectangle {
    width: parent.width
    height: parent.height
    z: -1

    Component.onCompleted: { RaspiDAC.getListItems() }

    ListModel {
        id: radioModel
    }

    ListView {
        anchors.fill: parent

        model: radioModel
        delegate: ListViewDelegate {
            bezeichner: name
            height: (app.mode === 3) ? 200 : 150
            onClicked: {
                RaspiDAC.setListItem(index);
            }
        }
    }
}

