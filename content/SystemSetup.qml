import QtQuick 2.4
import QtQuick.Controls 1.3
import RaspiDACNetwork 1.0
import "../javascript/raspiDAC.js" as RaspiDAC

Rectangle {
    id: rootSystemSetupPage
    width: parent.width
    height: parent.height
    z: -1

    Component.onCompleted:
    {
        network.getPm8000enable();
        enablePM8000.checked = network.pm8000enable;
    }

    readonly property string name: "Setup - System"

    MouseArea {
        anchors.fill: parent
        onClicked: Global.mainobj.state = "nothingVisible";
    }

    Column {
        anchors.fill: parent

        Item {
            width: parent.width
            height: 150
            SetupCheckbox {
                id: enablePM8000
                bezeichner: "PM8000 Steuerung"
                hilfetext: "Steuerung des Verstärkers PM800 über RaspiDAC."
                onCheckedChanged: {
                    network.setPm8000enable(enablePM8000.checked)
                }
            }
        }
    }

    RaspiDACNetwork {
        id: network
        onPm8000controlChanged: enablePM8000.checked = network.pm8000enable
    }

}

