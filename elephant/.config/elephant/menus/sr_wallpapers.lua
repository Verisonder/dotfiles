-- SR wallpaper picker with previews: the current theme's wallpapers + ~/Pictures/wallpaper
Name = "srwallpapers"
NamePretty = "Wallpapers"
Icon = "preferences-desktop-wallpaper"
HideFromProviderlist = true
Cache = false

local HOME = os.getenv("HOME")

local function current_theme()
    local f = io.open(HOME .. "/.config/sr/theme", "r")
    if not f then return "" end
    local t = f:read("*l") or ""
    f:close()
    return t
end

local function q(s)   -- shell-quote
    return "'" .. s:gsub("'", "'\\''") .. "'"
end

function GetEntries()
    local entries = {}
    local dirs = {
        HOME .. "/.cache/omarchy-src/themes/" .. current_theme() .. "/backgrounds",
        HOME .. "/Pictures/wallpaper",
    }
    for _, dir in ipairs(dirs) do
        local h = io.popen("find -L " .. q(dir) .. " -maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \\) 2>/dev/null | sort")
        if h then
            for path in h:lines() do
                local file = path:match("([^/]+)$")
                if file ~= "current.jpg" then
                    table.insert(entries, {
                        Text = file:gsub("%.%w+$", ""):gsub("^%d+%-", ""):gsub("[_%-]", " "),
                        Subtext = dir:find("omarchy") and "theme wallpaper" or "your wallpaper",
                        Preview = path,
                        PreviewType = "file",
                        Actions = { activate = HOME .. "/.local/bin/sr-wallpaper-set " .. q(path) },
                    })
                end
            end
            h:close()
        end
    end
    return entries
end
