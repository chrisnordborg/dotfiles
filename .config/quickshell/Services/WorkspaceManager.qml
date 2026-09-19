pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland

Singleton {
    id: root

    // Changing this forces consumers of the workspace model
    // to reevaluate after Hyprland state has been refreshed.
    property int workspaceRevision: 0

    Timer {
        id: workspaceRefreshTimer

        interval: 50
        repeat: false

        onTriggered: {
            Hyprland.refreshWorkspaces()
            Hyprland.refreshMonitors()

            // Give the Hyprland module a moment to update its
            // workspace/monitor objects before rebuilding models.
            Qt.callLater(function() {
                root.workspaceRevision++
            })
        }
    }

    function requestWorkspaceRefresh() {
        workspaceRefreshTimer.restart()
    }

    function activateNextFreeWorkspace() {
        let nextFree = getNextFreeWorkspace();
        activateWorkspaceById(nextFree);
    }

    function activateWorkspaceById(id) {
        Hyprland.dispatch(`hl.dsp.focus({workspace = ${id}})`);
    }

    function getAllNumberedWorkspaces() {
        // Establish a reactive dependency on workspaceRevision.
        let revision = root.workspaceRevision;

        let allWorkspaces = Hyprland.workspaces.values;
        let filteredWorkspaces = [];

        for (let workspace in allWorkspaces) {
            let currentWorkspace = allWorkspaces[workspace];

            if (currentWorkspace &&
                !currentWorkspace.name.includes("special")) {
                filteredWorkspaces.push(currentWorkspace);
            }
        }

        return filteredWorkspaces;
    }

    function getNextFreeWorkspace() {
        let workspaceList = getAllNumberedWorkspaces();

        if (workspaceList.length === 0) {
            return 1;
        }

        if (workspaceList[workspaceList.length - 1].id == workspaceList.length) {
            return workspaceList.length + 1;
        } else {
            let prevWorkspace = 0;

            for (let workspace in workspaceList) {
                let currentWorkspace = workspaceList[workspace];

                if (currentWorkspace.id != (prevWorkspace + 1)) {
                    return currentWorkspace.id - 1;
                } else {
                    prevWorkspace = currentWorkspace.id;
                }
            }
        }
    }

    function getNumberOfWorkspaces(monitor) {
        let workspaceList = getWorkspacesForMonitor(monitor);
        return workspaceList.length;
    }

    function getWorkspaceState(workspace) {
        if (workspace.focused == true) {
            return "focused";
        } else if (workspace.active == true) {
            return "active";
        } else {
            return "inactive";
        }
    }

    function getWorkspaceStateIndex(workspace) {
        let state = getWorkspaceState(workspace);

        if (state == "focused") {
            return 0;
        } else if (state == "active") {
            return 1;
        } else {
            return 2;
        }
    }

    function getWorkspacesForMonitor(monitor) {
        // Establish a reactive dependency on workspaceRevision.
        let revision = root.workspaceRevision;

        let allWorkspaces = getAllNumberedWorkspaces();
        let monitorWorkspaces = [];

        for (let workspace in allWorkspaces) {
            let currentWorkspace = allWorkspaces[workspace];

            if (currentWorkspace &&
                currentWorkspace.monitor == monitor) {
                monitorWorkspaces.push(currentWorkspace);
            }
        }

        return monitorWorkspaces;
    }

    Connections {
        target: Hyprland

        function onRawEvent(event) {
            if (event.name === "workspace" ||
                event.name === "workspacev2" ||
                event.name === "moveworkspace" ||
                event.name === "moveworkspacev2") {

                root.requestWorkspaceRefresh();
            }
        }
    }
}

