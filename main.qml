import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import RaspiDACNetwork 1.0
import QtGraphicalEffects 1.0
import "content"
import "javascript/raspiDAC.js" as RaspiDAC

ApplicationWindow {
    id: app
    title: qsTr("RaspiDAC")

    //    width: 600
    //    height: 1024
    //    property real scaling: 1

    width: 1080
    height: 1920
    property real scaling: 2

    visible: true

    property int mode: 0

    Component.onCompleted: {
        console.log("scaling: " + app.scaling);
    }

    RaspiDACNetwork {
        id: network
        onAlbumartChanged: {
            if (network.albumart.length > 0)
                albumArtImage.source = network.albumart;
            else
                albumArtImage.source = "images/logo.png";
        }
        onTitelChanged: { textTitel.text = network.titel; }
        onAlbumChanged: { textAlbum.text = network.album }
        onArtistChanged: {
            textArtist.text = network.artist;
            //textArtist.setText(network.artist)
        }
        onPlayModeChanged: {
            if (network.playMode === 0)
                playButtonImage.source = "images/pause.png";
            else
                playButtonImage.source = "images/play.png";
        }
        onGuiModeChanged: { switch (network.guiMode) {
            case 0: //Standby
                powerButtonImage.source = "images/power_white.png"
                playerButtonEnabled.source = "images/disabled.png"
                radioButtonEnabled.source = "images/disabled.png"
                inputButtonEnabled.source = "images/disabled.png"
                break;
            case 1: //UPNP
                powerButtonImage.source = "images/power_red.png"
                playerButtonEnabled.source = "images/enabled.png"
                radioButtonEnabled.source = "images/disabled.png"
                inputButtonEnabled.source = "images/disabled.png"
                break;
            case 2: //Radio
                powerButtonImage.source = "images/power_red.png"
                playerButtonEnabled.source = "images/disabled.png"
                radioButtonEnabled.source = "images/enabled.png"
                inputButtonEnabled.source = "images/disabled.png"
                break;
            case 3: //Input
                powerButtonImage.source = "images/power_red.png"
                playerButtonEnabled.source = "images/disabled.png"
                radioButtonEnabled.source = "images/disabled.png"
                inputButtonEnabled.source = "images/enabled.png"
                break;
            }
        }
        onInitializedChanged: {
            console.log("Renderer nicht gefunden!");
            dlgNetworkError.visible = true;

        }
    }

    property int appstate: Qt.application.state

    onAppstateChanged: {
        if(Qt.application.state === Qt.ApplicationActive && stackView.depth > 1) {
            stackView.pop({item: null, immediate: true});
            textStatuszeile.text = stackView.currentItem.name;
        }
    }

    Rectangle {
        id: root
        color: "#E3905C"
        anchors.fill: parent
    }

    toolBar: BorderImage {
        id: header
        border.bottom: 8
        source: "images/toolbar.png"
        width: parent.width
        height: 120

        Rectangle {
            id: setupButton
            width: height
            height: header.height - 10
            radius: 4
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 45

            color: setupButtonMouse.pressed ? "grey" : "transparent"

            Image {
                anchors.fill: parent
                source: "images/setup_white.png"
            }

            MouseArea {
                id: setupButtonMouse
                anchors.fill: parent
                anchors.margins: -10
                onClicked: {
                    if (mainPage.state == "setupVisible") {
                        mainPage.state = "nothingVisible"
                    } else {
                        mainPage.state = "setupVisible"
                    }
                }
            }
        }

        Rectangle {
            id: homeButton
            width: height
            height: header.height -10
            radius: 4
            anchors.verticalCenter: parent.verticalCenter
            anchors.right:  setupButton.left
            anchors.rightMargin: 10

            color: homeButtonMouse.pressed ? "grey" : "transparent"

            Image {
                id: homeButtonImage
                anchors.fill: parent
                anchors.margins: 15
                source: "images/navigation_home.png"
            }

            MouseArea {
                id: homeButtonMouse
                anchors.fill: parent
                anchors.margins: -10
                onClicked: {
                    stackView.pop(null)
                    textStatuszeile.text = stackView.currentItem.name;
                    mainPage.state = "nothingVisible";
                }
            }
        }

        Rectangle {
            id: powerButton
            width: height
            height: header.height -10
            radius: 4
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 45

            color: powerButtonMouse.pressed ? "grey" : "transparent"

            Image {
                id: powerButtonImage
                anchors.fill: parent
                anchors.margins: 15
                source: "images/power_white.png"
            }

            MouseArea {
                id: powerButtonMouse
                anchors.fill: parent
                anchors.margins: -10
                onClicked: {
                    if (network.guiMode > 0)
                        network.guiModeSelected(0)
                }
            }
        }

        Text {
            id: textStatuszeile
            font.pointSize: 18
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            color: "white"
            text: "RaspiDAC"
        }

    }

    ColumnLayout{
        spacing: 2

        Rectangle {
            Layout.alignment: Qt.AlignCenter
            color: "white"
            Layout.preferredWidth: root.width
            Layout.preferredHeight: root.height * 0.2
            z: 2

            Rectangle {
                id: albumArt
                height: parent.height - 20
                width: parent.height - 20
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 45

                Image {
                    id: albumArtImage
                    anchors.fill: parent
                    source: "images/logo.png"
                }
            }

            ColumnLayout {
                anchors.left: albumArt.right
                anchors.leftMargin: 30
                anchors.verticalCenter: parent.verticalCenter
                TextTicker {
                    id: textTitel
                    width: app.width - 0.2 * app.height - 50
                    font.pointSize: 16
                    font.bold: true
                    color: "black"
                    text: "Titel"
                }

                TextTicker {
                    id: textArtist
                    width: app.width - 0.2 * app.height - 50
                    font.pointSize: 14
                    color: "black"
                    text: "Artist"
                }

                TextTicker {
                    id: textAlbum
                    width: app.width - 0.2 * app.height - 50
                    font.pointSize: 12
                    color: "black"
                    text: "Album"
                }
            }

        }

        Rectangle {
            Layout.alignment: Qt.AlignCenter
            color: "white"
            Layout.preferredWidth: root.width
            Layout.preferredHeight: root.height * 0.55
            z: 1
            StackView {
                id: stackView
                anchors.fill: parent
                // Implements back key navigation
                focus: true
                Keys.onReleased: if (event.key === Qt.Key_Back) {
                                     if (stackView.depth > 1) {
                                         stackView.pop();
                                         textStatuszeile.text = stackView.currentItem.name;
                                     } else {
                                         mainPage.state = "nothingVisible";
                                     }
                                     event.accepted = true;
                                 }

                initialItem: Item {
                    id: mainPage
                    width: parent.width
                    height: parent.height
                    z: -1

                    readonly property string name: "RaspiDAC"

                    ColumnLayout {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.fill: parent
                        spacing: 1
                        Rectangle {
                            id: radioButton
                            Layout.fillWidth: true
                            height: 150
                            color: "transparent"
                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 30 * scaling
                                Rectangle {
                                    color: "transparent"
                                    width: height
                                    height: 52 * scaling
                                    Image {
                                        anchors.fill: parent
                                        id: radioButtonEnabled
                                        source: "images/disabled.png"

                                    }
                                }
                                Rectangle {
                                    width: 104 * scaling
                                    height: 120 * scaling
                                    color: "transparent"
                                    Image {
                                        anchors.fill: parent
                                        source: "images/radio.png"

                                    }
                                }
                                Rectangle {
                                    width: 52 * scaling
                                    height: width
                                    color: "transparent"
                                    Image {
                                        anchors.fill:parent
                                        source: "images/next.png"

                                    }
                                }
                            }

                            MouseArea {
                                id: radioButtonMouse
                                width: parent.width / 2
                                height: parent.height
                                anchors.left: parent.left
                                onClicked: {
                                    if (network.guiMode != 2)
                                        network.guiModeSelected(2)
                                }
                            }

                            MouseArea {
                                id: radioButtonMouseList
                                width: parent.width / 2
                                height: parent.height
                                anchors.left: radioButtonMouse.right
                                onClicked: {
                                    if(network.initialized) {
                                        mode = 2;
                                        stackView.push(Qt.resolvedUrl("content/List.qml"));
                                    }
                                }
                            }
                        }
                        Rectangle {
                            id: playerButton
                            Layout.fillWidth: true
                            height: 150
                            color: "transparent"
                            //color: playerButtonMouse.pressed ? "grey" : "transparent"
                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 30 * scaling
                                Rectangle {
                                    color: "transparent"
                                    width: height
                                    height: 52 * scaling
                                    Image {
                                        anchors.fill: parent
                                        id: playerButtonEnabled
                                        source: "images/disabled.png"

                                    }
                                }
                                Rectangle {
                                    width: 104 * scaling
                                    height: 120 * scaling
                                    color: "transparent"
                                    Image {
                                        anchors.fill: parent
                                        source: "images/player.png"

                                    }
                                }
                                Rectangle {
                                    width: height
                                    height: 52 * scaling
                                    color: "transparent"
                                    Image {
                                        anchors.fill:parent
                                        source: "images/next.png"

                                    }
                                }
                            }

                            MouseArea {
                                id: playerButtonMouse
                                width: parent.width / 2
                                height: parent.height
                                anchors.left: parent.left
                                onClicked: {
                                    if (network.guiMode != 1)
                                        network.guiModeSelected(1)
                                }
                            }

                            MouseArea {
                                id: playerButtonMouseList
                                width: parent.width / 2
                                height: parent.height
                                anchors.left: playerButtonMouse.right
                                onClicked: {
                                    if(network.initialized) {
                                        //                                    mode = 1;
                                        //                                    stackView.push(Qt.resolvedUrl("content/List.qml"));
                                    }
                                }
                            }
                        }
                        Rectangle {
                            id: inputButton
                            Layout.fillWidth: true
                            height: 150
                            color: "transparent"
                            //color: inputButtonMouse.pressed ? "grey" : "transparent"
                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 30 * scaling
                                Rectangle {
                                    color: "transparent"
                                    width: height
                                    height: 52 * scaling
                                    Image {
                                        anchors.fill: parent
                                        id: inputButtonEnabled
                                        source: "images/disabled.png"

                                    }
                                }
                                Rectangle {
                                    width: 104 * scaling
                                    height: 120 * scaling
                                    color: "transparent"
                                    Image {
                                        anchors.fill: parent
                                        source: "images/input.png"

                                    }
                                }
                                Rectangle {
                                    width: height
                                    height: 52 * scaling
                                    color: "transparent"
                                    Image {
                                        anchors.fill:parent
                                        source: "images/next.png"

                                    }
                                }
                            }

                            MouseArea {
                                id: inputButtonMouse
                                width: parent.width / 2
                                height: parent.height
                                anchors.left: parent.left
                                onClicked: {
                                    if (network.guiMode != 3)
                                        network.guiModeSelected(3)
                                }
                            }

                            MouseArea {
                                id: inputButtonMouseList
                                width: parent.width / 2
                                height: parent.height
                                anchors.left: inputButtonMouse.right
                                onClicked: {
                                    if(network.initialized) {
                                        mode = 3;
                                        stackView.push(Qt.resolvedUrl("content/List.qml"));
                                    }
                                }
                            }

                        }
                    }
                    states: [
                        State {
                            name: "infoVisible"
                            PropertyChanges { target: setupMenu; y: -700 }
                        },
                        State {
                            name: "setupVisible"
                            PropertyChanges { target: setupMenu; y: -20 }
                        },
                        State {
                            name: "nothingVisible"
                            PropertyChanges { target: setupMenu; y: -700 }
                        }

                    ]
                }
            }
        }

        Rectangle {
            Layout.alignment: Qt.AlignBottom
            color: "white"
            Layout.preferredWidth: root.width
            Layout.preferredHeight: root.height * 0.25
            z: 3
            ColumnLayout {
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 30
                RowLayout {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 10
                    Rectangle {
                        id: previousButton
                        width: height
                        height: scaling * 70
                        border.width: 5
                        border.color: "#E3905C"
                        radius: 5 * scaling
                        color: previousButtonMouse.pressed ? "grey" : "transparent"

                        Image {
                            anchors.fill: parent
                            anchors.margins: 10 * scaling
                            source:  "images/rewind.png"
                        }
                        MouseArea {
                            id: previousButtonMouse
                            anchors.fill: parent
                            onClicked: {
                                network.previous();
                            }
                        }
                    }
                    Rectangle {
                        id: playButton
                        width: height
                        height: 80 * scaling
                        border.width: 5
                        border.color: "#E3905C"
                        radius: 5 * scaling
                        color: playButtonMouse.pressed ? "grey" : "transparent"

                        Image {
                            id: playButtonImage
                            anchors.fill: parent
                            anchors.margins: 10 * scaling
                            source:  "images/play.png"
                        }
                        MouseArea {
                            id: playButtonMouse
                            anchors.fill: parent
                            onClicked: {
                                network.play();
                            }
                        }
                    }
                    Rectangle {
                        id: nextButton
                        width: height
                        height: 70 * scaling
                        border.width: 5
                        border.color: "#E3905C"
                        radius: 5 * scaling
                        color: nextButtonMouse.pressed ? "grey" : "transparent"

                        Image {
                            anchors.fill: parent
                            anchors.margins: 10 * scaling
                            source:  "images/forward.png"
                        }
                        MouseArea {
                            id: nextButtonMouse
                            anchors.fill: parent
                            onClicked: {
                                network.next();
                            }
                        }
                    }
                }
                RowLayout {
                    spacing: 10
                    anchors.horizontalCenter: parent.horizontalCenter
                    Rectangle {
                        id: volDownButton
                        width: 108 * scaling
                        height: 60 * scaling
                        border.width: 5
                        border.color: "#E3905C"
                        radius: 5 * scaling
                        color: volDownButtonMouse.pressed ? "grey" : "transparent"

                        Image {
                            anchors.fill: parent
                            anchors.margins: 10 * scaling
                            source:  "images/vol-.png"
                        }
                        MouseArea {
                            id: volDownButtonMouse
                            anchors.fill: parent
                            onPressed: network.volDownStart()
                            onReleased: network.volDownStop()
                        }
                    }
                    Rectangle {
                        id: muteButton
                        width: height
                        height: 70 * scaling
                        border.width: 5
                        border.color: "#E3905C"
                        radius: 5 * scaling
                        color: muteButtonMouse.pressed ? "grey" : "transparent"

                        Image {
                            anchors.fill: parent
                            anchors.margins: 10 * scaling
                            source:  "images/mute_on.png"
                        }
                        MouseArea {
                            id: muteButtonMouse
                            anchors.fill: parent
                            onClicked: network.mute()
                        }
                    }
                    Rectangle {
                        id: volUpButton
                        width: 108 * scaling
                        height: 60 * scaling
                        border.width: 5
                        border.color: "#E3905C"
                        radius: 5 * scaling
                        color: volUpButtonMouse.pressed ? "grey" : "transparent"

                        Image {
                            anchors.fill: parent
                            anchors.margins: 10 * scaling
                            source:  "images/vol+.png"
                        }
                        MouseArea {
                            id: volUpButtonMouse
                            anchors.fill: parent
                            onPressed: network.volUpStart()
                            onReleased: network.volUpStop()
                        }
                    }
                }
            }
        }

    }



    ListModel {
        id: setupModel
        ListElement {
            title: "Einstellungen"
        }
        ListElement {
            title: "Amp (PM8000)"
            page: "content/PM8000.qml"
            name: "PM8000"
        }
        ListElement {
            title: "TV (Panasonic Viera)"
            page: "content/Viera.qml"
            name: "Panasonic Viera"
        }
        ListElement {
            title: "System"
            page: "content/SystemSetup.qml"
            name: "Setup - System"
        }
        ListElement {
            title: "Verbinden..."
            page: ""
            name: "Verbinden..."
        }
    }

    Rectangle {
        id: setupMenu
        width: 380
        height: 565
        anchors.right: parent.right
        anchors.rightMargin: 20
        color: "transparent"
        z: 99
        y: -700

        Rectangle {
            width: 340
            height: 525
            anchors.centerIn: parent
            color: "white"
            border.color: "grey"

            ListView {
                anchors.fill: parent
                model: setupModel
                delegate: Rectangle {
                    width: 340
                    height: 105
                    color: index == setupMouse.pressed ? "lightgrey" : "transparent"
                    border.color: "grey"
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 25
                        font.family: "Abel"
                        font.pointSize: 16
                        text: title
                    }
                    MouseArea {
                        id: setupMouse
                        anchors.fill: parent
                        onClicked: {
                            if (index === 4)
                            {
                                network.initConnect()
                                mainPage.state = "nothingVisible"
                            } else if (index > 0) {
                                mainPage.state = "nothingVisible"
                                if (stackView.currentItem.name !== name) {
                                    stackView.push(Qt.resolvedUrl(page))
                                    textStatuszeile.text = name;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    DropShadow {
        anchors.fill: source
        horizontalOffset: 4
        verticalOffset: 4
        radius: 14
        samples: 24
        spread: 0.3
        color: "#80000000"
        source: setupMenu
    }

    MessageDialog {
        id: dlgNetworkError
        title: "Fehler"
        text: "Renderer nicht gefunden!\nVersuche zu verbinden..."
        standardButtons: StandardButton.Cancel | StandardButton.Retry
        onAccepted: {
            network.initConnect()
        }
    }

}

/*
*******TODO********
-------------------
-Steuerung der Fernsehers
-Steuerung des PM8000 (Eingänge umschalten)
-Netzwerkkommunikation nur bei eingeschaltetem WLAN
*/
