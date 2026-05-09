-- [[ Cryptic Hub - السرعة المطورة / Advanced WalkSpeed ]]
-- المطور: يامي (Yami) | التحديث: إضافة إشعار عند التفعيل فقط / Update: Added notification on activation only

return function(Tab, UI)
    local player = game.Players.LocalPlayer
    local StarterGui = game:GetService("StarterGui") -- إضافة خدمة الإشعارات
    
    -- دالة إرسال الإشعارات المزدوجة / Dual notification function
    local function Notify(title, text)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = title,
                Text = text,
                Duration = 3
            })
        end)
    end

    -- أضفنا الرقم 50 في نهاية الدالة ليكون القيمة الافتراضية في الخانة / Added 50 as the default value in the input field
    Tab:AddSpeedControl("سرعة المشي / WalkSpeed", function(active, value)
        local char = player.Character
        local hum = char and char:FindFirstChild("Humanoid")
        
        if hum then
            -- إذا تم تفعيل الزر، يأخذ القيمة المكتوبة، وإذا أطفي يرجع للسرعة الطبيعية (16)
            -- If enabled, uses the inputted value; if disabled, returns to default speed (16)
            hum.WalkSpeed = active and value or 16 
        end
        
        -- إظهار الإشعار عند التفعيل فقط / Show notification on activation only
        if active then
            Notify("Cryptic Hub", "⚡ تم تفعيل السرعة المطورة!\n⚡ Advanced WalkSpeed activated!")
        end
        -- إذا تم إيقاف الميزة (active = false) لن يظهر أي إشعار وتنطفئ بصمت
        
    end, 50)
end
