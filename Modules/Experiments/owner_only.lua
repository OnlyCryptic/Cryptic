-- [[ Cryptic Hub - التشغيل التلقائي (Auto-Execute) ]]
-- المطور: أروى (Arwa Roger) | الوصف: زرع السكربت ليعمل تلقائياً عند دخول أي ماب

return function(Tab, UI)
    local StarterGui = game:GetService("StarterGui")

    local function SendRobloxNotification(title, text)
        pcall(function() StarterGui:SetCore("SendNotification", { Title = title, Text = text, Duration = 5 }) end)
    end

    Tab:AddToggle("تشغيل السكربت تلقائياً / Auto-Execute", function(state)
        local scriptLink = "loadstring(game:HttpGet('https://raw.githubusercontent.com/OnlyCryptic/Cryptic/main/main.lua'))()"
        
        if state then
            -- 1. محاولة زرع السكربت في مجلد الـ AutoExecute
            local success, err = pcall(function()
                writefile("autoexec/CrypticHub_Auto.lua", scriptLink)
            end)
            
            -- 2. تفعيل التشغيل التلقائي عند الانتقال (Teleport)
            pcall(function()
                local queue_tp = queue_on_teleport or (syn and syn.queue_on_teleport) or (getgenv and getgenv().queue_on_teleport)
                if queue_tp then
                    queue_tp(scriptLink)
                end
            end)

            if success then
                SendRobloxNotification("Cryptic Hub", "✅ تم تفعيل التشغيل التلقائي! سيعمل السكربت بوجهك كل مرة.")
            else
                SendRobloxNotification("Cryptic Hub", "⚠️ حماية المشغل تمنع الزرع التلقائي.\nيرجى وضع السكربت يدوياً في قسم AutoExecute بالمشغل.")
            end
        else
            -- إزالة السكربت عند الإيقاف
            pcall(function()
                if isfile and isfile("autoexec/CrypticHub_Auto.lua") then
                    delfile("autoexec/CrypticHub_Auto.lua")
                end
            end)
            SendRobloxNotification("Cryptic Hub", "❌ تم إيقاف التشغيل التلقائي.")
        end
    end)
    
    Tab:AddLine()
    Tab:AddParagraph("ملاحظة: تعتمد هذه الميزة على المشغل (Executor). إذا لم تنجح في كتابة الملف تلقائياً، قم بنسخ رابط السكربت وضعه في مجلد autoexec الخاص بمشغلك يدوياً.")
end
