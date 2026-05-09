-- [[ Cryptic Hub - Player List ]]

local i18n = getgenv().CrypticI18n
local T = (i18n and i18n.T) or function(k) return k end

return function(Tab, UI)
    local Players     = game:GetService("Players")
    local StarterGui  = game:GetService("StarterGui")
    local TweenService= game:GetService("TweenService")
    local lp          = Players.LocalPlayer

    local PAGE    = Tab.Page
    local ACCENT  = Color3.fromRGB(0, 255, 150)
    local ACCENT2 = Color3.fromRGB(0, 150, 255)

    local CARD_H    = 56
    local GAP       = 4
    local isOpen    = false
    local playerCards = {}

    local function Tween(obj, props, t)
        TweenService:Create(obj, TweenInfo.new(t or 0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
    end

    local function Notify(text)
        pcall(function()
            StarterGui:SetCore("SendNotification", { Title = "Cryptic Hub", Text = text, Duration = 3 })
        end)
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
    end

    Tab.Order = Tab.Order + 1
    local HeaderBtn = Instance.new("TextButton", PAGE)
    HeaderBtn.LayoutOrder = Tab.Order
    HeaderBtn.Size = UDim2.new(0.98, 0, 0, 40)
    HeaderBtn.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
    HeaderBtn.BackgroundTransparency = 0.1
    HeaderBtn.Text = ""
    HeaderBtn.AutoButtonColor = false
    Instance.new("UICorner", HeaderBtn).CornerRadius = UDim.new(0, 10)
    GradStroke(HeaderBtn)

    local HIcon = Instance.new("TextLabel", HeaderBtn)
    HIcon.Size = UDim2.new(0, 28, 1, 0)
    HIcon.Position = UDim2.new(0, 10, 0, 0)
    HIcon.BackgroundTransparency = 1
    HIcon.Text = "👥"
    HIcon.TextSize = 16
    HIcon.Font = Enum.Font.GothamBold

    local HTitleLbl = Instance.new("TextLabel", HeaderBtn)
    HTitleLbl.Size = UDim2.new(0.55, 0, 1, 0)
    HTitleLbl.Position = UDim2.new(0, 42, 0, 0)
    HTitleLbl.BackgroundTransparency = 1
    HTitleLbl.Text = T("server.players.title")
    HTitleLbl.TextColor3 = Color3.fromRGB(200, 200, 215)
    HTitleLbl.Font = Enum.Font.GothamBold
    HTitleLbl.TextSize = 11
    HTitleLbl.TextXAlignment = Enum.TextXAlignment.Left

    local CountLbl = Instance.new("TextLabel", HeaderBtn)
    CountLbl.Size = UDim2.new(0.25, 0, 1, 0)
    CountLbl.Position = UDim2.new(0.65, 0, 0, 0)
    CountLbl.BackgroundTransparency = 1
    CountLbl.TextColor3 = ACCENT
    CountLbl.Font = Enum.Font.GothamBold
    CountLbl.TextSize = 10
    CountLbl.TextXAlignment = Enum.TextXAlignment.Right

    local ArrowLbl = Instance.new("TextLabel", HeaderBtn)
    ArrowLbl.Size = UDim2.new(0, 22, 1, 0)
    ArrowLbl.Position = UDim2.new(1, -26, 0, 0)
    ArrowLbl.BackgroundTransparency = 1
    ArrowLbl.Text = "›"
    ArrowLbl.TextColor3 = Color3.fromRGB(80, 80, 100)
    ArrowLbl.Font = Enum.Font.GothamBlack
    ArrowLbl.TextSize = 20

    Tab.Order = Tab.Order + 1
    local Container = Instance.new("Frame", PAGE)
    Container.LayoutOrder = Tab.Order
    Container.Size = UDim2.new(0.98, 0, 0, 0)
    Container.BackgroundTransparency = 1
    Container.ClipsDescendants = true

    local ListLayout = Instance.new("UIListLayout", Container)
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Padding = UDim.new(0, GAP)
    ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local cardOrder = 0

    local function buildCard(player)
        if player == lp then return end

        cardOrder = cardOrder + 1
        local Card = Instance.new("Frame", Container)
        Card.LayoutOrder = cardOrder
        Card.Size = UDim2.new(1, 0, 0, CARD_H)
        Card.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
        Card.BackgroundTransparency = 0.1
        Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 9)

        local Side = Instance.new("Frame", Card)
        Side.Size = UDim2.new(0, 3, 0.65, 0)
        Side.Position = UDim2.new(0, 0, 0.175, 0)
        Side.BackgroundColor3 = ACCENT2
        Side.BorderSizePixel = 0
        Instance.new("UICorner", Side).CornerRadius = UDim.new(1, 0)

        local AvatarBg = Instance.new("Frame", Card)
        AvatarBg.Size = UDim2.new(0, 36, 0, 36)
        AvatarBg.Position = UDim2.new(0, 10, 0.5, -18)
        AvatarBg.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
        AvatarBg.BorderSizePixel = 0
        Instance.new("UICorner", AvatarBg).CornerRadius = UDim.new(0, 7)

        local AvatarImg = Instance.new("ImageLabel", AvatarBg)
        AvatarImg.Size = UDim2.new(1, -4, 1, -4)
        AvatarImg.Position = UDim2.new(0, 2, 0, 2)
        AvatarImg.BackgroundTransparency = 1
        AvatarImg.Image = "rbxassetid://0"
        AvatarImg.ScaleType = Enum.ScaleType.Fit
        Instance.new("UICorner", AvatarImg).CornerRadius = UDim.new(0, 5)

        task.spawn(function()
            local ok, thumb = pcall(function()
                return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
            end)
            if ok and thumb then AvatarImg.Image = thumb end
        end)

        local NameLbl = Instance.new("TextLabel", Card)
        NameLbl.Size = UDim2.new(0.42, 0, 0, 20)
        NameLbl.Position = UDim2.new(0, 54, 0, 8)
        NameLbl.BackgroundTransparency = 1
        NameLbl.Text = player.DisplayName
        NameLbl.TextColor3 = Color3.new(1, 1, 1)
        NameLbl.Font = Enum.Font.GothamBold
        NameLbl.TextSize = 11
        NameLbl.TextXAlignment = Enum.TextXAlignment.Left
        NameLbl.TextTruncate = Enum.TextTruncate.AtEnd

        local UserLbl = Instance.new("TextLabel", Card)
        UserLbl.Size = UDim2.new(0.42, 0, 0, 14)
        UserLbl.Position = UDim2.new(0, 54, 0, 28)
        UserLbl.BackgroundTransparency = 1
        UserLbl.Text = "@" .. player.Name
        UserLbl.TextColor3 = Color3.fromRGB(80, 80, 105)
        UserLbl.Font = Enum.Font.Gotham
        UserLbl.TextSize = 9
        UserLbl.TextXAlignment = Enum.TextXAlignment.Left
        UserLbl.TextTruncate = Enum.TextTruncate.AtEnd

        local CopyBtn = Instance.new("TextButton", Card)
        CopyBtn.Size = UDim2.new(0, 58, 0, 26)
        CopyBtn.Position = UDim2.new(1, -124, 0.5, -13)
        CopyBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 44)
        CopyBtn.BackgroundTransparency = 0.2
        CopyBtn.Text = "📋 " .. T("server.players.copy")
        CopyBtn.TextColor3 = Color3.fromRGB(170, 170, 195)
        CopyBtn.Font = Enum.Font.GothamBold
        CopyBtn.TextSize = 8
        CopyBtn.AutoButtonColor = false
        Instance.new("UICorner", CopyBtn).CornerRadius = UDim.new(0, 6)

        CopyBtn.MouseEnter:Connect(function() Tween(CopyBtn, {BackgroundTransparency = 0.7}, 0.12) end)
        CopyBtn.MouseLeave:Connect(function() Tween(CopyBtn, {BackgroundTransparency = 0.2}, 0.12) end)
        CopyBtn.MouseButton1Click:Connect(function()
            pcall(function() setclipboard(player.Name) end)
            CopyBtn.Text = "✅"
            Notify(T("server.players.copied") .. ": @" .. player.Name)
            task.wait(1.5)
            CopyBtn.Text = "📋 " .. T("server.players.copy")
        end)

        local TpBtn = Instance.new("TextButton", Card)
        TpBtn.Size = UDim2.new(0, 58, 0, 26)
        TpBtn.Position = UDim2.new(1, -60, 0.5, -13)
        TpBtn.BackgroundColor3 = Color3.fromRGB(0, 70, 45)
        TpBtn.BackgroundTransparency = 0.2
        TpBtn.Text = "🚀 " .. T("server.players.tp")
        TpBtn.TextColor3 = ACCENT
        TpBtn.Font = Enum.Font.GothamBold
        TpBtn.TextSize = 8
        TpBtn.AutoButtonColor = false
        Instance.new("UICorner", TpBtn).CornerRadius = UDim.new(0, 6)

        TpBtn.MouseEnter:Connect(function() Tween(TpBtn, {BackgroundTransparency = 0.7}, 0.12) end)
        TpBtn.MouseLeave:Connect(function() Tween(TpBtn, {BackgroundTransparency = 0.2}, 0.12) end)
        TpBtn.MouseButton1Click:Connect(function()
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart")
                and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                lp.Character.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame + Vector3.new(2, 0, 0)
                Notify("🚀 " .. T("server.players.tp_to") .. ": " .. player.Name)
            else
                Notify("⚠️ " .. T("server.players.tp_fail"))
            end
        end)

        playerCards[player.UserId] = Card
    end

    local function refreshLayout()
        local count = 0
        for _ in pairs(playerCards) do count = count + 1 end
        CountLbl.Text = count .. " 🟢"

        if isOpen then
            local totalH = count * (CARD_H + GAP)
            Tween(Container, {Size = UDim2.new(0.98, 0, 0, totalH)}, 0.25)
        end
    end

    for _, p in ipairs(Players:GetPlayers()) do
        buildCard(p)
    end
    refreshLayout()

    Players.PlayerAdded:Connect(function(p)
        buildCard(p)
        refreshLayout()
    end)

    Players.PlayerRemoving:Connect(function(p)
        if playerCards[p.UserId] then
            playerCards[p.UserId]:Destroy()
            playerCards[p.UserId] = nil
            refreshLayout()
        end
    end)

    HeaderBtn.MouseEnter:Connect(function() Tween(HeaderBtn, {BackgroundTransparency = 0.6}, 0.15) end)
    HeaderBtn.MouseLeave:Connect(function() Tween(HeaderBtn, {BackgroundTransparency = 0.1}, 0.15) end)

    HeaderBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen

        local count = 0
        for _ in pairs(playerCards) do count = count + 1 end

        if isOpen then
            local totalH = count * (CARD_H + GAP)
            Tween(Container, {Size = UDim2.new(0.98, 0, 0, totalH)}, 0.28)
            Tween(ArrowLbl, {Rotation = 90}, 0.2)
            ArrowLbl.TextColor3 = ACCENT
        else
            Tween(Container, {Size = UDim2.new(0.98, 0, 0, 0)}, 0.22)
            Tween(ArrowLbl, {Rotation = 0}, 0.2)
            ArrowLbl.TextColor3 = Color3.fromRGB(80, 80, 100)
        end
    end)
end
