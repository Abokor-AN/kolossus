import QtQuick 2.15
import SddmComponents 2.0

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: config.BackgroundColor

    property string currentUser: userModel.lastUser
    property int sessionIndex: {
        for (var i = 0; i < sessionModel.rowCount(); i++) {
            var sessionName = (sessionModel.data(sessionModel.index(i, 0), Qt.DisplayRole) || "").toString().toLowerCase()
            if (sessionName.indexOf("uwsm") !== -1 || sessionName.indexOf("hyprland") !== -1)
                return i
        }
        return sessionModel.lastIndex
    }

    Image {
        anchors.fill: parent
        source: config.Background
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: true
    }

    Rectangle {
        anchors.fill: parent
        color: config.OverlayColor
    }

    Rectangle {
        id: panel
        width: Math.min(root.width * 0.72, 760)
        height: Math.min(root.height * 0.52, 500)
        anchors.centerIn: parent
        color: config.PanelColor
        border.color: config.ForegroundColor
        border.width: 2

        Column {
            width: parent.width - 96
            anchors.centerIn: parent
            spacing: 22

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: config.Title
                color: config.AccentColor
                font.family: config.Font
                font.pixelSize: Math.max(28, root.height * 0.045)
                font.bold: true
                font.letterSpacing: 4
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: config.Subtitle
                color: config.ForegroundColor
                opacity: 0.72
                font.family: config.Font
                font.pixelSize: Math.max(13, root.height * 0.016)
                font.letterSpacing: 2
            }

            Item { width: 1; height: 10 }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.currentUser
                color: config.ForegroundColor
                font.family: config.Font
                font.pixelSize: Math.max(17, root.height * 0.022)
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 16

                Text {
                    anchors.verticalCenter: passwordBox.verticalCenter
                    text: "\uf023"
                    color: config.AccentColor
                    font.family: config.Font
                    font.pixelSize: Math.max(21, root.height * 0.027)
                }

                Rectangle {
                    id: passwordBox
                    width: Math.min(root.width * 0.42, 510)
                    height: Math.max(58, root.height * 0.065)
                    color: config.InputColor
                    border.color: password.activeFocus ? config.AccentColor : config.ForegroundColor
                    border.width: password.activeFocus ? 3 : 2
                    clip: true

                    Text {
                        anchors.fill: parent
                        anchors.leftMargin: 20
                        verticalAlignment: Text.AlignVCenter
                        visible: password.text.length === 0 && !password.activeFocus
                        text: config.PasswordPlaceholder
                        color: config.ForegroundColor
                        opacity: 0.48
                        font.family: config.Font
                        font.pixelSize: Math.max(15, root.height * 0.019)
                    }

                    TextInput {
                        id: password
                        anchors.fill: parent
                        anchors.margins: 18
                        verticalAlignment: TextInput.AlignVCenter
                        echoMode: TextInput.Password
                        passwordCharacter: "•"
                        color: config.ForegroundColor
                        selectionColor: config.AccentColor
                        selectedTextColor: config.BackgroundColor
                        font.family: config.Font
                        font.pixelSize: Math.max(17, root.height * 0.021)
                        font.letterSpacing: 5
                        focus: true

                        Keys.onPressed: function(event) {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                errorMessage.text = ""
                                sddm.login(root.currentUser, password.text, root.sessionIndex)
                                event.accepted = true
                            } else if (event.key === Qt.Key_Escape) {
                                password.text = ""
                                event.accepted = true
                            }
                        }
                    }
                }
            }

            Text {
                id: errorMessage
                anchors.horizontalCenter: parent.horizontalCenter
                text: ""
                color: config.ErrorColor
                font.family: config.Font
                font.pixelSize: Math.max(13, root.height * 0.017)
            }
        }
    }

    Text {
        id: clock
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 32
        color: config.ForegroundColor
        font.family: config.Font
        font.pixelSize: Math.max(14, root.height * 0.019)

        function refresh() {
            text = Qt.formatDateTime(new Date(), "ddd dd MMM · HH:mm")
        }

        Component.onCompleted: refresh()
    }

    Timer {
        interval: 1000
        repeat: true
        running: true
        onTriggered: clock.refresh()
    }

    Row {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 32
        spacing: 28

        Text {
            text: "REDÉMARRER"
            color: rebootArea.containsMouse ? config.AccentColor : config.ForegroundColor
            font.family: config.Font
            font.pixelSize: Math.max(12, root.height * 0.014)

            MouseArea {
                id: rebootArea
                anchors.fill: parent
                anchors.margins: -10
                hoverEnabled: true
                onClicked: sddm.reboot()
            }
        }

        Text {
            text: "ÉTEINDRE"
            color: powerArea.containsMouse ? config.AccentColor : config.ForegroundColor
            font.family: config.Font
            font.pixelSize: Math.max(12, root.height * 0.014)

            MouseArea {
                id: powerArea
                anchors.fill: parent
                anchors.margins: -10
                hoverEnabled: true
                onClicked: sddm.powerOff()
            }
        }
    }

    Connections {
        target: sddm

        function onLoginFailed() {
            errorMessage.text = config.LoginFailed
            password.text = ""
            password.forceActiveFocus()
        }

        function onLoginSucceeded() {
            errorMessage.text = ""
        }
    }

    Component.onCompleted: password.forceActiveFocus()
}
