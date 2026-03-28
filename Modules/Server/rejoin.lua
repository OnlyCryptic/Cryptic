-- [[ Cryptic Hub - Server Actions V2 ]]

return function(Tab, UI)
    local TeleportService = game:GetService("TeleportService")
    local HttpService     = game:GetService("HttpService")
    local StarterGui      = game:GetService("StarterGui")
    local TweenService    = game:GetService("TweenService")
    local player          = game.Players.LocalPlayer

    local PAGE    = Tab.Page
    local ACCENT  = Color3.fromRGB(0, 255, 150)
    local ACCENT2 = Color3.fromRGB(0, 150, 255)

    local function Tween(obj, props, t)
        TweenService:Create(obj, TweenInfo.new(t or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
    end

    local function Notify(title, text)
        pcall(function()
            StarterGui:SetCore("SendNotification", { Title = title, Text = text, Duration = 4 })
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

    -- دالة بناء زر الإجراء
    local function ActionBtn(icon, title, sub, iconColor, callback)
        Tab.Order = Tab.Order + 1
        local Btn = Instance.new("TextButton", PAGE)
        Btn.LayoutOrder = Tab.Order
        Btn.Size = UDim2.new(0.98, 0, 0, 54)
        Btn.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
        Btn.BackgroundTransparency = 0.1
        Btn.Text = ""
        Btn.AutoButtonColor = false
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 10)
        GradStroke(Btn)

        local IconBg = Instance.new("Frame", Btn)
        IconBg.Size = UDim2.new(0, 38, 0, 38)
        IconBg.Position = UDim2.new(0, 10, 0.5, -19)
        IconBg.BackgroundColor3 = iconColor
        IconBg.BackgroundTransparency = 0.75
        Instance.new("UICorner", IconBg).CornerRadius = UDim.new(0, 8)

        local IconLbl = Instance.new("TextLabel", IconBg)
        IconLbl.Size = UDim2.new(1, 0, 1, 0)
        IconLbl.BackgroundTransparency = 1
        IconLbl.Text = icon
        IconLbl.TextSize = 20
        IconLbl.Font = Enum.Font.GothamBold

        local TitleLbl = Instance.new("TextLabel", Btn)
        TitleLbl.Size = UDim2.new(1, -70, 0, 22)
        TitleLbl.Position = UDim2.new(0, 58, 0, 7)
        TitleLbl.BackgroundTransparency = 1
        TitleLbl.Text = title
        TitleLbl.TextColor3 = Color3.new(1, 1, 1)
        TitleLbl.Font = Enum.Font.GothamBold
        TitleLbl.TextSize = 12
        TitleLbl.TextXAlignment = Enum.TextXAlignment.Left

        local SubLbl = Instance.new("TextLabel", Btn)
        SubLbl.Size = UDim2.new(1, -70, 0, 16)
        SubLbl.Position = UDim2.new(0, 58, 0, 28)
        SubLbl.BackgroundTransparency = 1
        SubLbl.Text = sub
        SubLbl.TextColor3 = Color3.fromRGB(110, 110, 130)
        SubLbl.Font = Enum.Font.Gotham
        SubLbl.TextSize = 10
        SubLbl.TextXAlignment = Enum.TextXAlignment.Left

        local Arrow = Instance.new("TextLabel", Btn)
        Arrow.Size = UDim2.new(0, 22, 0, 22)
        Arrow.Position = UDim2.new(1, -28, 0.5, -11)
        Arrow.BackgroundTransparency = 1
        Arrow.Text = "›"
        Arrow.TextColor3 = Color3.fromRGB(80, 80, 100)
        Arrow.Font = Enum.Font.GothamBlack
        Arrow.TextSize = 20

        local busy = false
        Btn.MouseEnter:Connect(function()
            if not busy then
                Tween(Btn, {BackgroundTransparency = 0.7}, 0.15)
                Tween(Arrow, {TextColor3 = ACCENT}, 0.15)
            end
        end)
        Btn.MouseLeave:Connect(function()
            Tween(Btn, {BackgroundTransparency = 0.1}, 0.15)
            Tween(Arrow, {TextColor3 = Color3.fromRGB(80, 80, 100)}, 0.15)
        end)
        Btn.MouseButton1Click:Connect(function()
            if busy then return end
            busy = true
            Tween(Btn, {BackgroundTransparency = 0.5}, 0.08)
            task.wait(0.12)
            Tween(Btn, {BackgroundTransparency = 0.1}, 0.15)
            task.spawn(function()
                callback()
                task.wait(3)
                busy = false
            end)
        end)
    end

    -- ============================================================
    -- 1. إعادة الدخول
    -- ============================================================
    ActionBtn("🔄", "Rejoin / إعادة دخول", "ادخل نفس السيرفر من جديد / Re-enter the same server", Color3.fromRGB(0, 180, 255), function()
        Notify("Cryptic Hub", "⏳ جاري إعادة الاتصال... / Reconnecting...")
        task.wait(0.8)
        pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
        end)
    end)

    -- ============================================================
    -- 2. تغيير السيرفر
    -- ============================================================
    ActionBtn("🌐", "Server Hop / تغيير السيرفر", "انتقل لسيرفر عشوائي / Jump to a random server", Color3.fromRGB(150, 80, 255), function()
        Notify("Cryptic Hub", "🔍 جاري البحث عن سيرفر... / Searching for a server...")

        local validServers = {}
        local ok = pcall(function()
            local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"
            local raw = ""
            local HttpReq = (request or http_request or (syn and syn.request))
            if HttpReq then
                local res = HttpReq({ Url = url, Method = "GET" })
                if res and res.Body then raw = res.Body end
            else
                raw = game:HttpGet(url)
            end
            if raw ~= "" then
                local data = HttpService:JSONDecode(raw)
                if data and data.data then
                    for _, srv in ipairs(data.data) do
                        if type(srv) == "table" and srv.id ~= game.JobId
                            and tonumber(srv.playing) and tonumber(srv.maxPlayers)
                            and srv.playing < (srv.maxPlayers - 1) then
                            table.insert(validServers, srv.id)
                        end
                    end
                end
            end
        end)

        if ok and #validServers > 0 then
            local pick = validServers[math.random(1, #validServers)]
            Notify("Cryptic Hub", "🚀 وجدنا سيرفر! / Found one! Teleporting...")
            task.wait(0.5)
            pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, pick, player) end)
        elseif ok then
            Notify("Cryptic Hub", "⚠️ ما في سيرفرات متاحة / No available servers found!")
        else
            Notify("Cryptic Hub", "❌ فشل البحث / Search failed — executor may not support this")
        end
    end)
end
