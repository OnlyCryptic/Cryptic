-- [[ Cryptic Hub - Element: Timed Toggle ]]

return function(TabOps, label, callback)
    local TweenService = game:GetService("TweenService")
    local function Tw(obj, props, t)
        TweenService:Create(obj, TweenInfo.new(t or 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
    end

    TabOps.Order = TabOps.Order + 1

    local ACCENT  = Color3.fromRGB(0, 255, 150)
    local ACCENT2 = Color3.fromRGB(0, 150, 255)
    local BLUE    = Color3.fromRGB(0, 150, 255)
    local OFF_CLR = Color3.fromRGB(45, 45, 55)

    local R = Instance.new("Frame", TabOps.Page)
    R.LayoutOrder = TabOps.Order
    R.Size = UDim2.new(0.98, 0, 0, 46)
    R.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
    R.BackgroundTransparency = 0.1
    Instance.new("UICorner", R).CornerRadius = UDim.new(0, 10)

    local Stroke = Instance.new("UIStroke", R)
    Stroke.Thickness = 1.2
    Stroke.Transparency = 0.55
    local Grad = Instance.new("UIGradient", Stroke)
    Grad.Color = ColorSequence.new{ ColorSequenceKeypoint.new(0, ACCENT), ColorSequenceKeypoint.new(1, ACCENT2) }
    Grad.Rotation = 45

    local Lbl = Instance.new("TextLabel", R)
    Lbl.Text = label
    Lbl.Size = UDim2.new(1, -65, 1, 0)
    Lbl.Position = UDim2.new(0, 10, 0, 0)
    Lbl.TextColor3 = Color3.fromRGB(210, 210, 225)
    Lbl.BackgroundTransparency = 1
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Font = Enum.Font.GothamSemibold
    Lbl.TextSize = 11
    Lbl.TextWrapped = false

    local Track = Instance.new("Frame", R)
    Track.Size = UDim2.new(0, 44, 0, 22)
    Track.Position = UDim2.new(1, -54, 0.5, -11)
    Track.BackgroundColor3 = OFF_CLR
    Track.BorderSizePixel = 0
    Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

    local Knob = Instance.new("Frame", Track)
    Knob.Size = UDim2.new(0, 16, 0, 16)
    Knob.Position = UDim2.new(0, 3, 0.5, -8)
    Knob.BackgroundColor3 = Color3.fromRGB(200, 200, 215)
    Knob.BorderSizePixel = 0
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

    local B = Instance.new("TextButton", R)
    B.Size = UDim2.new(1, 0, 1, 0)
    B.BackgroundTransparency = 1
    B.Text = ""
    B.AutoButtonColor = false

    local isRunning = false

    B.MouseEnter:Connect(function() Tw(R, {BackgroundTransparency = 0}, 0.12) end)
    B.MouseLeave:Connect(function() Tw(R, {BackgroundTransparency = 0.1}, 0.12) end)

    B.MouseButton1Click:Connect(function()
        if isRunning then return end
        isRunning = true
        Tw(Track, {BackgroundColor3 = BLUE}, 0.18)
        Tw(Knob,  {Position = UDim2.new(0, 25, 0.5, -8), BackgroundColor3 = Color3.fromRGB(255,255,255)}, 0.18)
        Tw(Stroke, {Transparency = 0.1}, 0.18)

        if TabOps.LogAction then
            TabOps.LogAction("⏱️ تفعيل مؤقت", label, "تم التفعيل", 15844367)
        end

        task.spawn(function()
            pcall(callback, true)
            task.wait(2)
            Tw(Track, {BackgroundColor3 = OFF_CLR}, 0.18)
            Tw(Knob,  {Position = UDim2.new(0, 3, 0.5, -8), BackgroundColor3 = Color3.fromRGB(200,200,215)}, 0.18)
            Tw(Stroke, {Transparency = 0.55}, 0.18)
            pcall(callback, false)
            isRunning = false
        end)
    end)

    return { Set = function() end, SetState = function() end }
end
