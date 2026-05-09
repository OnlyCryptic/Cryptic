-- [[ Cryptic Hub - Element: ToggleDropdown ]]
-- زر تشغيل رئيسي + سهم يفتح منطقة إعدادات داخلية
-- الإعدادات الداخلية محجوبة ما تشتغل إلا لما يُفعَّل الزر الرئيسي

return function(TabOps, label, mainCallback)
    local TweenService = game:GetService("TweenService")

    local function tween(obj, props, t)
        TweenService:Create(obj, TweenInfo.new(t or 0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
    end

    local isActive = false
    local isOpen   = false
    local configKey = TabOps.TabName .. "_td_" .. label

    if TabOps.UI and TabOps.UI.ConfigData and TabOps.UI.ConfigData[configKey] ~= nil then
        isActive = TabOps.UI.ConfigData[configKey]
    end

    -- ── الحاوية الكاملة ───────────────────────────────────────────
    TabOps.Order = TabOps.Order + 1
    local Container = Instance.new("Frame", TabOps.Page)
    Container.LayoutOrder = TabOps.Order
    Container.Size = UDim2.new(0.98, 0, 0, 45)
    Container.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    Container.BorderSizePixel = 0
    Container.ClipsDescendants = true
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 8)

    -- ── منطقة السهم (يسار الهيدر) — تفتح/تغلق ─────────────────
    local DropBtn = Instance.new("TextButton", Container)
    DropBtn.Size = UDim2.new(1, -60, 0, 45)
    DropBtn.Position = UDim2.new(0, 0, 0, 0)
    DropBtn.BackgroundTransparency = 1
    DropBtn.Text = ""
    DropBtn.AutoButtonColor = false
    DropBtn.ZIndex = 2

    -- السهم
    local Arrow = Instance.new("TextLabel", DropBtn)
    Arrow.Size = UDim2.new(0, 24, 0, 45)
    Arrow.Position = UDim2.new(0, 8, 0, 0)
    Arrow.BackgroundTransparency = 1
    Arrow.Text = "▶"
    Arrow.TextColor3 = Color3.fromRGB(100, 100, 120)
    Arrow.Font = Enum.Font.GothamBold
    Arrow.TextSize = 10

    -- اسم الميزة
    local NameLbl = Instance.new("TextLabel", DropBtn)
    NameLbl.Size = UDim2.new(1, -36, 0, 45)
    NameLbl.Position = UDim2.new(0, 34, 0, 0)
    NameLbl.BackgroundTransparency = 1
    NameLbl.Text = label
    NameLbl.TextColor3 = Color3.new(1, 1, 1)
    NameLbl.Font = Enum.Font.GothamSemibold
    NameLbl.TextSize = 11
    NameLbl.TextXAlignment = Enum.TextXAlignment.Right
    NameLbl.TextWrapped = false

    -- ── زر التشغيل الرئيسي (يمين الهيدر) ───────────────────────
    local ToggleZone = Instance.new("TextButton", Container)
    ToggleZone.Size = UDim2.new(0, 60, 0, 45)
    ToggleZone.Position = UDim2.new(1, -60, 0, 0)
    ToggleZone.BackgroundTransparency = 1
    ToggleZone.Text = ""
    ToggleZone.AutoButtonColor = false
    ToggleZone.ZIndex = 3

    local Pill = Instance.new("Frame", ToggleZone)
    Pill.Size = UDim2.new(0, 45, 0, 22)
    Pill.Position = UDim2.new(0.5, -22, 0.5, -11)
    Pill.BackgroundColor3 = isActive and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(55, 55, 60)
    Pill.BorderSizePixel = 0
    Instance.new("UICorner", Pill).CornerRadius = UDim.new(1, 0)

    -- خط فاصل (يظهر لما يفتح)
    local Divider = Instance.new("Frame", Container)
    Divider.Size = UDim2.new(0.9, 0, 0, 1)
    Divider.Position = UDim2.new(0.05, 0, 0, 45)
    Divider.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    Divider.BorderSizePixel = 0
    Divider.BackgroundTransparency = 1

    -- ── منطقة الإعدادات الداخلية ─────────────────────────────────
    local Inner = Instance.new("Frame", Container)
    Inner.Position = UDim2.new(0, 6, 0, 52)
    Inner.Size = UDim2.new(1, -12, 0, 0)
    Inner.BackgroundTransparency = 1

    local InnerLayout = Instance.new("UIListLayout", Inner)
    InnerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    InnerLayout.Padding = UDim.new(0, 6)
    InnerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local InnerPad = Instance.new("UIPadding", Inner)
    InnerPad.PaddingBottom = UDim.new(0, 8)

    -- طبقة الحجب — تمنع التفاعل مع الإعدادات الداخلية لما تكون الميزة معطلة
    local BlockLayer = Instance.new("TextButton", Container)
    BlockLayer.Size = UDim2.new(1, 0, 1, -46)
    BlockLayer.Position = UDim2.new(0, 0, 0, 46)
    BlockLayer.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
    BlockLayer.BackgroundTransparency = 0.35
    BlockLayer.Text = "🔒  فعّل الميزة أولاً"
    BlockLayer.TextColor3 = Color3.fromRGB(160, 160, 180)
    BlockLayer.Font = Enum.Font.Gotham
    BlockLayer.TextSize = 11
    BlockLayer.BorderSizePixel = 0
    BlockLayer.AutoButtonColor = false
    BlockLayer.ZIndex = 6
    BlockLayer.Visible = not isActive

    -- ── تحديث الحجم ──────────────────────────────────────────────
    local function UpdateSize()
        local contentH = InnerLayout.AbsoluteContentSize.Y
        if isOpen then
            local totalH = 46 + 8 + contentH + 12
            tween(Container, {Size = UDim2.new(0.98, 0, 0, totalH)}, 0.25)
            tween(Arrow, {Rotation = 90, TextColor3 = Color3.fromRGB(0, 210, 110)}, 0.2)
            tween(Divider, {BackgroundTransparency = 0.4}, 0.2)
            Inner.Size = UDim2.new(1, -12, 0, contentH + 14)
            BlockLayer.Size = UDim2.new(1, 0, 1, -47)
        else
            tween(Container, {Size = UDim2.new(0.98, 0, 0, 45)}, 0.22)
            tween(Arrow, {Rotation = 0, TextColor3 = Color3.fromRGB(100, 100, 120)}, 0.2)
            tween(Divider, {BackgroundTransparency = 1}, 0.15)
        end
    end

    InnerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if isOpen then UpdateSize() end
    end)

    -- ── منطق التشغيل الرئيسي ─────────────────────────────────────
    local function setActive(state, isClick)
        isActive = state
        tween(Pill, {BackgroundColor3 = isActive and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(55, 55, 60)}, 0.2)
        BlockLayer.Visible = not isActive
        if TabOps.UI and TabOps.UI.ConfigData then
            TabOps.UI.ConfigData[configKey] = isActive
        end
        pcall(mainCallback, isActive)
        if isClick and TabOps.LogAction then
            TabOps.LogAction("⚙️ تفعيل/إيقاف", label, isActive and "مفعل ✅" or "معطل ❌", isActive and 5763719 or 15548997)
        end
    end

    -- ── ضغطة السهم → فتح/غلق ─────────────────────────────────────
    DropBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        UpdateSize()
    end)

    -- ── ضغطة زر التشغيل ──────────────────────────────────────────
    ToggleZone.MouseButton1Click:Connect(function()
        setActive(not isActive, true)
    end)

    -- هوفر على منطقة السهم
    DropBtn.MouseEnter:Connect(function()
        tween(Container, {BackgroundColor3 = Color3.fromRGB(26, 26, 33)}, 0.15)
    end)
    DropBtn.MouseLeave:Connect(function()
        tween(Container, {BackgroundColor3 = Color3.fromRGB(22, 22, 28)}, 0.15)
    end)

    -- تطبيق الحالة المحفوظة
    Pill.BackgroundColor3 = isActive and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(55, 55, 60)
    if isActive then
        task.spawn(function() task.wait(1.5); pcall(mainCallback, isActive) end)
    end

    -- ── كائن الـ DropTab (يعمل مثل TabOps عشان تضيف عناصر داخله) ─
    local DropTab = setmetatable({
        Page     = Inner,
        Order    = 0,
        TabName  = TabOps.TabName .. "_dd_" .. label,
        LogAction = TabOps.LogAction,
        UI       = TabOps.UI,

        SetActive = function(state) setActive(state, false) end,
        OpenDropdown  = function() isOpen = true;  UpdateSize() end,
        CloseDropdown = function() isOpen = false; UpdateSize() end,
    }, { __index = TabOps })

    return DropTab
end
