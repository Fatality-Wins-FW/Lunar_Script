print("[Lunar] Initializing Universal Script...")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

if CoreGui:FindFirstChild("Lunar_Universal") then 
    CoreGui.Lunar_Universal:Destroy() 
end

getgenv().LunarRunning = true
getgenv().LunarState = {
    Aimbot = false,
    Trigger = false,
    ESP = false,
    Tracers = false,
    Chams = false,
    Skeleton = false,
    Fly = false,
    Speed = false,
    JumpPower = false,
    Noclip = false,
    InfJump = false,
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
            Trigger = Enum.KeyCode.None
        }
    }
}

local MyUI = nil
local uiVisible = true
local isShooting = false
local hasDrawing = pcall(function() Drawing.new("Circle") end)

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
    if not state then return false end
    if key ~= Enum.KeyCode.None then
        return UserInputService:IsKeyDown(key)
    end
    return true
end

local function isEnemy(p)
    if not p or p == LocalPlayer or not p.Character then return false end
    local char = p.Character
    local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return false end
    if char:FindFirstChildOfClass("ForceField") then return false end
    return true
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

local Library = loadstring(game:HttpGet("https://github.com/violin-suzutsuki/LinoriaLib/raw/refs/heads/main/Library.lua"))()
Library:SetWatermarkVisibility(false)

local Window = Library:CreateWindow({
    Title = "Lunar | Universal | V1",
    Center = true,
    AutoShow = true
})

task.wait(0.5)
SyncUI()

local function GetClosestTarget(maxDist)
    local target, dist = nil, maxDist or getgenv().LunarState.Config.AimFOV
    local mLoc = UserInputService:GetMouseLocation()
    for _, p in pairs(Players:GetPlayers()) do
        if isEnemy(p) and p.Character then
            local partName = getgenv().LunarState.Config.HitPart
            local part = p.Character:FindFirstChild(partName) or p.Character:FindFirstChild("HumanoidRootPart") or p.Character:FindFirstChild("Head")
            if part then
                local pos, on = Camera:WorldToViewportPoint(part.Position)
                if on then
                    local dx = pos.X - mLoc.X
                    local dy = pos.Y - mLoc.Y
                    local mag = math.sqrt(dx*dx + dy*dy)
                    if mag < dist then target = p; dist = mag end
                end
            end
        end
    end
    return target
end

local SkeletonBones = {
    R15 = {
        {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
        {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
        {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"},
        {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
        {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"}
    },
    R6 = {
        {"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"},
        {"Torso", "Left Leg"}, {"Torso", "Right Leg"}
    }
}

local ESPObjects = {}

local function CreateESPObject(plr)
    if ESPObjects[plr] then return end
    
    local cornerLines = {}
    if hasDrawing then
        for i = 1, 8 do
            local line = Drawing.new("Line")
            line.Thickness = 1.5
            line.Visible = false
            table.insert(cornerLines, line)
        end
    end

    ESPObjects[plr] = {
        Box = Instance.new("BillboardGui", plr.Character),
        CornerLines = cornerLines,
        Tracer = hasDrawing and Drawing.new("Line") or nil,
        Name = hasDrawing and Drawing.new("Text") or nil,
        HealthBarBg = hasDrawing and Drawing.new("Square") or nil,
        HealthBar = hasDrawing and Drawing.new("Square") or nil,
        Skeletons = {}
    }

    local obj = ESPObjects[plr]
    
    obj.Box.Name = "LunarEsp"
    obj.Box.AlwaysOnTop = true
    local hrp = plr.Character:FindFirstChild("HumanoidRootPart") or plr.Character:FindFirstChild("Torso")
    if hrp then obj.Box.Adornee = hrp end

    if hasDrawing then
        obj.Tracer.Thickness = 1
        obj.Tracer.Visible = false

        obj.Name.Size = 13
        obj.Name.Center = true
        obj.Name.Outline = true
        obj.Name.Visible = false

        obj.HealthBarBg.Filled = true
        obj.HealthBarBg.Color = Color3.fromRGB(10, 10, 10)
        obj.HealthBarBg.Visible = false

        obj.HealthBar.Filled = true
        obj.HealthBar.Color = Color3.fromRGB(40, 220, 90)
        obj.HealthBar.Visible = false

        for i = 1, 15 do
            local boneLine = Drawing.new("Line")
            boneLine.Thickness = 1.5
            boneLine.Visible = false
            table.insert(obj.Skeletons, boneLine)
        end
    end
end

local function HideESPObject(plr)
    local obj = ESPObjects[plr]
    if not obj then return end
    
    obj.Box:ClearAllChildren()
    
    if hasDrawing then
        for _, line in ipairs(obj.CornerLines) do line.Visible = false end
        obj.Tracer.Visible = false
        obj.Name.Visible = false
        obj.HealthBarBg.Visible = false
        obj.HealthBar.Visible = false
        for _, line in ipairs(obj.Skeletons) do line.Visible = false end
    end
end

local function RemoveESPObject(plr)
    local obj = ESPObjects[plr]
    if not obj then return end
    
    obj.Box:Destroy()
    
    if hasDrawing then
        for _, line in ipairs(obj.CornerLines) do line:Remove() end
        obj.Tracer:Remove()
        obj.Name:Remove()
        obj.HealthBarBg:Remove()
        obj.HealthBar:Remove()
        for _, line in ipairs(obj.Skeletons) do line:Remove() end
    end
    
    ESPObjects[plr] = nil
end

Players.PlayerRemoving:Connect(RemoveESPObject)

local function createEsp(player)
    if not player.Character then return end
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
    local legPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3.0, 0))
    local height = math.abs(headPos.Y - legPos.Y)
    local width = height * 0.6
    local topLeft = Vector2.new(rootPos.X - width / 2, headPos.Y)
    local color = getgenv().LunarState.Config.Visuals.BoxColor
    local style = getgenv().LunarState.Config.Visuals.EspStyle

    -- BillboardGui Box Fallback (Works on ALL executors)
    obj.Box:ClearAllChildren()
    if getgenv().LunarState.ESP then
        if style == "Full Box" then
            obj.Box.Size = UDim2.new(0, width, 0, height)
            obj.Box.Position = UDim2.new(0, topLeft.X, 0, topLeft.Y)
            local t = 0.05
            local function addFrame(pos, size)
                local fr = Instance.new("Frame", obj.Box)
                fr.Size = UDim2.new(size.X.Scale, size.X.Offset, size.Y.Scale, size.Y.Offset)
                fr.Position = UDim2.new(pos.X.Scale, pos.X.Offset, pos.Y.Scale, pos.Y.Offset)
                fr.BackgroundColor3 = color
                fr.BorderSizePixel = 0
            end
            addFrame(UDim2.new(0,0,0,0), UDim2.new(1,0,t,0))
            addFrame(UDim2.new(0,0,1-t,0), UDim2.new(1,0,t,0))
            addFrame(UDim2.new(0,0,0,0), UDim2.new(t,0,1,0))
            addFrame(UDim2.new(1-t,0,0,0), UDim2.new(t,0,1,0))
            
        elseif style == "Corner Box" then
            obj.Box.Size = UDim2.new(0, width, 0, height)
            obj.Box.Position = UDim2.new(0, topLeft.X, 0, topLeft.Y)
            local lineLen = math.clamp(width * 0.25, 4, 15)
            local w = lineLen / width
            local h = lineLen / height
            local function addCorner(pos, size)
                local fr = Instance.new("Frame", obj.Box)
                fr.Size = UDim2.new(size.X.Scale, size.X.Offset, size.Y.Scale, size.Y.Offset)
                fr.Position = UDim2.new(pos.X.Scale, pos.X.Offset, pos.Y.Scale, pos.Y.Offset)
                fr.BackgroundColor3 = color
                fr.BorderSizePixel = 0
            end
            addCorner(UDim2.new(0,0,0,0), UDim2.new(w,0,h,0))
            addCorner(UDim2.new(0,0,0,0), UDim2.new(w,0,h,0))
            addCorner(UDim2.new(1-w,0,0,0), UDim2.new(w,0,h,0))
            addCorner(UDim2.new(1-w,0,0,0), UDim2.new(w,0,h,0))
            addCorner(UDim2.new(0,0,1-h,0), UDim2.new(w,0,h,0))
            addCorner(UDim2.new(0,0,1-h,0), UDim2.new(w,0,h,0))
            addCorner(UDim2.new(1-w,0,1-h,0), UDim2.new(w,0,h,0))
            addCorner(UDim2.new(1-w,0,1-h,0), UDim2.new(w,0,h,0))
        end
    end

    -- Drawing API Features (Only render if executor supports it)
    if hasDrawing then
        -- Tracers
        if getgenv().LunarState.Tracers then
            obj.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            obj.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
            obj.Tracer.Color = getgenv().LunarState.Config.Visuals.TracerColor
            obj.Tracer.Thickness = getgenv().LunarState.Config.Visuals.TracerThickness
            obj.Tracer.Visible = true
        else
            obj.Tracer.Visible = false
        end

        -- Names & Distance
        if getgenv().LunarState.ESP then
            local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local dist = myHRP and math.floor((myHRP.Position - root.Position).Magnitude) or 0
            obj.Name.Text = player.Name .. " [" .. dist .. "m]"
            obj.Name.Position = Vector2.new(rootPos.X, topLeft.Y - 16)
            obj.Name.Color = Color3.fromRGB(255, 255, 255)
            obj.Name.Visible = true
        else
            obj.Name.Visible = false
        end

        -- Health Bars
        if getgenv().LunarState.ESP then
            local hpPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
            obj.HealthBarBg.Size = Vector2.new(3, height)
            obj.HealthBarBg.Position = Vector2.new(topLeft.X - 6, topLeft.Y)
            obj.HealthBarBg.Visible = true

            obj.HealthBar.Size = Vector2.new(3, height * hpPercent)
            obj.HealthBar.Position = Vector2.new(topLeft.X - 6, topLeft.Y + (height * (1 - hpPercent)))
            obj.HealthBar.Visible = true
        else
            obj.HealthBarBg.Visible = false
            obj.HealthBar.Visible = false
        end

        -- Skeleton ESP
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
            for _, line in ipairs(obj.Skeletons) do line.Visible = false end
        end
    end
end

print("[Lunar] Creating UI Tabs...")
local CombatTab = Window:AddTab("Combat")
local VisualsTab = Window:AddTab("Visuals")
local MiscTab = Window:AddTab("Misc")
local SettingsTab = Window:AddTab("Settings")

print("[Lunar] Building Combat Section...")
local CombatGroup = CombatTab:AddLeftGroupbox("Aimbot")
local aimbotToggle = CombatGroup:AddToggle("AimbotEnabled", {
    Text = "Enable Aimbot",
    Callback = function(s) 
        getgenv().LunarState.Aimbot = s 
        if fovCircle then fovCircle.Visible = s end
    end
})
aimbotToggle:AddKeyPicker("AimbotKey", {
    Default = "None",
    SyncToggleState = false,
    Mode = "Hold",
    Text = "Aimbot Key",
    NoUI = true,
    ChangedCallback = function(new) getgenv().LunarState.Config.Keys.Aimbot = new end
})
CombatGroup:AddSlider("AimFOV", {
    Text = "FOV Radius",
    Min = 10, Max = 500, Default = 150,
    Rounding = 0,
    Callback = function(v) 
        getgenv().LunarState.Config.AimFOV = v 
        if fovCircle then fovCircle.Radius = v end
    end
})
CombatGroup:AddSlider("AimSmooth", {
    Text = "Smoothness (0-1)",
    Min = 0, Max = 1, Default = 0.2,
    Rounding = 2,
    Callback = function(v) getgenv().LunarState.Config.AimSmoothness = v end
})
CombatGroup:AddDropdown("HitPart", {
    Text = "Target Part",
    Values = {"Head", "HumanoidRootPart", "UpperTorso", "Torso", "LeftArm", "RightArm"},
    Multi = false,
    Default = "Head",
    Callback = function(v) getgenv().LunarState.Config.HitPart = v end
})

local TriggerGroup = CombatTab:AddRightGroupbox("Triggerbot")
local triggerToggle = TriggerGroup:AddToggle("TriggerEnabled", {
    Text = "Enable Triggerbot",
    Callback = function(s) getgenv().LunarState.Trigger = s end
})
triggerToggle:AddKeyPicker("TriggerKey", {
    Default = "None",
    SyncToggleState = false,
    Mode = "Hold",
    Text = "Trigger Key",
    NoUI = true,
    ChangedCallback = function(new) getgenv().LunarState.Config.Keys.Trigger = new end
})
TriggerGroup:AddSlider("TriggerDelay", {
    Text = "Shot Delay (s)",
    Min = 0, Max = 0.5, Default = 0.025,
    Rounding = 3,
    Callback = function(v) getgenv().LunarState.Config.TriggerDelay = v end
})

print("[Lunar] Building Visuals Section...")
local VisualsGroup = VisualsTab:AddLeftGroupbox("ESP Options")
VisualsGroup:AddToggle("ESPEnabled", {
    Text = "Enable ESP",
    Callback = function(s) getgenv().LunarState.ESP = s end
})
VisualsGroup:AddDropdown("EspStyle", {
    Text = "Box ESP Style",
    Values = {"Full Box", "Corner Box"},
    Multi = false,
    Default = "Full Box",
    Callback = function(v) getgenv().LunarState.Config.Visuals.EspStyle = v end
})
VisualsGroup:AddToggle("TracerEnabled", {
    Text = "Tracers (Snaplines)",
    Callback = function(s) getgenv().LunarState.Tracers = s end
})
VisualsGroup:AddToggle("ChamsEnabled", {
    Text = "Chams (Highlight)",
    Callback = function(s) getgenv().LunarState.Chams = s end
})
VisualsGroup:AddToggle("SkeletonEnabled", {
    Text = "Skeleton ESP",
    Callback = function(s) getgenv().LunarState.Skeleton = s end
})

local TracerGroup = VisualsTab:AddRightGroupbox("Colors & Thickness")
TracerGroup:AddSlider("TracerThickness", {
    Text = "Tracer Thickness",
    Min = 1, Max = 5, Default = 2,
    Rounding = 0,
    Callback = function(v) getgenv().LunarState.Config.Visuals.TracerThickness = v end
})

print("[Lunar] Building Misc Section...")
local MiscGroup = MiscTab:AddLeftGroupbox("Movement")
MiscGroup:AddToggle("FlyEnabled", {
    Text = "Fly Mode",
    Callback = function(s) getgenv().LunarState.Fly = s end
})
MiscGroup:AddSlider("FlySpeed", {
    Text = "Fly Speed",
    Min = 10, Max = 300, Default = 50,
    Rounding = 0,
    Callback = function(v) getgenv().LunarState.Config.FlySpeed = v end
})
MiscGroup:AddSlider("WalkSpeed", {
    Text = "Walk Speed",
    Min = 16, Max = 300, Default = 16,
    Rounding = 0,
    Callback = function(v) getgenv().LunarState.Config.WalkSpeed = v end
})
MiscGroup:AddSlider("JumpPower", {
    Text = "Jump Power",
    Min = 50, Max = 350, Default = 50,
    Rounding = 0,
    Callback = function(v) getgenv().LunarState.Config.JumpPowerVal = v end
})
MiscGroup:AddSlider("Gravity", {
    Text = "Gravity",
    Min = 0, Max = 196, Default = 196,
    Rounding = 0,
    Callback = function(v) getgenv().LunarState.Config.Gravity = v end
})
MiscGroup:AddToggle("InfJumpEnabled", {
    Text = "Infinite Jump",
    Callback = function(s) getgenv().LunarState.InfJump = s end
})
MiscGroup:AddToggle("NoclipEnabled", {
    Text = "Noclip",
    Callback = function(s) getgenv().LunarState.Noclip = s end
})

print("[Lunar] Building Settings Section...")
local ConfigGroup = SettingsTab:AddLeftGroupbox("Configuration")
ConfigGroup:AddButton("Save Config", function()
    pcall(function()
        writefile("LunarUniversal_Config.json", HttpService:JSONEncode(getgenv().LunarState.Config))
        Library:Notify("Config Saved!")
    end)
end)
ConfigGroup:AddButton("Load Config", function()
    pcall(function()
        local data = readfile("LunarUniversal_Config.json")
        local decoded = HttpService:JSONDecode(data)
        for k,v in pairs(decoded) do getgenv().LunarState.Config[k] = v end
        if fovCircle then
            fovCircle.Radius = getgenv().LunarState.Config.AimFOV
            fovCircle.Thickness = getgenv().LunarState.Config.Visuals.FovThickness
        end
        Library:Notify("Config Loaded!")
    end)
end)
ConfigGroup:AddButton("Unload Script", function()
    getgenv().LunarRunning = false
    for _, l in pairs(getgenv().LunarState.Lines) do l:Remove() end
    if fovCircle then fovCircle:Remove() end
    if MyUI then MyUI:Destroy() end
    Library:Unload()
end)

print("[Lunar] Starting Runtime Loops...")
local frameSkip = 0
local flyBodyVel, flyBodyGyro, flyConn
local noclipConn, infJumpConn

RunService.RenderStepped:Connect(function()
    if not getgenv().LunarRunning then return end
    frameSkip = frameSkip + 1

    if hasDrawing and fovCircle then
        local mLoc = UserInputService:GetMouseLocation()
        fovCircle.Position = Vector2.new(mLoc.X, mLoc.Y)
        fovCircle.Radius = getgenv().LunarState.Config.AimFOV
    end

    local Character = LocalPlayer.Character
    if Character then
        local hum = Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = getgenv().LunarState.Speed and getgenv().LunarState.Config.WalkSpeed or 16
            if getgenv().LunarState.JumpPower then
                hum.UseJumpPower = true
                hum.JumpPower = getgenv().LunarState.Config.JumpPowerVal
            end
        end
        
        workspace.Gravity = getgenv().LunarState.Config.Gravity
        
        if getgenv().LunarState.Fly then
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

                flyConn = RunService.RenderStepped:Connect(function()
                    if not getgenv().LunarState.Fly or not hrp then return end
                    local move = Vector3.zero
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + Camera.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - Camera.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - Camera.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + Camera.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, 1, 0) end
                    flyBodyVel.Velocity = move * getgenv().LunarState.Config.FlySpeed
                    flyBodyGyro.CFrame = Camera.CFrame
                end)
            elseif not getgenv().LunarState.Fly and flyConn then
                flyConn:Disconnect()
                if flyBodyVel then flyBodyVel:Destroy() end
                if flyBodyGyro then flyBodyGyro:Destroy() end
                flyConn = nil
            end
        end
        
        if getgenv().LunarState.Noclip then
            if not noclipConn then
                noclipConn = RunService.Stepped:Connect(function()
                    if Character then
                        for _, p in ipairs(Character:GetChildren()) do
                            if p:IsA("BasePart") then p.CanCollide = false end
                        end
                    end
                end)
            end
        elseif noclipConn then
            noclipConn:Disconnect()
            noclipConn = nil
        end
        
        if getgenv().LunarState.InfJump then
            if not infJumpConn then
                infJumpConn = UserInputService.JumpRequest:Connect(function()
                    local h = Character:FindFirstChildOfClass("Humanoid")
                    if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
                end)
            end
        elseif infJumpConn then
            infJumpConn:Disconnect()
            infJumpConn = nil
        end
        
        if getgenv().LunarState.Chams then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    local h = plr.Character:FindFirstChild("LunarChams")
                    if not h then
                        h = Instance.new("Highlight")
                        h.Name = "LunarChams"
                        h.FillColor = getgenv().LunarState.Config.Visuals.ChamsColor
                        h.OutlineColor = Color3.fromRGB(200, 200, 200)
                        h.FillTransparency = 0.5
                        h.Parent = plr.Character
                    end
                end
            end
        else
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr.Character then
                    local h = plr.Character:FindFirstChild("LunarChams")
                    if h then h:Destroy() end
                end
            end
        end
    end

    if isFeatureActive("Aimbot") then
        local target = GetClosestTarget()
        if target and target.Character then
            local partName = getgenv().LunarState.Config.HitPart
            local part = target.Character:FindFirstChild(partName) or target.Character:FindFirstChild("HumanoidRootPart") or target.Character:FindFirstChild("Head")
            if part then
                local targetPos = part.Position
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
    for i = lIdx, #getgenv().LunarState.Lines do getgenv().LunarState.Lines[i].Visible = false end
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

print("[Lunar] Universal Script initialized successfully!")