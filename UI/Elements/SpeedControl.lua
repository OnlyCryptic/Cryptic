-- [[ Cryptic Hub - Element: Speed Control ]]

return function(TabOps, label, callback, default)
    local TweenService = game:GetService("TweenService")
    local function Tw(obj, props, t)
        TweenService:Create(obj, TweenInfo.new(t or 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
    end

    TabOps.Order = TabOps.Order + 1

    local ACCENT  = Color3.fromRGB(0, 255, 150)
    local ACCENT2 = Color3.fromRGB(0, 150, 255)
    local OFF_CLR = Color3.fromRGB(45, 45, 55)

    local Row = Instance.new("Frame", TabOps.Page)
    Row.LayoutOrder = TabOps.Order
    Row.Size = UDim2.new(0.98, 0, 0, 46)
    Row.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
    Row.BackgroundTransparency = 0.1
    Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 10)

    local Stroke = Instance.new("UIStroke", Row)
    Stroke.Thickness = 1.2
    Stroke.Transparency = 0.55
    local Grad = Instance.new("UIGradient", Stroke)
    Grad.Color = ColorSequence.new{ ColorSequenceKeypoint.new(0, ACCENT), ColorSequenceKeypoint.new(1, ACCENT2) }
    Grad.Rotation = 45

    local Lbl = Instance.new("TextLabel", Row)
    Lbl.Text = label
    Lbl.Size = UDim2.new(1, -120, 1, 0)
    Lbl.Position = UDim2.new(0, 10, 0, 0)
    Lbl.TextColor3 = Color3.fromRGB(210, 210, 225)
    Lbl.BackgroundTransparency = 1
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Font = Enum.Font.GothamSemibold
    Lbl.TextSize = 11
    Lbl.TextWrapped = false

    -- مربع الإدخال
    local Inp = Instance.new("TextBox", Row)
    Inp.Size = UDim2.new(0, 40, 0, 24)
    Inp.Position = UDim2.new(1, -106, 0.5, -12)
    Inp.Text = tostring(default or 50)
    Inp.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    Inp.TextColor3 = ACCENT
    Inp.Font = Enum.Font.GothamBold
    Inp.TextSize = 11
    Inp.ClearTextOnFocus = false
    Instance.new("UICorner", Inp).CornerRadius = UDim.new(0, 6)
    local InpStroke = Instance.new("UIStroke", Inp)
    InpStroke.Color = ACCENT
    InpStroke.Thickness = 1
    InpStroke.Transparency = 0.6

    -- زر التفعيل
    local Track = Instance.new("Frame", Row)
    Track.Size = UDim2.new(0, 44, 0, 22)
    Track.Position = UDim2.new(1, -52, 0.5, -11)
    Track.BackgroundColor3 = OFF_CLR
    Track.BorderSizePixel = 0
    Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

    local Knob = Instance.new("Frame", Track)
    Knob.Size = UDim2.new(0, 16, 0, 16)
    Knob.Position = UDim2.new(0, 3, 0.5, -8)
    Knob.BackgroundColor3 = Color3.fromRGB(200, 200, 215)
    Knob.BorderSizePixel = 0
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

    local Tgl = Instance.new("TextButton", Row)
    Tgl.Size = UDim2.new(0, 44, 0, 22)
    Tgl.Position = UDim2.new(1, -52, 0.5, -11)
    Tgl.BackgroundTransparency = 1
    Tgl.Text = ""
    Tgl.AutoButtonColor = false

    local active = false
    local startVal = tostring(default or 50)
    local configKey = TabOps.TabName .. "_" .. label .. "_Speed"

    if TabOps.UI.ConfigData[configKey] ~= nil then
        active = TabOps.UI.ConfigData[configKey].active
        Inp.Text = tostring(TabOps.UI.ConfigData[configKey].val)
    end

    local function update()
        if active then
            Tw(Track, {BackgroundColor3 = ACCENT}, 0.18)
            Tw(Knob,  {Position = UDim2.new(0, 25, 0.5, -8), BackgroundColor3 = Color3.fromRGB(255,255,255)}, 0.18)
            Tw(Stroke, {Transparency = 0.1}, 0.18)
        else
            Tw(Track, {BackgroundColor3 = OFF_CLR}, 0.18)
            Tw(Knob,  {Position = UDim2.new(0, 3, 0.5, -8), BackgroundColor3 = Color3.fromRGB(200,200,215)}, 0.18)
            Tw(Stroke, {Transparency = 0.55}, 0.18)
        end
        local val = tonumber(Inp.Text) or tonumber(startVal)
        TabOps.UI.ConfigData[configKey] = {active = active, val = val}
        pcall(callback, active, val)
    end

    -- Hover على الصف
    Row.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement then Tw(Row, {BackgroundTransparency = 0}, 0.12) end
    end)
    Row.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement then Tw(Row, {BackgroundTransparency = 0.1}, 0.12) end
    end)

    if active then
        Track.BackgroundColor3 = ACCENT
        Knob.Position = UDim2.new(0, 25, 0.5, -8)
        Knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
        Stroke.Transparency = 0.1
        task.spawn(function() task.wait(1.5); update() end)
    end

    Tgl.MouseButton1Click:Connect(function()
        active = not active
        update()
        if TabOps.LogAction then TabOps.LogAction("⚡ تحكم", label, active and Inp.Text or "معطل", active and 5763719 or 15548997) end
    end)
    Inp:GetPropertyChangedSignal("Text"):Connect(function() if active then update() end end)
end
