print("[Lunar] Initializing Universal Script V1...")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

if CoreGui:FindFirstChild("Lunar_Universal_V1") then
    CoreGui.Lunar_Universal_V1:Destroy()
end

getgenv().LunarRunning = true
getgenv().LunarState = {
    Aimbot = false,
    Trigger = false,
    SilentAim = false,
    ESP = false,
    Tracers = false,
    Chams = false,
    Skeleton = false,
    Names = false,
    HealthBars = false,
    Distance = false,
    Fly = false,
    Speed = false,
    JumpPower = false,
    Noclip = false,
    InfJump = false,
    GodMode = false,
    AntiAim = false,
    SpinBot = false,
    FastDrown = false,
    NoFallDamage = false,
    AutoFarm = false,
    Reach = false,
    KillAura = false,
    ChatSpam = false,
    FakeLag = false,
    Lines = {},
    Config = {
        AimFOV = 150,
        AimSmoothness = 0.2,
        HitPart = "Head",
        TriggerDelay = 0.025,
        WalkSpeed = 16,
        JumpPowerVal = 50,
        FlySpeed = 50,
        Gravity = 196,
        ReachDist = 5,
        Visuals = {
            BoxColor = Color3.fromRGB(255, 0, 0),
            TracerColor = Color3.fromRGB(255, 255, 255),
            ChamsColor = Color3.fromRGB(0, 170, 255),
            EspStyle = "Full Box",
            FovThickness = 1,
            TracerThickness = 2
        },
        Keys = {
            Aimbot = Enum.KeyCode.None,
            Trigger = Enum.KeyCode.None,
            Fly = Enum.KeyCode.None,
            Noclip = Enum.KeyCode.None,
            Speed = Enum.KeyCode.None
        }
    }
}

local MyUI = nil
local uiVisible = true
local isShooting = false
local hasDrawing =
    pcall(
    function()
        Drawing.new("Circle")
    end
)

local fovCircle = nil
if hasDrawing then
    fovCircle = Drawing.new("Circle")
    fovCircle.Thickness = getgenv().LunarState.Config.Visuals.FovThickness
    fovCircle.Color = Color3.fromRGB(255, 255, 255)
    fovCircle.Filled = false
    fovCircle.Visible = false
    fovCircle.Radius = getgenv().LunarState.Config.AimFOV
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
    if not state then
        return false
    end
    if key ~= Enum.KeyCode.None then
        return UserInputService:IsKeyDown(key)
    end
    return true
end

local function isEnemy(p)
    if not p or p == LocalPlayer or not p.Character then
        return false
    end
    local char = p.Character
    local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then
        return false
    end
    if char:FindFirstChildOfClass("ForceField") then
        return false
    end
    return true
end

local function shoot()
    if isShooting then
        return
    end
    isShooting = true
    task.spawn(
        function()
            pcall(
                function()
                    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                    if tool then
                        local shootFunc =
                            tool:FindFirstChild("Shoot") or tool:FindFirstChild("Fire") or tool:FindFirstChild("shoot") or
                            tool:FindFirstChild("fire")
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
                end
            )
            task.wait(getgenv().LunarState.Config.TriggerDelay)
            isShooting = false
        end
    )
end

-- Load LinoriaLib and Addons
local Library =
    loadstring(game:HttpGet("https://github.com/violin-suzutsuki/LinoriaLib/raw/refs/heads/main/Library.lua"))()
local ThemeManager =
    loadstring(
    game:HttpGet("https://github.com/violin-suzutsuki/LinoriaLib/raw/refs/heads/main/addons/ThemeManager.lua")
)()
local SaveManager =
    loadstring(
    game:HttpGet("https://github.com/violin-suzutsuki/LinoriaLib/raw/refs/heads/main/addons/SaveManager.lua")
)()

Library:SetWatermarkVisibility(false)

local Window = Library:CreateWindow({Title = "Lunar | Universal | V1", Center = true, AutoShow = true})
task.wait(0.5)
SyncUI()

local function GetClosestTarget(maxDist)
    local target, dist = nil, maxDist or getgenv().LunarState.Config.AimFOV
    local mLoc = UserInputService:GetMouseLocation()
    for _, p in pairs(Players:GetPlayers()) do
        if isEnemy(p) and p.Character then
            local partName = getgenv().LunarState.Config.HitPart
            local part = p.Character:FindFirstChild(partName) or p.Character:FindFirstChild("HumanoidRootPart")
            if part then
                local pos, on = Camera:WorldToViewportPoint(part.Position)
                if on then
                    local mag = (Vector2.new(pos.X, pos.Y) - mLoc).Magnitude
                    if mag < dist then
                        target = p
                        dist = mag
                    end
                end
            end
        end
    end
    return target
end

local SkeletonBones = {
    R15 = {
        {"Head", "UpperTorso"},
        {"UpperTorso", "LowerTorso"},
        {"LowerTorso", "LeftUpperLeg"},
        {"LeftUpperLeg", "LeftLowerLeg"},
        {"LeftLowerLeg", "LeftFoot"},
        {"LowerTorso", "RightUpperLeg"},
        {"RightUpperLeg", "RightLowerLeg"},
        {"RightLowerLeg", "RightFoot"},
        {"UpperTorso", "LeftUpperArm"},
        {"LeftUpperArm", "LeftLowerArm"},
        {"LeftLowerArm", "LeftHand"},
        {"UpperTorso", "RightUpperArm"},
        {"RightUpperArm", "RightLowerArm"},
        {"RightLowerArm", "RightHand"}
    },
    R6 = {
        {"Head", "Torso"},
        {"Torso", "Left Arm"},
        {"Torso", "Right Arm"},
        {"Torso", "Left Leg"},
        {"Torso", "Right Leg"}
    }
}

local ESPObjects = {}
local function CreateESPObject(plr)
    if ESPObjects[plr] then
        return
    end

    -- Initialize Drawing objects safely
    local cornerLines, tracer, name, healthBg, healthBar, skeletons = {}, nil, nil, nil, nil, {}
    if hasDrawing then
        for i = 1, 8 do
            local l = Drawing.new("Line")
            l.Thickness = 1.5
            l.Visible = false
            table.insert(cornerLines, l)
        end
        tracer = Drawing.new("Line")
        tracer.Thickness = 1
        name = Drawing.new("Text")
        name.Size = 13
        name.Center = true
        name.Outline = true
        healthBg = Drawing.new("Square")
        healthBg.Filled = true
        healthBg.Color = Color3.fromRGB(10, 10, 10)
        healthBar = Drawing.new("Square")
        healthBar.Filled = true
        healthBar.Color = Color3.fromRGB(40, 220, 90)
        for i = 1, 15 do
            local l = Drawing.new("Line")
            l.Thickness = 1.5
            table.insert(skeletons, l)
        end
    end

    ESPObjects[plr] = {
        CornerLines = cornerLines,
        Tracer = tracer,
        Name = name,
        HealthBarBg = healthBg,
        HealthBar = healthBar,
        Skeletons = skeletons
    }
end

local function HideESPObject(plr)
    local obj = ESPObjects[plr]
    if not obj or not hasDrawing then
        return
    end
    for _, l in ipairs(obj.CornerLines) do
        l.Visible = false
    end
    obj.Tracer.Visible = false
    obj.Name.Visible = false
    obj.HealthBarBg.Visible = false
    obj.HealthBar.Visible = false
    for _, l in ipairs(obj.Skeletons) do
        l.Visible = false
    end
end

local function RemoveESPObject(plr)
    local obj = ESPObjects[plr]
    if not obj or not hasDrawing then
        return
    end
    for _, l in ipairs(obj.CornerLines) do
        l:Remove()
    end
    obj.Tracer:Remove()
    obj.Name:Remove()
    obj.HealthBarBg:Remove()
    obj.HealthBar:Remove()
    for _, l in ipairs(obj.Skeletons) do
        l:Remove()
    end
    ESPObjects[plr] = nil
end
Players.PlayerRemoving:Connect(RemoveESPObject)

local function createEsp(player)
    if not player.Character then
        return
    end
    CreateESPObject(player)

    local obj = ESPObjects[player]
    local char = player.Character
    local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
    local head = char:FindFirstChild("Head")
    local hum = char:FindFirstChildOfClass("Humanoid")

    if not (char and root and head and hum and hum.Health > 0) then
        HideESPObject(player)
        return
    end

    local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
    if not (onScreen and rootPos.Z > 0) then
        HideESPObject(player)
        return
    end

    local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.7, 0))
    local legPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
    local height = math.abs(headPos.Y - legPos.Y)
    local width = height * 0.6
    local topLeftX = rootPos.X - width / 2
    local topLeftY = headPos.Y
    local color = getgenv().LunarState.Config.Visuals.BoxColor
    local style = getgenv().LunarState.Config.Visuals.EspStyle

    -- FIXED: Removed invalid BillboardGui.Position assignment entirely.
    -- All rendering is now handled exclusively via the safe Drawing API below.

    if hasDrawing and getgenv().LunarState.ESP then
        if style == "Full Box" then
            -- Draw 4 lines for full box using Drawing API
            local t = 0.05
            local hT = height * t
            local wT = width * t

            -- Top
            obj.CornerLines[1].From = Vector2.new(topLeftX, topLeftY)
            obj.CornerLines[1].To = Vector2.new(topLeftX + width, topLeftY)
            obj.CornerLines[1].Color = color
            obj.CornerLines[1].Visible = true

            -- Bottom
            obj.CornerLines[2].From = Vector2.new(topLeftX, topLeftY + height)
            obj.CornerLines[2].To = Vector2.new(topLeftX + width, topLeftY + height)
            obj.CornerLines[2].Color = color
            obj.CornerLines[2].Visible = true

            -- Left
            obj.CornerLines[3].From = Vector2.new(topLeftX, topLeftY)
            obj.CornerLines[3].To = Vector2.new(topLeftX, topLeftY + height)
            obj.CornerLines[3].Color = color
            obj.CornerLines[3].Visible = true

            -- Right
            obj.CornerLines[4].From = Vector2.new(topLeftX + width, topLeftY)
            obj.CornerLines[4].To = Vector2.new(topLeftX + width, topLeftY + height)
            obj.CornerLines[4].Color = color
            obj.CornerLines[4].Visible = true

            -- Hide unused corner lines
            for i = 5, 8 do
                obj.CornerLines[i].Visible = false
            end
        elseif style == "Corner Box" then
            local lineLen = math.clamp(width * 0.25, 4, 15)
            local topRight = Vector2.new(topLeftX + width, topLeftY)
            local bottomLeft = Vector2.new(topLeftX, topLeftY + height)
            local bottomRight = Vector2.new(topLeftX + width, topLeftY + height)

            -- Top Left
            obj.CornerLines[1].From = Vector2.new(topLeftX, topLeftY)
            obj.CornerLines[1].To = Vector2.new(topLeftX + lineLen, topLeftY)
            obj.CornerLines[1].Color = color
            obj.CornerLines[1].Visible = true

            obj.CornerLines[2].From = Vector2.new(topLeftX, topLeftY)
            obj.CornerLines[2].To = Vector2.new(topLeftX, topLeftY + lineLen)
            obj.CornerLines[2].Color = color
            obj.CornerLines[2].Visible = true

            -- Top Right
            obj.CornerLines[3].From = topRight
            obj.CornerLines[3].To = Vector2.new(topRight.X - lineLen, topRight.Y)
            obj.CornerLines[3].Color = color
            obj.CornerLines[3].Visible = true

            obj.CornerLines[4].From = topRight
            obj.CornerLines[4].To = Vector2.new(topRight.X, topRight.Y + lineLen)
            obj.CornerLines[4].Color = color
            obj.CornerLines[4].Visible = true

            -- Bottom Left
            obj.CornerLines[5].From = bottomLeft
            obj.CornerLines[5].To = Vector2.new(bottomLeft.X + lineLen, bottomLeft.Y)
            obj.CornerLines[5].Color = color
            obj.CornerLines[5].Visible = true

            obj.CornerLines[6].From = bottomLeft
            obj.CornerLines[6].To = Vector2.new(bottomLeft.X, bottomLeft.Y - lineLen)
            obj.CornerLines[6].Color = color
            obj.CornerLines[6].Visible = true

            -- Bottom Right
            obj.CornerLines[7].From = bottomRight
            obj.CornerLines[7].To = Vector2.new(bottomRight.X - lineLen, bottomRight.Y)
            obj.CornerLines[7].Color = color
            obj.CornerLines[7].Visible = true

            obj.CornerLines[8].From = bottomRight
            obj.CornerLines[8].To = Vector2.new(bottomRight.X, bottomRight.Y - lineLen)
            obj.CornerLines[8].Color = color
            obj.CornerLines[8].Visible = true
        end
    elseif hasDrawing then
        for i = 1, 8 do
            obj.CornerLines[i].Visible = false
        end
    end

    if hasDrawing then
        if getgenv().LunarState.Tracers then
            obj.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            obj.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
            obj.Tracer.Color = getgenv().LunarState.Config.Visuals.TracerColor
            obj.Tracer.Thickness = getgenv().LunarState.Config.Visuals.TracerThickness
            obj.Tracer.Visible = true
        else
            obj.Tracer.Visible = false
        end

        if getgenv().LunarState.Names or getgenv().LunarState.Distance then
            local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local dist = myHRP and math.floor((myHRP.Position - root.Position).Magnitude) or 0
            local text = ""
            if getgenv().LunarState.Names then
                text = player.Name
            end
            if getgenv().LunarState.Distance then
                text = text .. (text ~= "" and " [" or "[") .. dist .. "m]"
            end
            obj.Name.Text = text
            obj.Name.Position = Vector2.new(rootPos.X, topLeftY - 16)
            obj.Name.Color = Color3.fromRGB(255, 255, 255)
            obj.Name.Visible = true
        else
            obj.Name.Visible = false
        end

        if getgenv().LunarState.HealthBars then
            local hpPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
            obj.HealthBarBg.Size = Vector2.new(3, height)
            obj.HealthBarBg.Position = Vector2.new(topLeftX - 6, topLeftY)
            obj.HealthBarBg.Visible = true
            obj.HealthBar.Size = Vector2.new(3, height * hpPercent)
            obj.HealthBar.Position = Vector2.new(topLeftX - 6, topLeftY + (height * (1 - hpPercent)))
            obj.HealthBar.Visible = true
        else
            obj.HealthBarBg.Visible = false
            obj.HealthBar.Visible = false
        end

        if getgenv().LunarState.Skeleton then
            local rigType = (hum.RigType == Enum.HumanoidRigType.R15) and "R15" or "R6"
            local pairsList = SkeletonBones[rigType]
            for i, line in ipairs(obj.Skeletons) do
                if pairsList[i] then
                    local partA = char:FindFirstChild(pairsList[i][1])
                    local partB = char:FindFirstChild(pairsList[i][2])
                    if partA and partB then
                        local posA, visA = Camera:WorldToViewportPoint(partA.Position)
                        local posB, visB = Camera:WorldToViewportPoint(partB.Position)
                        if visA and visB and posA.Z > 0 and posB.Z > 0 then
                            line.From = Vector2.new(posA.X, posA.Y)
                            line.To = Vector2.new(posB.X, posB.Y)
                            line.Color = color
                            line.Visible = true
                        else
                            line.Visible = false
                        end
                    else
                        line.Visible = false
                    end
                else
                    line.Visible = false
                end
            end
        else
            for _, l in ipairs(obj.Skeletons) do
                l.Visible = false
            end
        end
    end
end

print("[Lunar] Creating UI Tabs...")
local CombatTab = Window:AddTab("Combat")
local VisualsTab = Window:AddTab("Visuals")
local MiscTab = Window:AddTab("Misc")
local SettingsTab = Window:AddTab("Settings")

print("[Lunar] Building Combat Section...")
local CombatGroup = CombatTab:AddLeftGroupbox("Aimbot & Trigger")
local aimbotToggle =
    CombatGroup:AddToggle(
    "AimbotEnabled",
    {Text = "Enable Aimbot", Callback = function(s)
            getgenv().LunarState.Aimbot = s
            if fovCircle then
                fovCircle.Visible = s
            end
        end}
)
aimbotToggle:AddKeyPicker(
    "AimbotKey",
    {
        Default = "None",
        SyncToggleState = false,
        Mode = "Hold",
        Text = "Aimbot Key",
        NoUI = true,
        ChangedCallback = function(new)
            getgenv().LunarState.Config.Keys.Aimbot = new
        end
    }
)
CombatGroup:AddSlider(
    "AimFOV",
    {Text = "FOV Radius", Min = 10, Max = 500, Default = 150, Rounding = 0, Callback = function(v)
            getgenv().LunarState.Config.AimFOV = v
            if fovCircle then
                fovCircle.Radius = v
            end
        end}
)
CombatGroup:AddSlider(
    "AimSmooth",
    {Text = "Smoothness", Min = 0, Max = 1, Default = 0.2, Rounding = 2, Callback = function(v)
            getgenv().LunarState.Config.AimSmoothness = v
        end}
)
CombatGroup:AddDropdown(
    "HitPart",
    {
        Text = "Target Part",
        Values = {"Head", "HumanoidRootPart", "UpperTorso", "Torso"},
        Multi = false,
        Default = "Head",
        Callback = function(v)
            getgenv().LunarState.Config.HitPart = v
        end
    }
)

local triggerToggle =
    CombatGroup:AddToggle(
    "TriggerEnabled",
    {Text = "Enable Triggerbot", Callback = function(s)
            getgenv().LunarState.Trigger = s
        end}
)
triggerToggle:AddKeyPicker(
    "TriggerKey",
    {
        Default = "None",
        SyncToggleState = false,
        Mode = "Hold",
        Text = "Trigger Key",
        NoUI = true,
        ChangedCallback = function(new)
            getgenv().LunarState.Config.Keys.Trigger = new
        end
    }
)
CombatGroup:AddSlider(
    "TriggerDelay",
    {Text = "Shot Delay", Min = 0, Max = 0.5, Default = 0.025, Rounding = 3, Callback = function(v)
            getgenv().LunarState.Config.TriggerDelay = v
        end}
)
CombatGroup:AddToggle(
    "SilentAim",
    {Text = "Silent Aim", Callback = function(s)
            getgenv().LunarState.SilentAim = s
        end}
)
CombatGroup:AddToggle(
    "KillAura",
    {Text = "Kill Aura", Callback = function(s)
            getgenv().LunarState.KillAura = s
        end}
)
CombatGroup:AddSlider(
    "Reach",
    {Text = "Reach Distance", Min = 1, Max = 20, Default = 5, Rounding = 0, Callback = function(v)
            getgenv().LunarState.Config.ReachDist = v
        end}
)

print("[Lunar] Building Visuals Section...")
local VisualsGroup = VisualsTab:AddLeftGroupbox("ESP Features")
VisualsGroup:AddToggle(
    "ESPEnabled",
    {Text = "Enable ESP Boxes", Callback = function(s)
            getgenv().LunarState.ESP = s
        end}
)
VisualsGroup:AddDropdown(
    "EspStyle",
    {
        Text = "Box Style",
        Values = {"Full Box", "Corner Box"},
        Multi = false,
        Default = "Full Box",
        Callback = function(v)
            getgenv().LunarState.Config.Visuals.EspStyle = v
        end
    }
)
VisualsGroup:AddToggle(
    "TracerEnabled",
    {Text = "Tracers", Callback = function(s)
            getgenv().LunarState.Tracers = s
        end}
)
VisualsGroup:AddToggle(
    "ChamsEnabled",
    {Text = "Chams", Callback = function(s)
            getgenv().LunarState.Chams = s
        end}
)
VisualsGroup:AddToggle(
    "SkeletonEnabled",
    {Text = "Skeleton", Callback = function(s)
            getgenv().LunarState.Skeleton = s
        end}
)
VisualsGroup:AddToggle(
    "NamesEnabled",
    {Text = "Player Names", Callback = function(s)
            getgenv().LunarState.Names = s
        end}
)
VisualsGroup:AddToggle(
    "DistanceEnabled",
    {Text = "Distance", Callback = function(s)
            getgenv().LunarState.Distance = s
        end}
)
VisualsGroup:AddToggle(
    "HealthBarsEnabled",
    {Text = "Health Bars", Callback = function(s)
            getgenv().LunarState.HealthBars = s
        end}
)

local TracerGroup = VisualsTab:AddRightGroupbox("Colors & Thickness")
TracerGroup:AddSlider(
    "TracerThickness",
    {Text = "Tracer Thickness", Min = 1, Max = 5, Default = 2, Rounding = 0, Callback = function(v)
            getgenv().LunarState.Config.Visuals.TracerThickness = v
        end}
)

print("[Lunar] Building Misc Section...")
local MiscGroup = MiscTab:AddLeftGroupbox("Movement & Physics")
local flyToggle =
    MiscGroup:AddToggle(
    "FlyEnabled",
    {Text = "Fly Mode", Callback = function(s)
            getgenv().LunarState.Fly = s
        end}
)
flyToggle:AddKeyPicker(
    "FlyKey",
    {
        Default = "None",
        SyncToggleState = false,
        Mode = "Hold",
        Text = "Fly Key",
        NoUI = true,
        ChangedCallback = function(new)
            getgenv().LunarState.Config.Keys.Fly = new
        end
    }
)
MiscGroup:AddSlider(
    "FlySpeed",
    {Text = "Fly Speed", Min = 10, Max = 300, Default = 50, Rounding = 0, Callback = function(v)
            getgenv().LunarState.Config.FlySpeed = v
        end}
)

local speedToggle =
    MiscGroup:AddToggle(
    "SpeedEnabled",
    {Text = "Walk Speed", Callback = function(s)
            getgenv().LunarState.Speed = s
        end}
)
speedToggle:AddKeyPicker(
    "SpeedKey",
    {
        Default = "None",
        SyncToggleState = false,
        Mode = "Hold",
        Text = "Speed Key",
        NoUI = true,
        ChangedCallback = function(new)
            getgenv().LunarState.Config.Keys.Speed = new
        end
    }
)
MiscGroup:AddSlider(
    "WalkSpeed",
    {Text = "Speed Value", Min = 16, Max = 300, Default = 16, Rounding = 0, Callback = function(v)
            getgenv().LunarState.Config.WalkSpeed = v
        end}
)

MiscGroup:AddToggle(
    "JumpPowerEnabled",
    {Text = "Custom Jump Power", Callback = function(s)
            getgenv().LunarState.JumpPower = s
        end}
)
MiscGroup:AddSlider(
    "JumpPower",
    {Text = "Jump Power Value", Min = 50, Max = 350, Default = 50, Rounding = 0, Callback = function(v)
            getgenv().LunarState.Config.JumpPowerVal = v
        end}
)
MiscGroup:AddSlider(
    "Gravity",
    {Text = "Gravity", Min = 0, Max = 196, Default = 196, Rounding = 0, Callback = function(v)
            getgenv().LunarState.Config.Gravity = v
        end}
)
MiscGroup:AddToggle(
    "InfJump",
    {Text = "Infinite Jump", Callback = function(s)
            getgenv().LunarState.InfJump = s
        end}
)
local noclipToggle =
    MiscGroup:AddToggle(
    "NoclipEnabled",
    {Text = "Noclip", Callback = function(s)
            getgenv().LunarState.Noclip = s
        end}
)
noclipToggle:AddKeyPicker(
    "NoclipKey",
    {
        Default = "None",
        SyncToggleState = false,
        Mode = "Hold",
        Text = "Noclip Key",
        NoUI = true,
        ChangedCallback = function(new)
            getgenv().LunarState.Config.Keys.Noclip = new
        end
    }
)

print("[Lunar] Building Extra Features Section...")
local ExtraGroup = MiscTab:AddRightGroupbox("Extra Features")
ExtraGroup:AddToggle(
    "GodMode",
    {Text = "God Mode", Callback = function(s)
            getgenv().LunarState.GodMode = s
        end}
)
ExtraGroup:AddToggle(
    "AntiAim",
    {Text = "Anti Aim (Moveable)", Callback = function(s)
            getgenv().LunarState.AntiAim = s
        end}
)
ExtraGroup:AddToggle(
    "SpinBot",
    {Text = "Spin Bot", Callback = function(s)
            getgenv().LunarState.SpinBot = s
        end}
)
ExtraGroup:AddToggle(
    "FastDrown",
    {Text = "Fast Drown", Callback = function(s)
            getgenv().LunarState.FastDrown = s
        end}
)
ExtraGroup:AddToggle(
    "NoFallDamage",
    {Text = "No Fall Damage", Callback = function(s)
            getgenv().LunarState.NoFallDamage = s
        end}
)
ExtraGroup:AddToggle(
    "AutoFarm",
    {Text = "Auto Farm", Callback = function(s)
            getgenv().LunarState.AutoFarm = s
        end}
)
ExtraGroup:AddToggle(
    "ChatSpam",
    {Text = "Chat Spam", Callback = function(s)
            getgenv().LunarState.ChatSpam = s
        end}
)
ExtraGroup:AddToggle(
    "FakeLag",
    {Text = "Fake Lag", Callback = function(s)
            getgenv().LunarState.FakeLag = s
        end}
)

print("[Lunar] Building Settings Section...")
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({"MenuKeybind"})
ThemeManager:SetFolder("LunarUniversal")
SaveManager:SetFolder("LunarUniversal")

local ConfigGroup = SettingsTab:AddLeftGroupbox("Configuration")
ConfigGroup:AddButton(
    "Unload",
    function()
        getgenv().LunarRunning = false
        for _, l in pairs(getgenv().LunarState.Lines) do
            l:Remove()
        end
        if fovCircle then
            fovCircle:Remove()
        end
        if MyUI then
            MyUI:Destroy()
        end
        Library:Unload()
    end
)

ThemeManager:ApplyToTab(SettingsTab)
SaveManager:BuildConfigSection(SettingsTab)

print("[Lunar] Starting Runtime Loops...")
local frameSkip = 0
local flyBodyVel, flyBodyGyro, flyConn
local noclipConn, infJumpConn, godConn, aaConn, spinConn, drownConn, fallConn, farmConn, spamConn, lagConn

RunService.RenderStepped:Connect(
    function()
        if not getgenv().LunarRunning then
            return
        end
        frameSkip = frameSkip + 1
        local Character = LocalPlayer.Character

        if hasDrawing and fovCircle then
            local mLoc = UserInputService:GetMouseLocation()
            fovCircle.Position = Vector2.new(mLoc.X, mLoc.Y)
            fovCircle.Radius = getgenv().LunarState.Config.AimFOV
        end

        if Character then
            local hum = Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = isFeatureActive("Speed") and getgenv().LunarState.Config.WalkSpeed or 16
                if getgenv().LunarState.JumpPower then
                    hum.UseJumpPower = true
                    hum.JumpPower = getgenv().LunarState.Config.JumpPowerVal
                end
            end
            workspace.Gravity = getgenv().LunarState.Config.Gravity

            -- Fly Logic with proper cleanup
            if isFeatureActive("Fly") then
                local hrp = Character:FindFirstChild("HumanoidRootPart") or Character:FindFirstChild("Torso")
                if hrp and not flyConn then
                    flyBodyVel = Instance.new("BodyVelocity")
                    flyBodyVel.MaxForce = Vector3.new(1, 1, 1) * 1e6
                    flyBodyVel.Velocity = Vector3.zero
                    flyBodyVel.Parent = hrp
                    flyBodyGyro = Instance.new("BodyGyro")
                    flyBodyGyro.MaxTorque = Vector3.new(1, 1, 1) * 1e6
                    flyBodyGyro.CFrame = hrp.CFrame
                    flyBodyGyro.Parent = hrp
                    flyConn =
                        RunService.RenderStepped:Connect(
                        function()
                            if not isFeatureActive("Fly") or not hrp then
                                return
                            end
                            local move = Vector3.zero
                            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                                move = move + Camera.CFrame.LookVector
                            end
                            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                                move = move - Camera.CFrame.LookVector
                            end
                            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                                move = move - Camera.CFrame.RightVector
                            end
                            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                                move = move + Camera.CFrame.RightVector
                            end
                            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                                move = move + Vector3.new(0, 1, 0)
                            end
                            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                                move = move - Vector3.new(0, 1, 0)
                            end
                            flyBodyVel.Velocity = move * getgenv().LunarState.Config.FlySpeed
                            flyBodyGyro.CFrame = Camera.CFrame
                        end
                    )
                elseif not isFeatureActive("Fly") and flyConn then
                    flyConn:Disconnect()
                    if flyBodyVel then
                        flyBodyVel:Destroy()
                    end
                    if flyBodyGyro then
                        flyBodyGyro:Destroy()
                    end
                    flyConn = nil
                end
            else
                if flyConn then
                    flyConn:Disconnect()
                    if flyBodyVel then
                        flyBodyVel:Destroy()
                    end
                    if flyBodyGyro then
                        flyBodyGyro:Destroy()
                    end
                    flyConn = nil
                end
            end

            -- Noclip Logic
            if getgenv().LunarState.Noclip then
                if not noclipConn then
                    noclipConn =
                        RunService.Stepped:Connect(
                        function()
                            if Character then
                                for _, p in ipairs(Character:GetChildren()) do
                                    if p:IsA("BasePart") then
                                        p.CanCollide = false
                                    end
                                end
                            end
                        end
                    )
                end
            elseif noclipConn then
                noclipConn:Disconnect()
                noclipConn = nil
            end

            -- Infinite Jump
            if getgenv().LunarState.InfJump then
                if not infJumpConn then
                    infJumpConn =
                        UserInputService.JumpRequest:Connect(
                        function()
                            local h = Character:FindFirstChildOfClass("Humanoid")
                            if h then
                                h:ChangeState(Enum.HumanoidStateType.Jumping)
                            end
                        end
                    )
                end
            elseif infJumpConn then
                infJumpConn:Disconnect()
                infJumpConn = nil
            end

            -- God Mode
            if getgenv().LunarState.GodMode then
                if not godConn then
                    godConn =
                        RunService.Heartbeat:Connect(
                        function()
                            if hum then
                                hum.Health = hum.MaxHealth
                            end
                        end
                    )
                end
            elseif godConn then
                godConn:Disconnect()
                godConn = nil
            end

            -- Anti Aim / Spin Bot (Allows Movement via Relative CFrame)
            if getgenv().LunarState.AntiAim or getgenv().LunarState.SpinBot then
                if not aaConn then
                    aaConn =
                        RunService.RenderStepped:Connect(
                        function()
                            local hrp = Character:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                -- Multiply current CFrame by rotation so WASD still applies to base orientation
                                if getgenv().LunarState.SpinBot then
                                    hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(tick() * 500), 0)
                                end
                                if getgenv().LunarState.AntiAim then
                                    hrp.CFrame = hrp.CFrame * CFrame.Angles(math.rad(90), 0, 0)
                                end
                            end
                        end
                    )
                end
            elseif aaConn then
                aaConn:Disconnect()
                aaConn = nil
            end

            -- Fast Drown
            if getgenv().LunarState.FastDrown then
                if not drownConn then
                    drownConn =
                        RunService.Heartbeat:Connect(
                        function()
                            if hum then
                                hum:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
                            end
                        end
                    )
                end
            elseif drownConn then
                drownConn:Disconnect()
                drownConn = nil
            end

            -- No Fall Damage
            if getgenv().LunarState.NoFallDamage then
                if not fallConn then
                    fallConn =
                        hum.StateChanged:Connect(
                        function(old, new)
                            if new == Enum.HumanoidStateType.Freefall then
                                hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
                            end
                        end
                    )
                end
            elseif fallConn then
                fallConn:Disconnect()
                fallConn = nil
            end

            -- Chams
            if getgenv().LunarState.Chams then
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character and not plr.Character:FindFirstChild("LunarChams") then
                        local h = Instance.new("Highlight")
                        h.Name = "LunarChams"
                        h.FillColor = getgenv().LunarState.Config.Visuals.ChamsColor
                        h.FillTransparency = 0.5
                        h.Parent = plr.Character
                    end
                end
            else
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr.Character then
                        local h = plr.Character:FindFirstChild("LunarChams")
                        if h then
                            h:Destroy()
                        end
                    end
                end
            end
        end

        -- Aimbot with Keybind Check
        if isFeatureActive("Aimbot") and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local target = GetClosestTarget()
            if target and target.Character then
                local partName = getgenv().LunarState.Config.HitPart
                local part =
                    target.Character:FindFirstChild(partName) or target.Character:FindFirstChild("HumanoidRootPart")
                if part then
                    local targetPos = part.Position
                    local currentPos = Camera.CFrame.Position
                    local smooth = getgenv().LunarState.Config.AimSmoothness
                    Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(currentPos, targetPos), smooth)
                end
            end
        end

        -- Triggerbot with Keybind Check
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

        if frameSkip % 2 ~= 0 then
            return
        end
        local lIdx = 1
        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        for _, p in pairs(Players:GetPlayers()) do
            if isEnemy(p) and p.Character then
                createEsp(p)
                if getgenv().LunarState.Tracers and hasDrawing then
                    local root = p.Character:FindFirstChild("HumanoidRootPart") or p.Character:FindFirstChild("Torso")
                    if root then
                        local pos, on = Camera:WorldToViewportPoint(root.Position)
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
                end
            else
                if p.Character and ESPObjects[p] then
                    HideESPObject(p)
                end
            end
        end
        for i = lIdx, #getgenv().LunarState.Lines do
            getgenv().LunarState.Lines[i].Visible = false
        end
    end
)

UserInputService.InputBegan:Connect(
    function(i, gp)
        if gp then
            return
        end
        if i.KeyCode == Enum.KeyCode.RightShift then
            Library:Toggle()
            if not MyUI then
                SyncUI()
            end
            if MyUI then
                uiVisible = not uiVisible
                MyUI.Enabled = uiVisible
            end
        end
    end
)

print("[Lunar] Universal Script V1 initialized successfully!")
