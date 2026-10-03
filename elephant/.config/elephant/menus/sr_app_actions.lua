-- SR app manager: what to do with the chosen app
Name = "srappactions"
NamePretty = "App"
Icon = "applications-system"
HideFromProviderlist = true
Cache = false

local bin = os.getenv("HOME") .. "/.local/bin/sr-apps"

local function current()
    local f = io.open(os.getenv("HOME") .. "/.cache/sr-apps-current")
    if not f then return nil end
    local id = f:read("*l")
    f:close()
    return id
end

function GetEntries()
    local id = current()
    if not id or id == "" then return {} end
    local name, icon = id, "application-x-executable"
    local h = io.popen(bin .. " --list; " .. bin .. " --list-hidden")
    if h then
        for line in h:lines() do
            local lid, lname, licon = line:match("^([^\t]*)\t([^\t]*)\t([^\t]*)")
            if lid == id then name, icon = lname, licon; break end
        end
        h:close()
    end
    return {
        { Text = "Open " .. name, Icon = icon,               Actions = { activate = bin .. " --do open:" .. id } },
        { Text = "App info",      Icon = "dialog-information", Actions = { activate = bin .. " --do info:" .. id } },
        { Text = "Hide from app menu", Subtext = "Nothing is uninstalled", Icon = "view-hidden",
          Actions = { activate = bin .. " --do hide:" .. id } },
        { Text = "Uninstall",     Subtext = "Asks before removing anything", Icon = "edit-delete",
          Actions = { activate = bin .. " --do uninstall:" .. id } },
        { Text = "Back to apps", Icon = "go-previous", Actions = { activate = bin .. " --do menu:" } },
    }
end
