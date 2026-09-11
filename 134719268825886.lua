local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

print("[Lunar] Initializing...")

-- [DEBUG] Remote Validation
local LocalPlayer = Players.LocalPlayer
local RemotesFolder = ReplicatedStorage:FindFirstChild("Remotes")

if not RemotesFolder then
    error("[Lunar] CRITICAL: 'Remotes' folder missing in ReplicatedStorage")
end

local remoteChildren = RemotesFolder:GetChildren()
print(string.format("[Lunar] Found %d remotes", #remoteChildren))

local function GetRemote(index, name)
    if index > #remoteChildren then
        warn(string.format("[Lunar] Remote %d (%s) out of bounds (Total: %d)", index, name, #remoteChildren))
        return nil
    end
    local r = remoteChildren[index]
    print(string.format("[Lunar] Loaded [%d]: %s (%s)", index, r.Name, r.ClassName))
    return r
end

local RebirthEvent = GetRemote(20, "Rebirth")
local PetEvent = GetRemote(109, "Pet")
local ClickEvent = GetRemote(154, "Click")

-- [STANDALONE UI] No external libraries needed
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LunarUI"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game.CoreGui

-- Main Window
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 450)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TitleBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -10, 1, 0)
TitleLabel.Position = UDim2.new(0, 5, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Lunar | Standalone | V1"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.Code
TitleLabel.TextSize = 16
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- Dragging Logic
local dragging, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

TitleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X, 
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Content Area
local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -10, 1, -45)
Content.Position = UDim2.new(0, 5, 0, 40)
Content.BackgroundTransparency = 1
Content.ScrollBarThickness = 4
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
Content.Parent = MainFrame

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 6)
ListLayout.Parent = Content

-- UI Helpers
local function CreateToggle(text, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 28)
    Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Frame.BorderSizePixel = 0
    Frame.Parent = Content
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -35, 1, 0)
    Label.Position = UDim2.new(0, 8, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.Code
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local Box = Instance.new("Frame")
    Box.Size = UDim2.new(0, 18, 0, 18)
    Box.Position = UDim2.new(1, -25, 0.5, -9)
    Box.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Box.BorderSizePixel = 0
    Box.Parent = Frame
    
    local state = default
    local function update()
        Box.BackgroundColor3 = state and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(60, 60, 60)
        if callback then callback(state) end
    end
    
    Frame.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            state = not state
            update()
        end
    end)
    
    update()
    return { GetValue = function() return state end }
end

local function CreateButton(text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 28)
    Btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Btn.BorderSizePixel = 0
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.Code
    Btn.TextSize = 14
    Btn.Parent = Content
    
    Btn.MouseEnter:Connect(function() Btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60) end)
    Btn.MouseLeave:Connect(function() Btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50) end)
    Btn.MouseButton1Click:Connect(callback)
end

local function CreateLabel(text)
    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(1, 0, 0, 20)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = text
    Lbl.TextColor3 = Color3.fromRGB(180, 180, 180)
    Lbl.Font = Enum.Font.Code
    Lbl.TextSize = 12
    Lbl.TextXAlignment = Enum.TextXAlignment.Center
    Lbl.Parent = Content
end

-- ==========================================
-- BUILD INTERFACE
-- ==========================================
print("[Lunar] Building Interface...")

CreateLabel("=== AUTOMATION ===")
local AutoClick = CreateToggle("Auto Click Loop", false)
local AutoEquip = CreateToggle("Auto Equip Best Pet", false)
local AutoRebirth = CreateToggle("Auto Rebirth", false)

CreateLabel("=== TELEPORTS ===")
local Islands = {
    {name="Spawn", pos=Vector3.new(-243.86, 164.48, 342.72)},
    {name="Winter Island", pos=Vector3.new(-202.88, 936.94, 326.96)},
    {name="Forest Island", pos=Vector3.new(-247.58, 2179.44, 249.47)},
    {name="Desert Island", pos=Vector3.new(-267.00, 3665.78, 362.30)},
    {name="Candy Island", pos=Vector3.new(-258.10, 5161.67, 299.96)},
    {name="Beach Island", pos=Vector3.new(-246.71, 6661.01, 342.58)}
}

for _, island in ipairs(Islands) do
    CreateButton("Teleport to " .. island.name, function()
        local Char = LocalPlayer.Character
        if Char and Char:FindFirstChild("HumanoidRootPart") then
            Char.HumanoidRootPart.CFrame = CFrame.new(island.pos + Vector3.new(0, 5, 0))
            print("[Lunar] Teleported to " .. island.name)
        else
            warn("[Lunar] Character or RootPart missing!")
        end
    end)
end

CreateLabel("=== SYSTEM ===")
CreateButton("Unload Script", function()
    ScreenGui:Destroy()
    print("[Lunar] Unloaded")
end)

print("[Lunar] Interface Ready")

-- Automation Loop
task.spawn(function()
    while task.wait(0.1) do
        if AutoClick.GetValue() and ClickEvent then
            pcall(function() ClickEvent:FireServer() end)
        end
        
        if AutoEquip.GetValue() and PetEvent then
            pcall(function() PetEvent:FireServer() end)
        end
        
        if AutoRebirth.GetValue() and RebirthEvent then
            pcall(function() RebirthEvent:FireServer(3) end)
        end
    end
end)