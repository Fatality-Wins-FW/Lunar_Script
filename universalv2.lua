local Library = loadstring(game:HttpGet("github raw link"))()
local SaveManager = loadstring(game:HttpGet("github raw link"))()

if not Library then error("Failed to load Lunar Library") end

local UI = Library:Init({
    Title = "Lunar",
    Subtitle = "Universal V2",
    Footer = "Lunar's Script",
    BackgroundColor = Color3.new(.114, 0.106, 0.106),
})

SaveManager:SetLibrary(UI)
SaveManager:SetFolder("Lunar_Script/universalv2")

local tabs = {"Combat", "Visuals", "Misc", "Settings"}
local tabInstances = {}

for _, name in ipairs(tabs) do
    tabInstances[name] = UI:AddTab(name)
end

local combatSec = UI:AddSection(tabInstances["Combat"], "Combat Options")
local visualsSec = UI:AddSection(tabInstances["Visuals"], "Visual Settings")
local miscSec = UI:AddSection(tabInstances["Misc"], "Miscellaneous")
local settingsSec = UI:AddSection(tabInstances["Settings"], "Settings")

UI:AddButton(combatSec, {Name = "Auto Farm", Callback = function() UI:Notify("Auto Farm", "Toggled!", 3) end})
UI:AddToggle(combatSec, {Name = "Aimbot", Default = false, Flag = "aimbot_enabled", Callback = function(v) UI:Notify("Aimbot", v and "On" or "Off", 2) end})
UI:AddSlider(combatSec, {Name = "FOV Size", Min = 0, Max = 360, Default = 180, Decimals = 0, Flag = "fov_size"})

UI:AddToggle(visualsSec, {Name = "ESP", Default = false, Flag = "esp_enabled"})
UI:AddColorPicker(visualsSec, {Name = "ESP Color", Default = Color3.fromRGB(255, 60, 60), Flag = "esp_color"})

UI:AddDropdown(miscSec, {Name = "Theme", Options = {"Dark", "Light", "Blue"}, Default = "Dark", Flag = "theme_selected"})
UI:AddSlider(miscSec, {Name = "WalkSpeed", Min = 16, Max = 100, Default = 16, Flag = "walkspeed", Callback = function(v) if game.Players.LocalPlayer.Character then game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v end end})

UI:AddKeybind(settingsSec, {Name = "Menu Keybind", Default = Enum.KeyCode.RightShift, Flag = "toggle_key", Callback = function(key) UI.MenuKey = key; UI:Notify("Settings", "Key changed to " .. key.Name, 3) end})
UI:AddTextbox(settingsSec, {Name = "Username", Placeholder = "Enter username...", Flag = "username"})

SaveManager:BuildConfigSection(settingsSec)

UI:AddButton(settingsSec, {Name = "Unload Script", Callback = function() UI:Unload() end})

SaveManager:LoadAutoloadConfig()
UI:Notify("Welcome", "Lunar Universal V2 loaded!", 5)