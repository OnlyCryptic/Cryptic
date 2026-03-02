-- [[ Cryptic Hub - سكربت الرقصات (All Emotes) ]]
-- المطور: Cryptic | التحديث: عزل التحميل لمنع تجميد الواجهة والزر المؤقت

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

    Tab:AddTimedToggle("تشغيل سكربت الرقصات", function(active)
        if active then
            -- 1. إرسال الإشعار فوراً
            SendScreenNotify(
                "Cryptic Hub", 
                "تم تشغيل سكربت رقصات رجاءا انتضر 3 دقائق على اقل لتحميل كل رقصات روبلوكس ⏳", 
                30
            )
            
            -- 2. عزل التحميل الثقيل في مسار منفصل تماماً (عشان ما يعلق الزر)
            task.spawn(function()
                -- نعطي الواجهة نصف ثانية عشان تحدث شكل الزر بدون لاق
                task.wait(0.5) 
                
                -- تشغيل السكربت الخارجي
                pcall(function()
                    loadstring(game:HttpGet("http://scriptblox.com/raw/Baseplate-Fe-All-Emote-7386"))()
                end)
            end)
        end
    end)
end
