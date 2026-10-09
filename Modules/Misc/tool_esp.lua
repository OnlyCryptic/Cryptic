-- [[ Cryptic Hub - Tools ESP ]]
return function(Tab, UI)
    local i18n = getgenv().CrypticI18n
    local T = (i18n and i18n.T) or function(k) return k end
    local function TT(key, fallback)
        local v = T(key)
        if v == nil or v == key then return fallback end
        return v
    end

    local Players    = game:GetService("Players")
    local CoreGui    = game:GetService("CoreGui")
    local StarterGui = game:GetService("StarterGui")
    local LocalPlayer = Players.LocalPlayer

    ----------------------------------------------------------------
    -- إعدادات
    ----------------------------------------------------------------
    local GUI_NAME  = "CrypticToolsESP"
    local MAX_ROW   = 5     -- أقصى عدد مربعات فوق الراس
    local SLOT      = 34    -- حجم المربع (بكسل)
    local PAD       = 3
    local PANEL_MAX = 25    -- أقصى عدد أدوات بالقائمة الموسعة
    local MAX_DIST  = 250   -- أبعد مسافة تظهر فيها المربعات ( studs)

    local C = {
        CARD   = Color3.fromRGB(22, 22, 32),
        EQUIP  = Color3.fromRGB(60, 46, 8),
        GOLD   = Color3.fromRGB(230, 175, 30),
        EDGE   = Color3.fromRGB(70, 70, 90),
        MORE   = Color3.fromRGB(30, 90, 200),
        TEXT   = Color3.fromRGB(240, 240, 240),
    }

    local ROW_W = MAX_ROW * SLOT + (MAX_ROW - 1) * PAD
    local GUI_W = ROW_W + 10
    local GUI_H = 420

    local function Notify(text)
        pcall(function()
            StarterGui:SetCore("SendNotification", {Title = "Cryptic Hub", Text = text, Duration = 3})
        end)
    end

    local function ParentGui(gui)
        local ok = pcall(function()
            if gethui then gui.Parent = gethui()
            elseif syn and syn.protect_gui then syn.protect_gui(gui); gui.Parent = CoreGui
            else gui.Parent = CoreGui end
        end)
        if not ok then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
    end

    local function Corner(parent, r)
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, r or 6)
        c.Parent = parent
        return c
    end

    ----------------------------------------------------------------
    -- الحالة
    ----------------------------------------------------------------
    local Holder
    local States    = {}   -- [player] = state
    local RootConns = {}
    local running   = false

    local function DisconnectList(list)
        for i = #list, 1, -1 do
            pcall(function() list[i]:Disconnect() end)
            list[i] = nil
        end
    end

    ----------------------------------------------------------------
    -- المربعات (Slots)
    ----------------------------------------------------------------
    local function MakeSlot(parent, order)
        local b = Instance.new("ImageButton")
        b.Size                   = UDim2.fromOffset(SLOT, SLOT)
        b.BackgroundColor3       = C.CARD
        b.BackgroundTransparency = 0.15
        b.BorderSizePixel        = 0
        b.AutoButtonColor        = false
        b.ScaleType              = Enum.ScaleType.Fit
        b.LayoutOrder            = order
        b.Visible                = false
        b.Parent                 = parent
        Corner(b, 6)

        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 1.5
        stroke.Color     = C.EDGE
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        stroke.Parent    = b

        local txt = Instance.new("TextLabel")
        txt.Size                   = UDim2.new(1, -4, 1, -4)
        txt.Position               = UDim2.fromOffset(2, 2)
        txt.BackgroundTransparency = 1
        txt.TextColor3             = C.TEXT
        txt.TextScaled             = true
        txt.TextWrapped            = true
        txt.Font                   = Enum.Font.GothamBold
        txt.Text                   = ""
        txt.Parent                 = b

        local slot = { btn = b, txt = txt, stroke = stroke, onClick = nil }
        b.MouseButton1Click:Connect(function()
            if slot.onClick then slot.onClick() end
        end)
        return slot
    end

    local function SetToolSlot(slot, tool, equipped)
        local tex = tool.TextureId
        if tex ~= "" then
            slot.btn.Image = tex
            slot.txt.Text  = ""
        else
            slot.btn.Image = ""
            slot.txt.Text  = tool.Name
        end
        slot.btn.BackgroundColor3 = equipped and C.EQUIP or C.CARD
        slot.stroke.Color         = equipped and C.GOLD or C.EDGE
        slot.txt.TextColor3       = C.TEXT
        slot.onClick = nil
        slot.btn.Visible = true
    end

    local function SetMoreSlot(slot, count, expanded, toggle)
        slot.btn.Image            = ""
        slot.txt.Text             = expanded and "▼" or ("+" .. count)
        slot.txt.TextColor3       = C.GOLD
        slot.btn.BackgroundColor3 = C.CARD
        slot.stroke.Color         = C.MORE
        slot.onClick = toggle
        slot.btn.Visible = true
    end

    ----------------------------------------------------------------
    -- تحديث اللاعب (مجمّع: كل التغييرات المتتالية تنتج تحديث واحد)
    ----------------------------------------------------------------
    local function Refresh(st)
        st.pending = false
        if not running or st.dead then return end

        local list = {}
        for tool, seq in pairs(st.tools) do
            list[#list + 1] = { tool = tool, seq = seq }
        end
        table.sort(list, function(a, b) return a.seq < b.seq end)

        local n       = #list
        local char    = st.plr.Character
        local showMore = n > MAX_ROW
        local direct  = showMore and (MAX_ROW - 1) or n

        st.gui.Enabled = n > 0
        if not showMore then st.expanded = false end

        for i = 1, MAX_ROW do
            local slot = st.rowSlots[i]
            if i <= direct then
                SetToolSlot(slot, list[i].tool, list[i].tool.Parent == char)
            elseif i == MAX_ROW and showMore then
                SetMoreSlot(slot, n - direct, st.expanded, st.toggle)
            else
                slot.btn.Visible = false
                slot.onClick = nil
            end
        end

        local panelOn = showMore and st.expanded
        st.panel.Visible = panelOn

        local used = 0
        if panelOn then
            local extras = math.min(n - direct, PANEL_MAX)
            for j = 1, extras do
                local slot = st.panelSlots[j]
                if not slot then
                    slot = MakeSlot(st.panel, j)
                    st.panelSlots[j] = slot
                end
                local e = list[direct + j]
                SetToolSlot(slot, e.tool, e.tool.Parent == char)
            end
            used = extras
        end
        for j = used + 1, #st.panelSlots do
            st.panelSlots[j].btn.Visible = false
        end
    end

    local function Schedule(st)
        if st.pending or st.dead then return end
        st.pending = true
        task.delay(0.05, Refresh, st)
    end

    ----------------------------------------------------------------
    -- تتبع الأدوات
    ----------------------------------------------------------------
    local function AddTool(st, tool)
        if st.tools[tool] then
            Schedule(st) -- انتقلت بين Backpack والشخصية: تحديث الإطار الذهبي
            return
        end
        st.seq += 1
        st.tools[tool] = st.seq
        st.toolConns[tool] = {
            tool:GetPropertyChangedSignal("TextureId"):Connect(function() Schedule(st) end),
            tool:GetPropertyChangedSignal("Name"):Connect(function() Schedule(st) end),
        }
        Schedule(st)
    end

    local function DropTool(st, tool)
        if not st.tools[tool] then return end
        st.tools[tool] = nil
        local conns = st.toolConns[tool]
        if conns then DisconnectList(conns) end
        st.toolConns[tool] = nil
        Schedule(st)
    end

    local function InPlayerContainers(st, tool)
        local p = tool.Parent
        if not p then return false end
        return p == st.plr.Character or p == st.plr:FindFirstChildOfClass("Backpack")
    end

    local function OnRemoved(st, tool)
        if not st.tools[tool] then return end
        if InPlayerContainers(st, tool) then
            Schedule(st) -- مجرد انتقال (equip/unequip)
        else
            DropTool(st, tool)
        end
    end

    local function Resync(st)
        for tool in pairs(st.tools) do
            if not InPlayerContainers(st, tool) then DropTool(st, tool) end
        end
        local char = st.plr.Character
        local bp   = st.plr:FindFirstChildOfClass("Backpack")
        for _, container in ipairs({ char, bp }) do
            if container then
                for _, c in ipairs(container:GetChildren()) do
                    if c:IsA("Tool") then AddTool(st, c) end
                end
            end
        end
        Schedule(st)
    end

    local function Watch(st, container, list)
        list[#list + 1] = container.ChildAdded:Connect(function(c)
            if c:IsA("Tool") then AddTool(st, c) end
        end)
        list[#list + 1] = container.ChildRemoved:Connect(function(c)
            if c:IsA("Tool") then OnRemoved(st, c) end
        end)
    end

    local function SetupBackpack(st, bp)
        DisconnectList(st.bpConns)
        Watch(st, bp, st.bpConns)
        Resync(st)
    end

    local function SetupChar(st, char)
        DisconnectList(st.charConns)
        st.gui.Adornee = nil
        if char then
            Watch(st, char, st.charConns)
            task.spawn(function()
                local head = char:FindFirstChild("Head") or char:WaitForChild("Head", 5)
                if head and not st.dead and st.plr.Character == char then
                    st.gui.Adornee = head
                end
            end)
        end
        Resync(st)
    end

    ----------------------------------------------------------------
    -- إنشاء / حذف لاعب
    ----------------------------------------------------------------
    local function CreateState(plr)
        local st = {
            plr = plr, tools = {}, toolConns = {}, seq = 0,
            expanded = false, pending = false, dead = false,
            rowSlots = {}, panelSlots = {},
            charConns = {}, bpConns = {}, mainConns = {},
        }

        local gui = Instance.new("BillboardGui")
        gui.Name           = "TESP_" .. plr.UserId
        gui.Size           = UDim2.fromOffset(GUI_W, GUI_H)
        gui.StudsOffset    = Vector3.new(0, 2.6, 0)
        gui.AlwaysOnTop    = true
        gui.MaxDistance    = MAX_DIST
        gui.LightInfluence = 0
        gui.ResetOnSpawn   = false
        gui.Enabled        = false
        gui.Parent         = Holder
        st.gui = gui

        local row = Instance.new("Frame")
        row.AnchorPoint            = Vector2.new(0.5, 0.5)
        row.Position               = UDim2.fromScale(0.5, 0.5)
        row.Size                   = UDim2.new(1, 0, 0, SLOT)
        row.BackgroundTransparency = 1
        row.BorderSizePixel        = 0
        row.Parent                 = gui

        local rl = Instance.new("UIListLayout")
        rl.FillDirection       = Enum.FillDirection.Horizontal
        rl.HorizontalAlignment = Enum.HorizontalAlignment.Center
        rl.VerticalAlignment   = Enum.VerticalAlignment.Center
        rl.SortOrder           = Enum.SortOrder.LayoutOrder
        rl.Padding             = UDim.new(0, PAD)
        rl.Parent              = row

        for i = 1, MAX_ROW do
            st.rowSlots[i] = MakeSlot(row, i)
        end

        local panel = Instance.new("Frame")
        panel.AnchorPoint            = Vector2.new(0.5, 1)
        panel.Position               = UDim2.new(0.5, 0, 0.5, -(SLOT / 2 + PAD + 2))
        panel.Size                   = UDim2.new(1, 0, 0, math.ceil(PANEL_MAX / MAX_ROW) * (SLOT + PAD))
        panel.BackgroundTransparency = 1
        panel.BorderSizePixel        = 0
        panel.Visible                = false
        panel.Parent                 = gui
        st.panel = panel

        local grid = Instance.new("UIGridLayout")
        grid.CellSize            = UDim2.fromOffset(SLOT, SLOT)
        grid.CellPadding         = UDim2.fromOffset(PAD, PAD)
        grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
        grid.VerticalAlignment   = Enum.VerticalAlignment.Bottom
        grid.SortOrder           = Enum.SortOrder.LayoutOrder
        grid.FillDirectionMaxCells = MAX_ROW
        grid.Parent              = panel

        st.toggle = function()
            st.expanded = not st.expanded
            Schedule(st)
        end

        return st
    end

    local function UntrackPlayer(plr)
        local st = States[plr]
        if not st then return end
        st.dead = true
        States[plr] = nil
        DisconnectList(st.mainConns)
        DisconnectList(st.charConns)
        DisconnectList(st.bpConns)
        for _, conns in pairs(st.toolConns) do DisconnectList(conns) end
        pcall(function() st.gui:Destroy() end)
    end

    local function TrackPlayer(plr)
        if plr == LocalPlayer or States[plr] or not Holder then return end
        local st = CreateState(plr)
        States[plr] = st

        st.mainConns[#st.mainConns + 1] = plr.ChildAdded:Connect(function(c)
            if c:IsA("Backpack") then SetupBackpack(st, c) end
        end)
        st.mainConns[#st.mainConns + 1] = plr.CharacterAdded:Connect(function(ch)
            SetupChar(st, ch)
        end)

        local bp = plr:FindFirstChildOfClass("Backpack")
        if bp then SetupBackpack(st, bp) end
        SetupChar(st, plr.Character)
    end

    ----------------------------------------------------------------
    -- تشغيل / إيقاف
    ----------------------------------------------------------------
    local function Cleanup()
        running = false
        DisconnectList(RootConns)
        for plr in pairs(States) do UntrackPlayer(plr) end
        if Holder then pcall(function() Holder:Destroy() end) end
        Holder = nil
    end

    Tab:AddToggle(TT("misc.tools_esp.label", "ESP الأدوات"), function(active)
        Cleanup()
        if not active then return end

        running = true
        Holder = Instance.new("Folder")
        Holder.Name = GUI_NAME
        ParentGui(Holder)

        RootConns[#RootConns + 1] = Players.PlayerAdded:Connect(TrackPlayer)
        RootConns[#RootConns + 1] = Players.PlayerRemoving:Connect(UntrackPlayer)
        for _, p in ipairs(Players:GetPlayers()) do TrackPlayer(p) end

        Notify(TT("misc.tools_esp.on", "ESP الأدوات شغال"))
    end)
end