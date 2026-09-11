local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

print("[Lunar] Initializing...")

-- [DEBUG] Remote Validation
local LocalPlayer = Players.LocalPlayer
local RemotesFolder = ReplicatedStorage:FindFirstChild("Remotes")

if not RemotesFolder then
    error("[Lunar] CRITICAL: 'Remotes' folder missing.")
end

local remoteChildren = RemotesFolder:GetChildren()
print(string.format("[Lunar] Found %d remotes", #remoteChildren))

local function GetRemote(index, name)
    if index > #remoteChildren then
        warn(string.format("[Lunar] Remote %d (%s) out of bounds.", index, name))
        return nil
    end
    print(string.format("[Lunar] Loaded [%d]: %s", index, remoteChildren[index].Name))
    return remoteChildren[index]
end

local RebirthEvent = GetRemote(20, "Rebirth")
local PetEvent = GetRemote(109, "Pet")
local ClickEvent = GetRemote(154, "Click")

-- [DEBUG] Library Load Attempt (We will bypass it if it fails)
local LibraryLoaded = false
pcall(function()
    local Lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
    -- If we get here without error, check if AddTab works
    local TestWin = Lib:CreateWindow({Title="Test", AutoShow=false})
    local TestTab = TestWin:AddTab("Test")
    if TestTab then LibraryLoaded = true end
    TestWin.Holder:Destroy() -- Clean up test window
end)

if not LibraryLoaded then
    warn("[Lunar] LinoriaLib failed or incompatible. Switching to Native UI Mode.")
else
    print("[Lunar] LinoriaLib compatible.")
end

-- ==========================================
-- NATIVE UI IMPLEMENTATION (Fallback)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LunarUI"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game.CoreGui

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TitleBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -10, 1, 0)
TitleLabel.Position = UDim2.new(0, 5, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Lunar | Native Mode | V1"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.Code
TitleLabel.TextSize = 16
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- Dragging Logic
local dragging, dragInput, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Content Area
local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -10, 1, -40)
Content.Position = UDim2.new(0, 5, 0, 35)
Content.BackgroundTransparency = 1
Content.ScrollBarThickness = 4
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
Content.Parent = MainFrame

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 5)
ListLayout.Parent = Content

-- Helper to create buttons/toggles
local function CreateToggle(text, default, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 25)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    ToggleFrame.Parent = Content
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -30, 1, 0)
    Label.Position = UDim2.new(0, 5, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.Code
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleFrame
    
    local Box = Instance.new("Frame")
    Box.Size = UDim2.new(0, 15, 0, 15)
    Box.Position = UDim2.new(1, -20, 0.5, -7.5)
    Box.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Box.Parent = ToggleFrame
    
    local state = default
    local function update()
        Box.BackgroundColor3 = state and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(60, 60, 60)
        callback(state)
    end
    
    ToggleFrame.InputBegan:Connect(function(i)
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
    Btn.Size = UDim2.new(1, 0, 0, 25)
    Btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.Code
    Btn.TextSize = 14
    Btn.Parent = Content
    
    Btn.MouseButton1Click:Connect(callback)
end

-- ==========================================
-- FEATURES
-- ==========================================
print("[Lunar] Building Interface...")

-- Toggles
local AutoClick = CreateToggle("Auto Click Loop", false, function(v) print("[Lunar] AutoClick:", v) end)
local AutoEquip = CreateToggle("Auto Equip Best", false, function(v) print("[Lunar] AutoEquip:", v) end)
local AutoRebirth = CreateToggle("Auto Rebirth", false, function(v) print("[Lunar] AutoRebirth:", v) end)

-- Teleport System
CreateButton("--- TELEPORTS ---", function() end)

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
            warn("[Lunar] Character not found!")
        end
    end)
end

CreateButton("Unload Script", function()
    ScreenGui:Destroy()
    print("[Lunar] Unloaded")
end)

print("[Lunar] Interface Ready")

-- Automation Loop
task.spawn(function()
    while task.wait() do
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