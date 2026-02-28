-- [[ Arwa Hub - المحرك الرئيسي المطور V4.0 ]]
-- المطور: Arwa | الإصدار: الشامل والمضاد للأخطاء

local Cryptic = {
    Config = {
        UserName = "OnlyCryptic", RepoName = "Cryptic", Branch = "main",
        Discord = "https://discord.gg/QSvQJs7BdP",
        WebID = "1477089260170383421",
        WebToken = "J7l45l_B6e9JFbgsplWBbCfIDtsB620nCn7ktJ4FwMdb7TypegGq3m8l8RGItg5cn7kl"
    },
    
    Structure = {
        ["معلومات"] = { Folder = "Misc", Files = {"info"} },
        ["قسم اللاعب"] = { Folder = "Player", Files = {"speed", "fly", "noclip", "antifling", "wallwalk", "walkfling"} },
        
        -- القسم الجديد الذي طلبته
        ["تعديل الخصوم"] = { Folder = "Combat", Files = {"hitbox"} },
        
        ["أدوات"] = { Folder = "Misc", Files = {"tptool", "emotes", "esp", "camera", "shiftlock"} },
        
        ["استهداف لاعب"] = { 
            Folder = "Combat", 
            Files = {"target_select", "target_spectate", "target_tp", "target_aimbot", "target_sit", "target_mimic", "target_fling"} 
        },
        
        ["قسم السيرفر"] = { Folder = "Misc", Files = {"server", "rejoin"} }
    },

    -- ترتيب الأقسام في القائمة
    TabsOrder = {"معلومات", "قسم اللاعب", "تعديل الخصوم", "أدوات", "استهداف لاعب", "قسم السيرفر"}
}

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

-- وظيفة إرسال السجل للديسكورد (Webhook)
local function SendWebhookLog()
    task.spawn(function()
        local fullWebhook = "https://discord.com/api/webhooks/" .. Cryptic.Config.WebID .. "/" .. Cryptic.Config.WebToken
        if Cryptic.Config.WebID == "" then return end
        local executor = (identifyexecutor and identifyexecutor()) or "Unknown Mobile"
        local gameName = "Roblox Game"
        pcall(function() gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name end)
        
        local data = {
            ["embeds"] = {{
                ["title"] = "🚀 Arwa Hub - تم التشغيل!",
                ["color"] = 65430, -- اللون الأخضر
                ["fields"] = {
                    {["name"] = "👤 اللاعب:", ["value"] = lp.DisplayName .. " (@" .. lp.Name .. ")", ["inline"] = true},
                    {["name"] = "🎮 الماب:", ["value"] = gameName, ["inline"] = true},
                    {["name"] = "💻 المشغل:", ["value"] = executor, ["inline"] = true}
                },
                ["footer"] = {["text"] = "Arwa Analytics | " .. os.date("%Y/%m/%d")}
            }}
        }
        
        local requestFunc = request or http_request or (http and http.request)
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

-- وظيفة تحميل الملفات مع كاسر الكاش لضمان التحديث الفوري
local function Import(path)
    -- إضافة رقم عشوائي في نهاية الرابط لضمان عدم تحميل نسخة قديمة من ذاكرة الجوال
    local cacheBuster = "?v=" .. math.random(1, 1000000)
    local url = "https://raw.githubusercontent.com/" .. Cryptic.Config.UserName .. "/" .. Cryptic.Config.RepoName .. "/" .. Cryptic.Config.Branch .. "/" .. path .. cacheBuster
    
    local s, r = pcall(game.HttpGet, game, url)
    if s and r then 
        local f, err = loadstring(r)
        if f then return f() end 
    end 
    return nil
end

-- تشغيل الواجهة وتحميل الموديلات
local UI = Import("UI_Engine.lua")
if UI then
    local MainWin = UI:CreateWindow("Arwa Hub | أروى")
    
    for _, tabName in ipairs(Cryptic.TabsOrder) do
        local info = Cryptic.Structure[tabName]
        if info then
            local CurrentTab = MainWin:CreateTab(tabName)
            for _, fileName in ipairs(info.Files) do
                -- استخدام pcall لضمان عدم توقف السكربت عند وجود خطأ في ملف واحد
                pcall(function()
                    local filePath = "Modules/" .. info.Folder .. "/" .. fileName .. ".lua"
                    local init = Import(filePath)
                    if type(init) == "function" then
                        init(CurrentTab, UI)
                        CurrentTab:AddLine()
                    end
                end)
            end
        end
    end
    
    SendWebhookLog()
    UI:Notify("✅ تم تحميل Arwa Hub V4.0 بنجاح!")
end
