local HttpService = game:GetService("HttpService")

local supported_games = {
    ["286090429"] = "https://raw.githubusercontent.com/Fatality-Wins-FW/Lunar_Script/main/286090429.lua",
    ["Universal"] = "https://raw.githubusercontent.com/Fatality-Wins-FW/Lunar_Script/main/universal.lua",
}

local function validateLuaContent(content, label)
    if not content or #content < 50 then
        return false, string.format("Empty response (Length: %d)", content and #content or 0)
    end
    
    if string.find(content, "<!DOCTYPE") or string.find(content, "<html") then
        return false, "Received HTML page instead of Lua"
    end
    
    if string.find(content, "404: Not Found") then
        return false, "File not found on repository"
    end
    
    local func, err = loadstring(content)
    if not func then
        local lineNum = string.match(tostring(err), ":([%d]+):")
        if lineNum then
            return false, string.format("Syntax error at line %s: %s", lineNum, tostring(err))
        end
        return false, string.format("Syntax error: %s", tostring(err))
    end
    
    return true, func
end

local function loadScript(url, label, maxRetries)
    maxRetries = maxRetries or 3
    
    for attempt = 1, maxRetries do
        print(string.format("[Loader] Loading %s (Attempt %d/%d)...", label, attempt, maxRetries))
        
        local success, content = pcall(function()
            return game:HttpGet(url, true)
        end)
        
        if not success then
            warn(string.format("[Loader] ❌ Network error: %s", tostring(content)))
            if attempt < maxRetries then task.wait(2) end
            continue
        end
        
        local isValid, result = validateLuaContent(content, label)
        
        if not isValid then
            warn(string.format("[Loader] ❌ Validation failed: %s", result))
            if attempt < maxRetries then task.wait(2) end
            continue
        end
        
        local execSuccess, execErr = pcall(result)
        if execSuccess then
            print(string.format("[Loader] ✅ %s loaded successfully!", label))
            return
        else
            warn(string.format("[Loader] ❌ Execution failed: %s", tostring(execErr)))
            return
        end
    end
    
    warn(string.format("[Loader] ❌ Failed after %d attempts", maxRetries))
end

local placeId = tostring(game.PlaceId)
local targetUrl = supported_games[placeId] or supported_games["Universal"]

if not targetUrl then
    warn("[Loader] ❌ No script URL configured for this game")
    return
end

local label = targetUrl == supported_games[placeId] 
    and string.format("Game-Specific Script (%s)", placeId) 
    or "Universal Script"

loadScript(targetUrl, label)