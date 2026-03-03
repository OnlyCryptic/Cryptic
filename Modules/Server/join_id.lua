-- [[ Cryptic Hub - ميزة الدخول عبر الآيدي ]]
-- المطور: يامي (Yami) | التحديث: ملف مستقل للدخول الفوري عبر JobId

return function(Tab, UI)
    local TeleportService = game:GetService("TeleportService")
    local Players = game:GetService("Players")
    local lp = Players.LocalPlayer

    -- 1. زر نسخ رمز السيرفر الحالي
    Tab:AddTimedToggle("📋 نسخ رمز السيرفر (JobId)", function(active)
        if active then
            pcall(function()
                setclipboard(tostring(game.JobId))
                UI:Notify("✅ تم نسخ الرمز للحافظة!")
            end)
        end
    end)

    Tab:AddLine()

    -- 2. خانة الانتقال الفوري (بمجرد اللصق وإغلاق الكيبورد)
    local InputField = Tab:AddInput("🔗 آيدي السيرفر المستهدف", "إلصق الرمز وأغلق الكيبورد...", function() end)

    task.spawn(function()
        -- ننتظر حتى يتم تحميل الواجهة بالكامل
        repeat task.wait() until InputField and InputField.TextBox
        
        InputField.TextBox.FocusLost:Connect(function()
            local txt = InputField.TextBox.Text
            
            -- التحقق من أن الآيدي طويل كفاية (الـ JobId دائماً يتجاوز 30 حرف)
            if txt and #txt > 20 then
                UI:Notify("⏳ جاري الانتقال للسيرفر المحدد...")
                
                pcall(function()
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, txt, lp)
                end)
                
            -- تنبيه إذا كان النص المدخل قصير أو خاطئ
            elseif txt ~= "" then
                UI:Notify("⚠️ الآيدي غير صحيح أو قصير جداً!")
            end
        end)
    end)
end
