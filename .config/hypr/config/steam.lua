-----------------------------------------------------------
-- STEAM GAMES
-----------------------------------------------------------

hl.window_rule({
    name = "steam_games",
    match = {
        class = "^steam_app_.*$",
    },
    float = true,
    no_anim = true,
    no_initial_focus = true,
    border_size = 0
})


-----------------------------------------------------------
-- STEAM CLIENT
-----------------------------------------------------------

hl.window_rule({
    name = "steam_client",
    match = {
        class = "^steam$",
    },
    opacity = 0.90,
})
