-- [[ Cryptic Hub - Building System V3.1 ]]
-- Floating HUD + D-Pad | Auto Grid | Stack blocks | Global i18n

return function(Tab, UI)
    local Players      = game:GetService("Players")
    local RunService   = game:GetService("RunService")
    local StarterGui   = game:GetService("StarterGui")
    local TweenService = game:GetService("TweenService")
    local UIS          = game:GetService("UserInputService")

    local lp  = Players.LocalPlayer
    local cam = workspace.CurrentCamera

    local i18n = getgenv().CrypticI18n
    local T = (i18n and i18n.T) or function(k) return k end

    local ACCENT  = Color3.fromRGB(0, 255, 150)
    local ACCENT2 = Color3.fromRGB(0, 150, 255)
    local BG      = Color3.fromRGB(16, 16, 20)
    local BG2     = Color3.fromRGB(22, 22, 28)

    local function Tw(obj, props, t)
        TweenService:Create(obj, TweenInfo.new(t or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
    end
    local function GradStroke(parent, thick)
        local s = Instance.new("UIStroke", parent)
        s.Thickness = thick or 1.2; s.Transparency = 0.3
        local g = Instance.new("UIGradient", s)
        g.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, ACCENT),
            ColorSequenceKeypoint.new(1, ACCENT2)
        }
        g.Rotation = 45
        return s
    end

    local SHAPE_KEYS = {"Part","WedgePart","CornerWedgePart","Cylinder","Sphere","TrussPart"}
    local SHAPE_LBL_KEYS = {"block","wedge","corner","cylinder","sphere","truss"}
    local MAT_LBL_KEYS = {"plastic","brick","wood","metal","neon","glass","marble","granite","ice","grass","sand","diamond"}

    -- ============================================================
    -- ⚙️ Config
    -- ============================================================
    local cfg = {
        shape    = "Part",
        color    = Color3.fromRGB(163, 162, 165),
        material = Enum.Material.SmoothPlastic,
        sizeX = 4, sizeY = 4, sizeZ = 4,
        gridSize = 4,
        range    = 20,
        rotY     = 0,
        buildOn  = false,
        offX = 0, offY = 0, offZ = 0,
    }

    local placedParts = {}
    local ghost, ghostConn, counterLbl = nil, nil, nil
    local hudGui = nil

    local BuildFolder = Instance.new("Folder")
    BuildFolder.Name  = "CrypticBuild_" .. lp.UserId
    BuildFolder.Parent = workspace

    local function Notify(text)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Build", Text = text, Duration = 2
            })
        end)
    end
    local function UpdateCounter()
        if counterLbl then counterLbl.Text = "🧱 " .. #placedParts .. T("other.build.counter") end
    end

    -- ============================================================
    -- 📐 Position Calculation (supports stacking + manual offset)
    -- ============================================================
    local function Snap(v, g) return math.round(v / g) * g end

    local function GetPlacePos()
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return Vector3.new(0, 5, 0) end

        local origin = cam.CFrame.Position
        local dir    = cam.CFrame.LookVector

        local rp = RaycastParams.new()
        rp.FilterDescendantsInstances = (ghost and ghost.Parent) and {ghost, char} or {char}
        rp.FilterType = Enum.RaycastFilterType.Exclude

        local result = workspace:Raycast(origin, dir * (cfg.range + 20), rp)

        local pos
        if result then
            local n = result.Normal
            local absN = Vector3.new(math.abs(n.X), math.abs(n.Y), math.abs(n.Z))
            local half = absN.X * cfg.sizeX/2 + absN.Y * cfg.sizeY/2 + absN.Z * cfg.sizeZ/2
            pos = result.Position + n * half
        else
            pos = root.Position + cam.CFrame.LookVector * cfg.range + Vector3.new(0, cfg.sizeY/2, 0)
        end

        local camRight = cam.CFrame.RightVector
        local camForward = Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z).Unit
        pos = pos
            + camRight   * cfg.offX
            + Vector3.new(0, cfg.offY, 0)
            + camForward * cfg.offZ

        return Vector3.new(Snap(pos.X, cfg.gridSize), Snap(pos.Y, cfg.gridSize), Snap(pos.Z, cfg.gridSize))
    end

    -- ============================================================
    -- 🧱 Part Factory
    -- ============================================================
    local function MakePart(isGhost)
        local part
        if cfg.shape == "WedgePart" then part = Instance.new("WedgePart")
        elseif cfg.shape == "CornerWedgePart" then part = Instance.new("CornerWedgePart")
        elseif cfg.shape == "TrussPart" then part = Instance.new("TrussPart")
        else
            part = Instance.new("Part")
            if cfg.shape == "Cylinder" then Instance.new("SpecialMesh", part).MeshType = Enum.MeshType.Cylinder
            elseif cfg.shape == "Sphere" then Instance.new("SpecialMesh", part).MeshType = Enum.MeshType.Sphere end
        end
        part.Size       = (cfg.shape == "TrussPart") and Vector3.new(2, cfg.sizeY, 2) or Vector3.new(cfg.sizeX, cfg.sizeY, cfg.sizeZ)
        part.BrickColor = BrickColor.new(cfg.color)
        part.Material   = cfg.material
        part.Anchored   = true
        part.CanCollide = not isGhost
        part.CastShadow = not isGhost
        if isGhost then
            part.Transparency = 0.45
            pcall(function() part.CanQuery = false end)
        end
        return part
    end

    -- ============================================================
    -- 👻 Ghost Preview
    -- ============================================================
    local function StartGhost()
        if ghost then pcall(function() ghost:Destroy() end) end
        ghost = MakePart(true); ghost.Parent = workspace
        if ghostConn then ghostConn:Disconnect() end
        ghostConn = RunService.RenderStepped:Connect(function()
            if ghost and ghost.Parent then
                ghost.CFrame = CFrame.new(GetPlacePos()) * CFrame.Angles(0, math.rad(cfg.rotY), 0)
            end
        end)
    end
    local function StopGhost()
        if ghostConn then ghostConn:Disconnect(); ghostConn = nil end
        if ghost then pcall(function() ghost:Destroy() end); ghost = nil end
    end
    local function RefreshGhost() if cfg.buildOn then StartGhost() end end

    -- ============================================================
    -- 🔨 Place / Undo / Clear
    -- ============================================================
    local function PlacePart()
        if not cfg.buildOn then Notify(T("other.build.no_build")); return end
        if not lp.Character then return end
        local part = MakePart(false)
        part.CFrame = CFrame.new(GetPlacePos()) * CFrame.Angles(0, math.rad(cfg.rotY), 0)
        part.Parent = BuildFolder
        table.insert(placedParts, part)
        UpdateCounter()
        StartGhost()
    end
    local function UndoLast()
        if #placedParts == 0 then return end
        local last = table.remove(placedParts)
        if last and last.Parent then last:Destroy() end
        UpdateCounter()
        Notify(T("other.build.notif_undo") .. #placedParts)
    end
    local function ClearAll()
        for _, p in ipairs(placedParts) do if p and p.Parent then p:Destroy() end end
        placedParts = {}; UpdateCounter(); Notify(T("other.build.notif_clear"))
    end

    -- ============================================================
    -- 📱 Floating HUD (Place + D-Pad)
    -- ============================================================
    local function MakeHud()
        if hudGui then pcall(function() hudGui:Destroy() end) end

        local SG = Instance.new("ScreenGui")
        SG.Name = "CrypticBuildHUD"
        SG.ResetOnSpawn = false
        SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        SG.DisplayOrder = 999
        pcall(function() SG.Parent = game:GetService("CoreGui") end)
        if not SG.Parent then SG.Parent = lp.PlayerGui end
        hudGui = SG

        local Frame = Instance.new("Frame", SG)
        Frame.Size = UDim2.new(0, 148, 0, 168)
        Frame.Position = UDim2.new(1, -168, 1, -230)
        Frame.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
        Frame.BackgroundTransparency = 0.25
        Frame.BorderSizePixel = 0
        Frame.Active = true
        Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 14)
        GradStroke(Frame, 1.5)

        local DragLbl = Instance.new("TextLabel", Frame)
        DragLbl.Size = UDim2.new(1, 0, 0, 18)
        DragLbl.BackgroundTransparency = 1
        DragLbl.Text = ":: Build HUD ::"
        DragLbl.TextColor3 = Color3.fromRGB(80, 80, 100)
        DragLbl.Font = Enum.Font.GothamSemibold
        DragLbl.TextSize = 8
        DragLbl.TextXAlignment = Enum.TextXAlignment.Center

        local PlaceBtn = Instance.new("TextButton", Frame)
        PlaceBtn.Size = UDim2.new(0.9, 0, 0, 42)
        PlaceBtn.Position = UDim2.new(0.05, 0, 0, 20)
        PlaceBtn.BackgroundColor3 = Color3.fromRGB(0, 90, 55)
        PlaceBtn.BackgroundTransparency = 0
        PlaceBtn.Text = "🔨  " .. T("other.build.place")
        PlaceBtn.TextColor3 = Color3.new(1, 1, 1)
        PlaceBtn.Font = Enum.Font.GothamBlack
        PlaceBtn.TextSize = 12
        PlaceBtn.AutoButtonColor = false
        Instance.new("UICorner", PlaceBtn).CornerRadius = UDim.new(0, 10)
        GradStroke(PlaceBtn, 1.5)

        PlaceBtn.MouseEnter:Connect(function() Tw(PlaceBtn, {BackgroundColor3 = Color3.fromRGB(0, 130, 80)}, 0.1) end)
        PlaceBtn.MouseLeave:Connect(function() Tw(PlaceBtn, {BackgroundColor3 = Color3.fromRGB(0, 90, 55)}, 0.1) end)
        PlaceBtn.MouseButton1Click:Connect(function()
            Tw(PlaceBtn, {BackgroundColor3 = ACCENT}, 0.06)
            task.wait(0.06)
            Tw(PlaceBtn, {BackgroundColor3 = Color3.fromRGB(0, 90, 55)}, 0.15)
            PlacePart()
        end)

        local DpadBase = Instance.new("Frame", Frame)
        DpadBase.Size = UDim2.new(0.9, 0, 0, 90)
        DpadBase.Position = UDim2.new(0.05, 0, 0, 68)
        DpadBase.BackgroundTransparency = 1

        local BTN_S = 28

        local function DBtn(icon, x, y, cb)
            local B = Instance.new("TextButton", DpadBase)
            B.Size = UDim2.new(0, BTN_S, 0, BTN_S)
            B.Position = UDim2.new(0, x, 0, y)
            B.BackgroundColor3 = Color3.fromRGB(25, 25, 36)
            B.BackgroundTransparency = 0.2
            B.Text = icon
            B.TextColor3 = ACCENT
            B.Font = Enum.Font.GothamBlack
            B.TextSize = 14
            B.AutoButtonColor = false
            Instance.new("UICorner", B).CornerRadius = UDim.new(0, 7)
            GradStroke(B, 1)
            B.MouseEnter:Connect(function() Tw(B, {BackgroundTransparency = 0.7}, 0.1) end)
            B.MouseLeave:Connect(function() Tw(B, {BackgroundTransparency = 0.2}, 0.1) end)
            B.MouseButton1Click:Connect(function()
                cb()
                RefreshGhost()
            end)
            return B
        end

        local G = cfg.gridSize
        local mid = (130 - BTN_S) / 2

        DBtn("⬆", mid, 2,            function() cfg.offY = cfg.offY + G end)
        DBtn("⬇", mid, BTN_S + 6,   function() cfg.offY = cfg.offY - G end)
        DBtn("⬅", mid - BTN_S - 5, BTN_S/2 - 2, function() cfg.offX = cfg.offX - G end)
        DBtn("➡", mid + BTN_S + 5, BTN_S/2 - 2, function() cfg.offX = cfg.offX + G end)

        local OffLbl = Instance.new("TextLabel", DpadBase)
        OffLbl.Size = UDim2.new(1, 0, 0, 14)
        OffLbl.Position = UDim2.new(0, 0, 0, 66)
        OffLbl.BackgroundTransparency = 1
        OffLbl.Font = Enum.Font.Gotham
        OffLbl.TextSize = 8
        OffLbl.TextColor3 = Color3.fromRGB(80, 80, 110)
        OffLbl.TextXAlignment = Enum.TextXAlignment.Center

        local function UpdateOffLbl()
            OffLbl.Text = string.format("X:%.0f  Y:%.0f", cfg.offX, cfg.offY)
        end
        UpdateOffLbl()

        local ResetBtn = Instance.new("TextButton", DpadBase)
        ResetBtn.Size = UDim2.new(0, 40, 0, 16)
        ResetBtn.Position = UDim2.new(0.5, -20, 0, 80)
        ResetBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
        ResetBtn.BackgroundTransparency = 0.2
        ResetBtn.Text = T("other.build.reset")
        ResetBtn.TextColor3 = Color3.fromRGB(255, 90, 90)
        ResetBtn.Font = Enum.Font.GothamSemibold
        ResetBtn.TextSize = 8
        ResetBtn.AutoButtonColor = false
        Instance.new("UICorner", ResetBtn).CornerRadius = UDim.new(0, 5)
        ResetBtn.MouseButton1Click:Connect(function()
            cfg.offX, cfg.offY, cfg.offZ = 0, 0, 0
            UpdateOffLbl()
            RefreshGhost()
        end)

        for _, btn in ipairs(DpadBase:GetChildren()) do
            if btn:IsA("TextButton") and btn ~= ResetBtn then
                btn.MouseButton1Click:Connect(UpdateOffLbl)
            end
        end

        -- ── Drag Logic ──────────────────────────────────────────
        local dragging = false
        local dragInput, dragStart, startPos

        local function DragUpdate(input)
            local delta = input.Position - dragStart
            Frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end

        DragLbl.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos  = Frame.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        UIS.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
                          or input.UserInputType == Enum.UserInputType.Touch) then
                DragUpdate(input)
            end
        end)

        SG.Enabled = cfg.buildOn
        return SG
    end

    -- ============================================================
    -- 🗺️ UI Builder
    -- ============================================================
    local PAGE = Tab.Page

    local function MakeSection(icon, title, defaultOpen)
        Tab.Order = Tab.Order + 1
        local Hdr = Instance.new("TextButton", PAGE)
        Hdr.LayoutOrder = Tab.Order; Hdr.Size = UDim2.new(0.98, 0, 0, 40)
        Hdr.BackgroundColor3 = BG; Hdr.BackgroundTransparency = 0.1
        Hdr.Text = ""; Hdr.AutoButtonColor = false
        Instance.new("UICorner", Hdr).CornerRadius = UDim.new(0, 10)
        GradStroke(Hdr)

        local IL = Instance.new("TextLabel", Hdr)
        IL.Size = UDim2.new(0, 26, 1, 0); IL.Position = UDim2.new(0, 10, 0, 0)
        IL.BackgroundTransparency = 1; IL.Text = icon; IL.TextSize = 16
        IL.Font = Enum.Font.GothamBold

        local TL = Instance.new("TextLabel", Hdr)
        TL.Size = UDim2.new(0.75, 0, 1, 0); TL.Position = UDim2.new(0, 40, 0, 0)
        TL.BackgroundTransparency = 1; TL.Text = title
        TL.TextColor3 = Color3.fromRGB(200, 200, 215)
        TL.Font = Enum.Font.GothamBold; TL.TextSize = 11
        TL.TextXAlignment = Enum.TextXAlignment.Left

        local Arr = Instance.new("TextLabel", Hdr)
        Arr.Size = UDim2.new(0, 22, 1, 0); Arr.Position = UDim2.new(1, -26, 0, 0)
        Arr.BackgroundTransparency = 1; Arr.Text = ">"
        Arr.TextColor3 = Color3.fromRGB(80, 80, 100)
        Arr.Font = Enum.Font.GothamBlack; Arr.TextSize = 16

        Tab.Order = Tab.Order + 1
        local Cont = Instance.new("Frame", PAGE)
        Cont.LayoutOrder = Tab.Order; Cont.Size = UDim2.new(0.98, 0, 0, 0)
        Cont.BackgroundTransparency = 1; Cont.ClipsDescendants = true

        local LL = Instance.new("UIListLayout", Cont)
        LL.SortOrder = Enum.SortOrder.LayoutOrder
        LL.Padding = UDim.new(0, 5)
        LL.HorizontalAlignment = Enum.HorizontalAlignment.Center

        local LP = Instance.new("UIPadding", Cont)
        LP.PaddingTop = UDim.new(0, 5); LP.PaddingBottom = UDim.new(0, 5)

        local isOpen = defaultOpen or false
        local function setOpen(v)
            isOpen = v
            local h = LL.AbsoluteContentSize.Y + 12
            if isOpen then
                Tw(Cont, {Size = UDim2.new(0.98, 0, 0, h)}, 0.25)
                Tw(Arr, {Rotation = 90, TextColor3 = ACCENT}, 0.2)
            else
                Tw(Cont, {Size = UDim2.new(0.98, 0, 0, 0)}, 0.22)
                Tw(Arr, {Rotation = 0, TextColor3 = Color3.fromRGB(80, 80, 100)}, 0.2)
            end
        end
        LL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            if isOpen then Cont.Size = UDim2.new(0.98, 0, 0, LL.AbsoluteContentSize.Y + 12) end
        end)
        if defaultOpen then task.defer(function() setOpen(true) end) end
        Hdr.MouseEnter:Connect(function() Tw(Hdr, {BackgroundTransparency = 0.6}, 0.15) end)
        Hdr.MouseLeave:Connect(function() Tw(Hdr, {BackgroundTransparency = 0.1}, 0.15) end)
        Hdr.MouseButton1Click:Connect(function() setOpen(not isOpen) end)
        return Cont, LL
    end

    local function SectionGrid(parent, cols)
        local G = Instance.new("Frame", parent)
        G.Size = UDim2.new(0.96, 0, 0, 0); G.BackgroundTransparency = 1
        G.AutomaticSize = Enum.AutomaticSize.Y
        local GL = Instance.new("UIGridLayout", G)
        GL.CellSize = UDim2.new(1/cols, -4, 0, 38)
        GL.CellPadding = UDim2.new(0, 4, 0, 4)
        GL.SortOrder = Enum.SortOrder.LayoutOrder
        return G, GL
    end

    local function MakeStepper(parent, label, init, step, minV, maxV, onChange)
        local Row = Instance.new("Frame", parent)
        Row.Size = UDim2.new(0.96, 0, 0, 38)
        Row.BackgroundColor3 = BG2; Row.BackgroundTransparency = 0.1
        Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 8)
        GradStroke(Row)

        local Lbl = Instance.new("TextLabel", Row)
        Lbl.Size = UDim2.new(0.4, 0, 1, 0); Lbl.Position = UDim2.new(0, 8, 0, 0)
        Lbl.BackgroundTransparency = 1; Lbl.Text = label
        Lbl.TextColor3 = Color3.fromRGB(180, 180, 200)
        Lbl.Font = Enum.Font.GothamSemibold; Lbl.TextSize = 10
        Lbl.TextXAlignment = Enum.TextXAlignment.Left

        local val = init
        local ValL = Instance.new("TextLabel", Row)
        ValL.Size = UDim2.new(0.2, 0, 1, 0); ValL.Position = UDim2.new(0.4, 0, 0, 0)
        ValL.BackgroundTransparency = 1; ValL.Text = tostring(val)
        ValL.TextColor3 = ACCENT; ValL.Font = Enum.Font.GothamBlack; ValL.TextSize = 13
        ValL.TextXAlignment = Enum.TextXAlignment.Center

        local function MkBtn(txt, col, txtcol, xp)
            local B = Instance.new("TextButton", Row)
            B.Size = UDim2.new(0.17, 0, 0.72, 0); B.Position = UDim2.new(xp, 0, 0.14, 0)
            B.BackgroundColor3 = col; B.Text = txt; B.TextColor3 = txtcol
            B.Font = Enum.Font.GothamBlack; B.TextSize = 16; B.AutoButtonColor = false
            Instance.new("UICorner", B).CornerRadius = UDim.new(0, 6)
            return B
        end

        local Minus = MkBtn("-", Color3.fromRGB(50, 30, 30), Color3.fromRGB(255, 80, 80), 0.61)
        local Plus  = MkBtn("+", Color3.fromRGB(20, 50, 35), ACCENT, 0.80)

        Minus.MouseButton1Click:Connect(function()
            val = math.max(minV, val - step); ValL.Text = tostring(val); pcall(onChange, val)
        end)
        Plus.MouseButton1Click:Connect(function()
            val = math.min(maxV, val + step); ValL.Text = tostring(val); pcall(onChange, val)
        end)
        return Row
    end

    -- ============================================================
    -- 🏗️ Build Mode Toggle Row
    -- ============================================================
    local function BuildMainUI()

        Tab.Order = Tab.Order + 1
        local BRow = Instance.new("Frame", PAGE)
        BRow.LayoutOrder = Tab.Order; BRow.Size = UDim2.new(0.98, 0, 0, 52)
        BRow.BackgroundColor3 = Color3.fromRGB(10, 30, 20); BRow.BackgroundTransparency = 0.05
        Instance.new("UICorner", BRow).CornerRadius = UDim.new(0, 12)
        GradStroke(BRow, 1.5)

        local BIco = Instance.new("TextLabel", BRow)
        BIco.Size = UDim2.new(0, 34, 1, 0); BIco.Position = UDim2.new(0, 8, 0, 0)
        BIco.BackgroundTransparency = 1; BIco.Text = "🏗️"; BIco.TextSize = 22
        BIco.Font = Enum.Font.GothamBold

        local BLbl = Instance.new("TextLabel", BRow)
        BLbl.Size = UDim2.new(0.5, 0, 1, 0); BLbl.Position = UDim2.new(0, 48, 0, 0)
        BLbl.BackgroundTransparency = 1; BLbl.Text = T("other.build.build_mode")
        BLbl.TextColor3 = Color3.new(1, 1, 1)
        BLbl.Font = Enum.Font.GothamBlack; BLbl.TextSize = 13
        BLbl.TextXAlignment = Enum.TextXAlignment.Left

        local TW, TH = 52, 26
        local Track = Instance.new("Frame", BRow)
        Track.Size = UDim2.new(0, TW, 0, TH)
        Track.Position = UDim2.new(1, -(TW + 12), 0.5, -TH/2)
        Track.BackgroundColor3 = Color3.fromRGB(45, 45, 55); Track.BorderSizePixel = 0
        Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)
        local Knob = Instance.new("Frame", Track)
        Knob.Size = UDim2.new(0, 20, 0, 20); Knob.Position = UDim2.new(0, 3, 0.5, -10)
        Knob.BackgroundColor3 = Color3.fromRGB(200, 200, 215); Knob.BorderSizePixel = 0
        Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

        local TBtn = Instance.new("TextButton", BRow)
        TBtn.Size = UDim2.new(1, 0, 1, 0); TBtn.BackgroundTransparency = 1
        TBtn.Text = ""; TBtn.AutoButtonColor = false

        local buildActive = false
        local function SetBuild(on)
            buildActive = on; cfg.buildOn = on
            if on then
                Tw(Track, {BackgroundColor3 = ACCENT}, 0.18)
                Tw(Knob, {Position = UDim2.new(0, TW - 23, 0.5, -10), BackgroundColor3 = Color3.new(1,1,1)}, 0.18)
                Tw(BRow, {BackgroundColor3 = Color3.fromRGB(0, 50, 32)}, 0.2)
                BLbl.TextColor3 = ACCENT; StartGhost()
                if not hudGui then MakeHud() end
                if hudGui then hudGui.Enabled = true end
                Notify(T("other.build.notif_on"))
            else
                Tw(Track, {BackgroundColor3 = Color3.fromRGB(45, 45, 55)}, 0.18)
                Tw(Knob, {Position = UDim2.new(0, 3, 0.5, -10), BackgroundColor3 = Color3.fromRGB(200, 200, 215)}, 0.18)
                Tw(BRow, {BackgroundColor3 = Color3.fromRGB(10, 30, 20)}, 0.2)
                BLbl.TextColor3 = Color3.new(1, 1, 1); StopGhost()
                if hudGui then hudGui.Enabled = false end
                Notify(T("other.build.notif_off"))
            end
        end
        TBtn.MouseButton1Click:Connect(function() SetBuild(not buildActive) end)

        -- ── Shape Section ──────────────────────────────────────
        local ShapeCont, _ = MakeSection("📐", T("other.build.shape"), true)
        local shapeGrid, _ = SectionGrid(ShapeCont, 3)

        local shapeBtns = {}
        local function SelectShape(key)
            cfg.shape = key
            for _, info in ipairs(shapeBtns) do
                local sel = (info.key == key)
                Tw(info.btn, {
                    BackgroundColor3 = sel and Color3.fromRGB(0, 60, 40) or BG2,
                    BackgroundTransparency = sel and 0 or 0.4
                }, 0.15)
            end
            RefreshGhost()
        end
        for i, key in ipairs(SHAPE_KEYS) do
            local Btn = Instance.new("TextButton", shapeGrid)
            Btn.LayoutOrder = i; Btn.BackgroundColor3 = BG2; Btn.BackgroundTransparency = 0.4
            Btn.Text = T("other.build.shape." .. SHAPE_LBL_KEYS[i])
            Btn.TextColor3 = Color3.fromRGB(200, 200, 215)
            Btn.Font = Enum.Font.GothamBold; Btn.TextSize = 10; Btn.AutoButtonColor = false
            Btn.TextWrapped = true
            Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8); GradStroke(Btn)
            Btn.MouseButton1Click:Connect(function() SelectShape(key) end)
            table.insert(shapeBtns, {btn = Btn, key = key})
        end
        SelectShape("Part")

        -- ── Color Section ─────────────────────────────────────
        local ColorCont, _ = MakeSection("🎨", T("other.build.color"), false)
        local colorGrid, _ = SectionGrid(ColorCont, 5)

        local COLORS = {
            Color3.fromRGB(242,243,243), Color3.fromRGB(163,162,165), Color3.fromRGB(27,42,53),
            Color3.fromRGB(196,40,28),   Color3.fromRGB(234,118,0),   Color3.fromRGB(245,205,48),
            Color3.fromRGB(39,70,45),    Color3.fromRGB(13,105,172),  Color3.fromRGB(107,50,124),
            Color3.fromRGB(255,152,220), Color3.fromRGB(105,64,40),   Color3.fromRGB(255,207,75),
            Color3.fromRGB(0,200,220),   Color3.fromRGB(175,221,255), Color3.fromRGB(0,220,120),
        }
        local colorBtns = {}
        local function SelectColor(col, ref)
            cfg.color = col
            if ghost then ghost.BrickColor = BrickColor.new(col) end
            for _, b in ipairs(colorBtns) do b.BorderSizePixel = 0 end
            if ref then ref.BorderSizePixel = 3; ref.BorderColor3 = Color3.new(1,1,1) end
        end
        for i, col in ipairs(COLORS) do
            local CB = Instance.new("TextButton", colorGrid)
            CB.LayoutOrder = i; CB.BackgroundColor3 = col; CB.BackgroundTransparency = 0.1
            CB.Text = ""; CB.AutoButtonColor = false
            Instance.new("UICorner", CB).CornerRadius = UDim.new(0, 6)
            CB.MouseButton1Click:Connect(function() SelectColor(col, CB) end)
            table.insert(colorBtns, CB)
        end

        -- ── Material Section ──────────────────────────────────
        local MatCont, _ = MakeSection("🧱", T("other.build.material"), false)
        local matGrid, _ = SectionGrid(MatCont, 3)

        local MAT_ENUMS = {
            Enum.Material.SmoothPlastic, Enum.Material.Brick, Enum.Material.Wood,
            Enum.Material.Metal, Enum.Material.Neon, Enum.Material.Glass,
            Enum.Material.Marble, Enum.Material.Granite, Enum.Material.Ice,
            Enum.Material.Grass, Enum.Material.Sand, Enum.Material.DiamondPlate,
        }
        local matBtns = {}
        local function SelectMat(mat, ref)
            cfg.material = mat
            if ghost then ghost.Material = mat end
            for _, b in ipairs(matBtns) do
                Tw(b, {BackgroundColor3 = BG2, BackgroundTransparency = 0.2}, 0.1)
                b.TextColor3 = Color3.fromRGB(180, 180, 200)
            end
            if ref then
                Tw(ref, {BackgroundColor3 = Color3.fromRGB(0, 60, 40), BackgroundTransparency = 0}, 0.1)
                ref.TextColor3 = ACCENT
            end
        end
        for i, mat in ipairs(MAT_ENUMS) do
            local MB = Instance.new("TextButton", matGrid)
            MB.LayoutOrder = i; MB.BackgroundColor3 = BG2; MB.BackgroundTransparency = 0.2
            MB.Text = T("other.build.mat." .. MAT_LBL_KEYS[i])
            MB.TextColor3 = Color3.fromRGB(180, 180, 200)
            MB.Font = Enum.Font.GothamSemibold; MB.TextSize = 9; MB.AutoButtonColor = false
            Instance.new("UICorner", MB).CornerRadius = UDim.new(0, 8); GradStroke(MB)
            MB.MouseButton1Click:Connect(function() SelectMat(mat, MB) end)
            table.insert(matBtns, MB)
        end
        SelectMat(Enum.Material.SmoothPlastic, matBtns[1])

        -- ── Size Section ──────────────────────────────────────
        local SizeCont, _ = MakeSection("📏", T("other.build.size"), false)
        MakeStepper(SizeCont, T("other.build.width"),  4, 1, 0.5, 50, function(v) cfg.sizeX = v; RefreshGhost() end)
        MakeStepper(SizeCont, T("other.build.height"), 4, 1, 0.5, 50, function(v) cfg.sizeY = v; RefreshGhost() end)
        MakeStepper(SizeCont, T("other.build.depth"),  4, 1, 0.5, 50, function(v) cfg.sizeZ = v; RefreshGhost() end)

        -- ── Extra Section ─────────────────────────────────────
        local ExtraCont, _ = MakeSection("⚙️", T("other.build.extra"), false)
        MakeStepper(ExtraCont, T("other.build.range"), 20, 2, 4, 60, function(v) cfg.range = v end)

        local RotRow = Instance.new("Frame", ExtraCont)
        RotRow.Size = UDim2.new(0.96, 0, 0, 38)
        RotRow.BackgroundColor3 = BG2; RotRow.BackgroundTransparency = 0.1
        Instance.new("UICorner", RotRow).CornerRadius = UDim.new(0, 8); GradStroke(RotRow)

        local RL = Instance.new("TextLabel", RotRow)
        RL.Size = UDim2.new(0.38, 0, 1, 0); RL.Position = UDim2.new(0, 8, 0, 0)
        RL.BackgroundTransparency = 1; RL.Text = T("other.build.rotate")
        RL.TextColor3 = Color3.fromRGB(180, 180, 200)
        RL.Font = Enum.Font.GothamSemibold; RL.TextSize = 10; RL.TextXAlignment = Enum.TextXAlignment.Left

        local RV = Instance.new("TextLabel", RotRow)
        RV.Size = UDim2.new(0.22, 0, 1, 0); RV.Position = UDim2.new(0.39, 0, 0, 0)
        RV.BackgroundTransparency = 1; RV.Text = "0"
        RV.TextColor3 = ACCENT; RV.Font = Enum.Font.GothamBlack; RV.TextSize = 12
        RV.TextXAlignment = Enum.TextXAlignment.Center

        local function RotBtn(txt, xp, delta)
            local B = Instance.new("TextButton", RotRow)
            B.Size = UDim2.new(0.18, 0, 0.72, 0); B.Position = UDim2.new(xp, 0, 0.14, 0)
            B.BackgroundColor3 = Color3.fromRGB(30, 30, 50); B.Text = txt
            B.TextColor3 = ACCENT2; B.Font = Enum.Font.GothamBlack; B.TextSize = 11
            B.AutoButtonColor = false
            Instance.new("UICorner", B).CornerRadius = UDim.new(0, 6)
            B.MouseButton1Click:Connect(function()
                cfg.rotY = (cfg.rotY + delta) % 360; RV.Text = cfg.rotY .. ""
                RefreshGhost()
            end)
        end
        RotBtn("-90", 0.60, -90); RotBtn("+90", 0.80, 90)

        -- ── Action Buttons ────────────────────────────────────
        Tab.Order = Tab.Order + 1
        local DivL = Instance.new("Frame", PAGE)
        DivL.LayoutOrder = Tab.Order; DivL.Size = UDim2.new(0.9, 0, 0, 1)
        DivL.BackgroundTransparency = 0.4
        local DG = Instance.new("UIGradient", DivL)
        DG.Color = ColorSequence.new{ColorSequenceKeypoint.new(0,ACCENT),ColorSequenceKeypoint.new(1,ACCENT2)}

        Tab.Order = Tab.Order + 1
        local PlaceBtn = Instance.new("TextButton", PAGE)
        PlaceBtn.LayoutOrder = Tab.Order; PlaceBtn.Size = UDim2.new(0.98, 0, 0, 54)
        PlaceBtn.BackgroundColor3 = Color3.fromRGB(0, 80, 50); PlaceBtn.BackgroundTransparency = 0
        PlaceBtn.Text = "🔨  " .. T("other.build.place")
        PlaceBtn.TextColor3 = Color3.new(1, 1, 1); PlaceBtn.Font = Enum.Font.GothamBlack; PlaceBtn.TextSize = 15
        PlaceBtn.AutoButtonColor = false
        Instance.new("UICorner", PlaceBtn).CornerRadius = UDim.new(0, 12); GradStroke(PlaceBtn, 2)
        PlaceBtn.MouseEnter:Connect(function() Tw(PlaceBtn, {BackgroundColor3 = Color3.fromRGB(0,120,75)}, 0.12) end)
        PlaceBtn.MouseLeave:Connect(function() Tw(PlaceBtn, {BackgroundColor3 = Color3.fromRGB(0,80,50)}, 0.12) end)
        PlaceBtn.MouseButton1Click:Connect(function()
            if not cfg.buildOn then
                Tw(BRow, {BackgroundColor3 = Color3.fromRGB(80,30,0)}, 0.1)
                task.wait(0.25); Tw(BRow, {BackgroundColor3 = Color3.fromRGB(10,30,20)}, 0.3)
                Notify(T("other.build.no_build")); return
            end
            Tw(PlaceBtn, {BackgroundColor3 = ACCENT}, 0.07)
            task.wait(0.07); Tw(PlaceBtn, {BackgroundColor3 = Color3.fromRGB(0,80,50)}, 0.18)
            PlacePart()
        end)

        Tab.Order = Tab.Order + 1
        local ARow = Instance.new("Frame", PAGE)
        ARow.LayoutOrder = Tab.Order; ARow.Size = UDim2.new(0.98, 0, 0, 42)
        ARow.BackgroundTransparency = 1

        local function ActionBtn(txt, col, txtcol, xp, cb)
            local B = Instance.new("TextButton", ARow)
            B.Size = UDim2.new(0.48, 0, 1, 0); B.Position = UDim2.new(xp, 0, 0, 0)
            B.BackgroundColor3 = col; B.BackgroundTransparency = 0.1
            B.Text = txt; B.TextColor3 = txtcol
            B.Font = Enum.Font.GothamBold; B.TextSize = 12; B.AutoButtonColor = false
            Instance.new("UICorner", B).CornerRadius = UDim.new(0, 10); GradStroke(B)
            B.MouseEnter:Connect(function() Tw(B, {BackgroundTransparency = 0.65}, 0.1) end)
            B.MouseLeave:Connect(function() Tw(B, {BackgroundTransparency = 0.1}, 0.1) end)
            B.MouseButton1Click:Connect(cb)
            return B
        end
        ActionBtn("↩  " .. T("other.build.undo"),    Color3.fromRGB(40,30,10), Color3.fromRGB(255,200,50), 0,    UndoLast)
        ActionBtn("X  " .. T("other.build.clear_all"), Color3.fromRGB(50,15,15), Color3.fromRGB(255,80,80),  0.52, function()
            if #placedParts == 0 then return end; ClearAll()
        end)

        Tab.Order = Tab.Order + 1
        local HintF = Instance.new("Frame", PAGE)
        HintF.LayoutOrder = Tab.Order; HintF.Size = UDim2.new(0.98, 0, 0, 30)
        HintF.BackgroundColor3 = Color3.fromRGB(0,30,20); HintF.BackgroundTransparency = 0.3
        Instance.new("UICorner", HintF).CornerRadius = UDim.new(0, 8)
        local HL = Instance.new("TextLabel", HintF)
        HL.Size = UDim2.new(1, -8, 1, 0); HL.Position = UDim2.new(0, 4, 0, 0)
        HL.BackgroundTransparency = 1; HL.Text = "💡 " .. T("other.build.hint")
        HL.TextColor3 = Color3.fromRGB(0, 200, 120)
        HL.Font = Enum.Font.Gotham; HL.TextSize = 8; HL.TextWrapped = true
        HL.TextXAlignment = Enum.TextXAlignment.Center

        -- ── Demolish Hammer ───────────────────────────────────
        local demolishActive = false
        local demolishConn   = nil
        local demolishHover  = nil

        Tab.Order = Tab.Order + 1
        local DemRow = Instance.new("Frame", PAGE)
        DemRow.LayoutOrder = Tab.Order; DemRow.Size = UDim2.new(0.98, 0, 0, 52)
        DemRow.BackgroundColor3 = Color3.fromRGB(45, 10, 10); DemRow.BackgroundTransparency = 0.05
        Instance.new("UICorner", DemRow).CornerRadius = UDim.new(0, 12)
        GradStroke(DemRow, 1.5)

        local DIco = Instance.new("TextLabel", DemRow)
        DIco.Size = UDim2.new(0, 34, 1, 0); DIco.Position = UDim2.new(0, 8, 0, 0)
        DIco.BackgroundTransparency = 1; DIco.Text = "⛏️"; DIco.TextSize = 22
        DIco.Font = Enum.Font.GothamBold

        local DLbl = Instance.new("TextLabel", DemRow)
        DLbl.Size = UDim2.new(0.55, 0, 1, 0); DLbl.Position = UDim2.new(0, 48, 0, 0)
        DLbl.BackgroundTransparency = 1; DLbl.Text = T("other.build.demolish")
        DLbl.TextColor3 = Color3.new(1, 1, 1)
        DLbl.Font = Enum.Font.GothamBlack; DLbl.TextSize = 13
        DLbl.TextXAlignment = Enum.TextXAlignment.Left

        local RED = Color3.fromRGB(255, 70, 70)
        local DTW, DTH = 52, 26
        local DTrack = Instance.new("Frame", DemRow)
        DTrack.Size = UDim2.new(0, DTW, 0, DTH)
        DTrack.Position = UDim2.new(1, -(DTW + 12), 0.5, -DTH/2)
        DTrack.BackgroundColor3 = Color3.fromRGB(45, 45, 55); DTrack.BorderSizePixel = 0
        Instance.new("UICorner", DTrack).CornerRadius = UDim.new(1, 0)
        local DKnob = Instance.new("Frame", DTrack)
        DKnob.Size = UDim2.new(0, 20, 0, 20); DKnob.Position = UDim2.new(0, 3, 0.5, -10)
        DKnob.BackgroundColor3 = Color3.fromRGB(200, 200, 215); DKnob.BorderSizePixel = 0
        Instance.new("UICorner", DKnob).CornerRadius = UDim.new(1, 0)
        local DTBtn = Instance.new("TextButton", DemRow)
        DTBtn.Size = UDim2.new(1, 0, 1, 0); DTBtn.BackgroundTransparency = 1
        DTBtn.Text = ""; DTBtn.AutoButtonColor = false

        local function StopDemolish()
            demolishActive = false
            if demolishConn then demolishConn:Disconnect(); demolishConn = nil end
            if demolishHover then
                pcall(function() demolishHover:Destroy() end)
                demolishHover = nil
            end
        end

        local function SetDemolish(on)
            if on then
                demolishActive = true
                if cfg.buildOn then SetBuild(false) end
                Tw(DTrack, {BackgroundColor3 = RED}, 0.18)
                Tw(DKnob, {Position = UDim2.new(0, DTW - 23, 0.5, -10), BackgroundColor3 = Color3.new(1,1,1)}, 0.18)
                Tw(DemRow, {BackgroundColor3 = Color3.fromRGB(80, 8, 8)}, 0.2)
                DLbl.TextColor3 = RED
                Notify(T("other.build.demolish_on"))

                local mouse = lp:GetMouse()
                local box = Instance.new("SelectionBox")
                box.Color3 = RED; box.LineThickness = 0.05
                box.Parent = workspace
                demolishHover = box

                local hoverConn = RunService.RenderStepped:Connect(function()
                    if not demolishActive then return end
                    local t = mouse.Target
                    box.Adornee = (t and t:IsDescendantOf(BuildFolder)) and t or nil
                end)

                demolishConn = UIS.InputBegan:Connect(function(input, gp)
                    if gp then return end
                    if input.UserInputType ~= Enum.UserInputType.MouseButton1
                    and input.UserInputType ~= Enum.UserInputType.Touch then return end
                    local target = mouse.Target
                    if target and target:IsDescendantOf(BuildFolder) then
                        box.Adornee = nil
                        for i, p in ipairs(placedParts) do
                            if p == target then table.remove(placedParts, i); break end
                        end
                        target:Destroy()
                        UpdateCounter()
                    end
                end)

                local stopWatch; stopWatch = RunService.Heartbeat:Connect(function()
                    if not demolishActive then hoverConn:Disconnect(); stopWatch:Disconnect() end
                end)
            else
                StopDemolish()
                Tw(DTrack, {BackgroundColor3 = Color3.fromRGB(45, 45, 55)}, 0.18)
                Tw(DKnob, {Position = UDim2.new(0, 3, 0.5, -10), BackgroundColor3 = Color3.fromRGB(200, 200, 215)}, 0.18)
                Tw(DemRow, {BackgroundColor3 = Color3.fromRGB(45, 10, 10)}, 0.2)
                DLbl.TextColor3 = Color3.new(1, 1, 1)
                Notify(T("other.build.demolish_off"))
            end
        end
        DTBtn.MouseButton1Click:Connect(function() SetDemolish(not demolishActive) end)

        -- ── Preset Houses ─────────────────────────────────────
        local PreCont, _ = MakeSection("🏠", T("other.build.presets"), false)
        local preGrid, _ = SectionGrid(PreCont, 1)

        local V3 = Vector3.new

        local presetGhosts   = {}
        local presetGhostCon = nil
        local presetPlaceGui = nil

        local function ClearPresetGhosts()
            if presetGhostCon then presetGhostCon:Disconnect(); presetGhostCon = nil end
            for _, gp in ipairs(presetGhosts) do pcall(function() gp:Destroy() end) end
            presetGhosts = {}
            if presetPlaceGui then pcall(function() presetPlaceGui:Destroy() end); presetPlaceGui = nil end
        end

        local function GetPresetBase()
            local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
            if not root then return Vector3.new(0, 0, 0) end
            local look = cam.CFrame.LookVector
            local dist = 26
            return Vector3.new(
                math.round(root.Position.X + look.X * dist),
                math.round(root.Position.Y) - 3,
                math.round(root.Position.Z + look.Z * dist)
            )
        end

        local function StartPresetGhost(parts, label)
            ClearPresetGhosts()
            if cfg.buildOn then SetBuild(false) end

            for _, d in ipairs(parts) do
                local gp = Instance.new("Part")
                gp.Size        = d.size
                gp.BrickColor  = BrickColor.new(d.color)
                gp.Material    = d.mat
                gp.Anchored    = true
                gp.CanCollide  = false
                gp.CastShadow  = false
                gp.Transparency = 0.48
                pcall(function() gp.CanQuery = false end)
                gp.Parent = workspace
                table.insert(presetGhosts, gp)
            end

            presetGhostCon = RunService.RenderStepped:Connect(function()
                local base = GetPresetBase()
                for i, gp in ipairs(presetGhosts) do
                    if gp and gp.Parent then
                        local d = parts[i]
                        gp.CFrame = CFrame.new(base + V3(d.ox, d.oy, d.oz))
                    end
                end
            end)

            local SG = Instance.new("ScreenGui")
            SG.Name = "CrypticPresetConfirm"; SG.ResetOnSpawn = false; SG.DisplayOrder = 1001
            pcall(function() SG.Parent = game:GetService("CoreGui") end)
            if not SG.Parent then SG.Parent = lp.PlayerGui end
            presetPlaceGui = SG

            local Popup = Instance.new("Frame", SG)
            Popup.Size = UDim2.new(0, 240, 0, 70)
            Popup.Position = UDim2.new(0.5, -120, 1, -108)
            Popup.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
            Popup.BackgroundTransparency = 0.1; Popup.BorderSizePixel = 0
            Instance.new("UICorner", Popup).CornerRadius = UDim.new(0, 14)
            GradStroke(Popup, 1.5)

            local HintL = Instance.new("TextLabel", Popup)
            HintL.Size = UDim2.new(1, 0, 0, 16); HintL.Position = UDim2.new(0, 0, 0, 6)
            HintL.BackgroundTransparency = 1; HintL.Text = T("other.build.preset_moving")
            HintL.TextColor3 = Color3.fromRGB(0, 200, 150)
            HintL.Font = Enum.Font.Gotham; HintL.TextSize = 9
            HintL.TextXAlignment = Enum.TextXAlignment.Center

            local ConfBtn = Instance.new("TextButton", Popup)
            ConfBtn.Size = UDim2.new(0.54, -6, 0, 36)
            ConfBtn.Position = UDim2.new(0, 8, 0, 26)
            ConfBtn.BackgroundColor3 = Color3.fromRGB(0, 80, 50)
            ConfBtn.Text = T("other.build.preset_place"); ConfBtn.TextColor3 = Color3.new(1,1,1)
            ConfBtn.Font = Enum.Font.GothamBlack; ConfBtn.TextSize = 12; ConfBtn.AutoButtonColor = false
            Instance.new("UICorner", ConfBtn).CornerRadius = UDim.new(0, 10); GradStroke(ConfBtn)

            local CancelBtn = Instance.new("TextButton", Popup)
            CancelBtn.Size = UDim2.new(0.43, -6, 0, 36)
            CancelBtn.Position = UDim2.new(0.57, -2, 0, 26)
            CancelBtn.BackgroundColor3 = Color3.fromRGB(70, 12, 12)
            CancelBtn.Text = T("other.build.preset_cancel"); CancelBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
            CancelBtn.Font = Enum.Font.GothamBold; CancelBtn.TextSize = 12; CancelBtn.AutoButtonColor = false
            Instance.new("UICorner", CancelBtn).CornerRadius = UDim.new(0, 10); GradStroke(CancelBtn)

            ConfBtn.MouseEnter:Connect(function()   Tw(ConfBtn, {BackgroundColor3 = Color3.fromRGB(0,120,75)}, 0.1) end)
            ConfBtn.MouseLeave:Connect(function()   Tw(ConfBtn, {BackgroundColor3 = Color3.fromRGB(0,80,50)}, 0.1) end)
            CancelBtn.MouseEnter:Connect(function() Tw(CancelBtn, {BackgroundColor3 = Color3.fromRGB(100,20,20)}, 0.1) end)
            CancelBtn.MouseLeave:Connect(function() Tw(CancelBtn, {BackgroundColor3 = Color3.fromRGB(70,12,12)}, 0.1) end)

            ConfBtn.MouseButton1Click:Connect(function()
                if presetGhostCon then presetGhostCon:Disconnect(); presetGhostCon = nil end
                for _, gp in ipairs(presetGhosts) do
                    if gp and gp.Parent then
                        gp.CanCollide  = true
                        gp.Transparency = 0
                        gp.CastShadow  = true
                        gp.Parent = BuildFolder
                        table.insert(placedParts, gp)
                    end
                end
                presetGhosts = {}
                if presetPlaceGui then pcall(function() presetPlaceGui:Destroy() end); presetPlaceGui = nil end
                UpdateCounter()
                Notify(label .. "  " .. T("other.build.preset_built"))
            end)

            CancelBtn.MouseButton1Click:Connect(function()
                ClearPresetGhosts()
            end)
        end

        -- ══ Preset Designs ═══════════════════════════════════════
        local WHITE  = Color3.fromRGB(242, 243, 243)
        local WMAT   = Enum.Material.SmoothPlastic
        local ROOF_C = Color3.fromRGB(194, 218, 240)
        local FLOOR_C= Color3.fromRGB(203, 204, 200)

        local HOUSE = {
            {size=V3(22,1,16), ox=0,    oy=0,   oz=0,   color=FLOOR_C, mat=WMAT},
            {size=V3(22,10,1), ox=0,    oy=5.5, oz=7.5, color=WHITE,   mat=WMAT},
            {size=V3(7,10,1),  ox=-7.5, oy=5.5, oz=-7.5,color=WHITE,   mat=WMAT},
            {size=V3(7,10,1),  ox=7.5,  oy=5.5, oz=-7.5,color=WHITE,   mat=WMAT},
            {size=V3(4,3,1),   ox=0,    oy=9.5, oz=-7.5,color=WHITE,   mat=WMAT},
            {size=V3(1,10,6),  ox=-10.5,oy=5.5, oz=-4,  color=WHITE,   mat=WMAT},
            {size=V3(1,10,6),  ox=-10.5,oy=5.5, oz=4,   color=WHITE,   mat=WMAT},
            {size=V3(1,4,4),   ox=-10.5,oy=9,   oz=0,   color=WHITE,   mat=WMAT},
            {size=V3(1,10,6),  ox=10.5, oy=5.5, oz=-4,  color=WHITE,   mat=WMAT},
            {size=V3(1,10,6),  ox=10.5, oy=5.5, oz=4,   color=WHITE,   mat=WMAT},
            {size=V3(1,4,4),   ox=10.5, oy=9,   oz=0,   color=WHITE,   mat=WMAT},
            {size=V3(24,1,18), ox=0,    oy=11,  oz=0,   color=ROOF_C,  mat=WMAT},
        }

        local MAR = Enum.Material.Marble
        local TOWER = {
            {size=V3(12,1,12),  ox=0,   oy=0,   oz=0,   color=WHITE, mat=MAR},
            {size=V3(12,24,1),  ox=0,   oy=12,  oz=-5.5,color=WHITE, mat=MAR},
            {size=V3(12,24,1),  ox=0,   oy=12,  oz=5.5, color=WHITE, mat=MAR},
            {size=V3(1,24,12),  ox=-5.5,oy=12,  oz=0,   color=WHITE, mat=MAR},
            {size=V3(1,24,12),  ox=5.5, oy=12,  oz=0,   color=WHITE, mat=MAR},
            {size=V3(14,1.5,14),ox=0,   oy=24,  oz=0,   color=Color3.fromRGB(230,235,245), mat=MAR},
            {size=V3(3,4,3),    ox=-5,  oy=26,  oz=-5,  color=WHITE, mat=MAR},
            {size=V3(3,4,3),    ox=5,   oy=26,  oz=-5,  color=WHITE, mat=MAR},
            {size=V3(3,4,3),    ox=-5,  oy=26,  oz=5,   color=WHITE, mat=MAR},
            {size=V3(3,4,3),    ox=5,   oy=26,  oz=5,   color=WHITE, mat=MAR},
            {size=V3(4,3,1),    ox=0,   oy=26,  oz=-6,  color=WHITE, mat=MAR},
            {size=V3(4,3,1),    ox=0,   oy=26,  oz=6,   color=WHITE, mat=MAR},
            {size=V3(1,3,4),    ox=-6,  oy=26,  oz=0,   color=WHITE, mat=MAR},
            {size=V3(1,3,4),    ox=6,   oy=26,  oz=0,   color=WHITE, mat=MAR},
        }

        local WOOD_W = Color3.fromRGB(188, 143, 98)
        local WOOD_R = Color3.fromRGB(101, 60, 32)
        local WM     = Enum.Material.Wood
        local CABIN = {
            {size=V3(14,1,10), ox=0,    oy=0,  oz=0,   color=FLOOR_C, mat=WMAT},
            {size=V3(14,8,1),  ox=0,    oy=4.5,oz=4.5, color=WOOD_W,  mat=WM},
            {size=V3(4,8,1),   ox=-5,   oy=4.5,oz=-4.5,color=WOOD_W,  mat=WM},
            {size=V3(4,8,1),   ox=5,    oy=4.5,oz=-4.5,color=WOOD_W,  mat=WM},
            {size=V3(2,3.5,1), ox=0,    oy=7.5,oz=-4.5,color=WOOD_W,  mat=WM},
            {size=V3(1,8,10),  ox=-6.5, oy=4.5,oz=0,   color=WOOD_W,  mat=WM},
            {size=V3(1,8,10),  ox=6.5,  oy=4.5,oz=0,   color=WOOD_W,  mat=WM},
            {size=V3(16,1,12), ox=0,    oy=9,  oz=0,   color=WOOD_R,  mat=WM},
        }

        local function PreBtn(label, parts)
            local B = Instance.new("TextButton", preGrid)
            B.BackgroundColor3 = Color3.fromRGB(15, 18, 15); B.BackgroundTransparency = 0.1
            B.Text = label; B.TextColor3 = ACCENT
            B.Font = Enum.Font.GothamBold; B.TextSize = 12; B.AutoButtonColor = false
            B.TextWrapped = false
            Instance.new("UICorner", B).CornerRadius = UDim.new(0, 8)
            GradStroke(B)
            B.MouseEnter:Connect(function() Tw(B, {BackgroundTransparency = 0.6}, 0.1) end)
            B.MouseLeave:Connect(function() Tw(B, {BackgroundTransparency = 0.1}, 0.1) end)
            B.MouseButton1Click:Connect(function()
                Tw(B, {BackgroundColor3 = Color3.fromRGB(0,60,40)}, 0.07)
                task.wait(0.1); Tw(B, {BackgroundColor3 = Color3.fromRGB(15,18,15)}, 0.2)
                StartPresetGhost(parts, label)
            end)
        end

        PreBtn(T("other.build.preset_house"), HOUSE)
        PreBtn(T("other.build.preset_tower"), TOWER)
        PreBtn(T("other.build.preset_cabin"), CABIN)

    end -- BuildMainUI

    -- ============================================================
    -- 🚀 Initialize directly (global i18n already chose language)
    -- ============================================================
    BuildMainUI()
    MakeHud()

    -- ============================================================
    -- 🔄 Cleanup
    -- ============================================================
    lp.CharacterAdded:Connect(function()
        task.wait(1); if cfg.buildOn then StartGhost() end
    end)

    local cg = game:GetService("CoreGui"):FindFirstChild("CrypticHub_V8_Premium")
    if cg then
        cg.AncestryChanged:Connect(function(_, p)
            if not p then
                StopGhost()
                for _, pt in ipairs(placedParts) do if pt and pt.Parent then pt:Destroy() end end
                pcall(function() BuildFolder:Destroy() end)
                if hudGui then pcall(function() hudGui:Destroy() end) end
            end
        end)
    end
end
