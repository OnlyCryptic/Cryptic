-- [[ Cryptic Hub - قسم السيرفر ]]
-- المطور: يامي (Yami) | التحديث: انتقال فوري لحظة اللصق (دون الحاجة لإغلاق الكيبورد)

return function(Tab, UI)
    local Players = game:GetService("Players")
    local Market = game:GetService("MarketplaceService")
    local TeleportService = game:GetService("TeleportService")
    local lp = Players.LocalPlayer

    -- 1. حالة السيرفر (مدمجة)
    local StatusLabel = Tab:AddLabel("📊 جاري جلب المعلومات...")

    task.spawn(function()
        local gameName = game.Name
        pcall(function()
            gameName = Market:GetProductInfo(game.PlaceId).Name
        end)
        
        local function updateStatus()
            StatusLabel.SetText("🎮 " .. gameName .. " | 👥 " .. #Players:GetPlayers() .. "/" .. Players.MaxPlayers)
        end
        
        updateStatus()
        Players.PlayerAdded:Connect(updateStatus)
        Players.PlayerRemoving:Connect(updateStatus)
    end)

    Tab:AddLine()

    -- 2. نسخ رمز السيرفر
    Tab:AddTimedToggle("📋 نسخ رمز السيرفر (JobId)", function(active)
        if active then
            pcall(function()
                setclipboard(tostring(game.JobId))
                UI:Notify("✅ تم نسخ الرمز للحافظة!")
            end)
        end
    end)

    -- 3. الانتقال الفوري المباشر (التعديل هنا)
    local InputField = Tab:AddInput("🔗 آيدي السيرفر المستهدف", "إلصق الرمز هنا للانتقال فوراً...", function() end)

    task.spawn(function()
        repeat task.wait() until InputField and InputField.TextBox
        
        local isTeleporting = false -- متغير لمنع التكرار (Spam)
        
        -- استخدمنا المراقبة اللحظية بدلاً من FocusLost
        InputField.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
            local txt = InputField.TextBox.Text
            
            -- الـ JobId الحقيقي يتكون من 36 حرف، وضعنا > 30 كشرط أمان
            if not isTeleporting and txt and #txt > 30 then
                isTeleporting = true -- نقفل الباب لمنع تكرار الانتقال
                UI:Notify("⏳ جاري الانتقال للسيرفر المحدد...")
                
                pcall(function()
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, txt, lp)
                end)
                
                -- إعادة التعيين في حال فشل الانتقال
                task.wait(5)
                isTeleporting = false
            end
        end)
    end)
end
