-----------------------------------------------------------
-- WORKSPACE ASSIGNMENTS
-----------------------------------------------------------

hl.window_rule({
    name = "terminal",
    match = {
        class = "kitty",
    },
    workspace = "1",
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
