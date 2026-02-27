-- [[ Cryptic Hub - ميزة السيرفر المطورة ]]
-- عرض تلقائي لبيانات الماب واللاعبين والبنج

return function(Tab, UI)
    local TeleportService = game:GetService("TeleportService")
    local Stats = game:GetService("Stats")
    local Market = game:GetService("MarketplaceService")

    -- جلب اسم الماب الحالي
    local gameName = Market:GetProductInfo(game.PlaceId).Name
    
    -- إنشاء خانة عرض البيانات (Label)
    local InfoDisplay = Tab:AddLabel("جاري جلب بيانات السيرفر...")
    
    -- تحديث المعلومات تلقائياً كل ثانيتين لضمان الدقة
    task.spawn(function()
        while true do
            -- حساب البنج التقريبي وعدد اللاعبين
            local ping = math.floor(Stats.Network.ServerTickRate:GetValue())
            local playersCount = #game.Players:GetPlayers()
            local maxPlayers = game.Players.MaxPlayers
            
            -- تحديث النص في الواجهة باللغة العربية
            InfoDisplay:SetText("📍 الماب: " .. gameName .. " | 👥 اللاعبين: " .. playersCount .. "/" .. maxPlayers .. " | 📶 البنج: " .. ping .. "ms")
            task.wait(2)
        end
    end)

    -- ميزة نسخ رمز الدخول (JobId) لمشاركتها مع الأصدقاء
    Tab:AddButton("نسخ رمز دخول السيرفر (JobId)", function()
        setclipboard(tostring(game.JobId))
        UI:Notify("تم نسخ الرمز! أرسله لصديقك ليدخل معك.")
    end)

    -- ميزة الدخول لسيرفر محدد عبر لصق الرمز
    Tab:AddInput("دخول سيرفر محدد عبر الرمز", "إلصق رمز الـ JobId هنا...", function(txt)
        if txt and #txt > 10 then
            UI:Notify("جاري محاولة الانتقال للسيرفر المختار...")
            TeleportService:TeleportToPlaceInstance(game.PlaceId, txt, game.Players.LocalPlayer)
        else
            UI:Notify("الرمز غير صحيح! تأكد من لصق JobId سليم.")
        end
    end)
end
