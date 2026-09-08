local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
end)

local Themes = {
    Dark = {
        Bg = Color3.fromRGB(11, 13, 19),
        Header = Color3.fromRGB(16, 19, 28),
        Accent = Color3.fromRGB(115, 95, 255),
        AccentGradient = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 120, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 60, 225))
        },
        Text = Color3.fromRGB(245, 247, 252),
        SubText = Color3.fromRGB(120, 128, 150),
        Card = Color3.fromRGB(18, 21, 31),
        CardHover = Color3.fromRGB(25, 30, 44),
        Stroke = Color3.fromRGB(40, 47, 66)
    },
    Midnight = {
        Bg = Color3.fromRGB(7, 10, 18),
        Header = Color3.fromRGB(12, 17, 30),
        Accent = Color3.fromRGB(0, 150, 255),
        AccentGradient = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 185, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 85, 215))
        },
        Text = Color3.fromRGB(240, 248, 255),
        SubText = Color3.fromRGB(110, 130, 165),
        Card = Color3.fromRGB(14, 20, 36),
        CardHover = Color3.fromRGB(20, 28, 50),
        Stroke = Color3.fromRGB(30, 58, 105)
    },
    Violet = {
        Bg = Color3.fromRGB(14, 8, 22),
        Header = Color3.fromRGB(22, 13, 34),
        Accent = Color3.fromRGB(180, 60, 255),
        AccentGradient = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(205, 80, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(125, 25, 205))
        },
        Text = Color3.fromRGB(250, 242, 255),
        SubText = Color3.fromRGB(150, 120, 180),
        Card = Color3.fromRGB(22, 14, 36),
        CardHover = Color3.fromRGB(32, 20, 52),
        Stroke = Color3.fromRGB(75, 40, 118)
    },
    Emerald = {
        Bg = Color3.fromRGB(7, 16, 12),
        Header = Color3.fromRGB(12, 25, 19),
        Accent = Color3.fromRGB(35, 210, 135),
        AccentGradient = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 235, 155)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 165, 100))
        },
        Text = Color3.fromRGB(240, 255, 248),
        SubText = Color3.fromRGB(110, 155, 132),
        Card = Color3.fromRGB(14, 28, 22),
        CardHover = Color3.fromRGB(20, 40, 31),
        Stroke = Color3.fromRGB(30, 85, 58)
    }
}

local CurrentTheme = Themes.Dark

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LunarHub_v005_VanguardV2"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local LoadingContainer = Instance.new("Frame")
LoadingContainer.Size = UDim2.new(0, 360, 0, 160)
LoadingContainer.Position = UDim2.new(0.5, -180, 0.5, -80)
LoadingContainer.BackgroundColor3 = CurrentTheme.Bg
LoadingContainer.BackgroundTransparency = 0.05
LoadingContainer.BorderSizePixel = 0
LoadingContainer.ZIndex = 1000
LoadingContainer.Parent = ScreenGui

local LoadingCorner = Instance.new("UICorner")
LoadingCorner.CornerRadius = UDim.new(0, 12)
LoadingCorner.Parent = LoadingContainer

local LoadingStroke = Instance.new("UIStroke")
LoadingStroke.Color = CurrentTheme.Stroke
LoadingStroke.Transparency = 0.2
LoadingStroke.Thickness = 1.5
LoadingStroke.Parent = LoadingContainer

local LunarLogo = Instance.new("TextLabel")
LunarLogo.Size = UDim2.new(1, 0, 0, 28)
LunarLogo.Position = UDim2.new(0, 0, 0, 22)
LunarLogo.BackgroundTransparency = 1
LunarLogo.Text = "L U N A R"
LunarLogo.TextColor3 = CurrentTheme.Text
LunarLogo.TextSize = 22
LunarLogo.Font = Enum.Font.GothamBold
LunarLogo.ZIndex = 1002
LunarLogo.Parent = LoadingContainer

local LoadingStatus = Instance.new("TextLabel")
LoadingStatus.Size = UDim2.new(1, 0, 0, 20)
LoadingStatus.Position = UDim2.new(0, 0, 0, 52)
LoadingStatus.BackgroundTransparency = 1
LoadingStatus.Text = "INITIALIZING CORE ENGINE..."
LoadingStatus.TextColor3 = CurrentTheme.SubText
LoadingStatus.TextSize = 10
LoadingStatus.Font = Enum.Font.GothamMedium
LoadingStatus.ZIndex = 1002
LoadingStatus.Parent = LoadingContainer

local PercentLabel = Instance.new("TextLabel")
PercentLabel.Size = UDim2.new(1, 0, 0, 20)
PercentLabel.Position = UDim2.new(0, 0, 0, 72)
PercentLabel.BackgroundTransparency = 1
PercentLabel.Text = "0%"
PercentLabel.TextColor3 = CurrentTheme.Accent
PercentLabel.TextSize = 13
PercentLabel.Font = Enum.Font.GothamBold
PercentLabel.ZIndex = 1002
PercentLabel.Parent = LoadingContainer

local BarBg = Instance.new("Frame")
BarBg.Size = UDim2.new(1, -50, 0, 5)
BarBg.Position = UDim2.new(0, 25, 0, 108)
BarBg.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
BarBg.BorderSizePixel = 0
BarBg.ZIndex = 1002
BarBg.Parent = LoadingContainer

local BarBgCorner = Instance.new("UICorner")
BarBgCorner.CornerRadius = UDim.new(1, 0)
BarBgCorner.Parent = BarBg

local BarFill = Instance.new("Frame")
BarFill.Size = UDim2.new(0, 0, 1, 0)
BarFill.BackgroundColor3 = CurrentTheme.Accent
BarFill.BorderSizePixel = 0
BarFill.ZIndex = 1003
BarFill.Parent = BarBg

local BarFillCorner = Instance.new("UICorner")
BarFillCorner.CornerRadius = UDim.new(1, 0)
BarFillCorner.Parent = BarFill

local BarGradient = Instance.new("UIGradient")
BarGradient.Color = CurrentTheme.AccentGradient
BarGradient.Parent = BarFill

local ReopenToast = Instance.new("TextButton")
ReopenToast.Name = "ReopenToast"
ReopenToast.Size = UDim2.new(0, 260, 0, 36)
ReopenToast.Position = UDim2.new(0.5, -130, 0, -60)
ReopenToast.BackgroundColor3 = CurrentTheme.Header
ReopenToast.BackgroundTransparency = 0.1
ReopenToast.Text = "Lunar Minimized (Click or Press Right-Ctrl)"
ReopenToast.TextColor3 = CurrentTheme.Text
ReopenToast.TextSize = 11
ReopenToast.Font = Enum.Font.GothamMedium
ReopenToast.Visible = false
ReopenToast.Parent = ScreenGui

local ToastCorner = Instance.new("UICorner")
ToastCorner.CornerRadius = UDim.new(0, 8)
ToastCorner.Parent = ReopenToast

local ToastStroke = Instance.new("UIStroke")
ToastStroke.Color = CurrentTheme.Stroke
ToastStroke.Transparency = 0.3
ToastStroke.Thickness = 1.2
ToastStroke.Parent = ReopenToast

local function ShowReopenToast()
    ReopenToast.Visible = true
    TweenService:Create(ReopenToast, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -130, 0, 16)}):Play()
end

local function HideReopenToast()
    local tw = TweenService:Create(ReopenToast, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(0.5, -130, 0, -60)})
    tw:Play()
    tw.Completed:Connect(function()
        if ReopenToast.Position.Y.Offset <= -50 then
            ReopenToast.Visible = false
        end
    end)
end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 700, 0, 460)
MainFrame.Position = UDim2.new(0.5, -350, 0.5, -230)
MainFrame.BackgroundColor3 = CurrentTheme.Bg
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = CurrentTheme.Stroke
MainStroke.Transparency = 0.4
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 52)
Header.BackgroundColor3 = CurrentTheme.Header
Header.BackgroundTransparency = 0.1
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderTitle = Instance.new("TextLabel")
HeaderTitle.Size = UDim2.new(0, 90, 1, 0)
HeaderTitle.Position = UDim2.new(0, 20, 0, 0)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Text = "LUNAR"
HeaderTitle.TextColor3 = CurrentTheme.Text
HeaderTitle.TextSize = 17
HeaderTitle.Font = Enum.Font.GothamBold
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
HeaderTitle.Parent = Header

local VersionBadge = Instance.new("Frame")
VersionBadge.Size = UDim2.new(0, 46, 0, 18)
VersionBadge.Position = UDim2.new(0, 92, 0.5, -9)
VersionBadge.BackgroundColor3 = CurrentTheme.Accent
VersionBadge.BackgroundTransparency = 0.85
VersionBadge.Parent = Header

local BadgeCorner = Instance.new("UICorner")
BadgeCorner.CornerRadius = UDim.new(0, 4)
BadgeCorner.Parent = VersionBadge

local BadgeText = Instance.new("TextLabel")
BadgeText.Size = UDim2.new(1, 0, 1, 0)
BadgeText.BackgroundTransparency = 1
BadgeText.Text = "v0.0.5"
BadgeText.TextColor3 = CurrentTheme.Accent
BadgeText.TextSize = 10
BadgeText.Font = Enum.Font.GothamBold
BadgeText.Parent = VersionBadge

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -38, 0.5, -16)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = CurrentTheme.SubText
CloseBtn.TextSize = 13
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = Header

CloseBtn.MouseEnter:Connect(function() 
    TweenService:Create(CloseBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 80, 80)}):Play() 
end)
CloseBtn.MouseLeave:Connect(function() 
    TweenService:Create(CloseBtn, TweenInfo.new(0.2), {TextColor3 = CurrentTheme.SubText}):Play() 
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 32, 0, 32)
MinimizeBtn.Position = UDim2.new(1, -72, 0.5, -16)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = CurrentTheme.SubText
MinimizeBtn.TextSize = 16
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Parent = Header

MinimizeBtn.MouseEnter:Connect(function() 
    TweenService:Create(MinimizeBtn, TweenInfo.new(0.2), {TextColor3 = CurrentTheme.Text}):Play() 
end)
MinimizeBtn.MouseLeave:Connect(function() 
    TweenService:Create(MinimizeBtn, TweenInfo.new(0.2), {TextColor3 = CurrentTheme.SubText}):Play() 
end)

MinimizeBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    ShowReopenToast()
end)

ReopenToast.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    HideReopenToast()
end)

local dragging, dragInput, dragStart, startPos
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

Header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        TweenService:Create(MainFrame, TweenInfo.new(0.08, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
            Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        }):Play()
    end
end)

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 155, 1, -68)
Sidebar.Position = UDim2.new(0, 16, 0, 60)
Sidebar.BackgroundTransparency = 1
Sidebar.Parent = MainFrame

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.Padding = UDim.new(0, 6)
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
SidebarLayout.Parent = Sidebar

local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -205, 1, -68)
ContentArea.Position = UDim2.new(0, 185, 0, 60)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

local Tabs = {}
local TabButtons = {}

local function CreateTab(name)
    local Page = Instance.new("ScrollingFrame")
    Page.Name = name .. "Page"
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.ScrollBarThickness = 2
    Page.ScrollBarImageColor3 = CurrentTheme.Accent
    Page.Visible = false
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.Parent = ContentArea

    local PageLayout = Instance.new("UIListLayout")
    PageLayout.Padding = UDim.new(0, 8)
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageLayout.Parent = Page

    PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 15)
    end)

    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, 0, 0, 38)
    TabBtn.BackgroundColor3 = CurrentTheme.Card
    TabBtn.BackgroundTransparency = 0.8
    TabBtn.Text = "    " .. name
    TabBtn.TextColor3 = CurrentTheme.SubText
    TabBtn.TextSize = 13
    TabBtn.Font = Enum.Font.GothamMedium
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.Parent = Sidebar

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = TabBtn

    local AccentBar = Instance.new("Frame")
    AccentBar.Name = "AccentBar"
    AccentBar.Size = UDim2.new(0, 3, 0, 18)
    AccentBar.Position = UDim2.new(0, 6, 0.5, -9)
    AccentBar.BackgroundColor3 = CurrentTheme.Accent
    AccentBar.BackgroundTransparency = 1
    AccentBar.BorderSizePixel = 0
    AccentBar.Parent = TabBtn

    local BarCorner = Instance.new("UICorner")
    BarCorner.CornerRadius = UDim.new(1, 0)
    BarCorner.Parent = AccentBar

    TabBtn.MouseButton1Click:Connect(function()
        for _, tPage in pairs(Tabs) do tPage.Visible = false end
        for _, button in pairs(TabButtons) do
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.8,
                TextColor3 = CurrentTheme.SubText
            }):Play()
            local bar = button:FindFirstChild("AccentBar")
            if bar then
                TweenService:Create(bar, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
            end
        end

        Page.Visible = true
        TweenService:Create(TabBtn, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.3,
            TextColor3 = CurrentTheme.Text
        }):Play()
        TweenService:Create(AccentBar, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
    end)

    Tabs[name] = Page
    table.insert(TabButtons, TabBtn)
    return Page
end

local ShooterPage  = CreateTab("Shooter")
local VisualsPage  = CreateTab("Visuals")
local MiscPage     = CreateTab("Misc")
local SettingsPage = CreateTab("Settings")

Tabs["Shooter"].Visible = true
TabButtons[1].BackgroundTransparency = 0.3
TabButtons[1].TextColor3 = CurrentTheme.Text
TabButtons[1]:FindFirstChild("AccentBar").BackgroundTransparency = 0

local function CreateToggle(parent, text, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -6, 0, 42)
    Frame.BackgroundColor3 = CurrentTheme.Card
    Frame.BackgroundTransparency = 0.2
    Frame.BorderSizePixel = 0
    Frame.Parent = parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Frame

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = CurrentTheme.Stroke
    Stroke.Transparency = 0.8
    Stroke.Thickness = 1
    Stroke.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -65, 1, 0)
    Label.Position = UDim2.new(0, 14, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = CurrentTheme.Text
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local Switch = Instance.new("TextButton")
    Switch.Size = UDim2.new(0, 40, 0, 20)
    Switch.Position = UDim2.new(1, -50, 0.5, -10)
    Switch.BackgroundColor3 = default and CurrentTheme.Accent or Color3.fromRGB(35, 38, 50)
    Switch.BorderSizePixel = 0
    Switch.Text = ""
    Switch.Parent = Frame

    local SwitchCorner = Instance.new("UICorner")
    SwitchCorner.CornerRadius = UDim.new(1, 0)
    SwitchCorner.Parent = Switch

    local Dot = Instance.new("Frame")
    Dot.Size = UDim2.new(0, 14, 0, 14)
    Dot.Position = default and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
    Dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Dot.BorderSizePixel = 0
    Dot.Parent = Switch

    local DotCorner = Instance.new("UICorner")
    DotCorner.CornerRadius = UDim.new(1, 0)
    DotCorner.Parent = Dot

    local active = default
    Switch.MouseButton1Click:Connect(function()
        active = not active
        if active then
            TweenService:Create(Switch, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundColor3 = CurrentTheme.Accent}):Play()
            TweenService:Create(Dot, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(1, -17, 0.5, -7)}):Play()
        else
            TweenService:Create(Switch, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(35, 38, 50)}):Play()
            TweenService:Create(Dot, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0, 3, 0.5, -7)}):Play()
        end
        callback(active)
    end)
end

local function CreateModeSelector(parent, text, options, defaultIndex, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -6, 0, 42)
    Frame.BackgroundColor3 = CurrentTheme.Card
    Frame.BackgroundTransparency = 0.2
    Frame.BorderSizePixel = 0
    Frame.Parent = parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Frame

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = CurrentTheme.Stroke
    Stroke.Transparency = 0.8
    Stroke.Thickness = 1
    Stroke.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.5, 0, 1, 0)
    Label.Position = UDim2.new(0, 14, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = CurrentTheme.Text
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 130, 0, 26)
    Btn.Position = UDim2.new(1, -144, 0.5, -13)
    Btn.BackgroundColor3 = Color3.fromRGB(28, 32, 44)
    Btn.Text = options[defaultIndex]
    Btn.TextColor3 = CurrentTheme.Accent
    Btn.TextSize = 11
    Btn.Font = Enum.Font.GothamBold
    Btn.Parent = Frame

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = Btn

    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.Color = CurrentTheme.Stroke
    BtnStroke.Transparency = 0.5
    BtnStroke.Thickness = 1
    BtnStroke.Parent = Btn

    local currentIndex = defaultIndex
    Btn.MouseButton1Click:Connect(function()
        currentIndex = currentIndex + 1
        if currentIndex > #options then currentIndex = 1 end
        Btn.Text = options[currentIndex]
        callback(options[currentIndex])
    end)
end

local function CreateSlider(parent, text, min, max, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -6, 0, 50)
    Frame.BackgroundColor3 = CurrentTheme.Card
    Frame.BackgroundTransparency = 0.2
    Frame.BorderSizePixel = 0
    Frame.Parent = parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Frame

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = CurrentTheme.Stroke
    Stroke.Transparency = 0.8
    Stroke.Thickness = 1
    Stroke.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.5, 0, 0, 22)
    Label.Position = UDim2.new(0, 14, 0, 6)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = CurrentTheme.Text
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local ValLabel = Instance.new("TextLabel")
    ValLabel.Name = "ValLabel"
    ValLabel.Size = UDim2.new(0.5, -18, 0, 22)
    ValLabel.Position = UDim2.new(0.5, 0, 0, 6)
    ValLabel.BackgroundTransparency = 1
    ValLabel.Text = tostring(default)
    ValLabel.TextColor3 = CurrentTheme.Accent
    ValLabel.TextSize = 12
    ValLabel.Font = Enum.Font.GothamBold
    ValLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValLabel.Parent = Frame

    local SliderTrack = Instance.new("Frame")
    SliderTrack.Size = UDim2.new(1, -28, 0, 5)
    SliderTrack.Position = UDim2.new(0, 14, 1, -12)
    SliderTrack.BackgroundColor3 = Color3.fromRGB(35, 38, 50)
    SliderTrack.BorderSizePixel = 0
    SliderTrack.Parent = Frame

    local TrackCorner = Instance.new("UICorner")
    TrackCorner.CornerRadius = UDim.new(1, 0)
    TrackCorner.Parent = SliderTrack

    local SliderFill = Instance.new("Frame")
    local initRatio = math.clamp((default - min) / (max - min), 0, 1)
    SliderFill.Size = UDim2.new(initRatio, 0, 1, 0)
    SliderFill.BackgroundColor3 = CurrentTheme.Accent
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderTrack

    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent = SliderFill

    local FillGradient = Instance.new("UIGradient")
    FillGradient.Color = CurrentTheme.AccentGradient
    FillGradient.Parent = SliderFill

    local sliding = false
    local function Update(input)
        local pos = math.clamp((input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
        TweenService:Create(SliderFill, TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Size = UDim2.new(pos, 0, 1, 0)}):Play()
        local val = math.floor(min + (max - min) * pos)
        ValLabel.Text = tostring(val)
        callback(val)
    end

    SliderTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = true
            Update(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then Update(input) end
    end)
end

local function CreateButton(parent, text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -6, 0, 38)
    Btn.BackgroundColor3 = CurrentTheme.Card
    Btn.BackgroundTransparency = 0.2
    Btn.Text = text
    Btn.TextColor3 = CurrentTheme.Text
    Btn.TextSize = 13
    Btn.Font = Enum.Font.GothamMedium
    Btn.Parent = parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Btn

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = CurrentTheme.Stroke
    Stroke.Transparency = 0.8
    Stroke.Thickness = 1
    Stroke.Parent = Btn

    Btn.MouseEnter:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = CurrentTheme.CardHover}):Play()
    end)
    Btn.MouseLeave:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = CurrentTheme.Card}):Play()
    end)

    Btn.MouseButton1Click:Connect(callback)
end

local AimbotEnabled = false
local AimFOV = 120
local AimSmoothness = 5
local AimPart = "Head"

local FOVCircle = Instance.new("Frame")
FOVCircle.Name = "FOVCircle"
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.Size = UDim2.new(0, AimFOV * 2, 0, AimFOV * 2)
FOVCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Visible = false
FOVCircle.Parent = ScreenGui

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0)
FOVCorner.Parent = FOVCircle

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Color = CurrentTheme.Accent
FOVStroke.Transparency = 0.4
FOVStroke.Thickness = 1.5
FOVStroke.Parent = FOVCircle

local function UpdateFOVSize(newRadius)
    AimFOV = newRadius
    FOVCircle.Size = UDim2.new(0, AimFOV * 2, 0, AimFOV * 2)
end

CreateToggle(ShooterPage, "Aimbot Enabled", false, function(v) AimbotEnabled = v end)
CreateToggle(ShooterPage, "Draw FOV Circle", false, function(v) FOVCircle.Visible = v end)
CreateSlider(ShooterPage, "Aimbot FOV Radius", 30, 600, 120, function(v) UpdateFOVSize(v) end)
CreateSlider(ShooterPage, "Smoothness", 1, 25, 5, function(v) AimSmoothness = v end)
CreateToggle(ShooterPage, "Target RootPart Instead of Head", false, function(v) AimPart = v and "HumanoidRootPart" or "Head" end)

RunService.RenderStepped:Connect(function()
    local mousePos = UserInputService:GetMouseLocation()
    FOVCircle.Position = UDim2.new(0, mousePos.X, 0, mousePos.Y)

    if AimbotEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target, closestDist = nil, AimFOV

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local part = plr.Character:FindFirstChild(AimPart)
                if part then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        if dist < closestDist then
                            closestDist = dist
                            target = part
                        end
                    end
                end
            end
        end

        if target then
            local currentCF = Camera.CFrame
            local targetCF = CFrame.new(currentCF.Position, target.Position)
            Camera.CFrame = currentCF:Lerp(targetCF, 1 / AimSmoothness)
        end
    end
end)

local ESP_Box = false
local ESP_BoxStyle = "Full Box"
local ESP_Health = false
local ESP_Name = false
local ESP_Tracers = false
local ESP_Skeleton = false
local ESP_Chams = false

local ESPColor = Color3.fromRGB(255, 255, 255)

CreateToggle(VisualsPage, "Box ESP Enabled", false, function(v) ESP_Box = v end)
CreateModeSelector(VisualsPage, "Box ESP Style", {"Full Box", "Corner Box"}, 1, function(selected)
    ESP_BoxStyle = selected
end)

CreateToggle(VisualsPage, "Health Bar", false, function(v) ESP_Health = v end)
CreateToggle(VisualsPage, "Player Names & Distance", false, function(v) ESP_Name = v end)
CreateToggle(VisualsPage, "Tracers (Snaplines)", false, function(v) ESP_Tracers = v end)
CreateToggle(VisualsPage, "Skeleton ESP", false, function(v) ESP_Skeleton = v end)
CreateToggle(VisualsPage, "Chams (Highlight)", false, function(v)
    ESP_Chams = v
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local h = plr.Character:FindFirstChild("LunarChams")
            if v then
                if not h then
                    h = Instance.new("Highlight")
                    h.Name = "LunarChams"
                    h.FillColor = ESPColor
                    h.OutlineColor = Color3.fromRGB(200, 200, 200)
                    h.FillTransparency = 0.5
                    h.Parent = plr.Character
                end
            else
                if h then h:Destroy() end
            end
        end
    end
end)

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
    if ESPObjects[plr] then return end
    
    local cornerLines = {}
    for i = 1, 8 do
        local line = Drawing.new("Line")
        line.Thickness = 1.5
        line.Visible = false
        table.insert(cornerLines, line)
    end

    ESPObjects[plr] = {
        Box = Drawing.new("Square"),
        CornerLines = cornerLines,
        Tracer = Drawing.new("Line"),
        Name = Drawing.new("Text"),
        HealthBarBg = Drawing.new("Square"),
        HealthBar = Drawing.new("Square"),
        Skeletons = {}
    }

    local obj = ESPObjects[plr]

    obj.Box.Thickness = 1.5
    obj.Box.Filled = false
    obj.Box.Visible = false

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

local function HideESPObject(plr)
    local obj = ESPObjects[plr]
    if not obj then return end
    obj.Box.Visible = false
    for _, line in ipairs(obj.CornerLines) do line.Visible = false end
    obj.Tracer.Visible = false
    obj.Name.Visible = false
    obj.HealthBarBg.Visible = false
    obj.HealthBar.Visible = false
    for _, line in ipairs(obj.Skeletons) do line.Visible = false end
end

local function RemoveESPObject(plr)
    local obj = ESPObjects[plr]
    if not obj then return end
    obj.Box:Remove()
    for _, line in ipairs(obj.CornerLines) do line:Remove() end
    obj.Tracer:Remove()
    obj.Name:Remove()
    obj.HealthBarBg:Remove()
    obj.HealthBar:Remove()
    for _, line in ipairs(obj.Skeletons) do line:Remove() end
    ESPObjects[plr] = nil
end

Players.PlayerRemoving:Connect(RemoveESPObject)

RunService.RenderStepped:Connect(function()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            CreateESPObject(plr)
            local obj = ESPObjects[plr]
            local char = plr.Character
            local root = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
            local head = char and char:FindFirstChild("Head")
            local hum = char and char:FindFirstChildOfClass("Humanoid")

            if char and root and head and hum and hum.Health > 0 then
                local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)

                if onScreen and rootPos.Z > 0 then
                    local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.7, 0))
                    local legPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3.0, 0))

                    local height = math.abs(headPos.Y - legPos.Y)
                    local width = height * 0.6
                    local topLeft = Vector2.new(rootPos.X - width / 2, headPos.Y)

                    if ESP_Box then
                        if ESP_BoxStyle == "Full Box" then
                            obj.Box.Size = Vector2.new(width, height)
                            obj.Box.Position = topLeft
                            obj.Box.Color = ESPColor
                            obj.Box.Visible = true
                            for _, line in ipairs(obj.CornerLines) do line.Visible = false end
                        elseif ESP_BoxStyle == "Corner Box" then
                            obj.Box.Visible = false
                            local lineLen = math.clamp(width * 0.25, 4, 15)
                            local topRight = Vector2.new(topLeft.X + width, topLeft.Y)
                            local bottomLeft = Vector2.new(topLeft.X, topLeft.Y + height)
                            local bottomRight = Vector2.new(topLeft.X + width, topLeft.Y + height)

                            obj.CornerLines[1].From = topLeft
                            obj.CornerLines[1].To = Vector2.new(topLeft.X + lineLen, topLeft.Y)
                            obj.CornerLines[2].From = topLeft
                            obj.CornerLines[2].To = Vector2.new(topLeft.X, topLeft.Y + lineLen)

                            obj.CornerLines[3].From = topRight
                            obj.CornerLines[3].To = Vector2.new(topRight.X - lineLen, topRight.Y)
                            obj.CornerLines[4].From = topRight
                            obj.CornerLines[4].To = Vector2.new(topRight.X, topRight.Y + lineLen)

                            obj.CornerLines[5].From = bottomLeft
                            obj.CornerLines[5].To = Vector2.new(bottomLeft.X + lineLen, bottomLeft.Y)
                            obj.CornerLines[6].From = bottomLeft
                            obj.CornerLines[6].To = Vector2.new(bottomLeft.X, bottomLeft.Y - lineLen)

                            obj.CornerLines[7].From = bottomRight
                            obj.CornerLines[7].To = Vector2.new(bottomRight.X - lineLen, bottomRight.Y)
                            obj.CornerLines[8].From = bottomRight
                            obj.CornerLines[8].To = Vector2.new(bottomRight.X, bottomRight.Y - lineLen)

                            for i = 1, 8 do
                                obj.CornerLines[i].Color = ESPColor
                                obj.CornerLines[i].Visible = true
                            end
                        end
                    else
                        obj.Box.Visible = false
                        for _, line in ipairs(obj.CornerLines) do line.Visible = false end
                    end

                    if ESP_Tracers then
                        obj.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        obj.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
                        obj.Tracer.Color = ESPColor
                        obj.Tracer.Visible = true
                    else
                        obj.Tracer.Visible = false
                    end

                    if ESP_Name then
                        local myHRP = Character and Character:FindFirstChild("HumanoidRootPart")
                        local dist = myHRP and math.floor((myHRP.Position - root.Position).Magnitude) or 0
                        obj.Name.Text = plr.Name .. " [" .. dist .. "m]"
                        obj.Name.Position = Vector2.new(rootPos.X, topLeft.Y - 16)
                        obj.Name.Color = Color3.fromRGB(255, 255, 255)
                        obj.Name.Visible = true
                    else
                        obj.Name.Visible = false
                    end

                    if ESP_Health then
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

                    if ESP_Skeleton then
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
                                        line.Color = ESPColor
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
                else
                    HideESPObject(plr)
                end
            else
                HideESPObject(plr)
            end
        end
    end
end)

local FlyEnabled = false
local FlySpeed = 50
local FlyBodyVel, FlyBodyGyro, FlyConn

CreateToggle(MiscPage, "Fly Mode", false, function(v)
    FlyEnabled = v
    local myHRP = Character and Character:FindFirstChild("HumanoidRootPart")
    if FlyEnabled and myHRP then
        FlyBodyVel = Instance.new("BodyVelocity")
        FlyBodyVel.MaxForce = Vector3.new(1, 1, 1) * 1e6
        FlyBodyVel.Velocity = Vector3.zero
        FlyBodyVel.Parent = myHRP

        FlyBodyGyro = Instance.new("BodyGyro")
        FlyBodyGyro.MaxTorque = Vector3.new(1, 1, 1) * 1e6
        FlyBodyGyro.CFrame = myHRP.CFrame
        FlyBodyGyro.Parent = myHRP

        FlyConn = RunService.RenderStepped:Connect(function()
            if not FlyEnabled or not myHRP then return end
            local move = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, 1, 0) end

            FlyBodyVel.Velocity = move * FlySpeed
            FlyBodyGyro.CFrame = Camera.CFrame
        end)
    else
        if FlyConn then FlyConn:Disconnect() end
        if FlyBodyVel then FlyBodyVel:Destroy() end
        if FlyBodyGyro then FlyBodyGyro:Destroy() end
    end
end)

CreateSlider(MiscPage, "Fly Speed", 10, 300, 50, function(v) FlySpeed = v end)
CreateSlider(MiscPage, "Walk Speed", 16, 300, 16, function(v)
    local hum = Character and Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = v end
end)
CreateSlider(MiscPage, "Jump Power", 50, 350, 50, function(v)
    local hum = Character and Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.UseJumpPower = true hum.JumpPower = v end
end)
CreateSlider(MiscPage, "Gravity Control", 0, 196, 196, function(v) workspace.Gravity = v end)

local InfJumpConn
CreateToggle(MiscPage, "Infinite Jump", false, function(v)
    if v then
        InfJumpConn = UserInputService.JumpRequest:Connect(function()
            local hum = Character and Character:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    else
        if InfJumpConn then InfJumpConn:Disconnect() InfJumpConn = nil end
    end
end)

local NoclipConn
CreateToggle(MiscPage, "Noclip", false, function(v)
    if v then
        NoclipConn = RunService.Stepped:Connect(function()
            if Character then
                for _, p in ipairs(Character:GetChildren()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end
        end)
    else
        if NoclipConn then NoclipConn:Disconnect() NoclipConn = nil end
    end
end)

local function ApplyTheme(theme)
    CurrentTheme = theme
    MainFrame.BackgroundColor3 = theme.Bg
    Header.BackgroundColor3 = theme.Header
    HeaderTitle.TextColor3 = theme.Text
    VersionBadge.BackgroundColor3 = theme.Accent
    BadgeText.TextColor3 = theme.Accent
    CloseBtn.TextColor3 = theme.SubText
    MinimizeBtn.TextColor3 = theme.SubText
    MainStroke.Color = theme.Stroke
    FOVStroke.Color = theme.Accent
    ReopenToast.BackgroundColor3 = theme.Header
    ReopenToast.TextColor3 = theme.Text
    ToastStroke.Color = theme.Stroke

    for _, btn in ipairs(TabButtons) do
        local bar = btn:FindFirstChild("AccentBar")
        if bar then bar.BackgroundColor3 = theme.Accent end
    end

    for _, page in pairs(Tabs) do
        for _, obj in ipairs(page:GetChildren()) do
            if obj:IsA("Frame") or obj:IsA("TextButton") then
                obj.BackgroundColor3 = theme.Card
                local stroke = obj:FindFirstChildOfClass("UIStroke")
                if stroke then stroke.Color = theme.Stroke end
                local lbl = obj:FindFirstChildOfClass("TextLabel")
                if lbl and lbl.Name ~= "ValLabel" then lbl.TextColor3 = theme.Text end
                local valLbl = obj:FindFirstChild("ValLabel")
                if valLbl then valLbl.TextColor3 = theme.Accent end
            end
        end
    end
end

CreateButton(SettingsPage, "Theme: Dark Classic", function() ApplyTheme(Themes.Dark) end)
CreateButton(SettingsPage, "Theme: Midnight Blue", function() ApplyTheme(Themes.Midnight) end)
CreateButton(SettingsPage, "Theme: Neon Violet", function() ApplyTheme(Themes.Violet) end)
CreateButton(SettingsPage, "Theme: Emerald Green", function() ApplyTheme(Themes.Emerald) end)

CreateSlider(SettingsPage, "UI Transparency", 0, 90, 5, function(v)
    MainFrame.BackgroundTransparency = v / 100
end)

CreateButton(SettingsPage, "ESP Color: White", function() ESPColor = Color3.fromRGB(255, 255, 255) end)
CreateButton(SettingsPage, "ESP Color: Cyan", function() ESPColor = Color3.fromRGB(0, 230, 255) end)
CreateButton(SettingsPage, "ESP Color: Red", function() ESPColor = Color3.fromRGB(255, 60, 60) end)
CreateButton(SettingsPage, "ESP Color: Yellow", function() ESPColor = Color3.fromRGB(255, 220, 40) end)

task.spawn(function()
    local steps = {
        {percent = 0.25, text = "LOADING MODULES & ASSETS..."},
        {percent = 0.65, text = "AUTHENTICATING ENGINE..."},
        {percent = 0.90, text = "INITIALIZING ESP ENGINE..."},
        {percent = 1.00, text = "LUNAR READY!"}
    }

    for _, step in ipairs(steps) do
        LoadingStatus.Text = step.text
        PercentLabel.Text = math.floor(step.percent * 100) .. "%"
        TweenService:Create(BarFill, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(step.percent, 0, 1, 0)}):Play()
        task.wait(0.35)
    end

    task.wait(0.2)

    TweenService:Create(LoadingContainer, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 360, 0, 0),
        BackgroundTransparency = 1
    }):Play()

    for _, v in ipairs(LoadingContainer:GetChildren()) do
        if v:IsA("TextLabel") or v:IsA("Frame") then
            TweenService:Create(v, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
            if v:IsA("TextLabel") then
                TweenService:Create(v, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
            end
        end
    end

    task.wait(0.35)
    LoadingContainer:Destroy()

    MainFrame.Visible = true
    MainFrame.Size = UDim2.new(0, 700, 0, 0)
    MainFrame.BackgroundTransparency = 1

    TweenService:Create(MainFrame, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 700, 0, 460),
        BackgroundTransparency = 0.05
    }):Play()
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightControl then
        MainFrame.Visible = not MainFrame.Visible
        if not MainFrame.Visible then
            ShowReopenToast()
        else
            HideReopenToast()
        end
    end
end)