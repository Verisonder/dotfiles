// SR login screen for SDDM — Omarchy lock-screen look, colours from sr-theme-set
import QtQuick 2.15

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: config.bg || "#282828"

    property int sessionIndex: sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0
    property var sessionNames: []
    property string fallbackUser: ""
    property string user: userModel.lastUser !== "" ? userModel.lastUser : fallbackUser
    // the greeter can't read fonts in your home folder, so the theme carries its own copy
    FontLoader { id: jbm; source: "font.ttf" }
    property string ff: jbm.status === FontLoader.Ready ? jbm.font.family : "monospace"

    // collect names from SDDM's models
    Repeater {
        model: sessionModel
        delegate: Item { Component.onCompleted: { var a = root.sessionNames.slice(); a[index] = name; root.sessionNames = a } }
    }
    Repeater {
        model: userModel
        delegate: Item { Component.onCompleted: if (index === 0) root.fallbackUser = name }
    }

    Image {
        anchors.fill: parent
        source: config.background ? Qt.resolvedUrl(config.background) : ""
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: false
    }
    Rectangle { anchors.fill: parent; color: root.color; opacity: 0.45 }

    Rectangle {
        id: box
        width: 650
        height: 100
        anchors.centerIn: parent
        color: Qt.rgba(root.color.r, root.color.g, root.color.b, 0.8)
        border.color: config.fg || "#d4be98"
        border.width: 4
        radius: 0

        TextInput {
            id: pw
            anchors.fill: parent
            anchors.margins: 16
            focus: true
            echoMode: TextInput.Password
            passwordCharacter: "•"
            color: config.fg || "#d4be98"
            font.family: root.ff
            font.pixelSize: 28
            horizontalAlignment: TextInput.AlignHCenter
            verticalAlignment: TextInput.AlignVCenter
            clip: true
            onTextChanged: { msg.text = ""; box.border.color = config.fg || "#d4be98" }
            Keys.onReturnPressed: sddm.login(root.user, text, root.sessionIndex)
            Keys.onEnterPressed: sddm.login(root.user, text, root.sessionIndex)
        }
        Text {
            anchors.centerIn: parent
            visible: pw.text === ""
            text: "Enter Password"
            color: config.fg || "#d4be98"
            opacity: 0.55
            font.family: root.ff
            font.pixelSize: 28
            font.italic: true
        }
    }

    Text {
        id: msg
        anchors.top: box.bottom
        anchors.topMargin: 18
        anchors.horizontalCenter: parent.horizontalCenter
        color: config.red || "#ea6962"
        font.family: root.ff
        font.pixelSize: 18
        text: ""
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            msg.text = "Wrong password"
            box.border.color = config.red || "#ea6962"
            pw.text = ""
            pw.forceActiveFocus()
        }
    }

    // session switcher (click to cycle), bottom centre
    Text {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 40
        anchors.horizontalCenter: parent.horizontalCenter
        text: "‹  " + (root.sessionNames[root.sessionIndex] || "") + "  ›"
        color: config.fg || "#d4be98"
        opacity: sessArea.containsMouse ? 1.0 : 0.7
        font.family: root.ff
        font.pixelSize: 18
        MouseArea {
            id: sessArea
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: function(mouse) {
                var n = Math.max(root.sessionNames.length, 1)
                root.sessionIndex = mouse.button === Qt.RightButton ? (root.sessionIndex + n - 1) % n
                                                                    : (root.sessionIndex + 1) % n
                pw.forceActiveFocus()
            }
        }
    }

    // reboot / power off, bottom right
    Row {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 40
        spacing: 28
        Repeater {
            model: [ { glyph: "\uf0e2", act: "reboot" }, { glyph: "\uf011", act: "off" } ]
            delegate: Text {
                text: modelData.glyph
                color: config.fg || "#d4be98"
                opacity: pa.containsMouse ? 1.0 : 0.7
                font.family: root.ff
                font.pixelSize: 26
                MouseArea {
                    id: pa
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: modelData.act === "reboot" ? sddm.reboot() : sddm.powerOff()
                }
            }
        }
    }

    Component.onCompleted: pw.forceActiveFocus()
}
