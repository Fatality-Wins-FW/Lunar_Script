local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

print("[Lunar] Initializing...")

local LocalPlayer = Players.LocalPlayer
local RemotesFolder = ReplicatedStorage:FindFirstChild("Remotes")

if not RemotesFolder then
    error("[Lunar] CRITICAL ERROR: 'Remotes' folder not found in ReplicatedStorage.")
end

local remoteChildren = RemotesFolder:GetChildren()
print(string.format("[Lunar] Found %d remotes", #remoteChildren))

-- Safe remote fetching
local function GetRemote(index, name)
    if index > #remoteChildren then
        warn(string.format("[Lunar] Remote index %d (%s) out of bounds.", index, name))
        return nil
    end
    local remote = remoteChildren[index]
    print(string.format("[Lunar] Loaded [%d]: %s", index, remote.Name))
    return remote
end

local RebirthEvent = GetRemote(20, "Rebirth")
local PetEvent = GetRemote(109, "Pet")
local ClickEvent = GetRemote(154, "Click")

-- Load Library with strict error handling
local Library, ThemeManager, SaveManager
local success, err = pcall(function()
    Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
    ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua"))()
    SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua"))()
end)

if not success or not Library then
    error("[Lunar] Failed to load LinoriaLib: " .. tostring(err))
end

print("[Lunar] Library loaded successfully")

local GameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name or "Unknown Game"

local Window = Library:CreateWindow({
    Title = string.format("Lunar | %s | V1", GameName),
    Center = true,
    AutoShow = true
})

-- Create tabs safely
local Tabs = {
    Main = Window:AddTab("Main"),
    Teleport = Window:AddTab("Teleport"),
    Settings = Window:AddTab("Settings")
}

-- Verify tabs were created to prevent 'index nil' errors
if not Tabs.Main or not Tabs.Teleport or not Tabs.Settings then
    error("[Lunar] CRITICAL: Failed to create UI tabs. Library version incompatible.")
end

local LeftGroup = Tabs.Main:AddLeftGroupbox("Actions")
local RightGroup = Tabs.Main:AddRightGroupbox("Automation")

local Toggles = {}
local Options = {}

-- Main Features
LeftGroup:AddToggle("AutoClick", {
    Text = "Auto Click Loop",
    Default = false
})

RightGroup:AddToggle("AutoEquipBest", {
    Text = "Auto Equip Best Pet",
    Default = false
})

RightGroup:AddToggle("AutoRebirth", {
    Text = "Auto Rebirth",
    Default = false
})

-- Teleport System using Toggles (Most compatible method)
local IslandToggles = {}
local Coordinates = {
    ["Spawn"] = Vector3.new(-243.86, 164.48, 342.72),
    ["Winter Island"] = Vector3.new(-202.88, 936.94, 326.96),
    ["Forest Island"] = Vector3.new(-247.58, 2179.44, 249.47),
    ["Desert Island"] = Vector3.new(-267.00, 3665.78, 362.30),
    ["Candy Island"] = Vector3.new(-258.10, 5161.67, 299.96),
    ["Beach Island"] = Vector3.new(-246.71, 6661.01, 342.58)
}

local IslandNames = {"Spawn", "Winter Island", "Forest Island", "Desert Island", "Candy Island", "Beach Island"}

for _, name in ipairs(IslandNames) do
    local toggleId = "Teleport" .. name:gsub("%s+", "")
    IslandToggles[name] = Tabs.Teleport:AddToggle(toggleId, {
        Text = "Select " .. name,
        Default = false
    })
end

Tabs.Teleport:AddButton({
    Text = "Teleport to Selected Island",
    Func = function()
        local SelectedIsland = nil
        
        -- Find which toggle is active
        for _, name in ipairs(IslandNames) do
            if IslandToggles[name].Value then
                SelectedIsland = name
                break
            end
        end
        
        if not SelectedIsland then
            Library:Notify("Please select an island first!", 3)
            return
        end
        
        local TargetPos = Coordinates[SelectedIsland]
        local Character = LocalPlayer.Character
        
        if Character then
            local RootPart = Character:FindFirstChild("HumanoidRootPart")
            if RootPart then
                RootPart.CFrame = CFrame.new(TargetPos + Vector3.new(0, 5, 0))
                Library:Notify("Teleported to " .. SelectedIsland, 3)
            else
                Library:Notify("Character root part missing!", 3)
            end
        else
            Library:Notify("Character not loaded!", 3)
        end
    end,
    DoubleClick = false
})

-- Managers Setup
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

ThemeManager:ApplyToTab(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Tabs.Settings:AddLeftGroupbox("Menu"):AddButton({
    Text = "Unload Script",
    Func = function() Library:Unload() end,
    DoubleClick = false
})

Library:Notify("Lunar V1 Loaded", 3)
print("[Lunar] UI initialized successfully")

-- Automation Loop with safety checks
task.spawn(function()
    while task.wait() do
        if Toggles.AutoClick and Toggles.AutoClick.Value and ClickEvent then
            pcall(function() ClickEvent:FireServer() end)
        end
        
        if Toggles.AutoEquipBest and Toggles.AutoEquipBest.Value and PetEvent then
            pcall(function() PetEvent:FireServer() end)
        end
        
        if Toggles.AutoRebirth and Toggles.AutoRebirth.Value and RebirthEvent then
            pcall(function() RebirthEvent:FireServer(3) end)
        end
    end
end)

Library:OnUnload(function()
    print("[Lunar] Unloaded")
end)

SaveManager:LoadAutoloadConfig()