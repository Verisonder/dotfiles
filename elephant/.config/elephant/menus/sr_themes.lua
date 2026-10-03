-- SR theme picker with previews (Walker shows the preview image on the side)
Name = "srthemes"
NamePretty = "Themes"
Icon = "preferences-desktop-theme"
HideFromProviderlist = true
Cache = false

local HOME = os.getenv("HOME")
local SRC = HOME .. "/.cache/omarchy-src/themes"

local function exists(p)
    local f = io.open(p, "r")
    if f then f:close() return true end
    return false
end

local function current()
    local f = io.open(HOME .. "/.config/sr/theme", "r")
    if not f then return "" end
    local t = f:read("*l") or ""
    f:close()
    return t
end

local function pretty(name)
    local s = name:gsub("[_%-]", " ")
    return (s:gsub("(%a)([%w']*)", function(a, b) return a:upper() .. b:lower() end))
end

function GetEntries()
    local entries, cur = {}, current()
    local h = io.popen("ls -1 '" .. SRC .. "' 2>/dev/null")
    if not h then return entries end
    for name in h:lines() do
        local dir = SRC .. "/" .. name
        local preview = dir .. "/preview.png"
        if not exists(preview) then
            local b = io.popen("ls -1 '" .. dir .. "/backgrounds' 2>/dev/null | head -n 1")
            local first = b and b:read("*l")
            if b then b:close() end
            preview = first and (dir .. "/backgrounds/" .. first) or nil
        end
        table.insert(entries, {
            Text = pretty(name) .. (name == cur and "   (current)" or ""),
            Preview = preview,
            PreviewType = "file",
            Actions = { activate = HOME .. "/.local/bin/sr-theme-set " .. name },
        })
    end
    h:close()
    return entries
end
