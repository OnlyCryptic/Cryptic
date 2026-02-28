-- [[ Arwa Hub - المحرك الرئيسي V4.1 ]]
-- المطور: Arwa | التعديل: إضافة قسم الخدع في نهاية القائمة

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
        ["أدوات"] = { Folder = "Misc", Files = {"tptool", "emotes", "esp", "camera", "shiftlock"} },
        
        ["استهداف لاعب"] = { 
            Folder = "Combat", 
            Files = {"target_select", "target_spectate", "target_tp", "target_aimbot", "target_sit", "target_mimic", "target_fling"} 
        },
        
        ["قسم السيرفر"] = { Folder = "Misc", Files = {"server", "rejoin"} },

        -- الخانة الجديدة باسم "خدع" وفيها تكبير الرؤوس
        ["خدع"] = { Folder = "Combat", Files = {"hitbox"} }
    },

    -- الترتيب الجديد: "خدع" أصبحت آخر خانة
    TabsOrder = {"معلومات", "قسم اللاعب", "أدوات", "استهداف لاعب", "قسم السيرفر", "خدع"}
}

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

-- وظيفة إرسال السجل (Webhook)
local function SendWebhookLog()
    task.spawn(function()
        local fullWebhook = "https://discord.com/api/webhooks/" .. Cryptic.Config.WebID .. "/" .. Cryptic.Config.WebToken
        if Cryptic.Config.WebID == "" then return end
        local executor = (identifyexecutor and identifyexecutor()) or "Unknown Mobile"
        local gameName = "Roblox Game"
        pcall(function() gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name end)
        
        local data = {
            ["embeds"] = {{
                ["title"] = "🚀 Arwa Hub - تشغيل جديد!",
                ["description"] = "تم تشغيل السكربت بنجاح مع قائمة الخدع الجديدة.",
                ["color"] = 65430,
                ["fields"] = {
                    {["name"] = "👤 اللاعب:", ["value"] = lp.DisplayName .. " (@" .. lp.Name .. ")", ["inline"] = true},
                    {["name"] = "🎮 الماب:", ["value"] = gameName, ["inline"] = true}
                },
                ["footer"] = {["text"] = "Arwa Analytics | " .. os.date("%Y/%m/%d")}
            }}
        }
        
        local requestFunc = request or http_request or (http and http.request)
        if requestFunc then pcall(function() requestFunc({Url = fullWebhook, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode(data)}) end) end
    end)
end

-- وظيفة تحميل الملفات (مع كاسر الكاش لضمان التحديث)
local function Import(path)
    local cacheBuster = "?v=" .. math.random(1, 1000000)
    local url = "https://raw.githubusercontent.com/" .. Cryptic.Config.UserName .. "/" .. Cryptic.Config.RepoName .. "/" .. Cryptic.Config.Branch .. "/" .. path .. cacheBuster
    local s, r = pcall(game.HttpGet, game, url)
    if s and r then 
        local f = loadstring(r)
        if f then return f() end 
    end 
    return nil
end

-- تشغيل الواجهة
local UI = Import("UI_Engine.lua")
if UI then
    local MainWin = UI:CreateWindow("Arwa Hub | أروى")
    
    for _, tabName in ipairs(Cryptic.TabsOrder) do
        local info = Cryptic.Structure[tabName]
        if info then
            local CurrentTab = MainWin:CreateTab(tabName)
            for _, fileName in ipairs(info.Files) do
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
    UI:Notify("✅ أهلاً بكِ في Arwa Hub! تم ترتيب القائمة بنجاح")
end
