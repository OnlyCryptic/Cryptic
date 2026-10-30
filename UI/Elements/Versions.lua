-- [[ Cryptic Hub - Element: VersionToggle (Toggle + Version Selector) ]]

return function(TabOps, label, callback, versions)
    local TweenService = game:GetService("TweenService")
    local function Tw(obj, props, t)
        TweenService:Create(obj, TweenInfo.new(t or 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
    end

    TabOps.Order = (TabOps.Order or 0) + 1
    local Cfg = (TabOps.UI and TabOps.UI.ConfigData) or {}
    local TabName = tostring(TabOps.TabName or "Tab")

    local ACCENT = Color3.fromRGB(0, 255, 150)
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

    local isActive = false -- لازم يكون فوق عشان القائمة المنسدلة تشوفه

    -- ========== Version Selector (اختياري) ==========
    local hasVersions = typeof(versions) == "table" and #versions > 0
    local currentVersion = versions and versions[1] or nil
    local versionKey = TabName .. "_" .. label .. "_Version"

    if hasVersions and Cfg[versionKey] then
        currentVersion = Cfg[versionKey]
    end

    local VersionBtn
    local DropdownFrame

    if hasVersions then
        VersionBtn = Instance.new("TextButton", R)
        VersionBtn.Size = UDim2.new(0, 52, 0, 22)
        VersionBtn.Position = UDim2.new(1, -110, 0.5, -11) -- جنب التوغل
        VersionBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
        VersionBtn.BorderSizePixel = 0
        VersionBtn.Text = currentVersion .. "  ▼"
        VersionBtn.TextColor3 = Color3.fromRGB(200, 220, 255)
        VersionBtn.Font = Enum.Font.GothamSemibold
        VersionBtn.TextSize = 11
        VersionBtn.AutoButtonColor = false
        VersionBtn.ZIndex = 10 -- فوق الزر الشفاف اللي يغطي الصف
        Instance.new("UICorner", VersionBtn).CornerRadius = UDim.new(0, 8)

        local VStroke = Instance.new("UIStroke", VersionBtn)
        VStroke.Thickness = 1.1
        VStroke.Color = ACCENT
        VStroke.Transparency = 0.35

        -- القائمة المنسدلة
        DropdownFrame = Instance.new("Frame", R)
        DropdownFrame.Size = UDim2.new(0, 70, 0, #versions * 26 + 6)
        DropdownFrame.Position = UDim2.new(1, -128, 0, 40)
        DropdownFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
        DropdownFrame.BorderSizePixel = 0
        DropdownFrame.Visible = false
        DropdownFrame.ZIndex = 50
        Instance.new("UICorner", DropdownFrame).CornerRadius = UDim.new(0, 8)

        local DStroke = Instance.new("UIStroke", DropdownFrame)
        DStroke.Thickness = 1.1
        DStroke.Color = ACCENT
        DStroke.Transparency = 0.3

        local list = Instance.new("UIListLayout", DropdownFrame)
        list.Padding = UDim.new(0, 2)
        list.HorizontalAlignment = Enum.HorizontalAlignment.Center
        list.SortOrder = Enum.SortOrder.LayoutOrder

        for i, ver in ipairs(versions) do
            local opt = Instance.new("TextButton", DropdownFrame)
            opt.Size = UDim2.new(0.9, 0, 0, 24)
            opt.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
            opt.BorderSizePixel = 0
            opt.Text = ver
            opt.TextColor3 = Color3.fromRGB(210, 210, 225)
            opt.Font = Enum.Font.GothamSemibold
            opt.TextSize = 11
            opt.AutoButtonColor = false
            opt.LayoutOrder = i
            opt.ZIndex = 51
            Instance.new("UICorner", opt).CornerRadius = UDim.new(0, 6)

            opt.MouseEnter:Connect(function()
                Tw(opt, {BackgroundColor3 = Color3.fromRGB(0, 180, 120)}, 0.12)
            end)
            opt.MouseLeave:Connect(function()
                Tw(opt, {BackgroundColor3 = Color3.fromRGB(28, 28, 36)}, 0.12)
            end)

            opt.MouseButton1Click:Connect(function()
                currentVersion = ver
                VersionBtn.Text = ver .. "  ▼"
                Cfg[versionKey] = ver
                DropdownFrame.Visible = false
                pcall(callback, isActive, ver) -- يمرر الإصدار كمان
            end)
        end

        -- الضغط على الزر يبدّل النسخة بالدور (v2 -> v1 -> v2 ...)
        VersionBtn.MouseButton1Click:Connect(function()
            local idx = 1
            for i, v in ipairs(versions) do
                if v == currentVersion then idx = i break end
            end
            local ver = versions[(idx % #versions) + 1]
            currentVersion = ver
            VersionBtn.Text = ver .. "  ▼"
            Cfg[versionKey] = ver
            pcall(callback, isActive, ver)
        end)
    end

    -- ========== Label ==========
    local Lbl = Instance.new("TextLabel", R)
    Lbl.Text = label
    Lbl.Size = UDim2.new(1, hasVersions and -125 or -65, 1, 0)
    Lbl.Position = UDim2.new(0, 10, 0, 0)
    Lbl.TextColor3 = Color3.fromRGB(210, 210, 225)
    Lbl.BackgroundTransparency = 1
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Font = Enum.Font.GothamSemibold
    Lbl.TextSize = 11
    Lbl.TextWrapped = false

    -- ========== Toggle Track ==========
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
    B.Size = UDim2.new(1, hasVersions and -120 or 0, 1, 0) -- ما يغطي زر النسخة
    B.BackgroundTransparency = 1
    B.Text = ""
    B.AutoButtonColor = false
    B.ZIndex = 2

    local configKey = TabName .. "_" .. label

    if Cfg[configKey] ~= nil then
        isActive = Cfg[configKey]
    end

    local function setState(state, isClick)
        isActive = state
        if isActive then
            Tw(Track, {BackgroundColor3 = ACCENT}, 0.18)
            Tw(Knob,  {Position = UDim2.new(0, 25, 0.5, -8), BackgroundColor3 = Color3.fromRGB(255,255,255)}, 0.18)
            Tw(Stroke, {Transparency = 0.1}, 0.18)
        else
            Tw(Track, {BackgroundColor3 = OFF_CLR}, 0.18)
            Tw(Knob,  {Position = UDim2.new(0, 3, 0.5, -8), BackgroundColor3 = Color3.fromRGB(200,200,215)}, 0.18)
            Tw(Stroke, {Transparency = 0.55}, 0.18)
        end
        Cfg[configKey] = isActive
        pcall(callback, isActive, currentVersion)
        if isClick and TabOps.LogAction then
            TabOps.LogAction("⚙️ تفعيل/إيقاف ميزة", label, isActive and "مفعل ✅" or "معطل ❌", isActive and 5763719 or 15548997)
        end
    end

    -- Hover
    B.MouseEnter:Connect(function() Tw(R, {BackgroundTransparency = 0}, 0.12) end)
    B.MouseLeave:Connect(function() Tw(R, {BackgroundTransparency = 0.1}, 0.12) end)

    if isActive then
        Track.BackgroundColor3 = ACCENT
        Knob.Position = UDim2.new(0, 25, 0.5, -8)
        Knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
        Stroke.Transparency = 0.1
        task.spawn(function()
            task.wait(1.5)
            pcall(callback, isActive, currentVersion)
        end)
    end

    B.MouseButton1Click:Connect(function()
        setState(not isActive, true)
    end)

    -- منطقة المفتاح نفسه (يمين زر النسخة)
    if hasVersions then
        local B2 = Instance.new("TextButton", R)
        B2.Size = UDim2.new(0, 60, 1, 0)
        B2.Position = UDim2.new(1, -60, 0, 0)
        B2.BackgroundTransparency = 1
        B2.Text = ""
        B2.AutoButtonColor = false
        B2.ZIndex = 2
        B2.MouseButton1Click:Connect(function()
            setState(not isActive, true)
        end)
    end

    return {
        SetState = function(self, state)
            setState(state, false)
        end,
        GetVersion = function()
            return currentVersion
        end
    }
end