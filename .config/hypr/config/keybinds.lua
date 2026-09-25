-----------------------------------------------------------
-- KEYBINDINGS
-----------------------------------------------------------

local main_mod = "ALT"


-----------------------------------------------------------
-- APPLICATIONS
-----------------------------------------------------------

hl.bind(
    main_mod .. " + RETURN",
    hl.dsp.exec_cmd("bash ~/.config/scripts/launch_terminal_last_dir.sh")
)

hl.bind(
    main_mod .. " + B",
    hl.dsp.exec_cmd("zen-browser")
)

hl.bind(
    main_mod .. " + E",
-- This --class forces a new class name for the window rule to target. 
-- Otherwise, since it's a TUI it opens in a terminal which inherits the terminal default class name.
		hl.dsp.exec_cmd("kitty --class 'yazi' yazi")
)

hl.bind(
    main_mod .. " + O",
    hl.dsp.exec_cmd("obsidian")
)

hl.bind(
    main_mod .. " + G",
    hl.dsp.exec_cmd("steam")
)

hl.bind(
    main_mod .. " + C",
    hl.dsp.exec_cmd("intellij")
)

-- OLD CONFIG:
-- bind = $main_mod, S, exec, $editor-alt
--
-- $editor-alt was never defined.
-- Uncomment and modify this once you know what it should launch.
--
-- hl.bind(
--     main_mod .. " + S",
--     hl.dsp.exec_cmd(editorAlt)
-- )


-----------------------------------------------------------
-- WINDOW MANAGEMENT
-----------------------------------------------------------

hl.bind(
    main_mod .. " + Q",
    hl.dsp.window.close()
)

--hl.bind(
--    main_mod .. " + SHIFT + Q",
--    hl.dsp.exit()
--)


hl.bind(
    main_mod .. " + W",
    hl.dsp.window.float({ action = "toggle" })
)

hl.bind(
    main_mod .. " + SPACE",
    hl.dsp.exec_cmd("tofi-drun -c ~/.config/tofi/configA --drun-launch=true")
)

hl.bind(
    main_mod .. " + SHIFT + R",
    hl.dsp.exec_cmd("hyprctl reload")
)

hl.bind(
	  main_mod .. " + ALT + I", 
		hl.dsp.exec_cmd("hyprctl dispatch layoutmsg togglesplit")
)


-- The following is to move the active window to the workspace currently active on the other monitor.
local function move_window_to_other_monitor()
    local monitor = hl.get_active_monitor()

    if monitor == nil then
        return
    end

    if monitor.name == "DP-2" then
        hl.dispatch(hl.dsp.window.move({ monitor = "r" }))
    elseif monitor.name == "DP-3" then
        hl.dispatch(hl.dsp.window.move({ monitor = "l" }))
    end
end

hl.bind(
    main_mod .. " + SHIFT + TAB",
    move_window_to_other_monitor
)




local function move_workspace_to_other_monitor()
    local monitor = hl.get_active_monitor()

    if not monitor then
        return
    end

    if monitor.name == "DP-2" then
        hl.dispatch(
            hl.dsp.workspace.move({ monitor = "r" })
        )
    elseif monitor.name == "DP-3" then
        hl.dispatch(
            hl.dsp.workspace.move({ monitor = "l" })
        )
    end
end

hl.bind(
    main_mod .. " + CONTROL + SHIFT + TAB",
    move_workspace_to_other_monitor
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
    main_mod .. " + LEFT",
    hl.dsp.focus({ direction = "l" })
)

hl.bind(
    main_mod .. " + RIGHT",
    hl.dsp.focus({ direction = "r" })
)

hl.bind(
    main_mod .. " + UP",
    hl.dsp.focus({ direction = "u" })
)

hl.bind(
    main_mod .. " + DOWN",
    hl.dsp.focus({ direction = "d" })
)

hl.bind(
    main_mod .. " + H",
    hl.dsp.focus({ direction = "l" })
)

hl.bind(
    main_mod .. " + J",
    hl.dsp.focus({ direction = "d" })
)

hl.bind(
    main_mod .. " + K",
    hl.dsp.focus({ direction = "u" })
)

hl.bind(
    main_mod .. " + L",
    hl.dsp.focus({ direction = "r" })
)


-----------------------------------------------------------
-- MOVE / SWAP WINDOWS
-----------------------------------------------------------

hl.bind(
    main_mod .. " + SHIFT + H",
    hl.dsp.window.swap({ direction = "l" })
)

hl.bind(
    main_mod .. " + SHIFT + J",
    hl.dsp.window.swap({ direction = "d" })
)

hl.bind(
    main_mod .. " + SHIFT + K",
    hl.dsp.window.swap({ direction = "u" })
)

hl.bind(
    main_mod .. " + SHIFT + L",
    hl.dsp.window.swap({ direction = "r" })
)


-----------------------------------------------------------
-- WORKSPACES
-----------------------------------------------------------

hl.bind(main_mod .. " + 1", hl.dsp.focus({ workspace = "1" }))
hl.bind(main_mod .. " + 2", hl.dsp.focus({ workspace = "2" }))
hl.bind(main_mod .. " + 3", hl.dsp.focus({ workspace = "3" }))
hl.bind(main_mod .. " + 4", hl.dsp.focus({ workspace = "4" }))
hl.bind(main_mod .. " + 5", hl.dsp.focus({ workspace = "5" }))
hl.bind(main_mod .. " + 6", hl.dsp.focus({ workspace = "6" }))
hl.bind(main_mod .. " + 7", hl.dsp.focus({ workspace = "7" }))
hl.bind(main_mod .. " + 8", hl.dsp.focus({ workspace = "8" }))
hl.bind(main_mod .. " + 9", hl.dsp.focus({ workspace = "9" }))
hl.bind(main_mod .. " + 0", hl.dsp.focus({ workspace = "10" }))

hl.bind(
    main_mod .. " + TAB",
    hl.dsp.focus({ workspace = "previous" })
)


-----------------------------------------------------------
-- MOVE WINDOW TO WORKSPACE
-----------------------------------------------------------

hl.bind(
    main_mod .. " + SHIFT + 1",
    hl.dsp.window.move({ workspace = "1" })
)

hl.bind(
    main_mod .. " + SHIFT + 2",
    hl.dsp.window.move({ workspace = "2" })
)

hl.bind(
    main_mod .. " + SHIFT + 3",
    hl.dsp.window.move({ workspace = "3" })
)

hl.bind(
    main_mod .. " + SHIFT + 4",
    hl.dsp.window.move({ workspace = "4" })
)

hl.bind(
    main_mod .. " + SHIFT + 5",
    hl.dsp.window.move({ workspace = "5" })
)

hl.bind(
    main_mod .. " + SHIFT + 6",
    hl.dsp.window.move({ workspace = "6" })
)

hl.bind(
    main_mod .. " + SHIFT + 7",
    hl.dsp.window.move({ workspace = "7" })
)

hl.bind(
    main_mod .. " + SHIFT + 8",
    hl.dsp.window.move({ workspace = "8" })
)

hl.bind(
    main_mod .. " + SHIFT + 9",
    hl.dsp.window.move({ workspace = "9" })
)

hl.bind(
    main_mod .. " + SHIFT + 0",
    hl.dsp.window.move({ workspace = "10" })
)


-----------------------------------------------------------
-- SCROLL THROUGH WORKSPACES
-----------------------------------------------------------

hl.bind(
    main_mod .. " + mouse_down",
    hl.dsp.focus({ workspace = "e+1" })
)

hl.bind(
    main_mod .. " + mouse_up",
    hl.dsp.focus({ workspace = "e-1" })
)


-----------------------------------------------------------
-- MOUSE WINDOW MOVEMENT / RESIZING
-----------------------------------------------------------

hl.bind(
    main_mod .. " + SHIFT + mouse:272",
    hl.dsp.window.drag(),
    { mouse = true }
)

hl.bind(
    main_mod .. " + SHIFT + mouse:273",
    hl.dsp.window.resize(),
    { mouse = true }
)

hl.bind(
    main_mod .. " + Z",
    hl.dsp.window.drag()
)

hl.bind(
    main_mod .. " + X",
    hl.dsp.window.resize()
)

-----------------------------------------------------------
-- RESIZE WINDOWS
-----------------------------------------------------------

hl.bind(
    main_mod .. " + SHIFT + RIGHT",
    hl.dsp.window.resize({ x = 30, y = 0, relative = true })
)

hl.bind(
    main_mod .. " + SHIFT + LEFT",
    hl.dsp.window.resize({ x = -30, y = 0, relative = true })
)

hl.bind(
    main_mod .. " + SHIFT + UP",
    hl.dsp.window.resize({ x = 0, y = -30, relative = true })
)

hl.bind(
    main_mod .. " + SHIFT + DOWN",
    hl.dsp.window.resize({ x = 0, y = 30, relative = true })
)


-----------------------------------------------------------
-- FULLSCREEN
-----------------------------------------------------------

hl.bind(
    main_mod .. " + F",
    hl.dsp.window.fullscreen()
)


-----------------------------------------------------------
-- WLOGOUT
-----------------------------------------------------------

hl.bind(
    main_mod .. " + ESCAPE",
    hl.dsp.exec_cmd("wlogout")
)


-----------------------------------------------------------
-- CLIPBOARD
-----------------------------------------------------------

hl.bind(
    main_mod .. " + V",
    hl.dsp.exec_cmd(
        "cliphist list | tofi -c ~/.config/tofi/configV | cliphist decode | wl-copy"
    )
)


-----------------------------------------------------------
-- COLOR PICKER
-----------------------------------------------------------

hl.bind(
    main_mod .. " + P",
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
    main_mod .. " + SHIFT + W",
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
    main_mod .. " + PRINT",
    hl.dsp.exec_cmd(
        "bash ~/dotfiles/.config/scripts/screenshot.sh area"
    )
)


-----------------------------------------------------------
-- AUDIO OUTPUT
-----------------------------------------------------------

hl.bind(
    main_mod .. " + SHIFT + A",
    hl.dsp.exec_cmd(
        "bash ~/.config/scripts/audio_output_switch.sh tofi"
    )
)


-----------------------------------------------------------
-- NOTES
-----------------------------------------------------------

hl.bind(
    main_mod .. " + SHIFT + N",
    hl.dsp.exec_cmd(
        "bash ~/.config/scripts/create_note.sh tofi"
    )
)


-----------------------------------------------------------
-- CONVERSIONS
-----------------------------------------------------------

hl.bind(
    main_mod .. " + SHIFT + C",
    hl.dsp.exec_cmd(
        "bash ~/.config/scripts/conversions.sh tofi"
    )
)


-----------------------------------------------------------
-- ANDROID FILE TRANSFER
-----------------------------------------------------------

hl.bind(
    main_mod .. " + SHIFT + P",
    hl.dsp.exec_cmd(
        "bash ~/.config/scripts/adb_transfer.sh tofi"
    )
)


-----------------------------------------------------------
-- MOUNT DEVICES
-----------------------------------------------------------

hl.bind(
    main_mod .. " + SHIFT + D",
    hl.dsp.exec_cmd(
        "bash ~/.config/scripts/mount_devices.sh tofi"
    )
)


-----------------------------------------------------------
-- TIMER
-----------------------------------------------------------

hl.bind(
    main_mod .. " + SHIFT + T",
    hl.dsp.exec_cmd(
        "bash ~/.config/scripts/toolbar/timer.sh tofi"
    )
)


-----------------------------------------------------------
-- POMODORO
-----------------------------------------------------------

hl.bind(
    main_mod .. " + SHIFT + P",
    hl.dsp.exec_cmd(
        "bash ~/.config/scripts/toolbar/pomodoro.sh tofi"
    )
)


-----------------------------------------------------------
-- BACKUP
-----------------------------------------------------------

hl.bind(
    main_mod .. " + SHIFT + B",
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
