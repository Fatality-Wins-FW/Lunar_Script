local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local VIM = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

if CoreGui:FindFirstChild("Lunar_Arsenal_V1") then CoreGui.Lunar_Arsenal_V1:Destroy() end

getgenv().LunarRunning = true
getgenv().LunarState = {
    Rage = false,
    Aimbot = false,
    Trigger = false,
    Silent = false,
    ESP = false,
    Tracers = false,
    Ammo = false,
    Acc = false,
    FireRate = false,
    Auto = false,
    WallBang = false,
    NoAnims = false,
    AutoInspect = false,
    Lines = {},
    Config = {
        AimFOV = 150,
        AimSmoothness = 0.2,
        AimPart = "Head",
        TriggerDelay = 0.025,
        RageSpinSpeed = 30,
        RageHeight = 9,
        FireRateVal = 0.05,
        AmmoVal = 300,
        PenetrationVal = 100,
        BoxColor = Color3.new(1, 0, 0),
        TracerColor = Color3.new(1, 0, 0)
    }
}

local MyUI = nil
local uiVisible = true
local isShooting = false
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 1
fovCircle.Color = Color3.new(1, 1, 1)
fovCircle.Filled = false
fovCircle.Visible = false

local function SyncUI()
    for _, v in pairs(CoreGui:GetChildren()) do
        if v:IsA("ScreenGui") and (v.Name == "Linoria" or v:FindFirstChild("Main")) then
            MyUI = v
            return v
        end
    end
end

local function isEnemy(p)
    if not p or p == LocalPlayer or not p.Character then return false end
    local char = p.Character
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return false end
    if char:FindFirstChildOfClass("ForceField") then return false end
    local specBox = workspace:FindFirstChild("SpectatorBox")
    if specBox and char:IsDescendantOf(specBox) then return false end
    local pos = hrp.Position
    if pos.Y < -50 or pos.Y > 400 or (pos - Vector3.new(0,0,0)).Magnitude > 900 then return false end
    if p.Team ~= LocalPlayer.Team then return true end
    local myTorso = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("UpperTorso")
    local theirTorso = char:FindFirstChild("UpperTorso")
    if myTorso and theirTorso then
        return myTorso.BrickColor ~= theirTorso.BrickColor
    end
    return false
end

local function shoot()
    if isShooting then return end
    isShooting = true
    task.spawn(function()
        pcall(function()
            local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool then
                local shootFunc = tool:FindFirstChild("Shoot") or tool:FindFirstChild("Fire") or tool:FindFirstChild("shoot") or tool:FindFirstChild("fire")
                if shootFunc and shootFunc:IsA("RemoteEvent") then
                    shootFunc:FireServer(Mouse.Hit.Position)
                elseif shootFunc and shootFunc:IsA("BindableEvent") then
                    shootFunc:Fire(Mouse.Hit.Position)
                else
                    local remote = tool:FindFirstChildOfClass("RemoteEvent")
                    if remote then
                        remote:FireServer(Mouse.Hit.Position)
                    else
                        mouse1press()
                        task.wait(getgenv().LunarState.Config.TriggerDelay)
                        mouse1release()
                    end
                end
            else
                mouse1press()
                task.wait(getgenv().LunarState.Config.TriggerDelay)
                mouse1release()
            end
        end)
        task.wait(getgenv().LunarState.Config.TriggerDelay)
        isShooting = false
    end)
end

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
Library:SetWatermarkVisibility(false)

local Window = Library:CreateWindow({
    Title = "Lunar | Arsenal | V1",
    Center = true,
    AutoShow = true
})

task.wait(0.5)
SyncUI()

local function GetClosestTarget()
    local target, dist = nil, getgenv().LunarState.Config.AimFOV
    local mLoc = UserInputService:GetMouseLocation()
    for _, p in pairs(Players:GetPlayers()) do
        if isEnemy(p) and p.Character and p.Character:FindFirstChild(getgenv().LunarState.Config.AimPart) then
            local pos, on = Camera:WorldToViewportPoint(p.Character[getgenv().LunarState.Config.AimPart].Position)
            if on then
                local dx = pos.X - mLoc.X
                local dy = pos.Y - mLoc.Y
                local mag = math.sqrt(dx*dx + dy*dy)
                if mag < dist then target = p; dist = mag end
            end
        end
    end
    return target
end

local function createBox(player)
    if player.Character and not player.Character:FindFirstChild("LunarBox") then
        local box = Instance.new("BillboardGui", player.Character)
        box.Name = "LunarBox"; box.Size = UDim2.new(4,0,5,0); box.AlwaysOnTop = true
        box.Adornee = player.Character:FindFirstChild("HumanoidRootPart")
        local t = 0.05
        local function f(p,s)
            local fr = Instance.new("Frame", box); fr.Size = s; fr.Position = p; 
            fr.BackgroundColor3 = getgenv().LunarState.Config.BoxColor; fr.BorderSizePixel = 0
        end
        f(UDim2.new(0,0,0,0), UDim2.new(1,0,t,0))
        f(UDim2.new(0,0,1-t,0), UDim2.new(1,0,t,0))
        f(UDim2.new(0,0,0,0), UDim2.new(t,0,1,0))
        f(UDim2.new(1-t,0,0,0), UDim2.new(t,0,1,0))
    end
end

local CombatTab = Window:AddTab("Combat")
local RageTab = Window:AddTab("Rage")
local VisualsTab = Window:AddTab("Visuals")
local ModsTab = Window:AddTab("Gun Mods")
local MiscTab = Window:AddTab("Misc")
local SettingsTab = Window:AddTab("Settings")

local CombatGroup = CombatTab:AddLeftGroupbox("Aimbot Settings")
CombatGroup:AddToggle("AimbotEnabled", {
    Text = "Enable Aimbot",
    Callback = function(s) getgenv().LunarState.Aimbot = s; fovCircle.Visible = s end
})
CombatGroup:AddSlider("AimFOV", {
    Text = "FOV Radius",
    Min = 10, Max = 500, Default = 150,
    Rounding = 0,
    Callback = function(v) getgenv().LunarState.Config.AimFOV = v; fovCircle.Radius = v end
})
CombatGroup:AddSlider("AimSmooth", {
    Text = "Smoothness (0-1)",
    Min = 0, Max = 1, Default = 0.2,
    Rounding = 2,
    Callback = function(v) getgenv().LunarState.Config.AimSmoothness = v end
})
CombatGroup:AddDropdown("AimPart", {
    Text = "Target Part",
    Values = {"Head", "HumanoidRootPart", "UpperTorso"},
    Multi = false,
    Default = "Head",
    Callback = function(v) getgenv().LunarState.Config.AimPart = v end
})

local TriggerGroup = CombatTab:AddRightGroupbox("Triggerbot")
TriggerGroup:AddToggle("TriggerEnabled", {
    Text = "Enable Triggerbot",
    Callback = function(s) getgenv().LunarState.Trigger = s end
})
TriggerGroup:AddSlider("TriggerDelay", {
    Text = "Shot Delay (s)",
    Min = 0, Max = 0.5, Default = 0.025,
    Rounding = 3,
    Callback = function(v) getgenv().LunarState.Config.TriggerDelay = v end
})

local SilentGroup = CombatTab:AddRightGroupbox("Silent Aim")
SilentGroup:AddToggle("SilentEnabled", {
    Text = "Enable Silent Aim",
    Callback = function(state)
        getgenv().LunarState.Silent = state
        if state then
            task.spawn(function()
                while getgenv().LunarState.Silent and getgenv().LunarRunning do
                    for _, v in pairs(Players:GetPlayers()) do
                        if isEnemy(v) and v.Character then
                            pcall(function()
                                local parts = {"RightUpperLeg", "LeftUpperLeg", "HeadHB", "HumanoidRootPart"}
                                for _, n in ipairs(parts) do
                                    local p = v.Character:FindFirstChild(n)
                                    if p then p.CanCollide = false; p.Transparency = 10; p.Size = Vector3.new(13,13,13) end
                                end
                            end)
                        end
                    end
                    task.wait(1)
                end
            end)
        end
    end
})

local RageGroup = RageTab:AddLeftGroupbox("Rage Configuration")
RageGroup:AddToggle("RageEnabled", {
    Text = "Enable Ragebot",
    Callback = function(s) getgenv().LunarState.Rage = s end
})
RageGroup:AddSlider("RageSpin", {
    Text = "Spin Speed",
    Min = 0, Max = 100, Default = 30,
    Rounding = 0,
    Callback = function(v) getgenv().LunarState.Config.RageSpinSpeed = v end
})
RageGroup:AddSlider("RageHeight", {
    Text = "Teleport Height",
    Min = 0, Max = 20, Default = 9,
    Rounding = 0,
    Callback = function(v) getgenv().LunarState.Config.RageHeight = v end
})

local VisualsGroup = VisualsTab:AddLeftGroupbox("ESP Options")
VisualsGroup:AddToggle("ESPEnabled", {
    Text = "Enable ESP Boxes",
    Callback = function(s) getgenv().LunarState.ESP = s end
})
VisualsGroup:AddToggle("TracerEnabled", {
    Text = "Enable Tracers",
    Callback = function(s) getgenv().LunarState.Tracers = s end
})
VisualsGroup:AddColorPicker("BoxColorPick", {
    Text = "Box Color",
    Default = Color3.new(1, 0, 0),
    Callback = function(c) getgenv().LunarState.Config.BoxColor = c end
})
VisualsGroup:AddColorPicker("TracerColorPick", {
    Text = "Tracer Color",
    Default = Color3.new(1, 0, 0),
    Callback = function(c) getgenv().LunarState.Config.TracerColor = c end
})

local ModsGroup = ModsTab:AddLeftGroupbox("Weapon Tweaks")
ModsGroup:AddToggle("AmmoEnabled", {
    Text = "Infinite Ammo",
    Callback = function(s) getgenv().LunarState.Ammo = s end
})
ModsGroup:AddSlider("AmmoAmount", {
    Text = "Ammo Value",
    Min = 1, Max = 999, Default = 300,
    Rounding = 0,
    Callback = function(v) getgenv().LunarState.Config.AmmoVal = v end
})
ModsGroup:AddToggle("AccEnabled", {
    Text = "100% Accuracy",
    Callback = function(s) getgenv().LunarState.Acc = s end
})
ModsGroup:AddToggle("FireRateEnabled", {
    Text = "Custom Fire Rate",
    Callback = function(s) getgenv().LunarState.FireRate = s end
})
ModsGroup:AddSlider("FireRateVal", {
    Text = "Fire Rate (s)",
    Min = 0.01, Max = 1, Default = 0.05,
    Rounding = 3,
    Callback = function(v) getgenv().LunarState.Config.FireRateVal = v end
})
ModsGroup:AddToggle("AutoEnabled", {
    Text = "All Automatic",
    Callback = function(s) getgenv().LunarState.Auto = s end
})
ModsGroup:AddToggle("WallbangEnabled", {
    Text = "Wallbang",
    Callback = function(s) getgenv().LunarState.WallBang = s end
})
ModsGroup:AddSlider("PenetrationVal", {
    Text = "Penetration Power",
    Min = 1, Max = 500, Default = 100,
    Rounding = 0,
    Callback = function(v) getgenv().LunarState.Config.PenetrationVal = v end
})

-- MISC
local MiscGroup = MiscTab:AddLeftGroupbox("Utilities")
MiscGroup:AddToggle("NoAnimsEnabled", {
    Text = "No Animations",
    Callback = function(s) getgenv().LunarState.NoAnims = s end
})
MiscGroup:AddToggle("AutoInspectEnabled", {
    Text = "Auto Inspect",
    Callback = function(s) getgenv().LunarState.AutoInspect = s end
})
MiscGroup:AddButton("Unload Script", function()
    getgenv().LunarRunning = false
    for _, l in pairs(getgenv().LunarState.Lines) do l:Remove() end
    fovCircle:Remove()
    if MyUI then MyUI:Destroy() end
    Library:Unload()
end)

local ConfigGroup = SettingsTab:AddLeftGroupbox("Configuration")
ConfigGroup:AddButton("Save Config", function()
    local success, data = pcall(function() return writefile("LunarArsenalV1_Config.json", game:GetService("HttpService"):JSONEncode(getgenv().LunarState.Config)) end)
    if success then Library:Notify("Config Saved!") end
end)
ConfigGroup:AddButton("Load Config", function()
    local success, data = pcall(function() return readfile("LunarArsenalV1_Config.json") end)
    if success then
        local decoded = game:GetService("HttpService"):JSONDecode(data)
        for k,v in pairs(decoded) do getgenv().LunarState.Config[k] = v end
        Library:Notify("Config Loaded!")
    else
        Library:Notify("No config file found!")
    end
end)

local frameSkip = 0
local modSkip = 0

RunService.RenderStepped:Connect(function()
    if not getgenv().LunarRunning then return end
    frameSkip = frameSkip + 1

    local mLoc = UserInputService:GetMouseLocation()
    fovCircle.Position = Vector2.new(mLoc.X, mLoc.Y)
    fovCircle.Radius = getgenv().LunarState.Config.AimFOV

    if getgenv().LunarState.NoAnims and LocalPlayer.Character then
        pcall(function()
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                for _, track in pairs(hum:GetPlayingAnimationTracks()) do track:Stop(0) end
            end
            if LocalPlayer.Character:FindFirstChild("Animate") then LocalPlayer.Character.Animate.Enabled = false end
        end)
    end

    if getgenv().LunarState.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) and not getgenv().LunarState.Rage then
        local target = GetClosestTarget()
        if target and target.Character and target.Character:FindFirstChild(getgenv().LunarState.Config.AimPart) then
            local targetPos = target.Character[getgenv().LunarState.Config.AimPart].Position
            local currentPos = Camera.CFrame.Position
            local smooth = getgenv().LunarState.Config.AimSmoothness
            
            -- Simple Lerp for smoothness
            local newCFrame = CFrame.new(currentPos, targetPos)
            Camera.CFrame = Camera.CFrame:Lerp(newCFrame, smooth)
        end
    end

    if getgenv().LunarState.Trigger then
        local target = Mouse.Target
        if target then
            local model = target:FindFirstAncestorWhichIsA("Model")
            if model then
                local plr = Players:GetPlayerFromCharacter(model)
                if plr and isEnemy(plr) then
                    mouse1press()
                    task.wait(getgenv().LunarState.Config.TriggerDelay)
                    mouse1release()
                end
            end
        end
    end

    if frameSkip % 2 ~= 0 then return end

    local lIdx = 1
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    for _, p in pairs(Players:GetPlayers()) do
        if isEnemy(p) and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            if getgenv().LunarState.ESP then createBox(p)
            else if p.Character:FindFirstChild("LunarBox") then p.Character.LunarBox:Destroy() end end

            if getgenv().LunarState.Tracers then
                local pos, on = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                if on then
                    local l = getgenv().LunarState.Lines[lIdx] or Drawing.new("Line")
                    l.Visible = true; l.Thickness = 2; l.Color = getgenv().LunarState.Config.TracerColor
                    l.From = center; l.To = Vector2.new(pos.X, pos.Y)
                    getgenv().LunarState.Lines[lIdx] = l; lIdx = lIdx + 1
                end
            end
        else
            if p.Character and p.Character:FindFirstChild("LunarBox") then p.Character.LunarBox:Destroy() end
        end
    end
    for i = lIdx, #getgenv().LunarState.Lines do getgenv().LunarState.Lines[i].Visible = false end
end)

RunService.Heartbeat:Connect(function()
    if not getgenv().LunarRunning then return end
    modSkip = modSkip + 1
    if modSkip % 10 ~= 0 then return end
    pcall(function()
        for _, v in next, ReplicatedStorage.Weapons:GetChildren() do
            for _, c in next, v:GetChildren() do
                if getgenv().LunarState.Ammo and (c.Name == "Ammo" or c.Name == "StoredAmmo") then c.Value = getgenv().LunarState.Config.AmmoVal end
                if getgenv().LunarState.Acc and (c.Name == "Spread" or c.Name == "RecoilControl") then c.Value = 0 end
                if getgenv().LunarState.FireRate and c.Name == "FireRate" then c.Value = getgenv().LunarState.Config.FireRateVal end
                if getgenv().LunarState.WallBang and (c.Name == "Wallbang" or c.Name == "Penetration") then c.Value = getgenv().LunarState.Config.PenetrationVal end
            end
            if getgenv().LunarState.Auto then
                local m = v:FindFirstChildOfClass("ModuleScript")
                if m then pcall(function() require(m).Auto = true end) end
            end
        end
    end)
end)

task.spawn(function()
    while task.wait(0.3) do
        if not getgenv().LunarRunning then break end
        if getgenv().LunarState.AutoInspect and not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            VIM:SendKeyEvent(true, Enum.KeyCode.F, false, game)
            task.wait()
            VIM:SendKeyEvent(false, Enum.KeyCode.F, false, game)
        end
    end
end)

task.spawn(function()
    while task.wait(0.05) do
        if not getgenv().LunarRunning then break end
        if getgenv().LunarState.Rage then
            pcall(function()
                local target = nil
                local dist = 1000
                for _, p in pairs(Players:GetPlayers()) do
                    if isEnemy(p) and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local d = (p.Character.HumanoidRootPart.Position - Camera.CFrame.Position).Magnitude
                        if d < dist then target = p; dist = d end
                    end
                end
                if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local tHRP = target.Character.HumanoidRootPart
                        local cfg = getgenv().LunarState.Config
                        hrp.CFrame = CFrame.new(tHRP.Position + Vector3.new(0, cfg.RageHeight, 0), tHRP.Position) * CFrame.Angles(0, tick() * cfg.RageSpinSpeed, 0)
                        hrp.Velocity = Vector3.new(0,0,0)
                        Camera.CFrame = CFrame.new(Camera.CFrame.Position, tHRP.Position)
                        Mouse.Hit = CFrame.new(tHRP.Position)
                        shoot()
                    end
                end
            end)
        end
    end
end)

UserInputService.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.RightShift then
        Library:Toggle()
        if not MyUI then SyncUI() end
        if MyUI then
            uiVisible = not uiVisible
            MyUI.Enabled = uiVisible
        end
    end
end)