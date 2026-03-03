-- [[ Cryptic Hub - قسم السيرفر ]]
-- المطور: يامي (Yami) | التحديث: دمج المعلومات وإزالة الزوائد

return function(Tab, UI)
    local Players = game:GetService("Players")
    local Market = game:GetService("MarketplaceService")
    local TeleportService = game:GetService("TeleportService")
    local lp = Players.LocalPlayer
    
    local TargetJobId = ""

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

    -- 2. أدوات النسخ والدخول (بدون عنوان إضافي)
    Tab:AddTimedToggle("📋 نسخ رمز السيرفر (JobId)", function(active)
        if active then
            pcall(function()
                setclipboard(tostring(game.JobId))
                UI:Notify("✅ تم نسخ الرمز للحافظة!")
            end)
        end
    end)

    Tab:AddInput("🔗 آيدي السيرفر المستهدف", "إلصق الرمز هنا...", function(txt)
        TargetJobId = txt
    end)

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
end
