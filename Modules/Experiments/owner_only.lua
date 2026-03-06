    -- [[ زر التشغيل التلقائي للسكربت (Auto-Execute) ]]
    Tab:AddLine()
    Tab:AddToggle("تشغيل السكربت تلقائياً / Auto-Execute", function(state)
        local scriptLink = "loadstring(game:HttpGet('https://raw.githubusercontent.com/OnlyCryptic/Cryptic/main/main.lua'))()"
        
        if state then
            -- 1. محاولة زرع السكربت في مجلد الـ AutoExecute الخاص بالمشغل
            local success, err = pcall(function()
                writefile("autoexec/CrypticHub_Auto.lua", scriptLink)
            end)
            
            -- 2. تفعيل التشغيل التلقائي عند الانتقال لسيرفر آخر (Teleport)
            pcall(function()
                local queue_tp = queue_on_teleport or (syn and syn.queue_on_teleport) or (getgenv and getgenv().queue_on_teleport)
                if queue_tp then
                    queue_tp(scriptLink)
                end
            end)

            if success then
                SendRobloxNotification("Cryptic Hub", "✅ تم تفعيل التشغيل التلقائي! سيعمل السكربت مع كل دخول.")
            else
                -- خطة بديلة إذا كان المشغل يحظر الكتابة في مجلد autoexec
                SendRobloxNotification("Cryptic Hub", "⚠️ حماية المشغل تمنع الزرع التلقائي.\nيرجى وضع السكربت يدوياً في قسم AutoExecute بالمشغل.")
            end
        else
            -- إزالة السكربت من مجلد التشغيل التلقائي عند الإيقاف
            pcall(function()
                if isfile and isfile("autoexec/CrypticHub_Auto.lua") then
                    delfile("autoexec/CrypticHub_Auto.lua")
                end
            end)
            SendRobloxNotification("Cryptic Hub", "❌ تم إيقاف التشغيل التلقائي.")
        end
    end)
    Tab:AddParagraph("ملاحظة: ميزة التشغيل التلقائي تعتمد على صلاحيات المشغل (Executor). إذا لم تعمل، استخدم قسم AutoExecute الموجود في واجهة المشغل الخاص بك.")
