-- ~/.config/hypr/keybinds.lua — all keyboard shortcuts
-- Edit here (SUPER+I > Keybindings), then SUPER+I > Reload desktop.
-- Format: hl.bind("MODS + KEY", action)

local HOME     = os.getenv("HOME") or "~"
local mainMod  = "SUPER"
local terminal = "kitty"

------------------------------------------------------------------------
-- Keybinds
------------------------------------------------------------------------
-- Apps
hl.bind(mainMod .. " + Return",  hl.dsp.exec_cmd(terminal))
hl.bind("CTRL + ALT + W",        hl.dsp.exec_cmd(terminal))
hl.bind("CTRL + ALT + F",        hl.dsp.exec_cmd("dolphin"))
hl.bind("CTRL + ALT + B",        hl.dsp.exec_cmd(HOME .. "/Apps/helium-0.11.7.1-x86_64.appimage"))
hl.bind("CTRL + ALT + Space",    hl.dsp.exec_cmd("bash " .. HOME .. "/Documents/omega_alacritty.sh"))
hl.bind("CTRL + SHIFT + Escape", hl.dsp.exec_cmd("plasma-systemmonitor"))

-- Launcher (press again to close)
hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd("~/.local/bin/sr-launcher"))
hl.bind("mouse:275",           hl.dsp.exec_cmd("~/.local/bin/sr-launcher"))

-- Clipboard history
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd(
    'cliphist list | walker --dmenu | cliphist decode | wl-copy'))

-- Bar and notifications
hl.bind(mainMod .. " + N",         hl.dsp.exec_cmd("pkill -SIGUSR1 waybar"))
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("makoctl dismiss -a"))

-- Scripts
hl.bind(mainMod .. " + O",           hl.dsp.exec_cmd(HOME .. "/.config/hypr/odysseus.sh"))
hl.bind(mainMod .. " + ALT + Space", hl.dsp.exec_cmd("sonder-screensaver"))

-- Session
hl.bind(mainMod .. " + L",         hl.dsp.exec_cmd("pidof hyprlock || hyprlock"))
hl.bind(mainMod .. " + Escape",    hl.dsp.exec_cmd(HOME .. "/.config/waybar/power.sh"))
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd('uwsm stop || loginctl terminate-session "$XDG_SESSION_ID"'))

-- Windows
hl.bind(mainMod .. " + Q",         hl.dsp.window.close())
hl.bind("CTRL + ALT + X",          hl.dsp.window.close())
hl.bind("mouse:276",               hl.dsp.window.close())
hl.bind(mainMod .. " + mouse:274", hl.dsp.window.close())
hl.bind(mainMod .. " + F",         hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mainMod .. " + S",         hl.dsp.window.float({ action = "toggle" }))

-- Mouse move / resize
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
hl.bind("CTRL + mouse:273",        hl.dsp.window.resize(), { mouse = true })

-- Focus and move with arrows
local arrows = { Left = "l", Right = "r", Up = "u", Down = "d" }
for key, dir in pairs(arrows) do
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ direction = dir }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ direction = dir }))
end

-- Workspaces 1-10 on the top row by keycode (works on AZERTY)
for i = 1, 10 do
    local code = 9 + i
    hl.bind(mainMod .. " + code:" .. code, function()
        if srDragging then   -- a window is being dragged: take it along
            hl.dispatch(hl.dsp.window.move({ workspace = i, follow = true }))
        else
            hl.dispatch(hl.dsp.focus({ workspace = i }))
        end
    end)
    hl.bind(mainMod .. " + SHIFT + code:" .. code, hl.dsp.window.move({ workspace = i, follow = true }))
    hl.bind(mainMod .. " + ALT + code:" .. code, hl.dsp.window.move({ workspace = i, follow = false }))
end

-- Screenshots
hl.bind("Print", hl.dsp.exec_cmd(
    'grim -g "$(slurp)" ~/Pictures/ScreenTrash/screenshot-$(date +%Y%m%d-%H%M%S).png'))
hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd('grim -g "$(slurp)" - | wl-copy'))

-- Media
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
    { locked = true, repeating = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"),
    { locked = true, repeating = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioStop",  hl.dsp.exec_cmd("playerctl stop"),       { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })


-- Bar panels by keyboard (Omarchy-style SUPER + CTRL)
hl.bind("SUPER + CTRL + A", hl.dsp.exec_cmd("~/.local/bin/sr-tui wiremix wiremix"))
hl.bind("SUPER + CTRL + W", hl.dsp.exec_cmd("~/.local/bin/sr-tui wlctl wlctl"))
hl.bind("SUPER + CTRL + B", hl.dsp.exec_cmd("~/.local/bin/sr-tui bluetui bluetui"))
hl.bind("SUPER + CTRL + T", hl.dsp.exec_cmd("~/.local/bin/sr-tui btop btop"))

------------------------------------------------------------------------
-- Desktops like Windows: ALT+Tab next, ALT+SHIFT+Tab previous
------------------------------------------------------------------------
hl.bind("ALT + Tab",         hl.dsp.focus({ workspace = "e+1" }))
hl.bind("ALT + SHIFT + Tab", hl.dsp.focus({ workspace = "e-1" }))

-- Settings menu
hl.bind(mainMod .. " + I", hl.dsp.exec_cmd(HOME .. "/.local/bin/sr-settings"))

-- App manager (info / hide / uninstall)
hl.bind(mainMod .. " + SHIFT + Space", hl.dsp.exec_cmd(HOME .. "/.local/bin/sr-apps"))

-- SHIFT+click in the app menu = app options (the click still goes through)
hl.bind("SHIFT + mouse:272", function()
    local f = io.open(HOME .. "/.cache/sr-shift-click", "w")
    if f then f:write("1"); f:close() end
end, { non_consuming = true })

------------------------------------------------------------------------
-- Drag a window to another desktop: hold SUPER, drag, press the number
------------------------------------------------------------------------
srDragging = false
hl.bind(mainMod .. " + mouse:272", function() srDragging = true end, { non_consuming = true })
hl.bind("mouse:272", function() srDragging = false end, { release = true, non_consuming = true })
hl.bind(mainMod .. " + mouse:272", function() srDragging = false end, { release = true, non_consuming = true })
