-- [[ Cryptic Hub - Map: Throw Things & Players ]]
-- نفس صيغة سكربت MM2: يرجع { Name, Render(tab, UI) } ويشتغل داخل واجهة الهب مباشرة
-- الترجمة: عربي + إنجليزي عبر getgenv().CrypticI18n (نفس طريقة MM2)
-- الأقسام: الحماية / الألعاب / الماب

-- ============================================================
-- 1. الترجمة
-- ============================================================
local NEW = {
    en = {
        ["tm.hint"]          = "Tap a section to open / close it",
        ["tm.section.def"]   = "🛡️  Defense",
        ["tm.section.toys"]  = "🧸  Toys",
        ["tm.section.map"]   = "🗺️  Map",
        ["tm.def.antigrab"]  = "Anti-Grab (auto struggle)",
        ["tm.def.antivoid"]  = "Anti-Void (return if thrown away)",
        ["tm.def.noremote"]  = "Struggle remote not found",
        ["tm.toys.name"]     = "Toy name",
        ["tm.toys.pick"]     = "Quick pick",
        ["tm.toys.amount"]   = "Amount",
        ["tm.toys.spawn"]    = "Spawn",
        ["tm.toys.clear"]    = "Delete My Toys",
        ["tm.toys.count"]    = "Your toys: %d",
        ["tm.toys.noremote"] = "Toy remote not found",
        ["tm.toys.cleared"]  = "Deleted %d toys",
        ["tm.toys.noname"]   = "Choose a toy first",
        ["tm.map.select"]    = "Choose location  ▾",
        ["tm.map.go"]        = "Teleport",
        ["tm.map.none"]      = "No locations on this map",
        ["tm.map.nopick"]    = "Choose a location first",
        ["tm.nochar"]        = "Character not ready",
        ["tm.stopall"]       = "Stop All",
        ["tm.stopped"]       = "Everything stopped",
    },
    ar = {
        ["tm.hint"]          = "اضغط على القسم لفتحه أو إغلاقه",
        ["tm.section.def"]   = "🛡️  الحماية",
        ["tm.section.toys"]  = "🧸  الألعاب",
        ["tm.section.map"]   = "🗺️  الماب",
        ["tm.def.antigrab"]  = "منع الإمساك (مقاومة تلقائية)",
        ["tm.def.antivoid"]  = "منع الضياع (يرجعك إذا انرميت بعيد)",
        ["tm.def.noremote"]  = "ما لقيت ريموت المقاومة",
        ["tm.toys.name"]     = "اسم اللعبة",
        ["tm.toys.pick"]     = "اختيار سريع",
        ["tm.toys.amount"]   = "العدد",
        ["tm.toys.spawn"]    = "إنشاء",
        ["tm.toys.clear"]    = "حذف ألعابي",
        ["tm.toys.count"]    = "ألعابك: %d",
        ["tm.toys.noremote"] = "ما لقيت ريموت الألعاب",
        ["tm.toys.cleared"]  = "تم حذف %d لعبة",
        ["tm.toys.noname"]   = "اختر لعبة أولاً",
        ["tm.map.select"]    = "اختر مكان  ▾",
        ["tm.map.go"]        = "انتقال",
        ["tm.map.none"]      = "ما في أماكن في هذا الماب",
        ["tm.map.nopick"]    = "اختر مكان أولاً",
        ["tm.nochar"]        = "الشخصية غير جاهزة",
        ["tm.stopall"]       = "إيقاف الكل",
        ["tm.stopped"]       = "تم إيقاف كل شيء",
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
    local Conns = {}
    getgenv().TM_Conns = Conns
    local function Track(c) Conns[#Conns + 1] = c; return c end

    local i18n = getgenv().CrypticI18n
    local function TX(k)
        local s = i18n and i18n.T and i18n.T(k)
        if s == nil or s == "" or s == k then return NEW.en[k] or k end
        return s
    end

    local Players           = game:GetService("Players")
    local RunService        = game:GetService("RunService")
    local TweenService      = game:GetService("TweenService")
    local StarterGui        = game:GetService("StarterGui")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
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
    local DIM      = Color3.fromRGB(110, 110, 130)
    local CARD     = Color3.fromRGB(16, 16, 22)
    local PAGE     = tab.Page

    -- ── حاوية تمرير خاصة بنا (نفس فكرة MM2: ارتفاعها يتبع النافذة) ──
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
        pd.PaddingBottom = UDim.new(0, 40)
        pcall(function() HOST.ScrollingEnabled = false end)

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

    local allToggles = {}
    local function Tog(sec, text, cb)
        local t = tab:AddToggle(text, function(v) cb(v and true or false) end)
        allToggles[#allToggles + 1] = t
        return t
    end

    local function Grid(sec, items)
        tab.Order = tab.Order + 1
        local G = Instance.new("Frame", sec.cont)
        G.LayoutOrder = tab.Order; G.Size = UDim2.new(0.98, 0, 0, 0)
        G.AutomaticSize = Enum.AutomaticSize.Y; G.BackgroundTransparency = 1
        local GL = Instance.new("UIGridLayout", G)
        GL.CellSize = UDim2.new(0.5, -4, 0, 46)
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

    -- عدّاد بأزرار - / + (بديل بسيط عن السلايدر)
    local function Stepper(sec, text, minV, maxV, defaultV, onChange)
        local R = Card(sec.cont, 50)
        local Lbl = Instance.new("TextLabel", R)
        Lbl.Size = UDim2.new(1, -150, 1, 0); Lbl.Position = UDim2.new(0, 12, 0, 0)
        Lbl.BackgroundTransparency = 1; Lbl.Text = text
        Lbl.TextColor3 = Color3.fromRGB(210, 210, 225)
        Lbl.Font = Enum.Font.GothamSemibold; Lbl.TextSize = 12
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
        local Minus, Plus = mk("-", -122), mk("+", -44)
        local V = Instance.new("TextLabel", R)
        V.Size = UDim2.new(0, 44, 1, 0); V.Position = UDim2.new(1, -86, 0, 0)
        V.BackgroundTransparency = 1; V.Text = tostring(val)
        V.TextColor3 = C_GREEN; V.Font = Enum.Font.GothamBold; V.TextSize = 14
        local function set(n)
            val = math.clamp(n, minV, maxV); V.Text = tostring(val); onChange(val)
        end
        Minus.MouseButton1Click:Connect(function() set(val - 1) end)
        Plus.MouseButton1Click:Connect(function() set(val + 1) end)
        onChange(val)
    end

    -- حقل عنوان + قائمة منسدلة (دروب داون) للقيم النصية
    local function Dropdown(sec, headText, getValues, onPick)
        tab.Order = tab.Order + 1
        local Wrap = Instance.new("Frame", sec.cont)
        Wrap.LayoutOrder = tab.Order; Wrap.Size = UDim2.new(0.98, 0, 0, 0)
        Wrap.AutomaticSize = Enum.AutomaticSize.Y; Wrap.BackgroundTransparency = 1
        local WL = Instance.new("UIListLayout", Wrap)
        WL.SortOrder = Enum.SortOrder.LayoutOrder; WL.Padding = UDim.new(0, 4)

        local Head = Instance.new("TextButton", Wrap)
        Head.LayoutOrder = 1; Head.Size = UDim2.new(1, 0, 0, 46)
        Head.BackgroundColor3 = CARD; Head.BackgroundTransparency = 0.08
        Head.BorderSizePixel = 0; Head.AutoButtonColor = false
        Head.Text = headText; Head.TextColor3 = Color3.fromRGB(210, 210, 225)
        Head.Font = Enum.Font.GothamSemibold; Head.TextSize = 12
        Instance.new("UICorner", Head).CornerRadius = UDim.new(0, 10)
        local hs = Instance.new("UIStroke", Head)
        hs.Thickness = 1.2; hs.Transparency = 0.45; hs.Color = sec.color

        local List = Instance.new("ScrollingFrame", Wrap)
        List.LayoutOrder = 2; List.Size = UDim2.new(1, 0, 0, 0)
        List.BackgroundColor3 = CARD; List.BackgroundTransparency = 0.05
        List.BorderSizePixel = 0; List.ScrollBarThickness = 3
        List.CanvasSize = UDim2.new(0, 0, 0, 0)
        List.AutomaticCanvasSize = Enum.AutomaticSize.Y
        List.Visible = false; List.ClipsDescendants = true
        Instance.new("UICorner", List).CornerRadius = UDim.new(0, 10)
        local LLay = Instance.new("UIListLayout", List)
        LLay.SortOrder = Enum.SortOrder.LayoutOrder; LLay.Padding = UDim.new(0, 3)
        local LPad = Instance.new("UIPadding", List)
        LPad.PaddingTop = UDim.new(0, 4); LPad.PaddingBottom = UDim.new(0, 4)
        LPad.PaddingLeft = UDim.new(0, 4); LPad.PaddingRight = UDim.new(0, 4)

        local open = false
        local function setOpen(v)
            open = v; List.Visible = v
            List.Size = UDim2.new(1, 0, 0, v and 170 or 0)
        end
        local function rebuild()
            for _, c in ipairs(List:GetChildren()) do
                if c:IsA("TextButton") then c:Destroy() end
            end
            for i, v in ipairs(getValues()) do
                local b = Instance.new("TextButton", List)
                b.LayoutOrder = i; b.Size = UDim2.new(1, 0, 0, 34)
                b.BackgroundColor3 = Color3.fromRGB(30, 30, 40); b.BackgroundTransparency = 0.2
                b.BorderSizePixel = 0; b.AutoButtonColor = false
                b.Text = v; b.TextColor3 = Color3.fromRGB(225, 225, 235)
                b.Font = Enum.Font.Gotham; b.TextSize = 12
                Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
                b.MouseButton1Click:Connect(function()
                    Head.Text = "▸  " .. v
                    setOpen(false)
                    onPick(v)
                end)
            end
        end
        Head.MouseButton1Click:Connect(function()
            if not open then rebuild() end
            setOpen(not open)
        end)
    end

    -- ═════════ الريموتات (نفس أسلوب Resonance: مجلد + اسم + مهلة) ═════════
    local function FindRemote(folder, name)
        local f = ReplicatedStorage:WaitForChild(folder, 0.5)
        return f and f:WaitForChild(name, 0.5)
    end
    local Remotes = {
        Struggle   = FindRemote("CharacterEvents", "Struggle"),
        SpawnToy   = FindRemote("MenuToys", "SpawnToyRemoteFunction"),
        DestroyToy = FindRemote("MenuToys", "DestroyToy"),
    }

    -- ═════════ الحالة والمنطق ═════════
    local State = { AntiGrab = false, AntiVoid = false, ToyName = "NinjaShuriken", Amount = 1 }

    local function Root()
        local c = lp.Character
        return c and c:FindFirstChild("HumanoidRootPart")
    end
    local function Hum()
        local c = lp.Character
        return c and c:FindFirstChildOfClass("Humanoid")
    end
    local function ToyFolder()
        return Workspace:FindFirstChild(lp.Name .. "SpawnedInToys")
    end
    local function CountToys()
        local f, n = ToyFolder(), 0
        if f then
            for _, c in ipairs(f:GetChildren()) do
                if c:IsA("Model") then n = n + 1 end
            end
        end
        return n
    end

    local spawning = false
    local function SpawnToys()
        if State.ToyName == "" then return Notify(TX("tm.toys.noname")) end
        if not Remotes.SpawnToy then return Notify(TX("tm.toys.noremote")) end
        if spawning then return end
        spawning = true
        task.spawn(function()
            for _ = 1, State.Amount do
                if not Alive() then break end
                local root = Root()
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
        if not (f and Remotes.DestroyToy) then return Notify(TX("tm.toys.noremote")) end
        local n = 0
        for _, c in ipairs(f:GetChildren()) do
            if c:IsA("Model") then Remotes.DestroyToy:FireServer(c); n = n + 1 end
        end
        Notify(TX("tm.toys.cleared"):format(n))
    end

    local function GetWaypoints()
        local list, map = {}, {}
        local wp = Workspace:FindFirstChild("Waypoints")
        if wp then
            for _, c in ipairs(wp:GetChildren()) do
                if c.Name ~= "CharacterWaypoint" then list[#list + 1] = c.Name; map[c.Name] = c end
            end
        end
        table.sort(list)
        return list, map
    end

    -- منع الإمساك: يقاوم ~30 مرة بالثانية طالما IsHeld شغال
    do
        local isHeld = lp:FindFirstChild("IsHeld")
        local acc = 0
        Track(RunService.Heartbeat:Connect(function(dt)
            if not State.AntiGrab or not Remotes.Struggle then return end
            if not (isHeld and isHeld.Value) then return end
            acc = acc + dt
            if acc < 1 / 30 then return end
            acc = 0
            Remotes.Struggle:FireServer()
        end))
    end

    -- منع الضياع: يحفظ آخر مكان آمن (واقف على الأرض) ويرجعك له لو نزلت بعيد تحته
    do
        local safe
        Track(RunService.Heartbeat:Connect(function()
            if not State.AntiVoid then safe = nil; return end
            local root, hum = Root(), Hum()
            if not (root and hum) then return end
            if hum.FloorMaterial ~= Enum.Material.Air then
                safe = root.CFrame
            elseif safe and root.Position.Y < safe.Position.Y - 250 then
                root.AssemblyLinearVelocity = Vector3.zero
                root.CFrame = safe + Vector3.new(0, 5, 0)
            end
        end))
    end

    -- ═════════ الأقسام ═════════
    tab.Order = tab.Order + 1
    local HintL = Instance.new("TextLabel", PAGE)
    HintL.LayoutOrder = tab.Order; HintL.Size = UDim2.new(0.98, 0, 0, 20)
    HintL.BackgroundTransparency = 1; HintL.Text = TX("tm.hint")
    HintL.TextColor3 = DIM; HintL.Font = Enum.Font.Gotham; HintL.TextSize = 11

    -- ── الحماية ──
    local secDef = MakeSection("def", TX("tm.section.def"), C_BLUE, true)
    InSection(secDef, function()
        Tog(secDef, TX("tm.def.antigrab"), function(v)
            State.AntiGrab = v
            if v and not Remotes.Struggle then Notify(TX("tm.def.noremote")) end
        end)
        Tog(secDef, TX("tm.def.antivoid"), function(v) State.AntiVoid = v end)
    end)

    -- ── الألعاب ──
    local secToys = MakeSection("toys", TX("tm.section.toys"), C_ORANGE, false)
    Dropdown(secToys, TX("tm.toys.pick") .. "  ▾",
        function() return { "NinjaShuriken", "PalletLightBrown", "YouDecoy" } end,  -- أسماء مؤكدة من كود Resonance
        function(v) State.ToyName = v end)
    Stepper(secToys, TX("tm.toys.amount"), 1, 10, 1, function(n) State.Amount = n end)
    Grid(secToys, {
        { text = "➕  " .. TX("tm.toys.spawn"), fn = SpawnToys },
        { text = "🗑️  " .. TX("tm.toys.clear"), color = C_RED, fn = ClearToys },
    })
    do
        local cnt = Card(secToys.cont, 34)
        local L = Instance.new("TextLabel", cnt)
        L.Size = UDim2.new(1, -24, 1, 0); L.Position = UDim2.new(0, 12, 0, 0)
        L.BackgroundTransparency = 1; L.Text = TX("tm.toys.count"):format(CountToys())
        L.TextColor3 = DIM; L.Font = Enum.Font.GothamSemibold; L.TextSize = 12
        L.TextXAlignment = Enum.TextXAlignment.Left
        local acc = 0
        Track(RunService.Heartbeat:Connect(function(dt)
            acc = acc + dt
            if acc < 1 then return end
            acc = 0
            pcall(function() L.Text = TX("tm.toys.count"):format(CountToys()) end)
        end))
    end

    -- ── الماب ──
    local secMap = MakeSection("map", TX("tm.section.map"), C_CYAN, false)
    do
        local list, map = GetWaypoints()
        if #list == 0 then
            local c = Card(secMap.cont, 34)
            local L = Instance.new("TextLabel", c)
            L.Size = UDim2.new(1, -24, 1, 0); L.Position = UDim2.new(0, 12, 0, 0)
            L.BackgroundTransparency = 1; L.Text = TX("tm.map.none")
            L.TextColor3 = DIM; L.Font = Enum.Font.Gotham; L.TextSize = 12
            L.TextXAlignment = Enum.TextXAlignment.Left
        else
            local picked
            Dropdown(secMap, TX("tm.map.select"), function() return list end, function(v) picked = v end)
            Grid(secMap, {
                { text = "📍  " .. TX("tm.map.go"), fn = function()
                    local inst = picked and map[picked]
                    if not inst then return Notify(TX("tm.map.nopick")) end
                    local root = Root()
                    if not root then return Notify(TX("tm.nochar")) end
                    root.CFrame = inst:GetPivot() + Vector3.new(0, 5, 0)
                end },
            })
        end
    end

    -- ── إيقاف الكل ──
    tab.Order = tab.Order + 1
    local StopB = Instance.new("TextButton", PAGE)
    StopB.LayoutOrder = tab.Order; StopB.Size = UDim2.new(0.98, 0, 0, 50)
    StopB.BackgroundColor3 = C_RED; StopB.BackgroundTransparency = 0.8
    StopB.BorderSizePixel = 0; StopB.AutoButtonColor = false
    StopB.Text = "⛔  " .. TX("tm.stopall")
    StopB.TextColor3 = Color3.fromRGB(255, 200, 200)
    StopB.Font = Enum.Font.GothamBlack; StopB.TextSize = 13
    Instance.new("UICorner", StopB).CornerRadius = UDim.new(0, 12)
    StopB.MouseButton1Click:Connect(function()
        State.AntiGrab, State.AntiVoid = false, false
        for _, t in ipairs(allToggles) do pcall(function() t:SetState(false) end) end
        Notify(TX("tm.stopped"), 2)
    end)
end

-- ============================================================
-- 3. إرجاع الجدول (نفس صيغة MM2)
-- ============================================================
return {
    Name   = "Throw Map",
    Render = Render,
}