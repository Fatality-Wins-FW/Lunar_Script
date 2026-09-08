local HttpService = game:GetService("HttpService")

local supported_games = {
    ["286090429"] = "https://github.com/Fatality-Wins-FW/Lunar_Script/raw/refs/heads/main/286090429.lua",
    ["Universal"] = "https://github.com/Fatality-Wins-FW/Lunar_Script/raw/refs/heads/main/universal.lua",
}

local function loadScript(url, label)
    print(string.format("[Loader] Loading %s...", label))
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)

    if success and result and #result > 100 then
        local execSuccess, execErr = pcall(function()
            loadstring(result)()
        end)
        if execSuccess then
            print(string.format("[Loader] ✅ %s loaded successfully!", label))
        else
            warn(string.format("[Loader] ❌ %s execution failed: %s", label, tostring(execErr)))
        end
    else
        warn(string.format("[Loader] ❌ Failed to fetch %s: %s", label, tostring(result)))
    end
end

local placeId = tostring(game.PlaceId)
local targetUrl = supported_games[placeId] or supported_games["Universal"]
local label = targetUrl == supported_games[placeId] 
    and string.format("Game-Specific Script (%s)", placeId) 
    or "Universal Script"

if targetUrl then
    loadScript(targetUrl, label)
else
    warn("[Loader] ❌ No script URL found for this game and no Universal fallback defined.")
end