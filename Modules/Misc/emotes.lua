-- [[ Cryptic Hub - سكربت الرقصات / All Emotes ]]
-- المطور: أروى (Arwa) | التحديث: إشعار تفعيل فقط + ترجمة مزدوجة / Update: Activation notify only + Dual language

return function(Tab, UI)
    -- متغير لحفظ حالة التشغيل (يمنع التكرار واللاق)
    local isExecuted = false

    -- دالة إرسال الإشعارات المزدوجة / Dual screen notification function
    local function SendScreenNotify(title, arText, enText, duration)
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = title,
                Text = arText .. "\n" .. enText,
                Duration = duration or 3
            })
        end)
    end

    Tab:AddToggle("سكربت الرقصات / Emotes", function(state)
        if state then
            -- التحقق إذا كان السكربت شغال من قبل / Check if already running
            if isExecuted then
                SendScreenNotify(
                    "Cryptic Hub", 
                    "⚠️ مشغل بالفعل! أعد الدخول لإعادة التشغيل", 
                    "⚠️ Already running! Rejoin to reset", 
                    5
                )
                return
            end
            
            -- تسجيل أنه تم التشغيل / Mark as executed
            isExecuted = true

            -- إرسال إشعار التفعيل المزدوج / Activation notification
            SendScreenNotify(
                "Cryptic Hub", 
                "⏳ تم التشغيل! انتظر 3 دقائق لتحميل الرقصات", 
                "⏳ Executed! Wait 3 mins to load emotes", 
                30
            )
            
            -- تشغيل السكربت الخارجي / Execute external script
            task.spawn(function()
                pcall(function()
                    loadstring(game:HttpGet("http://scriptblox.com/raw/Baseplate-Fe-All-Emote-7386"))()
                end)
            end)
        else
            -- إيقاف صامت: لا يوجد إشعار هنا عند إطفاء الزر
            if isExecuted then
                -- تنبيه بسيط فقط لأن السكربتات المحملة بـ loadstring لا يمكن حذفها برمجياً بسهولة
                SendScreenNotify(
                    "Cryptic Hub", 
                    "⚠️ السكربت محمل مسبقاً، أعد الدخول للإلغاء", 
                    "⚠️ Script already loaded, rejoin to cancel", 
                    5
                )
            end
        end
    end)
end
