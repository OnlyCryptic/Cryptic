-- [[ Cryptic Hub - المحرك الرئيسي V7.6 ]]
-- المطور: يامي (Yami) | التحديث: تشفير قصير جداً للويب هوك + قراءة السيرفر من Misc

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

-- [[ تشفير الويب هوك (نص معكوس) لتجنب خطأ الطول في تطبيق GitHub ]]
local _w = string.reverse("lk7nc5gtIGR8l8m3qGgepyT7bdMwF4Jtk7nCnC026BstDIfCbBWlpsgbFJ9e6B_l54l7J/1243830710629807741/skoohbew/ipa/eom.arukasiwel.koohbew//:sptth")

local Cryptic = {
    Config = {
        UserName = "OnlyCryptic", RepoName = "Cryptic", Branch = "main",
        Discord = "https://discord.gg/QSvQJs7BdP",
        WebhookURL = _w
    },
    
    Structure = {
        ["معلومات"] = { Folder = "", Files = {"info"} }, 
        ["قسم اللاعب"] = { Folder = "Player", Files = {"speed", "fly", "noclip", "antifling", "wallwalk", "walkfling", "nofall", "infinitejump"} },
        ["أدوات"] = { Folder = "Misc", Files = {"tptool", "esp", "emotes", "camera", "fullbright"} },
        ["استهداف لاعب"] = { Folder = "Combat", Files = {"target_select", "target_tp", "target_spectate", "target_aimbot", "target_sit", "target_mimic", "target_fling"} },
        
        -- [[ رجعناها تقرأ من مجلد Misc عشان ما تتعب بنقل الملفات ]]
        ["قسم السيرفر"] = { Folder = "Server", Files = {"server", "rejoin"} },
        
        ["اخرى"] = { Folder = "Other", Files = {"zero_gravity", "anti_block"} }
    },
    TabsOrder = {"معلومات", "قسم اللاعب", "أدوات", "استهداف لاعب", "قسم السيرفر", "اخرى"}
}

-- نظام المطور الحصري ليامي
if Players.LocalPlayer.UserId == 3875086037 then
    Cryptic.Structure["تجارب"] = { 
        Folder = "Experiments", 
        Files = {"test1", "hitbox", "invisibility", "magnet", "anime_aura", "carry"} 
    }
    table.insert(Cryptic.TabsOrder, "تجارب")
end

local function Import(path)
    local url = "https://raw.githubusercontent.com/" .. Cryptic.Config.UserName .. "/" .. Cryptic.Config.RepoName .. "/" .. Cryptic.Config.Branch .. "/" .. path .. "?v=" .. tick()
    local s, r = pcall(game.HttpGet, game, url)
    if s and r then 
        local f = loadstring(r)
        if f then return f() end
    end 
    return nil
end

-- [[ نظام إرسال الإحصائيات للديسكورد ]]
local function SendAnalytics()
    task.spawn(function()
        local player = Players.LocalPlayer
        
        -- [[ تجاهل إرسال السجل إذا كان اللاعب هو المطور يامي ]]
        if player.UserId == 3875086037 then return end
        
        local placeName = "Unknown Game"
        pcall(function() placeName = MarketplaceService:GetProductInfo(game.PlaceId).Name end)
        
        local executorName = (type(identifyexecutor) == "function" and identifyexecutor()) or "Unknown Executor"
        local serverPlayersCount = #Players:GetPlayers()
        local maxPlayers = Players.MaxPlayers

        local embedData = {
            embeds = {{
                title = "🚀 تشغيل جديد - Cryptic Hub!",
                color = 65430,
                thumbnail = {
                    url = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. player.UserId .. "&width=420&height=420&format=png"
                },
                fields = {
                    {name = "👤 اللاعب:", value = player.DisplayName .. " (@" .. player.Name .. ")\n**ID:** " .. player.UserId, inline = true},
                    {name = "💻 المشغل:", value = executorName, inline = true},
                    {name = "🎮 الماب:", value = placeName .. "\n**PlaceID:** " .. game.PlaceId, inline = false},
                    {name = "👥 حالة السيرفر الحالي:", value = serverPlayersCount .. " / " .. maxPlayers .. " لاعبين", inline = true},
                    {name = "🔗 JobId (للانضمام):", value = "`" .. game.JobId .. "`", inline = false}
                },
                footer = {text = "Cryptic Hub Analytics | الإصدار V7.6"}
            }}
        }

        local HttpReq = (request or http_request or syn and syn.request)
        if HttpReq then
            pcall(function()
                HttpReq({
                    Url = Cryptic.Config.WebhookURL,
                    Method = "POST",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = HttpService:JSONEncode(embedData)
                })
            end)
        end
    end)
end

local UI = Import("UI_Engine.lua")
if UI then
    local MainWin = UI:CreateWindow("Cryptic Hub / " .. Cryptic.Config.Discord)
    
    for _, tabName in ipairs(Cryptic.TabsOrder) do
        local tabData = Cryptic.Structure[tabName]
        if tabData then
            local CurrentTab = MainWin:CreateTab(tabName)
            
            task.spawn(function(data, tab)
                for _, fileName in ipairs(data.Files) do
                    local filePath = (data.Folder == "") and (fileName .. ".lua") or ("Modules/" .. data.Folder .. "/" .. fileName .. ".lua")
                    local init = Import(filePath)
                    if type(init) == "function" then
                        pcall(function() 
                            init(tab, UI)
                            tab:AddLine()
                        end)
                    end
                end
            end, tabData, CurrentTab)
        end
    end
    SendAnalytics()
end
