-- [[ Cryptic Hub - Map: Throw Things & Players (v2) ]]
-- نفس صيغة MM2: يرجع { Name, Render(tab, UI) } ويشتغل داخل واجهة الهب
-- الأقسام: الحماية / رد الهجوم / الخط / الألعاب / الماب
-- ملاحظة: كل النصوص والرموز ASCII أو عربي فقط (بدون إيموجي أو رموز تظهر مربعات)

-- ============================================================
-- 1. الترجمة (عربي + إنجليزي)
-- ============================================================
local NEW = {
    en = {
        ["tm.hint"]            = "Tap a section to open / close it",
        ["tm.sec.def"]         = "Defense",
        ["tm.sec.counter"]     = "Counter Attack",
        ["tm.sec.line"]        = "Line",
        ["tm.sec.toys"]        = "Toys",
        ["tm.sec.map"]         = "Map",

        ["tm.anti.grab"]       = "Anti Grab",
        ["tm.anti.grab.type"]  = "Anti Grab type",
        ["tm.anti.normal"]     = "Normal",
        ["tm.anti.strong"]     = "Strong (no ragdoll)",
        ["tm.anti.explosion"]  = "Anti Explosion",
        ["tm.anti.burn"]       = "Anti Burn",
        ["tm.anti.sticky"]     = "Anti Sticky",
        ["tm.anti.paint"]      = "Anti Paint",
        ["tm.anti.poison"]     = "Anti Poison",
        ["tm.anti.void"]       = "Anti Void",
        ["tm.anti.invis"]      = "Anti Invis",
        ["tm.anti.lag"]        = "Anti Lag (hide lines and sticky lag)",
        ["tm.noremote"]        = "Remote not found: %s",

        ["tm.ca.enable"]       = "Counter Attack",
        ["tm.ca.mode"]         = "When someone grabs you",
        ["tm.ca.notify"]       = "Only notify me",
        ["tm.ca.grabback"]     = "Grab them back",
        ["tm.ca.escape"]       = "Escape to safe spot",
        ["tm.ca.last"]         = "Last person who grabbed you: %s",
        ["tm.ca.nobody"]       = "nobody",
        ["tm.ca.grabbed"]      = "%s grabbed you",

        ["tm.line.extend"]     = "Extend Line",
        ["tm.line.speed"]      = "Extend speed",
        ["tm.line.strength.on"] = "Super Strength (throw power)",
        ["tm.line.strength"]   = "Strength",
        ["tm.line.texture"]    = "Line texture",
        ["tm.line.texture.on"] = "Use custom line texture",
        ["tm.line.info"]       = "Grabbed object information",
        ["tm.line.holding"]    = "Holding: %s",

        ["tm.toys.pick"]       = "Toy",
        ["tm.toys.amount"]     = "Amount",
        ["tm.toys.spawn"]      = "Spawn",
        ["tm.toys.clear"]      = "Delete My Toys",
        ["tm.toys.count"]      = "Your toys: %d",
        ["tm.toys.cleared"]    = "Deleted %d toys",

        ["tm.map.point"]       = "Location",
        ["tm.map.go"]          = "Teleport",
        ["tm.map.none"]        = "No locations on this map",
        ["tm.nochar"]          = "Character not ready",
    },
    ar = {
        ["tm.hint"]            = "اضغط على القسم لفتحه أو إغلاقه",
        ["tm.sec.def"]         = "الحماية",
        ["tm.sec.counter"]     = "رد الهجوم",
        ["tm.sec.line"]        = "الخط",
        ["tm.sec.toys"]        = "الألعاب",
        ["tm.sec.map"]         = "الماب",

        ["tm.anti.grab"]       = "منع الإمساك",
        ["tm.anti.grab.type"]  = "نوع منع الإمساك",
        ["tm.anti.normal"]     = "عادي",
        ["tm.anti.strong"]     = "قوي (بدون سقوط)",
        ["tm.anti.explosion"]  = "منع الانفجار",
        ["tm.anti.burn"]       = "منع الحرق",
        ["tm.anti.sticky"]     = "منع اللزق",
        ["tm.anti.paint"]      = "منع الصبغ",
        ["tm.anti.poison"]     = "منع السم",
        ["tm.anti.void"]       = "منع السقوط للفراغ",
        ["tm.anti.invis"]      = "كشف المخفيين",
        ["tm.anti.lag"]        = "منع اللاق (إخفاء الخطوط ولاق اللزق)",
        ["tm.noremote"]        = "ما لقيت الريموت: %s",

        ["tm.ca.enable"]       = "رد الهجوم",
        ["tm.ca.mode"]         = "لما أحد يمسكك",
        ["tm.ca.notify"]       = "نبهني فقط",
        ["tm.ca.grabback"]     = "امسكه بالمقابل",
        ["tm.ca.escape"]       = "اهرب لمكان آمن",
        ["tm.ca.last"]         = "آخر شخص أمسكك: %s",
        ["tm.ca.nobody"]       = "ما أحد",
        ["tm.ca.grabbed"]      = "%s أمسكك",

        ["tm.line.extend"]     = "تطويل الخط",
        ["tm.line.speed"]      = "سرعة التطويل",
        ["tm.line.strength.on"] = "قوة خارقة (قوة الرمي)",
        ["tm.line.strength"]   = "القوة",
        ["tm.line.texture"]    = "شكل الخط",
        ["tm.line.texture.on"] = "تفعيل شكل الخط المخصص",
        ["tm.line.info"]       = "معلومات الشيء الممسوك",
        ["tm.line.holding"]    = "ماسك: %s",

        ["tm.toys.pick"]       = "اللعبة",
        ["tm.toys.amount"]     = "العدد",
        ["tm.toys.spawn"]      = "إنشاء",
        ["tm.toys.clear"]      = "حذف ألعابي",
        ["tm.toys.count"]      = "ألعابك: %d",
        ["tm.toys.cleared"]    = "تم حذف %d لعبة",

        ["tm.map.point"]       = "المكان",
        ["tm.map.go"]          = "انتقال",
        ["tm.map.none"]        = "ما في أماكن في هذا الماب",
        ["tm.nochar"]          = "الشخصية غير جاهزة",
    },
}

local function RegisterTranslations()
    local i18n = getgenv().CrypticI18n
    if not i18n or not i18n.Register then return end
    for lang, t in pairs(NEW) do pcall(i18n.Register, lang, t) end
end

-- ============================================================
-- 2. الواجهة والمنطق
-- ============================================================
local function Render(tab, UI)
    RegisterTranslations()

    -- ── إدارة التشغيل المتكرر (نفس MM2_RunId) ──
    getgenv().TM_RunId = (getgenv().TM_RunId or 0) + 1
    local RUN = getgenv().TM_RunId
    local function Alive() return getgenv().TM_RunId == RUN end
    if getgenv().TM_Conns then
        for _, c in ipairs(getgenv().TM_Conns) do pcall(function() c:Disconnect() end) end
    end
    if getgenv().TM_Gui then pcall(function() getgenv().TM_Gui:Destroy() end) end
    local Conns = {}
    getgenv().TM_Conns = Conns
    local function Track(c) Conns[#Conns + 1] = c; return c end

    local i18n = getgenv().CrypticI18n
    local function TX(k)
        local s = i18n and i18n.T and i18n.T(k)
        if s == nil or s == "" or s == k then return NEW.en[k] or k end
        return s
    end
    local function TF(k, ...)
        local ok, s = pcall(string.format, TX(k), ...)
        return ok and s or TX(k)
    end

    local Players           = game:GetService("Players")
    local RunService        = game:GetService("RunService")
    local TweenService      = game:GetService("TweenService")
    local StarterGui        = game:GetService("StarterGui")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local UserInputService  = game:GetService("UserInputService")
    local ContextAction     = game:GetService("ContextActionService")
    local Debris            = game:GetService("Debris")
    local Workspace         = game:GetService("Workspace")
    local lp                = Players.LocalPlayer

    local function Notify(text, dur)
        pcall(function()
            StarterGui:SetCore("SendNotification", { Title = "Throw Map", Text = text, Duration = dur or 3 })
        end)
    end
    local function Tw(o, p, t)
        TweenService:Create(o, TweenInfo.new(t or 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), p):Play()
    end

    local C_GREEN  = Color3.fromRGB(0, 255, 150)
    local C_BLUE   = Color3.fromRGB(0, 150, 255)
    local C_RED    = Color3.fromRGB(255, 90, 90)
    local C_ORANGE = Color3.fromRGB(255, 150, 50)
    local C_CYAN   = Color3.fromRGB(0, 205, 255)
    local C_PURPLE = Color3.fromRGB(130, 150, 255)
    local DIM      = Color3.fromRGB(110, 110, 130)
    local CARD     = Color3.fromRGB(16, 16, 22)
    local TEXT     = Color3.fromRGB(215, 215, 228)
    local PAGE     = tab.Page

    -- ═════════ حاوية التمرير (نفس فكرة MM2) ═════════
    do
        local HOST = PAGE
        local sc = Instance.new("ScrollingFrame")
        sc.Name = "TMScroll"
        sc.BackgroundTransparency = 1; sc.BorderSizePixel = 0
        sc.LayoutOrder = 0; sc.Active = true
        sc.ScrollingDirection = Enum.ScrollingDirection.Y
        sc.CanvasSize = UDim2.new(0, 0, 0, 0)
        sc.AutomaticCanvasSize = Enum.AutomaticSize.Y
        sc.ScrollBarThickness = 3
        sc.ScrollBarImageColor3 = Color3.fromRGB(120, 125, 140)
        sc.Size = UDim2.new(1, 0, 0, 260)
        sc.Parent = HOST
        local ll = Instance.new("UIListLayout", sc)
        ll.SortOrder = Enum.SortOrder.LayoutOrder
        ll.Padding = UDim.new(0, 8)
        ll.HorizontalAlignment = Enum.HorizontalAlignment.Center
        local pd = Instance.new("UIPadding", sc)
        pd.PaddingBottom = UDim.new(0, 44)
        pcall(function() HOST.ScrollingEnabled = false end)

        local function fit()
            local h, scale = 0, 1
            local ok = pcall(function()
                local curH = sc.Size.Y.Offset
                if curH > 0 and sc.AbsoluteSize.Y > 0 then
                    scale = math.clamp(sc.AbsoluteSize.Y / curH, 0.2, 5)
                end
                h = HOST.AbsoluteWindowSize.Y
                local a = HOST.Parent
                while a and a:IsA("GuiObject") do
                    if a.ClipsDescendants then
                        h = math.min(h, a.AbsolutePosition.Y + a.AbsoluteSize.Y - sc.AbsolutePosition.Y)
                        break
                    end
                    a = a.Parent
                end
            end)
            if ok and h > 60 then
                h = math.floor(h / scale)
                if sc.Size.Y.Offset ~= h then sc.Size = UDim2.new(1, 0, 0, h) end
            end
        end
        local t = 0
        Track(RunService.Heartbeat:Connect(function(dt)
            t = t + dt
            if t < 0.2 then return end
            t = 0
            fit()
        end))
        task.defer(fit)
        PAGE = sc
        tab.Page = sc
    end

    -- ═════════ مكوّنات الواجهة ═════════
    local function Card(parent, h)
        tab.Order = tab.Order + 1
        local f = Instance.new("Frame", parent)
        f.LayoutOrder = tab.Order
        f.Size = UDim2.new(0.98, 0, 0, h)
        f.BackgroundColor3 = CARD; f.BackgroundTransparency = 0.08; f.BorderSizePixel = 0
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 12)
        return f
    end

    local SecOpen = getgenv().TM_SecOpen or {}
    getgenv().TM_SecOpen = SecOpen

    local function MakeSection(id, title, color, defaultOpen)
        tab.Order = tab.Order + 1
        local Hdr = Instance.new("TextButton", PAGE)
        Hdr.LayoutOrder = tab.Order; Hdr.Size = UDim2.new(0.98, 0, 0, 50)
        Hdr.BackgroundColor3 = CARD; Hdr.BackgroundTransparency = 0.08
        Hdr.BorderSizePixel = 0; Hdr.Text = ""; Hdr.AutoButtonColor = false
        Instance.new("UICorner", Hdr).CornerRadius = UDim.new(0, 12)
        local st = Instance.new("UIStroke", Hdr)
        st.Thickness = 1.3; st.Transparency = 0.55; st.Color = color

        local bar = Instance.new("Frame", Hdr)
        bar.Size = UDim2.new(0, 5, 1, -16); bar.Position = UDim2.new(0, 8, 0, 8)
        bar.BackgroundColor3 = color; bar.BorderSizePixel = 0
        Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

        local TL = Instance.new("TextLabel", Hdr)
        TL.Size = UDim2.new(1, -70, 1, 0); TL.Position = UDim2.new(0, 24, 0, 0)
        TL.BackgroundTransparency = 1; TL.Text = title
        TL.TextColor3 = Color3.fromRGB(230, 230, 242)
        TL.Font = Enum.Font.GothamBold; TL.TextSize = 13
        TL.TextXAlignment = Enum.TextXAlignment.Left
        TL.TextTruncate = Enum.TextTruncate.AtEnd

        local Arr = Instance.new("TextLabel", Hdr)
        Arr.Size = UDim2.new(0, 28, 1, 0); Arr.Position = UDim2.new(1, -38, 0, 0)
        Arr.BackgroundTransparency = 1; Arr.Text = ">"; Arr.TextColor3 = DIM
        Arr.Font = Enum.Font.GothamBlack; Arr.TextSize = 18

        tab.Order = tab.Order + 1
        local Cont = Instance.new("Frame", PAGE)
        Cont.LayoutOrder = tab.Order; Cont.Size = UDim2.new(0.98, 0, 0, 0)
        Cont.BackgroundTransparency = 1; Cont.ClipsDescendants = true
        local LL = Instance.new("UIListLayout", Cont)
        LL.SortOrder = Enum.SortOrder.LayoutOrder; LL.Padding = UDim.new(0, 6)
        LL.HorizontalAlignment = Enum.HorizontalAlignment.Center
        local pad = Instance.new("UIPadding", Cont)
        pad.PaddingTop = UDim.new(0, 4); pad.PaddingBottom = UDim.new(0, 8)

        local sec = { cont = Cont, color = color }
        local isOpen = false
        local function apply(open, animate)
            isOpen = open; SecOpen[id] = open
            Cont.AutomaticSize = open and Enum.AutomaticSize.Y or Enum.AutomaticSize.None
            Cont.Size = UDim2.new(0.98, 0, 0, 0)
            local d = animate and 0.2 or 0
            Tw(Arr, { Rotation = open and 90 or 0, TextColor3 = open and color or DIM }, d)
            Tw(st, { Transparency = open and 0.15 or 0.55 }, d)
        end
        local startOpen = SecOpen[id]
        if startOpen == nil then startOpen = defaultOpen end
        if startOpen then task.defer(function() apply(true, false) end) end
        Hdr.MouseButton1Click:Connect(function() apply(not isOpen, true) end)
        return sec
    end

    -- يدخل عناصر الهب (AddToggle) داخل القسم
    local function InSection(sec, fn)
        local before = {}
        for _, c in ipairs(PAGE:GetChildren()) do before[c] = true end
        tab.Page = sec.cont
        local ok, err = pcall(fn)
        tab.Page = PAGE
        if not ok then warn("[ThrowMap UI] " .. tostring(err)) end
        for _, c in ipairs(PAGE:GetChildren()) do
            if not before[c] and c:IsA("GuiObject") then c.Parent = sec.cont end
        end
    end

    local function Tog(sec, text, cb)
        InSection(sec, function()
            tab:AddToggle(text, function(v) cb(v and true or false) end)
        end)
    end

    local function Grid(sec, items)
        tab.Order = tab.Order + 1
        local G = Instance.new("Frame", sec.cont)
        G.LayoutOrder = tab.Order; G.Size = UDim2.new(0.98, 0, 0, 0)
        G.AutomaticSize = Enum.AutomaticSize.Y; G.BackgroundTransparency = 1
        local GL = Instance.new("UIGridLayout", G)
        GL.CellSize = UDim2.new(items[2] and 0.5 or 1, items[2] and -4 or 0, 0, 46)
        GL.CellPadding = UDim2.new(0, 8, 0, 8)
        GL.SortOrder = Enum.SortOrder.LayoutOrder
        for i, it in ipairs(items) do
            local col = it.color or sec.color
            local B = Instance.new("TextButton", G)
            B.LayoutOrder = i
            B.BackgroundColor3 = col; B.BackgroundTransparency = 0.82
            B.BorderSizePixel = 0; B.AutoButtonColor = false
            B.Text = it.text; B.TextColor3 = Color3.fromRGB(235, 235, 245)
            B.Font = Enum.Font.GothamBold; B.TextSize = 12
            B.TextWrapped = true; B.TextTruncate = Enum.TextTruncate.AtEnd
            Instance.new("UICorner", B).CornerRadius = UDim.new(0, 11)
            local s = Instance.new("UIStroke", B)
            s.Thickness = 1.3; s.Color = col; s.Transparency = 0.4
            B.MouseButton1Click:Connect(function()
                B.BackgroundTransparency = 0.3
                Tw(B, { BackgroundTransparency = 0.82 }, 0.25)
                pcall(it.fn)
            end)
        end
    end

    -- بطاقة نص (لعرض معلومات تتحدث)
    local function InfoCard(sec, text)
        local c = Card(sec.cont, 38)
        local L = Instance.new("TextLabel", c)
        L.Size = UDim2.new(1, -24, 1, 0); L.Position = UDim2.new(0, 12, 0, 0)
        L.BackgroundTransparency = 1; L.Text = text
        L.TextColor3 = DIM; L.Font = Enum.Font.GothamSemibold; L.TextSize = 12
        L.TextXAlignment = Enum.TextXAlignment.Left
        L.TextTruncate = Enum.TextTruncate.AtEnd
        return L
    end

    -- عدّاد بأزرار - / +
    local function Stepper(sec, text, minV, maxV, defaultV, step, onChange)
        local R = Card(sec.cont, 50)
        local Lbl = Instance.new("TextLabel", R)
        Lbl.Size = UDim2.new(1, -170, 1, 0); Lbl.Position = UDim2.new(0, 14, 0, 0)
        Lbl.BackgroundTransparency = 1; Lbl.Text = text
        Lbl.TextColor3 = TEXT; Lbl.Font = Enum.Font.GothamSemibold; Lbl.TextSize = 12
        Lbl.TextXAlignment = Enum.TextXAlignment.Left
        Lbl.TextTruncate = Enum.TextTruncate.AtEnd

        local val = defaultV
        local function mk(txt, x)
            local b = Instance.new("TextButton", R)
            b.Size = UDim2.new(0, 34, 0, 32); b.Position = UDim2.new(1, x, 0.5, -16)
            b.BackgroundColor3 = Color3.fromRGB(45, 45, 55); b.BorderSizePixel = 0
            b.Text = txt; b.TextColor3 = Color3.new(1, 1, 1)
            b.Font = Enum.Font.GothamBold; b.TextSize = 18; b.AutoButtonColor = false
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
            return b
        end
        local Minus, Plus = mk("-", -134), mk("+", -44)
        local V = Instance.new("TextLabel", R)
        V.Size = UDim2.new(0, 56, 1, 0); V.Position = UDim2.new(1, -96, 0, 0)
        V.BackgroundTransparency = 1; V.Text = tostring(val)
        V.TextColor3 = sec.color; V.Font = Enum.Font.GothamBold; V.TextSize = 13
        local function set(n)
            val = math.clamp(n, minV, maxV); V.Text = tostring(val); onChange(val)
        end
        Minus.MouseButton1Click:Connect(function() set(val - step) end)
        Plus.MouseButton1Click:Connect(function() set(val + step) end)
        onChange(val)
    end

    -- ═════════ دروب داون (تصميم جديد) ═════════
    -- items = { { id = "x", text = "اسم" }, ... }
    -- الرأس: عنوان على اليسار + القيمة المختارة بلون القسم على اليمين + سهم يدور
    -- القائمة: صفوف مرتبة، الصف المختار له شريط جانبي، ومنها تمرير لو كثرت الخيارات
    local openToken = 0
    local function Dropdown(sec, title, items, defaultIndex, onPick)
        tab.Order = tab.Order + 1
        local Wrap = Instance.new("Frame", sec.cont)
        Wrap.LayoutOrder = tab.Order; Wrap.Size = UDim2.new(0.98, 0, 0, 0)
        Wrap.AutomaticSize = Enum.AutomaticSize.Y; Wrap.BackgroundTransparency = 1
        local WL = Instance.new("UIListLayout", Wrap)
        WL.SortOrder = Enum.SortOrder.LayoutOrder; WL.Padding = UDim.new(0, 4)

        local Head = Instance.new("TextButton", Wrap)
        Head.LayoutOrder = 1; Head.Size = UDim2.new(1, 0, 0, 50)
        Head.BackgroundColor3 = CARD; Head.BackgroundTransparency = 0.08
        Head.BorderSizePixel = 0; Head.AutoButtonColor = false; Head.Text = ""
        Instance.new("UICorner", Head).CornerRadius = UDim.new(0, 12)
        local hs = Instance.new("UIStroke", Head)
        hs.Thickness = 1.2; hs.Transparency = 0.55; hs.Color = sec.color

        local Title = Instance.new("TextLabel", Head)
        Title.Size = UDim2.new(0.45, -14, 1, 0); Title.Position = UDim2.new(0, 14, 0, 0)
        Title.BackgroundTransparency = 1; Title.Text = title
        Title.TextColor3 = TEXT; Title.Font = Enum.Font.GothamSemibold; Title.TextSize = 12
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.TextTruncate = Enum.TextTruncate.AtEnd

        local Value = Instance.new("TextLabel", Head)
        Value.Size = UDim2.new(0.55, -46, 1, 0); Value.Position = UDim2.new(0.45, 0, 0, 0)
        Value.BackgroundTransparency = 1; Value.Text = ""
        Value.TextColor3 = sec.color; Value.Font = Enum.Font.GothamBold; Value.TextSize = 12
        Value.TextXAlignment = Enum.TextXAlignment.Right
        Value.TextTruncate = Enum.TextTruncate.AtEnd

        local Arr = Instance.new("TextLabel", Head)
        Arr.Size = UDim2.new(0, 28, 1, 0); Arr.Position = UDim2.new(1, -36, 0, 0)
        Arr.BackgroundTransparency = 1; Arr.Text = ">"; Arr.TextColor3 = DIM
        Arr.Font = Enum.Font.GothamBlack; Arr.TextSize = 16

        local List = Instance.new("Frame", Wrap)
        List.LayoutOrder = 2; List.Size = UDim2.new(1, 0, 0, 0)
        List.BackgroundColor3 = CARD; List.BackgroundTransparency = 0.05
        List.BorderSizePixel = 0; List.ClipsDescendants = true; List.Visible = false
        Instance.new("UICorner", List).CornerRadius = UDim.new(0, 12)
        local ls = Instance.new("UIStroke", List)
        ls.Thickness = 1; ls.Transparency = 0.6; ls.Color = sec.color

        local Scroll = Instance.new("ScrollingFrame", List)
        Scroll.Size = UDim2.new(1, 0, 1, 0)
        Scroll.BackgroundTransparency = 1; Scroll.BorderSizePixel = 0
        Scroll.ScrollBarThickness = 3
        Scroll.ScrollBarImageColor3 = Color3.fromRGB(120, 125, 140)
        Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        local SL = Instance.new("UIListLayout", Scroll)
        SL.SortOrder = Enum.SortOrder.LayoutOrder; SL.Padding = UDim.new(0, 3)
        local SP = Instance.new("UIPadding", Scroll)
        SP.PaddingTop = UDim.new(0, 5); SP.PaddingBottom = UDim.new(0, 5)
        SP.PaddingLeft = UDim.new(0, 5); SP.PaddingRight = UDim.new(0, 8)

        local ROW_H, MAX_ROWS = 36, 5
        local fullH = math.min(#items, MAX_ROWS) * (ROW_H + 3) + 10
        local selectedId = nil
        local rows = {}
        local open = false

        local function paint()
            for id, r in pairs(rows) do
                local sel = (id == selectedId)
                r.btn.BackgroundColor3 = sel and sec.color or Color3.fromRGB(34, 34, 46)
                r.btn.BackgroundTransparency = sel and 0.82 or 0.3
                r.btn.TextColor3 = sel and Color3.new(1, 1, 1) or Color3.fromRGB(200, 200, 215)
                r.btn.Font = sel and Enum.Font.GothamBold or Enum.Font.Gotham
                r.bar.Visible = sel
            end
        end

        local function setOpen(v)
            open = v
            openToken = openToken + 1
            local my = openToken
            Tw(Arr, { Rotation = v and 90 or 0, TextColor3 = v and sec.color or DIM }, 0.18)
            Tw(hs, { Transparency = v and 0.15 or 0.55 }, 0.18)
            if v then
                List.Visible = true
                Tw(List, { Size = UDim2.new(1, 0, 0, fullH) }, 0.18)
            else
                Tw(List, { Size = UDim2.new(1, 0, 0, 0) }, 0.16)
                task.delay(0.17, function()
                    if openToken == my and not open then List.Visible = false end
                end)
            end
        end

        local function pick(item, silent)
            selectedId = item.id
            Value.Text = item.text
            paint()
            if not silent then onPick(item.id) end
        end

        for i, item in ipairs(items) do
            local b = Instance.new("TextButton", Scroll)
            b.LayoutOrder = i; b.Size = UDim2.new(1, 0, 0, ROW_H)
            b.BorderSizePixel = 0; b.AutoButtonColor = false
            b.Text = item.text; b.TextSize = 12
            b.TextXAlignment = Enum.TextXAlignment.Left
            b.TextTruncate = Enum.TextTruncate.AtEnd
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 9)
            local pd = Instance.new("UIPadding", b)
            pd.PaddingLeft = UDim.new(0, 16)
            local bar = Instance.new("Frame", b)
            bar.Size = UDim2.new(0, 3, 1, -14); bar.Position = UDim2.new(0, -10, 0, 7)
            bar.BackgroundColor3 = sec.color; bar.BorderSizePixel = 0; bar.Visible = false
            Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
            rows[item.id] = { btn = b, bar = bar }
            b.MouseButton1Click:Connect(function()
                pick(item, false)
                setOpen(false)
            end)
        end

        Head.MouseEnter:Connect(function() Tw(Head, { BackgroundTransparency = 0 }, 0.12) end)
        Head.MouseLeave:Connect(function() Tw(Head, { BackgroundTransparency = 0.08 }, 0.12) end)
        Head.MouseButton1Click:Connect(function() setOpen(not open) end)

        local first = items[defaultIndex or 1]
        if first then pick(first, false) end   -- يضبط القيمة الافتراضية ويبلّغ الدالة
    end

    -- ═════════ الريموتات (مجلد + اسم + مهلة، مثل Resonance) ═════════
    local function FindRemote(folder, name)
        local f = ReplicatedStorage:WaitForChild(folder, 0.5)
        return f and f:WaitForChild(name, 0.5)
    end
    local Remotes = {
        Struggle        = FindRemote("CharacterEvents", "Struggle"),
        Ragdoll         = FindRemote("CharacterEvents", "RagdollRemote"),
        SetNetworkOwner = FindRemote("GrabEvents", "SetNetworkOwner"),
        SpawnToy        = FindRemote("MenuToys", "SpawnToyRemoteFunction"),
        DestroyToy      = FindRemote("MenuToys", "DestroyToy"),
    }

    -- ═════════ الحالة والمساعدات ═════════
    local State = {
        AntiGrab = false, AntiGrabType = "Normal",
        AntiExplosion = false, AntiBurn = false, AntiSticky = false,
        AntiPaint = false, AntiPoison = false, AntiVoid = false,
        AntiInvis = false, AntiLag = false,
        Counter = false, CounterMode = "Notify",
        Extend = false, ExtendSpeed = 1,
        Strength = false, StrengthValue = 400,
        TextureOn = false, Texture = "Chain 2",
        Info = false,
        ToyName = "NinjaShuriken", Amount = 1,
    }

    local function Char()
        local c = lp.Character
        if not c then return nil end
        return c, c:FindFirstChild("HumanoidRootPart"), c:FindFirstChildOfClass("Humanoid")
    end
    local function Cam() return Workspace.CurrentCamera end
    local function ToyFolder() return Workspace:FindFirstChild(lp.Name .. "SpawnedInToys") end
    local function CountToys()
        local f, n = ToyFolder(), 0
        if f then
            for _, c in ipairs(f:GetChildren()) do
                if c:IsA("Model") then n = n + 1 end
            end
        end
        return n
    end
    local function MapPath(...)
        local cur = Workspace:FindFirstChild("Map")
        for _, n in ipairs({ ... }) do
            if not cur then return nil end
            cur = cur:FindFirstChild(n)
        end
        return cur
    end

    local isHeld = lp:FindFirstChild("IsHeld")
    local safeCF = nil     -- آخر مكان آمن وقفت فيه

    -- ═════════ الحماية ═════════
    local agAcc, invAcc, lagAcc, sticAcc = 0, 0, 0, 0
    Track(RunService.Heartbeat:Connect(function(dt)
        if not Alive() then return end
        local _, root, hum = Char()

        -- حفظ المكان الآمن
        if root and hum and hum.FloorMaterial ~= Enum.Material.Air
           and root.Position.Y > -400 and root.Position.Y < 5000
           and not (isHeld and isHeld.Value) then
            safeCF = root.CFrame
        end

        -- منع الإمساك
        if State.AntiGrab and Remotes.Struggle and isHeld and isHeld.Value then
            agAcc = agAcc + dt
            if agAcc >= 1 / 30 then
                agAcc = 0
                Remotes.Struggle:FireServer()
                if State.AntiGrabType == "Strong" and root then
                    if Remotes.Ragdoll then Remotes.Ragdoll:FireServer(root, 0) end
                    root.AssemblyLinearVelocity = Vector3.zero
                    root.AssemblyAngularVelocity = Vector3.zero
                end
            end
        end

        -- منع السقوط للفراغ
        if State.AntiVoid and root then
            local y = root.Position.Y
            if y <= -500 or y >= 10000 then
                root.AssemblyLinearVelocity = Vector3.zero
                root.CFrame = safeCF or CFrame.new(0, 15, 0)
            end
        end

        -- كشف المخفيين (كل 0.1 ثانية)
        invAcc = invAcc + dt
        if State.AntiInvis and invAcc >= 0.1 then
            invAcc = 0
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= lp and p.Character then
                    local r = p.Character:FindFirstChild("HumanoidRootPart")
                    local h = p.Character:FindFirstChildOfClass("Humanoid")
                    if r then r.Massless = false end
                    if h and h.Sit and h.SeatPart then
                        local w = h.SeatPart:FindFirstChild("SeatWeld")
                        if w and not w.Enabled then w.Enabled = true end
                    end
                end
            end
        end

        -- منع اللاق: يخفي خطوط اللاعبين الثانيين (كل ثانية)
        lagAcc = lagAcc + dt
        if State.AntiLag and lagAcc >= 1 then
            lagAcc = 0
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= lp and p.Character then
                    for _, c in ipairs(p.Character:GetChildren()) do
                        if c.Name == "GrabParts" then c:Destroy() end
                    end
                end
            end
        end

        -- منع اللزق: يشيل TouchInterest من قطع اللزق المتصلة بجسمك (كل 0.1)
        sticAcc = sticAcc + dt
        if State.AntiSticky and sticAcc >= 0.1 then
            sticAcc = 0
            local char = Char()
            if char then
                local mine = ToyFolder()
                for _, part in ipairs(char:GetChildren()) do
                    if part:IsA("BasePart") then
                        for _, other in ipairs(part:GetConnectedParts()) do
                            if other.Name == "StickyPart" and not (mine and other:IsDescendantOf(mine)) then
                                for _, c in ipairs(other:GetChildren()) do
                                    if c:IsA("TouchInterest") then c:Destroy() end
                                end
                            end
                        end
                    end
                end
            end
        end
    end))

    -- منع الانفجار: لما تنزل قطعة انفجار قريبة منك يثبتك لحظة ويصفّر السرعة
    Track(Workspace.ChildAdded:Connect(function(child)
        if not (State.AntiExplosion and child.Name == "Part" and child:IsA("BasePart")) then return end
        local char, root, hum = Char()
        if not (char and root and hum) then return end
        if (child.Position - root.Position).Magnitude > 20 then return end
        root.Anchored = true
        task.wait(0.02)
        if not hum.SeatPart then hum.Sit = false end
        for _, d in ipairs(char:GetDescendants()) do
            if d.Name == "RagdollLimbPart" and d:IsA("BasePart") then d.CanCollide = false end
        end
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        root.Anchored = false
    end))

    -- منع الحرق: يطفي النار ويحرك قطعة الإطفاء معك لين تخلص
    local function HookBurn(char)
        local root = char:WaitForChild("HumanoidRootPart", 3)
        if not root then return end
        Track(root.ChildAdded:Connect(function(child)
            if not Alive() or not State.AntiBurn or child.Name ~= "FireParticleEmitter" then return end
            local ext = MapPath("Hole", "PoisonSmallHole", "ExtinguishPart")
            local light = root:FindFirstChild("FireLight")
            if light then light:Destroy() end
            pcall(function() child.Enabled = false end)
            local pg = lp:FindFirstChild("PlayerGui")
            local fade = pg and pg:FindFirstChild("ScreenOverlayGui")
            fade = fade and fade:FindFirstChild("FireFade")
            if fade then fade.Visible = false end
            if not ext then return end
            local orig = ext.CFrame
            while child.Parent and root.Parent and Alive() do
                ext.CFrame = root.CFrame
                task.wait()
            end
            ext.CFrame = orig
        end))
    end
    Track(lp.CharacterAdded:Connect(HookBurn))
    if lp.Character then task.spawn(HookBurn, lp.Character) end

    -- منع الصبغ والسم: يوقف لمس القطع الخطرة (ويرجعها لما تطفي الميزة)
    local function SetTouch(partName, enabled, onlyPoisonHoles)
        local roots = {}
        if onlyPoisonHoles then
            roots = { MapPath("Hole", "PoisonBigHole"), MapPath("Hole", "PoisonSmallHole") }
            for _, r in ipairs(roots) do
                if r then
                    local p = r:FindFirstChild(partName)
                    if p then p.CanTouch = enabled end
                end
            end
        else
            for _, d in ipairs(Workspace:GetDescendants()) do
                if d.Name == partName and d:IsA("BasePart") then d.CanTouch = enabled end
            end
        end
    end
    Track(Workspace.DescendantAdded:Connect(function(d)
        if State.AntiPaint and d.Name == "PaintPlayerPart" and d:IsA("BasePart") then
            d.CanTouch = false
        end
    end))

    -- منع اللاق (جزء السكربتات المحلية)
    local function SetLagScripts(on)
        local ps = lp:FindFirstChild("PlayerScripts")
        if not ps then return end
        for _, n in ipairs({ "CharacterAndBeamMove", "StickyPartsTouchDetection" }) do
            local s = ps:FindFirstChild(n)
            if s then pcall(function() s.Enabled = not on end) end
        end
    end

    -- ═════════ رد الهجوم ═════════
    local lastGrabber = nil
    local lastLabel = nil
    local function UpdateLastLabel()
        if lastLabel then
            lastLabel.Text = TF("tm.ca.last", lastGrabber and (lastGrabber.DisplayName .. " (@" .. lastGrabber.Name .. ")") or TX("tm.ca.nobody"))
        end
    end

    local escaping = false
    local function Counter(plr)
        local mode = State.CounterMode
        if mode == "Notify" then
            Notify(TF("tm.ca.grabbed", plr.DisplayName))
        elseif mode == "GrabBack" then
            local _, myRoot = Char()
            local r = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
            if myRoot and r and Remotes.SetNetworkOwner then
                Remotes.SetNetworkOwner:FireServer(r, CFrame.new(myRoot.Position + Vector3.new(0, 1.6, 0), r.Position))
            end
        elseif mode == "Escape" then
            if escaping then return end
            escaping = true
            task.delay(0.15, function()
                local _, root = Char()
                if root then
                    root.AssemblyLinearVelocity = Vector3.zero
                    root.CFrame = safeCF or CFrame.new(0, 15, 0)
                end
                escaping = false
            end)
        end
    end

    local function HookHead(char)
        local head = char:WaitForChild("Head", 5)
        if not head then return end
        Track(head.ChildAdded:Connect(function(child)
            if not Alive() or child.Name ~= "PartOwner" or not child:IsA("StringValue") then return end
            local plr = Players:FindFirstChild(child.Value)
            if not plr or plr == lp then return end
            lastGrabber = plr
            UpdateLastLabel()
            if State.Counter then Counter(plr) end
        end))
    end
    Track(lp.CharacterAdded:Connect(HookHead))
    if lp.Character then task.spawn(HookHead, lp.Character) end

    -- ═════════ الخط (التطويل / القوة / الشكل / المعلومات) ═════════
    local LineTypes = {
        Laser = "rbxassetid://8922958725", Chain = "rbxassetid://81358145120405",
        ["Chain 2"] = "rbxassetid://132910145874066", ["Chain 3"] = "rbxassetid://128466395060514",
        ["Chain 4"] = "rbxassetid://73368670987191", Pulse = "rbxassetid://82163767314193",
        Rope = "rbxassetid://78999022056924", Dots = "rbxassetid://9169659357",
        Bubbles = "rbxassetid://1249690853", Spring = "rbxassetid://18837732116",
    }
    local LineNames = {}
    for k in pairs(LineTypes) do LineNames[#LineNames + 1] = k end
    table.sort(LineNames)

    -- نص معلومات الشيء الممسوك (يظهر أسفل الشاشة)
    local InfoLabel
    do
        local gui = Instance.new("ScreenGui")
        gui.Name = "TM_" .. tostring(math.random(100000, 999999))
        gui.ResetOnSpawn = false; gui.DisplayOrder = 40
        local ok = pcall(function() gui.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
        if not ok or not gui.Parent then gui.Parent = lp:WaitForChild("PlayerGui") end
        getgenv().TM_Gui = gui
        InfoLabel = Instance.new("TextLabel", gui)
        InfoLabel.AnchorPoint = Vector2.new(0.5, 1)
        InfoLabel.Position = UDim2.new(0.5, 0, 0.82, 0)
        InfoLabel.Size = UDim2.new(0, 260, 0, 30)
        InfoLabel.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
        InfoLabel.BackgroundTransparency = 0.2
        InfoLabel.TextColor3 = Color3.new(1, 1, 1)
        InfoLabel.Font = Enum.Font.GothamBold; InfoLabel.TextSize = 13
        InfoLabel.Visible = false
        Instance.new("UICorner", InfoLabel).CornerRadius = UDim.new(0, 8)
    end

    local lineDist = 0
    local lastThrowInput = -10
    Track(UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then lastThrowInput = os.clock() end
    end))
    Track(UserInputService.InputChanged:Connect(function(input)
        if not State.Extend then return end
        if input.UserInputType == Enum.UserInputType.MouseWheel then
            if lineDist < 11 then lineDist = 11 end
            if input.Position.Z > 0 then
                lineDist = lineDist + State.ExtendSpeed
            elseif input.Position.Z < 0 then
                lineDist = math.max(3, lineDist - State.ExtendSpeed)
            end
        end
    end))

    Track(Workspace.ChildAdded:Connect(function(child)
        if not Alive() or child.Name ~= "GrabParts" then return end

        local beamPart = child:WaitForChild("BeamPart", 0.1)
        local beam = beamPart and beamPart:WaitForChild("GrabBeam", 0.1)
        if State.TextureOn and beam and LineTypes[State.Texture] then
            pcall(function() beam.Texture = LineTypes[State.Texture] end)
        end

        local dragPart = child:WaitForChild("DragPart", 0.1)
        local grabPart = child:WaitForChild("GrabPart", 0.1)
        local weld = grabPart and grabPart:WaitForChild("WeldConstraint", 0.1)
        local part1 = weld and weld.Part1

        -- تطويل الخط: ننسخ DragPart ونحركه أمام الكاميرا بالمسافة المختارة
        if State.Extend and dragPart then
            pcall(function()
                local clone = dragPart:Clone()
                clone.Name = "DragPart1"
                clone.AlignPosition.Attachment1 = clone.DragAttach
                clone.Parent = child
                lineDist = (clone.Position - Cam().CFrame.Position).Magnitude
                clone.AlignOrientation.Enabled = false
                dragPart.AlignPosition.Enabled = false
                local zoomIn = ContextAction:GetButton("ZoomIn")
                local zoomOut = ContextAction:GetButton("ZoomOut")
                task.spawn(function()
                    while child.Parent and Alive() and clone.Parent do
                        if zoomOut and zoomOut.GuiState == Enum.GuiState.Press then
                            lineDist = lineDist + State.ExtendSpeed
                        elseif zoomIn and zoomIn.GuiState == Enum.GuiState.Press then
                            lineDist = math.max(3, lineDist - State.ExtendSpeed)
                        end
                        local cam = Cam()
                        clone.Position = cam.CFrame.Position + cam.CFrame.LookVector * lineDist
                        task.wait()
                    end
                end)
            end)
        end

        -- معلومات الشيء الممسوك
        if State.Info and part1 and part1.Parent then
            local model = part1.Parent
            local owner = model:IsA("Model") and Players:GetPlayerFromCharacter(model)
            local name = owner and owner.DisplayName or model.Name
            InfoLabel.Text = TF("tm.line.holding", name)
            InfoLabel.Visible = true
            task.spawn(function()
                while child.Parent and Alive() do task.wait(0.1) end
                InfoLabel.Visible = false
            end)
        end

        -- القوة الخارقة: بعد الرمي نعطي الشيء سرعة باتجاه الكاميرا لمدة ثانية
        if State.Strength and part1 and part1:IsA("BasePart") then
            local function boost()
                if not (part1 and part1.Parent) then return end
                local bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bv.Velocity = Cam().CFrame.LookVector * State.StrengthValue
                bv.Parent = part1
                Debris:AddItem(bv, 1)
            end
            local throwBtn = ContextAction:GetButton("Throw")
            local tconn
            if throwBtn then
                tconn = throwBtn.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Touch then boost() end
                end)
            end
            child.AncestryChanged:Connect(function(_, parent)
                if parent ~= nil then return end
                if tconn then tconn:Disconnect() end
                if throwBtn or not State.Strength then return end
                local t0 = os.clock()
                if t0 - lastThrowInput < 0.4 then boost(); return end
                local c
                c = UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton2 then
                        c:Disconnect(); boost()
                    end
                end)
                task.delay(0.15, function() if c then c:Disconnect() end end)
            end)
        end
    end))

    -- ═════════ الألعاب والماب ═════════
    local spawning = false
    local function SpawnToys()
        if not Remotes.SpawnToy then return Notify(TF("tm.noremote", "SpawnToy")) end
        if spawning then return end
        spawning = true
        task.spawn(function()
            for _ = 1, State.Amount do
                if not Alive() then break end
                local _, root = Char()
                if not root then Notify(TX("tm.nochar")); break end
                local can = lp:FindFirstChild("CanSpawnToy")
                local t0 = os.clock()
                while can and can.Value == false and os.clock() - t0 < 5 do task.wait() end
                local pos = CFrame.new(root.Position + Vector3.new(0, 15, 0)) + Vector3.new(0, 0, 20)
                local rp = Workspace:FindFirstChild("RotateOrientPart")
                local rot = rp and rp.Rotation or Vector3.zero
                task.spawn(function()
                    pcall(function() Remotes.SpawnToy:InvokeServer(State.ToyName, pos, rot) end)
                end)
                task.wait(0.4)
            end
            spawning = false
        end)
    end

    local function ClearToys()
        local f = ToyFolder()
        if not (f and Remotes.DestroyToy) then return Notify(TF("tm.noremote", "DestroyToy")) end
        local n = 0
        for _, c in ipairs(f:GetChildren()) do
            if c:IsA("Model") then Remotes.DestroyToy:FireServer(c); n = n + 1 end
        end
        Notify(TF("tm.toys.cleared", n))
    end

    local function GetWaypoints()
        local items, map = {}, {}
        local wp = Workspace:FindFirstChild("Waypoints")
        if wp then
            local names = {}
            for _, c in ipairs(wp:GetChildren()) do
                if c.Name ~= "CharacterWaypoint" then names[#names + 1] = c.Name; map[c.Name] = c end
            end
            table.sort(names)
            for _, n in ipairs(names) do items[#items + 1] = { id = n, text = n } end
        end
        return items, map
    end

    -- ═════════ بناء الأقسام ═════════
    tab.Order = tab.Order + 1
    do
        local H = Instance.new("TextLabel", PAGE)
        H.LayoutOrder = tab.Order; H.Size = UDim2.new(0.98, 0, 0, 20)
        H.BackgroundTransparency = 1; H.Text = TX("tm.hint")
        H.TextColor3 = DIM; H.Font = Enum.Font.Gotham; H.TextSize = 11
    end

    -- ── الحماية ──
    local secDef = MakeSection("def", TX("tm.sec.def"), C_BLUE, true)
    Tog(secDef, TX("tm.anti.grab"), function(v)
        State.AntiGrab = v
        if v and not Remotes.Struggle then Notify(TF("tm.noremote", "Struggle")) end
    end)
    Dropdown(secDef, TX("tm.anti.grab.type"), {
        { id = "Normal", text = TX("tm.anti.normal") },
        { id = "Strong", text = TX("tm.anti.strong") },
    }, 1, function(id) State.AntiGrabType = id end)
    Tog(secDef, TX("tm.anti.explosion"), function(v) State.AntiExplosion = v end)
    Tog(secDef, TX("tm.anti.burn"), function(v) State.AntiBurn = v end)
    Tog(secDef, TX("tm.anti.sticky"), function(v) State.AntiSticky = v end)
    Tog(secDef, TX("tm.anti.paint"), function(v)
        State.AntiPaint = v
        task.spawn(SetTouch, "PaintPlayerPart", not v, false)
    end)
    Tog(secDef, TX("tm.anti.poison"), function(v)
        State.AntiPoison = v
        task.spawn(function()
            SetTouch("PoisonHurtPart", not v, true)
            SetTouch("PaintPlayerPart", not v, true)
        end)
    end)
    Tog(secDef, TX("tm.anti.void"), function(v) State.AntiVoid = v end)
    Tog(secDef, TX("tm.anti.invis"), function(v) State.AntiInvis = v end)
    Tog(secDef, TX("tm.anti.lag"), function(v)
        State.AntiLag = v
        SetLagScripts(v)
    end)

    -- ── رد الهجوم ──
    local secCA = MakeSection("counter", TX("tm.sec.counter"), C_RED, false)
    Dropdown(secCA, TX("tm.ca.mode"), {
        { id = "Notify",   text = TX("tm.ca.notify") },
        { id = "GrabBack", text = TX("tm.ca.grabback") },
        { id = "Escape",   text = TX("tm.ca.escape") },
    }, 1, function(id) State.CounterMode = id end)
    Tog(secCA, TX("tm.ca.enable"), function(v) State.Counter = v end)
    lastLabel = InfoCard(secCA, "")
    UpdateLastLabel()

    -- ── الخط ──
    local secLine = MakeSection("line", TX("tm.sec.line"), C_PURPLE, false)
    Tog(secLine, TX("tm.line.extend"), function(v) State.Extend = v end)
    Stepper(secLine, TX("tm.line.speed"), 1, 15, 1, 1, function(n) State.ExtendSpeed = n end)
    Tog(secLine, TX("tm.line.strength.on"), function(v) State.Strength = v end)
    Stepper(secLine, TX("tm.line.strength"), 300, 5000, 400, 100, function(n) State.StrengthValue = n end)
    do
        local items = {}
        for _, n in ipairs(LineNames) do items[#items + 1] = { id = n, text = n } end
        local idx = table.find(LineNames, "Chain 2") or 1
        Dropdown(secLine, TX("tm.line.texture"), items, idx, function(id) State.Texture = id end)
    end
    Tog(secLine, TX("tm.line.texture.on"), function(v) State.TextureOn = v end)
    Tog(secLine, TX("tm.line.info"), function(v)
        State.Info = v
        if not v then InfoLabel.Visible = false end
    end)

    -- ── الألعاب ──
    local secToys = MakeSection("toys", TX("tm.sec.toys"), C_ORANGE, false)
    Dropdown(secToys, TX("tm.toys.pick"), {
        { id = "NinjaShuriken",    text = "NinjaShuriken" },
        { id = "PalletLightBrown", text = "PalletLightBrown" },
        { id = "YouDecoy",         text = "YouDecoy" },
    }, 1, function(id) State.ToyName = id end)
    Stepper(secToys, TX("tm.toys.amount"), 1, 10, 1, 1, function(n) State.Amount = n end)
    Grid(secToys, {
        { text = TX("tm.toys.spawn"), fn = SpawnToys },
        { text = TX("tm.toys.clear"), color = C_RED, fn = ClearToys },
    })
    do
        local L = InfoCard(secToys, TF("tm.toys.count", CountToys()))
        local acc = 0
        Track(RunService.Heartbeat:Connect(function(dt)
            acc = acc + dt
            if acc < 1 then return end
            acc = 0
            pcall(function() L.Text = TF("tm.toys.count", CountToys()) end)
        end))
    end

    -- ── الماب ──
    local secMap = MakeSection("map", TX("tm.sec.map"), C_CYAN, false)
    do
        local items, map = GetWaypoints()
        if #items == 0 then
            InfoCard(secMap, TX("tm.map.none"))
        else
            local picked = items[1].id
            Dropdown(secMap, TX("tm.map.point"), items, 1, function(id) picked = id end)
            Grid(secMap, {
                { text = TX("tm.map.go"), fn = function()
                    local inst = map[picked]
                    local _, root = Char()
                    if not root then return Notify(TX("tm.nochar")) end
                    if inst then root.CFrame = inst:GetPivot() + Vector3.new(0, 5, 0) end
                end },
            })
        end
    end
end

-- ============================================================
-- 3. إرجاع الجدول (نفس صيغة MM2)
-- ============================================================
return {
    Name   = "Throw Map",
    Render = Render,
}