-- [[ Cryptic Hub - ميزة التنقل بين السيرفرات ]]
-- المطور: يامي (Yami) | التحديث: إشعارات روبلوكس الأصلية + Server Hop ذكي

return function(Tab, UI)
    local TeleportService = game:GetService("TeleportService")
    local HttpService = game:GetService("HttpService")
    local StarterGui = game:GetService("StarterGui")
    local player = game.Players.LocalPlayer

    -- دالة إشعارات روبلوكس الأصلية (تعمل بشكل مستقل بدون تعليق)
    local function SendRobloxNotification(title, text)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = title,
                Text = text,
                Duration = 4,
            })
        end)
    end

    -- 1. إعادة الدخول (Rejoin)
    Tab:AddButton("إعادة دخول / Rejoin", function()
        SendRobloxNotification("Cryptic Hub", "⏳ جاري إعادة الاتصال بالسيرفر الحالي...")
        
        task.wait(0.5) -- انتظار بسيط جداً لضمان ظهور الإشعار قبل التجميد
        pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
        end)
    end)

    -- 2. تغيير السيرفر (Server Hop)
    Tab:AddButton("تغيير السيرفر / Server Hop", function()
        SendRobloxNotification("Cryptic Hub", "🔍 جاري البحث عن سيرفر مناسب...")
        
        task.spawn(function()
            local success, _ = pcall(function()
                -- جلب السيرفرات النشطة لتجنب السيرفرات الميتة (Desc)
                local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"
                local request = game:HttpGet(url)
                local data = HttpService:JSONDecode(request)
                
                if data and data.data then
                    local servers = data.data
                    
                    -- خلط القائمة عشوائياً عشان ما ينقلك لنفس السيرفر دائماً
                    for i = #servers, 2, -1 do
                        local j = math.random(1, i)
                        servers[i], servers[j] = servers[j], servers[i]
                    end
                    
                    for _, srv in ipairs(servers) do
                        -- التأكد أن السيرفر ليس الحالي وفيه مساحة لاعبين
                        if srv.id ~= game.JobId and srv.playing < srv.maxPlayers then
                            SendRobloxNotification("Cryptic Hub", "🚀 تم إيجاد سيرفر! جاري الانتقال...")
                            TeleportService:TeleportToPlaceInstance(game.PlaceId, srv.id, player)
                            return -- إنهاء البحث بمجرد إيجاد سيرفر
                        end
                    end
                end
            end)
            
            if not success then
                SendRobloxNotification("Cryptic Hub", "⚠️ فشل البحث، قد يكون بسبب المشغل أو الاتصال.")
            end
        end)
    end)
end
