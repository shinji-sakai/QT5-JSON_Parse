import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQml.Models 2.3
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.3
import QtGraphicalEffects 1.0

import "qml"

Rectangle {
    id: root
    color: "#303030"
    enabled: !scheduler.count

    Material.accent: Material.Orange
    signal filterChanged(string regExp)
    property string regExp: filter.text
    property int nID: 0

    Title {
        id: titleFrame
        title: tabBar.currentIndex === 0 ? "JSON - Text Editor" : "JSON - Tree Editor"

        Row {
            anchors.fill: parent
            anchors.topMargin: 10
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            spacing: 10

            layoutDirection: Qt.RightToLeft

            TextField {
                id: filter
                visible: tabBar.currentIndex == 1
                width: 170
                topPadding: 10
                leftPadding: 30
                rightPadding: 10
                bottomPadding: 10
                anchors.verticalCenter: parent.verticalCenter
                background: Rectangle {
                    border.width: 2
                    border.color: "orange"
                    radius: 10
                    color: "transparent"
                }

                Image {
                    anchors.left: parent.left
                    anchors.leftMargin: 4
                    anchors.verticalCenter: parent.verticalCenter
                    source: "qrc:/images/filter.png"

                    width: 20
                    height: 20
                    fillMode: Image.Stretch
                }

                onTextChanged: root.filterChanged(text)
            }

            Button {
                text: "Export"
                visible: tabBar.currentIndex == 1
                anchors.verticalCenter: parent.verticalCenter
                onClicked: saveDialog.open()
            }

            Button {
                text: "Print"
                visible: tabBar.currentIndex == 1
                anchors.verticalCenter: parent.verticalCenter
            }

            Button {
                text: "Open"
                visible: tabBar.currentIndex == 0
                anchors.verticalCenter: parent.verticalCenter
                onClicked: openDialog.open()
            }
        }
    }

    FileDialog {
        id: openDialog
        title: "Open json file"
        nameFilters: [ "JSON files (*.txt *.json)" ]
        folder: shortcuts.documents
        onAccepted: controller.readFile(fileUrl)
    }

    FileDialog {
        id: saveDialog
        selectExisting: false
        title: "Export json data"
        nameFilters: [ "Text format (*.txt)", "JSON format (*.json)", "Spreadsheet format (*.csv)", "PDF format (*.pdf)"]
        folder: shortcuts.documents
        onAccepted: {
            controller.setText(treeViewer.getJSON());
            controller.saveFile(fileUrl, treeViewer.getJSON());
        }
    }

    Item {
        id: scene
        anchors.top: titleFrame.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: tabBar.top
        anchors.margins: 10

        onWidthChanged: controller.setEditAreaSize(x, y, width, height)
        onHeightChanged: controller.setEditAreaSize(x, y, width, height)
        onXChanged: controller.setEditAreaSize(x, y, width, height)
        onYChanged: controller.setEditAreaSize(x, y, width, height)

        Rectangle {
            anchors.fill: parent
            border.width: 2
            border.color: "orange"
            radius: 10
            color: "transparent"

            TreeViewer {
                id: treeViewer
                visible: tabBar.currentIndex == 1
                enabled: visible
                anchors.fill: parent
            }
        }

        Rectangle {
            anchors.centerIn: parent
            border.width: 2
            border.color: "orange"
            radius: 10
            color: "#303030"
            width: 300
            height: 150
            visible: scheduler.count

            ConicalGradient {
                id: busy
                visible: false
                anchors.top: parent.top
                anchors.bottom: inform.top
                anchors.topMargin: 20
                anchors.horizontalCenter: parent.horizontalCenter
                width: height
                gradient: Gradient {
                    GradientStop {
                       position: 0.000
                       color: "#00000000"
                    }
                    GradientStop {
                       position: 1
                       color: "#ff000000"
                    }
                }

                NumberAnimation on angle {
                    from: 0
                    to : 360
                    duration: 1000
                    loops: Animation.Infinite
                }
            }

            ColorOverlay {
                id: colorOverlayer
                anchors.fill: busy
                source: busy
                visible: false
                color: "orange"
            }

            Rectangle {
                id: maskOverlayer
                anchors.fill: colorOverlayer
                radius: width / 2
                visible: false
            }

            OpacityMask {
                source: colorOverlayer
                maskSource: maskOverlayer
                anchors.fill: maskOverlayer
            }

            Text {
                id: inform
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 20

                font.pointSize: 20
                text: "Please wait for the parsing to finish"
                color: "white"
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            }
        }
    }

    TabBar {
        id: tabBar
        position: TabBar.Footer
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        onCurrentIndexChanged: {
            if (currentIndex == 0)
                controller.setText(treeViewer.getJSON());
            else if (currentIndex == 1 && controller.textChanged())
                treeViewer.json = controller.getText();
            controller.showEditArea(currentIndex == 0);
        }

        TabButton {
            text: qsTr("Load JSON")
        }
        TabButton {
            text: qsTr("Tree viewer")
        }
    }

    Component {
        id: jsonNode
        JSONNode {
            idx: ObjectModel.index
        }
    }

    Timer {
        id: extractor
        running: scheduler.count
        repeat: true
        interval: 10
        triggeredOnStart: true
        onTriggered: {
            if (scheduler.get(0).item)
                scheduler.get(0).item.refresh();
            scheduler.remove(0);
        }
    }

    ListModel {
        id: scheduler
    }

    function getVariableType(obj) {
        if (Array.isArray(obj))
            return "array";
        if (typeof obj == "object" && obj === null)
            return "null";
        return typeof obj;
    }

    Component.onCompleted: Qt.application.font.pixelSize = 18
}
