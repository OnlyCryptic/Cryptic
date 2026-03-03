-- [[ Cryptic Hub - المحرك الرئيسي V7.5 ]]
-- المطور: يامي (Yami) | التحديث: تشفير الويب هوك + إخفاء المطور من السجلات

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

-- [[ تشفير الويب هوك لمنع سرقته من داخل الكود ]]
local _w = {"h","t","t","p","s",":","/","/","w","e","b","h","o","o","k",".","l","e","w","i","s","a","k","u","r","a",".","m","o","e","/","a","p","i","/","w","e","b","h","o","o","k","s","/","1","4","7","7","0","8","9","2","6","0","1","7","0","3","8","3","4","2","1","/","J","7","l","4","5","l","_","B","6","e","9","J","F","b","g","s","p","l","W","B","b","C","f","I","D","t","s","B","6","2","0","n","C","n","7","k","t","J","4","F","w","M","d","b","7","T","y","p","e","g","G","q","3","m","8","l","8","R","G","I","t","g","5","c","n","7","k","l"}

local Cryptic = {
    Config = {
        UserName = "OnlyCryptic", RepoName = "Cryptic", Branch = "main",
        Discord = "https://discord.gg/QSvQJs7BdP",
        WebhookURL = table.concat(_w, "") -- يتم تجميع الرابط في الخلفية بدون ما ينكشف
    },
    
    Structure = {
        ["معلومات"] = { Folder = "", Files = {"info"} }, 
        ["قسم اللاعب"] = { Folder = "Player", Files = {"speed", "fly", "noclip", "antifling", "wallwalk", "walkfling", "nofall", "infinitejump"} },
        ["أدوات"] = { Folder = "Misc", Files = {"tptool", "esp", "emotes", "camera", "fullbright"} },
        ["استهداف لاعب"] = { Folder = "Combat", Files = {"target_select", "target_tp", "target_spectate", "target_aimbot", "target_sit", "target_mimic", "target_fling"} },
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
                footer = {text = "Cryptic Hub Analytics | الإصدار V7.5"}
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
