-- [[ Cryptic Hub - Element: MapCard ]]
-- بطاقة الماب الاحترافية مع الصورة وزر تشغيل السكربت

return function(TabOps, mapData)
    local HttpService = game:GetService("HttpService")
    local TweenService = game:GetService("TweenService")
    local StarterGui = game:GetService("StarterGui")

    local function Tween(inst, props, t)
        TweenService:Create(inst, TweenInfo.new(t or 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
    end

    -- ── الحاوية الرئيسية ──────────────────────────────────────────
    TabOps.Order = TabOps.Order + 1
    local Card = Instance.new("Frame", TabOps.Page)
    Card.LayoutOrder = TabOps.Order
    Card.Size = UDim2.new(0.97, 0, 0, 200)
    Card.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
    Card.BorderSizePixel = 0
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 10)

    local CardStroke = Instance.new("UIStroke", Card)
    CardStroke.Thickness = 1.5
    CardStroke.Transparency = 0.15
    local CardGradient = Instance.new("UIGradient", CardStroke)
    CardGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 200, 120)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 120, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 200, 120))
    }

    -- ── صورة الماب ───────────────────────────────────────────────
    local ThumbFrame = Instance.new("Frame", Card)
    ThumbFrame.Size = UDim2.new(1, 0, 0, 120)
    ThumbFrame.Position = UDim2.new(0, 0, 0, 0)
    ThumbFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
    ThumbFrame.BorderSizePixel = 0
    Instance.new("UICorner", ThumbFrame).CornerRadius = UDim.new(0, 10)
    ThumbFrame.ClipsDescendants = true

    -- تدرج فوق الصورة من الأسفل
    local ThumbOverlay = Instance.new("Frame", ThumbFrame)
    ThumbOverlay.Size = UDim2.new(1, 0, 0.7, 0)
    ThumbOverlay.Position = UDim2.new(0, 0, 0.3, 0)
    ThumbOverlay.BorderSizePixel = 0
    ThumbOverlay.BackgroundTransparency = 1
    local OverlayGrad = Instance.new("UIGradient", ThumbOverlay)
    OverlayGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(14, 14, 18)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(14, 14, 18))
    }
    OverlayGrad.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(1, 0)
    }
    OverlayGrad.Rotation = 90

    local ThumbImg = Instance.new("ImageLabel", ThumbFrame)
    ThumbImg.Size = UDim2.new(1, 0, 1, 0)
    ThumbImg.BackgroundTransparency = 1
    ThumbImg.ScaleType = Enum.ScaleType.Crop
    ThumbImg.ZIndex = 1

    -- نص تحميل مؤقت
    local LoadingLabel = Instance.new("TextLabel", ThumbFrame)
    LoadingLabel.Size = UDim2.new(1, 0, 1, 0)
    LoadingLabel.BackgroundTransparency = 1
    LoadingLabel.Text = "⏳ جاري تحميل الصورة..."
    LoadingLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
    LoadingLabel.Font = Enum.Font.GothamSemibold
    LoadingLabel.TextSize = 13
    LoadingLabel.ZIndex = 2

    -- جلب صورة الماب تلقائياً
    task.spawn(function()
        local placeId = mapData.PlaceId
        local thumbUrl = nil

        -- جلب universeId من placeId
        local universeId = nil
        pcall(function()
            local raw = game:HttpGet("https://apis.roblox.com/universes/v1/places/" .. placeId .. "/universe")
            local data = HttpService:JSONDecode(raw)
            universeId = data and data.universeId
        end)

        -- جلب صورة الغلاف
        if universeId then
            pcall(function()
                local raw = game:HttpGet("https://thumbnails.roblox.com/v1/games/multiget/thumbnails?universeIds=" .. universeId .. "&size=768x432&format=Png&isSquare=false")
                local data = HttpService:JSONDecode(raw)
                if data and data.data and data.data[1] and data.data[1].thumbnails and data.data[1].thumbnails[1] then
                    thumbUrl = data.data[1].thumbnails[1].imageUrl
                end
            end)
        end

        if thumbUrl then
            ThumbImg.Image = thumbUrl
            LoadingLabel.Visible = false
        else
            -- fallback: أيقونة اللعبة
            if universeId then
                pcall(function()
                    local raw = game:HttpGet("https://thumbnails.roblox.com/v1/games/icons?universeIds=" .. universeId .. "&size=256x256&format=Png&isCircular=false")
                    local data = HttpService:JSONDecode(raw)
                    if data and data.data and data.data[1] then
                        ThumbImg.Image = data.data[1].imageUrl or ""
                        LoadingLabel.Visible = false
                    end
                end)
            end
            if LoadingLabel.Visible then
                LoadingLabel.Text = "🎮 " .. mapData.Name
            end
        end
    end)

    -- ── معلومات الماب تحت الصورة ─────────────────────────────────
    local InfoRow = Instance.new("Frame", Card)
    InfoRow.Size = UDim2.new(1, -12, 0, 36)
    InfoRow.Position = UDim2.new(0, 6, 0, 124)
    InfoRow.BackgroundTransparency = 1

    -- بادج "ماب مدعوم"
    local Badge = Instance.new("Frame", InfoRow)
    Badge.Size = UDim2.new(0, 100, 0, 20)
    Badge.Position = UDim2.new(0, 0, 0.5, -10)
    Badge.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
    Badge.BorderSizePixel = 0
    Instance.new("UICorner", Badge).CornerRadius = UDim.new(0, 5)
    local BadgeLabel = Instance.new("TextLabel", Badge)
    BadgeLabel.Size = UDim2.new(1, 0, 1, 0)
    BadgeLabel.BackgroundTransparency = 1
    BadgeLabel.Text = "✅ ماب مدعوم"
    BadgeLabel.TextColor3 = Color3.new(1, 1, 1)
    BadgeLabel.Font = Enum.Font.GothamBold
    BadgeLabel.TextSize = 11

    -- اسم الماب
    local MapName = Instance.new("TextLabel", InfoRow)
    MapName.Size = UDim2.new(1, -115, 1, 0)
    MapName.Position = UDim2.new(0, 110, 0, 0)
    MapName.BackgroundTransparency = 1
    MapName.Text = mapData.Name
    MapName.TextColor3 = Color3.new(1, 1, 1)
    MapName.Font = Enum.Font.GothamBlack
    MapName.TextSize = 13
    MapName.TextXAlignment = Enum.TextXAlignment.Right

    -- ── زر تشغيل السكربت ─────────────────────────────────────────
    TabOps.Order = TabOps.Order + 1
    local RunBtn = Instance.new("TextButton", TabOps.Page)
    RunBtn.LayoutOrder = TabOps.Order
    RunBtn.Size = UDim2.new(0.97, 0, 0, 42)
    RunBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
    RunBtn.Text = "🚀  تشغيل سكربت الماب  /  Run Map Script"
    RunBtn.TextColor3 = Color3.new(1, 1, 1)
    RunBtn.Font = Enum.Font.GothamBold
    RunBtn.TextSize = 13
    RunBtn.BorderSizePixel = 0
    Instance.new("UICorner", RunBtn).CornerRadius = UDim.new(0, 8)

    local BtnStroke = Instance.new("UIStroke", RunBtn)
    BtnStroke.Thickness = 1.2
    BtnStroke.Transparency = 0.4
    local BtnGrad = Instance.new("UIGradient", BtnStroke)
    BtnGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 150)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 200, 100))
    }

    -- توهج خلف الزر
    local BtnGlow = Instance.new("ImageLabel", RunBtn)
    BtnGlow.Size = UDim2.new(1.2, 0, 2.5, 0)
    BtnGlow.Position = UDim2.new(-0.1, 0, -0.8, 0)
    BtnGlow.BackgroundTransparency = 1
    BtnGlow.Image = "rbxassetid://5028857084"
    BtnGlow.ImageColor3 = Color3.fromRGB(0, 200, 100)
    BtnGlow.ImageTransparency = 0.7
    BtnGlow.ZIndex = 0

    RunBtn.MouseEnter:Connect(function()
        Tween(RunBtn, {BackgroundColor3 = Color3.fromRGB(0, 190, 100)}, 0.15)
        Tween(BtnGlow, {ImageTransparency = 0.4}, 0.15)
    end)
    RunBtn.MouseLeave:Connect(function()
        Tween(RunBtn, {BackgroundColor3 = Color3.fromRGB(0, 150, 80)}, 0.2)
        Tween(BtnGlow, {ImageTransparency = 0.7}, 0.2)
    end)

    RunBtn.MouseButton1Click:Connect(function()
        -- تأثير الضغط
        Tween(RunBtn, {BackgroundColor3 = Color3.fromRGB(0, 120, 60), Size = UDim2.new(0.95, 0, 0, 38)}, 0.1)
        task.delay(0.12, function()
            Tween(RunBtn, {BackgroundColor3 = Color3.fromRGB(0, 150, 80), Size = UDim2.new(0.97, 0, 0, 42)}, 0.15)
        end)

        -- إشعار قبل التشغيل
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "🗺️ " .. mapData.Name,
                Text = "🚀 جاري تشغيل سكربت الماب...",
                Duration = 4
            })
        end)

        -- تنفيذ السكربت
        task.delay(0.5, function()
            local ok, err = pcall(function()
                loadstring(mapData.Script)()
            end)
            if not ok then
                pcall(function()
                    StarterGui:SetCore("SendNotification", {
                        Title = "⚠️ خطأ",
                        Text = "فشل تشغيل السكربت: " .. tostring(err),
                        Duration = 6
                    })
                end)
            end
        end)

        -- لوج الديسكورد
        if TabOps.LogAction then
            TabOps.LogAction("🗺️ سكربت ماب", "الماب:", mapData.Name, 65430)
        end
    end)

    -- ── وصف الماب ───────────────────────────────────────────────
    TabOps.Order = TabOps.Order + 1
    local DescFrame = Instance.new("Frame", TabOps.Page)
    DescFrame.LayoutOrder = TabOps.Order
    DescFrame.Size = UDim2.new(0.97, 0, 0, 34)
    DescFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    DescFrame.BorderSizePixel = 0
    Instance.new("UICorner", DescFrame).CornerRadius = UDim.new(0, 7)

    local DescLabel = Instance.new("TextLabel", DescFrame)
    DescLabel.Size = UDim2.new(1, -16, 1, 0)
    DescLabel.Position = UDim2.new(0, 8, 0, 0)
    DescLabel.BackgroundTransparency = 1
    DescLabel.Text = "ℹ️  " .. mapData.Description
    DescLabel.TextColor3 = Color3.fromRGB(140, 140, 160)
    DescLabel.Font = Enum.Font.Gotham
    DescLabel.TextSize = 11
    DescLabel.TextXAlignment = Enum.TextXAlignment.Right
    DescLabel.TextWrapped = true

    return Card
end
