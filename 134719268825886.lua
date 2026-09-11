local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Debugging: Print startup info to console
print("[Lunar] Initializing...")

local LocalPlayer = Players.LocalPlayer
local RemotesFolder = ReplicatedStorage:FindFirstChild("Remotes")

if not RemotesFolder then
    error("[Lunar] CRITICAL ERROR: 'Remotes' folder not found in ReplicatedStorage. The game may have updated.")
end

local remoteChildren = RemotesFolder:GetChildren()
print(string.format("[Lunar] Found %d remotes in ReplicatedStorage", #remoteChildren))

-- Safe remote fetching with bounds checking
local function GetRemote(index, name)
    if index > #remoteChildren then
        warn(string.format("[Lunar] WARNING: Remote index %d for '%s' is out of bounds (Total: %d). Feature disabled.", index, name, #remoteChildren))
        return nil
    end
    local remote = remoteChildren[index]
    print(string.format("[Lunar] Loaded remote [%d]: %s (%s)", index, remote.Name, remote.ClassName))
    return remote
end

local RebirthEvent = GetRemote(20, "RebirthEvent")
local PetEvent = GetRemote(109, "PetEvent")
local ClickEvent = GetRemote(154, "ClickEvent")

-- Load Library with error handling
local Library, ThemeManager, SaveManager
local success, err = pcall(function()
    Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
    ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua"))()
    SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua"))()
end)

if not success then
    error("[Lunar] Failed to load LinoriaLib: " .. tostring(err))
end

print("[Lunar] Library loaded successfully")

-- Check available methods for debugging
print(string.format("[Lunar] Available Tab methods: AddToggle=%s, AddSlider=%s, AddDropdown=%s, AddComboBox=%s, AddListBox=%s",
    type(Tabs.Main and Tabs.Main.AddToggle),
    type(Tabs.Main and Tabs.Main.AddSlider),
    type(Tabs.Main and Tabs.Main.AddDropdown),
    type(Tabs.Main and Tabs.Main.AddComboBox),
    type(Tabs.Main and Tabs.Main.AddListBox)
))

local GameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name or "Unknown Game"

local Window = Library:CreateWindow({
    Title = string.format("Lunar | %s | V1", GameName),
    Center = true,
    AutoShow = true
})

local Tabs = {
    Main = Window:AddTab("Main"),
    Teleport = Window:AddTab("Teleport"),
    Settings = Window:AddTab("Settings")
}

local LeftGroup = Tabs.Main:AddLeftGroupbox("Actions")
local RightGroup = Tabs.Main:AddRightGroupbox("Automation")

local Toggles = {}
local Options = {}

LeftGroup:AddToggle("AutoClick", {
    Text = "Auto Click Loop",
    Default = false,
    Tooltip = "Automatically fires the click event"
})

RightGroup:AddToggle("AutoEquipBest", {
    Text = "Auto Equip Best Pet",
    Default = false,
    Tooltip = "Automatically equips the best pet"
})

RightGroup:AddToggle("AutoRebirth", {
    Text = "Auto Rebirth",
    Default = false,
    Tooltip = "Automatically performs rebirths"
})

-- Using Slider instead of Dropdown for maximum compatibility
-- Islands: Spawn=1, Winter=2, Forest=3, Desert=4, Candy=5, Beach=6
Options.IslandSelect = Tabs.Teleport:AddSlider("IslandSelect", {
    Text = "Select Island",
    Default = 1,
    Min = 1,
    Max = 6,
    Rounding = 0,
    Compact = false
})

local IslandNames = {
    [1] = "Spawn",
    [2] = "Winter Island",
    [3] = "Forest Island",
    [4] = "Desert Island",
    [5] = "Candy Island",
    [6] = "Beach Island"
}

Tabs.Teleport:AddButton({
    Text = "Teleport to Island",
    Func = function()
        local IslandIndex = math.floor(Options.IslandSelect.Value)
        local SelectedIsland = IslandNames[IslandIndex]
        
        if not SelectedIsland then
            Library:Notify("Invalid island selected!", 3)
            return
        end
        
        local Coordinates = {
            ["Spawn"] = Vector3.new(-243.86, 164.48, 342.72),
            ["Winter Island"] = Vector3.new(-202.88, 936.94, 326.96),
            ["Forest Island"] = Vector3.new(-247.58, 2179.44, 249.47),
            ["Desert Island"] = Vector3.new(-267.00, 3665.78, 362.30),
            ["Candy Island"] = Vector3.new(-258.10, 5161.67, 299.96),
            ["Beach Island"] = Vector3.new(-246.71, 6661.01, 342.58)
        }
        
        local TargetPos = Coordinates[SelectedIsland]
        if TargetPos then
            local Character = LocalPlayer.Character
            if Character then
                local RootPart = Character:FindFirstChild("HumanoidRootPart")
                if RootPart then
                    RootPart.CFrame = CFrame.new(TargetPos + Vector3.new(0, 5, 0))
                    Library:Notify("Teleported to " .. SelectedIsland, 3)
                else
                    Library:Notify("Character not loaded yet!", 3)
                end
            else
                Library:Notify("No character found!", 3)
            end
        end
    end,
    DoubleClick = false
})

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

ThemeManager:ApplyToTab(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Tabs.Settings:AddLeftGroupbox("Menu"):AddButton({
    Text = "Unload Script",
    Func = function()
        Library:Unload()
    end,
    DoubleClick = false
})

Library:Notify("Lunar V1 Loaded", 3)
print("[Lunar] UI initialized successfully")

task.spawn(function()
    while task.wait() do
        if Toggles.AutoClick.Value and ClickEvent then
            pcall(function()
                ClickEvent:FireServer()
            end)
        end
        
        if Toggles.AutoEquipBest.Value and PetEvent then
            pcall(function()
                PetEvent:FireServer()
            end)
        end
        
        if Toggles.AutoRebirth.Value and RebirthEvent then
            pcall(function()
                RebirthEvent:FireServer(3)
            end)
        end
    end
end)

Library:OnUnload(function()
    print("[Lunar] Unloaded")
end)

SaveManager:LoadAutoloadConfig()