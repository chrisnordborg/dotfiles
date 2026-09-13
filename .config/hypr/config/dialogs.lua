-----------------------------------------------------------
-- GTK / QT DIALOGS
-----------------------------------------------------------

hl.window_rule({
    name = "prompts",

    match = {
        title = "Open|Save|Preferences|Settings|Authentication",
    },

    float = true,
    center = true,
})


-----------------------------------------------------------
-- FILE PICKERS
-----------------------------------------------------------

hl.window_rule({
    name = "file_pickers",

    match = {
        class = "org\\.gnome\\.GtkFileChooserDialog|xdg-desktop-portal",
    },

    float = true,
    center = true,
})
