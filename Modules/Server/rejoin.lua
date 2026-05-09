-- [[ Cryptic Hub - ميزة التنقل بين السيرفرات ]]
-- المطور: يامي (Yami) | التحديث: Server Hop ذكي وقوي مع دعم جميع المشغلات

return function(Tab, UI)
    local TeleportService = game:GetService("TeleportService")
    local HttpService = game:GetService("HttpService")
    local StarterGui = game:GetService("StarterGui")
    local player = game.Players.LocalPlayer

    -- نظام إشعارات روبلوكس المستقل
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
        SendRobloxNotification("Cryptic Hub", "⏳ جاري إعادة الاتصال...")
        task.wait(0.5)
        pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
        end)
    end)

    -- 2. تغيير السيرفر (Server Hop)
    Tab:AddButton("تغيير السيرفر / Server Hop", function()
        SendRobloxNotification("Cryptic Hub", "🔍 جاري البحث عن سيرفر جديد...")
        
        task.spawn(function()
            local validServers = {}
            local success, _ = pcall(function()
                local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"
                local responseText = ""
                
                -- [[ استخدام دوال المشغلات القوية لتخطي حظر روبلوكس ]]
                local HttpReq = (request or http_request or syn and syn.request)
                if HttpReq then
                    local res = HttpReq({Url = url, Method = "GET"})
                    if res and res.Body then responseText = res.Body end
                else
                    -- الطريقة البديلة إذا المشغل ضعيف
                    responseText = game:HttpGet(url)
                end

                if responseText ~= "" then
                    local data = HttpService:JSONDecode(responseText)
                    if data and data.data then
                        for _, srv in ipairs(data.data) do
                            -- [[ الفلترة الذكية ]]
                            -- يجب أن لا يكون السيرفر الحالي، وأن يكون فيه مكانين فارغين على الأقل لضمان الدخول
                            if type(srv) == "table" and srv.id ~= game.JobId and tonumber(srv.playing) and tonumber(srv.maxPlayers) then
                                if srv.playing < (srv.maxPlayers - 1) then
                                    table.insert(validServers, srv.id)
                                end
                            end
                        end
                    end
                end
            end)

            if success and #validServers > 0 then
                -- اختيار سيرفر عشوائي من القائمة النظيفة
                local randomServer = validServers[math.random(1, #validServers)]
                SendRobloxNotification("Cryptic Hub", "🚀 تم إيجاد سيرفر! جاري الانتقال...")
                task.wait(0.5)
                TeleportService:TeleportToPlaceInstance(game.PlaceId, randomServer, player)
            elseif success and #validServers == 0 then
                SendRobloxNotification("Cryptic Hub", "⚠️ لم يتم العثور على سيرفرات أخرى متاحة!")
            else
                SendRobloxNotification("Cryptic Hub", "❌ فشل البحث! قد يكون المشغل لا يدعم جلب السيرفرات.")
            end
        end)
    end)
end
