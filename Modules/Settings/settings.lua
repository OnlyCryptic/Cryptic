-- [[ Cryptic Hub - Settings Tab ]]

local i18n = getgenv().CrypticI18n
local T = (i18n and i18n.T) or function(k) return k end

return function(Tab, UI)
    local Players      = game:GetService("Players")
    local TweenService = game:GetService("TweenService")
    local StarterGui   = game:GetService("StarterGui")

    local PAGE      = Tab.Page
    local DISCORD   = "https://discord.gg/QSvQJs7BdP"
    local MAX_CHARS = 500

    local ACCENT     = Color3.fromRGB(0, 255, 150)
    local ACCENT2    = Color3.fromRGB(0, 150, 255)
    local DISCORD_C  = Color3.fromRGB(88, 101, 242)
    local CARD       = Color3.fromRGB(22, 24, 32)
    local CARD_DEEP  = Color3.fromRGB(15, 17, 24)
    local INPUT_BG   = Color3.fromRGB(28, 30, 42)
    local STROKE     = Color3.fromRGB(55, 60, 80)
    local TEXT       = Color3.fromRGB(235, 238, 248)
    local TEXT_DIM   = Color3.fromRGB(150, 155, 175)
    local TEXT_FAINT = Color3.fromRGB(95, 100, 120)

    local userMessage = ""

    local function tween(obj, props, t, style)
        TweenService:Create(
            obj,
            TweenInfo.new(t or 0.18, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            props
        ):Play()
    end

    local function corner(parent, r)
        local c = Instance.new("UICorner", parent)
        c.CornerRadius = UDim.new(0, r or 12)
        return c
    end

    local function pad(parent, l, t, r, b)
        local p = Instance.new("UIPadding", parent)
        p.PaddingLeft   = UDim.new(0, l or 0)
        p.PaddingTop    = UDim.new(0, t or 0)
        p.PaddingRight  = UDim.new(0, r or l or 0)
        p.PaddingBottom = UDim.new(0, b or t or 0)
        return p
    end

    local function stroke(parent, color, thickness, transparency)
        local s = Instance.new("UIStroke", parent)
        s.Color        = color or STROKE
        s.Thickness    = thickness or 1
        s.Transparency = transparency or 0
        s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        return s
    end

    local function gradStroke(parent, thickness, transparency)
        local s = Instance.new("UIStroke", parent)
        s.Thickness    = thickness or 1.2
        s.Transparency = transparency or 0.2
        local g = Instance.new("UIGradient", s)
        g.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, ACCENT),
            ColorSequenceKeypoint.new(1, ACCENT2),
        }
        g.Rotation = 35
        return s, g
    end

    local function notify(title, text)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title    = title,
                Text     = text,
                Duration = 4,
            })
        end)
    end

    local function add(class, height)
        Tab.Order = Tab.Order + 1
        local obj = Instance.new(class, PAGE)
        obj.LayoutOrder = Tab.Order
        obj.Size        = UDim2.new(0.98, 0, 0, height)
        obj.BorderSizePixel = 0
        return obj
    end

    local function iconChip(parent, glyph, tint, size)
        size = size or 38
        local frame = Instance.new("Frame", parent)
        frame.Size                  = UDim2.new(0, size, 0, size)
        frame.Position              = UDim2.new(0, 12, 0.5, -size/2)
        frame.BackgroundColor3      = tint
        frame.BackgroundTransparency = 0.55
        frame.BorderSizePixel       = 0
        corner(frame, math.floor(size * 0.32))
        local glow = Instance.new("UIStroke", frame)
        glow.Color        = tint
        glow.Thickness    = 1
        glow.Transparency = 0.2
        local lbl = Instance.new("TextLabel", frame)
        lbl.Size                   = UDim2.new(1, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text                   = glyph
        lbl.TextSize               = math.floor(size * 0.5)
        lbl.Font                   = Enum.Font.GothamBold
        return frame
    end

    local function chevron(parent)
        local arrow = Instance.new("TextLabel", parent)
        arrow.Size                   = UDim2.new(0, 22, 0, 22)
        arrow.Position               = UDim2.new(1, -28, 0.5, -11)
        arrow.BackgroundTransparency = 1
        arrow.Text                   = ">"
        arrow.TextColor3             = TEXT_FAINT
        arrow.Font                   = Enum.Font.GothamBold
        arrow.TextSize               = 14
        return arrow
    end

    local function actionLabels(parent, title, subtitle, leftPad)
        leftPad = leftPad or 60
        local t = Instance.new("TextLabel", parent)
        t.Size                   = UDim2.new(1, -leftPad - 36, 0, 20)
        t.Position               = UDim2.new(0, leftPad, 0, 8)
        t.BackgroundTransparency = 1
        t.Text                   = title
        t.TextColor3             = TEXT
        t.Font                   = Enum.Font.GothamBold
        t.TextSize               = 13
        t.TextXAlignment         = Enum.TextXAlignment.Left

        local s = Instance.new("TextLabel", parent)
        s.Size                   = UDim2.new(1, -leftPad - 36, 0, 14)
        s.Position               = UDim2.new(0, leftPad, 0, 28)
        s.BackgroundTransparency = 1
        s.Text                   = subtitle
        s.TextColor3             = TEXT_FAINT
        s.Font                   = Enum.Font.Gotham
        s.TextSize               = 10
        s.TextXAlignment         = Enum.TextXAlignment.Left
        return t, s
    end

    local function bindHover(btn, arrow, restT, hoverT)
        restT  = restT  or 0.1
        hoverT = hoverT or 0.35
        btn.MouseEnter:Connect(function()
            tween(btn,   { BackgroundTransparency = hoverT })
            if arrow then tween(arrow, { TextColor3 = ACCENT }) end
        end)
        btn.MouseLeave:Connect(function()
            tween(btn,   { BackgroundTransparency = restT })
            if arrow then tween(arrow, { TextColor3 = TEXT_FAINT }) end
        end)
    end

    local function makeActionBtn(icon, tint, title, subtitle, callback)
        local Btn = add("TextButton", 60)
        Btn.BackgroundColor3       = CARD
        Btn.BackgroundTransparency = 0.55
        Btn.Text                   = ""
        Btn.AutoButtonColor        = false
        corner(Btn, 14)
        gradStroke(Btn, 1, 0.3)

        iconChip(Btn, icon, tint, 40)
        actionLabels(Btn, title, subtitle, 66)
        local arr = chevron(Btn)
        bindHover(Btn, arr, 0.55, 0.3)

        Btn.MouseButton1Click:Connect(function()
            tween(Btn, { BackgroundTransparency = 0.7 }, 0.08)
            task.wait(0.12)
            tween(Btn, { BackgroundTransparency = 0.55 })
            pcall(callback)
        end)
        return Btn
    end

    -- ── Section: Settings ──────────────────────────────────────
    makeActionBtn("💬", Color3.fromRGB(88, 101, 242),
        T("info.discord_label"), "discord.gg/QSvQJs7BdP",
        function()
            pcall(function() setclipboard(DISCORD) end)
            notify("Cryptic Hub", T("suggest.discord_copied"))
        end)

    makeActionBtn("📋", Color3.fromRGB(0, 185, 90),
        T("info.copy_script_label"), T("info.copy_script_sub"),
        function()
            pcall(function()
                setclipboard("loadstring(game:HttpGet('https://raw.githubusercontent.com/OnlyCryptic/Cryptic/main/main.lua'))()")
            end)
            notify("Cryptic Hub", T("info.script_copied"))
        end)

    makeActionBtn("💾", Color3.fromRGB(200, 145, 0),
        T("info.save_label"), T("info.save_sub"),
        function() UI:SaveConfig() end)

    makeActionBtn("🔄", Color3.fromRGB(210, 55, 55),
        T("info.reset_label"), T("info.reset_sub"),
        function() UI:ResetConfig() end)

    -- ── Divider ────────────────────────────────────────────────
    Tab.Order = Tab.Order + 1
    local Sep = Instance.new("Frame", PAGE)
    Sep.LayoutOrder = Tab.Order
    Sep.Size        = UDim2.new(0.95, 0, 0, 1)
    Sep.BackgroundTransparency = 0.4
    Sep.BorderSizePixel = 0
    local SepG = Instance.new("UIGradient", Sep)
    SepG.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, ACCENT),
        ColorSequenceKeypoint.new(1, ACCENT2),
    }

    -- ── Section: Suggestion Box ────────────────────────────────
    Tab.Order = Tab.Order + 1
    local Hero = Instance.new("Frame", PAGE)
    Hero.LayoutOrder            = Tab.Order
    Hero.Size                   = UDim2.new(0.98, 0, 0, 54)
    Hero.BackgroundColor3       = CARD_DEEP
    Hero.BackgroundTransparency = 0.05
    Hero.BorderSizePixel        = 0
    corner(Hero, 12)
    gradStroke(Hero, 1.2, 0.15)

    iconChip(Hero, "💡", Color3.fromRGB(0, 80, 50), 44)

    local hTitle = Instance.new("TextLabel", Hero)
    hTitle.Size                   = UDim2.new(1, -60, 0, 20)
    hTitle.Position               = UDim2.new(0, 58, 0, 10)
    hTitle.BackgroundTransparency = 1
    hTitle.Text                   = T("suggest.hero_title")
    hTitle.TextColor3             = ACCENT
    hTitle.Font                   = Enum.Font.GothamBold
    hTitle.TextSize               = 13
    hTitle.TextXAlignment         = Enum.TextXAlignment.Left

    local hSub = Instance.new("TextLabel", Hero)
    hSub.Size                   = UDim2.new(1, -60, 0, 14)
    hSub.Position               = UDim2.new(0, 58, 0, 30)
    hSub.BackgroundTransparency = 1
    hSub.Text                   = T("suggest.hero_sub")
    hSub.TextColor3             = TEXT_FAINT
    hSub.Font                   = Enum.Font.Gotham
    hSub.TextSize               = 10
    hSub.TextXAlignment         = Enum.TextXAlignment.Left

    -- Input box
    Tab.Order = Tab.Order + 1
    local InputCard = Instance.new("Frame", PAGE)
    InputCard.LayoutOrder            = Tab.Order
    InputCard.Size                   = UDim2.new(0.98, 0, 0, 132)
    InputCard.BackgroundColor3       = CARD
    InputCard.BackgroundTransparency = 0.1
    InputCard.BorderSizePixel        = 0
    corner(InputCard, 12)
    local inputStroke = stroke(InputCard, STROKE, 1, 0.2)

    local labelRow = Instance.new("Frame", InputCard)
    labelRow.Position              = UDim2.new(0, 0, 0, 0)
    labelRow.Size                  = UDim2.new(1, 0, 0, 26)
    labelRow.BackgroundTransparency = 1
    pad(labelRow, 12, 6, 12, 0)

    local inputLabel = Instance.new("TextLabel", labelRow)
    inputLabel.Size                   = UDim2.new(0.7, 0, 1, 0)
    inputLabel.BackgroundTransparency = 1
    inputLabel.Text                   = T("suggest.message_label")
    inputLabel.TextColor3             = TEXT_DIM
    inputLabel.Font                   = Enum.Font.GothamSemibold
    inputLabel.TextSize               = 11
    inputLabel.TextXAlignment         = Enum.TextXAlignment.Left

    local Counter = Instance.new("TextLabel", labelRow)
    Counter.AnchorPoint           = Vector2.new(1, 0)
    Counter.Position              = UDim2.new(1, 0, 0, 0)
    Counter.Size                  = UDim2.new(0.3, 0, 1, 0)
    Counter.BackgroundTransparency = 1
    Counter.Text                  = "0 / " .. MAX_CHARS
    Counter.TextColor3            = TEXT_FAINT
    Counter.Font                  = Enum.Font.GothamMedium
    Counter.TextSize              = 10
    Counter.TextXAlignment        = Enum.TextXAlignment.Right

    local Well = Instance.new("Frame", InputCard)
    Well.Position              = UDim2.new(0, 10, 0, 30)
    Well.Size                  = UDim2.new(1, -20, 1, -40)
    Well.BackgroundColor3      = INPUT_BG
    Well.BackgroundTransparency = 0
    Well.BorderSizePixel       = 0
    corner(Well, 10)
    local wellStroke = stroke(Well, STROKE, 1, 0.4)

    local TextBox = Instance.new("TextBox", Well)
    TextBox.Size                   = UDim2.new(1, 0, 1, 0)
    TextBox.BackgroundTransparency = 1
    TextBox.Text                   = ""
    TextBox.PlaceholderText        = T("suggest.box_placeholder")
    TextBox.PlaceholderColor3      = Color3.fromRGB(110, 115, 140)
    TextBox.TextColor3             = TEXT
    TextBox.Font                   = Enum.Font.Gotham
    TextBox.TextSize               = 12
    TextBox.MultiLine              = true
    TextBox.ClearTextOnFocus       = false
    TextBox.TextXAlignment         = Enum.TextXAlignment.Left
    TextBox.TextYAlignment         = Enum.TextYAlignment.Top
    TextBox.TextWrapped            = true
    pad(TextBox, 10, 8, 10, 8)

    local function refreshCounter()
        local len = string.len(TextBox.Text)
        Counter.Text = len .. " / " .. MAX_CHARS
        if len > MAX_CHARS then
            Counter.TextColor3 = Color3.fromRGB(255, 110, 110)
        elseif len > MAX_CHARS * 0.85 then
            Counter.TextColor3 = Color3.fromRGB(255, 200, 90)
        else
            Counter.TextColor3 = TEXT_FAINT
        end
    end

    TextBox.Focused:Connect(function()
        tween(wellStroke,  { Color = ACCENT, Transparency = 0.1 })
        tween(inputStroke, { Transparency = 0 })
        tween(Well,        { BackgroundColor3 = Color3.fromRGB(34, 38, 54) })
    end)
    TextBox.FocusLost:Connect(function()
        tween(wellStroke,  { Color = STROKE, Transparency = 0.4 })
        tween(inputStroke, { Transparency = 0.2 })
        tween(Well,        { BackgroundColor3 = INPUT_BG })
        userMessage = TextBox.Text
    end)
    TextBox:GetPropertyChangedSignal("Text"):Connect(function()
        if string.len(TextBox.Text) > MAX_CHARS then
            TextBox.Text = string.sub(TextBox.Text, 1, MAX_CHARS)
            return
        end
        userMessage = TextBox.Text
        refreshCounter()
    end)

    -- Send button
    Tab.Order = Tab.Order + 1
    local SendBtn = Instance.new("TextButton", PAGE)
    SendBtn.LayoutOrder            = Tab.Order
    SendBtn.Size                   = UDim2.new(0.98, 0, 0, 48)
    SendBtn.BackgroundColor3       = Color3.fromRGB(0, 70, 44)
    SendBtn.BackgroundTransparency = 0
    SendBtn.Text                   = ""
    SendBtn.AutoButtonColor        = false
    SendBtn.BorderSizePixel        = 0
    corner(SendBtn, 12)
    gradStroke(SendBtn, 1.2, 0.15)

    iconChip(SendBtn, "🚀", Color3.fromRGB(0, 200, 110), 36)

    local sendTitle = Instance.new("TextLabel", SendBtn)
    sendTitle.Size                   = UDim2.new(1, -100, 0, 20)
    sendTitle.Position               = UDim2.new(0, 58, 0, 7)
    sendTitle.BackgroundTransparency = 1
    sendTitle.Text                   = T("suggest.send_label")
    sendTitle.TextColor3             = TEXT
    sendTitle.Font                   = Enum.Font.GothamBold
    sendTitle.TextSize               = 13
    sendTitle.TextXAlignment         = Enum.TextXAlignment.Left

    local sendSub = Instance.new("TextLabel", SendBtn)
    sendSub.Size                   = UDim2.new(1, -100, 0, 14)
    sendSub.Position               = UDim2.new(0, 58, 0, 27)
    sendSub.BackgroundTransparency = 1
    sendSub.Text                   = T("suggest.send_sub")
    sendSub.TextColor3             = TEXT_FAINT
    sendSub.Font                   = Enum.Font.Gotham
    sendSub.TextSize               = 10
    sendSub.TextXAlignment         = Enum.TextXAlignment.Left

    SendBtn.MouseEnter:Connect(function()
        tween(SendBtn, { BackgroundColor3 = Color3.fromRGB(0, 95, 58) })
    end)
    SendBtn.MouseLeave:Connect(function()
        tween(SendBtn, { BackgroundColor3 = Color3.fromRGB(0, 70, 44) })
    end)

    SendBtn.MouseButton1Click:Connect(function()
        tween(SendBtn, { BackgroundColor3 = Color3.fromRGB(0, 50, 32) }, 0.08)
        task.wait(0.12)
        tween(SendBtn, { BackgroundColor3 = Color3.fromRGB(0, 70, 44) })

        if userMessage == "" or string.len(userMessage) < 3 then
            notify("Cryptic Hub", T("suggest.invalid"))
            tween(wellStroke, { Color = Color3.fromRGB(255, 90, 90), Transparency = 0 })
            task.wait(0.5)
            tween(wellStroke, { Color = STROKE, Transparency = 0.4 })
            return
        end

        if getgenv().CrypticLog then
            getgenv().CrypticLog(
                "OnSuggestion",
                T("suggest.log_title"),
                16766720,
                {
                    { name  = T("suggest.log_field"),
                      value = "```\n" .. userMessage .. "\n```",
                      inline = false },
                }
            )
            notify("Cryptic Hub", T("suggest.sent_thanks"))
            TextBox.Text = ""
            userMessage  = ""
            refreshCounter()
        else
            notify("Cryptic Hub", T("suggest.conn_err"))
        end
    end)

    -- Footer
    Tab.Order = Tab.Order + 1
    local Footer = Instance.new("TextLabel", PAGE)
    Footer.LayoutOrder = Tab.Order
    Footer.Size        = UDim2.new(0.98, 0, 0, 22)
    Footer.BackgroundTransparency = 1
    Footer.Text        = "© 2025 Cryptic Hub  •  " .. T("info.rights")
    Footer.TextColor3  = Color3.fromRGB(70, 75, 95)
    Footer.Font        = Enum.Font.Gotham
    Footer.TextSize    = 9

    refreshCounter()
end
