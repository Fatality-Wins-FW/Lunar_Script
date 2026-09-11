local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local RebirthEvent = Remotes:GetChildren()[20]
local PetEvent = Remotes:GetChildren()[109]
local ClickEvent = Remotes:GetChildren()[154]

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/wally-rbix/LinoriaLib/main/Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/wally-rbix/LinoriaLib/main/addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/wally-rbix/LinoriaLib/main/addons/SaveManager.lua"))()

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

local IslandList = {
    "Spawn",
    "Winter Island",
    "Forest Island",
    "Desert Island",
    "Candy Island",
    "Beach Island"
}

Options.IslandSelect = Tabs.Teleport:AddDropdown("IslandSelect", {
    Values = IslandList,
    Multi = false,
    Default = 1,
    Text = "Select Island"
})

Tabs.Teleport:AddButton({
    Text = "Teleport to Island",
    Func = function()
        local SelectedIsland = Options.IslandSelect.Value
        if not SelectedIsland then return end
        
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
                end
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

task.spawn(function()
    while task.wait() do
        if Toggles.AutoClick.Value then
            pcall(function()
                ClickEvent:FireServer()
            end)
        end
        
        if Toggles.AutoEquipBest.Value then
            pcall(function()
                PetEvent:FireServer()
            end)
        end
        
        if Toggles.AutoRebirth.Value then
            pcall(function()
                RebirthEvent:FireServer(3)
            end)
        end
    end
end)

Library:OnUnload(function()
    print("Lunar Unloaded")
end)

SaveManager:LoadAutoloadConfig()