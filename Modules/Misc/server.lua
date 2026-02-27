-- [[ Cryptic Hub - ميزة السيرفر المطورة والمحسنة ]]
-- المطور: Arwa | تحديث فوري لعدد اللاعبين وتصميم أنيق

return function(Tab, UI)
    local Players = game:GetService("Players")
    local Market = game:GetService("MarketplaceService")
    local TeleportService = game:GetService("TeleportService")
    local lp = Players.LocalPlayer

    -- 1. عرض المعلومات بشكل منفصل وأنيق (يظهر العدد فوراً بدون انتظار)
    local GameNameLabel = Tab:AddLabel("🎮 الماب: جاري التحميل...")
    local PlayersLabel = Tab:AddLabel("👥 اللاعبين: " .. #Players:GetPlayers() .. " / " .. Players.MaxPlayers)

    -- 2. جلب اسم الماب في الخلفية دون تعطيل الواجهة
    task.spawn(function()
        local success, result = pcall(function()
            return Market:GetProductInfo(game.PlaceId).Name
        end)
        
        -- إذا نجح الجلب يعرض الاسم، وإذا فشل يعرض اسم المكان الافتراضي لضمان السرعة
        if success and result then
            GameNameLabel.SetText("🎮 الماب: " .. result)
        else
            GameNameLabel.SetText("🎮 الماب: " .. game.Name)
        end
    end)

    -- 3. التحديث "الذكي" لعدد اللاعبين (بدون Loop)
    -- يتحدث فوراً وبدون لاج فقط عندما يدخل أو يخرج لاعب
    local function updatePlayersCount()
        PlayersLabel.SetText("👥 اللاعبين: " .. #Players:GetPlayers() .. " / " .. Players.MaxPlayers)
    end

    Players.PlayerAdded:Connect(updatePlayersCount)
    Players.PlayerRemoving:Connect(updatePlayersCount)

    -- خط فاصل لتنظيم الواجهة
    Tab:AddLine()

    -- 4. أزرار الدخول والنسخ بتصميم أوضح
    Tab:AddButton("📋 نسخ رمز السيرفر (JobId)", function()
        pcall(function()
            setclipboard(tostring(game.JobId))
            UI:Notify("✅ تم نسخ رمز السيرفر بنجاح!")
        end)
    end)

    Tab:AddInput("🔗 الانضمام لسيرفر محدد", "إلصق الرمز (JobId) هنا...", function(txt)
        if txt and #txt > 10 then
            UI:Notify("⏳ جاري الانتقال للسيرفر...")
            pcall(function()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, txt, lp)
            end)
        else
            UI:Notify("❌ الرمز غير صحيح أو قصير جداً")
        end
    end)
    
    Tab:AddParagraph("ملاحظة: يمكنك نسخ الرمز وإرساله لأصدقائك ليلتحقوا بك في نفس السيرفر.")
end
