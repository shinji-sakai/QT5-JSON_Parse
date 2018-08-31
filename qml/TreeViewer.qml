import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQml.Models 2.3

Flickable {
    clip: true
    anchors.fill: parent
    anchors.margins: 5
    contentWidth: width - 10
    contentHeight: content.height + 10
    flickableDirection: Flickable.VerticalFlick
    property var json

    JSONNode {
        id: content
        isRoot: true
    }

    ScrollBar.vertical: ScrollBar {}

    onJsonChanged: {
        content.value = json;
        content.filter(filter.text)
    }

    function getJSON() {
        return content.getJSON();
    }

    Component.onCompleted: root.filterChanged.connect(content.filter)
}
