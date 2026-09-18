local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Library = {}
Library.Flags = {}
Library.UnloadFunctions = {}
Library.Notifications = {}
Library.Objects = {}

local function Create(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then inst[k] = v end
    end
    if props and props.Parent then inst.Parent = props.Parent end
    return inst
end

local function Round(n, d)
    local m = 10 ^ (d or 0)
    return math.floor(n * m + 0.5) / m
end

function Library:Init(config)
    config = config or {}
    self.Config = {
        Title = config.Title or "Lunar",
        Subtitle = config.Subtitle or "Universal",
        Footer = config.Footer or "Lunar's Script",
        BackgroundColor = config.BackgroundColor or Color3.fromRGB(29, 27, 27),
        AccentColor = config.AccentColor or Color3.fromRGB(255, 60, 60),
        TextColor = config.TextColor or Color3.fromRGB(255, 255, 255),
        SecondaryColor = config.SecondaryColor or Color3.fromRGB(24, 22, 22),
        BorderColor = config.BorderColor or Color3.fromRGB(40, 38, 38),
    }

    self.ScreenGui = Create("ScreenGui", {Name = "LunarUI_" .. tostring(math.random(1000, 9999)), ZIndexBehavior = Enum.ZIndexBehavior.Sibling, ResetOnSpawn = false, Parent = CoreGui})
    self.NotificationFrame = Create("Frame", {Size = UDim2.new(0, 300, 1, -50), Position = UDim2.new(1, -320, 0, 20), BackgroundTransparency = 1, Parent = self.ScreenGui})
    
    self.MainFrame = Create("Frame", {
        Size = UDim2.new(0, 700, 0, 480), Position = UDim2.new(0.5, -350, 0.5, -240),
        BackgroundColor3 = self.Config.BackgroundColor, BorderColor3 = self.Config.BorderColor,
        BorderSizePixel = 1, Active = true, Draggable = false, Parent = self.ScreenGui
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = self.MainFrame})

    self.DragHandle = Create("Frame", {Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = Color3.fromRGB(18, 16, 16), BorderSizePixel = 0, ZIndex = 10, Parent = self.MainFrame})
    Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = self.DragHandle})
    
    self.ResizeHandle = Create("Frame", {Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(1, -20, 1, -20), BackgroundColor3 = self.Config.AccentColor, BorderSizePixel = 0, ZIndex = 10, Visible = false, Parent = self.MainFrame})
    Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = self.ResizeHandle})

    self.TopBarContent = Create("Frame", {Size = UDim2.new(1, 0, 0, 30), Position = UDim2.new(0, 0, 0, 30), BackgroundColor3 = Color3.fromRGB(18, 16, 16), BorderSizePixel = 0, Parent = self.MainFrame})
    Create("TextLabel", {Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.new(0, 15, 0, 0), BackgroundTransparency = 1, Text = self.Config.Title, TextColor3 = self.Config.AccentColor, TextSize = 16, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, Parent = self.TopBarContent})
    Create("TextLabel", {Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.new(0.5, 0, 0, 0), BackgroundTransparency = 1, Text = self.Config.Subtitle, TextColor3 = Color3.fromRGB(120, 120, 120), TextSize = 12, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Right, Parent = self.TopBarContent})

    self.TabContainer = Create("Frame", {Size = UDim2.new(0, 160, 1, -60), Position = UDim2.new(0, 0, 0, 60), BackgroundColor3 = self.Config.SecondaryColor, BorderSizePixel = 0, Parent = self.MainFrame})
    self.ContentContainer = Create("Frame", {Size = UDim2.new(1, -160, 1, -60), Position = UDim2.new(0, 160, 0, 60), BackgroundTransparency = 1, Parent = self.MainFrame})
    Create("TextLabel", {Size = UDim2.new(1, -160, 0, 20), Position = UDim2.new(0, 160, 1, -20), BackgroundColor3 = Color3.fromRGB(18, 16, 16), BorderSizePixel = 0, Text = self.Config.Footer, TextColor3 = Color3.fromRGB(80, 80, 80), TextSize = 10, Font = Enum.Font.Gotham, Parent = self.MainFrame})

    self.Tabs = {}
    self.CurrentTab = nil
    self.MenuKey = Enum.KeyCode.RightShift
    self.Visible = true
    self:_SetupDragResize()
    self:_SetupMenuToggle()
    return self
end

function Library:GetObjectByFlag(flag) return self.Objects[flag] end

function Library:Notify(title, message, duration)
    duration = duration or 5
    local notif = Create("Frame", {Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = self.Config.BackgroundColor, BorderColor3 = self.Config.AccentColor, BorderSizePixel = 2, ClipsDescendants = true, Parent = self.NotificationFrame})
    Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = notif})
    Create("TextLabel", {Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0, 10, 0, 5), BackgroundTransparency = 1, Text = title, TextColor3 = self.Config.AccentColor, TextSize = 14, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, Parent = notif})
    local msgLabel = Create("TextLabel", {Size = UDim2.new(1, -20, 1, -30), Position = UDim2.new(0, 10, 0, 25), BackgroundTransparency = 1, Text = message, TextColor3 = self.Config.TextColor, TextSize = 12, Font = Enum.Font.Gotham, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, Parent = notif})
    table.insert(self.Notifications, notif)
    local targetH = 60 + msgLabel.TextBounds.Y
    notif.Size = UDim2.new(1, 0, 0, 0)
    TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, targetH)}):Play()
    task.delay(duration, function()
        TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(1, 0, 0, 0)}):Play()
        task.wait(0.3); notif:Destroy()
        for i, n in ipairs(self.Notifications) do if n == notif then table.remove(self.Notifications, i) break end end
    end)
end

function Library:AddTab(name)
    local btn = Create("TextButton", {Size = UDim2.new(1, -12, 0, 36), Position = UDim2.new(0, 6, 0, (#self.Tabs * 40) + 6), BackgroundColor3 = Color3.fromRGB(30, 28, 28), BorderSizePixel = 0, Text = name, TextColor3 = Color3.fromRGB(150, 150, 150), TextSize = 13, Font = Enum.Font.GothamMedium, AutoButtonColor = false, Parent = self.TabContainer})
    Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = btn})
    
    local content = Create("ScrollingFrame", {Size = UDim2.new(1, -20, 1, -20), Position = UDim2.new(0, 10, 0, 10), BackgroundTransparency = 1, ScrollBarThickness = 4, ScrollBarImageColor3 = self.Config.AccentColor, Visible = false, CanvasSize = UDim2.new(0, 0, 0, 0), Parent = self.ContentContainer})
    
    local data = {Btn = btn, Cont = content, Y = 0}
    
    local function selectThisTab()
        if self.CurrentTab then
            self.CurrentTab.Btn.BackgroundColor3 = Color3.fromRGB(30, 28, 28)
            self.CurrentTab.Btn.TextColor3 = Color3.fromRGB(150, 150, 150)
            self.CurrentTab.Cont.Visible = false
        end
        self.CurrentTab = data
        btn.BackgroundColor3 = self.Config.AccentColor
        btn.TextColor3 = self.Config.TextColor
        content.Visible = true
    end

    btn.MouseButton1Click:Connect(selectThisTab)
    table.insert(self.Tabs, data)
    
    if #self.Tabs == 1 then 
        selectThisTab() 
    end
    
    return data
end

function Library:_UpdateCanvas(frame)
    task.defer(function()
        if not frame or not frame:GetChildren() then return end
        local h = 0
        for _, c in ipairs(frame:GetChildren()) do
            if c:IsA("GuiObject") and c.Visible then h = h + c.AbsoluteSize.Y + 6 end
        end
        frame.CanvasSize = UDim2.new(0, 0, 0, h)
    end)
end

function Library:AddSection(tab, name)
    local sec = Create("Frame", {Size = UDim2.new(1, -10, 0, 0), BackgroundTransparency = 1, Parent = tab.Cont})
    sec.Position = UDim2.new(0, 5, 0, tab.Y)
    
    -- FIXED: Added background color to prevent overlap with components below
    Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 22), 
        BackgroundColor3 = self.Config.SecondaryColor, 
        BackgroundTransparency = 0, 
        Text = name, 
        TextColor3 = self.Config.AccentColor, 
        TextSize = 13, 
        Font = Enum.Font.GothamBold, 
        TextXAlignment = Enum.TextXAlignment.Left, 
        Parent = sec
    })
    
    local inner = Create("Frame", {Size = UDim2.new(1, 0, 1, -22), Position = UDim2.new(0, 0, 0, 22), BackgroundTransparency = 1, Parent = sec})
    tab.Y = tab.Y + sec.AbsoluteSize.Y + 6
    self:_UpdateCanvas(tab.Cont)
    return {Frame = sec, Inner = inner, Y = 0, ParentTab = tab}
end

function Library:AddButton(sec, cfg)
    cfg = cfg or {}
    local btn = Create("TextButton", {
        Size = UDim2.new(1, -10, 0, 32), 
        BackgroundColor3 = Color3.fromRGB(38, 36, 36), 
        BorderColor3 = Color3.fromRGB(55, 53, 53), 
        BorderSizePixel = 1, 
        Text = cfg.Name or "Button", 
        TextColor3 = self.Config.TextColor, 
        TextSize = 12, 
        Font = Enum.Font.GothamMedium, 
        AutoButtonColor = false, 
        Parent = sec.Inner
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = btn})
    btn.Position = UDim2.new(0, 5, 0, sec.Y); sec.Y = sec.Y + 38
    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(48, 46, 46) end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(38, 36, 36) end)
    btn.MouseButton1Click:Connect(function() if cfg.Callback then cfg.Callback() end end)
    self:_UpdateCanvas(sec.ParentTab.Cont)
    return btn
end

function Library:AddToggle(sec, cfg)
    cfg = cfg or {}
    local cont = Create("Frame", {Size = UDim2.new(1, -10, 0, 32), BackgroundTransparency = 1, Parent = sec.Inner})
    cont.Position = UDim2.new(0, 5, 0, sec.Y); sec.Y = sec.Y + 38
    Create("TextLabel", {Size = UDim2.new(1, -45, 1, 0), BackgroundTransparency = 1, Text = cfg.Name or "Toggle", TextColor3 = self.Config.TextColor, TextSize = 12, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, Parent = cont})
    local box = Create("Frame", {Size = UDim2.new(0, 34, 0, 18), Position = UDim2.new(1, -40, 0.5, -9), BackgroundColor3 = Color3.fromRGB(45, 43, 43), BorderColor3 = Color3.fromRGB(70, 68, 68), BorderSizePixel = 1, Parent = cont})
    Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = box})
    local ind = Create("Frame", {Size = UDim2.new(1, -4, 1, -4), Position = UDim2.new(0, 2, 0, 2), BackgroundColor3 = self.Config.AccentColor, BorderSizePixel = 0, Visible = cfg.Default or false, Parent = box})
    Create("UICorner", {CornerRadius = UDim.new(0, 3), Parent = ind})
    local val = cfg.Default or false; self.Flags[cfg.Flag or cfg.Name] = val
    if cfg.Callback then cfg.Callback(val) end
    cont.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then val = not val; self.Flags[cfg.Flag or cfg.Name] = val; ind.Visible = val; if cfg.Callback then cfg.Callback(val) end end end)
    self:_UpdateCanvas(sec.ParentTab.Cont)
    return {SetValue = function(_, v) val = v; ind.Visible = v; self.Flags[cfg.Flag or cfg.Name] = v; if cfg.Callback then cfg.Callback(v) end end, Type = "Toggle", Value = val}
end

function Library:AddSlider(sec, cfg)
    cfg = cfg or {}
    local min, max, def = cfg.Min or 0, cfg.Max or 100, cfg.Default or 50; local dec = cfg.Decimals or 0
    local cont = Create("Frame", {Size = UDim2.new(1, -10, 0, 48), BackgroundTransparency = 1, Parent = sec.Inner})
    cont.Position = UDim2.new(0, 5, 0, sec.Y); sec.Y = sec.Y + 54
    Create("TextLabel", {Size = UDim2.new(1, -50, 0, 15), BackgroundTransparency = 1, Text = cfg.Name or "Slider", TextColor3 = self.Config.TextColor, TextSize = 12, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, Parent = cont})
    local valLabel = Create("TextLabel", {Size = UDim2.new(0, 45, 0, 15), Position = UDim2.new(1, -45, 0, 0), BackgroundTransparency = 1, Text = tostring(def), TextColor3 = self.Config.AccentColor, TextSize = 12, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Right, Parent = cont})
    local bar = Create("Frame", {Size = UDim2.new(1, 0, 0, 8), Position = UDim2.new(0, 0, 0, 22), BackgroundColor3 = Color3.fromRGB(45, 43, 43), BorderColor3 = Color3.fromRGB(70, 68, 68), BorderSizePixel = 1, Parent = cont})
    Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = bar})
    local fill = Create("Frame", {Size = UDim2.new((def - min) / (max - min), 0, 1, 0), BackgroundColor3 = self.Config.AccentColor, BorderSizePixel = 0, Parent = bar})
    Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = fill})
    local cur = def; self.Flags[cfg.Flag or cfg.Name] = cur
    if cfg.Callback then cfg.Callback(cur) end
    local drag = false
    bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = true end end)
    bar.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
            local mx = UserInputService:GetMouseLocation().X; local bx = bar.AbsolutePosition.X; local bw = bar.AbsoluteSize.X
            local pct = math.clamp((mx - bx) / bw, 0, 1); local nv = min + (pct * (max - min)); nv = Round(nv, dec)
            cur = nv; self.Flags[cfg.Flag or cfg.Name] = nv; fill.Size = UDim2.new(pct, 0, 1, 0); valLabel.Text = tostring(nv)
            if cfg.Callback then cfg.Callback(nv) end
        end
    end)
    self:_UpdateCanvas(sec.ParentTab.Cont)
    return {SetValue = function(_, v) v = math.clamp(v, min, max); cur = v; self.Flags[cfg.Flag or cfg.Name] = v; fill.Size = UDim2.new((v - min) / (max - min), 0, 1, 0); valLabel.Text = tostring(v); if cfg.Callback then cfg.Callback(v) end end, Type = "Slider", Value = cur}
end

function Library:AddDropdown(sec, cfg)
    cfg = cfg or {}; local opts = cfg.Options or {}; local def = cfg.Default or opts[1]
    local cont = Create("Frame", {Size = UDim2.new(1, -10, 0, 32), BackgroundTransparency = 1, Parent = sec.Inner})
    cont.Position = UDim2.new(0, 5, 0, sec.Y); sec.Y = sec.Y + 38
    Create("TextLabel", {Size = UDim2.new(1, -100, 1, 0), BackgroundTransparency = 1, Text = cfg.Name or "Dropdown", TextColor3 = self.Config.TextColor, TextSize = 12, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, Parent = cont})
    local box = Create("TextButton", {Size = UDim2.new(0, 90, 0, 24), Position = UDim2.new(1, -95, 0.5, -12), BackgroundColor3 = Color3.fromRGB(38, 36, 36), BorderColor3 = Color3.fromRGB(55, 53, 53), BorderSizePixel = 1, Text = def or "", TextColor3 = self.Config.TextColor, TextSize = 11, Font = Enum.Font.GothamMedium, AutoButtonColor = false, Parent = cont})
    Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = box})
    local list = Create("Frame", {Size = UDim2.new(0, 90, 0, 0), Position = UDim2.new(1, -95, 1, 2), BackgroundColor3 = self.Config.SecondaryColor, BorderColor3 = self.Config.AccentColor, BorderSizePixel = 1, ClipsDescendants = true, Visible = false, ZIndex = 10, Parent = cont})
    Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = list})
    local cur = def; self.Flags[cfg.Flag or cfg.Name] = cur; if cfg.Callback then cfg.Callback(cur) end; local open = false
    local function refresh()
        for _, c in ipairs(list:GetChildren()) do if c:IsA("GuiObject") then c:Destroy() end end
        local y = 0
        for _, o in ipairs(opts) do
            local b = Create("TextButton", {Size = UDim2.new(1, 0, 0, 24), Position = UDim2.new(0, 0, 0, y), BackgroundColor3 = Color3.fromRGB(38, 36, 36), BorderSizePixel = 0, Text = o, TextColor3 = self.Config.TextColor, TextSize = 11, Font = Enum.Font.GothamMedium, AutoButtonColor = false, Parent = list})
            b.MouseButton1Click:Connect(function() cur = o; self.Flags[cfg.Flag or cfg.Name] = o; box.Text = o; if cfg.Callback then cfg.Callback(o) end; open = false; list.Visible = false; list.Size = UDim2.new(0, 90, 0, 0) end)
            y = y + 24
        end
        list.Size = UDim2.new(0, 90, 0, y)
    end
    box.MouseButton1Click:Connect(function() open = not open; list.Visible = open; if open then refresh() else list.Size = UDim2.new(0, 90, 0, 0) end end)
    self:_UpdateCanvas(sec.ParentTab.Cont)
    return {SetValue = function(_, v) cur = v; box.Text = v; self.Flags[cfg.Flag or cfg.Name] = v; if cfg.Callback then cfg.Callback(v) end end, SetOptions = function(_, o) opts = o; if open then refresh() end end, Type = "Dropdown", Value = cur}
end

function Library:AddColorPicker(sec, cfg)
    cfg = cfg or {}
    local cont = Create("Frame", {Size = UDim2.new(1, -10, 0, 32), BackgroundTransparency = 1, Parent = sec.Inner})
    cont.Position = UDim2.new(0, 5, 0, sec.Y); sec.Y = sec.Y + 38
    Create("TextLabel", {Size = UDim2.new(1, -45, 1, 0), BackgroundTransparency = 1, Text = cfg.Name or "Color", TextColor3 = self.Config.TextColor, TextSize = 12, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, Parent = cont})
    local box = Create("Frame", {Size = UDim2.new(0, 34, 0, 18), Position = UDim2.new(1, -40, 0.5, -9), BackgroundColor3 = cfg.Default or Color3.new(1, 1, 1), BorderColor3 = Color3.fromRGB(70, 68, 68), BorderSizePixel = 1, Parent = cont})
    Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = box})
    local cur = cfg.Default or Color3.new(1, 1, 1); self.Flags[cfg.Flag or cfg.Name] = cur; if cfg.Callback then cfg.Callback(cur) end
    box.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            local hues = {Color3.fromRGB(255, 60, 60), Color3.fromRGB(60, 255, 60), Color3.fromRGB(60, 60, 255), Color3.fromRGB(255, 255, 60)}
            local idx = 1; for x, h in ipairs(hues) do if h == cur then idx = x break end end
            cur = hues[(idx % #hues) + 1]; box.BackgroundColor3 = cur; self.Flags[cfg.Flag or cfg.Name] = cur; if cfg.Callback then cfg.Callback(cur) end
        end
    end)
    self:_UpdateCanvas(sec.ParentTab.Cont)
    return {SetValue = function(_, c) cur = c; box.BackgroundColor3 = c; self.Flags[cfg.Flag or cfg.Name] = c; if cfg.Callback then cfg.Callback(c) end end, Type = "ColorPicker", Value = cur}
end

function Library:AddKeybind(sec, cfg)
    cfg = cfg or {}
    local cont = Create("Frame", {Size = UDim2.new(1, -10, 0, 32), BackgroundTransparency = 1, Parent = sec.Inner})
    cont.Position = UDim2.new(0, 5, 0, sec.Y); sec.Y = sec.Y + 38
    Create("TextLabel", {Size = UDim2.new(1, -80, 1, 0), BackgroundTransparency = 1, Text = cfg.Name or "Keybind", TextColor3 = self.Config.TextColor, TextSize = 12, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, Parent = cont})
    local box = Create("TextButton", {Size = UDim2.new(0, 70, 0, 24), Position = UDim2.new(1, -75, 0.5, -12), BackgroundColor3 = Color3.fromRGB(38, 36, 36), BorderColor3 = Color3.fromRGB(55, 53, 53), BorderSizePixel = 1, Text = (cfg.Default or Enum.KeyCode.F).Name, TextColor3 = self.Config.TextColor, TextSize = 11, Font = Enum.Font.GothamMedium, AutoButtonColor = false, Parent = cont})
    Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = box})
    local cur = cfg.Default or Enum.KeyCode.F; self.Flags[cfg.Flag or cfg.Name] = cur; local wait = false
    box.MouseButton1Click:Connect(function() wait = true; box.Text = "..." end)
    UserInputService.InputBegan:Connect(function(i, gp) if wait and i.UserInputType == Enum.UserInputType.Keyboard then wait = false; cur = i.KeyCode; box.Text = cur.Name; self.Flags[cfg.Flag or cfg.Name] = cur; if cfg.Callback then cfg.Callback(cur) end end end)
    self:_UpdateCanvas(sec.ParentTab.Cont)
    return {SetValue = function(_, k) cur = k; box.Text = k.Name; self.Flags[cfg.Flag or cfg.Name] = k; if cfg.Callback then cfg.Callback(k) end end, Type = "Keybind", Value = cur}
end

function Library:AddTextbox(sec, cfg)
    cfg = cfg or {}
    local cont = Create("Frame", {Size = UDim2.new(1, -10, 0, 52), BackgroundTransparency = 1, Parent = sec.Inner})
    cont.Position = UDim2.new(0, 5, 0, sec.Y); sec.Y = sec.Y + 58
    Create("TextLabel", {Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, Text = cfg.Name or "Textbox", TextColor3 = self.Config.TextColor, TextSize = 12, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, Parent = cont})
    local tb = Create("TextBox", {Size = UDim2.new(1, -10, 0, 26), Position = UDim2.new(0, 5, 0, 22), BackgroundColor3 = Color3.fromRGB(38, 36, 36), BorderColor3 = Color3.fromRGB(55, 53, 53), BorderSizePixel = 1, Text = cfg.Default or "", PlaceholderText = cfg.Placeholder or "...", TextColor3 = self.Config.TextColor, TextSize = 12, Font = Enum.Font.GothamMedium, ClearTextOnFocus = false, Parent = cont})
    Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = tb})
    local cur = cfg.Default or ""; self.Flags[cfg.Flag or cfg.Name] = cur; if cfg.Callback then cfg.Callback(cur) end
    tb.FocusLost:Connect(function() cur = tb.Text; self.Flags[cfg.Flag or cfg.Name] = cur; if cfg.Callback then cfg.Callback(cur) end end)
    self:_UpdateCanvas(sec.ParentTab.Cont)
    return {SetValue = function(_, t) cur = t; tb.Text = t; self.Flags[cfg.Flag or cfg.Name] = t; if cfg.Callback then cfg.Callback(t) end end, Type = "Textbox", Value = cur}
end

function Library:Unload()
    self:Notify("System", "Unloading...", 2)
    for _, f in ipairs(self.UnloadFunctions) do pcall(f) end
    task.wait(0.5); if self.ScreenGui then self.ScreenGui:Destroy() end
    self.Flags = {}
end

table.insert(Library.UnloadFunctions, function() if Library.ScreenGui then Library.ScreenGui:Destroy() end end)

-- FIXED DRAG & RESIZE LOGIC
function Library:_SetupDragResize()
    local dragging, dragOffset, resizing, resizeStartSize, resizeStartPos = false, Vector2.new(), false, Vector2.new(), Vector2.new()
    
    self.DragHandle.InputBegan:Connect(function(i) 
        if i.UserInputType == Enum.UserInputType.MouseButton1 then 
            dragging = true 
            -- Calculate offset from the frame's top-left corner
            dragOffset = i.Position - self.MainFrame.AbsolutePosition
            self.ResizeHandle.Visible = true 
        end 
    end)
    
    self.ResizeHandle.InputBegan:Connect(function(i) 
        if i.UserInputType == Enum.UserInputType.MouseButton1 then 
            resizing = true 
            resizeStartSize = self.MainFrame.AbsoluteSize 
            resizeStartPos = i.Position 
        end 
    end)
    
    UserInputService.InputEnded:Connect(function(i) 
        if i.UserInputType == Enum.UserInputType.MouseButton1 then 
            if dragging then dragging = false; self.ResizeHandle.Visible = false end 
            if resizing then resizing = false end 
        end 
    end)
    
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then 
            -- Apply offset correctly so it doesn't jump
            self.MainFrame.Position = UDim2.new(0, i.Position.X - dragOffset.X, 0, i.Position.Y - dragOffset.Y) 
        end
        if resizing and i.UserInputType == Enum.UserInputType.MouseMovement then
            -- FIXED: Explicitly use .X and .Y to avoid Vector3 errors
            local delta = Vector2.new(i.Position.X - resizeStartPos.X, i.Position.Y - resizeStartPos.Y)
            self.MainFrame.Size = UDim2.new(0, math.clamp(resizeStartSize.X + delta.X, 600, 1200), 0, math.clamp(resizeStartSize.Y + delta.Y, 400, 800))
        end
    end)
end

function Library:_SetupMenuToggle()
    UserInputService.InputBegan:Connect(function(i, gp) if i.UserInputType == Enum.UserInputType.Keyboard and i.KeyCode == self.MenuKey then self.Visible = not self.Visible; self.MainFrame.Visible = self.Visible end end)
end

return Library