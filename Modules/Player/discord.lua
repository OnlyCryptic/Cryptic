-- [[ Cryptic Hub - Discord Invite Popup ]]
-- تظهر مرة واحدة في الأسبوع بعد 20 ثانية من التحميل
-- Localized via i18n. الكي: player.discord.*

return function(Tab, UI)
    task.spawn(function()
        local i18n = getgenv().CrypticI18n
        local T    = (i18n and i18n.T) or function(k) return k end

        local Players          = game:GetService("Players")
        local TweenService     = game:GetService("TweenService")
        local UserInputService = game:GetService("UserInputService")
        local StarterGui       = game:GetService("StarterGui")
        local lp               = Players.LocalPlayer

        local DISCORD_LINK   = "https://discord.gg/QSvQJs7BdP"
        local SHOW_INTERVAL  = 7 * 24 * 60 * 60 -- one week
        local DELAY_BEFORE   = 20
        local COUNTDOWN_SECS = 20
        local STATE_FILE     = "CrypticHub_DiscordPopup1.txt"

        local hasFS = (typeof(writefile) == "function")
                  and (typeof(readfile)  == "function")
                  and (typeof(isfile)    == "function")

        local function getLastShown()
            if not hasFS then return 0 end
            local ok, res = pcall(function()
                if isfile(STATE_FILE) then
                    return tonumber(readfile(STATE_FILE)) or 0
                end
                return 0
            end)
            return ok and res or 0
        end

        local function markShown()
            if not hasFS then return end
            pcall(function() writefile(STATE_FILE, tostring(os.time())) end)
        end

        if os.time() - getLastShown() < SHOW_INTERVAL then
            return
        end

        task.wait(DELAY_BEFORE)
        markShown()

        local gui = Instance.new("ScreenGui")
        gui.Name              = "CrypticDiscordInvite"
        gui.ResetOnSpawn      = false
        gui.IgnoreGuiInset    = true
        gui.ZIndexBehavior    = Enum.ZIndexBehavior.Sibling
        gui.DisplayOrder      = 999999

        local parented = false
        pcall(function()
            if typeof(gethui) == "function" then
                gui.Parent = gethui(); parented = true
            elseif syn and syn.protect_gui then
                syn.protect_gui(gui); gui.Parent = game:GetService("CoreGui"); parented = true
            else
                gui.Parent = game:GetService("CoreGui"); parented = true
            end
        end)
        if not parented then
            gui.Parent = lp:WaitForChild("PlayerGui")
        end

        local card = Instance.new("Frame")
        card.Name                 = "Card"
        card.AnchorPoint          = Vector2.new(1, 1)
        card.Position             = UDim2.new(1, -18, 1, -18)
        card.Size                 = UDim2.fromOffset(0, 0)
        card.BackgroundColor3     = Color3.fromRGB(18, 20, 28)
        card.BackgroundTransparency = 0.2
        card.BorderSizePixel      = 0
        card.ClipsDescendants     = true
        card.ZIndex               = 2
        card.Parent               = gui

        local cardCorner = Instance.new("UICorner", card)
        cardCorner.CornerRadius = UDim.new(0, 14)

        local cardStroke = Instance.new("UIStroke", card)
        cardStroke.Color        = Color3.fromRGB(88, 101, 242)
        cardStroke.Thickness    = 1.4
        cardStroke.Transparency = 0.25

        local accent = Instance.new("Frame", card)
        accent.Size              = UDim2.new(1, 0, 0, 4)
        accent.BackgroundColor3  = Color3.fromRGB(88, 101, 242)
        accent.BorderSizePixel   = 0
        accent.ZIndex            = 3
        local accentCorner = Instance.new("UICorner", accent)
        accentCorner.CornerRadius = UDim.new(0, 4)

        local title = Instance.new("TextLabel", card)
        title.BackgroundTransparency = 1
        title.Position           = UDim2.new(0, 12, 0, 10)
        title.Size               = UDim2.new(1, -50, 0, 18)
        title.Font               = Enum.Font.GothamBold
        title.TextSize           = 13
        title.TextXAlignment     = Enum.TextXAlignment.Left
        title.TextColor3         = Color3.fromRGB(255, 255, 255)
        title.Text               = T("player.discord.title")
        title.ZIndex             = 3

        local body = Instance.new("TextLabel", card)
        body.BackgroundTransparency = 1
        body.Position            = UDim2.new(0, 12, 0, 30)
        body.Size                = UDim2.new(1, -24, 0, 32)
        body.Font                = Enum.Font.Gotham
        body.TextSize            = 11
        body.TextWrapped         = true
        body.TextXAlignment      = Enum.TextXAlignment.Left
        body.TextYAlignment      = Enum.TextYAlignment.Top
        body.TextColor3          = Color3.fromRGB(210, 214, 225)
        body.Text                = T("player.discord.body")
        body.ZIndex              = 3

        local countdown = Instance.new("TextLabel", card)
        countdown.BackgroundTransparency = 1
        countdown.Position       = UDim2.new(1, -38, 0, 10)
        countdown.Size           = UDim2.new(0, 28, 0, 18)
        countdown.Font           = Enum.Font.GothamBold
        countdown.TextSize       = 12
        countdown.TextXAlignment = Enum.TextXAlignment.Right
        countdown.TextColor3     = Color3.fromRGB(160, 165, 180)
        countdown.Text           = tostring(COUNTDOWN_SECS)
        countdown.ZIndex         = 3

        local btnRow = Instance.new("Frame", card)
        btnRow.BackgroundTransparency = 1
        btnRow.Position          = UDim2.new(0, 10, 1, -34)
        btnRow.Size              = UDim2.new(1, -20, 0, 26)
        btnRow.ZIndex            = 3

        local layout = Instance.new("UIListLayout", btnRow)
        layout.FillDirection      = Enum.FillDirection.Horizontal
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        layout.VerticalAlignment  = Enum.VerticalAlignment.Center
        layout.Padding            = UDim.new(0, 6)
        layout.SortOrder          = Enum.SortOrder.LayoutOrder

        local function makeButton(text, primary, order)
            local b = Instance.new("TextButton", btnRow)
            b.AutoButtonColor      = false
            b.BorderSizePixel      = 0
            b.Size                 = UDim2.new(0, primary and 110 or 72, 1, 0)
            b.Font                 = Enum.Font.GothamBold
            b.TextSize             = 11
            b.Text                 = text
            b.LayoutOrder          = order
            b.ZIndex               = 4
            b.BackgroundColor3     = primary and Color3.fromRGB(88, 101, 242) or Color3.fromRGB(48, 52, 64)
            b.BackgroundTransparency = primary and 0.05 or 0.25
            b.TextColor3           = Color3.fromRGB(255, 255, 255)
            local c = Instance.new("UICorner", b); c.CornerRadius = UDim.new(0, 6)
            local s = Instance.new("UIStroke", b)
            s.Color        = primary and Color3.fromRGB(120, 130, 255) or Color3.fromRGB(95, 100, 115)
            s.Thickness    = 1
            s.Transparency = 0.45
            return b
        end

        local closeBtn = makeButton(T("player.discord.close"), false, 1)
        local joinBtn  = makeButton(T("player.discord.copy"),  true,  2)

        local TARGET_SIZE = UDim2.fromOffset(280, 110)
        TweenService:Create(card, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Size = TARGET_SIZE}):Play()

        local closed = false
        local function closeUI()
            if closed then return end
            closed = true
            TweenService:Create(card, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                {Size = UDim2.fromOffset(0, 0)}):Play()
            task.wait(0.25)
            if gui then gui:Destroy() end
        end

        local function notify(t, x)
            pcall(function()
                StarterGui:SetCore("SendNotification", {Title = t, Text = x, Duration = 4})
            end)
        end

        closeBtn.MouseButton1Click:Connect(closeUI)
        joinBtn.MouseButton1Click:Connect(function()
            local copied = false
            pcall(function()
                if typeof(setclipboard) == "function" then
                    setclipboard(DISCORD_LINK); copied = true
                elseif typeof(toclipboard) == "function" then
                    toclipboard(DISCORD_LINK); copied = true
                elseif syn and syn.write_clipboard then
                    syn.write_clipboard(DISCORD_LINK); copied = true
                end
            end)
            if copied then
                notify("Cryptic Hub", T("player.discord.copied"))
            else
                notify("Cryptic Hub", DISCORD_LINK)
            end
            closeUI()
        end)

        local function hover(btn, baseColor, hoverColor)
            btn.MouseEnter:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = hoverColor}):Play()
            end)
            btn.MouseLeave:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = baseColor}):Play()
            end)
        end
        hover(joinBtn,  Color3.fromRGB(88, 101, 242), Color3.fromRGB(112, 124, 255))
        hover(closeBtn, Color3.fromRGB(48, 52, 64),   Color3.fromRGB(68, 73, 88))

        do
            local dragging, dragStart, startPos
            local function update(input)
                local delta = input.Position - dragStart
                local goal  = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
                TweenService:Create(card, TweenInfo.new(0.10, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {Position = goal}):Play()
            end
            card.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                    dragging  = true
                    dragStart = input.Position
                    startPos  = card.Position
                    input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then
                            dragging = false
                        end
                    end)
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
                              or input.UserInputType == Enum.UserInputType.Touch) then
                    update(input)
                end
            end)
        end

        task.spawn(function()
            for i = COUNTDOWN_SECS, 1, -1 do
                if closed then return end
                countdown.Text = tostring(i)
                task.wait(1)
            end
            if not closed then closeUI() end
        end)
    end)

    return false
end
