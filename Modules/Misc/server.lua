-- [[ Cryptic Hub - ميزة السيرفر الاحترافية ]]
-- المطور: Cryptic | التحديث: فصل زر الدخول عن الإدخال + نظام التوجل المؤقت

return function(Tab, UI)
    local Players = game:GetService("Players")
    local Market = game:GetService("MarketplaceService")
    local TeleportService = game:GetService("TeleportService")
    local lp = Players.LocalPlayer
    
    local TargetJobId = "" -- متغير لحفظ الآيدي المكتوب

    -- 1. معلومات السيرفر (تحديث تلقائي)
    Tab:AddLabel("📊 حالة السيرفر الحالية")
    local GameNameLabel = Tab:AddLabel("🎮 الماب: جاري الفحص...")
    local PlayersLabel = Tab:AddLabel("👥 اللاعبين: " .. #Players:GetPlayers() .. " / " .. Players.MaxPlayers)

    task.spawn(function()
        local success, result = pcall(function()
            return Market:GetProductInfo(game.PlaceId).Name
        end)
        GameNameLabel.SetText("🎮 الماب: " .. (success and result or game.Name))
    end)

    local function updatePlayersCount()
        PlayersLabel.SetText("👥 اللاعبين: " .. #Players:GetPlayers() .. " / " .. Players.MaxPlayers)
    end
    Players.PlayerAdded:Connect(updatePlayersCount)
    Players.PlayerRemoving:Connect(updatePlayersCount)

    Tab:AddLine()

    -- 2. أدوات السيرفر (نسخ ودخول)
    Tab:AddLabel("🛠️ أدوات التحكم بالسيرفر")
    
    -- استخدام الزر المؤقت لنسخ الرمز بشكل أنيق
    Tab:AddTimedToggle("📋 نسخ رمز السيرفر (JobId)", function(active)
        if active then
            pcall(function()
                setclipboard(tostring(game.JobId))
                UI:Notify("✅ تم نسخ الرمز للحافظة!")
            end)
        end
    end)

    -- خانة إدخال الآيدي (تحفظ النص فقط)
    Tab:AddInput("🔗 آيدي السيرفر المستهدف", "إلصق الرمز هنا...", function(txt)
        TargetJobId = txt
    end)

    -- زر منفصل لتنفيذ الدخول (عشان ما يقلتش عليك)
    Tab:AddButton("🚀 دخول السيرفر المحدد", function()
        if TargetJobId and #TargetJobId > 10 then
            UI:Notify("⏳ جاري محاولة الانتقال...")
            pcall(function()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, TargetJobId, lp)
            end)
        else
            UI:Notify("⚠️ يرجى إدخال آيدي صحيح أولاً!")
        end
    end)

    Tab:AddLine()

    -- 3. ميزات إضافية
    Tab:AddButton("🔄 إعادة دخول السيرفر (Rejoin)", function()
        UI:Notify("🔄 جاري إعادة الاتصال...")
        TeleportService:Teleport(game.PlaceId, lp)
    end)

    Tab:AddParagraph("نصيحة: استخدم Rejoin إذا شعرت بوجود لاق (Lag) في السيرفر.")
end
