-- [[ Cryptic Hub - Join by ID V2 ]]

return function(Tab, UI)
    local TeleportService = game:GetService("TeleportService")
    local StarterGui      = game:GetService("StarterGui")
    local TweenService    = game:GetService("TweenService")
    local Players         = game:GetService("Players")
    local lp              = Players.LocalPlayer

    local PAGE    = Tab.Page
    local ACCENT  = Color3.fromRGB(0, 255, 150)
    local ACCENT2 = Color3.fromRGB(0, 150, 255)

    local function Tween(obj, props, t)
        TweenService:Create(obj, TweenInfo.new(t or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
    end

    local function Notify(text)
        pcall(function()
            StarterGui:SetCore("SendNotification", { Title = "Cryptic Hub", Text = text, Duration = 4 })
        end)
    end

    local function GradStroke(parent, thick)
        local s = Instance.new("UIStroke", parent)
        s.Thickness = thick or 1.2; s.Transparency = 0.3
        local g = Instance.new("UIGradient", s)
        g.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, ACCENT),
            ColorSequenceKeypoint.new(1, ACCENT2)
        }
        g.Rotation = 45
    end

    -- ============================================================
    -- 1. زر نسخ رمز السيرفر الحالي
    -- ============================================================
    Tab.Order = Tab.Order + 1
    local CopyBtn = Instance.new("TextButton", PAGE)
    CopyBtn.LayoutOrder = Tab.Order
    CopyBtn.Size = UDim2.new(0.98, 0, 0, 48)
    CopyBtn.BackgroundColor3 = Color3.fromRGB(14, 30, 22)
    CopyBtn.BackgroundTransparency = 0.1
    CopyBtn.Text = ""
    CopyBtn.AutoButtonColor = false
    Instance.new("UICorner", CopyBtn).CornerRadius = UDim.new(0, 10)
    GradStroke(CopyBtn)

    local CopyIcon = Instance.new("TextLabel", CopyBtn)
    CopyIcon.Size = UDim2.new(0, 36, 0, 36)
    CopyIcon.Position = UDim2.new(0, 8, 0.5, -18)
    CopyIcon.BackgroundTransparency = 1
    CopyIcon.Text = "📋"
    CopyIcon.TextSize = 20
    CopyIcon.Font = Enum.Font.GothamBold

    local CopyTitle = Instance.new("TextLabel", CopyBtn)
    CopyTitle.Size = UDim2.new(1, -55, 0, 20)
    CopyTitle.Position = UDim2.new(0, 46, 0, 6)
    CopyTitle.BackgroundTransparency = 1
    CopyTitle.Text = "نسخ رمز السيرفر الحالي / Copy Current Job ID"
    CopyTitle.TextColor3 = ACCENT
    CopyTitle.Font = Enum.Font.GothamBold
    CopyTitle.TextSize = 11
    CopyTitle.TextXAlignment = Enum.TextXAlignment.Left

    local CopySub = Instance.new("TextLabel", CopyBtn)
    CopySub.Size = UDim2.new(1, -55, 0, 16)
    CopySub.Position = UDim2.new(0, 46, 0, 26)
    CopySub.BackgroundTransparency = 1
    CopySub.Text = tostring(game.JobId):sub(1, 30) .. "…"
    CopySub.TextColor3 = Color3.fromRGB(100, 100, 120)
    CopySub.Font = Enum.Font.Code
    CopySub.TextSize = 9
    CopySub.TextXAlignment = Enum.TextXAlignment.Left

    CopyBtn.MouseEnter:Connect(function() Tween(CopyBtn, {BackgroundTransparency = 0.7}, 0.15) end)
    CopyBtn.MouseLeave:Connect(function() Tween(CopyBtn, {BackgroundTransparency = 0.1}, 0.15) end)
    CopyBtn.MouseButton1Click:Connect(function()
        Tween(CopyBtn, {BackgroundTransparency = 0.5}, 0.08)
        task.wait(0.12)
        Tween(CopyBtn, {BackgroundTransparency = 0.1}, 0.15)
        pcall(function() setclipboard(tostring(game.JobId)) end)
        CopyTitle.Text = "✅ تم النسخ! / Copied!"
        task.wait(2)
        CopyTitle.Text = "نسخ رمز السيرفر الحالي / Copy Current Job ID"
        Notify("✅ تم النسخ! / Job ID copied to clipboard!")
    end)

    -- ============================================================
    -- 2. الانتقال برمز السيرفر
    -- ============================================================
    Tab.Order = Tab.Order + 1
    local InputCard = Instance.new("Frame", PAGE)
    InputCard.LayoutOrder = Tab.Order
    InputCard.Size = UDim2.new(0.98, 0, 0, 90)
    InputCard.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
    InputCard.BackgroundTransparency = 0.1
    Instance.new("UICorner", InputCard).CornerRadius = UDim.new(0, 10)
    GradStroke(InputCard)

    local CardTitle = Instance.new("TextLabel", InputCard)
    CardTitle.Size = UDim2.new(1, -16, 0, 24)
    CardTitle.Position = UDim2.new(0, 12, 0, 6)
    CardTitle.BackgroundTransparency = 1
    CardTitle.Text = "🔗  انتقل لسيرفر / Join Server by ID"
    CardTitle.TextColor3 = Color3.fromRGB(180, 180, 200)
    CardTitle.Font = Enum.Font.GothamBold
    CardTitle.TextSize = 11
    CardTitle.TextXAlignment = Enum.TextXAlignment.Left

    -- حقل الإدخال
    local InputBg = Instance.new("Frame", InputCard)
    InputBg.Size = UDim2.new(1, -70, 0, 32)
    InputBg.Position = UDim2.new(0, 10, 0, 34)
    InputBg.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    InputBg.BackgroundTransparency = 0.1
    Instance.new("UICorner", InputBg).CornerRadius = UDim.new(0, 8)
    local IBStroke = Instance.new("UIStroke", InputBg)
    IBStroke.Thickness = 1; IBStroke.Color = Color3.fromRGB(60, 60, 80); IBStroke.Transparency = 0.5

    local TextBox = Instance.new("TextBox", InputBg)
    TextBox.Size = UDim2.new(1, -12, 1, 0)
    TextBox.Position = UDim2.new(0, 8, 0, 0)
    TextBox.BackgroundTransparency = 1
    TextBox.Text = ""
    TextBox.PlaceholderText = "الصق الرمز هنا... / Paste ID here..."
    TextBox.PlaceholderColor3 = Color3.fromRGB(80, 80, 100)
    TextBox.TextColor3 = Color3.fromRGB(220, 220, 230)
    TextBox.Font = Enum.Font.Code
    TextBox.TextSize = 10
    TextBox.TextXAlignment = Enum.TextXAlignment.Left
    TextBox.ClearTextOnFocus = false

    TextBox.Focused:Connect(function()
        Tween(IBStroke, {Color = ACCENT, Transparency = 0.3}, 0.2)
    end)
    TextBox.FocusLost:Connect(function()
        Tween(IBStroke, {Color = Color3.fromRGB(60, 60, 80), Transparency = 0.5}, 0.2)
    end)

    -- زر الانتقال
    local JoinBtn = Instance.new("TextButton", InputCard)
    JoinBtn.Size = UDim2.new(0, 50, 0, 32)
    JoinBtn.Position = UDim2.new(1, -60, 0, 34)
    JoinBtn.BackgroundColor3 = ACCENT
    JoinBtn.BackgroundTransparency = 0.1
    JoinBtn.Text = "GO"
    JoinBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    JoinBtn.Font = Enum.Font.GothamBlack
    JoinBtn.TextSize = 12
    JoinBtn.AutoButtonColor = false
    Instance.new("UICorner", JoinBtn).CornerRadius = UDim.new(0, 8)

    local HintLbl = Instance.new("TextLabel", InputCard)
    HintLbl.Size = UDim2.new(1, -16, 0, 16)
    HintLbl.Position = UDim2.new(0, 12, 0, 70)
    HintLbl.BackgroundTransparency = 1
    HintLbl.Text = "الرمز يجب أن يكون أطول من 20 حرف / ID must be longer than 20 chars"
    HintLbl.TextColor3 = Color3.fromRGB(70, 70, 90)
    HintLbl.Font = Enum.Font.Gotham
    HintLbl.TextSize = 8
    HintLbl.TextXAlignment = Enum.TextXAlignment.Left

    JoinBtn.MouseEnter:Connect(function() Tween(JoinBtn, {BackgroundTransparency = 0.4}, 0.15) end)
    JoinBtn.MouseLeave:Connect(function() Tween(JoinBtn, {BackgroundTransparency = 0.1}, 0.15) end)

    local function TryJoin()
        local txt = TextBox.Text
        if txt and #txt > 20 then
            Notify("⏳ جاري الانتقال... / Teleporting to server...")
            task.wait(0.5)
            pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, txt, lp) end)
        elseif txt ~= "" then
            HintLbl.TextColor3 = Color3.fromRGB(255, 80, 80)
            Notify("⚠️ الرمز غير صحيح / Invalid or too short ID!")
            task.wait(2)
            HintLbl.TextColor3 = Color3.fromRGB(70, 70, 90)
        end
    end

    JoinBtn.MouseButton1Click:Connect(function()
        Tween(JoinBtn, {BackgroundTransparency = 0.6}, 0.08)
        task.wait(0.12)
        Tween(JoinBtn, {BackgroundTransparency = 0.1}, 0.15)
        TryJoin()
    end)
    TextBox.FocusLost:Connect(function(enter) if enter then TryJoin() end end)
end
