-- [[ Cryptic Hub - Element: HotkeyToggle ]]
-- Compact card: toggle enable/disable + key chip to set shortcut key
-- API: HotkeyToggle(TabOps, label, saveFile, callback)
--      callback(active, key) fires whenever toggle or key changes

return function(TabOps, label, saveFile, callback)
    local TwSvc  = game:GetService("TweenService")
    local Http   = game:GetService("HttpService")
    local SGui   = game:GetService("StarterGui")

    local FILE = (type(saveFile) == "string" and saveFile ~= "") and saveFile or "CrypticHub_Hotkey.dat"

    -- ── Colours (matches hub theme) ───────────────────────────────────
    local ACCENT   = Color3.fromRGB(0, 255, 150)
    local ACCENT2  = Color3.fromRGB(0, 150, 255)
    local CARD     = Color3.fromRGB(16, 16, 20)
    local DEEP     = Color3.fromRGB(12, 13, 18)
    local STROKE   = Color3.fromRGB(55, 60, 80)
    local TEXT     = Color3.fromRGB(210, 210, 225)
    local DIM      = Color3.fromRGB(90, 95, 115)
    local ON_CLR   = ACCENT
    local OFF_CLR  = Color3.fromRGB(45, 45, 55)

    local function tw(obj, props, t)
        TwSvc:Create(obj, TweenInfo.new(t or 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
    end

    -- ── Load persisted state ──────────────────────────────────────────
    local isActive = false
    local hotKey   = ""

    pcall(function()
        if isfile and isfile(FILE) then
            local d = Http:JSONDecode(readfile(FILE))
            if type(d) == "table" then
                isActive = d.enabled == true
                hotKey   = type(d.key) == "string" and d.key or ""
            end
        end
    end)

    local function persist()
        pcall(function()
            if writefile then
                writefile(FILE, Http:JSONEncode({ enabled = isActive, key = hotKey }))
            end
        end)
    end

    -- ── Card (collapsed = 52px, expanded = 88px) ─────────────────────
    TabOps.Order = TabOps.Order + 1

    local COLLAPSED_H = 52
    local EXPANDED_H  = 88

    local Card = Instance.new("Frame", TabOps.Page)
    Card.Name                  = "HotkeyToggle_" .. label
    Card.LayoutOrder           = TabOps.Order
    Card.Size                  = UDim2.new(0.98, 0, 0, COLLAPSED_H)
    Card.BackgroundColor3      = CARD
    Card.BackgroundTransparency = 0.1
    Card.BorderSizePixel       = 0
    Card.ClipsDescendants      = true
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 10)

    local Stroke = Instance.new("UIStroke", Card)
    Stroke.Thickness    = 1.2
    Stroke.Transparency = isActive and 0.1 or 0.55
    local SG = Instance.new("UIGradient", Stroke)
    SG.Color    = ColorSequence.new{
        ColorSequenceKeypoint.new(0, ACCENT),
        ColorSequenceKeypoint.new(1, ACCENT2),
    }
    SG.Rotation = 45

    -- ── Row 1: icon · label · key chip · toggle ───────────────────────
    local IconLbl = Instance.new("TextLabel", Card)
    IconLbl.Position               = UDim2.new(0, 10, 0, 9)
    IconLbl.Size                   = UDim2.new(0, 18, 0, 18)
    IconLbl.BackgroundTransparency = 1
    IconLbl.Text                   = "⌨️"
    IconLbl.TextSize               = 13
    IconLbl.Font                   = Enum.Font.GothamBold

    local NameLbl = Instance.new("TextLabel", Card)
    NameLbl.Position               = UDim2.new(0, 32, 0, 9)
    NameLbl.Size                   = UDim2.new(0.42, 0, 0, 18)
    NameLbl.BackgroundTransparency = 1
    NameLbl.Text                   = label
    NameLbl.TextColor3             = TEXT
    NameLbl.Font                   = Enum.Font.GothamSemibold
    NameLbl.TextSize               = 11
    NameLbl.TextXAlignment         = Enum.TextXAlignment.Left

    -- Key chip (shows current key; tap to edit)
    local KeyChip = Instance.new("TextButton", Card)
    KeyChip.AnchorPoint            = Vector2.new(1, 0)
    KeyChip.Position               = UDim2.new(1, -62, 0, 8)
    KeyChip.Size                   = UDim2.new(0, 46, 0, 22)
    KeyChip.Text                   = hotKey ~= "" and hotKey or "---"
    KeyChip.BackgroundColor3       = DEEP
    KeyChip.TextColor3             = hotKey ~= "" and ACCENT or DIM
    KeyChip.Font                   = Enum.Font.GothamBold
    KeyChip.TextSize               = 11
    KeyChip.AutoButtonColor        = false
    KeyChip.BorderSizePixel        = 0
    Instance.new("UICorner", KeyChip).CornerRadius = UDim.new(0, 7)
    local KS = Instance.new("UIStroke", KeyChip)
    KS.Thickness    = 1
    KS.Color        = STROKE
    KS.Transparency = 0.35

    -- Toggle track + knob
    local Track = Instance.new("Frame", Card)
    Track.AnchorPoint     = Vector2.new(1, 0)
    Track.Position        = UDim2.new(1, -10, 0, 8)
    Track.Size            = UDim2.new(0, 44, 0, 22)
    Track.BackgroundColor3 = isActive and ON_CLR or OFF_CLR
    Track.BorderSizePixel = 0
    Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

    local Knob = Instance.new("Frame", Track)
    Knob.Size             = UDim2.new(0, 16, 0, 16)
    Knob.Position         = isActive and UDim2.new(0, 25, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    Knob.BackgroundColor3 = isActive and Color3.new(1,1,1) or Color3.fromRGB(200,200,215)
    Knob.BorderSizePixel  = 0
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

    -- Invisible button covering ONLY the toggle track (no overlap with KeyChip)
    -- Track spans from right edge: 10px→54px. Button is slightly larger for tap comfort.
    local ToggleBtn = Instance.new("TextButton", Card)
    ToggleBtn.AnchorPoint          = Vector2.new(1, 0)
    ToggleBtn.Position             = UDim2.new(1, -10, 0, 4)   -- right edge matches Track's right edge
    ToggleBtn.Size                 = UDim2.new(0, 50, 0, 30)   -- 50px wide → fully covers Track (44px) + 6px padding
    ToggleBtn.BackgroundTransparency = 1
    ToggleBtn.Text                 = ""
    ToggleBtn.AutoButtonColor      = false
    ToggleBtn.ZIndex               = 3

    -- Hint below first row
    local HintLbl = Instance.new("TextLabel", Card)
    HintLbl.Position               = UDim2.new(0, 32, 0, 30)
    HintLbl.Size                   = UDim2.new(1, -40, 0, 14)
    HintLbl.BackgroundTransparency = 1
    HintLbl.Text                   = hotKey ~= "" and ("Key: " .. hotKey .. " — tap to change") or "Tap [---] to set a key"
    HintLbl.TextColor3             = DIM
    HintLbl.Font                   = Enum.Font.Gotham
    HintLbl.TextSize               = 9
    HintLbl.TextXAlignment         = Enum.TextXAlignment.Left

    -- ── Row 2: input (hidden until key chip tapped) ───────────────────
    local InputRow = Instance.new("Frame", Card)
    InputRow.Position               = UDim2.new(0, 10, 0, COLLAPSED_H + 2)
    InputRow.Size                   = UDim2.new(1, -20, 0, 30)
    InputRow.BackgroundTransparency = 1

    local TB = Instance.new("TextBox", InputRow)
    TB.Size              = UDim2.new(1, -44, 1, 0)
    TB.BackgroundColor3  = DEEP
    TB.TextColor3        = ACCENT
    TB.PlaceholderText   = "e.g.  H  ·  F5  ·  Insert"
    TB.PlaceholderColor3 = DIM
    TB.Text              = hotKey
    TB.Font              = Enum.Font.GothamSemibold
    TB.TextSize          = 11
    TB.ClearTextOnFocus  = false
    TB.BorderSizePixel   = 0
    Instance.new("UICorner", TB).CornerRadius = UDim.new(0, 7)
    local TBS = Instance.new("UIStroke", TB)
    TBS.Thickness = 1; TBS.Color = STROKE; TBS.Transparency = 0.35

    local OkBtn = Instance.new("TextButton", InputRow)
    OkBtn.Position          = UDim2.new(1, -40, 0, 0)
    OkBtn.Size              = UDim2.new(0, 38, 1, 0)
    OkBtn.Text              = "✓"
    OkBtn.BackgroundColor3  = ACCENT
    OkBtn.TextColor3        = CARD
    OkBtn.Font              = Enum.Font.GothamBlack
    OkBtn.TextSize          = 15
    OkBtn.AutoButtonColor   = false
    OkBtn.BorderSizePixel   = 0
    Instance.new("UICorner", OkBtn).CornerRadius = UDim.new(0, 7)

    -- ── Toggle logic ──────────────────────────────────────────────────
    local function refreshToggleVisual()
        tw(Track, { BackgroundColor3 = isActive and ON_CLR or OFF_CLR })
        tw(Knob,  { Position = isActive and UDim2.new(0, 25, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
                    BackgroundColor3 = isActive and Color3.new(1,1,1) or Color3.fromRGB(200,200,215) })
        tw(Stroke, { Transparency = isActive and 0.1 or 0.55 })
    end

    ToggleBtn.MouseButton1Click:Connect(function()
        isActive = not isActive
        refreshToggleVisual()
        persist()
        pcall(callback, isActive, hotKey)
    end)

    -- ── Key chip: expand / collapse ───────────────────────────────────
    local expanded = false

    local function setExpanded(v)
        expanded = v
        local targetH = v and EXPANDED_H or COLLAPSED_H
        tw(Card,     { Size = UDim2.new(0.98, 0, 0, targetH) }, 0.2)
        tw(InputRow, { Position = UDim2.new(0, 10, 0, COLLAPSED_H + 2) }, 0.2)
        if v then TB:CaptureFocus() end
        tw(KS, { Color = v and ACCENT or STROKE, Transparency = v and 0 or 0.35 })
    end

    KeyChip.MouseButton1Click:Connect(function()
        setExpanded(not expanded)
    end)

    -- ── Apply entered key ─────────────────────────────────────────────
    local function applyKey()
        setExpanded(false)
        local raw = TB.Text:gsub("%s+", "")
        if raw == "" then
            hotKey = ""
            KeyChip.Text       = "---"
            KeyChip.TextColor3 = DIM
            HintLbl.Text       = "Tap [---] to set a key"
            persist()
            pcall(callback, isActive, hotKey)
            return
        end
        -- resolve: try as-is, Title-case, UPPER
        local resolved
        for _, try in ipairs({ raw, raw:sub(1,1):upper()..raw:sub(2):lower(), raw:upper() }) do
            if Enum.KeyCode[try] then resolved = try break end
        end
        if not resolved then
            pcall(function()
                SGui:SetCore("SendNotification", {
                    Title = "Quick Key",
                    Text  = "\"" .. raw .. "\" is not a valid key",
                    Duration = 2,
                })
            end)
            return
        end
        hotKey             = resolved
        TB.Text            = resolved
        KeyChip.Text       = resolved
        KeyChip.TextColor3 = ACCENT
        HintLbl.Text       = "Key: " .. resolved .. " — tap to change"
        persist()
        pcall(callback, isActive, hotKey)
    end

    OkBtn.MouseButton1Click:Connect(applyKey)
    TB.FocusLost:Connect(function(enter) if enter then applyKey() end end)

    -- Hover effects
    OkBtn.MouseEnter:Connect(function() tw(OkBtn, { BackgroundColor3 = Color3.fromRGB(0, 220, 130) }) end)
    OkBtn.MouseLeave:Connect(function() tw(OkBtn, { BackgroundColor3 = ACCENT }) end)
    KeyChip.MouseEnter:Connect(function() tw(KS, { Color = ACCENT, Transparency = 0.1 }) end)
    KeyChip.MouseLeave:Connect(function()
        if not expanded then tw(KS, { Color = STROKE, Transparency = 0.35 }) end
    end)

    -- ── Restore on load ───────────────────────────────────────────────
    if isActive then
        task.spawn(function()
            task.wait(1.5)
            pcall(callback, isActive, hotKey)
        end)
    end

    return {
        GetState   = function() return isActive, hotKey end,
        SetActive  = function(v) isActive = v; refreshToggleVisual(); persist() end,
    }
end
