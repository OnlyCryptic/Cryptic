-- [[ Cryptic Hub - سكربت الرقصات (All Emotes) ]]
-- المطور: أروى (Arwa) | التحديث: زر تشغيل عادي (Toggle) يشتغل مرة واحدة فقط

return function(Tab, UI)
    -- متغير لحفظ حالة التشغيل (يمنع التكرار واللاق)
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

    Tab:AddToggle("سكربت الرقصات / Emotes", function(state)
        if state then
            -- التحقق إذا كان السكربت شغال من قبل
            if isExecuted then
                SendScreenNotify("Cryptic Hub", "مشغل بالفعل اخرج ورجع لعادت تشغيله ⚠️", 5)
                return
            end
            
            -- تسجيل أنه تم التشغيل عشان ما يتكرر
            isExecuted = true

            -- إرسال الإشعار فوراً
            SendScreenNotify(
                "Cryptic Hub", 
                "تم تشغيل سكربت رقصات رجاءا انتضر 3 دقائق على اقل لتحميل كل رقصات روبلوكس ⏳", 
                30
            )
            
            -- عزل التحميل الثقيل في مسار منفصل تماماً
            task.spawn(function()
                pcall(function()
                    loadstring(game:HttpGet("http://scriptblox.com/raw/Baseplate-Fe-All-Emote-7386"))()
                end)
            end)
        else
            -- إذا حاول يطفي الزر بعد ما اشتغل
            if isExecuted then
                SendScreenNotify("Cryptic Hub", "مشغل بالفعل اخرج ورجع لعادت تشغيله ⚠️", 5)
            end
        end
    end)
end
