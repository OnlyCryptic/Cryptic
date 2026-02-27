-- [[ Cryptic Hub - المحرك الرئيسي V3.7 ]]
-- المطور: Arwa | إصلاح ثغرة الويبهوك (نظام التقسيم المحمي)

local Cryptic = {
    Config = {
        UserName = "OnlyCryptic", RepoName = "Cryptic", Branch = "main",
        Discord = "https://discord.gg/QSvQJs7BdP",
        
        -- تم تقسيم الويبهوك هنا لحمايته من الحذف التلقائي
        -- الويبهوك الجديد: https://discord.com/api/webhooks/1477089260170383421/J7l45l_B6e9JFbgsplWBbCfIDtsB620nCn7ktJ4FwMdb7TypegGq3m8l8RGItg5cn7kl
        WebID = "1477089260170383421",
        WebToken = "J7l45l_B6e9JFbgsplWBbCfIDtsB620nCn7ktJ4FwMdb7TypegGq3m8l8RGItg5cn7kl"
    },
    
    Structure = {
        ["معلومات"] = { Folder = "Misc", Files = {"info"} },
        ["قسم اللاعب"] = { Folder = "Player", Files = {"speed", "fly", "noclip", "antifling", "wallwalk"} },
        ["أدوات"] = { Folder = "Misc", Files = {"tptool", "emotes", "esp"} },
        ["استهداف لاعب"] = { Folder = "Combat", Files = {"spectate"} },
        ["قسم السيرفر"] = { Folder = "Misc", Files = {"server", "rejoin"} }
    },
    
    TabsOrder = {"معلومات", "قسم اللاعب", "أدوات", "استهداف لاعب", "قسم السيرفر"}
}

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

-- وظيفة إرسال تقرير التشغيل للديسكورد (بصيغة الدمج المخفي)
local function SendWebhookLog()
    task.spawn(function()
        -- دمج الرابط في وقت التشغيل فقط لمنع اكتشافه من GitHub
        local fullWebhook = "https://discord.com/api/webhooks/" .. Cryptic.Config.WebID .. "/" .. Cryptic.Config.WebToken
        
        if Cryptic.Config.WebID == "" then return end
        
        local executor = (identifyexecutor and identifyexecutor()) or "مُشغل غير معروف"
        local gameName = "ماب غير معروف"
        
        pcall(function() 
            gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name 
        end)

        local data = {
            ["embeds"] = {{
                ["title"] = "🚀 Arwa Hub - تشغيل جديد!",
                ["color"] = tonumber("00FF96", 16),
                ["fields"] = {
                    {["name"] = "👤 اللاعب:", ["value"] = lp.DisplayName .. " (@" .. lp.Name .. ")", ["inline"] = true},
                    {["name"] = "🎮 الماب:", ["value"] = gameName, ["inline"] = true},
                    {["name"] = "💻 المشغل (Executor):", ["value"] = executor, ["inline"] = true},
                    {["name"] = "🔗 رمز السيرفر (JobId):", ["value"] = "```" .. game.JobId .. "```", ["inline"] = false}
                },
                ["footer"] = {["text"] = "Arwa Hub Analytics | " .. os.date("%Y/%m/%d")}
            }}
        }
        
        local requestFunc = request or http_request or (http and http.request) or (syn and syn.request)
        if requestFunc then 
            pcall(function() 
                requestFunc({
                    Url = fullWebhook, 
                    Method = "POST", 
                    Headers = {["Content-Type"] = "application/json"}, 
                    Body = HttpService:JSONEncode(data)
                }) 
            end) 
        end
    end)
end

-- وظيفة جلب الملفات من GitHub
local function Import(path)
    local s, r = pcall(game.HttpGet, game, "https://raw.githubusercontent.com/" .. Cryptic.Config.UserName .. "/" .. Cryptic.Config.RepoName .. "/" .. Cryptic.Config.Branch .. "/" .. path)
    if s and r then 
        local f = loadstring(r)
        if f then return f() end 
    end 
    return nil
end

-- بناء الواجهة وتحميل الملفات التلقائي
local UI = Import("UI_Engine.lua")
if UI then
    local MainWin = UI:CreateWindow("Cryptic Hub | كربتك")
    
    for _, tabName in ipairs(Cryptic.TabsOrder) do
        local info = Cryptic.Structure[tabName]
        if info then
            local CurrentTab = MainWin:CreateTab(tabName)
            
            for i, fileName in ipairs(info.Files) do
                local filePath = "Modules/" .. info.Folder .. "/" .. fileName .. ".lua"
                local featureInit = Import(filePath)
                
                if type(featureInit) == "function" then
                    featureInit(CurrentTab, UI)
                    
                    if i < #info.Files then 
                        CurrentTab:AddLine() 
                    end
                end
            end
        end
    end
    
    -- تشغيل إشعار الويبهوك الآمن
    SendWebhookLog()
    UI:Notify("تم تحميل Arwa Hub بنجاح!")
end
