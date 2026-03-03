-- [[ Cryptic Hub - ميزة الدخول عبر الآيدي ]]
-- المطور: يامي (Yami) | التحديث: استخدام إشعارات روبلوكس الأصلية لتجنب القلتشات

return function(Tab, UI)
    local TeleportService = game:GetService("TeleportService")
    local StarterGui = game:GetService("StarterGui")
    local Players = game:GetService("Players")
    local lp = Players.LocalPlayer

    -- دالة إشعارات روبلوكس الأصلية
    local function SendRobloxNotification(title, text)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = title,
                Text = text,
                Duration = 4,
            })
        end)
    end

    -- 1. زر نسخ رمز السيرفر الحالي
    Tab:AddTimedToggle("📋 نسخ رمز السيرفر (JobId)", function(active)
        if active then
            pcall(function()
                setclipboard(tostring(game.JobId))
                SendRobloxNotification("Cryptic Hub", "✅ تم نسخ الرمز للحافظة!")
            end)
        end
    end)

    Tab:AddLine()

    -- 2. خانة الانتقال الفوري (بمجرد اللصق وإغلاق الكيبورد)
    local InputField = Tab:AddInput("🔗 آيدي السيرفر المستهدف / jobId", "إلصق الرمز وأغلق الكيبورد...", function() end)

    task.spawn(function()
        repeat task.wait() until InputField and InputField.TextBox
        
        InputField.TextBox.FocusLost:Connect(function()
            local txt = InputField.TextBox.Text
            
            if txt and #txt > 20 then
                SendRobloxNotification("Cryptic Hub", "⏳ جاري الانتقال للسيرفر المحدد...")
                
                -- انتظار خفيف جداً لضمان ظهور الإشعار قبل تجميد الانتقال
                task.wait(0.5) 
                
                pcall(function()
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, txt, lp)
                end)
                
            elseif txt ~= "" then
                SendRobloxNotification("Cryptic Hub", "⚠️ الآيدي غير صحيح أو قصير جداً!")
            end
        end)
    end)
end
