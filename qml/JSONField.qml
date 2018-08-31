import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

RowLayout {
    width: parent.width - 140
    height: valueEdit.height
    property bool collapse: dropper.checked
    property int checked: checker.checkState
    spacing: 2

    property string field: fieldEdit.text
    property string value: valueEdit.text

    ToolButton {
        id: dropper
        width: 20
        height: 20
        anchors.verticalCenter: fieldEdit.verticalCenter

        text: ">"
        checked: false
        rotation: checked ? 90 : 0
        checkable: true
        opacity: type === "array" || type === "object" ? 1 : 0
        onCheckedChanged: {
            if (checked)
                node.swipe();
        }
    }

    CheckBox {
        anchors.verticalCenter: fieldEdit.verticalCenter
        leftPadding: -10
        id: checker
        checked: true
        tristate: true
        onClicked: {
            if (checkState)
                node.forceChecked(Qt.Checked);
            else
                node.forceChecked(Qt.Unchecked);
        }
    }

    TextField {
        id: fieldEdit

        anchors.top: parent.top
        anchors.topMargin: height / 2
        topPadding: 2
        leftPadding: 2
        rightPadding: 2
        bottomPadding: 2
        text: branch.type === "array" ? idx : node.field
        enabled: branch.type === "array" || isRoot ? false : true
        implicitWidth: contentWidth + 10 > 20 ? contentWidth + 10 : 20
        hoverEnabled: true
        placeholderText: "field"

        background: Rectangle {
            radius: 2
            color: parent.focus ? "slategray" : "transparent"
        }
    }

    Label {
        anchors.verticalCenter: fieldEdit.verticalCenter
        id: separator
        opacity: (type === "array" || type === "object") ? false : true
        text: ":"
    }

    TextArea {
        id: valueEdit
        anchors.top: parent.top
        anchors.topMargin: fieldEdit.anchors.topMargin

        topPadding: 2
        leftPadding: 2
        rightPadding: 2
        bottomPadding: 2
        text:   type === "array" ? "[" + childModels.count + "]" :
                type === "object" ? "{" + childModels.count + "}" :
                node.value === undefined ? "" : node.value || node.value !== null ? node.value.toString() : "null"
        enabled: type === "array" || type === "object" ? false : true
        width: implicitWidth
        implicitWidth: parent.width - fieldEdit.width - separator.width - 45
        wrapMode: TextEdit.WrapAnywhere
        hoverEnabled: true
        placeholderText: "value"
        color: !isNaN(text) ? "lightgreen" :
                text == "null" ? "steelblue" :
                text == "true" || text == "false" ? "tomato" : "khaki"

        background: Rectangle {
            radius: 2
            color: parent.focus ? "slategray" : "transparent"
        }
    }

    ToolButton {
        id: sorter
        padding: 4
        anchors.verticalCenter: fieldEdit.verticalCenter

        contentItem: Image {
            source: checked ? "qrc:/images/sortasc.png" : "qrc:/images/sortdesc.png"
            sourceSize.width: 16
            sourceSize.height: 16
            fillMode: Image.Stretch
        }

        background: Rectangle {
            width: 24
            height: 24
            color: "transparent"
            border.width: 1
            border.color: "gray"
            radius: 4
            opacity: 0.2
        }

        checked: true
        checkable: true
        enabled: type === "array" || type === "object" ? true : false
        opacity: enabled ? 1 : 0

        onClicked: node.sortNode(checked);
    }

    ToolButton {
        id: newChild
        padding: 4
        anchors.verticalCenter: fieldEdit.verticalCenter

        contentItem: Image {
            source: "qrc:/images/new.png"
            sourceSize.width: 16
            sourceSize.height: 16
            fillMode: Image.Stretch
        }

        background: Rectangle {
            width: 24
            height: 24
            color: "transparent"
            border.width: 1
            border.color: "gray"
            radius: 4
            opacity: 0.2
        }

        enabled: type === "object" || type === "array"
        opacity: enabled ? 1 : 0.2

        onClicked: node.newItem()
    }

    ToolButton {
        id: bringUp
        padding: 4
        anchors.verticalCenter: fieldEdit.verticalCenter

        contentItem: Image {
            source: "qrc:/images/bringup.png"
            sourceSize.width: 16
            sourceSize.height: 16
            fillMode: Image.Stretch
        }

        background: Rectangle {
            width: 24
            height: 24
            color: "transparent"
            border.width: 1
            border.color: "gray"
            radius: 4
            opacity: 0.2
        }

        enabled: idx != 0 && !isRoot
        opacity: enabled ? 1 : 0.2

        onClicked: node.bringUp()
    }

    ToolButton {
        id: bringDown
        padding: 4
        anchors.verticalCenter: fieldEdit.verticalCenter

        contentItem: Image {
            source: "qrc:/images/bringdown.png"
            sourceSize.width: 16
            sourceSize.height: 16
            fillMode: Image.Stretch
        }

        background: Rectangle {
            width: 24
            height: 24
            color: "transparent"
            border.width: 1
            border.color: "gray"
            radius: 4
            opacity: 0.2
        }

        enabled: idx != siblingCnt - 1 && !isRoot
        opacity: enabled ? 1 : 0.2

        onClicked: node.bringDown()
    }

    function setChecked(state) {
        checker.checkState = state;
    }

    function filter(regExp) {
        if (branch.type !== "array" && fieldEdit.text.toLowerCase().indexOf(regExp.toLowerCase()) !== -1)
            return true;
        if (type !== "array" && type !== "object" && valueEdit.text.toLowerCase().indexOf(regExp.toLowerCase()) !== -1)
            return true;
        return false;
    }

    Component.onCompleted: {
        parent.setChecked.connect(setChecked);
    }
}
