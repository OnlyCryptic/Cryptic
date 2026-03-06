-- [[ Cryptic Hub - المحرك الرئيسي V7.7 ]]
-- المطور: أروى (Arwa) | التحديث: استثناء المطور من السجلات + حماية من تكرار تشغيل الواجهة

-- [[ حماية السكربت من التكرار (Anti-Double Execute) ]]
if getgenv().CrypticHub_Loaded then 
    return 
end
getgenv().CrypticHub_Loaded = true

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

local Cryptic = {
    Config = {
        UserName = "OnlyCryptic", RepoName = "Cryptic", Branch = "main",
        Discord = "https://discord.gg/QSvQJs7BdP",
        WebhookURL = "https://webhook.lewisakura.moe/api/webhooks/1477089260170383421/J7l45l_B6e9JFbgsplWBbCfIDtsB620nCn7ktJ4FwMdb7TypegGq3m8l8RGItg5cn7kl"
    },

    Structure = {  
        ["معلومات / info"] = { Folder = "", Files = {"info"} },   
        ["قسم اللاعب / player"] = { Folder = "Player", Files = {"speed", "fly", "noclip", "antifling", "wallwalk", "walkfling", "nofall", "infinitejump"} },  
        ["أدوات / tools"] = { Folder = "Misc", Files = {"tptool", "auto_tool", "esp", "shiftlock", "emotes", "camera", "fullbright"} },  
        ["استهداف لاعب / players"] = { Folder = "Combat", Files = {"target_select", "target_tp", "target_spectate", "target_aimbot", "target_sit", "target_mimic", "target_fling", "carry"} },  
        ["قسم السيرفر / server"] = { Folder = "Server", Files = {"server", "rejoin", "join_id"} },  
        ["اخرى / Other"] = { Folder = "Other", Files = {"zero_gravity", "anti_block", "block_surfer", "hm"} }  
    },  
    TabsOrder = {"معلومات / info", "قسم اللاعب / player", "أدوات / tools", "استهداف لاعب / players", "قسم السيرفر / server", "اخرى / Other"}
}

-- نظام المطور الحصري
if Players.LocalPlayer.UserId == 3875086037 then
    Cryptic.Structure["تجارب"] = {
        Folder = "Experiments",
        Files = {"owner_only"} 
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
    -- التعديل هنا: منع إرسال السجلات إذا كان اللاعب هو المطور
    if Players.LocalPlayer.UserId == 3875086037 then return end

    task.spawn(function()
        local player = Players.LocalPlayer
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
                footer = {text = "Cryptic Hub Analytics | الإصدار V7.7"}  
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
              
            task.spawn(function(data, tab, nameOfTab)  
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
                
                -- [[ أزرار الحفظ الفعلية ]]
                if nameOfTab == "معلومات / info" then
                    tab:AddButton("💾 حفظ الإعدادات / Save Config", function()
                        pcall(function()
                            UI:SaveConfig()
                        end)
                    end)

                    tab:AddButton("🔄 مسح اعدادات محفوضه", function()
                        pcall(function()
                            UI:ResetConfig()
                        end)
                    end)
                end
                
            end, tabData, CurrentTab, tabName)  
        end  
    end  
    SendAnalytics()
end
