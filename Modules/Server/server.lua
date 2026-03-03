-- [[ Cryptic Hub - قسم السيرفر ]]
-- المطور: يامي (Yami) | التحديث: انتقال تلقائي بمجرد لصق الآيدي بدون أزرار

return function(Tab, UI)
    local Players = game:GetService("Players")
    local Market = game:GetService("MarketplaceService")
    local TeleportService = game:GetService("TeleportService")
    local lp = Players.LocalPlayer

    -- 1. حالة السيرفر (مدمجة في سطر واحد لتوفير المساحة)
    local StatusLabel = Tab:AddLabel("📊 جاري جلب المعلومات...")

    task.spawn(function()
        local gameName = game.Name
        pcall(function()
            gameName = Market:GetProductInfo(game.PlaceId).Name
        end)
        
        local function updateStatus()
            -- دمج اسم الماب وعدد اللاعبين
            StatusLabel.SetText("🎮 " .. gameName .. " | 👥 " .. #Players:GetPlayers() .. "/" .. Players.MaxPlayers)
        end
        
        updateStatus()
        Players.PlayerAdded:Connect(updateStatus)
        Players.PlayerRemoving:Connect(updateStatus)
    end)

    Tab:AddLine()

    -- 2. أدوات النسخ والدخول التلقائي
    Tab:AddTimedToggle("📋 نسخ رمز السيرفر (JobId)", function(active)
        if active then
            pcall(function()
                setclipboard(tostring(game.JobId))
                UI:Notify("✅ تم نسخ الرمز للحافظة!")
            end)
        end
    end)

    -- دمج الانتقال التلقائي بمجرد إدخال الآيدي
    Tab:AddInput("🔗 آيدي السيرفر المستهدف", "إلصق الرمز هنا للانتقال فوراً...", function(txt)
        -- نتحقق إن النص المدخل طويل كفاية ليكون JobId (عادة الـ JobId يتكون من 36 حرف)
        if txt and #txt > 20 then
            UI:Notify("⏳ جاري محاولة الانتقال التلقائي...")
            pcall(function()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, txt, lp)
            end)
        end
    end)
end
