local HttpService = game:GetService("HttpService")

local supported_games = {
    ["286090429"] = "https://raw.githubusercontent.com/Fatality-Wins-FW/Lunar_Script/main/286090429.lua",
    ["Universal"] = "https://raw.githubusercontent.com/Fatality-Wins-FW/Lunar_Script/main/universal.lua",
}

local function loadScript(url, label, maxRetries)
    maxRetries = maxRetries or 3
    
    for attempt = 1, maxRetries do
        print(string.format("[Loader] Loading %s (Attempt %d/%d)...", label, attempt, maxRetries))
        
        local success, result = pcall(function()
            return game:HttpGet(url, true)
        end)

        if not success then
            warn(string.format("[Loader] ❌ Network error fetching %s: %s", label, tostring(result)))
            if attempt < maxRetries then task.wait(2) end
            continue
        end

        if not result or #result < 50 then
            warn(string.format("[Loader] ❌ Empty response for %s (Length: %d)", label, result and #result or 0))
            if attempt < maxRetries then task.wait(2) end
            continue
        end
        
        if string.find(result, "<!DOCTYPE") or string.find(result, "<html") or string.find(result, "404: Not Found") then
            warn(string.format("[Loader] ❌ Received HTML/error page instead of Lua for %s", label))
            if attempt < maxRetries then task.wait(2) end
            continue
        end

        local func, syntaxErr = loadstring(result)
        if not func then
            warn(string.format("[Loader] ❌ Invalid Lua syntax in %s: %s", label, tostring(syntaxErr)))
            return
        end

        local execSuccess, execErr = pcall(func)
        if execSuccess then
            print(string.format("[Loader] ✅ %s loaded successfully!", label))
            return
        else
            warn(string.format("[Loader] ❌ %s execution failed: %s", label, tostring(execErr)))
            return
        end
    end
    
    warn(string.format("[Loader] ❌ Failed to load %s after %d attempts", label, maxRetries))
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