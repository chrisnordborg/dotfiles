-----------------------------------------------------------
-- HYPRLAND CONFIG
-----------------------------------------------------------


-----------------------------------------------------------
-- PROGRAMS
-----------------------------------------------------------

local terminalj= "kitty"
local fileManager = "nautilus"
local menu = "tofi-drun -c ~/.config/tofi/configA --drun-launch=true"
local browser = "zen-browser"
local musicplayer = "rhythmbox"
local notes = "obsidian"
local editor = "intellij"
local colorPicker = "hyprpicker"

-- NOTE:
-- The old config references $editor-alt, but never defines it.
-- Define it here if you actually have an alternate editor.
-- local editorAlt = "..."

local waybarSetup =
    "waybar -c ~/dotfiles/.config/waybar/config_hyprland.jsonc " ..
    "-s ~/dotfiles/.config/waybar/style.css"


-----------------------------------------------------------
-- MONITORS
-----------------------------------------------------------

hl.monitor({
    output = "DP-2",
    mode = "1920x1080",
    position = "0x0",
    scale = 1,
})

hl.monitor({
    output = "DP-3",
    mode = "1920x1080",
    position = "1920x0",
    scale = 1,
})

hl.workspace_rule({
    workspace = "3",
    monitor = "DP-3",
})


-----------------------------------------------------------
-- AUTOSTART
-----------------------------------------------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")
    -- hl.exec_cmd(waybarSetup)
    hl.exec_cmd("quickshell")
    hl.exec_cmd("/usr/bin/dunst")
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("keyd")

    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")

    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("bash ~/dotfiles/.config/scripts/random_wallpaper.sh")
    hl.exec_cmd(browser)
    hl.exec_cmd(terminal)
    hl.exec_cmd("onedrive --monitor")
end)



-----------------------------------------------------------
-- ENVIRONMENT
-----------------------------------------------------------

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- Firefox
-- hl.env("MOZ_ENABLE_WAYLAND", "1")

-- NVIDIA
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("NVD_BACKEND", "direct")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

-- Qt
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("QT_STYLE_OVERRIDE", "kvantum")

-- Toolkit backends
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("CLUTTER_BACKEND", "wayland")

-- XDG
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")


-----------------------------------------------------------
-- GENERAL / LOOK AND FEEL
-----------------------------------------------------------

hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 5,

        --border_size = 2,
        border_size = 0,

--        col = {
--            active_border = {
--                colors = {
                   -- "rgb(8aadf4)",
                   -- "rgb(24273A)",
                   -- "rgb(24273A)",
                   -- "rgb(8aadf4)",
--                    "rgb(24273A)",
--                    "rgb(24273A)",
--                    "rgb(24273A)",
--                    "rgb(27273A)",
--                },
--                angle = 45,
--            },

--            inactive_border = {
--                colors = {
--                    "rgb(24273A)",
--                    "rgb(24273A)",
--                    "rgb(24273A)",
--                    "rgb(27273A)",
--                },
--                angle = 45,
--           },
--        },

        resize_on_border = true,
        allow_tearing = false,
        layout = "dwindle",
    },

    decoration = {
        rounding = 10,

        active_opacity = 1.0,
        inactive_opacity = 0.6,

        blur = {
            enabled = true,
            size = 1,
            passes = 4,
            new_optimizations = true,
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
    },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
        disable_splash_rendering = true,

        -- Disabled during freeze troubleshooting
        vrr = 0,
    },

    render = {
        -- Disabled during freeze troubleshooting
        direct_scanout = false,
    },

    input = {
        kb_layout = "se,us",
        kb_variant = "",
        kb_model = "",

        -- Your old config assigned kb_options twice.
        -- This preserves the actual intended keyboard switching.
        kb_options = "grp:ctrl_space_toggle",
        kb_rules = "",
        follow_mouse = 1,

        -- Wired mouse
        sensitivity = -0.6,

        touchpad = {
            natural_scroll = true,
        },
    },
})


-----------------------------------------------------------
-- ANIMATION CURVES
-----------------------------------------------------------

hl.curve("wind", {
    type = "bezier",
    points = {
        { 0.05, 0.9 },
        { 0.1, 1.05 },
    },
})

hl.curve("winIn", {
    type = "bezier",
    points = {
        { 0.1, 1.1 },
        { 0.1, 1.1 },
    },
})

hl.curve("winOut", {
    type = "bezier",
    points = {
        { 0.3, -0.3 },
        { 0, 1 },
    },
})

hl.curve("liner", {
    type = "bezier",
    points = {
        { 1, 1 },
        { 1, 1 },
    },
})


-----------------------------------------------------------
-- ANIMATIONS
-----------------------------------------------------------

hl.animation({
    leaf = "windows",
    enabled = true,
    speed = 6,
    bezier = "wind",
    style = "slide",
})

hl.animation({
    leaf = "windowsIn",
    enabled = true,
    speed = 6,
    bezier = "winIn",
    style = "slide",
})

hl.animation({
    leaf = "windowsOut",
    enabled = true,
    speed = 5,
    bezier = "winOut",
    style = "slide",
})

hl.animation({
    leaf = "windowsMove",
    enabled = true,
    speed = 5,
    bezier = "wind",
    style = "slide",
})

hl.animation({
    leaf = "border",
    enabled = true,
    speed = 1,
    bezier = "liner",
})

--hl.animation({
--   leaf = "borderangle",
--    enabled = true,
--    speed = 30,
--    bezier = "liner",
--    style = "loop",
--})

hl.animation({
    leaf = "fade",
    enabled = true,
    speed = 10,
    bezier = "default",
})

hl.animation({
   leaf = "workspaces",
   enabled = true,
   speed = 5,
   bezier = "wind",
})


-----------------------------------------------------------
-- INPUT DEVICES
-----------------------------------------------------------

hl.device({
    name = "epic-mouse-v1",
    sensitivity = -0.5,
})


-----------------------------------------------------------
-- LOAD OTHER CONFIGURATION
-----------------------------------------------------------

require("config.keybinds")

require("config.workspaces")
require("config.opacity")
require("config.floating")
require("config.dialogs")
require("config.special")
require("config.steam")
require("config.xwayland")
