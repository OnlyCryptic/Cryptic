-- [[ Arwa Hub - المحرك الرئيسي V4.3 ]]
-- المطور: Arwa | الإصدار: المصلح للإشعارات والترتيب النهائي

local Cryptic = {
    Config = {
        UserName = "OnlyCryptic", RepoName = "Cryptic", Branch = "main",
        Discord = "https://discord.gg/QSvQJs7BdP",
        WebID = "1477089260170383421",
        WebToken = "J7l45l_B6e9JFbgsplWBbCfIDtsB620nCn7ktJ4FwMdb7TypegGq3m8l8RGItg5cn7kl"
    },
    
    Structure = {
        ["معلومات"] = { Folder = "Misc", Files = {"info"} },
        ["قسم اللاعب"] = { Folder = "Player", Files = {"speed", "fly", "noclip", "antifling", "wallwalk"} },
        ["أدوات"] = { Folder = "Misc", Files = {"tptool", "emotes", "esp", "camera", "shiftlock"} },
        
        -- ترتيب الأزرار: الانتقال فوق المراقبة
        ["استهداف لاعب"] = { 
            Folder = "Combat", 
            Files = {
                "target_select",
                "target_tp", -- الانتقال أولاً
                "target_spectate", -- المراقبة ثانياً
                "target_aimbot",
                "target_sit",
                "target_mimic",
                "target_fling"
            } 
        },
        
        ["قسم السيرفر"] = { Folder = "Misc", Files = {"server", "rejoin"} },
        
                -- قسم "خدع" في النهاية
        ["خدع"] = { 
            Folder = "Combat", 
            Files = {"hitbox", "anime_aura"} -- أضفنا الهالة هنا
        }

    -- الترتيب النهائي للأقسام
    TabsOrder = {"معلومات", "قسم اللاعب", "أدوات", "استهداف لاعب", "قسم السيرفر", "خدع"}
}

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

-- دالة إرسال السجل
local function SendWebhookLog()
    task.spawn(function()
        local fullWebhook = "https://discord.com/api/webhooks/" .. Cryptic.Config.WebID .. "/" .. Cryptic.Config.WebToken
        if Cryptic.Config.WebID == "" then return end
        local requestFunc = request or http_request or (http and http.request)
        if requestFunc then 
            pcall(function() 
                requestFunc({
                    Url = fullWebhook, 
                    Method = "POST", 
                    Headers = {["Content-Type"] = "application/json"}, 
                    Body = HttpService:JSONEncode({
                        ["embeds"] = {{
                            ["title"] = "🚀 Arwa Hub - تشغيل جديد!",
                            ["color"] = 65430,
                            ["fields"] = {
                                {["name"] = "👤 اللاعب:", ["value"] = lp.DisplayName .. " (@" .. lp.Name .. ")", ["inline"] = true}
                            }
                        }}
                    })
                }) 
            end) 
        end
    end)
end

-- وظيفة تحميل الملفات
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

-- نظام الإشعارات المطور (الإصلاح الجذري)
local function ArwaNotify(msg)
    task.spawn(function()
        -- 1. محاولة الإرسال عبر مكتبة الواجهة
        local success = pcall(function()
            if _G.ArwaUI and _G.ArwaUI.Notify then
                _G.ArwaUI:Notify(msg)
            end
        end)
        
        -- 2. بديل نظام روبلوكس الرسمي إذا فشلت المكتبة
        if not success or not _G.ArwaUI then
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Arwa Hub",
                Text = msg,
                Duration = 5
            })
        end
    end)
end

-- تشغيل الواجهة
local UI = Import("UI_Engine.lua")
if UI then
    _G.ArwaUI = UI -- تخزين الواجهة عالمياً لضمان الوصول للإشعارات
    local MainWin = UI:CreateWindow("Cryptic hub / https://discord.gg/QSvQJs7BdP ")
    
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
    task.wait(1) -- انتظار بسيط لضمان تحميل الواجهة قبل إرسال الإشعار
    ArwaNotify("✅ أهلاً بكِ يا أروى! تم التحميل بنجاح")
end
