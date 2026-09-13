-----------------------------------------------------------
-- SPECIAL WORKSPACES
-----------------------------------------------------------

hl.window_rule({
    name = "music",

    match = {
        class = "Spotify|rhythmbox",
    },

    workspace = "special:music",
})


-----------------------------------------------------------
-- QUICK SCRATCH TERMINAL
-----------------------------------------------------------

-- Original configuration had this disabled.
--
-- hl.window_rule({
--     name = "scratch_terminal",
--
--     match = {
--         class = "kitty",
--     },
--
--     workspace = "special:scratch",
-- })
