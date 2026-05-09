-- [[ Cryptic Hub - Element: Button ]]

return function(TabOps, text, callback)
    local TweenService = game:GetService("TweenService")
    local function Tw(obj, props, t)
        TweenService:Create(obj, TweenInfo.new(t or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
    end

    TabOps.Order = TabOps.Order + 1

    local ACCENT  = Color3.fromRGB(0, 255, 150)
    local ACCENT2 = Color3.fromRGB(0, 150, 255)

    local B = Instance.new("TextButton", TabOps.Page)
    B.LayoutOrder = TabOps.Order
    B.Size = UDim2.new(0.98, 0, 0, 40)
    B.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
    B.BackgroundTransparency = 0.1
    B.Text = text
    B.TextColor3 = ACCENT
    B.Font = Enum.Font.GothamBold
    B.TextSize = 12
    B.AutoButtonColor = false
    Instance.new("UICorner", B).CornerRadius = UDim.new(0, 10)

    local Stroke = Instance.new("UIStroke", B)
    Stroke.Thickness = 1.2
    Stroke.Transparency = 0.4
    local Grad = Instance.new("UIGradient", Stroke)
    Grad.Color = ColorSequence.new{ ColorSequenceKeypoint.new(0, ACCENT), ColorSequenceKeypoint.new(1, ACCENT2) }
    Grad.Rotation = 45

    B.MouseEnter:Connect(function()
        Tw(B, {BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(0, 40, 28)}, 0.15)
        Tw(Stroke, {Transparency = 0.1}, 0.15)
    end)
    B.MouseLeave:Connect(function()
        Tw(B, {BackgroundTransparency = 0.1, BackgroundColor3 = Color3.fromRGB(16, 16, 20)}, 0.15)
        Tw(Stroke, {Transparency = 0.4}, 0.15)
    end)

    B.MouseButton1Click:Connect(function()
        if TabOps.LogAction then TabOps.LogAction("🔘 ضغطة زر", "تم الضغط على:", text, 3447003) end
        pcall(callback)
    end)

    return B
end
