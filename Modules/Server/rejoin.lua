-- [[ Cryptic Hub - ميزة التنقل بين السيرفرات ]]
-- الملف: rejoin.lua

return function(Tab, UI)
    local TeleportService = game:GetService("TeleportService")
    local HttpService = game:GetService("HttpService")
    local player = game.Players.LocalPlayer

    -- زر إعادة الدخول لنفس السيرفر
    Tab:AddButton("إعادة دخول السيرفر (Rejoin)", function()
        UI:Notify("جاري إعادة الاتصال بالسيرفر الحالي...")
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
    end)

    -- زر البحث عن سيرفر جديد (Server Hop)
    Tab:AddButton("تغيير السيرفر", function()
        UI:Notify("جاري البحث عن سيرفر جديد...")
        pcall(function()
            local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data
            for _, s in pairs(servers) do
                if s.id ~= game.JobId and s.playing < s.maxPlayers then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, player)
                    break
                end
            end
        end)
    end)
end
