-- [[ Cryptic Hub - Element: Player Selector (V2 - Open-style design) ]]
-- المسار: UI/Elements/PlayerSelector.lua
-- نفس الواجهة البرمجية بالضبط: Tab:AddPlayerSelector(label, placeholder, callback)
-- يرجع { SetText, UpdateList, Clear } وcallback ينادى بنفس الطريقة

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local env = getgenv()

return function(TabOps, label, placeholder, callback)
    TabOps.Order = TabOps.Order + 1

    -- ============ الترجمات المدمجة (نفس نظام MapCard) ============
    local L = {
        en = {no_players="No players found", hide_list="Hide list", show_list="Show players"},
        ar = {no_players="ما فيه لاعبين", hide_list="إغلاق القائمة", show_list="عرض قائمة اللاعبين"},
        ru = {no_players="Игроки не найдены", hide_list="Скрыть список", show_list="Показать игроков"},
        pt = {no_players="Nenhum jogador encontrado", hide_list="Ocultar lista", show_list="Mostrar jogadores"},
        es = {no_players="No se encontraron jugadores", hide_list="Ocultar lista", show_list="Mostrar jugadores"},
        fr = {no_players="Aucun joueur trouvé", hide_list="Masquer la liste", show_list="Afficher les joueurs"},
        id = {no_players="Pemain tidak ditemukan", hide_list="Sembunyikan daftar", show_list="Tampilkan pemain"},
        fil = {no_players="Walang nahanap na manlalaro", hide_list="Itago ang listahan", show_list="Ipakita ang mga manlalaro"},
        tr = {no_players="Oyuncu bulunamadı", hide_list="Listeyi gizle", show_list="Oyuncuları göster"},
        hi = {no_players="कोई खिलाड़ी नहीं मिला", hide_list="सूची छिपाएँ", show_list="खिलाड़ी दिखाएँ"},
        de = {no_players="Keine Spieler gefunden", hide_list="Liste verbergen", show_list="Spieler anzeigen"},
        nl = {no_players="Geen spelers gevonden", hide_list="Lijst verbergen", show_list="Spelers tonen"},
        pl = {no_players="Nie znaleziono graczy", hide_list="Ukryj listę", show_list="Pokaż graczy"},
        uk = {no_players="Гравців не знайдено", hide_list="Приховати список", show_list="Показати гравців"},
        it = {no_players="Nessun giocatore trovato", hide_list="Nascondi lista", show_list="Mostra giocatori"},
        vi = {no_players="Không tìm thấy người chơi", hide_list="Ẩn danh sách", show_list="Hiện danh sách"},
        th = {no_players="ไม่พบผู้เล่น", hide_list="ซ่อนรายการ", show_list="แสดงผู้เล่น"},
        zh = {no_players="未找到玩家", hide_list="隐藏列表", show_list="显示玩家"},
        tw = {no_players="未找到玩家", hide_list="隱藏列表", show_list="顯示玩家"},
        ko = {no_players="플레이어를 찾을 수 없음", hide_list="목록 숨기기", show_list="플레이어 표시"},
        ja = {no_players="プレイヤーが見つかりません", hide_list="リストを隠す", show_list="プレイヤーを表示"},
    }

    local function TT(k)
        local i = env.CrypticI18n
        if i and i.T then
            local ok, v = pcall(i.T, "combat.select." .. k)
            if ok and type(v) == "string" and v ~= "combat.select." .. k then return v end
        end
        local c = "en"
        if i and i.Get then pcall(function() c = tostring(i.Get()) end) end
        c = c:lower()
        local t = L[c] or L[c:sub(1, 2)] or L.en
        return t[k] or L.en[k]
    end

    -- ── الألوان (نفس ثيم Open) ───────────────────────────────
    local ACCENT   = Color3.fromRGB(0, 255, 150)
    local ACCENT2  = Color3.fromRGB(0, 150, 255)
    local BG_CARD  = Color3.fromRGB(22, 25, 34)
    local BG_FIELD = Color3.fromRGB(30, 33, 44)
    local BG_BTN   = Color3.fromRGB(26, 29, 40)
    local BG_ITEM  = Color3.fromRGB(28, 31, 42)
    local BG_ITEM_HOVER = Color3.fromRGB(36, 40, 54)
    local BG_ITEM_SEL   = Color3.fromRGB(0, 62, 43)
    local STROKE   = Color3.fromRGB(45, 49, 64)
    local TEXT     = Color3.fromRGB(235, 238, 245)
    local DIM      = Color3.fromRGB(160, 165, 180)

    local function Tw(obj, props, t)
        TweenService:Create(obj, TweenInfo.new(t or 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
    end
    local function corner(parent, r)
        local c = Instance.new("UICorner", parent)
        c.CornerRadius = UDim.new(0, r or 10)
        return c
    end

    -- ── القياسات (كلها ثابتة) ────────────────────────────────
    local BASE_H    = 126
    local LIST_Y    = 122
    local ITEM_H    = 44
    local ITEM_GAP  = 4
    local EMPTY_H   = 36
    local MAX_LIST_H = 200

    -- ══════════════════════════════════════════
    -- الكرت
    -- ══════════════════════════════════════════
    local Container = Instance.new("Frame", TabOps.Page)
    Container.LayoutOrder = TabOps.Order
    Container.Size = UDim2.new(0.95, 0, 0, BASE_H)
    Container.BackgroundColor3 = BG_CARD
    Container.BackgroundTransparency = 0.15
    Container.BorderSizePixel = 0
    Container.ClipsDescendants = true
    corner(Container, 12)

    local CardStroke = Instance.new("UIStroke", Container)
    CardStroke.Thickness = 1
    CardStroke.Color = STROKE
    CardStroke.Transparency = 0.3

    -- الشريط الملون
    local Strip = Instance.new("Frame", Container)
    Strip.Size = UDim2.new(0, 3, 0, 24)
    Strip.Position = UDim2.new(0, 0, 0, 10)
    Strip.BackgroundColor3 = ACCENT
    Strip.BorderSizePixel = 0
    corner(Strip, 2)
    local StripGrad = Instance.new("UIGradient", Strip)
    StripGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, ACCENT),
        ColorSequenceKeypoint.new(1, ACCENT2),
    }
    StripGrad.Rotation = 90

    -- مربع الأيقونة
    local IconChip = Instance.new("Frame", Container)
    IconChip.Size = UDim2.new(0, 26, 0, 26)
    IconChip.Position = UDim2.new(0, 12, 0, 9)
    IconChip.BackgroundColor3 = Color3.fromRGB(0, 45, 32)
    IconChip.BorderSizePixel = 0
    corner(IconChip, 8)
    local IconStroke = Instance.new("UIStroke", IconChip)
    IconStroke.Thickness = 1
    IconStroke.Color = ACCENT
    IconStroke.Transparency = 0.6
    local IconLbl = Instance.new("TextLabel", IconChip)
    IconLbl.Size = UDim2.new(1, 0, 1, 0)
    IconLbl.BackgroundTransparency = 1
    IconLbl.Text = "🎯"
    IconLbl.TextSize = 14
    IconLbl.Font = Enum.Font.GothamBold
    IconLbl.TextColor3 = Color3.new(1, 1, 1)

    -- العنوان (يسار) + عدد اللاعبين (يمين)
    local Lbl = Instance.new("TextLabel", Container)
    Lbl.Text = label
    Lbl.Size = UDim2.new(1, -110, 0, 26)
    Lbl.Position = UDim2.new(0, 46, 0, 9)
    Lbl.BackgroundTransparency = 1
    Lbl.TextColor3 = TEXT
    Lbl.Font = Enum.Font.GothamBold
    Lbl.TextSize = 12
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.TextTruncate = Enum.TextTruncate.AtEnd

    local CountLbl = Instance.new("TextLabel", Container)
    CountLbl.Size = UDim2.new(0, 60, 0, 26)
    CountLbl.Position = UDim2.new(1, -72, 0, 9)
    CountLbl.BackgroundTransparency = 1
    CountLbl.TextColor3 = ACCENT
    CountLbl.Font = Enum.Font.GothamBold
    CountLbl.TextSize = 11
    CountLbl.TextXAlignment = Enum.TextXAlignment.Right
    CountLbl.Text = "👥 0"

    -- ══════════════════════════════════════════
    -- مربع البحث
    -- ══════════════════════════════════════════
    local SearchWrap = Instance.new("Frame", Container)
    SearchWrap.Size = UDim2.new(1, -24, 0, 34)
    SearchWrap.Position = UDim2.new(0, 12, 0, 44)
    SearchWrap.BackgroundColor3 = BG_FIELD
    SearchWrap.BorderSizePixel = 0
    corner(SearchWrap, 9)
    local SearchStroke = Instance.new("UIStroke", SearchWrap)
    SearchStroke.Thickness = 1
    SearchStroke.Color = STROKE
    SearchStroke.Transparency = 0.2

    local SearchIcon = Instance.new("TextLabel", SearchWrap)
    SearchIcon.Size = UDim2.new(0, 26, 1, 0)
    SearchIcon.Position = UDim2.new(0, 6, 0, 0)
    SearchIcon.BackgroundTransparency = 1
    SearchIcon.Text = "🔍"
    SearchIcon.TextSize = 13
    SearchIcon.Font = Enum.Font.GothamBold
    SearchIcon.TextColor3 = DIM

    local SearchBox = Instance.new("TextBox", SearchWrap)
    SearchBox.Size = UDim2.new(1, -70, 1, 0)
    SearchBox.Position = UDim2.new(0, 32, 0, 0)
    SearchBox.BackgroundTransparency = 1
    SearchBox.PlaceholderText = placeholder
    SearchBox.PlaceholderColor3 = Color3.fromRGB(110, 115, 130)
    SearchBox.TextColor3 = TEXT
    SearchBox.Text = ""
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.TextSize = 12
    SearchBox.TextXAlignment = Enum.TextXAlignment.Left
    SearchBox.ClearTextOnFocus = true
    SearchBox.TextTruncate = Enum.TextTruncate.AtEnd

    local ClearBtn = Instance.new("TextButton", SearchWrap)
    ClearBtn.Size = UDim2.new(0, 26, 0, 26)
    ClearBtn.Position = UDim2.new(1, -30, 0.5, -13)
    ClearBtn.BackgroundColor3 = Color3.fromRGB(50, 30, 34)
    ClearBtn.BackgroundTransparency = 0.3
    ClearBtn.Text = "X"
    ClearBtn.TextColor3 = Color3.fromRGB(255, 110, 115)
    ClearBtn.Font = Enum.Font.GothamBold
    ClearBtn.TextSize = 12
    ClearBtn.AutoButtonColor = false
    ClearBtn.Visible = false
    corner(ClearBtn, 7)

    -- ══════════════════════════════════════════
    -- زر فتح/إغلاق القائمة
    -- ══════════════════════════════════════════
    local DropBtn = Instance.new("TextButton", Container)
    DropBtn.Size = UDim2.new(1, -24, 0, 30)
    DropBtn.Position = UDim2.new(0, 12, 0, 84)
    DropBtn.BackgroundColor3 = BG_BTN
    DropBtn.Text = ""
    DropBtn.AutoButtonColor = false
    DropBtn.BorderSizePixel = 0
    corner(DropBtn, 9)
    local DropStroke = Instance.new("UIStroke", DropBtn)
    DropStroke.Thickness = 1
    DropStroke.Color = STROKE
    DropStroke.Transparency = 0.4

    local BtnText = Instance.new("TextLabel", DropBtn)
    BtnText.Size = UDim2.new(1, -44, 1, 0)
    BtnText.Position = UDim2.new(0, 12, 0, 0)
    BtnText.BackgroundTransparency = 1
    BtnText.TextColor3 = DIM
    BtnText.Font = Enum.Font.GothamSemibold
    BtnText.TextSize = 11
    BtnText.TextXAlignment = Enum.TextXAlignment.Left
    BtnText.TextTruncate = Enum.TextTruncate.AtEnd

    local BtnArrow = Instance.new("TextLabel", DropBtn)
    BtnArrow.AnchorPoint = Vector2.new(0.5, 0.5)
    BtnArrow.Size = UDim2.new(0, 20, 0, 20)
    BtnArrow.Position = UDim2.new(1, -20, 0.5, 0)
    BtnArrow.BackgroundTransparency = 1
    BtnArrow.Text = "▼"
    BtnArrow.TextSize = 10
    BtnArrow.Font = Enum.Font.GothamBold
    BtnArrow.TextColor3 = ACCENT

    -- ══════════════════════════════════════════
    -- قائمة اللاعبين
    -- ══════════════════════════════════════════
    local DropList = Instance.new("ScrollingFrame", Container)
    DropList.Size = UDim2.new(1, -24, 0, 0)
    DropList.Position = UDim2.new(0, 12, 0, LIST_Y)
    DropList.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
    DropList.BackgroundTransparency = 0.2
    DropList.BorderSizePixel = 0
    DropList.Visible = false
    DropList.ScrollBarThickness = 3
    DropList.ScrollBarImageColor3 = ACCENT
    DropList.ScrollBarImageTransparency = 0.4
    DropList.ScrollingDirection = Enum.ScrollingDirection.Y
    DropList.ScrollingEnabled = true
    DropList.Active = true
    DropList.CanvasSize = UDim2.new(0, 0, 0, 0)
    corner(DropList, 9)

    local ListPad = Instance.new("UIPadding", DropList)
    ListPad.PaddingTop = UDim.new(0, 4)
    ListPad.PaddingBottom = UDim.new(0, 4)
    ListPad.PaddingLeft = UDim.new(0, 4)
    ListPad.PaddingRight = UDim.new(0, 4)

    local ListLayout = Instance.new("UIListLayout", DropList)
    ListLayout.Padding = UDim.new(0, ITEM_GAP)
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local EmptyLbl = Instance.new("TextLabel", Container)
    EmptyLbl.Size = UDim2.new(1, -24, 0, EMPTY_H)
    EmptyLbl.Position = UDim2.new(0, 12, 0, LIST_Y)
    EmptyLbl.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
    EmptyLbl.BackgroundTransparency = 0.2
    EmptyLbl.Text = TT("no_players")
    EmptyLbl.TextColor3 = DIM
    EmptyLbl.Font = Enum.Font.Gotham
    EmptyLbl.TextSize = 11
    EmptyLbl.Visible = false
    corner(EmptyLbl, 9)

    -- ══════════════════════════════════════════
    -- الحالة
    -- ══════════════════════════════════════════
    local isOpen = false
    local focused = false
    local currentSelectedUser = nil
    local items = {}
    local totalPlayers = 0
    local visibleCount = 0

    local function updateBtnText()
        local base = isOpen and TT("hide_list") or TT("show_list")
        BtnText.Text = base .. "  (" .. totalPlayers .. ")"
        Tw(BtnArrow, { Rotation = isOpen and 180 or 0 }, 0.18)
    end

    local function updateMetrics()
        local n = visibleCount
        local contentH = (n > 0) and (n * ITEM_H + (n - 1) * ITEM_GAP + 8) or EMPTY_H
        local listH = math.min(contentH, MAX_LIST_H)
        DropList.CanvasSize = UDim2.new(0, 0, 0, contentH)
        if isOpen then
            DropList.Size = UDim2.new(1, -24, 0, listH)
            DropList.Visible = n > 0
            EmptyLbl.Visible = n == 0
            Tw(Container, { Size = UDim2.new(0.95, 0, 0, LIST_Y + listH + 12) }, 0.2)
        else
            DropList.Visible = false
            EmptyLbl.Visible = false
            Tw(Container, { Size = UDim2.new(0.95, 0, 0, BASE_H) }, 0.2)
        end
    end

    local function setOpen(open)
        isOpen = open
        updateBtnText()
        updateMetrics()
    end

    local function refreshVisuals()
        for _, it in ipairs(items) do
            local sel = currentSelectedUser == it.name
            Tw(it.frame, { BackgroundColor3 = sel and BG_ITEM_SEL or BG_ITEM }, 0.12)
            it.stroke.Color = sel and ACCENT or STROKE
            it.stroke.Transparency = sel and 0.35 or 0.7
            it.nameLbl.TextColor3 = sel and ACCENT or TEXT
            it.check.Visible = sel
        end
        local has = currentSelectedUser ~= nil
        SearchStroke.Color = (focused or has) and ACCENT or STROKE
        SearchStroke.Transparency = (focused or has) and 0.35 or 0.2
        SearchIcon.Text = has and "✓" or "🔍"
        SearchIcon.TextColor3 = has and ACCENT or DIM
        ClearBtn.Visible = SearchBox.Text ~= ""
    end

    local function applyFilter(query)
        query = string.lower(query or "")
        local shown = 0
        for _, it in ipairs(items) do
            local match = query == ""
                or string.find(string.lower(it.name), query, 1, true) ~= nil
                or string.find(string.lower(it.display), query, 1, true) ~= nil
            it.frame.Visible = match
            if match then shown = shown + 1 end
        end
        visibleCount = shown
        DropList.CanvasPosition = Vector2.new(0, 0)
        updateMetrics()
    end

    DropBtn.MouseButton1Click:Connect(function() setOpen(not isOpen) end)
    DropBtn.MouseEnter:Connect(function()
        Tw(DropBtn, { BackgroundColor3 = Color3.fromRGB(32, 36, 50) }, 0.12)
        Tw(DropStroke, { Transparency = 0.1, Color = ACCENT }, 0.12)
    end)
    DropBtn.MouseLeave:Connect(function()
        Tw(DropBtn, { BackgroundColor3 = BG_BTN }, 0.15)
        Tw(DropStroke, { Transparency = 0.4, Color = STROKE }, 0.15)
    end)

    updateBtnText()

    -- ══════════════════════════════════════════
    -- بناء بطاقات اللاعبين
    -- ══════════════════════════════════════════
    local function UpdateList(playersList)
        playersList = playersList or {}
        totalPlayers = #playersList
        CountLbl.Text = "👥 " .. totalPlayers

        for _, it in ipairs(items) do
            if it.frame then it.frame:Destroy() end
        end
        items = {}

        local sorted = {}
        for _, p in ipairs(playersList) do table.insert(sorted, p) end
        table.sort(sorted, function(a, b)
            return string.lower(a.DisplayName) < string.lower(b.DisplayName)
        end)

        for index, p in ipairs(sorted) do
            local creationDate = "??/??/????"
            if p.AccountAge then
                local success, dateStr = pcall(function()
                    local unixTime = os.time() - (p.AccountAge * 86400)
                    return os.date("%Y/%m/%d", unixTime)
                end)
                if success and dateStr then creationDate = dateStr end
            end

            local PItem = Instance.new("Frame", DropList)
            PItem.Name = p.Name
            PItem.LayoutOrder = index
            PItem.Size = UDim2.new(1, -8, 0, ITEM_H)
            PItem.BackgroundColor3 = BG_ITEM
            PItem.BorderSizePixel = 0
            corner(PItem, 9)
            local ItemStroke = Instance.new("UIStroke", PItem)
            ItemStroke.Thickness = 1
            ItemStroke.Color = STROKE
            ItemStroke.Transparency = 0.7

            local Avatar = Instance.new("ImageLabel", PItem)
            Avatar.Size = UDim2.new(0, 32, 0, 32)
            Avatar.Position = UDim2.new(0, 8, 0.5, -16)
            Avatar.BackgroundColor3 = Color3.fromRGB(45, 48, 62)
            Avatar.BorderSizePixel = 0
            corner(Avatar, 999)
            task.spawn(function()
                local ok, thumb = pcall(function()
                    return Players:GetUserThumbnailAsync(p.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
                end)
                if ok and thumb and Avatar.Parent then Avatar.Image = thumb end
            end)

            local NLabel = Instance.new("TextLabel", PItem)
            NLabel.Size = UDim2.new(1, -92, 0, 18)
            NLabel.Position = UDim2.new(0, 48, 0, 6)
            NLabel.Text = p.DisplayName
            NLabel.TextColor3 = TEXT
            NLabel.BackgroundTransparency = 1
            NLabel.TextXAlignment = Enum.TextXAlignment.Left
            NLabel.Font = Enum.Font.GothamBold
            NLabel.TextSize = 12
            NLabel.TextTruncate = Enum.TextTruncate.AtEnd

            local ULabel = Instance.new("TextLabel", PItem)
            ULabel.Size = UDim2.new(0, 90, 0, 14)
            ULabel.Position = UDim2.new(0, 48, 0, 24)
            ULabel.Text = "@" .. p.Name
            ULabel.TextColor3 = DIM
            ULabel.BackgroundTransparency = 1
            ULabel.TextXAlignment = Enum.TextXAlignment.Left
            ULabel.Font = Enum.Font.Gotham
            ULabel.TextSize = 10
            ULabel.TextTruncate = Enum.TextTruncate.AtEnd

            local DateLabel = Instance.new("TextLabel", PItem)
            DateLabel.Size = UDim2.new(0, 80, 0, 14)
            DateLabel.Position = UDim2.new(1, -120, 0, 24)
            DateLabel.Text = "📅 " .. creationDate
            DateLabel.TextColor3 = Color3.fromRGB(140, 145, 160)
            DateLabel.BackgroundTransparency = 1
            DateLabel.TextXAlignment = Enum.TextXAlignment.Right
            DateLabel.Font = Enum.Font.Gotham
            DateLabel.TextSize = 10

            -- زر X العادي
            local Check = Instance.new("TextButton", PItem)
            Check.Size = UDim2.new(0, 28, 1, 0)
            Check.Position = UDim2.new(1, -34, 0, 0)
            Check.BackgroundTransparency = 1
            Check.Text = "X"  -- تم التعديل هنا: حرف X عادي
            Check.TextColor3 = Color3.fromRGB(255, 80, 80)
            Check.Font = Enum.Font.GothamBold
            Check.TextSize = 14
            Check.Visible = false
            Check.ZIndex = PItem.ZIndex + 4

            local SelectBtn = Instance.new("TextButton", PItem)
            SelectBtn.Size = UDim2.new(1, 0, 1, 0)
            SelectBtn.BackgroundTransparency = 1
            SelectBtn.Text = ""
            SelectBtn.AutoButtonColor = false
            SelectBtn.ZIndex = PItem.ZIndex + 3

            local entry = {
                name = p.Name, display = p.DisplayName,
                frame = PItem, stroke = ItemStroke, nameLbl = NLabel, check = Check,
            }
            table.insert(items, entry)

            -- وظيفة زر X لإلغاء التحديد
            Check.MouseButton1Click:Connect(function()
                if currentSelectedUser == p.Name then
                    currentSelectedUser = nil
                    SearchBox.Text = ""
                    applyFilter("")
                    refreshVisuals()
                    pcall(callback, nil)
                end
            end)

            SelectBtn.MouseEnter:Connect(function()
                if currentSelectedUser ~= entry.name then
                    Tw(PItem, { BackgroundColor3 = BG_ITEM_HOVER }, 0.1)
                end
            end)
            SelectBtn.MouseLeave:Connect(function()
                if currentSelectedUser ~= entry.name then
                    Tw(PItem, { BackgroundColor3 = BG_ITEM }, 0.12)
                end
            end)

            SelectBtn.MouseButton1Click:Connect(function()
                currentSelectedUser = p.Name
                SearchBox.Text = p.DisplayName .. " (@" .. p.Name .. ")"
                applyFilter("")
                refreshVisuals()

                task.wait(0.15)
                setOpen(false)

                if TabOps.LogAction then TabOps.LogAction("👤 تحديد لاعب", label, "تم تحديد: " .. p.Name, 10181046) end
                pcall(callback, p)
            end)
        end

        applyFilter(focused and SearchBox.Text or "")
        refreshVisuals()
    end

    -- ══════════════════════════════════════════
    -- البحث الذكي
    -- ══════════════════════════════════════════
    local function resetSelection()
        currentSelectedUser = nil
        refreshVisuals()
    end

    SearchBox.Focused:Connect(function()
        focused = true
        currentSelectedUser = nil
        refreshVisuals()
        pcall(callback, nil)
    end)

    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        ClearBtn.Visible = SearchBox.Text ~= ""
        if focused then applyFilter(SearchBox.Text) end
    end)

    SearchBox.FocusLost:Connect(function()
        focused = false
        local txt = SearchBox.Text
        if txt == "" then
            applyFilter("")
            resetSelection()
            pcall(callback, nil)
            return
        end

        local bestMatch = nil
        local search = txt:lower()
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= Players.LocalPlayer and string.sub(p.Name:lower(), 1, #search) == search then
                bestMatch = p
                break
            end
        end
        if not bestMatch then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= Players.LocalPlayer and string.sub(p.DisplayName:lower(), 1, #search) == search then
                    bestMatch = p
                    break
                end
            end
        end

        applyFilter("")
        if bestMatch then
            currentSelectedUser = bestMatch.Name
            SearchBox.Text = bestMatch.DisplayName .. " (@" .. bestMatch.Name .. ")"
            refreshVisuals()

            if TabOps.LogAction then TabOps.LogAction("🔍 بحث وتحديد لاعب", label, "تم تحديد: " .. bestMatch.Name, 10181046) end
            pcall(callback, bestMatch)
        else
            resetSelection()
            pcall(callback, txt)
        end
    end)

    ClearBtn.MouseButton1Click:Connect(function()
        SearchBox.Text = ""
        applyFilter("")
        resetSelection()
        pcall(callback, nil)
    end)
    ClearBtn.MouseEnter:Connect(function() Tw(ClearBtn, { BackgroundTransparency = 0 }, 0.1) end)
    ClearBtn.MouseLeave:Connect(function() Tw(ClearBtn, { BackgroundTransparency = 0.3 }, 0.12) end)

    SearchBox.Focused:Connect(function()
        Tw(SearchWrap, { BackgroundColor3 = Color3.fromRGB(34, 38, 52) }, 0.12)
    end)
    SearchBox.FocusLost:Connect(function()
        Tw(SearchWrap, { BackgroundColor3 = BG_FIELD }, 0.15)
    end)

    -- ══════════════════════════════════════════
    -- أدوات خارجية (نفس الأسماء القديمة)
    -- ══════════════════════════════════════════
    return {
        SetText = function(t)
            SearchBox.Text = t or ""
            local uname = type(t) == "string" and t:match("%(@(.+)%)%s*$")
            currentSelectedUser = uname
            refreshVisuals()
        end,
        UpdateList = UpdateList,
        Clear = function()
            SearchBox.Text = ""
            currentSelectedUser = nil
            applyFilter("")
            refreshVisuals()
        end,
    }
end