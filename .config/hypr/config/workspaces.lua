-----------------------------------------------------------
-- WORKSPACE ASSIGNMENTS
-----------------------------------------------------------
-- Run the app you want, and inside a terminal, 
-- run 'hyprctl clients -j | jq '.[] | {class, initialClass, title, initialTitle, workspace}' 
-- to find out the class/initialClass/title/initialTitle

hl.window_rule({
    name = "terminal",
    match = {
        class = "kitty",
    },
    workspace = "1",
})


hl.window_rule({
	name = "yazi-on-ws2",
	match = { class = "yazi" },
	workspace = "2"
})


hl.window_rule({
    name = "browser",
    match = {
        title = "Zen Browser",
    },
    workspace = "3",
})


hl.window_rule({
    name = "notes",
    match = {
        class = "obsidian",
    },
    workspace = "4",
})


hl.window_rule({
    name = "music",
    match = {
        class = "rhythmbox|spotify",
    },
    workspace = "5",
})


hl.window_rule({
    name = "games",
    match = {
        class = "steam",
    },
    workspace = "10",
})
