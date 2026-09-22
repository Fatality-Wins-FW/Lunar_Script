print("[Lunar] Initializing Universal Script V2...")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- STATE MANAGEMENT
getgenv().LunarState = {
    Aimbot = false, SilentAim = false, Trigger = false, KillAura = false, Reach = false,
    ESP = false, BoxESP = false, Tracers = false, Names = false, Distance = false, 
    HealthBars = false, Skeleton = false, Chams = false, Glow = false, OffscreenArrows = false,
    Fly = false, Speed = false, InfJump = false, Noclip = false, NoFallDamage = false,
    AntiFling = false, AutoFarm = false, SpinBot = false,
    Config = {
        AimFOV = 150, AimSmooth = 0.2, HitPart = "Head", TriggerDelay = 0.025, ReachDist = 5,
        WalkSpeed = 16, JumpPower = 50, Gravity = 196, FlySpeed = 50,
        Visuals = {
            BoxColor = Color3.fromRGB(255, 60, 60), TracerColor = Color3.fromRGB(255, 255, 255),
            NameColor = Color3.fromRGB(255, 255, 255), HealthColor = Color3.fromRGB(40, 220, 90),
            EspStyle = "Full Box", MaxDistance = 1000,
            BoxThickness = 1, TracerThickness = 2, FontSize = 13
        }
    },
    Lines = {}, ESPObjects = {}
}

-- LIBRARY INITIALIZATION
local repo = "https://raw.githubusercontent.com/yukvx/ObsidianUi/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

-- FIX: Set Library for managers BEFORE creating window/sections
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
SaveManager:SetFolder("Lunar_Script/universalv2")

local Window = Library:CreateWindow({
    Title = "Lunar",
    Footer = "Universal V2",
    NotifySide = "Right",
    ShowCustomCursor = true,
})

local Tabs = {
    Combat = Window:AddTab("Combat", "crosshair"),
    Visuals = Window:AddTab("Visuals", "eye"),
    Misc = Window:AddTab("Misc", "settings-2"),
    Settings = Window:AddTab("Settings", "settings"),
}

-- HELPER FUNCTIONS
local function isEnemy(p)
    if not p or p == LocalPlayer or not p.Character then return false end
    local char = p.Character
    local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return false end
    if char:FindFirstChildOfClass("ForceField") then return false end
    return true
end

local function GetClosestTarget(maxDist)
    local target, dist = nil, maxDist or getgenv().LunarState.Config.AimFOV
    local mLoc = UserInputService:GetMouseLocation()
    -- FIX: Subtract GUI inset for accurate mouse position relative to viewport
    local guiInset = game:GetService("GuiService"):GetGuiInset()
    mLoc = Vector2.new(mLoc.X - guiInset.X, mLoc.Y - guiInset.Y)
    
    for _, p in pairs(Players:GetPlayers()) do
        if isEnemy(p) and p.Character then
            local partName = getgenv().LunarState.Config.HitPart
            local part = p.Character:FindFirstChild(partName) or p.Character:FindFirstChild("HumanoidRootPart")
            if part then
                local pos, on = Camera:WorldToViewportPoint(part.Position)
                if on then
                    local mag = (Vector2.new(pos.X, pos.Y) - mLoc).Magnitude
                    if mag < dist then target = p; dist = mag end
                end
            end
        end
    end
    return target
end

-- FOV CIRCLE SETUP
local hasDrawing = pcall(function() Drawing.new("Circle") end)
local fovCircle = nil
if hasDrawing then
    fovCircle = Drawing.new("Circle")
    fovCircle.Thickness = 1
    fovCircle.Color = Color3.fromRGB(255, 255, 255)
    fovCircle.Filled = false
    fovCircle.Visible = false
    fovCircle.Radius = getgenv().LunarState.Config.AimFOV
end

-- ESP SYSTEM V2
local SkeletonBones = {
    R15 = {{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},{"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},{"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"}},
    R6 = {{"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},{"Torso","Left Leg"},{"Torso","Right Leg"}}
}

local function CreateESPObject(plr)
    if getgenv().LunarState.ESPObjects[plr] then return end
    local obj = {}
    if hasDrawing then
        obj.BoxLines = {}
        for i=1,8 do local l=Drawing.new("Line"); l.Thickness=getgenv().LunarState.Config.Visuals.BoxThickness; table.insert(obj.BoxLines,l) end
        obj.Tracer = Drawing.new("Line"); obj.Tracer.Thickness = getgenv().LunarState.Config.Visuals.TracerThickness
        obj.Name = Drawing.new("Text"); obj.Name.Size = getgenv().LunarState.Config.Visuals.FontSize; obj.Name.Center = true; obj.Name.Outline = true
        obj.HealthBg = Drawing.new("Square"); obj.HealthBg.Filled = true; obj.HealthBg.Color = Color3.fromRGB(10,10,10)
        obj.HealthBar = Drawing.new("Square"); obj.HealthBar.Filled = true; obj.HealthBar.Color = getgenv().LunarState.Config.Visuals.HealthColor
        obj.Skeletons = {}
        for i=1,15 do local l=Drawing.new("Line"); l.Thickness=1.5; table.insert(obj.Skeletons,l) end
        obj.Arrow = Drawing.new("Triangle"); obj.Arrow.Filled = true; obj.Arrow.Color = getgenv().LunarState.Config.Visuals.BoxColor
    end
    getgenv().LunarState.ESPObjects[plr] = obj
end

local function HideESPObject(plr)
    local obj = getgenv().LunarState.ESPObjects[plr]; if not obj or not hasDrawing then return end
    for _,l in ipairs(obj.BoxLines) do l.Visible=false end
    obj.Tracer.Visible=false; obj.Name.Visible=false; obj.HealthBg.Visible=false; obj.HealthBar.Visible=false
    for _,l in ipairs(obj.Skeletons) do l.Visible=false end
    obj.Arrow.Visible = false
end

local function RemoveESPObject(plr)
    local obj = getgenv().LunarState.ESPObjects[plr]; if not obj or not hasDrawing then return end
    for _,l in ipairs(obj.BoxLines) do pcall(function() l:Remove() end) end
    pcall(function() obj.Tracer:Remove() end); pcall(function() obj.Name:Remove() end)
    pcall(function() obj.HealthBg:Remove() end); pcall(function() obj.HealthBar:Remove() end)
    for _,l in ipairs(obj.Skeletons) do pcall(function() l:Remove() end) end
    pcall(function() obj.Arrow:Remove() end)
    getgenv().LunarState.ESPObjects[plr] = nil
end

Players.PlayerRemoving:Connect(RemoveESPObject)

local function UpdateESP(player)
    if not player.Character then return end
    CreateESPObject(player)
    local obj = getgenv().LunarState.ESPObjects[player]
    local char = player.Character
    local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
    local head = char:FindFirstChild("Head")
    local hum = char:FindFirstChildOfClass("Humanoid")
    
    if not (char and root and head and hum and hum.Health > 0) then 
        HideESPObject(player); return 
    end
    
    local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
    if not (onScreen and rootPos.Z > 0) then 
        HideESPObject(player); return 
    end
    
    local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,0.7,0))
    local legPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0,3,0))
    local height = math.abs(headPos.Y - legPos.Y)
    local width = height * 0.6
    local topLeftX = rootPos.X - width/2
    local topLeftY = headPos.Y
    local color = getgenv().LunarState.Config.Visuals.BoxColor
    local style = getgenv().LunarState.Config.Visuals.EspStyle

    if hasDrawing and getgenv().LunarState.ESP then
        if getgenv().LunarState.BoxESP then
            if style == "Full Box" then
                obj.BoxLines[1].From = Vector2.new(topLeftX, topLeftY)
                obj.BoxLines[1].To = Vector2.new(topLeftX + width, topLeftY)
                obj.BoxLines[1].Color = color; obj.BoxLines[1].Visible = true
                
                obj.BoxLines[2].From = Vector2.new(topLeftX, topLeftY + height)
                obj.BoxLines[2].To = Vector2.new(topLeftX + width, topLeftY + height)
                obj.BoxLines[2].Color = color; obj.BoxLines[2].Visible = true
                
                obj.BoxLines[3].From = Vector2.new(topLeftX, topLeftY)
                obj.BoxLines[3].To = Vector2.new(topLeftX, topLeftY + height)
                obj.BoxLines[3].Color = color; obj.BoxLines[3].Visible = true
                
                obj.BoxLines[4].From = Vector2.new(topLeftX + width, topLeftY)
                obj.BoxLines[4].To = Vector2.new(topLeftX + width, topLeftY + height)
                obj.BoxLines[4].Color = color; obj.BoxLines[4].Visible = true
                
                for i=5,8 do obj.BoxLines[i].Visible = false end
                
            elseif style == "Corner Box" then
                local lineLen = math.clamp(width * 0.25, 4, 15)
                local topRight = Vector2.new(topLeftX + width, topLeftY)
                local bottomLeft = Vector2.new(topLeftX, topLeftY + height)
                local bottomRight = Vector2.new(topLeftX + width, topLeftY + height)

                obj.BoxLines[1].From = Vector2.new(topLeftX, topLeftY)
                obj.BoxLines[1].To = Vector2.new(topLeftX + lineLen, topLeftY)
                obj.BoxLines[1].Color = color; obj.BoxLines[1].Visible = true
                
                obj.BoxLines[2].From = Vector2.new(topLeftX, topLeftY)
                obj.BoxLines[2].To = Vector2.new(topLeftX, topLeftY + lineLen)
                obj.BoxLines[2].Color = color; obj.BoxLines[2].Visible = true

                obj.BoxLines[3].From = topRight
                obj.BoxLines[3].To = Vector2.new(topRight.X - lineLen, topRight.Y)
                obj.BoxLines[3].Color = color; obj.BoxLines[3].Visible = true
                
                obj.BoxLines[4].From = topRight
                obj.BoxLines[4].To = Vector2.new(topRight.X, topRight.Y + lineLen)
                obj.BoxLines[4].Color = color; obj.BoxLines[4].Visible = true

                obj.BoxLines[5].From = bottomLeft
                obj.BoxLines[5].To = Vector2.new(bottomLeft.X + lineLen, bottomLeft.Y)
                obj.BoxLines[5].Color = color; obj.BoxLines[5].Visible = true
                
                obj.BoxLines[6].From = bottomLeft
                obj.BoxLines[6].To = Vector2.new(bottomLeft.X, bottomLeft.Y - lineLen)
                obj.BoxLines[6].Color = color; obj.BoxLines[6].Visible = true

                obj.BoxLines[7].From = bottomRight
                obj.BoxLines[7].To = Vector2.new(bottomRight.X - lineLen, bottomRight.Y)
                obj.BoxLines[7].Color = color; obj.BoxLines[7].Visible = true
                
                obj.BoxLines[8].From = bottomRight
                obj.BoxLines[8].To = Vector2.new(bottomRight.X, bottomRight.Y - lineLen)
                obj.BoxLines[8].Color = color; obj.BoxLines[8].Visible = true
            end
        else
            for i=1,8 do obj.BoxLines[i].Visible = false end
        end

        if getgenv().LunarState.Tracers then
            obj.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            obj.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
            obj.Tracer.Color = getgenv().LunarState.Config.Visuals.TracerColor
            obj.Tracer.Visible = true
        else obj.Tracer.Visible = false end
        
        if getgenv().LunarState.Names or getgenv().LunarState.Distance then
            local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local dist = myHRP and math.floor((myHRP.Position - root.Position).Magnitude) or 0
            local text = ""
            if getgenv().LunarState.Names then text = player.Name end
            if getgenv().LunarState.Distance then text = text .. (text~="" and " [" or "[") .. dist .. "m]" end
            obj.Name.Text = text; obj.Name.Position = Vector2.new(rootPos.X, topLeftY - 16)
            obj.Name.Color = getgenv().LunarState.Config.Visuals.NameColor; obj.Name.Visible = true
        else obj.Name.Visible = false end
        
        if getgenv().LunarState.HealthBars then
            local hpPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
            obj.HealthBg.Size = Vector2.new(4, height); obj.HealthBg.Position = Vector2.new(topLeftX-7, topLeftY); obj.HealthBg.Visible = true
            obj.HealthBar.Size = Vector2.new(4, height*hpPercent); obj.HealthBar.Position = Vector2.new(topLeftX-7, topLeftY+(height*(1-hpPercent))); obj.HealthBar.Visible = true
        else obj.HealthBg.Visible = false; obj.HealthBar.Visible = false end
        
        if getgenv().LunarState.Skeleton then
            local rigType = (hum.RigType == Enum.HumanoidRigType.R15) and "R15" or "R6"
            local pairsList = SkeletonBones[rigType]
            for i, line in ipairs(obj.Skeletons) do
                if pairsList[i] then
                    local partA = char:FindFirstChild(pairsList[i][1]); local partB = char:FindFirstChild(pairsList[i][2])
                    if partA and partB then
                        local posA, visA = Camera:WorldToViewportPoint(partA.Position); local posB, visB = Camera:WorldToViewportPoint(partB.Position)
                        if visA and visB and posA.Z>0 and posB.Z>0 then 
                            line.From=Vector2.new(posA.X,posA.Y); line.To=Vector2.new(posB.X,posB.Y); 
                            line.Color=color; line.Visible=true
                        else line.Visible = false end
                    else line.Visible = false end
                else line.Visible = false end
            end
        else for _,l in ipairs(obj.Skeletons) do l.Visible=false end end

        if getgenv().LunarState.OffscreenArrows and not onScreen then
            local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
            local angle = math.atan2(rootPos.Y - center.Y, rootPos.X - center.X)
            local radius = math.min(Camera.ViewportSize.X, Camera.ViewportSize.Y) / 2 - 30
            local arrowPos = center + Vector2.new(math.cos(angle), math.sin(angle)) * radius
            
            obj.Arrow.PointA = arrowPos
            obj.Arrow.PointB = arrowPos + Vector2.new(math.cos(angle + 2.5), math.sin(angle + 2.5)) * 15
            obj.Arrow.PointC = arrowPos + Vector2.new(math.cos(angle - 2.5), math.sin(angle - 2.5)) * 15
            obj.Arrow.Visible = true
        else obj.Arrow.Visible = false end

    elseif hasDrawing then
        HideESPObject(player)
    end
end

local function UpdateChams()
    if getgenv().LunarState.Chams or getgenv().LunarState.Glow then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                if getgenv().LunarState.Chams and not plr.Character:FindFirstChild("LunarChams") then
                    local h = Instance.new("Highlight")
                    h.Name = "LunarChams"
                    h.FillColor = getgenv().LunarState.Config.Visuals.BoxColor
                    h.FillTransparency = 0.5
                    h.OutlineColor = Color3.fromRGB(0,0,0)
                    h.Parent = plr.Character
                end
                if getgenv().LunarState.Glow and not plr.Character:FindFirstChild("LunarGlow") then
                    local g = Instance.new("Highlight")
                    g.Name = "LunarGlow"
                    g.FillColor = getgenv().LunarState.Config.Visuals.BoxColor
                    g.FillTransparency = 0.8
                    g.OutlineTransparency = 1
                    g.Parent = plr.Character
                end
            end
        end
    else
        for _, plr in ipairs(Players:GetPlayers()) do 
            if plr.Character then 
                local c = plr.Character:FindFirstChild("LunarChams"); if c then c:Destroy() end
                local g = plr.Character:FindFirstChild("LunarGlow"); if g then g:Destroy() end
            end 
        end
    end
end

-- COMBAT TAB
do
    local LeftGroup = Tabs.Combat:AddLeftGroupbox("Aimbot & Trigger")
    
    LeftGroup:AddToggle("AimbotEnabled", { Text = "Enable Aimbot", Default = false })
    Toggles.AimbotEnabled:OnChanged(function(Value)
        getgenv().LunarState.Aimbot = Value
        if fovCircle then fovCircle.Visible = Value end
    end)
    
    LeftGroup:AddKeyPicker("AimbotKey", { Default = "None", SyncToggleState = false, Mode = "Hold", Text = "Aimbot Key", NoUI = true })

    LeftGroup:AddSlider("AimFOV", { Text = "FOV Radius", Min = 10, Max = 500, Default = 150, Rounding = 0 })
    Options.AimFOV:OnChanged(function(Value)
        getgenv().LunarState.Config.AimFOV = Value
        if fovCircle then fovCircle.Radius = Value end
    end)

    LeftGroup:AddSlider("AimSmooth", { Text = "Smoothness", Min = 0, Max = 1, Default = 0.2, Rounding = 2 })
    Options.AimSmooth:OnChanged(function(Value) getgenv().LunarState.Config.AimSmooth = Value end)

    LeftGroup:AddDropdown("HitPart", { Text = "Target Part", Values = {"Head","HumanoidRootPart","UpperTorso","Torso"}, Multi = false, Default = "Head" })
    Options.HitPart:OnChanged(function(Value) getgenv().LunarState.Config.HitPart = Value end)

    LeftGroup:AddDivider()

    LeftGroup:AddToggle("TriggerEnabled", { Text = "Enable Triggerbot", Default = false })
    Toggles.TriggerEnabled:OnChanged(function(Value) getgenv().LunarState.Trigger = Value end)
    
    LeftGroup:AddKeyPicker("TriggerKey", { Default = "None", SyncToggleState = false, Mode = "Hold", Text = "Trigger Key", NoUI = true })

    LeftGroup:AddSlider("TriggerDelay", { Text = "Shot Delay", Min = 0, Max = 0.5, Default = 0.025, Rounding = 3 })
    Options.TriggerDelay:OnChanged(function(Value) getgenv().LunarState.Config.TriggerDelay = Value end)

    LeftGroup:AddToggle("SilentAim", { Text = "Silent Aim", Default = false })
    Toggles.SilentAim:OnChanged(function(Value) getgenv().LunarState.SilentAim = Value end)

    LeftGroup:AddToggle("KillAura", { Text = "Kill Aura", Default = false })
    Toggles.KillAura:OnChanged(function(Value) getgenv().LunarState.KillAura = Value end)

    LeftGroup:AddSlider("ReachDist", { Text = "Reach Distance", Min = 1, Max = 20, Default = 5, Rounding = 0 })
    Options.ReachDist:OnChanged(function(Value) getgenv().LunarState.Config.ReachDist = Value end)
end

-- VISUALS TAB
do
    local LeftGroup = Tabs.Visuals:AddLeftGroupbox("ESP Features")
    
    LeftGroup:AddToggle("ESPEnabled", { Text = "Master ESP Toggle", Default = false })
    Toggles.ESPEnabled:OnChanged(function(Value) getgenv().LunarState.ESP = Value end)

    LeftGroup:AddToggle("BoxESP", { Text = "Box ESP", Default = true })
    Toggles.BoxESP:OnChanged(function(Value) getgenv().LunarState.BoxESP = Value end)

    LeftGroup:AddDropdown("EspStyle", { Text = "Box Style", Values = {"Full Box","Corner Box"}, Multi = false, Default = "Full Box" })
    Options.EspStyle:OnChanged(function(Value) getgenv().LunarState.Config.Visuals.EspStyle = Value end)

    LeftGroup:AddToggle("Tracers", { Text = "Tracers", Default = false })
    Toggles.Tracers:OnChanged(function(Value) getgenv().LunarState.Tracers = Value end)

    LeftGroup:AddToggle("Names", { Text = "Player Names", Default = true })
    Toggles.Names:OnChanged(function(Value) getgenv().LunarState.Names = Value end)

    LeftGroup:AddToggle("Distance", { Text = "Distance", Default = false })
    Toggles.Distance:OnChanged(function(Value) getgenv().LunarState.Distance = Value end)

    LeftGroup:AddToggle("HealthBars", { Text = "Health Bars", Default = true })
    Toggles.HealthBars:OnChanged(function(Value) getgenv().LunarState.HealthBars = Value end)

    LeftGroup:AddToggle("Skeleton", { Text = "Skeleton ESP", Default = false })
    Toggles.Skeleton:OnChanged(function(Value) getgenv().LunarState.Skeleton = Value end)

    LeftGroup:AddToggle("OffscreenArrows", { Text = "Offscreen Arrows", Default = false })
    Toggles.OffscreenArrows:OnChanged(function(Value) getgenv().LunarState.OffscreenArrows = Value end)

    LeftGroup:AddDivider()

    LeftGroup:AddToggle("Chams", { Text = "Chams", Default = false })
    Toggles.Chams:OnChanged(function(Value) getgenv().LunarState.Chams = Value end)

    LeftGroup:AddToggle("Glow", { Text = "Glow Effect", Default = false })
    Toggles.Glow:OnChanged(function(Value) getgenv().LunarState.Glow = Value end)

    local RightGroup = Tabs.Visuals:AddRightGroupbox("Colors & Thickness")
    
    RightGroup:AddLabel("Box Color"):AddColorPicker("BoxColor", { Default = Color3.fromRGB(255, 60, 60), Transparency = 0 })
    Options.BoxColor:OnChanged(function(Value) getgenv().LunarState.Config.Visuals.BoxColor = Value end)

    RightGroup:AddLabel("Tracer Color"):AddColorPicker("TracerColor", { Default = Color3.fromRGB(255, 255, 255), Transparency = 0 })
    Options.TracerColor:OnChanged(function(Value) getgenv().LunarState.Config.Visuals.TracerColor = Value end)

    RightGroup:AddLabel("Name Color"):AddColorPicker("NameColor", { Default = Color3.fromRGB(255, 255, 255), Transparency = 0 })
    Options.NameColor:OnChanged(function(Value) getgenv().LunarState.Config.Visuals.NameColor = Value end)

    RightGroup:AddLabel("Health Color"):AddColorPicker("HealthColor", { Default = Color3.fromRGB(40, 220, 90), Transparency = 0 })
    Options.HealthColor:OnChanged(function(Value) getgenv().LunarState.Config.Visuals.HealthColor = Value end)

    RightGroup:AddDivider()

    RightGroup:AddSlider("BoxThickness", { Text = "Box Thickness", Min = 1, Max = 5, Default = 1, Rounding = 0 })
    Options.BoxThickness:OnChanged(function(Value) 
        getgenv().LunarState.Config.Visuals.BoxThickness = Value
        for _, obj in pairs(getgenv().LunarState.ESPObjects) do
            for _, l in ipairs(obj.BoxLines) do l.Thickness = Value end
        end
    end)

    RightGroup:AddSlider("TracerThickness", { Text = "Tracer Thickness", Min = 1, Max = 5, Default = 2, Rounding = 0 })
    Options.TracerThickness:OnChanged(function(Value) 
        getgenv().LunarState.Config.Visuals.TracerThickness = Value
        for _, obj in pairs(getgenv().LunarState.ESPObjects) do
            obj.Tracer.Thickness = Value
        end
    end)

    RightGroup:AddSlider("FontSize", { Text = "Font Size", Min = 10, Max = 24, Default = 13, Rounding = 0 })
    Options.FontSize:OnChanged(function(Value) 
        getgenv().LunarState.Config.Visuals.FontSize = Value
        for _, obj in pairs(getgenv().LunarState.ESPObjects) do
            obj.Name.Size = Value
        end
    end)

    RightGroup:AddSlider("MaxDistance", { Text = "Max Render Dist", Min = 100, Max = 5000, Default = 1000, Rounding = 0 })
    Options.MaxDistance:OnChanged(function(Value) getgenv().LunarState.Config.Visuals.MaxDistance = Value end)
end

-- MISC TAB
do
    local LeftGroup = Tabs.Misc:AddLeftGroupbox("Movement & Physics")
    
    LeftGroup:AddToggle("FlyEnabled", { Text = "Fly Mode", Default = false })
    Toggles.FlyEnabled:OnChanged(function(Value) getgenv().LunarState.Fly = Value end)
    
    LeftGroup:AddKeyPicker("FlyKey", { Default = "None", SyncToggleState = false, Mode = "Hold", Text = "Fly Key", NoUI = true })

    LeftGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Min = 10, Max = 300, Default = 50, Rounding = 0 })
    Options.FlySpeed:OnChanged(function(Value) getgenv().LunarState.Config.FlySpeed = Value end)

    LeftGroup:AddToggle("SpeedEnabled", { Text = "Walk Speed", Default = false })
    Toggles.SpeedEnabled:OnChanged(function(Value) getgenv().LunarState.Speed = Value end)
    
    LeftGroup:AddKeyPicker("SpeedKey", { Default = "None", SyncToggleState = false, Mode = "Hold", Text = "Speed Key", NoUI = true })

    LeftGroup:AddSlider("WalkSpeed", { Text = "Speed Value", Min = 16, Max = 300, Default = 16, Rounding = 0 })
    Options.WalkSpeed:OnChanged(function(Value) getgenv().LunarState.Config.WalkSpeed = Value end)

    LeftGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
    Toggles.InfJump:OnChanged(function(Value) getgenv().LunarState.InfJump = Value end)

    LeftGroup:AddToggle("NoclipEnabled", { Text = "Noclip", Default = false })
    Toggles.NoclipEnabled:OnChanged(function(Value) getgenv().LunarState.Noclip = Value end)
    
    LeftGroup:AddKeyPicker("NoclipKey", { Default = "None", SyncToggleState = false, Mode = "Hold", Text = "Noclip Key", NoUI = true })

    LeftGroup:AddSlider("Gravity", { Text = "Gravity", Min = 0, Max = 196, Default = 196, Rounding = 0 })
    Options.Gravity:OnChanged(function(Value) getgenv().LunarState.Config.Gravity = Value end)

    LeftGroup:AddToggle("NoFallDamage", { Text = "No Fall Damage", Default = false })
    Toggles.NoFallDamage:OnChanged(function(Value) getgenv().LunarState.NoFallDamage = Value end)

    local RightGroup = Tabs.Misc:AddRightGroupbox("Protection & Extra")
    
    RightGroup:AddToggle("AntiFling", { Text = "Anti-Fling Protection", Default = false })
    Toggles.AntiFling:OnChanged(function(Value) getgenv().LunarState.AntiFling = Value end)

    RightGroup:AddToggle("SpinBot", { Text = "Spin Bot", Default = false })
    Toggles.SpinBot:OnChanged(function(Value) getgenv().LunarState.SpinBot = Value end)

    RightGroup:AddToggle("AutoFarm", { Text = "Auto Farm", Default = false })
    Toggles.AutoFarm:OnChanged(function(Value) getgenv().LunarState.AutoFarm = Value end)
end

-- SETTINGS TAB
do
    local LeftGroup = Tabs.Settings:AddLeftGroupbox("Menu Settings")
    
    LeftGroup:AddLabel("Menu Keybind")
        :AddKeyPicker("MenuKeybind", { 
            Default = "RightShift", NoUI = true, Text = "Menu keybind" 
        })

    SaveManager:BuildConfigSection(Tabs.Settings)
    ThemeManager:ApplyToTab(Tabs.Settings)

    LeftGroup:AddDivider()

    LeftGroup:AddButton({
        Text = "Unload Script",
        Func = function()
            getgenv().LunarRunning = false
            for _,l in pairs(getgenv().LunarState.Lines) do pcall(function() l:Remove() end) end
            if fovCircle then pcall(function() fovCircle:Remove() end) end
            for _, obj in pairs(getgenv().LunarState.ESPObjects) do RemoveESPObject(obj) end
            Library:Unload() 
        end,
    })
end

-- FINAL SETUP
Library.ToggleKeybind = Options.MenuKeybind
SaveManager:LoadAutoloadConfig()

-- MAIN RUNTIME LOOP
local frameSkip = 0
local flyBodyVel, flyBodyGyro, flyConn
local noclipConn, infJumpConn, fallConn, spinConn, antiFlingConn
local originalCFrames = {}

RunService.RenderStepped:Connect(function()
    if not getgenv().LunarRunning then return end
    frameSkip = frameSkip + 1
    local Character = LocalPlayer.Character
    
    -- FIX: Subtract GUI inset for accurate FOV circle positioning
    if hasDrawing and fovCircle then
        local mLoc = UserInputService:GetMouseLocation()
        local guiInset = game:GetService("GuiService"):GetGuiInset()
        fovCircle.Position = Vector2.new(mLoc.X - guiInset.X, mLoc.Y - guiInset.Y)
        fovCircle.Radius = getgenv().LunarState.Config.AimFOV
    end

    if Character then
        local hum = Character:FindFirstChildOfClass("Humanoid")
        if hum then
            if getgenv().LunarState.Speed then
                hum.WalkSpeed = getgenv().LunarState.Config.WalkSpeed
            else
                hum.WalkSpeed = 16
            end
            
            Workspace.Gravity = getgenv().LunarState.Config.Gravity
            
            if getgenv().LunarState.Fly then
                local hrp = Character:FindFirstChild("HumanoidRootPart") or Character:FindFirstChild("Torso")
                if hrp and not flyConn then
                    flyBodyVel = Instance.new("BodyVelocity")
                    flyBodyVel.MaxForce = Vector3.new(1,1,1)*1e6
                    flyBodyVel.Velocity = Vector3.zero
                    flyBodyVel.Parent = hrp
                    
                    flyBodyGyro = Instance.new("BodyGyro")
                    flyBodyGyro.MaxTorque = Vector3.new(1,1,1)*1e6
                    flyBodyGyro.CFrame = hrp.CFrame
                    flyBodyGyro.Parent = hrp
                    
                    flyConn = RunService.RenderStepped:Connect(function()
                        if not getgenv().LunarState.Fly or not hrp then return end
                        local move = Vector3.zero
                        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + Camera.CFrame.LookVector end
                        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - Camera.CFrame.LookVector end
                        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - Camera.CFrame.RightVector end
                        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + Camera.CFrame.RightVector end
                        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
                        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0,1,0) end
                        flyBodyVel.Velocity = move * getgenv().LunarState.Config.FlySpeed
                        flyBodyGyro.CFrame = Camera.CFrame
                    end)
                elseif not getgenv().LunarState.Fly and flyConn then
                    flyConn:Disconnect()
                    if flyBodyVel then flyBodyVel:Destroy() end
                    if flyBodyGyro then flyBodyGyro:Destroy() end
                    flyConn = nil
                end
            else
                if flyConn then 
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
                            for _,p in ipairs(Character:GetChildren()) do 
                                if p:IsA("BasePart") then p.CanCollide = false end 
                            end 
                        end 
                    end) 
                end
            elseif noclipConn then 
                noclipConn:Disconnect(); noclipConn = nil 
            end
            
            if getgenv().LunarState.InfJump then
                if not infJumpConn then 
                    infJumpConn = UserInputService.JumpRequest:Connect(function() 
                        local h = Character:FindFirstChildOfClass("Humanoid")
                        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end 
                    end) 
                end
            elseif infJumpConn then 
                infJumpConn:Disconnect(); infJumpConn = nil 
            end
            
            if getgenv().LunarState.NoFallDamage then
                if not fallConn then
                    fallConn = hum.StateChanged:Connect(function(old, new)
                        if new == Enum.HumanoidStateType.Freefall then
                            hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
                            task.wait(0.1)
                            hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
                        end
                    end)
                end
            elseif fallConn then
                fallConn:Disconnect(); fallConn = nil
            end
            
            if getgenv().LunarState.SpinBot then
                if not spinConn then
                    spinConn = RunService.RenderStepped:Connect(function()
                        local hrp = Character:FindFirstChild("HumanoidRootPart")
                        if hrp then hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(tick()*500), 0) end
                    end)
                end
            elseif spinConn then 
                spinConn:Disconnect(); spinConn = nil 
            end
            
            if getgenv().LunarState.AntiFling then
                if not antiFlingConn then
                    antiFlingConn = RunService.Heartbeat:Connect(function()
                        local hrp = Character:FindFirstChild("HumanoidRootPart")
                        if not hrp then return end
                        local currentVel = hrp.Velocity
                        if currentVel.Magnitude > 1000 then
                            if not originalCFrames[Character] then
                                originalCFrames[Character] = hrp.CFrame
                            end
                            hrp.CFrame = originalCFrames[Character]
                            hrp.Velocity = Vector3.new(0, 0, 0)
                            hrp.RotVelocity = Vector3.new(0, 0, 0)
                            task.delay(0.5, function() originalCFrames[Character] = nil end)
                        else
                            originalCFrames[Character] = hrp.CFrame
                        end
                    end)
                end
            elseif antiFlingConn then
                antiFlingConn:Disconnect(); antiFlingConn = nil
                originalCFrames = {}
            end
        end
        
        UpdateChams()
    end

    if getgenv().LunarState.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = GetClosestTarget()
        if target and target.Character then
            local partName = getgenv().LunarState.Config.HitPart
            local part = target.Character:FindFirstChild(partName) or target.Character:FindFirstChild("HumanoidRootPart")
            if part then
                local targetPos = part.Position
                local currentPos = Camera.CFrame.Position
                local smooth = getgenv().LunarState.Config.AimSmooth
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(currentPos, targetPos), smooth)
            end
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

    if frameSkip % 2 == 0 then
        local lIdx = 1
        local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        
        for _, p in pairs(Players:GetPlayers()) do
            if isEnemy(p) and p.Character then
                local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local dist = myHRP and (myHRP.Position - (p.Character:FindFirstChild("HumanoidRootPart") or p.Character:FindFirstChild("Torso")).Position).Magnitude or 9999
                
                if dist <= getgenv().LunarState.Config.Visuals.MaxDistance then
                    UpdateESP(p)
                    
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
                    HideESPObject(p)
                end
            else
                if p.Character and getgenv().LunarState.ESPObjects[p] then 
                    HideESPObject(p) 
                end
            end
        end
        
        for i = lIdx, #getgenv().LunarState.Lines do 
            getgenv().LunarState.Lines[i].Visible = false 
        end
    end
end)

UserInputService.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.RightShift then
        Library:Toggle()
    end
end)

Library:Notify({ 
    Title = "Welcome", 
    Description = "Lunar Universal V2 loaded successfully!", 
    Time = 5 
})

print("[Lunar] Universal Script V2 initialized successfully!")