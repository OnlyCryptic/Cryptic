-- [[ Cryptic Hub - التشغيل التلقائي (Auto-Execute) ]]
-- المطور: أروى (Arwa) | الوصف: زرع السكربت ليعمل تلقائياً ومنع تكرار الواجهة

return function(Tab, UI)
    local StarterGui = game:GetService("StarterGui")

    local function SendRobloxNotification(title, text)
        pcall(function() StarterGui:SetCore("SendNotification", { Title = title, Text = text, Duration = 5 }) end)
    end

    Tab:AddToggle("تشغيل السكربت تلقائياً / Auto-Execute", function(state)
        -- كود الحقن الذكي (يفحص إذا السكربت شغال مسبقاً عشان ما يكرر الواجهة)
        local scriptLink = [[
            if not getgenv().CrypticHub_Loaded then
                getgenv().CrypticHub_Loaded = true
                loadstring(game:HttpGet('https://raw.githubusercontent.com/OnlyCryptic/Cryptic/main/main.lua'))()
            end
        ]]
        
        if state then
            -- محاولة الزرع في ملف (حسب صلاحيات المشغل)
            pcall(function()
                writefile("autoexec/CrypticHub_Auto.lua", scriptLink)
            end)
            
            -- التفعيل عند الانتقال أو الريجوين
            pcall(function()
                local queue_tp = queue_on_teleport or (syn and syn.queue_on_teleport) or (getgenv and getgenv().queue_on_teleport)
                if queue_tp then
                    queue_tp(scriptLink)
                end
            end)

            SendRobloxNotification("Cryptic Hub", "✅ تم تفعيل التشغيل التلقائي! (لا تنسى حفظ الإعدادات)")
        else
            pcall(function()
                if isfile and isfile("autoexec/CrypticHub_Auto.lua") then
                    delfile("autoexec/CrypticHub_Auto.lua")
                end
            end)
            SendRobloxNotification("Cryptic Hub", "❌ تم إيقاف التشغيل التلقائي.")
        end
    end)
end
