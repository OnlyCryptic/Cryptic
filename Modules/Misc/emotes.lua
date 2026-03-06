-- [[ Cryptic Hub - سكربت الرقصات (All Emotes) ]]
-- المطور: أروى (Arwa) | التحديث: زر عادي يشتغل مرة واحدة فقط لمنع اللاق والكرش

return function(Tab, UI)
    -- متغير لحفظ حالة التشغيل (يمنع التكرار)
    local isExecuted = false

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

    Tab:AddButton("سكربت الرقصات / Emotes", function()
        -- التحقق إذا كان السكربت شغال من قبل
        if isExecuted then
            SendScreenNotify("Cryptic Hub", "مشغل بالفعل اخرج ورجع لعادت تشغيله ⚠️", 5)
            return -- إيقاف تنفيذ الكود هنا
        end
        
        -- قفل الزر وتسجيل أنه تم التشغيل
        isExecuted = true

        -- 1. إرسال الإشعار فوراً
        SendScreenNotify(
            "Cryptic Hub", 
            "تم تشغيل سكربت رقصات رجاءا انتضر 3 دقائق على اقل لتحميل كل رقصات روبلوكس ⏳", 
            30
        )
        
        -- 2. عزل التحميل الثقيل في مسار منفصل تماماً (عشان ما يعلق اللعبة)
        task.spawn(function()
            -- تشغيل السكربت الخارجي
            pcall(function()
                loadstring(game:HttpGet("http://scriptblox.com/raw/Baseplate-Fe-All-Emote-7386"))()
            end)
        end)
    end)
end
