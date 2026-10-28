-- [[ Cryptic Hub - Map: Dhab Hunt (صيد ضبان) — v2 ]]
-- الحقوق: سكربت kwarpex (discord.gg/76wNYBeDxR) + أفكار من MAX Hub — الحقوق محفوظة لأصحابها.
-- نفس نظام MM2: الملف يرجع { Name, Render } والهب يستدعي Render(tab, UI).
-- PlaceId: سجّل رقم اللعبة في الـ loader عندك بنفس طريقة MM2.
--
-- التعرّف على الضبان يدعم الطريقتين (عشان لو واحدة قديمة تشتغل الثانية):
--   1) المجلد Workspace.DhabWild  (طريقة kwarpex)
--   2) مسح الموديلات اللي فيها Attribute اسمه Tier (T1..T6) — طريقة MAX
-- وفي الواجهة سطر حالة يوضح كم ضب انلقى وبأي طريقة، فتعرف بسرعة لو اللعبة تغيّرت.

local function Render(tab, UI)
    -- ── إدارة التشغيل المتكرر: كل Render له رقم، وأي لوب قديم ينتهي لحاله ──
    getgenv().Dhab_RunId = (getgenv().Dhab_RunId or 0) + 1
    local RUN = getgenv().Dhab_RunId
    local function Alive() return getgenv().Dhab_RunId == RUN end

    if type(getgenv().Dhab_Cleanup) == "function" then
        pcall(getgenv().Dhab_Cleanup)
    end
    local Conns = {}
    local function TrackConn(c) Conns[#Conns + 1] = c; return c end

    local Players          = game:GetService("Players")
    local RunService       = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local Lighting         = game:GetService("Lighting")
    local Workspace        = game:GetService("Workspace")
    local TweenService     = game:GetService("TweenService")
    local StarterGui       = game:GetService("StarterGui")
    local HttpService      = game:GetService("HttpService")
    local GuiService       = game:GetService("GuiService")
    local TeleportService  = game:GetService("TeleportService")

    local lp       = Players.LocalPlayer
    local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

    local C_GREEN  = Color3.fromRGB(0, 255, 150)
    local C_CYAN   = Color3.fromRGB(0, 205, 255)
    local C_ORANGE = Color3.fromRGB(255, 150, 50)
    local C_RED    = Color3.fromRGB(255, 90, 90)
    local C_PURPLE = Color3.fromRGB(150, 120, 255)
    local DIM      = Color3.fromRGB(110, 110, 130)
    local CARD     = Color3.fromRGB(16, 16, 22)
    local PAGE     = tab.Page

    local TierColors = {
        T1 = Color3.fromRGB(150, 160, 175), T2 = Color3.fromRGB(70, 160, 95),
        T3 = Color3.fromRGB(65, 130, 195),  T4 = Color3.fromRGB(150, 100, 200),
        T5 = Color3.fromRGB(255, 180, 50),  T6 = Color3.fromRGB(255, 50, 70),
    }

    local function Tw2(o, p, t)
        TweenService:Create(o, TweenInfo.new(t or 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), p):Play()
    end

    local function Notify(title, text, dur)
        pcall(function()
            StarterGui:SetCore("SendNotification", { Title = title, Text = text, Duration = dur or 4 })
        end)
    end

    -- ── الإعدادات المحفوظة (الأرقام والخيارات فقط؛ مفاتيح التشغيل الرئيسية ترجع مطفية) ──
    local SAVE_FILE = "Cryptic_DhabHunt.json"
    local Cfg = {
        EspDist = 500, RareAlerts = true, AimDist = 100, FOV = 120,
        UseFOV = true, NeedTool = true, HoldAim = false,
        AntiAfk = true, AutoRejoin = true,
    }
    pcall(function()
        if isfile and readfile and isfile(SAVE_FILE) then
            local d = HttpService:JSONDecode(readfile(SAVE_FILE))
            if type(d) == "table" then
                for k, v in pairs(d) do
                    if Cfg[k] ~= nil and type(v) == type(Cfg[k]) then Cfg[k] = v end
                end
            end
        end
    end)
    Cfg.EspDist = math.clamp(Cfg.EspDist, 100, 3000)
    Cfg.AimDist = math.clamp(Cfg.AimDist, 20, 300)
    Cfg.FOV     = math.clamp(Cfg.FOV, 40, 300)

    local saveToken = 0
    local function SaveSoon() -- نكتب الملف مرة وحدة بعد ما تهدأ التغييرات (السلايدر يغيّر كثير)
        saveToken = saveToken + 1
        local my = saveToken
        task.delay(1, function()
            if my ~= saveToken or not writefile then return end
            pcall(function() writefile(SAVE_FILE, HttpService:JSONEncode(Cfg)) end)
        end)
    end

    -- ── النصوص (إنجليزي + عربي، وباقي اللغات تأخذ الإنجليزي) ──
    local NEW = {
        en = {
            ["dhab.section.visuals"] = "👁️  Visuals",
            ["dhab.section.aim"]     = "🎯  Aim",
            ["dhab.section.utils"]   = "🛡️  Utilities",
            ["dhab.esp"]             = "Dhab ESP (all)",
            ["dhab.rare"]            = "Rare ESP only (Legendary / Mythic)",
            ["dhab.night"]           = "Night Vision",
            ["dhab.shop"]            = "Ezba Shop ESP",
            ["dhab.alerts"]          = "Smart Alerts (rare nearby)",
            ["dhab.espdist"]         = "ESP Distance",
            ["dhab.aim"]             = "Aim at Heaviest Dhab",
            ["dhab.needtool"]        = "Require equipped weapon",
            ["dhab.usefov"]          = "Show FOV circle",
            ["dhab.holdaim"]         = "Aim only while holding right-click / touch",
            ["dhab.aimdist"]         = "Aim Distance",
            ["dhab.fov"]             = "FOV Radius",
            ["dhab.antiafk"]         = "Anti-AFK",
            ["dhab.rejoin"]          = "Auto Rejoin on disconnect",
            ["dhab.weight"]          = "Weight: ",
            ["dhab.stopall"]         = "Stop All",
            ["dhab.credit"]          = "By kwarpex · txn server · ideas from MAX Hub",
            ["dhab.card.none"]       = "🔍 No rare dhab in range",
            ["dhab.card.closest"]    = "⭐ Closest rare:",
            ["dhab.card.status"]     = "Dhabs found: %d  ·  source: %s",
            ["dhab.card.off"]        = "Turn on ESP, Rare ESP, Aim or Alerts to scan",
            ["dhab.alert"]           = "%s dhab nearby (%s) — %dm",
            ["dhab.shop.label"]      = "⛺ Ezba Shop [%dm]",
            ["dhab.tier.T1"] = "Common",   ["dhab.tier.T2"] = "Uncommon", ["dhab.tier.T3"] = "Rare",
            ["dhab.tier.T4"] = "Epic",     ["dhab.tier.T5"] = "Legendary", ["dhab.tier.T6"] = "Mythic",
            ["dhab.state.idle"] = "Idle 🧍", ["dhab.state.walk"] = "Walking 🚶", ["dhab.state.flee"] = "Fleeing 🏃",
            ["dhab.state.alert"] = "Alert ⚠️", ["dhab.state.display"] = "Displaying ✨",
        },
        ar = {
            ["dhab.section.visuals"] = "👁️  الكشف والرؤية",
            ["dhab.section.aim"]     = "🎯  التصويب",
            ["dhab.section.utils"]   = "🛡️  أدوات",
            ["dhab.esp"]             = "كشف الضبان (الكل)",
            ["dhab.rare"]            = "كشف النادر فقط (أسطوري / خرافي)",
            ["dhab.night"]           = "الرؤية الليلية",
            ["dhab.shop"]            = "كشف محل العزب",
            ["dhab.alerts"]          = "تنبيه ذكي (ضب نادر قريب)",
            ["dhab.espdist"]         = "مسافة الكشف",
            ["dhab.aim"]             = "تصويب على أثقل ضب",
            ["dhab.needtool"]        = "يلزم إشهار السلاح",
            ["dhab.usefov"]          = "إظهار دائرة التصويب (FOV)",
            ["dhab.holdaim"]         = "التصويب فقط مع كليك يمين / لمس",
            ["dhab.aimdist"]         = "مسافة التصويب",
            ["dhab.fov"]             = "حجم دائرة FOV",
            ["dhab.antiafk"]         = "منع الخمول (Anti-AFK)",
            ["dhab.rejoin"]          = "إعادة الدخول عند الفصل",
            ["dhab.weight"]          = "وزنه: ",
            ["dhab.stopall"]         = "إيقاف الكل",
            ["dhab.credit"]          = "من صنع kwarpex · سيرفر txn · أفكار من MAX Hub",
            ["dhab.card.none"]       = "🔍 لا يوجد ضب نادر في النطاق",
            ["dhab.card.closest"]    = "⭐ أقرب ضب نادر:",
            ["dhab.card.status"]     = "الضبان الملقية: %d  ·  المصدر: %s",
            ["dhab.card.off"]        = "شغّل الكشف أو التنبيه أو التصويب عشان يبدأ المسح",
            ["dhab.alert"]           = "ضب %s قريب (%s) — %d متر",
            ["dhab.shop.label"]      = "⛺ محل العزب [%d م]",
            ["dhab.tier.T1"] = "عادي",  ["dhab.tier.T2"] = "مميز",  ["dhab.tier.T3"] = "نادر",
            ["dhab.tier.T4"] = "فاخر",  ["dhab.tier.T5"] = "أسطوري", ["dhab.tier.T6"] = "خرافي",
            ["dhab.state.idle"] = "واقف 🧍", ["dhab.state.walk"] = "يمشي 🚶", ["dhab.state.flee"] = "يهرب 🏃",
            ["dhab.state.alert"] = "منتبه ⚠️", ["dhab.state.display"] = "يستعرض ✨",
        },
    }
    local i18n = getgenv().CrypticI18n
    if i18n and i18n.Register then
        for lang, t in pairs(NEW) do pcall(i18n.Register, lang, t) end
    end
    local function TX(k)
        local s
        if i18n and i18n.T then
            local ok, v = pcall(i18n.T, k)
            if ok then s = v end
        end
        if s == nil or s == "" or s == k then return NEW.en[k] or k end
        return s
    end

    -- ── حاوية تمرير خاصة (نفس MM2): ارتفاعها يتبع الجزء المرئي من النافذة ──
    local HOST = PAGE
    do
        local sc = Instance.new("ScrollingFrame")
        sc.Name = "DhabScroll"
        sc.BackgroundTransparency = 1; sc.BorderSizePixel = 0
        sc.LayoutOrder = 0
        sc.Active = true
        sc.ScrollingEnabled = true
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
        pd.PaddingBottom = UDim.new(0, 16)
        pcall(function() HOST.ScrollingEnabled = false end)

        -- Absolute* بالبكسل المرسوم (بعد UIScale) و Size/Padding بالوحدات المحلية → نحوّل بالقسمة على السكيل
        local GRIP_PX = 36 -- = RESIZE_HIT_AREA_PX (32) + RESIZE_SAFE_GAP_PX (4) في الكور
        local function fit()
            local h = 0
            local scale = 1
            local ok = pcall(function()
                local curH = sc.Size.Y.Offset
                if curH > 0 and sc.AbsoluteSize.Y > 0 then
                    scale = math.clamp(sc.AbsoluteSize.Y / curH, 0.2, 5)
                end
                h = HOST.AbsoluteWindowSize.Y
                local a = HOST.Parent
                while a and a:IsA("GuiObject") do
                    if a.ClipsDescendants then
                        local visibleBottom = a.AbsolutePosition.Y + a.AbsoluteSize.Y
                        h = math.min(h, visibleBottom - sc.AbsolutePosition.Y)
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
        local acc = 0
        TrackConn(RunService.Heartbeat:Connect(function(dt)
            acc = acc + dt
            if acc < 0.2 then return end
            acc = 0
            fit()
        end))
        task.defer(fit)
        PAGE = sc
        tab.Page = sc
    end

    getgenv().Dhab_SecOpen = getgenv().Dhab_SecOpen or {}
    local SecOpen = getgenv().Dhab_SecOpen

    -- ═════════════ منطق اللعبة ═════════════
    local State = { detect = false, rare = false, night = false, shop = false, aim = false }

    -- حاوية الـ ESP: كائناتنا فقط (ما نلمس كائنات اللعبة)
    local EspGui = Instance.new("ScreenGui")
    EspGui.Name = "Dhab_" .. tostring(math.random(100000, 999999))
    EspGui.ResetOnSpawn = false
    EspGui.DisplayOrder = 50
    do
        local parented = pcall(function() EspGui.Parent = game:GetService("CoreGui") end)
        if not parented or not EspGui.Parent then
            local hui
            if type(gethui) == "function" then
                local okH, res = pcall(gethui)
                if okH and typeof(res) == "Instance" then hui = res end
            end
            EspGui.Parent = hui or lp:WaitForChild("PlayerGui")
        end
    end

    -- الرؤية الليلية
    pcall(function()
        local old = Lighting:FindFirstChild("KwarpexNaturalNightVision")
        if old then old:Destroy() end
    end)
    local NightEffect = Instance.new("ColorCorrectionEffect")
    NightEffect.Name = "KwarpexNaturalNightVision"
    NightEffect.Enabled = false
    NightEffect.Brightness = 0.12
    NightEffect.Contrast = 0.05
    NightEffect.Saturation = 0.1
    NightEffect.Parent = Lighting

    -- دائرة FOV (Drawing غير متوفر في كل المنفّذات → نتأكد)
    local fovCircle
    pcall(function()
        if Drawing and Drawing.new then
            fovCircle = Drawing.new("Circle")
            fovCircle.Thickness = 1.5
            fovCircle.Color = C_PURPLE
            fovCircle.Filled = false
            fovCircle.Transparency = 0.7
            fovCircle.Visible = false
        end
    end)

    -- قراءة الوزن الحقيقي من اللعبة (منطق kwarpex)
    local function RawWeight(dhabModel)
        for attrName, attrVal in pairs(dhabModel:GetAttributes()) do
            local lowerName = string.lower(attrName)
            if string.find(lowerName, "weight") or string.find(lowerName, "وزن") or string.find(lowerName, "mass") then
                if type(attrVal) == "number" then return math.floor(attrVal) end
            end
        end

        local hitbox = dhabModel:FindFirstChild("Hitbox")
        if hitbox then
            for attrName, attrVal in pairs(hitbox:GetAttributes()) do
                local lowerName = string.lower(attrName)
                if string.find(lowerName, "weight") or string.find(lowerName, "وزن") or string.find(lowerName, "mass") then
                    if type(attrVal) == "number" then return math.floor(attrVal) end
                end
            end
        end

        for _, child in ipairs(dhabModel:GetDescendants()) do
            if child:IsA("NumberValue") or child:IsA("IntValue") then
                local lowerName = string.lower(child.Name)
                if string.find(lowerName, "weight") or string.find(lowerName, "وزن")
                    or string.find(lowerName, "mass") or string.find(lowerName, "w") then
                    return math.floor(child.Value)
                end
            end
        end

        if hitbox and hitbox:IsA("BasePart") then
            return math.clamp(math.floor(hitbox.Size.X + hitbox.Size.Y + hitbox.Size.Z), 1, 100)
        end
        return 5
    end

    -- كاش للوزن (ثانية وحدة): كان يُحسب لكل ضب في كل فريم ويسبب لاق
    local weightCache = setmetatable({}, { __mode = "k" })
    local function GetWeight(model)
        local now = os.clock()
        local c = weightCache[model]
        if c and now - c.t < 1 then return c.w end
        local w = RawWeight(model)
        weightCache[model] = { w = w, t = now }
        return w
    end

    local function GetPart(model)
        if model:IsA("BasePart") then return model end
        return model:FindFirstChild("Hitbox") or model:FindFirstChild("HumanoidRootPart")
            or model:FindFirstChild("Head") or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
    end

    -- Tier / State من الـ Attributes (طريقة MAX)
    local function ReadInfo(model)
        local tier, state
        for k, v in pairs(model:GetAttributes()) do
            local kl = tostring(k):lower()
            if kl == "tier" then
                local s = tostring(v):upper()
                if TierColors[s] then tier = s end
            elseif kl == "state" then
                state = tostring(v):lower()
            end
        end
        return tier, state
    end

    -- ── جمع الضبان: المجلد أولاً، وإذا فاضي نمسح الـ Workspace كل 3 ثواني ──
    local scanCache, scanT = {}, 0
    local sourceName = "-"
    local function CollectModels()
        local folder = Workspace:FindFirstChild("DhabWild")
        if folder then
            local kids = folder:GetChildren()
            if #kids > 0 then sourceName = "DhabWild"; return kids end
        end
        sourceName = "scan"
        local now = os.clock()
        if now - scanT > 3 then
            scanT = now
            scanCache = {}
            local myChar = lp.Character
            for _, d in ipairs(Workspace:GetDescendants()) do
                if d:IsA("Model") and not Players:GetPlayerFromCharacter(d)
                    and not (myChar and d:IsDescendantOf(myChar)) then
                    if (ReadInfo(d)) then scanCache[#scanCache + 1] = d end
                end
            end
        end
        return scanCache
    end

    local Entries = {}      -- آخر نتيجة مسح (تستعملها الـ ESP والتصويب)
    local lastState = {}    -- آخر حالة معروفة لكل ضب (عشان ما تتغير النص فجأة)
    local notified = setmetatable({}, { __mode = "k" })

    local function StateText(model, rawState)
        if rawState then
            local k = "dhab.state." .. rawState
            if NEW.en[k] then lastState[model] = TX(k) end
        end
        return lastState[model] or TX("dhab.state.idle")
    end

    local function Refresh()
        local char = lp.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local list = {}
        for _, m in ipairs(CollectModels()) do
            if m.Parent then
                local part = GetPart(m)
                if part then
                    local tier, st = ReadInfo(m)
                    list[#list + 1] = {
                        model = m, part = part, tier = tier,
                        state = StateText(m, st),
                        dist = hrp and (hrp.Position - part.Position).Magnitude or math.huge,
                    }
                end
            end
        end
        table.sort(list, function(a, b) return a.dist < b.dist end)
        Entries = list
    end

    -- ── ESP للضبان ──
    local espItems = {}
    local function DestroyItem(item)
        if item.highlight then pcall(function() item.highlight:Destroy() end) end
        if item.billboard then pcall(function() item.billboard:Destroy() end) end
    end
    local function ClearESP()
        for _, item in pairs(espItems) do DestroyItem(item) end
        espItems = {}
    end

    local function UpdateESP()
        if not (State.detect or State.rare) then ClearESP() return end
        local keep = {}
        local shown = 0
        local maxCount = isMobile and 10 or 20 -- أقل على الجوال لمنع التقطيع
        for _, e in ipairs(Entries) do
            if shown >= maxCount then break end
            local isRare = (e.tier == "T5" or e.tier == "T6")
            if e.dist <= Cfg.EspDist and (State.detect or (State.rare and isRare)) then
                shown = shown + 1
                local model = e.model
                keep[model] = true
                local color = (e.tier and TierColors[e.tier]) or C_CYAN

                local item = espItems[model]
                if not item then
                    local hl = Instance.new("Highlight")
                    hl.Name = "DhabESP"
                    hl.Adornee = model
                    hl.FillTransparency = 0.3
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.OutlineTransparency = 0
                    hl.Parent = EspGui

                    local bb = Instance.new("BillboardGui")
                    bb.Name = "DhabTag"
                    bb.Adornee = e.part
                    bb.Size = UDim2.new(0, 190, 0, 46)
                    bb.StudsOffset = Vector3.new(0, 3, 0)
                    bb.AlwaysOnTop = true
                    bb.Parent = EspGui

                    local txt = Instance.new("TextLabel")
                    txt.Size = UDim2.new(1, 0, 1, 0)
                    txt.BackgroundTransparency = 1
                    txt.TextSize = 13
                    txt.Font = Enum.Font.GothamBold
                    txt.TextStrokeTransparency = 0
                    txt.TextWrapped = true
                    txt.Parent = bb

                    item = { highlight = hl, billboard = bb, label = txt }
                    espItems[model] = item
                end
                item.highlight.FillColor = color
                item.label.TextColor3 = color
                local head = e.tier and (TX("dhab.tier." .. e.tier) .. " · " .. e.state) or e.state
                item.label.Text = head .. "\n" .. TX("dhab.weight") .. GetWeight(model) .. " · " .. math.floor(e.dist) .. "m"
            end
        end
        for model, item in pairs(espItems) do
            if not keep[model] or not model.Parent then
                DestroyItem(item)
                espItems[model] = nil
            end
        end
    end

    -- ── ESP محل العزب ──
    local shopItem, shopModel, shopScanT = nil, nil, 0
    local function ClearShop()
        if shopItem then DestroyItem(shopItem); shopItem = nil end
    end
    local function UpdateShop()
        if not State.shop then ClearShop() return end
        local now = os.clock()
        if (not shopModel or not shopModel.Parent) and now - shopScanT > 3 then
            shopScanT = now
            shopModel = Workspace:FindFirstChild("DhabEzbaShop", true) or Workspace:FindFirstChild("EzbaShop", true)
        end
        if not shopModel or not shopModel.Parent then ClearShop() return end
        local part = GetPart(shopModel)
        if not part then ClearShop() return end
        if not shopItem then
            local hl = Instance.new("Highlight")
            hl.Name = "DhabShopESP"; hl.Adornee = shopModel
            hl.FillColor = TierColors.T5; hl.FillTransparency = 0.4
            hl.OutlineColor = Color3.new(1, 1, 1); hl.Parent = EspGui
            local bb = Instance.new("BillboardGui")
            bb.Name = "DhabShopTag"; bb.Adornee = part
            bb.Size = UDim2.new(0, 180, 0, 30); bb.StudsOffset = Vector3.new(0, 6, 0)
            bb.AlwaysOnTop = true; bb.Parent = EspGui
            local txt = Instance.new("TextLabel", bb)
            txt.Size = UDim2.new(1, 0, 1, 0); txt.BackgroundTransparency = 1
            txt.TextColor3 = TierColors.T5; txt.TextSize = 13
            txt.Font = Enum.Font.GothamBold; txt.TextStrokeTransparency = 0
            shopItem = { highlight = hl, billboard = bb, label = txt }
        end
        local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        local d = hrp and math.floor((hrp.Position - part.Position).Magnitude) or 0
        shopItem.label.Text = string.format(TX("dhab.shop.label"), d)
    end

    -- ── بطاقة المعلومات (أقرب ضب نادر + حالة المسح) ──
    local cardLabel
    local function UpdateCard()
        if not cardLabel then return end
        local scanning = State.detect or State.rare or State.aim or Cfg.RareAlerts
        if not scanning then cardLabel.Text = TX("dhab.card.off"); return end
        local rare
        for _, e in ipairs(Entries) do
            if (e.tier == "T5" or e.tier == "T6") and e.dist <= Cfg.EspDist then rare = e; break end
        end
        local l1 = rare
            and (TX("dhab.card.closest") .. " " .. TX("dhab.tier." .. rare.tier) .. " · " .. rare.state .. " · " .. math.floor(rare.dist) .. "m")
            or TX("dhab.card.none")
        cardLabel.Text = l1 .. "\n" .. string.format(TX("dhab.card.status"), #Entries, sourceName)
    end

    local function CheckAlerts()
        if not Cfg.RareAlerts then return end
        for _, e in ipairs(Entries) do
            if (e.tier == "T5" or e.tier == "T6") and e.dist <= 250 and not notified[e.model] then
                notified[e.model] = true
                Notify("Dhab Hunt", string.format(TX("dhab.alert"), TX("dhab.tier." .. e.tier), e.state, math.floor(e.dist)), 5)
            end
        end
    end

    -- ── حلقة المسح: كل 0.4 ثانية فقط، وتوقف إذا ما في شيء شغّال ──
    do
        local acc = 0
        TrackConn(RunService.Heartbeat:Connect(function(dt)
            if not Alive() then return end
            acc = acc + dt
            if acc < 0.4 then return end
            acc = 0
            if State.detect or State.rare or State.aim or Cfg.RareAlerts then
                pcall(Refresh)
                pcall(UpdateESP)
                pcall(CheckAlerts)
            else
                if next(espItems) then ClearESP() end
            end
            pcall(UpdateShop)
            pcall(UpdateCard)
        end))
    end

    -- ── التصويب (كل فريم، على قائمة جاهزة من المسح) ──
    TrackConn(RunService.RenderStepped:Connect(function()
        if not Alive() then return end
        local cam = Workspace.CurrentCamera
        if not cam then return end

        local center
        if isMobile then center = cam.ViewportSize / 2 else center = UserInputService:GetMouseLocation() end
        if fovCircle then
            fovCircle.Position = center
            fovCircle.Radius = Cfg.FOV
            fovCircle.Visible = State.aim and Cfg.UseFOV
        end
        if not State.aim then return end

        local char = lp.Character
        if not char then return end
        if Cfg.NeedTool and not char:FindFirstChildOfClass("Tool") then return end
        if Cfg.HoldAim and not (UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
            or UserInputService.TouchEnabled) then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        -- أثقل ضب داخل المسافة (وداخل الدائرة إذا مفعّلة)؛ عند التساوي الأقرب
        local bestPart, bestW, bestD
        for _, e in ipairs(Entries) do
            local part = e.part
            if e.model.Parent and part and part.Parent then
                local dist = (part.Position - hrp.Position).Magnitude
                if dist <= Cfg.AimDist then
                    local sp, onScreen = cam:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local ok = true
                        if Cfg.UseFOV then
                            ok = (Vector2.new(sp.X, sp.Y) - center).Magnitude <= Cfg.FOV
                        end
                        if ok then
                            local w = GetWeight(e.model)
                            if not bestPart or w > bestW or (w == bestW and dist < bestD) then
                                bestPart, bestW, bestD = part, w, dist
                            end
                        end
                    end
                end
            end
        end
        if bestPart then
            cam.CFrame = CFrame.new(cam.CFrame.Position, bestPart.Position)
        end
    end))

    -- ── Anti-AFK + إعادة الدخول عند الفصل ──
    TrackConn(lp.Idled:Connect(function()
        if not Cfg.AntiAfk then return end
        pcall(function()
            local vu = game:GetService("VirtualUser")
            vu:CaptureController()
            vu:ClickButton2(Vector2.new())
        end)
    end))

    local rejoining = false
    TrackConn(GuiService.ErrorMessageChanged:Connect(function(msg)
        if not Cfg.AutoRejoin or rejoining or not Alive() then return end
        if type(msg) ~= "string" or msg == "" then return end
        rejoining = true
        task.delay(2, function()
            pcall(function() TeleportService:Teleport(game.PlaceId, lp) end)
            task.delay(10, function() rejoining = false end)
        end)
    end))

    -- تنظيف كامل عند إعادة التشغيل
    getgenv().Dhab_Cleanup = function()
        for _, c in ipairs(Conns) do pcall(function() c:Disconnect() end) end
        table.clear(Conns)
        ClearESP(); ClearShop()
        pcall(function() EspGui:Destroy() end)
        pcall(function() NightEffect:Destroy() end)
        if fovCircle then pcall(function() fovCircle:Remove() end) end
    end

    -- ═════════════ الواجهة (نفس نظام أقسام MM2) ═════════════
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

    -- قسم قابل للطي: شريط لون جانبي + عدّاد الميزات المفعّلة
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
        TL.Size = UDim2.new(1, -120, 1, 0); TL.Position = UDim2.new(0, 24, 0, 0)
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

        local sec = { cont = Cont, count = 0, color = color }
        function sec.refresh()
            Badge.Visible = sec.count > 0
            Badge.Text = "ON " .. sec.count
        end

        local isOpen = false
        -- الارتفاع تلقائي حسب المحتوى وهو مفتوح
        local function apply(open, animate)
            isOpen = open; SecOpen[id] = open
            Cont.AutomaticSize = open and Enum.AutomaticSize.Y or Enum.AutomaticSize.None
            Cont.Size = UDim2.new(0.98, 0, 0, 0)
            local d = animate and 0.2 or 0
            Tw2(Arr, { Rotation = open and 90 or 0, TextColor3 = open and color or DIM }, d)
            Tw2(st, { Transparency = open and 0.15 or 0.55 }, d)
        end
        local startOpen = SecOpen[id]
        if startOpen == nil then startOpen = defaultOpen end
        if startOpen then task.defer(function() apply(true, false) end) end
        Hdr.MouseButton1Click:Connect(function() apply(not isOpen, true) end)
        return sec
    end

    -- يدخل عناصر الهب (Toggle) داخل القسم حتى لو حفظ الهب الصفحة داخلياً
    local function InSection(sec, fn)
        local before = {}
        for _, c in ipairs(PAGE:GetChildren()) do before[c] = true end
        tab.Page = sec.cont
        local ok, err = pcall(fn)
        tab.Page = PAGE
        if not ok then
            warn("[Dhab UI] " .. tostring(err))
            local e = Instance.new("TextLabel", sec.cont)
            e.Size = UDim2.new(1, 0, 0, 40); e.BackgroundTransparency = 1
            e.TextWrapped = true; e.TextSize = 11; e.Font = Enum.Font.Gotham
            e.TextColor3 = Color3.fromRGB(255, 120, 120); e.Text = "UI error: " .. tostring(err)
            e.LayoutOrder = 9999
        end
        for _, c in ipairs(PAGE:GetChildren()) do
            if not before[c] and c:IsA("GuiObject") then c.Parent = sec.cont end
        end
    end

    -- توغل يزيد عدّاد القسم تلقائياً. master=true → يتطفّى مع زر "إيقاف الكل"
    local masterToggles = {}
    local function Tog(sec, text, cb, master, initial)
        local on = false
        local t = tab:AddToggle(text, function(v)
            v = v and true or false
            if v ~= on then
                on = v
                sec.count = sec.count + (v and 1 or -1)
                sec.refresh()
            end
            cb(v)
        end)
        if master then masterToggles[#masterToggles + 1] = t end
        if initial then pcall(function() t:SetState(true) end) end
        return t
    end

    -- بطاقة نص صغيرة داخل القسم
    local function InfoCard(sec, color)
        tab.Order = tab.Order + 1
        local F = Instance.new("Frame", sec.cont)
        F.LayoutOrder = tab.Order; F.Size = UDim2.new(0.98, 0, 0, 52)
        F.BackgroundColor3 = CARD; F.BackgroundTransparency = 0.1; F.BorderSizePixel = 0
        Instance.new("UICorner", F).CornerRadius = UDim.new(0, 10)
        local s = Instance.new("UIStroke", F)
        s.Thickness = 1.1; s.Transparency = 0.6; s.Color = color
        local L = Instance.new("TextLabel", F)
        L.Size = UDim2.new(1, -16, 1, -8); L.Position = UDim2.new(0, 8, 0, 4)
        L.BackgroundTransparency = 1; L.TextColor3 = Color3.fromRGB(215, 215, 230)
        L.Font = Enum.Font.GothamSemibold; L.TextSize = 11; L.TextWrapped = true
        L.TextXAlignment = Enum.TextXAlignment.Left; L.TextYAlignment = Enum.TextYAlignment.Center
        L.Text = TX("dhab.card.off")
        return L
    end

    -- ── الأقسام ──
    local secVis = MakeSection("visuals", TX("dhab.section.visuals"), C_CYAN, true)
    InSection(secVis, function()
        cardLabel = InfoCard(secVis, C_CYAN)
        Tog(secVis, TX("dhab.esp"), function(v)
            State.detect = v
            if not v then ClearESP() end
        end, true)
        Tog(secVis, TX("dhab.rare"), function(v)
            State.rare = v
            if not v then ClearESP() end
        end, true)
        Tog(secVis, TX("dhab.night"), function(v)
            State.night = v
            NightEffect.Enabled = v
        end, true)
        Tog(secVis, TX("dhab.shop"), function(v)
            State.shop = v
            if not v then ClearShop() end
        end, true)
        Tog(secVis, TX("dhab.alerts"), function(v)
            Cfg.RareAlerts = v
            SaveSoon()
        end, false, Cfg.RareAlerts)
        AddSlider(TX("dhab.espdist"), 100, 3000, Cfg.EspDist, 100, "m", function(v)
            Cfg.EspDist = v
            SaveSoon()
        end)
    end)

    local secAim = MakeSection("aim", TX("dhab.section.aim"), C_ORANGE, true)
    InSection(secAim, function()
        Tog(secAim, TX("dhab.aim"), function(v)
            State.aim = v
        end, true)
        Tog(secAim, TX("dhab.needtool"), function(v)
            Cfg.NeedTool = v
            SaveSoon()
        end, false, Cfg.NeedTool)
        Tog(secAim, TX("dhab.usefov"), function(v)
            Cfg.UseFOV = v
            SaveSoon()
        end, false, Cfg.UseFOV)
        Tog(secAim, TX("dhab.holdaim"), function(v)
            Cfg.HoldAim = v
            SaveSoon()
        end, false, Cfg.HoldAim)
        AddSlider(TX("dhab.aimdist"), 20, 300, Cfg.AimDist, 10, "m", function(v)
            Cfg.AimDist = v
            SaveSoon()
        end)
        AddSlider(TX("dhab.fov"), 40, 300, Cfg.FOV, 10, "", function(v)
            Cfg.FOV = v
            SaveSoon()
        end)
    end)

    local secUtil = MakeSection("utils", TX("dhab.section.utils"), C_GREEN, false)
    InSection(secUtil, function()
        Tog(secUtil, TX("dhab.antiafk"), function(v)
            Cfg.AntiAfk = v
            SaveSoon()
        end, false, Cfg.AntiAfk)
        Tog(secUtil, TX("dhab.rejoin"), function(v)
            Cfg.AutoRejoin = v
            SaveSoon()
        end, false, Cfg.AutoRejoin)
    end)

    -- ── زر إيقاف الكل (أسفل) ──
    tab.Order = tab.Order + 1
    local StopB = Instance.new("TextButton", PAGE)
    StopB.LayoutOrder = tab.Order; StopB.Size = UDim2.new(0.98, 0, 0, 50)
    StopB.BackgroundColor3 = C_RED; StopB.BackgroundTransparency = 0.8
    StopB.BorderSizePixel = 0; StopB.AutoButtonColor = false
    StopB.Text = "⛔  " .. TX("dhab.stopall")
    StopB.TextColor3 = Color3.fromRGB(255, 200, 200)
    StopB.Font = Enum.Font.GothamBlack; StopB.TextSize = 13
    Instance.new("UICorner", StopB).CornerRadius = UDim.new(0, 12)
    local sbs = Instance.new("UIStroke", StopB)
    sbs.Thickness = 1.4; sbs.Color = C_RED; sbs.Transparency = 0.35
    StopB.MouseButton1Click:Connect(function()
        for _, t in ipairs(masterToggles) do pcall(function() t:SetState(false) end) end
        State.detect, State.rare, State.night, State.shop, State.aim = false, false, false, false, false
        NightEffect.Enabled = false
        ClearESP(); ClearShop()
        StopB.BackgroundTransparency = 0.4
        Tw2(StopB, { BackgroundTransparency = 0.8 }, 0.3)
    end)

    -- ── الحقوق (محفوظة لأصحاب السكربتات الأصلية) + مساحة فاضية آخر الصفحة ──
    tab.Order = tab.Order + 1
    local Credit = Instance.new("TextLabel", PAGE)
    Credit.LayoutOrder = tab.Order; Credit.Size = UDim2.new(0.98, 0, 0, 18)
    Credit.BackgroundTransparency = 1; Credit.Text = TX("dhab.credit")
    Credit.TextColor3 = DIM; Credit.Font = Enum.Font.Gotham; Credit.TextSize = 10
    Credit.TextTruncate = Enum.TextTruncate.AtEnd

    tab.Order = tab.Order + 1
    local sp = Instance.new("Frame", PAGE)
    sp.LayoutOrder = tab.Order; sp.Size = UDim2.new(0.98, 0, 0, 14)
    sp.BackgroundTransparency = 1; sp.BorderSizePixel = 0
end

-- ============================================================
-- إرجاع الجدول (نفس صيغة MM2)
-- ============================================================
return {
    Name   = "Dhab Hunt",
    Render = Render,
}