-- ملف ميزة السيرفر (server.lua)
return function(Tab, UI)
    local TeleportService = game:GetService("TeleportService")
    local Stats = game:GetService("Stats")
    
    -- عرض المعلومات الأساسية
    Tab:AddButton("تحديث معلومات السيرفر", function()
        local ping = math.floor(Stats.Network.ServerTickRate:GetValue())
        local playersCount = #game.Players:GetPlayers()
        UI:Notify("البنج: " .. ping .. " | اللاعبين: " .. playersCount)
    end)

    -- نسخ رمز الدخول (JobId)
    Tab:AddButton("نسخ رمز دخول السيرفر", function()
        setclipboard(tostring(game.JobId))
        UI:Notify("تم نسخ الرمز! أرسله لصديقك.")
    end)

    -- لصق الرمز والدخول
    Tab:AddInput("دخول سيرفر محدد", "إلصق رمز الـ JobId هنا...", function(txt)
        if txt and #txt > 10 then
            UI:Notify("جاري الانتقال للسيرفر...")
            TeleportService:TeleportToPlaceInstance(game.PlaceId, txt, game.Players.LocalPlayer)
        else
            UI:Notify("الرمز غير صحيح!")
        end
    end)
end
