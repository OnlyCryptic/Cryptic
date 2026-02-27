-- [[ Cryptic Hub - المحرك الرئيسي النهائي ]]
-- المطور: أروى (Arwa)
-- هذا الملف هو المسؤول عن الربط بين GitHub والواجهة ونظام المراقبة

local Cryptic = {
    -- 1. إعدادات المستودع والويب هوك
    Config = {
        UserName = "OnlyCryptic", 
        RepoName = "Cryptic",  
        Branch   = "main",
        -- رابط الويب هوك الخاص بكِ للمراقبة
        Webhook  = "https://discord.com/api/webhooks/1476744644183199834/w8CnCw7ehZom4b0MXkb0L4bCd9fy0sQs7LX4HZb4JfFUrqPqykwagx3hybF0UaY8ATr2"
    },
    
    -- 2. هيكل الأقسام (تأكدي من مطابقة أسماء الملفات في GitHub)
    Structure = {
        ["قسم اللاعب"] = {
            Folder = "Player",
            Files  = {"speed", "fly", "noclip"} 
        },
        ["قسم لاعبين"] = {
            Folder = "Combat",
            Files  = {"esp"} 
        },
        ["قسم السيرفر"] = {
            Folder = "Misc",
            Files  = {"server", "rejoin"}
        }
    }
}

local lp = game.Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- وظيفة إرسال التقارير المنظمة إلى ديسكورد
local function SendLog(action, details)
    local gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
    local data = {
        ["embeds"] = {{
            ["title"] = "🚀 Cryptic Hub | تقرير نشاط جديد",
            ["color"] = 0x00FF96, -- لون نيون أخضر
            ["fields"] = {
                {["name"] = "الحدث", ["value"] = action, ["inline"] = true},
                {["name"] = "التفاصيل", ["value"] = details or "لا توجد تفاصيل", ["inline"] = true},
                {["name"] = "اسم اللاعب", ["value"] = lp.Name, ["inline"] = true},
                {["name"] = "المعرف (ID)", ["value"] = tostring(lp.UserId), ["inline"] = true},
                {["name"] = "اللعبة الحالية", ["value"] = gameName, ["inline"] = false},
                {["name"] = "رمز السيرفر (JobId)", ["value"] = "```" .. game.JobId .. "```", ["inline"] = false}
            },
            ["footer"] = {["text"] = "نظام مراقبة كربتك هب - Arwa Edition"}
        }}
    }
    
    pcall(function()
        local json = HttpService:JSONEncode(data)
        -- استخدام دالة request المتوفرة في معظم الـ Executors الحديثة
        if request then
            request({
                Url = Cryptic.Config.Webhook,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = json
            })
        elseif syn and syn.request then
            syn.request({
                Url = Cryptic.Config.Webhook,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = json
            })
        else
            game:HttpPost(Cryptic.Config.Webhook, json)
        end
    end)
end

-- بناء رابط الـ Raw لجلب الملفات
local RawURL = "https://raw.githubusercontent.com/" .. Cryptic.Config.UserName .. "/" .. Cryptic.Config.RepoName .. "/" .. Cryptic.Config.Branch .. "/"

local function Import(path)
    local success, result = pcall(function() return game:HttpGet(RawURL .. path) end)
    if success and result then
        local func, err = loadstring(result)
        if func then 
            return func() 
        else 
            warn("❌ خطأ في كود الملف: " .. path .. " | " .. tostring(err))
        end
    else
        warn("❌ تعذر تحميل الملف: " .. path)
    end
    return nil
end

-- ==========================================
-- بداية تنفيذ السكربت
-- ==========================================

print("🚀 جاري تشغيل Cryptic Hub... أهلاً بك يا أروى.")

-- إرسال تقرير التشغيل فوراً
SendLog("تشغيل السكربت", "قام المستخدم بفتح الواجهة بنجاح")

-- 1. تحميل محرك الواجهة المطور (UI_Engine.lua)
local UI = Import("UI_Engine.lua")

if UI then
    -- تمرير وظيفة المراقبة للمحرك لكي يستخدمها في الأزرار والتبديلات
    UI.Logger = SendLog 
    
    -- 2. إنشاء النافذة الرئيسية
    local MainWin = UI:CreateWindow("Cryptic Hub | كربتك")

    -- 3. بناء الأقسام وتحميل الميزات تلقائياً
    for tabName, info in pairs(Cryptic.Structure) do
        -- إنشاء Tab جديد في القائمة الجانبية
        local CurrentTab = MainWin:CreateTab(tabName)
        
        for _, fileName in pairs(info.Files) do
            local filePath = "Modules/" .. info.Folder .. "/" .. fileName .. ".lua"
            
            -- تحميل الميزة (مثل speed, fly, esp, server) وتمرير الصفحة لها
            pcall(function()
                local featureInit = Import(filePath)
                if type(featureInit) == "function" then
                    featureInit(CurrentTab, UI) 
                end
            end)
        end
    end

    UI:Notify("تم تحميل جميع الأقسام والميزات بنجاح!")
else
    warn("❌ فشل تحميل UI_Engine.lua. تأكد من صحة الرابط والملف على GitHub.")
end
