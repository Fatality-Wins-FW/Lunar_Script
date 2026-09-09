print("[Lunar] Initializing Loader...")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local VIM = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

if CoreGui:FindFirstChild("Lunar_Arsenal_V1") then 
    CoreGui.Lunar_Arsenal_V1:Destroy() 
end

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
        PenetrationVal = 100,
        SilentFOV = 200,
        Theme = {
            MainColor = Color3.fromRGB(45, 45, 45),
            AccentColor = Color3.fromRGB(0, 170, 255),
            TextColor = Color3.fromRGB(255, 255, 255)
        },
        Visuals = {
            AimbotFovColor = Color3.fromRGB(0, 170, 255),
            SilentFovColor = Color3.fromRGB(0, 255, 0),
            EspBoxColor = Color3.fromRGB(255, 0, 0),
            TracerColor = Color3.fromRGB(255, 0, 0),
            FovThickness = 1,
            TracerThickness = 2,
            EspStyle = "2D Box"
        },
        Keys = {
            Aimbot = Enum.KeyCode.None,
            Trigger = Enum.KeyCode.None,
            Silent = Enum.KeyCode.None,
            Rage = Enum.KeyCode.None
        }
    }
}

local MyUI = nil
local uiVisible = true
local isShooting = false

local fovCircle, silentFovCircle = nil, nil
local hasDrawing = pcall(function() Drawing.new("Circle") end)

if hasDrawing then
    fovCircle = Drawing.new("Circle")
    fovCircle.Thickness = getgenv().LunarState.Config.Visuals.FovThickness
    fovCircle.Color = getgenv().LunarState.Config.Visuals.AimbotFovColor
    fovCircle.Filled = false
    fovCircle.Visible = false
    fovCircle.Radius = getgenv().LunarState.Config.AimFOV

    silentFovCircle = Drawing.new("Circle")
    silentFovCircle.Thickness = getgenv().LunarState.Config.Visuals.FovThickness
    silentFovCircle.Color = getgenv().LunarState.Config.Visuals.SilentFovColor
    silentFovCircle.Filled = false
    silentFovCircle.Visible = false
    silentFovCircle.Radius = getgenv().LunarState.Config.SilentFOV
else
    warn("[Lunar] Drawing library not found! FOV circles will be disabled.")
end

local function SyncUI()
    for _, v in pairs(CoreGui:GetChildren()) do
        if v:IsA("ScreenGui") and (v.Name == "Linoria" or v:FindFirstChild("Main")) then
            MyUI = v
            return v
        end
    end
end

local function isFeatureActive(featureName)
    local state = getgenv().LunarState[featureName]
    local key = getgenv().LunarState.Config.Keys[featureName]
    if not state then return false end
    if key ~= Enum.KeyCode.None then
        return UserInputService:IsKeyDown(key)
    end
    return true
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

-- FIXED LOADER: Standard LinoriaLib + Addons Loading
print("[Lunar] Loading UI Libraries...")
local Library = loadstring(game:HttpGet("https://github.com/violin-suzutsuki/LinoriaLib/raw/refs/heads/main/Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://github.com/violin-suzutsuki/LinoriaLib/raw/refs/heads/main/addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet("https://github.com/violin-suzutsuki/LinoriaLib/raw/refs/heads/main/addons/SaveManager.lua"))()

Library:SetWatermarkVisibility(false)

local Window = Library:CreateWindow({
    Title = "Lunar | Arsenal | V1",
    Center = true,
    AutoShow = true
})

task.wait(0.5)
SyncUI()

local function GetClosestTarget(maxDist)
    local target, dist = nil, maxDist or getgenv().LunarState.Config.AimFOV
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

local function createEsp(player)
    if not player.Character or player.Character:FindFirstChild("LunarEsp") then return end
    
    local style = getgenv().LunarState.Config.Visuals.EspStyle
    local color = getgenv().LunarState.Config.Visuals.EspBoxColor
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local esp = Instance.new("BillboardGui", player.Character)
    esp.Name = "LunarEsp"
    esp.AlwaysOnTop = true
    esp.Adornee = hrp
    
    -- FIXED: Removed invalid .Position assignment. BillboardGuis follow Adornee automatically.
    if style == "2D Box" then
        esp.Size = UDim2.new(4, 0, 5, 0)
        local t = 0.05
        local function addFrame(pos, size)
            local fr = Instance.new("Frame", esp)
            fr.Size = size
            fr.Position = pos
            fr.BackgroundColor3 = color
            fr.BorderSizePixel = 0
        end
        addFrame(UDim2.new(0,0,0,0), UDim2.new(1,0,t,0))
        addFrame(UDim2.new(0,0,1-t,0), UDim2.new(1,0,t,0))
        addFrame(UDim2.new(0,0,0,0), UDim2.new(t,0,1,0))
        addFrame(UDim2.new(1-t,0,0,0), UDim2.new(t,0,1,0))
        
    elseif style == "3D Box" then
        esp.Size = UDim2.new(5, 0, 6, 0)
        local outline = Instance.new("Frame", esp)
        outline.Size = UDim2.new(1,0,1,0)
        outline.BackgroundTransparency = 1
        local border = Instance.new("UIStroke", outline)
        border.Color = color
        border.Thickness = 2
        border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        
    elseif style == "Corner" then
        esp.Size = UDim2.new(4, 0, 5, 0)
        local t = 0.15
        local w = 0.04
        local function addCorner(pos, size)
            local fr = Instance.new("Frame", esp)
            fr.Size = size
            fr.Position = pos
            fr.BackgroundColor3 = color
            fr.BorderSizePixel = 0
        end
        addCorner(UDim2.new(0,0,0,0), UDim2.new(w,0,t,0))
        addCorner(UDim2.new(0,0,0,0), UDim2.new(t,0,w,0))
        addCorner(UDim2.new(1-w,0,0,0), UDim2.new(w,0,t,0))
        addCorner(UDim2.new(1-t,0,0,0), UDim2.new(t,0,w,0))
        addCorner(UDim2.new(0,0,1-t,0), UDim2.new(w,0,t,0))
        addCorner(UDim2.new(0,0,1-w,0), UDim2.new(t,0,w,0))
        addCorner(UDim2.new(1-w,0,1-t,0), UDim2.new(w,0,t,0))
        addCorner(UDim2.new(1-t,0,1-w,0), UDim2.new(t,0,w,0))
    end
end

local function safeAdd(groupbox, method, ...)
    local args = {...}
    local ok, res = pcall(function()
        return groupbox[method](groupbox, unpack(args))
    end)
    if not ok then
        warn(string.format("[Lunar] ⚠️ Skipped '%s': %s", method, tostring(res)))
    end
    return res
end

print("[Lunar] Creating UI Tabs...")
local CombatTab = Window:AddTab("Combat")
local RageTab = Window:AddTab("Rage")
local VisualsTab = Window:AddTab("Visuals")
local ModsTab = Window:AddTab("Gun Mods")
local MiscTab = Window:AddTab("Misc")
local SettingsTab = Window:AddTab("Settings")

print("[Lunar] Building Combat Section...")
local CombatGroup = CombatTab:AddLeftGroupbox("Aimbot")
safeAdd(CombatGroup, "AddToggle", "AimbotEnabled", {
    Text = "Enable Aimbot",
    Callback = function(s) 
        getgenv().LunarState.Aimbot = s 
        if fovCircle then fovCircle.Visible = s end
    end
})
safeAdd(CombatGroup, "AddSlider", "AimFOV", {
    Text = "FOV Radius",
    Min = 10, Max = 500, Default = 150,
    Rounding = 0,
    Callback = function(v) 
        getgenv().LunarState.Config.AimFOV = v 
        if fovCircle then fovCircle.Radius = v end
    end
})
safeAdd(CombatGroup, "AddSlider", "AimSmooth", {
    Text = "Smoothness (0-1)",
    Min = 0, Max = 1, Default = 0.2,
    Rounding = 2,
    Callback = function(v) getgenv().LunarState.Config.AimSmoothness = v end
})
safeAdd(CombatGroup, "AddDropdown", "AimPart", {
    Text = "Target Part",
    Values = {"Head", "HumanoidRootPart", "UpperTorso"},
    Multi = false,
    Default = "Head",
    Callback = function(v) getgenv().LunarState.Config.AimPart = v end
})

print("[Lunar] Building Triggerbot Section...")
local TriggerGroup = CombatTab:AddRightGroupbox("Triggerbot")
safeAdd(TriggerGroup, "AddToggle", "TriggerEnabled", {
    Text = "Enable Triggerbot",
    Callback = function(s) getgenv().LunarState.Trigger = s end
})
safeAdd(TriggerGroup, "AddSlider", "TriggerDelay", {
    Text = "Shot Delay (s)",
    Min = 0, Max = 0.5, Default = 0.025,
    Rounding = 3,
    Callback = function(v) getgenv().LunarState.Config.TriggerDelay = v end
})

print("[Lunar] Building Silent Aim Section...")
local SilentGroup = CombatTab:AddRightGroupbox("Silent Aim")
safeAdd(SilentGroup, "AddToggle", "SilentEnabled", {
    Text = "Enable Silent Aim",
    Callback = function(state)
        getgenv().LunarState.Silent = state
        if silentFovCircle then silentFovCircle.Visible = state end
    end
})
safeAdd(SilentGroup, "AddSlider", "SilentFOV", {
    Text = "Silent FOV",
    Min = 10, Max = 500, Default = 200,
    Rounding = 0,
    Callback = function(v) 
        getgenv().LunarState.Config.SilentFOV = v 
        if silentFovCircle then silentFovCircle.Radius = v end
    end
})

print("[Lunar] Building Rage Section...")
local RageGroup = RageTab:AddLeftGroupbox("Rage Configuration")
safeAdd(RageGroup, "AddToggle", "RageEnabled", {
    Text = "Enable Ragebot",
    Callback = function(s) getgenv().LunarState.Rage = s end
})
safeAdd(RageGroup, "AddSlider", "RageSpin", {
    Text = "Spin Speed",
    Min = 0, Max = 100, Default = 30,
    Rounding = 0,
    Callback = function(v) getgenv().LunarState.Config.RageSpinSpeed = v end
})
safeAdd(RageGroup, "AddSlider", "RageHeight", {
    Text = "Teleport Height",
    Min = 0, Max = 20, Default = 9,
    Rounding = 0,
    Callback = function(v) getgenv().LunarState.Config.RageHeight = v end
})

print("[Lunar] Building Visuals Section...")
local VisualsGroup = VisualsTab:AddLeftGroupbox("ESP Options")
safeAdd(VisualsGroup, "AddToggle", "ESPEnabled", {
    Text = "Enable ESP",
    Callback = function(s) getgenv().LunarState.ESP = s end
})
safeAdd(VisualsGroup, "AddDropdown", "EspStyle", {
    Text = "ESP Style",
    Values = {"2D Box", "3D Box", "Corner"},
    Multi = false,
    Default = "2D Box",
    Callback = function(v) getgenv().LunarState.Config.Visuals.EspStyle = v end
})

local TracerGroup = VisualsTab:AddRightGroupbox("Tracers")
safeAdd(TracerGroup, "AddToggle", "TracerEnabled", {
    Text = "Enable Tracers",
    Callback = function(s) getgenv().LunarState.Tracers = s end
})
safeAdd(TracerGroup, "AddSlider", "TracerThickness", {
    Text = "Tracer Thickness",
    Min = 1, Max = 5, Default = 2,
    Rounding = 0,
    Callback = function(v) getgenv().LunarState.Config.Visuals.TracerThickness = v end
})

print("[Lunar] Building Gun Mods Section...")
local ModsGroup = ModsTab:AddLeftGroupbox("Weapon Tweaks")
safeAdd(ModsGroup, "AddToggle", "AmmoEnabled", {
    Text = "Infinite Ammo",
    Callback = function(s) getgenv().LunarState.Ammo = s end
})
safeAdd(ModsGroup, "AddToggle", "AccEnabled", {
    Text = "100% Accuracy",
    Callback = function(s) getgenv().LunarState.Acc = s end
})
safeAdd(ModsGroup, "AddToggle", "FireRateEnabled", {
    Text = "Custom Fire Rate",
    Callback = function(s) getgenv().LunarState.FireRate = s end
})
safeAdd(ModsGroup, "AddSlider", "FireRateVal", {
    Text = "Fire Rate (s)",
    Min = 0.01, Max = 1, Default = 0.05,
    Rounding = 3,
    Callback = function(v) getgenv().LunarState.Config.FireRateVal = v end
})
safeAdd(ModsGroup, "AddToggle", "AutoEnabled", {
    Text = "All Automatic",
    Callback = function(s) getgenv().LunarState.Auto = s end
})
safeAdd(ModsGroup, "AddToggle", "WallbangEnabled", {
    Text = "Wallbang",
    Callback = function(s) getgenv().LunarState.WallBang = s end
})
safeAdd(ModsGroup, "AddSlider", "PenetrationVal", {
    Text = "Penetration Power",
    Min = 1, Max = 500, Default = 100,
    Rounding = 0,
    Callback = function(v) getgenv().LunarState.Config.PenetrationVal = v end
})

print("[Lunar] Building Misc Section...")
local MiscGroup = MiscTab:AddLeftGroupbox("Utilities")
safeAdd(MiscGroup, "AddToggle", "NoAnimsEnabled", {
    Text = "No Animations",
    Callback = function(s) getgenv().LunarState.NoAnims = s end
})
safeAdd(MiscGroup, "AddToggle", "AutoInspectEnabled", {
    Text = "Auto Inspect",
    Callback = function(s) getgenv().LunarState.AutoInspect = s end
})
safeAdd(MiscGroup, "AddButton", "UnloadBtn", "Unload Script", function()
    getgenv().LunarRunning = false
    for _, l in pairs(getgenv().LunarState.Lines) do l:Remove() end
    if fovCircle then fovCircle:Remove() end
    if silentFovCircle then silentFovCircle:Remove() end
    if MyUI then MyUI:Destroy() end
    Library:Unload()
end)

print("[Lunar] Building Settings Section...")
-- INTEGRATED THEME & SAVE MANAGERS
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({"MenuKeybind"})
ThemeManager:SetFolder("LunarArsenal")
SaveManager:SetFolder("LunarArsenal")

local ConfigGroup = SettingsTab:AddLeftGroupbox("Configuration")
safeAdd(ConfigGroup, "AddButton", "ResetConfigBtn", "Reset Config", function()
    getgenv().LunarState.Config = {
        AimFOV = 150, AimSmoothness = 0.2, AimPart = "Head", TriggerDelay = 0.025,
        RageSpinSpeed = 30, RageHeight = 9, FireRateVal = 0.05, PenetrationVal = 100,
        SilentFOV = 200,
        Theme = {MainColor = Color3.fromRGB(45,45,45), AccentColor = Color3.fromRGB(0,170,255), TextColor = Color3.fromRGB(255,255,255)},
        Visuals = {
            AimbotFovColor = Color3.fromRGB(0,170,255), SilentFovColor = Color3.fromRGB(0,255,0),
            EspBoxColor = Color3.fromRGB(255,0,0), TracerColor = Color3.fromRGB(255,0,0),
            FovThickness = 1, TracerThickness = 2, EspStyle = "2D Box"
        },
        Keys = {Aimbot = Enum.KeyCode.None, Trigger = Enum.KeyCode.None, Silent = Enum.KeyCode.None, Rage = Enum.KeyCode.None}
    }
    if fovCircle then
        fovCircle.Color = getgenv().LunarState.Config.Visuals.AimbotFovColor
        fovCircle.Radius = getgenv().LunarState.Config.AimFOV
        fovCircle.Thickness = getgenv().LunarState.Config.Visuals.FovThickness
    end
    if silentFovCircle then
        silentFovCircle.Color = getgenv().LunarState.Config.Visuals.SilentFovColor
        silentFovCircle.Radius = getgenv().LunarState.Config.SilentFOV
        silentFovCircle.Thickness = getgenv().LunarState.Config.Visuals.FovThickness
    end
    Library:Notify("Config Reset!")
end)

-- Apply ThemeManager and SaveManager to Settings Tab
ThemeManager:ApplyToTab(SettingsTab)
SaveManager:BuildConfigSection(SettingsTab)

print("[Lunar] Starting Runtime Loops...")
local frameSkip = 0
local modSkip = 0

RunService.RenderStepped:Connect(function()
    if not getgenv().LunarRunning then return end
    frameSkip = frameSkip + 1

    if hasDrawing then
        local mLoc = UserInputService:GetMouseLocation()
        fovCircle.Position = Vector2.new(mLoc.X, mLoc.Y)
        fovCircle.Radius = getgenv().LunarState.Config.AimFOV
        silentFovCircle.Position = Vector2.new(mLoc.X, mLoc.Y)
        silentFovCircle.Radius = getgenv().LunarState.Config.SilentFOV
    end

    if getgenv().LunarState.NoAnims and LocalPlayer.Character then
        pcall(function()
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                for _, track in pairs(hum:GetPlayingAnimationTracks()) do track:Stop(0) end
            end
            if LocalPlayer.Character:FindFirstChild("Animate") then LocalPlayer.Character.Animate.Enabled = false end
        end)
    end

    local aimbotActive = isFeatureActive("Aimbot")
    local hasKeybind = getgenv().LunarState.Config.Keys.Aimbot ~= Enum.KeyCode.None
    local mb2Pressed = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    
    if aimbotActive and not isFeatureActive("Rage") then
        local shouldAim = false
        if hasKeybind then
            shouldAim = mb2Pressed
        else
            shouldAim = true
        end
        
        if shouldAim then
            local target = GetClosestTarget()
            if target and target.Character and target.Character:FindFirstChild(getgenv().LunarState.Config.AimPart) then
                local targetPos = target.Character[getgenv().LunarState.Config.AimPart].Position
                local currentPos = Camera.CFrame.Position
                local smooth = getgenv().LunarState.Config.AimSmoothness
                local newCFrame = CFrame.new(currentPos, targetPos)
                Camera.CFrame = Camera.CFrame:Lerp(newCFrame, smooth)
            end
        end
    end

    if isFeatureActive("Trigger") then
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
            if getgenv().LunarState.ESP then 
                createEsp(p)
            else 
                if p.Character:FindFirstChild("LunarEsp") then p.Character.LunarEsp:Destroy() end 
            end

            if getgenv().LunarState.Tracers and hasDrawing then
                local pos, on = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                if on then
                    local l = getgenv().LunarState.Lines[lIdx] or Drawing.new("Line")
                    l.Visible = true
                    l.Thickness = getgenv().LunarState.Config.Visuals.TracerThickness
                    l.Color = getgenv().LunarState.Config.Visuals.TracerColor
                    l.From = center
                    l.To = Vector2.new(pos.X, pos.Y)
                    getgenv().LunarState.Lines[lIdx] = l
                    lIdx = lIdx + 1
                end
            end
        else
            if p.Character and p.Character:FindFirstChild("LunarEsp") then p.Character.LunarEsp:Destroy() end
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
                if getgenv().LunarState.Ammo and (c.Name == "Ammo" or c.Name == "StoredAmmo") then c.Value = 300 end
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
        if isFeatureActive("Rage") then
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

print("[Lunar] All features initialized. Script running successfully!")