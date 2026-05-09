-- [[ Cryptic Hub - ميزة الدخول عبر الآيدي / Server ID Access ]]
-- المطور: يامي (Yami) | التحديث: إشعار تفعيل فقط + ترجمة مزدوجة / Update: Activation notify only + Dual language

return function(Tab, UI)
    local TeleportService = game:GetService("TeleportService")
    local StarterGui = game:GetService("StarterGui")
    local Players = game:GetService("Players")
    local lp = Players.LocalPlayer

    -- دالة الإشعارات المزدوجة / Dual notification function
    local function Notify(arText, enText)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Cryptic Hub",
                Text = arText .. "\n" .. enText,
                Duration = 4,
            })
        end)
    end

    -- 1. زر نسخ رمز السيرفر الحالي / Copy Current JobId
    Tab:AddTimedToggle("📋 نسخ رمز السيرفر / Copy JobId", function(active)
        if active then
            pcall(function()
                setclipboard(tostring(game.JobId))
                -- إشعار التفعيل المزدوج / Activation notify
                Notify("✅ تم نسخ الرمز للحافظة!", "✅ Server ID copied to clipboard!")
            end)
        end
        -- الإيقاف صامت تلقائياً لأنه TimedToggle
    end)

    Tab:AddLine()

    -- 2. خانة الانتقال الفوري / Target Server Input
    local InputField = Tab:AddInput("🔗 آيدي السيرفر / Target JobId", "إلصق الرمز هنا... / Paste ID here...", function() end)

    task.spawn(function()
        repeat task.wait() until InputField and InputField.TextBox
        
        InputField.TextBox.FocusLost:Connect(function()
            local txt = InputField.TextBox.Text
            
            if txt and #txt > 20 then
                -- إشعار بدء الانتقال المزدوج / Teleport start notify
                Notify("⏳ جاري الانتقال للسيرفر المحدد...", "⏳ Teleporting to target server...")
                
                task.wait(0.5) 
                
                pcall(function()
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, txt, lp)
                end)
                
            elseif txt ~= "" then
                -- إشعار الخطأ المزدوج / Error notify
                Notify("⚠️ الآيدي غير صحيح أو قصير جداً!", "⚠️ ID is invalid or too short!")
            end
        end)
    end)
end
