-- [[ Cryptic Hub - Element: Toggle (Auto-Off On Death) ]]

return function(TabOps, label, callback)
    local TweenService = game:GetService("TweenService")
    local function Tw(obj, props, t)
        TweenService:Create(obj, TweenInfo.new(t or 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
    end

    TabOps.Order = TabOps.Order + 1

    local ACCENT  = Color3.fromRGB(0, 255, 150)
    local ACCENT2 = Color3.fromRGB(0, 150, 255)
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

    local isActive = false
    local configKey = TabOps.TabName .. "_" .. label

    if TabOps.UI.ConfigData[configKey] ~= nil then isActive = TabOps.UI.ConfigData[configKey] end

    local function setState(state, isClick)
        isActive = state
        if isActive then
            Tw(Track, {BackgroundColor3 = ACCENT}, 0.18)
            Tw(Knob,  {Position = UDim2.new(0, 25, 0.5, -8), BackgroundColor3 = Color3.fromRGB(255,255,255)}, 0.18)
            Tw(Stroke, {Transparency = 0.1}, 0.18)
        else
            Tw(Track, {BackgroundColor3 = OFF_CLR}, 0.18)
            Tw(Knob,  {Position = UDim2.new(0, 3, 0.5, -8),  BackgroundColor3 = Color3.fromRGB(200,200,215)}, 0.18)
            Tw(Stroke, {Transparency = 0.55}, 0.18)
        end
        TabOps.UI.ConfigData[configKey] = isActive
        pcall(callback, isActive)
        if isClick and TabOps.LogAction then
            TabOps.LogAction("⚙️ تفعيل/إيقاف ميزة", label, isActive and "مفعل ✅" or "معطل ❌", isActive and 5763719 or 15548997)
        end
    end

    B.MouseEnter:Connect(function() Tw(R, {BackgroundTransparency = 0}, 0.12) end)
    B.MouseLeave:Connect(function() Tw(R, {BackgroundTransparency = 0.1}, 0.12) end)

    if isActive then
        Track.BackgroundColor3 = ACCENT
        Knob.Position = UDim2.new(0, 25, 0.5, -8)
        Knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
        Stroke.Transparency = 0.1
        task.spawn(function() task.wait(1.5); pcall(callback, isActive) end)
    end

    B.MouseButton1Click:Connect(function() setState(not isActive, true) end)

    -- إطفاء تلقائي عند الموت
    local player = game.Players.LocalPlayer
    local function setupDeathEvent(char)
        local hum = char:WaitForChild("Humanoid", 5)
        if hum then
            hum.Died:Connect(function()
                if isActive then setState(false, false) end
            end)
        end
    end
    if player.Character then task.spawn(function() setupDeathEvent(player.Character) end) end
    player.CharacterAdded:Connect(function(char) setupDeathEvent(char) end)

    return { SetState = function(self, state) setState(state, false) end }
end
