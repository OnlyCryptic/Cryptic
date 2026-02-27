-- [[ Cryptic Hub - المحرك الرئيسي المطور ]]
-- المطور: يامي (@d8u_)
-- النسخة: 1.5.0 (نسخة الهاتف)

local Cryptic = {
    -- 1. الإعدادات العامة والروابط
    Config = {
        UserName = "OnlyCryptic", 
        RepoName = "Cryptic",  
        Branch   = "main",
        Discord  = "https://discord.gg/QSvQJs7BdP",
        -- رابط الويب هوك الخاص بكِ للمراقبة
        Webhook  = "https://discord.com/api/webhooks/1476744644183199834/w8CnCw7ehZom4b0MXkb0L4bCd9fy0sQs7LX4HZb4JfFUrqPqykwagx3hybF0UaY8ATr2"
    },
    
    -- 2. هيكل الأقسام (تم ترتيبها لفتح المعلومات أولاً)
    Structure = {
        ["قسم المعلومات"] = { 
            Folder = "Misc",   
            Files = {"info"} 
        },
        ["قسم اللاعب"] = { 
            Folder = "Player", 
            Files = {"speed", "fly", "noclip"} 
        },
        ["قسم لاعبين"] = { 
            Folder = "Combat", 
            Files = {"esp"} 
        },
        ["قسم السيرفر"] = { 
            Folder = "Misc",   
            Files = {"server", "rejoin"} 
        }
    }
}

local lp = game.Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- وظيفة إرسال التقارير لديسكورد
local function SendLog(action, details)
    local gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
    local data = {
        ["embeds"] = {{
            ["title"] = "🚀 Cryptic Hub | تقرير نشاط",
            ["color"] = 0x00FF96,
            ["fields"] = {
                {["name"] = "الحدث", ["value"] = action, ["inline"] = true},
                {["name"] = "التفاصيل", ["value"] = details or "N/A", ["inline"] = true},
                {["name"] = "اسم اللاعب", ["value"] = lp.Name, ["inline"] = true},
                {["name"] = "المعرف (ID)", ["value"] = tostring(lp.UserId), ["inline"] = true},
                {["name"] = "اللعبة", ["value"] = gameName, ["inline"] = false},
                {["name"] = "رمز السيرفر", ["value"] = "```" .. game.JobId .. "```", ["inline"] = false}
            },
            ["footer"] = {["text"] = "نظام مراقبة كربتك هب"}
        }}
    }
    
    pcall(function()
        local json = HttpService:JSONEncode(data)
        if request then
            request({Url = Cryptic.Config.Webhook, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = json})
        else
            game:HttpPost(Cryptic.Config.Webhook, json)
        end
    end)
end

-- بناء روابط الـ Raw من GitHub
local RawURL = "https://raw.githubusercontent.com/" .. Cryptic.Config.UserName .. "/" .. Cryptic.Config.RepoName .. "/" .. Cryptic.Config.Branch .. "/"

local function Import(path)
    local success, result = pcall(function() return game:HttpGet(RawURL .. path) end)
    if success and result then
        local func, err = loadstring(result)
        if func then return func() end
    end
    return nil
end

-- ==========================================
-- تشغيل العمليات التلقائية
-- ==========================================

-- 1. نسخ رابط الديسكورد تلقائياً فور التشغيل
pcall(function() 
    setclipboard(Cryptic.Config.Discord) 
end)

-- 2. إرسال تقرير تشغيل السكربت
SendLog("تشغيل السكربت", "قام المستخدم بفتح الواجهة بنجاح")

-- 3. تحميل محرك الواجهة وتشغيل الأقسام
local UI = Import("UI_Engine.lua")

if UI then
    UI.Logger = SendLog -- تمرير نظام المراقبة للواجهة
    local MainWin = UI:CreateWindow("Cryptic Hub | كربتك")

    -- تحميل الميزات بناءً على الترتيب في الجدول
    for tabName, info in pairs(Cryptic.Structure) do
        local CurrentTab = MainWin:CreateTab(tabName)
        for _, fileName in pairs(info.Files) do
            local filePath = "Modules/" .. info.Folder .. "/" .. fileName .. ".lua"
            pcall(function()
                local featureInit = Import(filePath)
                if type(featureInit) == "function" then
                    featureInit(CurrentTab, UI) 
                end
            end)
        end
    end

    UI:Notify("أهلاً بكِ يا أروى! تم نسخ الرابط وتشغيل الأقسام.")
else
    warn("❌ فشل تحميل UI_Engine.lua")
end
