-----------------------------------------------------------
-- OPACITY RULES
-----------------------------------------------------------

hl.window_rule({
    name = "core_apps",
    match = {
        class = "Thorium-browser",
    },
    opacity = 0.90,
})


hl.window_rule({
    name = "development_and_tools",
    match = {
        class = "Code|Arduino IDE|dev\\.warp\\.Warp|obsidian|kitty|org\\.gnome\\.Nautilus|org\\.kde\\.ark",
    },
    opacity = 0.80,
})


hl.window_rule({
    name = "theming_and_config",
    match = {
        class = "qt5ct|qt6ct|kvantummanager|nwg-look",
    },
    opacity = 0.80,
})


hl.window_rule({
    name = "system_utilities",
    match = {
        class = "pavucontrol|blueman-manager|nm-(applet|connection-editor)|org\\.kde\\.polkit-kde-authentication-agent-1|polkit-gnome-authentication-agent-1|org\\.freedesktop\\.impl\\.portal\\.desktop\\.(gtk|hyprland)",
    },
    opacity = 0.80,
})


hl.window_rule({
    name = "spotify_edge_cases_A",
    match = {
        class = "Spotify",
    },
    opacity = 0.70,
})


hl.window_rule({
    name = "spotify_edge_cases_B",
    match = {
        title = "^Spotify Free",
    },
    opacity = 0.70,
})


-----------------------------------------------------------
-- FLOATING RULES
-----------------------------------------------------------

hl.window_rule({
    name = "floating_rules",
    match = {
        class = "!class:Floating",
    },
    opacity = 1.0,
})
