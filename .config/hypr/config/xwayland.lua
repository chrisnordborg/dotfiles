-----------------------------------------------------------
-- XWAYLAND
-----------------------------------------------------------

hl.window_rule({
    name = "xwayland",
    match = {
        class = "xwayland:1",
    },
    no_blur = true,
})


-----------------------------------------------------------
-- LEGACY ELECTRON / JAVA
-----------------------------------------------------------

hl.window_rule({
    name = "legacy_electron_and_java",
    match = {
        xwayland = true,
        class = "Spotify|Arduino IDE",
    },
    opacity = 0.75,
})
