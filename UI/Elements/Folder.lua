-- [[ Cryptic Hub - UI Element: Folder ]]
return function(TabRef, title)
    TabRef.Order = TabRef.Order + 1

    local TweenService = game:GetService("TweenService")
    local isRTL = false
    pcall(function()
        local env = getgenv and getgenv()
        local i18n = env and env.CrypticI18n
        local meta = i18n and i18n.GetMeta and i18n.GetMeta()
        isRTL = meta ~= nil and meta.dir == "rtl"
    end)

    local isOpen = false
    local headerHeight = 52
    local containerWidth = 0.97

    local function tween(obj, props, duration)
        TweenService:Create(
            obj,
            TweenInfo.new(duration or 0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
            props
        ):Play()
    end

    -- Match the dark, rounded expandable card used by the Building section.
    local FolderContainer = Instance.new("Frame", TabRef.Page)
    FolderContainer.LayoutOrder = TabRef.Order
    FolderContainer.Size = UDim2.new(containerWidth, 0, 0, headerHeight)
    FolderContainer.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    FolderContainer.BorderSizePixel = 0
    FolderContainer.ClipsDescendants = true
    Instance.new("UICorner", FolderContainer).CornerRadius = UDim.new(0, 12)

    local Border = Instance.new("UIStroke", FolderContainer)
    Border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Border.Thickness = 1.5
    Border.Transparency = 0.55
    local BorderGradient = Instance.new("UIGradient", Border)
    BorderGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 220, 140)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(30, 120, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 220, 140)),
    }
    BorderGradient.Rotation = 90

    local BackgroundGradient = Instance.new("UIGradient", FolderContainer)
    BackgroundGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(22, 22, 30)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(14, 14, 20)),
    }
    BackgroundGradient.Rotation = 135

    local HeaderBtn = Instance.new("TextButton", FolderContainer)
    HeaderBtn.Size = UDim2.new(1, 0, 0, headerHeight)
    HeaderBtn.BackgroundTransparency = 1
    HeaderBtn.Text = ""
    HeaderBtn.AutoButtonColor = false
    HeaderBtn.ZIndex = 3

    local AccentBar = Instance.new("Frame", HeaderBtn)
    AccentBar.Size = UDim2.new(0, 3, 0, 26)
    AccentBar.Position = UDim2.new(0, 10, 0.5, -13)
    AccentBar.BorderSizePixel = 0
    AccentBar.BackgroundColor3 = Color3.fromRGB(0, 220, 140)
    Instance.new("UICorner", AccentBar).CornerRadius = UDim.new(1, 0)
    local AccentGradient = Instance.new("UIGradient", AccentBar)
    AccentGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 160)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 140, 255)),
    }
    AccentGradient.Rotation = 90

    local TitleLbl = Instance.new("TextLabel", HeaderBtn)
    TitleLbl.Size = UDim2.new(1, -88, 1, 0)
    TitleLbl.Position = UDim2.new(0, 40, 0, 0)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text = title
    TitleLbl.TextColor3 = Color3.fromRGB(215, 215, 225)
    TitleLbl.Font = Enum.Font.GothamBold
    TitleLbl.TextSize = 13
    TitleLbl.TextTruncate = Enum.TextTruncate.AtEnd
    TitleLbl.TextXAlignment = isRTL and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
    TitleLbl.ZIndex = 3

    local ArrowCircle = Instance.new("Frame", HeaderBtn)
    ArrowCircle.Size = UDim2.new(0, 26, 0, 26)
    ArrowCircle.Position = UDim2.new(1, -38, 0.5, -13)
    ArrowCircle.BackgroundColor3 = Color3.fromRGB(0, 200, 120)
    ArrowCircle.BackgroundTransparency = 0.75
    ArrowCircle.BorderSizePixel = 0
    Instance.new("UICorner", ArrowCircle).CornerRadius = UDim.new(1, 0)
    ArrowCircle.ZIndex = 3

    local Arrow = Instance.new("TextLabel", ArrowCircle)
    Arrow.Size = UDim2.new(1, 0, 1, 0)
    Arrow.BackgroundTransparency = 1
    Arrow.Text = "▶"
    Arrow.TextColor3 = Color3.fromRGB(0, 255, 150)
    Arrow.Font = Enum.Font.GothamBold
    Arrow.TextSize = 10
    Arrow.TextXAlignment = Enum.TextXAlignment.Center
    Arrow.ZIndex = 4

    local Divider = Instance.new("Frame", FolderContainer)
    Divider.Size = UDim2.new(0.88, 0, 0, 1)
    Divider.Position = UDim2.new(0.06, 0, 0, headerHeight)
    Divider.BorderSizePixel = 0
    Divider.BackgroundColor3 = Color3.fromRGB(0, 200, 120)
    Divider.BackgroundTransparency = 1
    Instance.new("UICorner", Divider).CornerRadius = UDim.new(1, 0)

    local InnerPage = Instance.new("Frame", FolderContainer)
    InnerPage.Position = UDim2.new(0, 5, 0, headerHeight + 6)
    InnerPage.Size = UDim2.new(1, -10, 0, 0)
    InnerPage.BackgroundTransparency = 1

    local InnerLayout = Instance.new("UIListLayout", InnerPage)
    InnerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    InnerLayout.Padding = UDim.new(0, 6)
    InnerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local InnerPadding = Instance.new("UIPadding", InnerPage)
    InnerPadding.PaddingTop = UDim.new(0, 4)
    InnerPadding.PaddingBottom = UDim.new(0, 10)

    local function UpdateSize()
        local contentHeight = TabRef.UI and TabRef.UI.GetUnscaledLayoutHeight
            and TabRef.UI.GetUnscaledLayoutHeight(InnerLayout.AbsoluteContentSize.Y)
            or InnerLayout.AbsoluteContentSize.Y

        if isOpen then
            local totalHeight = headerHeight + 1 + 8 + contentHeight + 14
            tween(FolderContainer, {
                Size = UDim2.new(containerWidth, 0, 0, totalHeight),
                BackgroundColor3 = Color3.fromRGB(20, 20, 28),
            }, 0.28)
            tween(Arrow, {
                Rotation = 90,
                TextColor3 = Color3.fromRGB(0, 255, 160),
            }, 0.22)
            tween(ArrowCircle, {BackgroundTransparency = 0.55}, 0.22)
            tween(TitleLbl, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
            tween(Divider, {BackgroundTransparency = 0.6}, 0.2)
            tween(Border, {Transparency = 0.25}, 0.2)
            tween(AccentBar, {Size = UDim2.new(0, 4, 0, 30)}, 0.2)
            InnerPage.Size = UDim2.new(1, -10, 0, contentHeight + 18)
        else
            tween(FolderContainer, {
                Size = UDim2.new(containerWidth, 0, 0, headerHeight),
                BackgroundColor3 = Color3.fromRGB(18, 18, 24),
            }, 0.25)
            tween(Arrow, {
                Rotation = 0,
                TextColor3 = Color3.fromRGB(130, 130, 150),
            }, 0.22)
            tween(ArrowCircle, {BackgroundTransparency = 0.85}, 0.22)
            tween(TitleLbl, {TextColor3 = Color3.fromRGB(215, 215, 225)}, 0.2)
            tween(Divider, {BackgroundTransparency = 1}, 0.18)
            tween(Border, {Transparency = 0.55}, 0.2)
            tween(AccentBar, {Size = UDim2.new(0, 3, 0, 26)}, 0.2)
            InnerPage.Size = UDim2.new(1, -10, 0, 0)
        end
    end

    HeaderBtn.Activated:Connect(function()
        isOpen = not isOpen
        UpdateSize()
    end)

    InnerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if isOpen then UpdateSize() end
    end)

    local responsiveScale = TabRef.UI and TabRef.UI.ResponsiveScale
    if responsiveScale then
        responsiveScale:GetPropertyChangedSignal("Scale"):Connect(function()
            task.defer(UpdateSize)
        end)
    end

    HeaderBtn.MouseEnter:Connect(function()
        if not isOpen then
            tween(FolderContainer, {BackgroundColor3 = Color3.fromRGB(22, 22, 30)}, 0.15)
            tween(Border, {Transparency = 0.35}, 0.15)
            tween(AccentBar, {BackgroundColor3 = Color3.fromRGB(0, 255, 170)}, 0.15)
        end
    end)
    HeaderBtn.MouseLeave:Connect(function()
        if not isOpen then
            tween(FolderContainer, {BackgroundColor3 = Color3.fromRGB(18, 18, 24)}, 0.2)
            tween(Border, {Transparency = 0.55}, 0.2)
            tween(AccentBar, {BackgroundColor3 = Color3.fromRGB(0, 220, 140)}, 0.2)
        end
    end)

    -- Return a nested tab-like object so existing controls keep working.
    local FolderTab = setmetatable({
        Page = InnerPage,
        Order = 0,
    }, {
        __index = TabRef,
    })

    return FolderTab
end
