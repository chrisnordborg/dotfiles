import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: root

    // Theme
    property color colBg: "#1a1b26"
    property color colFg: "#a9b1d6"
    property color colMuted: "#444b6a"
    property color colCyan: "#0db9d7"
    property color colBlue: "#7aa2f7"
    property color colYellow: "#e0af68"
    property color colWhite: "#ffffff"
    property color colbrblk: "#444b6a"
    property string fontFamily: "JetBrainsMono Nerd Font"
    property int fontSize: 18

    // System data
    property int cpuUsage: 0
    property int memUsage: 0
    property var lastCpuIdle: 0
		property var lastCpuTotal: 0
		property int barHeight: 12

    anchors.top: true
    anchors.left: true
    anchors.right: true
    implicitHeight: 34 

    // The entire bar is transparent
    color: "transparent"


Process {
    id: cpuProc
    command: ["sh", "-c", "head -1 /proc/stat"]
    stdout: SplitParser {
        onRead: data => {
            if (!data) return
            var p = data.trim().split(/\s+/)
            var idle = parseInt(p[4]) + parseInt(p[5])
            var total = p.slice(1, 8).reduce((a, b) => a + parseInt(b), 0)
            if (lastCpuTotal > 0) {
                cpuUsage = Math.round(100 * (1 - (idle - lastCpuIdle) / (total - lastCpuTotal)))
            }
            lastCpuTotal = total
            lastCpuIdle = idle
        }
    }
    Component.onCompleted: running = true
	}

	Process {
    id: memProc
    command: ["sh", "-c", "free | grep Mem"]
    stdout: SplitParser {
        onRead: data => {
            if (!data) return
            var parts = data.trim().split(/\s+/)
            var total = parseInt(parts[1]) || 1
            var used = parseInt(parts[2]) || 0
            memUsage = Math.round(100 * used / total)
        }
    }
    Component.onCompleted: running = true
}

Timer {
    interval: 2000        // Every 2 seconds
    running: true         // Start immediately
    repeat: true          // Keep going forever
		onTriggered: {
			cpuProc.running = true
			memProc.running = true
		}

}


    RowLayout {
        anchors.fill: parent
        anchors.margins: 0
        spacing: 0

        // ─────────────────────────────
        // Workspaces
        // ─────────────────────────────
// Workspaces
Rectangle {
    color: root.colBg
    radius: 6

    Layout.fillHeight: true

    Row {
        id: workspaceRow
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 10	
        anchors.rightMargin: 8
        spacing: 15	

        Repeater {
            model: 10

            Text {
                property var ws: Hyprland.workspaces.values.find(
                    w => w.id === index + 1
                )

                property bool isActive:
                    Hyprland.focusedWorkspace?.id === (index + 1)

                text: index + 1

                color: isActive
                    ? root.colYellow
                    : (ws ? root.colCyan : root.colMuted)

                font {
                    family: root.fontFamily
                    pixelSize: root.fontSize
                    bold: true
                }

                MouseArea {
                    anchors.fill: parent

                    onClicked:
                        Hyprland.dispatch("workspace " + (index + 1))
                }
            }
        }
    }

    implicitWidth: workspaceRow.implicitWidth + barHeight + 12
}

        // Flexible space between sections
        Item {
            Layout.fillWidth: true
        }

        // ─────────────────────────────
        // System data
        // ─────────────────────────────
Rectangle {
    color: root.colBg
    radius: 6

    Layout.fillHeight: true

    Row {
        id: systemRow
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: 8

        // CPU
        Text {
            text: "CPU: " + cpuUsage + "%"
            color: root.colYellow

            font {
                family: root.fontFamily
                pixelSize: root.fontSize
                bold: true
            }
        }

        Rectangle {
            width: 1
            height: barHeight
            color: root.colMuted
        }

        // Memory
        Text {
            text: "Mem: " + memUsage + "%"
            color: root.colCyan

            font {
                family: root.fontFamily
                pixelSize: root.fontSize
                bold: true
            }
        }

        Rectangle {
            width: 1
            height: barHeight 
            color: root.colMuted
        }

				// Clock
				
        Text {
            id: clock
            color: root.colBlue
            font { family: root.fontFamily; pixelSize: root.fontSize +2 ; bold: true }
            text: Qt.formatDateTime(new Date(), "HH:mm")
            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: clock.text = Qt.formatDateTime(new Date(), "HH:mm")
            }

					}
					Column {
				Text {
            id: day
						color: root.colBlue
            font { family: root.fontFamily; pixelSize: root.fontSize - 6; bold: false }
            text: Qt.formatDateTime(new Date(), "ddd")
            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: day.text = Qt.formatDateTime(new Date(), "ddd")
            }
					}
				Text {
            id: date	
            color: root.colBlue
            font { family: root.fontFamily; pixelSize: root.fontSize - 6; bold: false}
            text: Qt.formatDateTime(new Date(), "MMM dd")
            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: date.text = Qt.formatDateTime(new Date(), "MMM dd")
            }
					}
				}
			}

    implicitWidth: systemRow.implicitWidth + barHeight
	}
}

    }

