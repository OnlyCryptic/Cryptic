-- [[ Cryptic Hub - UI Element: Open (V2 - Enhanced Design) ]]

return function(TabRef, title, icon)
    TabRef.Order = TabRef.Order + 1
    icon = icon or "📂"

    local TweenService = game:GetService("TweenService")
    local isOpen = false

    local function tween(obj, props, t, style, dir)
        TweenService:Create(
            obj,
            TweenInfo.new(t or 0.25, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out),
            props
        ):Play()
    end

    -- ══════════════════════════════════════════
    -- الإطار الخارجي
    -- ══════════════════════════════════════════
    local Container = Instance.new("Frame", TabRef.Page)
    Container.LayoutOrder = TabRef.Order
    Container.Size = UDim2.new(0.97, 0, 0, 52)
    Container.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    Container.ClipsDescendants = true
    Container.BorderSizePixel = 0
    local ContCorner = Instance.new("UICorner", Container)
    ContCorner.CornerRadius = UDim.new(0, 12)

    -- ظل/توهج خارجي (محاكاة بـ stroke متدرج)
    local Stroke = Instance.new("UIStroke", Container)
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Stroke.Thickness = 1.5
    Stroke.Transparency = 0.55
    local StrokeGrad = Instance.new("UIGradient", Stroke)
    StrokeGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0,   Color3.fromRGB(0,  220, 140)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(30, 120, 255)),
        ColorSequenceKeypoint.new(1,   Color3.fromRGB(0,  220, 140)),
    }
    StrokeGrad.Rotation = 90

    -- خلفية تدرج داخلية خفية (shimmer)
    local BgGrad = Instance.new("UIGradient", Container)
    BgGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0,   Color3.fromRGB(22, 22, 30)),
        ColorSequenceKeypoint.new(1,   Color3.fromRGB(14, 14, 20)),
    }
    BgGrad.Rotation = 135

    -- ══════════════════════════════════════════
    -- الهيدر (زر الفتح)
    -- ══════════════════════════════════════════
    local Header = Instance.new("TextButton", Container)
    Header.Size = UDim2.new(1, 0, 0, 52)
    Header.BackgroundTransparency = 1
    Header.Text = ""
    Header.AutoButtonColor = false
    Header.ZIndex = 3

    -- شريط لوني على اليسار (accent bar)
    local AccentBar = Instance.new("Frame", Header)
    AccentBar.Size = UDim2.new(0, 3, 0, 26)
    AccentBar.Position = UDim2.new(0, 10, 0.5, -13)
    AccentBar.BorderSizePixel = 0
    AccentBar.BackgroundColor3 = Color3.fromRGB(0, 220, 140)
    local AccentCorner = Instance.new("UICorner", AccentBar)
    AccentCorner.CornerRadius = UDim.new(1, 0)
    local AccentGrad = Instance.new("UIGradient", AccentBar)
    AccentGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 160)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 140, 255)),
    }
    AccentGrad.Rotation = 90

    -- أيقونة القسم
    local IconLbl = Instance.new("TextLabel", Header)
    IconLbl.Size = UDim2.new(0, 30, 0, 30)
    IconLbl.Position = UDim2.new(0, 20, 0.5, -15)
    IconLbl.BackgroundTransparency = 1
    IconLbl.Text = icon
    IconLbl.TextSize = 18
    IconLbl.Font = Enum.Font.GothamBold
    IconLbl.TextXAlignment = Enum.TextXAlignment.Center
    IconLbl.ZIndex = 3

    -- اسم القسم
    local TitleLbl = Instance.new("TextLabel", Header)
    TitleLbl.Size = UDim2.new(1, -100, 1, 0)
    TitleLbl.Position = UDim2.new(0, 56, 0, 0)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text = title
    TitleLbl.TextColor3 = Color3.fromRGB(215, 215, 225)
    TitleLbl.Font = Enum.Font.GothamBold
    TitleLbl.TextSize = 13
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    TitleLbl.ZIndex = 3

    -- دائرة خلفية للسهم
    local ArrowCircle = Instance.new("Frame", Header)
    ArrowCircle.Size = UDim2.new(0, 26, 0, 26)
    ArrowCircle.Position = UDim2.new(1, -38, 0.5, -13)
    ArrowCircle.BackgroundColor3 = Color3.fromRGB(0, 200, 120)
    ArrowCircle.BackgroundTransparency = 0.75
    ArrowCircle.BorderSizePixel = 0
    local ACircleCorner = Instance.new("UICorner", ArrowCircle)
    ACircleCorner.CornerRadius = UDim.new(1, 0)
    ArrowCircle.ZIndex = 3

    -- سهم داخل الدائرة
    local Arrow = Instance.new("TextLabel", ArrowCircle)
    Arrow.Size = UDim2.new(1, 0, 1, 0)
    Arrow.BackgroundTransparency = 1
    Arrow.Text = "▶"
    Arrow.TextColor3 = Color3.fromRGB(0, 255, 150)
    Arrow.Font = Enum.Font.GothamBold
    Arrow.TextSize = 10
    Arrow.TextXAlignment = Enum.TextXAlignment.Center
    Arrow.ZIndex = 4

    -- ══════════════════════════════════════════
    -- خط فاصل
    -- ══════════════════════════════════════════
    local Divider = Instance.new("Frame", Container)
    Divider.Size = UDim2.new(0.88, 0, 0, 1)
    Divider.Position = UDim2.new(0.06, 0, 0, 52)
    Divider.BorderSizePixel = 0
    Divider.BackgroundColor3 = Color3.fromRGB(0, 200, 120)
    Divider.BackgroundTransparency = 1
    local DivCorner = Instance.new("UICorner", Divider)
    DivCorner.CornerRadius = UDim.new(1, 0)

    -- ══════════════════════════════════════════
    -- منطقة المحتوى الداخلي
    -- ══════════════════════════════════════════
    local Inner = Instance.new("Frame", Container)
    Inner.Position = UDim2.new(0, 5, 0, 58)
    Inner.Size = UDim2.new(1, -10, 0, 0)
    Inner.BackgroundTransparency = 1

    local InnerLayout = Instance.new("UIListLayout", Inner)
    InnerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    InnerLayout.Padding = UDim.new(0, 6)
    InnerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local InnerPad = Instance.new("UIPadding", Inner)
    InnerPad.PaddingBottom = UDim.new(0, 10)
    InnerPad.PaddingTop = UDim.new(0, 4)

    -- ══════════════════════════════════════════
    -- منطق الفتح والغلق
    -- ══════════════════════════════════════════
    local function UpdateSize()
        local contentH = InnerLayout.AbsoluteContentSize.Y
        if isOpen then
            local totalH = 52 + 1 + 8 + contentH + 14
            tween(Container, {Size = UDim2.new(0.97, 0, 0, totalH), BackgroundColor3 = Color3.fromRGB(20, 20, 28)}, 0.28)
            tween(Arrow, {Rotation = 90, TextColor3 = Color3.fromRGB(0, 255, 160)}, 0.22)
            tween(ArrowCircle, {BackgroundTransparency = 0.55}, 0.22)
            tween(TitleLbl, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
            tween(Divider, {BackgroundTransparency = 0.6}, 0.2)
            tween(Stroke, {Transparency = 0.25}, 0.2)
            Inner.Size = UDim2.new(1, -10, 0, contentH + 18)
        else
            tween(Container, {Size = UDim2.new(0.97, 0, 0, 52), BackgroundColor3 = Color3.fromRGB(18, 18, 24)}, 0.25)
            tween(Arrow, {Rotation = 0, TextColor3 = Color3.fromRGB(130, 130, 150)}, 0.22)
            tween(ArrowCircle, {BackgroundTransparency = 0.85}, 0.22)
            tween(TitleLbl, {TextColor3 = Color3.fromRGB(215, 215, 225)}, 0.2)
            tween(Divider, {BackgroundTransparency = 1}, 0.18)
            tween(Stroke, {Transparency = 0.55}, 0.2)
        end
    end

    InnerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if isOpen then UpdateSize() end
    end)

    -- هوفر
    Header.MouseEnter:Connect(function()
        if not isOpen then
            tween(Container, {BackgroundColor3 = Color3.fromRGB(22, 22, 30)}, 0.15)
            tween(Stroke, {Transparency = 0.35}, 0.15)
            tween(AccentBar, {BackgroundColor3 = Color3.fromRGB(0, 255, 170)}, 0.15)
        end
    end)
    Header.MouseLeave:Connect(function()
        if not isOpen then
            tween(Container, {BackgroundColor3 = Color3.fromRGB(18, 18, 24)}, 0.2)
            tween(Stroke, {Transparency = 0.55}, 0.2)
            tween(AccentBar, {BackgroundColor3 = Color3.fromRGB(0, 220, 140)}, 0.2)
        end
    end)

    Header.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        UpdateSize()
    end)

    -- ══════════════════════════════════════════
    -- كائن OpenTab
    -- ══════════════════════════════════════════
    local OpenTab = setmetatable({
        Page    = Inner,
        Order   = 0,
        TabName = (TabRef.TabName or "") .. "_" .. title,
        LogAction = TabRef.LogAction,
        UI      = TabRef.UI,

        Open = function()
            isOpen = true
            UpdateSize()
        end,
        Close = function()
            isOpen = false
            UpdateSize()
        end,
        Toggle = function()
            isOpen = not isOpen
            UpdateSize()
        end,
    }, { __index = TabRef })

    return OpenTab
end
