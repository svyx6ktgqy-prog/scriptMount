-- Load the Rayfield library
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main/source.lua'))()

-- Create the main window
local Window = Rayfield:CreateWindow({
   Name = "ALB8RAAQ - Monitor",
   LoadingTitle = "Loading Network Monitor...",
   LoadingSubtitle = "Solo Modo",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

-- Roblox Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- State variables
local SpyEnabled = false
local ActionLogs = {}

-- ==========================================
-- SOLO MONITOREO DE RED
-- ==========================================
local MonitorTab = Window:CreateTab("Network Monitor", 4483362458)

local LastActionLabel = MonitorTab:CreateParagraph({Title = "Last Interaction", Content = "Waiting..."})

MonitorTab:CreateToggle({
   Name = "Enable Network Spy", 
   CurrentValue = false, 
   Flag = "SpyToggle", 
   Callback = function(V) SpyEnabled = V end
})

MonitorTab:CreateButton({
   Name = "Copy General History",
   Callback = function()
        if setclipboard then
            local text = "--- HISTORY ---\n"
            for i, log in ipairs(ActionLogs) do 
                text = text .. string.format("[%d] %s | %s | %s\n", i, log.Time, log.Path, log.Method) 
            end
            setclipboard(text)
        end
   end,
})

-- ==========================================
-- LÓGICA DE RED (Manteniendo la funcionalidad)
-- ==========================================
local function FormatArguments(args)
    local result = ""
    for i, v in ipairs(args) do
        local argType = typeof(v)
        if argType == "string" then result = result .. '"' .. v .. '"'
        elseif argType == "Instance" then result = result .. v:GetFullName()
        elseif argType == "table" then
            local ok, json = pcall(function() return game:GetService("HttpService"):JSONEncode(v) end)
            result = result .. (ok and json or "{Table}")
        else result = result .. tostring(v) end
        if i < #args then result = result .. ", " end
    end
    return result == "" and "None" or result
end

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if not checkcaller() and (method == "FireServer" or method == "InvokeServer") then
        local path = self:GetFullName()
        local formattedArgs = FormatArguments(args)
        local timeStamp = os.date("%H:%M:%S")

        if SpyEnabled then
            table.insert(ActionLogs, {Time = timeStamp, Path = path, Method = method, Args = formattedArgs})
            task.spawn(function() LastActionLabel:Set({Title = "Interaction!", Content = path .. "\n" .. formattedArgs}) end)
        end
    end

    return oldNamecall(self, ...)
end)
