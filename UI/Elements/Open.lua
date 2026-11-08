-- [[ Cryptic Hub - UI Element: Open (V2 API + V3 Design) ]]
-- نفس شكل v3 (كرت + شريط ملون + أيقونة داخل مربع + سهم + هوفر) 
-- مع الحفاظ على كل شي في v2:
--   * نفس التوقيع:  Open(TabRef, title, icon)
--   * نفس الأوامر:  Open() / Close() / Toggle()   (تشتغل بنقطة أو نقطتين)
--   * TabName = TabRef.TabName .. "_" .. title
--   * metatable __index = TabRef (أي شي بالتاب الأصلي يوصله)
--   * Page / Order / LogAction / UI
-- إضافات من v3 (ما تأثر على أي ملف): SetOpen / IsOpen / Accent / ثيم احتياطي / لون حسب العنوان

-- تحكم البيسي (إضافة): 
--   كليك يسار = فتح/غلق | Shift + كليك = افتح هذا واقفل الباقي
--   كليك يمين = افتح/اقفل كل أقسام نفس التاب | Enter وانت واقف بالماوس عليه = فتح/غلق
-- كلها تشتغل بدون ما تغير أي شي بالملفات الثانية. الجوال يظل نفس الشي (لمس عادي).
local Registry = setmetatable({}, { __mode = "k" }) -- الأقسام حسب التاب

return function(TabRef, title, icon)
    local TweenService = game:GetService("TweenService")
    local isTouch = game:GetService("UserInputService").TouchEnabled

    local UI = TabRef.UI or {}
    local THEME = UI.Theme or {
        BgChip = Color3.fromRGB(22, 25, 34), Stroke = Color3.fromRGB(35, 38, 50),
        Text = Color3.fromRGB(235, 238, 245), TextDim = Color3.fromRGB(160, 165, 180),
        AccentA = Color3.fromRGB(0, 255, 150),
    }

    local function New(class, parent, props)
        local inst = Instance.new(class)
        for k, v in pairs(props or {}) do inst[k] = v end
        inst.Parent = parent
        return inst
    end

    local function unscaled(px)
        if UI.GetUnscaledLayoutHeight then return UI.GetUnscaledLayoutHeight(px) end
        return px
    end

    title = tostring(title or "Section")
    icon = icon or "📂"
    local accent = (UI.AccentFor and UI.AccentFor(title)) or THEME.AccentA
    local HEAD_H = isTouch and 54 or 48

    TabRef.Order = TabRef.Order + 1

    -- ══════════════════════════════════════════
    -- الكرت
    -- ══════════════════════════════════════════
    local Card = New("Frame", TabRef.Page, {
        Name = "OpenSection_" .. title,
        LayoutOrder = TabRef.Order,
        Size = UDim2.new(0.98, 0, 0, HEAD_H),
        BackgroundColor3 = THEME.BgChip,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    })
    New("UICorner", Card, { CornerRadius = UDim.new(0, 12) })
    local cardStroke = New("UIStroke", Card, { Thickness = 1, Color = THEME.Stroke, Transparency = 0.3 })

    -- الشريط الملون + مربع الأيقونة + العنوان + السهم
    local Strip = New("Frame", Card, {
        Size = UDim2.new(0, 3, 0, HEAD_H - 24), Position = UDim2.new(0, 0, 0, 12),
        BackgroundColor3 = accent, BorderSizePixel = 0,
    })
    New("UICorner", Strip, { CornerRadius = UDim.new(0, 2) })

    local IconChip = New("Frame", Card, {
        Size = UDim2.new(0, 32, 0, 32), Position = UDim2.new(0, 14, 0, (HEAD_H - 32) / 2),
        BackgroundColor3 = accent:Lerp(Color3.new(0, 0, 0), 0.7), BorderSizePixel = 0,
    })
    New("UICorner", IconChip, { CornerRadius = UDim.new(0, 9) })
    New("UIStroke", IconChip, { Thickness = 1, Color = accent, Transparency = 0.6 })
    New("TextLabel", IconChip, {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = tostring(icon),
        TextSize = 17, Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1),
    })

    New("TextLabel", Card, {
        Position = UDim2.new(0, 56, 0, 0), Size = UDim2.new(1, -100, 0, HEAD_H), BackgroundTransparency = 1,
        Text = title, TextColor3 = THEME.Text, Font = Enum.Font.GothamBold, TextSize = isTouch and 15 or 14,
        TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
    })

    local Chevron = New("TextLabel", Card, {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(1, -24, 0, HEAD_H / 2), Size = UDim2.new(0, 22, 0, 22),
        BackgroundTransparency = 1, Text = "▼", TextSize = 11, Font = Enum.Font.GothamBold, TextColor3 = accent,
    })

    local Divider = New("Frame", Card, {
        Position = UDim2.new(0.04, 0, 0, HEAD_H), Size = UDim2.new(0.92, 0, 0, 1),
        BackgroundColor3 = THEME.Stroke, BackgroundTransparency = 1, BorderSizePixel = 0,
    })

    -- ══════════════════════════════════════════
    -- المحتوى الداخلي (هذا هو Page حق التاب الفرعي)
    -- ══════════════════════════════════════════
    local Inner = New("Frame", Card, {
        Name = "Body", Position = UDim2.new(0, 0, 0, HEAD_H + 8), Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1, BorderSizePixel = 0,
    })
    local InnerLayout = New("UIListLayout", Inner, {
        Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
    })

    -- ══════════════════════════════════════════
    -- منطق الفتح والغلق
    -- ══════════════════════════════════════════
    local isOpen = false
    local currentTween

    local function targetHeight()
        if not isOpen then return HEAD_H end
        return HEAD_H + 8 + unscaled(InnerLayout.AbsoluteContentSize.Y) + 14
    end

    local function refresh(animate)
        if currentTween then currentTween:Cancel(); currentTween = nil end
        local size = UDim2.new(Card.Size.X.Scale, Card.Size.X.Offset, 0, targetHeight())
        if animate then
            currentTween = TweenService:Create(Card, TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = size })
            currentTween:Play()
        else
            Card.Size = size
        end
    end

    InnerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if isOpen then refresh(false) end
    end)

    if UI.ResponsiveScale then
        UI.ResponsiveScale:GetPropertyChangedSignal("Scale"):Connect(function()
            task.defer(function() if isOpen then refresh(false) end end)
        end)
    end

    local function setOpen(state, animate)
        isOpen = state and true or false
        TweenService:Create(Chevron, TweenInfo.new(0.2, Enum.EasingStyle.Quad), { Rotation = isOpen and 180 or 0 }):Play()
        TweenService:Create(Divider, TweenInfo.new(0.2), { BackgroundTransparency = isOpen and 0.5 or 1 }):Play()
        TweenService:Create(cardStroke, TweenInfo.new(0.2), {
            Color = isOpen and accent or THEME.Stroke, Transparency = isOpen and 0.35 or 0.3,
        }):Play()
        refresh(animate ~= false)
    end

    -- زر الهيدر + الهوفر
    local Header = New("TextButton", Card, {
        Size = UDim2.new(1, 0, 0, HEAD_H), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, ZIndex = 5,
    })
    -- ── تحكم البيسي ──
    local UserInputService = game:GetService("UserInputService")
    local hovering = false

    local siblings = Registry[TabRef.Page]
    if not siblings then
        siblings = {}
        Registry[TabRef.Page] = siblings
    end
    local me = { set = setOpen, isOpen = function() return isOpen end }
    table.insert(siblings, me)

    local function setAll(state)
        for _, s in ipairs(siblings) do s.set(state, true) end
    end
    local function openOnlyMe()
        for _, s in ipairs(siblings) do s.set(s == me, true) end
    end
    local function shiftDown()
        return UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
            or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
    end

    Header.MouseEnter:Connect(function()
        hovering = true
        TweenService:Create(Card, TweenInfo.new(0.12), { BackgroundTransparency = 0.15 }):Play()
    end)
    Header.MouseLeave:Connect(function()
        hovering = false
        TweenService:Create(Card, TweenInfo.new(0.15), { BackgroundTransparency = 0.3 }):Play()
    end)

    -- إحساس الضغط
    if not isTouch then
        Header.MouseButton1Down:Connect(function()
            TweenService:Create(Card, TweenInfo.new(0.08), { BackgroundTransparency = 0.05 }):Play()
        end)
        Header.MouseButton1Up:Connect(function()
            TweenService:Create(Card, TweenInfo.new(0.12), { BackgroundTransparency = hovering and 0.15 or 0.3 }):Play()
        end)
    end

    Header.MouseButton1Click:Connect(function()
        if not isTouch and shiftDown() then
            openOnlyMe()
        else
            setOpen(not isOpen, true)
        end
    end)

    -- كليك يمين: افتح/اقفل الكل
    Header.MouseButton2Click:Connect(function()
        setAll(not isOpen)
    end)

    -- Enter وهو واقف بالماوس على الهيدر
    local keyConn = UserInputService.InputBegan:Connect(function(input, processed)
        if processed or not hovering then return end
        if input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.KeypadEnter then
            setOpen(not isOpen, true)
        end
    end)

    -- تنظيف لو انحذف الكرت
    Card.Destroying:Connect(function()
        keyConn:Disconnect()
        for i, s in ipairs(siblings) do
            if s == me then table.remove(siblings, i) break end
        end
        if #siblings == 0 then Registry[TabRef.Page] = nil end
    end)

    -- ══════════════════════════════════════════
    -- كائن OpenTab (نفس v2 + إضافات v3)
    -- ══════════════════════════════════════════
    local OpenTab = setmetatable({
        Page    = Inner,
        Order   = 0,
        TabName = (TabRef.TabName or "") .. "_" .. title,
        LogAction = TabRef.LogAction,
        UI      = TabRef.UI,

        -- من v3 (إضافات فقط)
        Accent         = accent,
        _IsOpenSection = true,

        -- من v2 (نفس السلوك، تشتغل بنقطة أو نقطتين)
        Open = function()
            setOpen(true, true)
        end,
        Close = function()
            setOpen(false, true)
        end,
        Toggle = function()
            setOpen(not isOpen, true)
        end,
    }, { __index = TabRef })

    -- من v3
    function OpenTab:SetOpen(state) setOpen(state, true) end
    function OpenTab:IsOpen() return isOpen end

    return OpenTab
end
