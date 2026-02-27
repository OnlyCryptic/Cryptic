-- [[ Cryptic Hub - ميزة السيرفر المختصرة ]]
-- عرض عدد اللاعبين واسم الماب فقط

return function(Tab, UI)
    local Market = game:GetService("MarketplaceService")
    local player = game.Players.LocalPlayer

    -- 1. إنشاء خانة العرض (Label)
    local InfoDisplay = Tab:AddLabel("جاري التحميل...")

    -- 2. جلب اسم الماب الحالي مرة واحدة بحذر
    local gameName = "غير معروف"
    task.spawn(function()
        local s, res = pcall(function()
            return Market:GetProductInfo(game.PlaceId).Name
        end)
        if s then gameName = res end
    end)

    -- 3. حلقة تحديث عدد اللاعبين فقط كل ثانيتين
    task.spawn(function()
        while task.wait(2) do
            pcall(function()
                local playersCount = #game.Players:GetPlayers()
                local maxPlayers = game.Players.MaxPlayers
                
                -- التنسيق المطلوب: (العدد/الأقصى) ماب (الاسم)
                InfoDisplay:SetText(playersCount .. "/" .. maxPlayers .. " | ماب " .. gameName)
            end)
        end
    end)

    -- ميزة نسخ رمز الدخول (JobId) - أبقيناها لأهميتها في مشاركة السيرفر
    Tab:AddButton("نسخ رمز دخول السيرفر (JobId)", function()
        setclipboard(tostring(game.JobId))
        UI:Notify("تم نسخ الرمز!")
    end)

    -- ميزة الدخول لسيرفر محدد
    Tab:AddInput("دخول سيرفر محدد", "إلصق الرمز هنا...", function(txt)
        if txt and #txt > 5 then
            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, txt, player)
        end
    end)
end
