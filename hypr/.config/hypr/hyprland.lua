-- ~/.config/hypr/hyprland.lua — Nidal's config, Omarchy look, Gruvbox theme
-- Look-and-feel taken from Omarchy (github.com/basecamp/omarchy, MIT)
-- API reference: /usr/share/hypr/stubs/hl.meta.lua

local HOME      = os.getenv("HOME") or "~"
local mainMod   = "SUPER"
local terminal  = "kitty"
local wallpaper = HOME .. "/Pictures/wallpaper/current.jpg"

-- Gruvbox (Omarchy theme)
local active_border_color   = "rgb(7daea3)"
local inactive_border_color = "rgba(595959aa)"

local function pidof(name)
    local f = io.popen("pidof -s " .. name .. " 2>/dev/null")
    if not f then return false end
    local out = f:read("*l")
    f:close()
    return out ~= nil and out ~= ""
end

------------------------------------------------------------------------
-- Environment
------------------------------------------------------------------------
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("NVD_BACKEND", "direct")

hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "kde")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("XDG_MENU_PREFIX", "plasma-")
-- GTK look comes from gsettings (set by sr-theme-set)

hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")

hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

------------------------------------------------------------------------
-- Monitors
------------------------------------------------------------------------
hl.monitor({ output = "HDMI-A-3", mode = "1920x1200@59.95", position = "0x137",  scale = 1 })
hl.monitor({ output = "HDMI-A-2", mode = "1920x1080@60.0",  position = "1920x0", scale = 1, transform = 1 })

------------------------------------------------------------------------
-- Look and feel (Omarchy)
------------------------------------------------------------------------
hl.config({
    general = {
        gaps_in     = 5,
        gaps_out    = 10,
        border_size = 2,
        col = {
            active_border   = active_border_color,
            inactive_border = inactive_border_color,
        },
        resize_on_border = false,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    decoration = {
        rounding = 0,
        shadow = { enabled = false },
        blur   = { enabled = false },
    },

    group = {
        col = {
            border_active   = active_border_color,
            border_inactive = inactive_border_color,
        },
    },

    animations = { enabled = true },
})

hl.curve("easeOutQuint",   { type = "bezier", points = { { 0.23, 1 },    { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear",         { type = "bezier", points = { { 0, 0 },       { 1, 1 } } })
hl.curve("almostLinear",   { type = "bezier", points = { { 0.5, 0.5 },   { 0.75, 1.0 } } })
hl.curve("quick",          { type = "bezier", points = { { 0.15, 0 },    { 0.1, 1 } } })

hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true, speed = 3.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.1,  bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "fadeSwitch",    enabled = false })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = false })

hl.config({
    dwindle = {
        preserve_split = true,
        force_split    = 2,
    },

    misc = {
        disable_hyprland_logo      = true,
        disable_splash_rendering   = true,
        disable_scale_notification = true,
        force_default_wallpaper    = 0,
        focus_on_activate          = true,
        background_color           = "rgba(282828ff)",
    },

    cursor = {
        no_hardware_cursors      = true,
        hide_on_key_press        = true,
        warp_on_change_workspace = 1,
    },

    binds = {
        hide_special_on_workspace_change = true,
    },

    input = {
        kb_layout          = "fr",
        numlock_by_default = true,
        follow_mouse       = 1,
        touchpad = { natural_scroll = false },
    },

    xwayland = { force_zero_scaling = true },
})

------------------------------------------------------------------------
-- Autostart (runs on start and on every reload; daemons are guarded)
------------------------------------------------------------------------
local function startup()
    hl.exec_cmd("dbus-update-activation-environment --systemd --all")
    hl.exec_cmd("systemctl --user import-environment "
        .. "WAYLAND_DISPLAY DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE HYPRLAND_INSTANCE_SIGNATURE")
    hl.exec_cmd("xhost +si:localuser:root")

    if not pidof("swaybg")   then hl.exec_cmd("swaybg -m fill -i " .. wallpaper) end
    if not pidof("waybar")   then hl.exec_cmd("waybar") end
    if not pidof("mako")     then hl.exec_cmd("mako") end
    if not pidof("hypridle") then hl.exec_cmd("hypridle") end
    if not pidof("polkit-kde-authentication-agent-1") then
        hl.exec_cmd("/usr/libexec/kf6/polkit-kde-authentication-agent-1")
    end
    if not pidof("wl-paste") then hl.exec_cmd("wl-paste --watch cliphist store") end
end

hl.on("hyprland.start", startup)
startup()

------------------------------------------------------------------------
-- Omarchy-style floating TUIs (Wi-Fi, Bluetooth, audio, btop)
------------------------------------------------------------------------
local tuis = "(org.sr.wlctl|org.sr.bluetui|org.sr.wiremix|org.sr.btop|org.sr.editor)"
hl.window_rule({ match = { class = tuis }, float = true })
hl.window_rule({ match = { class = tuis }, center = true })
hl.window_rule({ match = { class = tuis }, size = { 875, 600 } })

------------------------------------------------------------------------
-- Keybindings and theme live in their own files
------------------------------------------------------------------------
for _, f in ipairs({ "keybinds.lua", "theme.lua" }) do
    local path = HOME .. "/.config/hypr/" .. f
    local fh = io.open(path)
    if fh then fh:close(); dofile(path) end
end
