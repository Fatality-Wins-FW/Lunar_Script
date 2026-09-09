local HttpService = game:GetService("HttpService")

local supported_games = {
    ["286090429"] = "https://github.com/Fatality-Wins-FW/Lunar_Script/raw/refs/heads/main/286090429.lua",
    ["Universal"] = "https://github.com/Fatality-Wins-FW/Lunar_Script/raw/refs/heads/main/universal.lua",
}

local function loadScript(url, label)
    print(string.format("[Loader] Loading %s...", label))
    
    local success, result = pcall(function()
        return game:HttpGet(url, true)
    end)

    if not success then
        warn(string.format("[Loader] ❌ Failed to fetch %s: Network error - %s", label, tostring(result)))
        return
    end

    if not result or #result < 50 then
        warn(string.format("[Loader] ❌ Failed to fetch %s: Empty or invalid response (Length: %d)", label, result and #result or 0))
        return
    end

    if string.find(result, "<!DOCTYPE") or string.find(result, "<html") then
        warn(string.format("[Loader] ❌ Failed to fetch %s: Received HTML instead of Lua script", label))
        return
    end

    local execSuccess, execErr = pcall(function()
        local func = loadstring(result)
        if not func then
            error("Invalid Lua syntax in downloaded script")
        end
        func()
    end)

    if execSuccess then
        print(string.format("[Loader] ✅ %s loaded successfully!", label))
    else
        warn(string.format("[Loader] ❌ %s execution failed: %s", label, tostring(execErr)))
    end
end

local placeId = tostring(game.PlaceId)
local targetUrl = supported_games[placeId] or supported_games["Universal"]

if not targetUrl then
    warn("[Loader] ❌ No script URL found for this game and no Universal fallback defined.")
    return
end

local label = targetUrl == supported_games[placeId] 
    and string.format("Game-Specific Script (%s)", placeId) 
    or "Universal Script"

loadScript(targetUrl, label)