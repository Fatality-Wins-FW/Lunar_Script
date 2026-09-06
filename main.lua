local HttpService = game:GetService("HttpService")

local supported_games = {
    ["286090429"] = "https://github.com/Fatality-Wins-FW/Lunar_Script/raw/refs/heads/main/286090429.lua",
}

local function loadScript(url)
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)

    if success then
        pcall(function()
            loadstring(result)()
        end)
    else
        warn("[Loader] Failed to fetch script:", result)
    end
end

local placeId = tostring(game.PlaceId)

if supported_games[placeId] then
    loadScript(supported_games[placeId])
else
    warn(string.format("[Loader] Game ID '%s' is not currently supported.", placeId))
end