import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQml.Models 2.3

Column {
    property string type
    property string field
    property var value
    property real idx
    property bool collapse: !nodeLine.collapse
    property bool isRoot: false
    property int checked: nodeLine.checked
    property var branch: parent.parent
    property int siblingCnt: branch.count
    property int count: childModels.count

    property string f: nodeLine.field
    property string v: type === "object" || type ==="array" ? childModels.count.toString() : nodeLine.value

    signal setChecked(var state);

    width: parent.width
    spacing: 5

    JSONField {
        id: nodeLine
        type: type
    }

    ObjectModel {
        id: childModels
    }

    Column {
        id: childNodes
        visible: (type === "object" || type === "array") && !collapse
        anchors.left: parent.left
        anchors.leftMargin: 30
        width: parent.width - 30
        spacing: 5

        Repeater {
            id: scatter
            model: childModels
        }
    }

    function refresh() {
        type = root.getVariableType(value);

        var oldCnt = childModels.count, cnt, idx, item;

        switch (type) {
        case "object":
            cnt = Object.keys(value).length;

            for (idx = oldCnt; idx >= cnt; idx --) {
                childModels.get(idx - 1).destroy();
                childModels.remove(idx - 1);
            }

            for (;idx < cnt; idx ++) {
                item = jsonNode.createObject(this);
                childModels.append(item);
            }

            Object.keys(value).forEach(function (key, idx) {
                childModels.get(idx).field = key;
                childModels.get(idx).value = value[key];
            })
            break;
        case "array":
            cnt = value.length;

            for (idx = oldCnt; idx >= cnt; idx --) {
                childModels.get(idx).destroy();
                childModels.remove(idx);
            }

            for (;idx < cnt; idx ++) {
                item = jsonNode.createObject(this);
                childModels.append(item);
            }

            value.forEach(function (node, idx) {
                childModels.get(idx).value = node
            })
            break;
        default:
            break;
        }

        if (isRoot == true)
            field = type;
        else if (name === undefined)
            field = "";
        else field = name;
    }

    function clearAll() {
        while (childModels.count) {
            var item = childModels.get(0);
            childModels.remove(0);

            if (item === undefined)
                console.log("Cannot remove undefined object!");
            else
                item.destroy();
        }

        childModels.clear();
    }

    function forceChecked(state) {
        setChecked(state)
        for (var idx = 0; idx < childModels.count; idx ++)
            childModels.get(idx).forceChecked(state);
        if (parent.parent.checkState)
            parent.parent.checkState();
    }

    function checkState() {
        var checked = true, unchecked = true;
        for (var idx = 0; idx < childModels.count; idx ++)
        {
            checked = checked && (childModels.get(idx).checked === Qt.Checked);
            unchecked = unchecked && (childModels.get(idx).checked === Qt.Unchecked);
        }
        if (checked)
            setChecked(Qt.Checked);
        else if (unchecked)
            setChecked(Qt.Unchecked);
        else
            setChecked(Qt.PartiallyChecked);
    }

    function kill() {
        clearAll();
        destroy();
    }

    function filter(regExp) {
        var vis = false;
        vis = vis || nodeLine.filter(regExp);
        for (var idx = 0; idx < childModels.count; idx ++) {
            var item = childModels.get(idx);
            item.visible = item.filter(regExp);
            vis = vis || item.visible;
        }
        return vis;
    }

    function sortNode(ascending) {
        var list = [], idx, sign = ascending ? 1 : -1;
        for (idx = childModels.count; idx > 0; idx --)
            list.push(childModels.get(idx - 1));
        if (type === "object") {
            list.sort(function (a, b) {
                if (a.f > b.f)
                    return sign * 1;
                else if (a.f < b.f)
                    return sign * -1;
                return 0;
            })
            childModels.clear();
            list.forEach(function (item) {
                childModels.append(item);
            })
        }
        else {
            list.sort(function (a, b) {
                if (a.v > b.v)
                    return sign * 1;
                else if (a.v < b.v)
                    return sign * -1;
                return 0;
            })
            childModels.clear();
            list.forEach(function (item) {
                childModels.append(item);
            })
        }
    }

    function bringUp() { parent.parent.moveUp(idx); }
    function bringDown() { parent.parent.moveDown(idx); }
    function moveUp(idx) { childModels.move(idx, idx - 1); }
    function moveDown(idx) { childModels.move(idx, idx + 1); }

    function getJSON() {
        var jsonValue, idx;
        switch (type) {
        case "array":
            jsonValue = [];
            for(idx = 0; idx < childModels.count; idx ++)
                jsonValue.push(childModels.get(idx).getJSON());
            break;
        case "object":
            jsonValue = {};
            for(idx = 0; idx < childModels.count; idx ++)
                jsonValue[childModels.get(idx).field] = childModels.get(idx).getJSON();
            break;
        default:
            jsonValue = value;
            break;
        }
    }

    onValueChanged: refresh()
    Component.onCompleted: {
        clearAll();
        refresh()
    }
}
