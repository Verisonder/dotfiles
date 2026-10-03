-- SR app menu: every app with its icon. Click/Enter opens it, SHIFT+click shows its options.
Name = "srapps"
NamePretty = "Apps"
Icon = "applications-system"
HideFromProviderlist = true
Cache = false

local bin = os.getenv("HOME") .. "/.local/bin/sr-apps"

function GetEntries()
    local entries = {}
    local h = io.popen(bin .. " --list")
    if h then
        for line in h:lines() do
            local id, name, icon, comment = line:match("^([^\t]*)\t([^\t]*)\t([^\t]*)\t?(.*)$")
            if id then
                table.insert(entries, {
                    Text = name,
                    Subtext = comment,
                    Icon = icon,
                    Actions = { activate = bin .. " --click '" .. id .. "'" },
                })
            end
        end
        h:close()
    end
    return entries
end
