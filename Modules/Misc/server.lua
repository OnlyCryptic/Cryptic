-- [[ Cryptic Hub - ميزة السيرفر المستقرة ]]
-- تم إصلاح مشكلة التعليق وضمان التحديث التلقائي

return function(Tab, UI)
    local TeleportService = game:GetService("TeleportService")
    local Market = game:GetService("MarketplaceService")
    local player = game.Players.LocalPlayer

    -- 1. إنشاء خانة العرض أولاً لضمان عدم بقائها معلقة
    local InfoDisplay = Tab:AddLabel("📍 جاري الاتصال بالسيرفر...")

    -- 2. محاولة جلب اسم الماب بحذر (pcall) لعدم تعطيل السكربت
    local gameName = "غير معروف"
    task.spawn(function()
        local s, res = pcall(function()
            return Market:GetProductInfo(game.PlaceId).Name
        end)
        if s then gameName = res end
    end)

    -- 3. حلقة التحديث التلقائي (محمية لضمان الاستمرارية)
    task.spawn(function()
        while task.wait(2) do
            pcall(function()
                -- حساب عدد اللاعبين
                local playersCount = #game.Players:GetPlayers()
                local maxPlayers = game.Players.MaxPlayers
                
                -- جلب البنج بدقة أفضل للهواتف
                local ping = math.floor(player:GetNetworkPing() * 1000) 
                if ping <= 0 then ping = "..." end -- في حال لم يقرأ البنج بعد

                -- تحديث النص في الواجهة
                InfoDisplay:SetText("📍 ماب: " .. gameName .. " | 👥 لاعبين: " .. playersCount .. "/" .. maxPlayers .. " | 📶 بنج: " .. ping .. "ms")
            end)
        end
    end)

    -- ميزة نسخ رمز الدخول (JobId)
    Tab:AddButton("نسخ رمز دخول السيرفر (JobId)", function()
        setclipboard(tostring(game.JobId))
        UI:Notify("تم نسخ الرمز بنجاح!")
    end)

    -- ميزة الدخول لسيرفر محدد
    Tab:AddInput("دخول سيرفر محدد عبر الرمز", "إلصق رمز الـ JobId هنا...", function(txt)
        if txt and #txt > 5 then
            UI:Notify("جاري الانتقال للسيرفر...")
            TeleportService:TeleportToPlaceInstance(game.PlaceId, txt, player)
        else
            UI:Notify("الرمز غير صالح!")
        end
    end)
end
