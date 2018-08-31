import QtQuick 2.9
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0

Item {
    property string title
    width: parent.width
    height: titleText.height
    Label {
        id: titleText
        text: title
        font.pixelSize: Qt.application.font.pixelSize * 2
        topPadding: 20
        leftPadding: 10
        rightPadding: 10
        bottomPadding: 10
        font.bold: true
        visible: false
    }

    Rectangle {
        id: painter
        anchors.fill: titleText
        anchors.margins: -2
        visible: false
        gradient: Gradient {
            GradientStop { position: 0.5; color: "Orange" }
            GradientStop { position: 0.7; color: "Gold" }
        }
    }

    OpacityMask {
        anchors.fill: painter
        source: painter
        maskSource: titleText
    }
}
