-- [[ Cryptic Hub - UI Element: Open ]]
-- داله تفتح/تغلق بانيل خفيف يشبه نظام الفولدر

return function(TabRef, title, icon)
    TabRef.Order = TabRef.Order + 1
    icon = icon or "📂"

    -- الإطار الخارجي
    local Container = Instance.new("Frame", TabRef.Page)
    Container.LayoutOrder = TabRef.Order
    Container.Size = UDim2.new(0.98, 0, 0, 44)
    Container.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Container.BackgroundTransparency = 0.2
    Container.ClipsDescendants = true
    local ContCorner = Instance.new("UICorner", Container)
    ContCorner.CornerRadius = UDim.new(0, 8)

    -- بوردر بتدرج
    local Stroke = Instance.new("UIStroke", Container)
    Stroke.Thickness = 1.2
    Stroke.Transparency = 0.4
    local StrokeGrad = Instance.new("UIGradient", Stroke)
    StrokeGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 150)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 150, 255))
    }

    -- هيدر زر الفتح
    local Header = Instance.new("TextButton", Container)
    Header.Size = UDim2.new(1, 0, 0, 44)
    Header.BackgroundTransparency = 1
    Header.Text = ""
    Header.AutoButtonColor = false

    -- أيقونة السهم
    local Arrow = Instance.new("TextLabel", Header)
    Arrow.Size = UDim2.new(0, 24, 0, 24)
    Arrow.Position = UDim2.new(1, -32, 0.5, -12)
    Arrow.BackgroundTransparency = 1
    Arrow.Text = "▶"
    Arrow.TextColor3 = Color3.fromRGB(0, 255, 150)
    Arrow.Font = Enum.Font.GothamBold
    Arrow.TextSize = 12

    -- أيقونة + اسم الداله
    local TitleLbl = Instance.new("TextLabel", Header)
    TitleLbl.Size = UDim2.new(1, -50, 1, 0)
    TitleLbl.Position = UDim2.new(0, 12, 0, 0)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text = icon .. "  " .. title
    TitleLbl.TextColor3 = Color3.fromRGB(220, 220, 220)
    TitleLbl.Font = Enum.Font.GothamBold
    TitleLbl.TextSize = 12
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left

    -- خط فاصل تحت الهيدر (يظهر لما يفتح)
    local Divider = Instance.new("Frame", Container)
    Divider.Size = UDim2.new(0.9, 0, 0, 1)
    Divider.Position = UDim2.new(0.05, 0, 0, 44)
    Divider.BorderSizePixel = 0
    Divider.BackgroundTransparency = 1
    local DivGrad = Instance.new("UIGradient", Divider)
    DivGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 150)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 150, 255))
    }

    -- منطقة المحتوى الداخلي
    local Inner = Instance.new("Frame", Container)
    Inner.Position = UDim2.new(0, 6, 0, 50)
    Inner.Size = UDim2.new(1, -12, 0, 0)
    Inner.BackgroundTransparency = 1

    local InnerLayout = Instance.new("UIListLayout", Inner)
    InnerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    InnerLayout.Padding = UDim.new(0, 7)
    InnerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local InnerPad = Instance.new("UIPadding", Inner)
    InnerPad.PaddingBottom = UDim.new(0, 8)

    -- منطق الفتح والغلق
    local isOpen = false
    local TweenService = game:GetService("TweenService")

    local function tween(obj, props, t)
        TweenService:Create(obj, TweenInfo.new(t or 0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
    end

    local function UpdateSize()
        local contentH = InnerLayout.AbsoluteContentSize.Y
        if isOpen then
            local totalH = 44 + 1 + 8 + contentH + 8
            tween(Container, {Size = UDim2.new(0.98, 0, 0, totalH)}, 0.25)
            tween(Arrow, {TextColor3 = Color3.fromRGB(0, 255, 150), Rotation = 90}, 0.2)
            tween(TitleLbl, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
            tween(Divider, {BackgroundTransparency = 0.5}, 0.2)
            Inner.Size = UDim2.new(1, -12, 0, contentH + 16)
        else
            tween(Container, {Size = UDim2.new(0.98, 0, 0, 44)}, 0.22)
            tween(Arrow, {TextColor3 = Color3.fromRGB(120, 120, 120), Rotation = 0}, 0.2)
            tween(TitleLbl, {TextColor3 = Color3.fromRGB(220, 220, 220)}, 0.2)
            tween(Divider, {BackgroundTransparency = 1}, 0.15)
        end
    end

    -- تحديث الحجم لما يتغير المحتوى الداخلي
    InnerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if isOpen then UpdateSize() end
    end)

    -- هوفر
    Header.MouseEnter:Connect(function()
        if not isOpen then
            tween(Container, {BackgroundColor3 = Color3.fromRGB(25, 25, 32)}, 0.15)
        end
    end)
    Header.MouseLeave:Connect(function()
        tween(Container, {BackgroundColor3 = Color3.fromRGB(20, 20, 25)}, 0.15)
    end)

    -- ضغطة الفتح/الغلق
    Header.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        UpdateSize()
    end)

    -- كائن الداله يشتغل مثل TabOps عشان تضيف عناصر فيه
    local OpenTab = setmetatable({
        Page = Inner,
        Order = 0,
        TabName = TabRef.TabName .. "_" .. title,
        LogAction = TabRef.LogAction,
        UI = TabRef.UI,

        -- دوال للتحكم من الخارج
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
        end
    }, {
        __index = TabRef
    })

    return OpenTab
end
