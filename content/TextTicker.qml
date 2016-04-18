import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2

Item {
    id: ticker
    height: tickerText.height
    clip: true
    property string text: ""
    property alias font: tickerText.font
    property alias color: tickerText.color
    onTextChanged: tickerText.startTicker(text)

    Text {
        id: tickerText
        font.pointSize: ticker.pointSize
        color: "black"
        text: ""

        function startTicker(text)
        {
            tickerText.text = text
            if (tickerText.width > ticker.width)
            {
                tickerText.text = text + "              "
                tickerTextAni.to = -tickerText.width
                tickerText.text = tickerText.text + text
                tickerTextTimer.start()
            }
        }

        NumberAnimation on x {
            id: tickerTextAni
            from: 0
            to: -tickerText.width
            running: false
            duration: tickerText.width * 10
            loops: 1
            onStopped: {
                tickerText.x = 0
                tickerTextTimer.start()
            }
        }
        Timer {
            id: tickerTextTimer
            interval: 5000
            onTriggered: tickerTextAni.start()
        }
    }
}

