-----------------------------------------------------------
-- KEYBINDINGS
-----------------------------------------------------------

local mainMod = "ALT"


-----------------------------------------------------------
-- APPLICATIONS
-----------------------------------------------------------

hl.bind(
    mainMod .. " + RETURN",
    hl.dsp.exec_cmd("bash ~/.config/scripts/launch_terminal_last_dir.sh")
)

hl.bind(
    mainMod .. " + B",
    hl.dsp.exec_cmd("zen-browser")
)

hl.bind(
    mainMod .. " + O",
    hl.dsp.exec_cmd("obsidian")
)

hl.bind(
    mainMod .. " + G",
    hl.dsp.focus({ workspace = "10" })
)

hl.bind(
    mainMod .. " + G",
    hl.dsp.exec_cmd("steam")
)

hl.bind(
    mainMod .. " + C",
    hl.dsp.exec_cmd("intellij")
)

-- OLD CONFIG:
-- bind = $mainMod, S, exec, $editor-alt
--
-- $editor-alt was never defined.
-- Uncomment and modify this once you know what it should launch.
--
-- hl.bind(
--     mainMod .. " + S",
--     hl.dsp.exec_cmd(editorAlt)
-- )


-----------------------------------------------------------
-- WINDOW MANAGEMENT
-----------------------------------------------------------

hl.bind(
    mainMod .. " + Q",
    hl.dsp.window.close()
)

hl.bind(
    mainMod .. " + SHIFT + Q",
    hl.dsp.exit()
)

hl.bind(
    mainMod .. " + E",
    hl.dsp.exec_cmd("nautilus")
)

hl.bind(
    mainMod .. " + W",
    hl.dsp.window.float({ action = "toggle" })
)

hl.bind(
    mainMod .. " + SPACE",
    hl.dsp.exec_cmd("tofi-drun -c ~/.config/tofi/configA --drun-launch=true")
)

hl.bind(
    mainMod .. " + SHIFT + R",
    hl.dsp.exec_cmd("hyprctl reload")
)

hl.bind(
	  mainMod .. " + ALT + I", 
		hl.dsp.exec_cmd("hyprctl dispatch layoutmsg togglesplit")
)


-----------------------------------------------------------
-- EMOJI PICKER
-----------------------------------------------------------

hl.bind(
    "SUPER + E",
    hl.dsp.exec_cmd("jome -d | wl-copy")
)


-----------------------------------------------------------
-- MOVE FOCUS
-----------------------------------------------------------

hl.bind(
    mainMod .. " + LEFT",
    hl.dsp.focus({ direction = "l" })
)

hl.bind(
    mainMod .. " + RIGHT",
    hl.dsp.focus({ direction = "r" })
)

hl.bind(
    mainMod .. " + UP",
    hl.dsp.focus({ direction = "u" })
)

hl.bind(
    mainMod .. " + DOWN",
    hl.dsp.focus({ direction = "d" })
)

hl.bind(
    mainMod .. " + H",
    hl.dsp.focus({ direction = "l" })
)

hl.bind(
    mainMod .. " + J",
    hl.dsp.focus({ direction = "d" })
)

hl.bind(
    mainMod .. " + K",
    hl.dsp.focus({ direction = "u" })
)

hl.bind(
    mainMod .. " + L",
    hl.dsp.focus({ direction = "r" })
)


-----------------------------------------------------------
-- MOVE / SWAP WINDOWS
-----------------------------------------------------------

hl.bind(
    mainMod .. " + SHIFT + H",
    hl.dsp.window.swap({ direction = "l" })
)

hl.bind(
    mainMod .. " + SHIFT + J",
    hl.dsp.window.swap({ direction = "d" })
)

hl.bind(
    mainMod .. " + SHIFT + K",
    hl.dsp.window.swap({ direction = "u" })
)

hl.bind(
    mainMod .. " + SHIFT + L",
    hl.dsp.window.swap({ direction = "r" })
)


-----------------------------------------------------------
-- WORKSPACES
-----------------------------------------------------------

hl.bind(mainMod .. " + 1", hl.dsp.focus({ workspace = "1" }))
hl.bind(mainMod .. " + 2", hl.dsp.focus({ workspace = "2" }))
hl.bind(mainMod .. " + 3", hl.dsp.focus({ workspace = "3" }))
hl.bind(mainMod .. " + 4", hl.dsp.focus({ workspace = "4" }))
hl.bind(mainMod .. " + 5", hl.dsp.focus({ workspace = "5" }))
hl.bind(mainMod .. " + 6", hl.dsp.focus({ workspace = "6" }))
hl.bind(mainMod .. " + 7", hl.dsp.focus({ workspace = "7" }))
hl.bind(mainMod .. " + 8", hl.dsp.focus({ workspace = "8" }))
hl.bind(mainMod .. " + 9", hl.dsp.focus({ workspace = "9" }))
hl.bind(mainMod .. " + 0", hl.dsp.focus({ workspace = "10" }))

hl.bind(
    mainMod .. " + TAB",
    hl.dsp.focus({ workspace = "previous" })
)


-----------------------------------------------------------
-- MOVE WINDOW TO WORKSPACE
-----------------------------------------------------------

hl.bind(
    mainMod .. " + SHIFT + 1",
    hl.dsp.window.move({ workspace = "1" })
)

hl.bind(
    mainMod .. " + SHIFT + 2",
    hl.dsp.window.move({ workspace = "2" })
)

hl.bind(
    mainMod .. " + SHIFT + 3",
    hl.dsp.window.move({ workspace = "3" })
)

hl.bind(
    mainMod .. " + SHIFT + 4",
    hl.dsp.window.move({ workspace = "4" })
)

hl.bind(
    mainMod .. " + SHIFT + 5",
    hl.dsp.window.move({ workspace = "5" })
)

hl.bind(
    mainMod .. " + SHIFT + 6",
    hl.dsp.window.move({ workspace = "6" })
)

hl.bind(
    mainMod .. " + SHIFT + 7",
    hl.dsp.window.move({ workspace = "7" })
)

hl.bind(
    mainMod .. " + SHIFT + 8",
    hl.dsp.window.move({ workspace = "8" })
)

hl.bind(
    mainMod .. " + SHIFT + 9",
    hl.dsp.window.move({ workspace = "9" })
)

hl.bind(
    mainMod .. " + SHIFT + 0",
    hl.dsp.window.move({ workspace = "10" })
)


-----------------------------------------------------------
-- SCROLL THROUGH WORKSPACES
-----------------------------------------------------------

hl.bind(
    mainMod .. " + mouse_down",
    hl.dsp.focus({ workspace = "e+1" })
)

hl.bind(
    mainMod .. " + mouse_up",
    hl.dsp.focus({ workspace = "e-1" })
)


-----------------------------------------------------------
-- MOUSE WINDOW MOVEMENT / RESIZING
-----------------------------------------------------------

hl.bind(
    mainMod .. " + SHIFT + mouse:272",
    hl.dsp.window.drag(),
    { mouse = true }
)

hl.bind(
    mainMod .. " + SHIFT + mouse:273",
    hl.dsp.window.resize(),
    { mouse = true }
)

hl.bind(
    mainMod .. " + Z",
    hl.dsp.window.drag()
)

hl.bind(
    mainMod .. " + X",
    hl.dsp.window.resize()
)

-----------------------------------------------------------
-- RESIZE WINDOWS
-----------------------------------------------------------

hl.bind(
    mainMod .. " + SHIFT + RIGHT",
    hl.dsp.window.resize({ x = 30, y = 0, relative = true })
)

hl.bind(
    mainMod .. " + SHIFT + LEFT",
    hl.dsp.window.resize({ x = -30, y = 0, relative = true })
)

hl.bind(
    mainMod .. " + SHIFT + UP",
    hl.dsp.window.resize({ x = 0, y = -30, relative = true })
)

hl.bind(
    mainMod .. " + SHIFT + DOWN",
    hl.dsp.window.resize({ x = 0, y = 30, relative = true })
)


-----------------------------------------------------------
-- FULLSCREEN
-----------------------------------------------------------

hl.bind(
    mainMod .. " + F",
    hl.dsp.window.fullscreen()
)


-----------------------------------------------------------
-- WLOGOUT
-----------------------------------------------------------

hl.bind(
    mainMod .. " + ESCAPE",
    hl.dsp.exec_cmd("wlogout")
)


-----------------------------------------------------------
-- CLIPBOARD
-----------------------------------------------------------

hl.bind(
    mainMod .. " + V",
    hl.dsp.exec_cmd(
        "cliphist list | tofi -c ~/.config/tofi/configV | cliphist decode | wl-copy"
    )
)


-----------------------------------------------------------
-- COLOR PICKER
-----------------------------------------------------------

hl.bind(
    mainMod .. " + P",
    hl.dsp.exec_cmd(
        "bash ~/dotfiles/.config/scripts/colorpicker.sh"
    )
)


-----------------------------------------------------------
-- WALLPAPER
-----------------------------------------------------------

hl.bind(
    "SUPER + W",
    hl.dsp.exec_cmd(
        "bash ~/dotfiles/.config/scripts/select_wallpaper_theme.sh tofi"
    )
)

hl.bind(
    mainMod .. " + SHIFT + W",
    hl.dsp.exec_cmd(
        "bash ~/dotfiles/.config/scripts/random_wallpaper.sh"
    )
)


-----------------------------------------------------------
-- WAYBAR
-----------------------------------------------------------

hl.bind(
    "CTRL + ESCAPE",
    hl.dsp.exec_cmd(
        "killall waybar || waybar -c ~/dotfiles/.config/waybar/config_hyprland.jsonc -s ~/dotfiles/.config/waybar/style.css"
    )
)


-----------------------------------------------------------
-- SCREENSHOTS
-----------------------------------------------------------

hl.bind(
    "PRINT",
    hl.dsp.exec_cmd(
        "bash ~/dotfiles/.config/scripts/screenshot.sh full"
    )
)

hl.bind(
    mainMod .. " + PRINT",
    hl.dsp.exec_cmd(
        "bash ~/dotfiles/.config/scripts/screenshot.sh area"
    )
)


-----------------------------------------------------------
-- AUDIO OUTPUT
-----------------------------------------------------------

hl.bind(
    mainMod .. " + SHIFT + A",
    hl.dsp.exec_cmd(
        "bash ~/.config/scripts/audio_output_switch.sh tofi"
    )
)


-----------------------------------------------------------
-- NOTES
-----------------------------------------------------------

hl.bind(
    mainMod .. " + SHIFT + N",
    hl.dsp.exec_cmd(
        "bash ~/.config/scripts/create_note.sh tofi"
    )
)


-----------------------------------------------------------
-- CONVERSIONS
-----------------------------------------------------------

hl.bind(
    mainMod .. " + SHIFT + C",
    hl.dsp.exec_cmd(
        "bash ~/.config/scripts/conversions.sh tofi"
    )
)


-----------------------------------------------------------
-- ANDROID FILE TRANSFER
-----------------------------------------------------------

hl.bind(
    mainMod .. " + SHIFT + P",
    hl.dsp.exec_cmd(
        "bash ~/.config/scripts/adb_transfer.sh tofi"
    )
)


-----------------------------------------------------------
-- MOUNT DEVICES
-----------------------------------------------------------

hl.bind(
    mainMod .. " + SHIFT + D",
    hl.dsp.exec_cmd(
        "bash ~/.config/scripts/mount_devices.sh tofi"
    )
)


-----------------------------------------------------------
-- TIMER
-----------------------------------------------------------

hl.bind(
    mainMod .. " + SHIFT + T",
    hl.dsp.exec_cmd(
        "bash ~/.config/scripts/toolbar/timer.sh tofi"
    )
)


-----------------------------------------------------------
-- POMODORO
-----------------------------------------------------------

hl.bind(
    mainMod .. " + SHIFT + P",
    hl.dsp.exec_cmd(
        "bash ~/.config/scripts/toolbar/pomodoro.sh tofi"
    )
)


-----------------------------------------------------------
-- BACKUP
-----------------------------------------------------------

hl.bind(
    mainMod .. " + SHIFT + B",
    hl.dsp.exec_cmd(
        "bash ~/.config/scripts/backup.sh snapshot"
    )
)


-----------------------------------------------------------
-- VOLUME / MEDIA
-----------------------------------------------------------

hl.bind(
    "XF86AudioRaiseVolume",
    hl.dsp.exec_cmd("pamixer -i 5")
)

hl.bind(
    "XF86AudioLowerVolume",
    hl.dsp.exec_cmd("pamixer -d 5")
)

hl.bind(
    "XF86AudioMicMute",
    hl.dsp.exec_cmd("pamixer --default-source -m")
)

hl.bind(
    "XF86AudioMute",
    hl.dsp.exec_cmd("pamixer -t")
)

hl.bind(
    "XF86AudioPlay",
    hl.dsp.exec_cmd("playerctl play-pause")
)

hl.bind(
    "XF86AudioPause",
    hl.dsp.exec_cmd("playerctl play-pause")
)

hl.bind(
    "XF86AudioNext",
    hl.dsp.exec_cmd("playerctl next")
)

hl.bind(
    "XF86AudioPrev",
    hl.dsp.exec_cmd("playerctl previous")
)


-----------------------------------------------------------
-- SCREEN BRIGHTNESS
-----------------------------------------------------------

hl.bind(
    "XF86MonBrightnessUp",
    hl.dsp.exec_cmd("brightnessctl s +5%")
)

hl.bind(
    "XF86MonBrightnessDown",
    hl.dsp.exec_cmd("brightnessctl s 5%-")
)
