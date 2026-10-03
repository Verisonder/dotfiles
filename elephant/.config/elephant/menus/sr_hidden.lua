-- SR app manager: apps you hid (pick one to show it again)
Name = "srhidden"
NamePretty = "Hidden apps"
Icon = "view-hidden"
HideFromProviderlist = true
Cache = false

local bin = os.getenv("HOME") .. "/.local/bin/sr-apps"

function GetEntries()
    local entries = {}
    local h = io.popen(bin .. " --list-hidden")
    if h then
        for line in h:lines() do
            local id, name, icon = line:match("^([^\t]*)\t([^\t]*)\t([^\t]*)")
            if id then
                table.insert(entries, {
                    Text = name,
                    Subtext = "Click to show it in the app menu again",
                    Icon = icon,
                    Actions = { activate = bin .. " --do unhide:" .. id },
                })
            end
        end
        h:close()
    end
    table.insert(entries, { Text = "Back to apps", Icon = "go-previous",
                            Actions = { activate = bin .. " --do menu:" } })
    return entries
end
