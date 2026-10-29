-- [[ Cryptic Hub - Map: Throw Things & Players (v3) ]]
-- نفس صيغة MM2: يرجع { Name, Render(tab, UI) } ويشتغل داخل واجهة الهب
-- الأقسام: الحماية / رد الهجوم / الخط / الألعاب / الماب
-- مبني على v2 + ميزات دفاعية منقولة من سكربت Resonance (Anti Blobman / Anti Snowball / No Void Kill / Noclip Barrier)
-- ملاحظة: كل النصوص والرموز ASCII أو عربي فقط (بدون إيموجي أو رموز تظهر مربعات)
--
-- الجديد في v3:
--   * حفظ كل الإعدادات (الملف Cryptic_ThrowMap.json) وتفعيل المحفوظ تلقائياً عند التشغيل
--   * كل ميزة تتراجع بالكامل عند إعادة تشغيل السكربت (ما يبقى أثر قديم)
--   * ريموتات تُبحث عند الاستخدام (لو تأخرت اللعبة في تحميلها ما تضيع الميزة)
--   * اتصالات الشخصية تتنظف مع كل Respawn (ما تتراكم)
--   * سلايدر بدل - / + (سحب + ضغط مطوّل) وعدّاد الميزات المفعّلة في رأس كل قسم
--   * مواقع محفوظة A / B + آخر مكان آمن + نقطة الظهور

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
        ["tm.anti.blobman"]    = "Anti Blobman (can't be grabbed by Blobman)",
        ["tm.anti.snowball"]   = "Anti Snowball (auto unfreeze)",
        ["tm.anti.explosion"]  = "Anti Explosion",
        ["tm.anti.burn"]       = "Anti Burn",
        ["tm.anti.sticky"]     = "Anti Sticky",
        ["tm.anti.paint"]      = "Anti Paint",
        ["tm.anti.poison"]     = "Anti Poison",
        ["tm.anti.void"]       = "Anti Void (teleport back up)",
        ["tm.anti.invis"]      = "Anti Invis",
        ["tm.anti.lag"]        = "Anti Lag (hide lines and sticky lag)",
        ["tm.noremote"]        = "Remote not found: %s",

        ["tm.ca.enable"]       = "Counter Attack",
        ["tm.ca.mode"]         = "When someone grabs you",
        ["tm.ca.notify"]       = "Only notify me",
        ["tm.ca.grabback"]     = "Grab them back",
        ["tm.ca.escape"]       = "Escape to last safe spot",
        ["tm.ca.spawn"]        = "Teleport to spawn",
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
        ["tm.line.spin"]       = "Spin grabbed objects (objects only, not players)",
        ["tm.line.fling"]      = "Fling grabbed objects (objects only, not players)",
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
        ["tm.map.spawn"]       = "Go to spawn",
        ["tm.map.safe"]        = "Back to last safe spot",
        ["tm.map.saveA"]       = "Save my spot as A",
        ["tm.map.goA"]         = "Go to spot A",
        ["tm.map.saveB"]       = "Save my spot as B",
        ["tm.map.goB"]         = "Go to spot B",
        ["tm.map.saved"]       = "Saved spot %s",
        ["tm.map.nosaved"]     = "Nothing saved for spot %s",
        ["tm.map.nosafe"]      = "No safe spot recorded yet",
        ["tm.map.novoid"]      = "No Void Kill (void can't kill you)",
        ["tm.map.barrier"]     = "Noclip Plot Barriers",
        ["tm.qp.toggle"]       = "Quick panel (on-screen buttons)",
        ["tm.qp.grab"]         = "Anti Grab",
        ["tm.qp.blob"]         = "Blobman",
        ["tm.qp.snow"]         = "Snowball",
        ["tm.qp.expl"]         = "Explosion",
        ["tm.sec.cam"]         = "Camera",
        ["tm.cam.zoom"]        = "Zoom (scope) - mouse wheel changes it",
        ["tm.cam.zoomfov"]     = "Zoom field of view (low = closer)",
        ["tm.cam.fov"]         = "Field of view",
        ["tm.cam.third"]       = "Third Person (unlimited zoom out)",
        ["tm.cam.noclip"]      = "Camera Noclip (see through walls)",
        ["tm.toys.pallet"]     = "Spawn Pallet at camera",
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
        ["tm.anti.blobman"]    = "منع البلوبمان (ما يقدر يمسكك بالبلوبمان)",
        ["tm.anti.snowball"]   = "منع كرة الثلج (فك التجميد تلقائياً)",
        ["tm.anti.explosion"]  = "منع الانفجار",
        ["tm.anti.burn"]       = "منع الحرق",
        ["tm.anti.sticky"]     = "منع اللزق",
        ["tm.anti.paint"]      = "منع الصبغ",
        ["tm.anti.poison"]     = "منع السم",
        ["tm.anti.void"]       = "منع السقوط للفراغ (يرجعك فوق)",
        ["tm.anti.invis"]      = "كشف المخفيين",
        ["tm.anti.lag"]        = "منع اللاق (إخفاء الخطوط ولاق اللزق)",
        ["tm.noremote"]        = "ما لقيت الريموت: %s",

        ["tm.ca.enable"]       = "رد الهجوم",
        ["tm.ca.mode"]         = "لما أحد يمسكك",
        ["tm.ca.notify"]       = "نبهني فقط",
        ["tm.ca.grabback"]     = "امسكه بالمقابل",
        ["tm.ca.escape"]       = "اهرب لآخر مكان آمن",
        ["tm.ca.spawn"]        = "انتقل لنقطة الظهور",
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
        ["tm.line.spin"]       = "تدوير الأشياء الممسوكة (أشياء فقط، مو لاعبين)",
        ["tm.line.fling"]      = "قذف الأشياء الممسوكة (أشياء فقط، مو لاعبين)",
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
        ["tm.map.spawn"]       = "انتقل لنقطة الظهور",
        ["tm.map.safe"]        = "ارجع لآخر مكان آمن",
        ["tm.map.saveA"]       = "احفظ موقعي كـ A",
        ["tm.map.goA"]         = "انتقل للموقع A",
        ["tm.map.saveB"]       = "احفظ موقعي كـ B",
        ["tm.map.goB"]         = "انتقل للموقع B",
        ["tm.map.saved"]       = "تم حفظ الموقع %s",
        ["tm.map.nosaved"]     = "ما فيه شيء محفوظ للموقع %s",
        ["tm.map.nosafe"]      = "ما تسجّل مكان آمن لسا",
        ["tm.map.novoid"]      = "منع الموت بالفراغ (الفراغ ما يقتلك)",
        ["tm.map.barrier"]     = "اختراق حواجز البيوت",
        ["tm.qp.toggle"]       = "لوحة سريعة (أزرار على الشاشة)",
        ["tm.qp.grab"]         = "منع الإمساك",
        ["tm.qp.blob"]         = "بلوبمان",
        ["tm.qp.snow"]         = "كرة ثلج",
        ["tm.qp.expl"]         = "انفجار",
        ["tm.sec.cam"]         = "الكاميرا",
        ["tm.cam.zoom"]        = "زوم (منظار) - عجلة الماوس تغيّره",
        ["tm.cam.zoomfov"]     = "زاوية الزوم (أقل = أقرب)",
        ["tm.cam.fov"]         = "زاوية الرؤية",
        ["tm.cam.third"]       = "منظور الشخص الثالث (تصغير بلا حد)",
        ["tm.cam.noclip"]      = "كاميرا تخترق الجدران",
        ["tm.toys.pallet"]     = "ضع باليت عند الكاميرا",
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

    -- ── إدارة التشغيل المتكرر: رقم جديد + تنظيف كامل للنسخة السابقة (يرجّع كل التغييرات) ──
    getgenv().TM_RunId = (getgenv().TM_RunId or 0) + 1
    local RUN = getgenv().TM_RunId
    local function Alive() return getgenv().TM_RunId == RUN end
    if type(getgenv().TM_Cleanup) == "function" then
        pcall(getgenv().TM_Cleanup)
    end
    getgenv().TM_Cleanup = nil

    local Conns = {}
    local function Track(c) Conns[#Conns + 1] = c; return c end
    local TrackConn = Track -- الاسم الذي يستخدمه مكوّن السلايدر

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
    local HttpService       = game:GetService("HttpService")
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

    -- ═════════ الحفظ (كل الإعدادات في ملف واحد) ═════════
    local SAVE_FILE = "Cryptic_ThrowMap.json"
    local Saved = {}
    pcall(function()
        if isfile and readfile and isfile(SAVE_FILE) then
            local d = HttpService:JSONDecode(readfile(SAVE_FILE))
            if type(d) == "table" then Saved = d end
        end
    end)
    local saveTok = 0
    local function SaveSoon() -- نكتب الملف مرة وحدة بعد ما تهدأ التغييرات
        saveTok = saveTok + 1
        local my = saveTok
        task.delay(1, function()
            if my ~= saveTok or not writefile then return end
            pcall(function() writefile(SAVE_FILE, HttpService:JSONEncode(Saved)) end)
        end)
    end
    local function SV(key, default) -- قيمة محفوظة بنفس نوع الافتراضي، وإلا الافتراضي
        local v = Saved[key]
        if v == nil or type(v) ~= type(default) then return default end
        return v
    end

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

        -- Absolute* بالبكسل المرسوم (بعد UIScale) و Size/Padding بالوحدات المحلية → نحوّل بالقسمة على السكيل
        local GRIP_PX = 36 -- = RESIZE_HIT_AREA_PX (32) + RESIZE_SAFE_GAP_PX (4) في الكور
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
                local pad = math.ceil(GRIP_PX / scale) + 4
                if pd.PaddingBottom.Offset ~= pad then pd.PaddingBottom = UDim.new(0, pad) end
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

    -- قسم قابل للطي + عدّاد الميزات المفعّلة
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
        TL.Size = UDim2.new(1, -130, 1, 0); TL.Position = UDim2.new(0, 24, 0, 0)
        TL.BackgroundTransparency = 1; TL.Text = title
        TL.TextColor3 = Color3.fromRGB(230, 230, 242)
        TL.Font = Enum.Font.GothamBold; TL.TextSize = 13
        TL.TextXAlignment = Enum.TextXAlignment.Left
        TL.TextTruncate = Enum.TextTruncate.AtEnd

        local Badge = Instance.new("TextLabel", Hdr)
        Badge.Size = UDim2.new(0, 46, 0, 22); Badge.Position = UDim2.new(1, -92, 0.5, -11)
        Badge.BackgroundColor3 = color; Badge.BackgroundTransparency = 0.7
        Badge.TextColor3 = Color3.new(1, 1, 1); Badge.Font = Enum.Font.GothamBlack
        Badge.TextSize = 11; Badge.Text = "0"; Badge.Visible = false
        Instance.new("UICorner", Badge).CornerRadius = UDim.new(1, 0)

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

        local sec = { cont = Cont, color = color, count = 0 }
        function sec.refresh()
            Badge.Visible = sec.count > 0
            Badge.Text = "ON " .. sec.count
        end

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

    local function AddSlider(text, minV, maxV, defaultV, step, suffix, callback)
        local Tw = function(obj, props, t)
            TweenService:Create(obj,
                TweenInfo.new(t or 0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                props):Play()
        end
        tab.Order = tab.Order + 1
        suffix = suffix or ""

        local ACCENT  = Color3.fromRGB(0, 255, 150)
        local ACCENT2 = Color3.fromRGB(0, 150, 255)
        local OFF_CLR = Color3.fromRGB(45, 45, 55)
        local BASE    = Color3.fromRGB(16, 16, 20)

        local R = Instance.new("Frame", tab.Page)
        R.LayoutOrder            = tab.Order
        R.Size                   = UDim2.new(0.98, 0, 0, 76)
        R.BackgroundColor3       = BASE
        R.BackgroundTransparency = 0.1
        R.BorderSizePixel        = 0
        Instance.new("UICorner", R).CornerRadius = UDim.new(0, 10)

        local Stroke = Instance.new("UIStroke", R)
        Stroke.Thickness    = 1.2
        Stroke.Transparency = 0.55
        local SG = Instance.new("UIGradient", Stroke)
        SG.Color    = ColorSequence.new{
            ColorSequenceKeypoint.new(0, ACCENT),
            ColorSequenceKeypoint.new(1, ACCENT2) }
        SG.Rotation = 45

        local Lbl = Instance.new("TextLabel", R)
        Lbl.Text                   = text
        Lbl.Size                   = UDim2.new(1, -90, 0, 24)
        Lbl.Position               = UDim2.new(0, 10, 0, 6)
        Lbl.TextColor3             = Color3.fromRGB(210, 210, 225)
        Lbl.BackgroundTransparency = 1
        Lbl.TextXAlignment         = Enum.TextXAlignment.Left
        Lbl.Font                   = Enum.Font.GothamSemibold
        Lbl.TextSize               = 12
        Lbl.TextWrapped            = false
        Lbl.TextTruncate           = Enum.TextTruncate.AtEnd

        local ValLbl = Instance.new("TextLabel", R)
        ValLbl.Size                   = UDim2.new(0, 70, 0, 24)
        ValLbl.Position               = UDim2.new(1, -80, 0, 6)
        ValLbl.BackgroundTransparency = 1
        ValLbl.TextColor3             = ACCENT
        ValLbl.TextXAlignment         = Enum.TextXAlignment.Right
        ValLbl.Font                   = Enum.Font.GothamBold
        ValLbl.TextSize               = 13

        local function mkStepBtn(txt, pos)
            local b = Instance.new("TextButton", R)
            b.Size                   = UDim2.new(0, 38, 0, 34)
            b.Position               = pos
            b.BackgroundColor3       = OFF_CLR
            b.BackgroundTransparency = 0.1
            b.BorderSizePixel        = 0
            b.Text                   = txt
            b.TextColor3             = Color3.new(1, 1, 1)
            b.Font                   = Enum.Font.GothamBold
            b.TextSize               = 18
            b.AutoButtonColor        = false
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
            return b
        end
        local Minus = mkStepBtn("-", UDim2.new(0, 8, 0, 36))
        local Plus  = mkStepBtn("+", UDim2.new(1, -46, 0, 36))

        local Track = Instance.new("Frame", R)
        Track.Size             = UDim2.new(1, -108, 0, 8)
        Track.Position         = UDim2.new(0, 54, 0, 49)
        Track.BackgroundColor3 = OFF_CLR
        Track.BorderSizePixel  = 0
        Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

        local Fill = Instance.new("Frame", Track)
        Fill.Size             = UDim2.new(0, 0, 1, 0)
        Fill.BackgroundColor3 = ACCENT
        Fill.BorderSizePixel  = 0
        Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
        local FG = Instance.new("UIGradient", Fill)
        FG.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, ACCENT),
            ColorSequenceKeypoint.new(1, ACCENT2) }

        local Knob = Instance.new("Frame", Track)
        Knob.Size             = UDim2.new(0, 22, 0, 22)
        Knob.AnchorPoint      = Vector2.new(0.5, 0.5)
        Knob.Position         = UDim2.new(0, 0, 0.5, 0)
        Knob.BackgroundColor3 = Color3.new(1, 1, 1)
        Knob.BorderSizePixel  = 0
        Knob.ZIndex           = 2
        Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

        -- منطقة لمس أكبر من الشريط نفسه
        local Hit = Instance.new("TextButton", R)
        Hit.Size                   = UDim2.new(1, -108, 0, 46)
        Hit.Position               = UDim2.new(0, 54, 0, 30)
        Hit.BackgroundTransparency = 1
        Hit.Text                   = ""
        Hit.AutoButtonColor        = false
        Hit.ZIndex                 = 3

        local value = math.clamp(defaultV, minV, maxV)
        local function render()
            local a = (value - minV) / (maxV - minV)
            Fill.Size     = UDim2.new(a, 0, 1, 0)
            Knob.Position = UDim2.new(a, 0, 0.5, 0)
            ValLbl.Text   = tostring(value) .. suffix
        end
        render()

        local function setValue(v)
            v = math.clamp(math.floor(v / step + 0.5) * step, minV, maxV)
            if v == value then return end
            value = v
            render()
            pcall(callback, value)
        end

        local function isPress(i)
            return i.UserInputType == Enum.UserInputType.MouseButton1
                or i.UserInputType == Enum.UserInputType.Touch
        end
        local function setFromX(x)
            local w = Track.AbsoluteSize.X
            if w <= 0 then return end
            local a = math.clamp((x - Track.AbsolutePosition.X) / w, 0, 1)
            setValue(minV + a * (maxV - minV))
        end

        -- السحب
        local dragging = false
        Hit.InputBegan:Connect(function(i)
            if isPress(i) then
                dragging = true
                pcall(function() tab.Page.ScrollingEnabled = false end)
                Tw(Knob, { Size = UDim2.new(0, 28, 0, 28) })
                Tw(Stroke, { Transparency = 0.1 })
                setFromX(i.Position.X)
            end
        end)
        TrackConn(UserInputService.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement
                          or i.UserInputType == Enum.UserInputType.Touch) then
                setFromX(i.Position.X)
            end
        end))
        TrackConn(UserInputService.InputEnded:Connect(function(i)
            if dragging and isPress(i) then
                dragging = false
                pcall(function() tab.Page.ScrollingEnabled = true end)
                Tw(Knob, { Size = UDim2.new(0, 22, 0, 22) })
                Tw(Stroke, { Transparency = 0.55 })
            end
        end))

        -- أزرار - / + (ضغطة = خطوة، ضغط مطوّل = تكرار سريع)
        local holdId = nil
        local function bindStep(btn, dir)
            btn.InputBegan:Connect(function(i)
                if not isPress(i) then return end
                local id = {}
                holdId = id
                Tw(btn, { BackgroundColor3 = ACCENT2 })
                setValue(value + dir * step)
                task.spawn(function()
                    task.wait(0.4)
                    while holdId == id and Alive() do
                        setValue(value + dir * step)
                        task.wait(0.06)
                    end
                end)
            end)
            btn.InputEnded:Connect(function(i)
                if isPress(i) then
                    holdId = nil
                    Tw(btn, { BackgroundColor3 = OFF_CLR })
                end
            end)
        end
        bindStep(Minus, -1)
        bindStep(Plus,  1)
    end

    -- ═════════ الريموتات (تُبحث عند الاستخدام، فلو تأخرت اللعبة ما تضيع) ═════════
    local RemoteCache = {}
    local function Remote(folder, name)
        local key = folder .. "/" .. name
        local r = RemoteCache[key]
        if r and r.Parent then return r end
        local f = ReplicatedStorage:FindFirstChild(folder)
        r = f and f:FindFirstChild(name)
        RemoteCache[key] = r
        return r
    end
    local function RStruggle()  return Remote("CharacterEvents", "Struggle") end
    local function RRagdoll()   return Remote("CharacterEvents", "RagdollRemote") end
    local function RSetOwner()  return Remote("GrabEvents", "SetNetworkOwner") end
    local function RSpawnToy()  return Remote("MenuToys", "SpawnToyRemoteFunction") end
    local function RDestroyToy() return Remote("MenuToys", "DestroyToy") end
    task.spawn(function() -- نسخّن الكاش بدون ما نوقف الواجهة
        for _, p in ipairs({ { "CharacterEvents", "Struggle" }, { "CharacterEvents", "RagdollRemote" },
            { "GrabEvents", "SetNetworkOwner" }, { "MenuToys", "SpawnToyRemoteFunction" }, { "MenuToys", "DestroyToy" } }) do
            local f = ReplicatedStorage:WaitForChild(p[1], 3)
            if f then f:WaitForChild(p[2], 3) end
        end
    end)

    -- ═════════ الحالة والمساعدات ═════════
    local State = {
        AntiGrab = false, AntiGrabType = "Normal",
        AntiBlobman = false, AntiSnowball = false,
        AntiExplosion = false, AntiBurn = false, AntiSticky = false,
        AntiPaint = false, AntiPoison = false, AntiVoid = false,
        AntiInvis = false, AntiLag = false,
        Counter = false, CounterMode = "Notify",
        Extend = false, ExtendSpeed = 1,
        Strength = false, StrengthValue = 400,
        TextureOn = false, Texture = "Chain 2",
        Info = false, GrabSpin = false, GrabFling = false,
        Zoom = false, ZoomFOV = 20, FOV = 70, ThirdPerson = false, CamNoclip = false,
        ToyName = "NinjaShuriken", Amount = 1,
    }
    State.AntiGrabType  = SV("AntiGrabType", State.AntiGrabType)
    State.CounterMode   = SV("CounterMode", State.CounterMode)
    State.ExtendSpeed   = math.clamp(SV("ExtendSpeed", State.ExtendSpeed), 1, 15)
    State.StrengthValue = math.clamp(SV("StrengthValue", State.StrengthValue), 300, 5000)
    State.Texture       = SV("Texture", State.Texture)
    State.ToyName       = SV("ToyName", State.ToyName)
    State.Amount        = math.clamp(SV("Amount", State.Amount), 1, 10)
    State.ZoomFOV       = math.clamp(SV("ZoomFOV", State.ZoomFOV), 10, 120)
    State.FOV           = math.clamp(SV("FOV", State.FOV), 30, 120)

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
    local function Held()
        if not (isHeld and isHeld.Parent) then isHeld = lp:FindFirstChild("IsHeld") end
        return isHeld and isHeld.Value
    end
    local safeCF = nil -- آخر مكان آمن وقفت فيه

    -- اتصالات الشخصية: تتنظف مع كل Respawn (ما تتراكم)
    local charConns = {}
    local function TrackChar(c) charConns[#charConns + 1] = c; return c end
    local function ClearCharConns()
        for _, c in ipairs(charConns) do pcall(function() c:Disconnect() end) end
        table.clear(charConns)
    end
    Track(lp.CharacterRemoving:Connect(ClearCharConns))

    -- نقل آمن: نفك الجلسة ونصفّر السرعة قبل النقل
    local function TeleportTo(cf)
        local _, root, hum = Char()
        if not (root and hum) or hum.Health <= 0 then Notify(TX("tm.nochar")) return false end
        if hum.SeatPart then hum.Sit = false end
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        root.CFrame = cf
        return true
    end
    local function SpawnCF()
        local sp = Workspace:FindFirstChild("SpawnLocation")
        return sp and sp:IsA("BasePart") and (sp.CFrame + Vector3.new(0, 5, 0)) or nil
    end

    -- ═════════ نظام الميزات: حفظ + تفعيل المحفوظ + تراجع كامل عند إعادة التشغيل ═════════
    local Applied, Applyers, Setters = {}, {}, {}
    local function Feature(sec, key, text, apply)
        Applied[key] = false
        Applyers[key] = apply
        local t
        local function set(v)
            v = v and true or false
            if Applied[key] == v then return end -- نفس الحالة: ما نسوي شيء (يمنع التكرار)
            Applied[key] = v
            State[key] = v
            Saved[key] = v
            SaveSoon()
            sec.count = sec.count + (v and 1 or -1)
            sec.refresh()
            local ok, err = pcall(apply, v)
            if not ok then warn("[ThrowMap] " .. key .. ": " .. tostring(err)) end
        end
        InSection(sec, function()
            t = tab:AddToggle(text, function(v) set(v) end)
        end)
        -- للأزرار السريعة: يغيّر الحالة ويحدّث شكل التوغل
        Setters[key] = function(v)
            set(v)
            if t then pcall(function() t:SetState(v and true or false) end) end
        end
        if Saved[key] == true then
            set(true)
            pcall(function() t:SetState(true) end)
        end
        return t
    end

    -- ═════════ الحماية ═════════
    local acc = { ag = 0, inv = 0, lag = 0, stic = 0, snow = 0, blob = 0 }

    -- Anti Blobman: ننقل RootAttachment خارج الشخصية ونترك BoolValue بنفس الاسم، ونرجعه عند الإيقاف
    local blob = { att = nil, flag = nil, char = nil, pending = false }
    local function RestoreBlob()
        local _, root = Char()
        if blob.att then
            if blob.att.Parent and root and blob.char == lp.Character then blob.att.Parent = root
            elseif blob.att.Parent then blob.att:Destroy() end
            blob.att = nil
        end
        if blob.flag then
            if blob.flag.Parent then blob.flag:Destroy() end
            blob.flag = nil
        end
        blob.char = nil
    end

    Track(RunService.Heartbeat:Connect(function(dt)
        if not Alive() then return end
        local char, root, hum = Char()

        -- حفظ المكان الآمن
        if root and hum and hum.FloorMaterial ~= Enum.Material.Air
           and root.Position.Y > -400 and root.Position.Y < 5000 and not Held() then
            safeCF = root.CFrame
        end

        -- منع الإمساك
        if State.AntiGrab and Held() then
            acc.ag = acc.ag + dt
            if acc.ag >= 1 / 30 then
                acc.ag = 0
                local struggle = RStruggle()
                if struggle then struggle:FireServer() end
                if State.AntiGrabType == "Strong" and root then
                    local rag = RRagdoll()
                    if rag then rag:FireServer(root, 0) end
                    root.AssemblyLinearVelocity = Vector3.zero
                    root.AssemblyAngularVelocity = Vector3.zero
                end
            end
        end

        -- منع السقوط للفراغ (يرجعك لآخر مكان آمن)
        if State.AntiVoid and root then
            local y = root.Position.Y
            if y <= -500 or y >= 10000 then
                root.AssemblyLinearVelocity = Vector3.zero
                root.CFrame = safeCF or CFrame.new(0, 15, 0)
            end
        end

        -- منع كرة الثلج: إذا تجمّدت (WeldHRP) نكسر التجميد بالراجدول ونفك الجلسة
        if State.AntiSnowball and root and hum and hum.Health > 0 then
            acc.snow = acc.snow + dt
            if acc.snow >= 0.05 then
                acc.snow = 0
                local weld = root:FindFirstChild("WeldHRP")
                if weld then
                    local rag = RRagdoll()
                    if rag then rag:FireServer(root, 0.5) end
                    if not hum.SeatPart then hum.Sit = false end
                    hum.AutoRotate = true
                    if weld.Enabled then
                        pcall(function() ContextAction:UnbindAction("JumpRemover") end)
                        pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true) end)
                    end
                end
            end
        end

        -- منع البلوبمان
        if State.AntiBlobman then
            if not (char and root) then
                if blob.att and blob.att.Parent then blob.att:Destroy() end
                blob.att, blob.char = nil, nil
                if blob.flag and blob.flag.Parent then blob.flag:Destroy() end
                blob.flag = nil
            else
                if blob.att and blob.char ~= char then -- شخصية جديدة: نتخلص من المرفق القديم
                    if blob.att.Parent then blob.att:Destroy() end
                    blob.att, blob.flag, blob.char = nil, nil, nil
                end
                if not blob.att and not blob.pending then
                    local att = root:FindFirstChild("RootAttachment")
                    if att and att:IsA("Attachment") then
                        blob.pending = true
                        task.delay(0.5, function()
                            blob.pending = false
                            if not (Alive() and State.AntiBlobman) then return end
                            local c2, r2 = Char()
                            if not (c2 == char and r2 == root and att.Parent == root) then return end
                            att.Parent = ReplicatedStorage
                            blob.att, blob.char = att, c2
                            local f = Instance.new("BoolValue")
                            f.Name = "RootAttachment"
                            f.Parent = root
                            blob.flag = f
                        end)
                    end
                end
                if root.Massless then root.Massless = false end
            end
        end

        -- كشف المخفيين (كل 0.1 ثانية)
        acc.inv = acc.inv + dt
        if State.AntiInvis and acc.inv >= 0.1 then
            acc.inv = 0
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
        acc.lag = acc.lag + dt
        if State.AntiLag and acc.lag >= 1 then
            acc.lag = 0
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= lp and p.Character then
                    for _, c in ipairs(p.Character:GetChildren()) do
                        if c.Name == "GrabParts" then c:Destroy() end
                    end
                end
            end
        end

        -- منع اللزق: يشيل TouchInterest من قطع اللزق المتصلة بجسمك (كل 0.1)
        acc.stic = acc.stic + dt
        if State.AntiSticky and acc.stic >= 0.1 then
            acc.stic = 0
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
        TrackChar(root.ChildAdded:Connect(function(child)
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
            local setOwner = RSetOwner()
            if myRoot and r and setOwner then
                setOwner:FireServer(r, CFrame.new(myRoot.Position + Vector3.new(0, 1.6, 0), r.Position))
            end
        elseif mode == "Escape" or mode == "Spawn" then
            if escaping then return end
            escaping = true
            task.delay(0.15, function()
                local dest = (mode == "Spawn" and SpawnCF()) or safeCF or CFrame.new(0, 15, 0)
                local _, root = Char()
                if root then
                    root.AssemblyLinearVelocity = Vector3.zero
                    root.CFrame = dest
                end
                escaping = false
            end)
        end
    end

    local function HookHead(char)
        local head = char:WaitForChild("Head", 5)
        if not head then return end
        TrackChar(head.ChildAdded:Connect(function(child)
            if not Alive() or child.Name ~= "PartOwner" or not child:IsA("StringValue") then return end
            local plr = Players:FindFirstChild(child.Value)
            if not plr or plr == lp then return end
            lastGrabber = plr
            UpdateLastLabel()
            if State.Counter then Counter(plr) end
        end))
    end

    local function HookChar(char)
        ClearCharConns()
        task.spawn(HookBurn, char)
        task.spawn(HookHead, char)
    end
    Track(lp.CharacterAdded:Connect(HookChar))
    if lp.Character then HookChar(lp.Character) end

    -- ═════════ الكاميرا (منقولة من Resonance: Zoom / FOV / Third Person / Camera Noclip) ═════════
    local origFOV = (Cam() and Cam().FieldOfView) or 70
    local origCamMode, origMaxZoom, origMinZoom = lp.CameraMode, lp.CameraMaxZoomDistance, lp.CameraMinZoomDistance
    local origOcclusion = lp.DevCameraOcclusionMode

    local fovTween
    local function TweenFOV(v, t) -- نفس TweenFOV في Resonance
        if fovTween then fovTween:Cancel(); fovTween = nil end
        local cam = Cam()
        if not cam then return end
        fovTween = TweenService:Create(cam, TweenInfo.new(t or 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { FieldOfView = math.clamp(v, 1, 120) })
        fovTween:Play()
    end
    local function SetFOV(v, forZoom) -- نفس SetFOV في Resonance
        if forZoom then
            State.ZoomFOV = math.clamp(v, 10, 120)
            Saved.ZoomFOV = State.ZoomFOV; SaveSoon()
            TweenFOV(State.ZoomFOV, 0.2)
        else
            State.FOV = math.clamp(v, 30, 120)
            Saved.FOV = State.FOV; SaveSoon()
            if not State.Zoom then TweenFOV(State.FOV, 0.25) end
        end
    end
    if Saved.FOV ~= nil then TweenFOV(State.FOV, 0.1) end -- زاوية محفوظة من قبل

    -- حركة الكاميرا الناعمة أثناء الزوم (UpdateZoomCamera في Resonance، نعومة = 9)
    local zoomCF
    local function UpdateZoomCamera(dt)
        local cam = Cam()
        if not State.Zoom or not cam or cam.CameraType == Enum.CameraType.Scriptable then
            zoomCF = nil
            return
        end
        local cur = cam.CFrame
        if not zoomCF then zoomCF = cur return end
        zoomCF = zoomCF:Lerp(cur, math.clamp(1 - math.exp(-9 * (dt or 1 / 60)), 0, 1))
        cam.CFrame = zoomCF
    end
    local function UnbindZoom() pcall(function() RunService:UnbindFromRenderStep("TMZoom") end) end

    -- عجلة الماوس أثناء الزوم: تقرّب / تبعّد بخطوة 5 (نفس Resonance)
    Track(UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseWheel or not State.Zoom then return end
        if input.Position.Z > 0 then SetFOV(State.ZoomFOV - 5, true)
        elseif input.Position.Z < 0 then SetFOV(State.ZoomFOV + 5, true) end
    end))

    local occConn
    local function SetOcclusion(mode) pcall(function() lp.DevCameraOcclusionMode = mode end) end

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
    if not LineTypes[State.Texture] then State.Texture = "Chain 2" end

    -- نص معلومات الشيء الممسوك (يظهر أسفل الشاشة)
    local InfoGui, InfoLabel
    do
        local gui = Instance.new("ScreenGui")
        gui.Name = "TM_" .. tostring(math.random(100000, 999999))
        gui.ResetOnSpawn = false; gui.DisplayOrder = 40
        local ok = pcall(function() gui.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
        if not ok or not gui.Parent then gui.Parent = lp:WaitForChild("PlayerGui") end
        InfoGui = gui
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
        if not State.Extend or State.Zoom then return end
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

        -- تدوير / قذف الشيء الممسوك (منطق Grabs.Spin و Grabs.Fling في Resonance: RotVelocity على GrabPart).
        -- نطبّقها على الأشياء فقط: مو لاعبين، ومو قطع الماب
        if (State.GrabSpin or State.GrabFling) and grabPart and grabPart:FindFirstChild("GrabAttach")
            and part1 and part1.Parent and part1.Parent ~= Workspace
            and not Players:GetPlayerFromCharacter(part1.Parent) then
            local map = Workspace:FindFirstChild("Map")
            if not (map and part1:IsDescendantOf(map)) then
                task.spawn(function()
                    while part1 and part1.Parent and child.Parent and Alive()
                        and (State.GrabSpin or State.GrabFling) and task.wait() do
                        local v = State.GrabFling and 1500 or 50 -- قذف 1500، تدوير 50 (نفس قيم Resonance)
                        pcall(function() grabPart.RotVelocity = Vector3.new(v, v, v) end)
                    end
                end)
            end
        end

        -- تطويل الخط: ننسخ DragPart ونحركه أمام الكاميرا بالمسافة المختارة
        if State.Extend and dragPart then
            pcall(function()
                local clone = dragPart:Clone()
                clone.Name = "DragPart1"
                clone.AlignPosition.Attachment1 = clone.DragAttach
                clone.Parent = child
                local cam0 = Cam()
                if cam0 then lineDist = (clone.Position - cam0.CFrame.Position).Magnitude end
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
                        if cam then
                            clone.Position = cam.CFrame.Position + cam.CFrame.LookVector * lineDist
                        end
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
                if InfoLabel and InfoLabel.Parent then InfoLabel.Visible = false end
            end)
        end

        -- القوة الخارقة: بعد الرمي نعطي الشيء سرعة باتجاه الكاميرا لمدة ثانية
        if State.Strength and part1 and part1:IsA("BasePart") then
            local function boost()
                if not (part1 and part1.Parent) then return end
                local cam = Cam()
                if not cam then return end
                local bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bv.Velocity = cam.CFrame.LookVector * State.StrengthValue
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
        local spawn = RSpawnToy()
        if not spawn then return Notify(TF("tm.noremote", "SpawnToy")) end
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
                    pcall(function() spawn:InvokeServer(State.ToyName, pos, rot) end)
                end)
                task.wait(0.4)
            end
            spawning = false
        end)
    end

    -- نفس مفتاح "Spawn Pallet" في Resonance: باليت عند مكان الكاميرا
    local function SpawnPallet()
        local spawn, cam = RSpawnToy(), Cam()
        if not spawn then return Notify(TF("tm.noremote", "SpawnToy")) end
        if not cam then return end
        local rp = Workspace:FindFirstChild("RotateOrientPart")
        local rot = rp and rp.Rotation or Vector3.zero
        task.spawn(function()
            pcall(function() spawn:InvokeServer("PalletLightBrown", cam.CFrame, rot) end)
        end)
    end

    local function ClearToys()
        local f, destroy = ToyFolder(), RDestroyToy()
        if not (f and destroy) then return Notify(TF("tm.noremote", "DestroyToy")) end
        local n = 0
        for _, c in ipairs(f:GetChildren()) do
            if c:IsA("Model") then destroy:FireServer(c); n = n + 1 end
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

    -- مواقع محفوظة (A / B) لكل ماب
    local placeKey = tostring(game.PlaceId)
    local function SaveSpot(slot)
        local _, root = Char()
        if not root then return Notify(TX("tm.nochar")) end
        if type(Saved.Spots) ~= "table" then Saved.Spots = {} end
        if type(Saved.Spots[placeKey]) ~= "table" then Saved.Spots[placeKey] = {} end
        local p = root.Position
        Saved.Spots[placeKey][slot] = { x = p.X, y = p.Y, z = p.Z }
        SaveSoon()
        Notify(TF("tm.map.saved", slot))
    end
    local function GoSpot(slot)
        local spots = type(Saved.Spots) == "table" and Saved.Spots[placeKey]
        local s = type(spots) == "table" and spots[slot]
        if type(s) ~= "table" or type(s.x) ~= "number" or type(s.y) ~= "number" or type(s.z) ~= "number" then
            return Notify(TF("tm.map.nosaved", slot))
        end
        TeleportTo(CFrame.new(s.x, s.y + 3, s.z))
    end

    -- ═════════ لوحة سريعة على الشاشة: أزرار تشغيل / إيقاف لأهم الدفاعات (تنفع للجوال) ═════════
    local QP = {}
    do
        local keys = {
            { "AntiGrab", "tm.qp.grab" }, { "AntiBlobman", "tm.qp.blob" },
            { "AntiSnowball", "tm.qp.snow" }, { "AntiExplosion", "tm.qp.expl" },
        }
        local BW, BH, GAP, BAR = 62, 34, 4, 16
        local W, H = BW * 2 + GAP, BAR + 4 + BH * 2 + GAP
        local fr = Instance.new("Frame")
        fr.Name = "QuickPanel"; fr.BackgroundTransparency = 1
        fr.Size = UDim2.new(0, W, 0, H)
        fr.Position = UDim2.new(math.clamp(SV("QPX", 0.02), 0, 0.95), 0, math.clamp(SV("QPY", 0.3), 0, 0.9), 0)
        fr.Visible = false; fr.Parent = InfoGui

        local btns = {}
        for i, k in ipairs(keys) do
            local col, row = (i - 1) % 2, math.floor((i - 1) / 2)
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(0, BW, 0, BH)
            b.Position = UDim2.new(0, col * (BW + GAP), 0, BAR + 4 + row * (BH + GAP))
            b.BackgroundColor3 = Color3.fromRGB(20, 20, 28); b.BackgroundTransparency = 0.2
            b.AutoButtonColor = false; b.Text = TX(k[2])
            b.TextColor3 = Color3.fromRGB(225, 225, 238)
            b.Font = Enum.Font.GothamBold; b.TextSize = 10; b.TextWrapped = true
            b.Parent = fr
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
            local st = Instance.new("UIStroke", b)
            st.Thickness = 1.2; st.Color = C_BLUE; st.Transparency = 0.5
            b.MouseButton1Click:Connect(function()
                local set = Setters[k[1]]
                if set then set(not Applied[k[1]]) end
            end)
            btns[#btns + 1] = { b = b, st = st, key = k[1] }
        end

        -- شريط السحب
        local bar = Instance.new("TextButton")
        bar.Size = UDim2.new(1, 0, 0, BAR); bar.Position = UDim2.new(0, 0, 0, 0)
        bar.BackgroundColor3 = Color3.fromRGB(30, 30, 42); bar.BackgroundTransparency = 0.2
        bar.Text = "• • •"; bar.TextColor3 = Color3.fromRGB(170, 170, 190)
        bar.Font = Enum.Font.GothamBold; bar.TextSize = 11; bar.AutoButtonColor = false
        bar.Parent = fr
        Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 8)

        local dragging, startIn, startPx
        local function isPress(i)
            return i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1
        end
        bar.InputBegan:Connect(function(i)
            if not isPress(i) then return end
            dragging = i; startIn = i.Position
            local abs = InfoGui.AbsoluteSize
            startPx = Vector2.new(fr.Position.X.Scale * abs.X, fr.Position.Y.Scale * abs.Y)
        end)
        Track(UserInputService.InputChanged:Connect(function(i)
            if not dragging then return end
            local moving = (dragging.UserInputType == Enum.UserInputType.Touch and i == dragging)
                or (dragging.UserInputType == Enum.UserInputType.MouseButton1 and i.UserInputType == Enum.UserInputType.MouseMovement)
            if not moving then return end
            local abs = InfoGui.AbsoluteSize
            if abs.X <= 0 or abs.Y <= 0 then return end
            local nx = math.clamp(startPx.X + (i.Position.X - startIn.X), 0, math.max(0, abs.X - W))
            local ny = math.clamp(startPx.Y + (i.Position.Y - startIn.Y), 0, math.max(0, abs.Y - H))
            fr.Position = UDim2.new(nx / abs.X, 0, ny / abs.Y, 0)
        end))
        Track(UserInputService.InputEnded:Connect(function(i)
            if dragging and (i == dragging or (dragging.UserInputType == Enum.UserInputType.MouseButton1
                and i.UserInputType == Enum.UserInputType.MouseButton1)) then
                dragging = nil
                Saved.QPX, Saved.QPY = fr.Position.X.Scale, fr.Position.Y.Scale
                SaveSoon()
            end
        end))

        -- تلوين الأزرار حسب الحالة
        local acc2 = 0
        Track(RunService.Heartbeat:Connect(function(dt)
            acc2 = acc2 + dt
            if acc2 < 0.25 or not fr.Visible then return end
            acc2 = 0
            for _, e in ipairs(btns) do
                local on = Applied[e.key]
                e.b.BackgroundColor3 = on and C_GREEN or Color3.fromRGB(20, 20, 28)
                e.b.BackgroundTransparency = on and 0.65 or 0.2
                e.st.Color = on and C_GREEN or C_BLUE
            end
        end))
        QP.frame = fr
    end

    -- ═════════ تنظيف كامل عند إعادة التشغيل: يرجّع كل ميزة كانت مفعّلة ═════════
    getgenv().TM_Cleanup = function()
        for key, fn in pairs(Applyers) do
            if Applied[key] then pcall(fn, false) end
        end
        pcall(RestoreBlob)
        UnbindZoom()
        if fovTween then pcall(function() fovTween:Cancel() end) end
        if Saved.FOV ~= nil and Cam() then pcall(function() Cam().FieldOfView = origFOV end) end
        if occConn then pcall(function() occConn:Disconnect() end) end
        for _, c in ipairs(Conns) do pcall(function() c:Disconnect() end) end
        table.clear(Conns)
        ClearCharConns()
        if InfoGui then pcall(function() InfoGui:Destroy() end) end
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
    Feature(secDef, "QuickPanel", TX("tm.qp.toggle"), function(v)
        if QP.frame then QP.frame.Visible = v end
    end)
    Feature(secDef, "AntiGrab", TX("tm.anti.grab"), function(v)
        if v and not RStruggle() then Notify(TF("tm.noremote", "Struggle")) end
    end)
    do
        local items = {
            { id = "Normal", text = TX("tm.anti.normal") },
            { id = "Strong", text = TX("tm.anti.strong") },
        }
        local idx = (State.AntiGrabType == "Strong") and 2 or 1
        Dropdown(secDef, TX("tm.anti.grab.type"), items, idx, function(id)
            State.AntiGrabType = id
            Saved.AntiGrabType = id; SaveSoon()
        end)
    end
    Feature(secDef, "AntiBlobman", TX("tm.anti.blobman"), function(v)
        if not v then RestoreBlob() end
    end)
    Feature(secDef, "AntiSnowball", TX("tm.anti.snowball"), function() end)
    Feature(secDef, "AntiExplosion", TX("tm.anti.explosion"), function() end)
    Feature(secDef, "AntiBurn", TX("tm.anti.burn"), function() end)
    Feature(secDef, "AntiSticky", TX("tm.anti.sticky"), function() end)
    Feature(secDef, "AntiPaint", TX("tm.anti.paint"), function(v)
        task.spawn(SetTouch, "PaintPlayerPart", not v, false)
    end)
    Feature(secDef, "AntiPoison", TX("tm.anti.poison"), function(v)
        task.spawn(function()
            SetTouch("PoisonHurtPart", not v, true)
            SetTouch("PaintPlayerPart", not v, true)
        end)
    end)
    Feature(secDef, "AntiVoid", TX("tm.anti.void"), function() end)
    Feature(secDef, "AntiInvis", TX("tm.anti.invis"), function() end)
    Feature(secDef, "AntiLag", TX("tm.anti.lag"), function(v) SetLagScripts(v) end)

    -- ── رد الهجوم ──
    local secCA = MakeSection("counter", TX("tm.sec.counter"), C_RED, false)
    do
        local items = {
            { id = "Notify",   text = TX("tm.ca.notify") },
            { id = "GrabBack", text = TX("tm.ca.grabback") },
            { id = "Escape",   text = TX("tm.ca.escape") },
            { id = "Spawn",    text = TX("tm.ca.spawn") },
        }
        local idx = 1
        for i, it in ipairs(items) do if it.id == State.CounterMode then idx = i end end
        Dropdown(secCA, TX("tm.ca.mode"), items, idx, function(id)
            State.CounterMode = id
            Saved.CounterMode = id; SaveSoon()
        end)
    end
    Feature(secCA, "Counter", TX("tm.ca.enable"), function() end)
    lastLabel = InfoCard(secCA, "")
    UpdateLastLabel()

    -- ── الخط ──
    local secLine = MakeSection("line", TX("tm.sec.line"), C_PURPLE, false)
    Feature(secLine, "Extend", TX("tm.line.extend"), function() end)
    InSection(secLine, function()
        AddSlider(TX("tm.line.speed"), 1, 15, State.ExtendSpeed, 1, "", function(v)
            State.ExtendSpeed = v
            Saved.ExtendSpeed = v; SaveSoon()
        end)
    end)
    Feature(secLine, "Strength", TX("tm.line.strength.on"), function() end)
    InSection(secLine, function()
        AddSlider(TX("tm.line.strength"), 300, 5000, State.StrengthValue, 100, "", function(v)
            State.StrengthValue = v
            Saved.StrengthValue = v; SaveSoon()
        end)
    end)
    do
        local items = {}
        for _, n in ipairs(LineNames) do items[#items + 1] = { id = n, text = n } end
        local idx = table.find(LineNames, State.Texture) or 1
        Dropdown(secLine, TX("tm.line.texture"), items, idx, function(id)
            State.Texture = id
            Saved.Texture = id; SaveSoon()
        end)
    end
    Feature(secLine, "TextureOn", TX("tm.line.texture.on"), function() end)
    Feature(secLine, "Info", TX("tm.line.info"), function(v)
        if not v and InfoLabel then InfoLabel.Visible = false end
    end)
    Feature(secLine, "GrabSpin", TX("tm.line.spin"), function() end)
    Feature(secLine, "GrabFling", TX("tm.line.fling"), function() end)

    -- ── الألعاب ──
    local secToys = MakeSection("toys", TX("tm.sec.toys"), C_ORANGE, false)
    do
        local items = {
            { id = "NinjaShuriken",    text = "NinjaShuriken" },
            { id = "PalletLightBrown", text = "PalletLightBrown" },
            { id = "YouDecoy",         text = "YouDecoy" },
        }
        local idx = 1
        for i, it in ipairs(items) do if it.id == State.ToyName then idx = i end end
        Dropdown(secToys, TX("tm.toys.pick"), items, idx, function(id)
            State.ToyName = id
            Saved.ToyName = id; SaveSoon()
        end)
    end
    InSection(secToys, function()
        AddSlider(TX("tm.toys.amount"), 1, 10, State.Amount, 1, "", function(v)
            State.Amount = v
            Saved.Amount = v; SaveSoon()
        end)
    end)
    Grid(secToys, {
        { text = TX("tm.toys.spawn"), fn = SpawnToys },
        { text = TX("tm.toys.clear"), color = C_RED, fn = ClearToys },
        { text = TX("tm.toys.pallet"), color = C_CYAN, fn = SpawnPallet },
    })
    do
        local L = InfoCard(secToys, TF("tm.toys.count", CountToys()))
        local a = 0
        Track(RunService.Heartbeat:Connect(function(dt)
            a = a + dt
            if a < 1 then return end
            a = 0
            pcall(function() L.Text = TF("tm.toys.count", CountToys()) end)
        end))
    end

    -- ── الكاميرا (من Resonance) ──
    local secCam = MakeSection("cam", TX("tm.sec.cam"), C_GREEN, false)
    Feature(secCam, "Zoom", TX("tm.cam.zoom"), function(v)
        UnbindZoom()
        if v then
            RunService:BindToRenderStep("TMZoom", Enum.RenderPriority.Camera.Value + 1, UpdateZoomCamera)
            local cam = Cam()
            zoomCF = cam and cam.CFrame or nil
            TweenFOV(State.ZoomFOV, 0.35)
        else
            zoomCF = nil
            TweenFOV(Saved.FOV ~= nil and State.FOV or origFOV, 0.35) -- نرجع لزاويتك أو للأصلية
        end
    end)
    InSection(secCam, function()
        AddSlider(TX("tm.cam.zoomfov"), 10, 120, State.ZoomFOV, 5, "", function(v)
            State.ZoomFOV = v; Saved.ZoomFOV = v; SaveSoon()
            if State.Zoom then TweenFOV(v, 0.2) end
        end)
        AddSlider(TX("tm.cam.fov"), 30, 120, State.FOV, 5, "", function(v)
            SetFOV(v, false)
        end)
    end)
    Feature(secCam, "ThirdPerson", TX("tm.cam.third"), function(v)
        if v then
            pcall(function() lp.CameraMode = Enum.CameraMode.Classic end)
            if not pcall(function() lp.CameraMaxZoomDistance = math.huge end) then
                pcall(function() lp.CameraMaxZoomDistance = 1e6 end)
            end
            pcall(function() lp.CameraMinZoomDistance = 0.5 end)
        else
            pcall(function() lp.CameraMode = origCamMode end)
            pcall(function() lp.CameraMaxZoomDistance = origMaxZoom end)
            pcall(function() lp.CameraMinZoomDistance = origMinZoom end)
        end
    end)
    Feature(secCam, "CamNoclip", TX("tm.cam.noclip"), function(v)
        if occConn then occConn:Disconnect(); occConn = nil end
        if v then
            SetOcclusion(Enum.DevCameraOcclusionMode.Invisicam)
            occConn = lp:GetPropertyChangedSignal("DevCameraOcclusionMode"):Connect(function()
                if State.CamNoclip and lp.DevCameraOcclusionMode ~= Enum.DevCameraOcclusionMode.Invisicam then
                    SetOcclusion(Enum.DevCameraOcclusionMode.Invisicam)
                end
            end)
        else
            SetOcclusion(origOcclusion)
        end
    end)

    -- ── الماب ──
    local secMap = MakeSection("map", TX("tm.sec.map"), C_CYAN, false)

    -- منع الموت بالفراغ: FallenPartsDestroyHeight = NaN (ويرجع لقيمته الأصلية عند الإيقاف)
    local origFallen = Workspace.FallenPartsDestroyHeight
    if origFallen ~= origFallen then origFallen = -100 end
    Feature(secMap, "NoVoid", TX("tm.map.novoid"), function(v)
        Workspace.FallenPartsDestroyHeight = v and (0 / 0) or origFallen
    end)

    -- اختراق حواجز البيوت: CanCollide = false (ويرجع لقيمته الأصلية)
    local barrierOrig = setmetatable({}, { __mode = "k" })
    local function ApplyBarriers(on)
        local plots = Workspace:FindFirstChild("Plots")
        if not plots then return end
        for _, plot in ipairs(plots:GetChildren()) do
            local barrier = plot:FindFirstChild("Barrier")
            if barrier then
                for _, part in ipairs(barrier:GetChildren()) do
                    if part:IsA("BasePart") and part.Name == "PlotBarrier" then
                        if on then
                            if barrierOrig[part] == nil then barrierOrig[part] = part.CanCollide end
                            part.CanCollide = false
                        else
                            local o = barrierOrig[part]
                            part.CanCollide = (o == nil) and true or o
                            barrierOrig[part] = nil
                        end
                    end
                end
            end
        end
    end
    Feature(secMap, "Barriers", TX("tm.map.barrier"), function(v) ApplyBarriers(v) end)
    Track(Workspace.DescendantAdded:Connect(function(d) -- بيوت تنضاف بعدين
        if State.Barriers and d.Name == "PlotBarrier" and d:IsA("BasePart") then
            if barrierOrig[d] == nil then barrierOrig[d] = d.CanCollide end
            d.CanCollide = false
        end
    end))

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
                    if inst and inst.Parent then TeleportTo(inst:GetPivot() + Vector3.new(0, 5, 0)) end
                end },
            })
        end
    end
    Grid(secMap, {
        { text = TX("tm.map.spawn"), fn = function()
            local cf = SpawnCF()
            if cf then TeleportTo(cf) end
        end },
        { text = TX("tm.map.safe"), fn = function()
            if safeCF then TeleportTo(safeCF + Vector3.new(0, 3, 0)) else Notify(TX("tm.map.nosafe")) end
        end },
        { text = TX("tm.map.saveA"), fn = function() SaveSpot("A") end },
        { text = TX("tm.map.goA"),   fn = function() GoSpot("A") end },
        { text = TX("tm.map.saveB"), fn = function() SaveSpot("B") end },
        { text = TX("tm.map.goB"),   fn = function() GoSpot("B") end },
    })
end

-- ============================================================
-- 3. إرجاع الجدول (نفس صيغة MM2)
-- ============================================================
return {
    Name   = "Throw Map",
    Render = Render,
}
