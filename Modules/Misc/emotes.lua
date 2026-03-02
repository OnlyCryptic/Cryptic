-- [[ Cryptic Hub - سكربت الرقصات (All Emotes) ]]
-- المطور: Cryptic | التحديث: استخدام الزر المؤقت + إشعار روبلوكس لمدة 10 ثواني

return function(Tab, UI)
    -- دالة إرسال الإشعارات على شاشة اللعبة مباشرة
    local function SendScreenNotify(title, text, duration)
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = title,
                Text = text,
                Duration = duration or 3
            })
        end)
    end

    -- استخدام دالة الزر المؤقت الجديدة (تشتغل وتطفي تلقائياً)
    Tab:AddTimedToggle("تشغيل سكربت الرقصات", function(active)
        if active then
            -- إرسال الإشعار لمدة 10 ثواني في شاشة روبلوكس
            SendScreenNotify(
                "Cryptic Hub", 
                "تم تشغيل سكربت رقصات رجاءا انتضر 3 دقائق على اقل لتحميل كل رقصات روبلوكس ⏳", 
                10
            )
            
            -- تشغيل السكربت الخارجي باستخدام pcall لمنع أي كراش
            pcall(function()
                loadstring(game:HttpGet("http://scriptblox.com/raw/Baseplate-Fe-All-Emote-7386"))()
            end)
        end
    end)
end
