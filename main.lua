-- [[ Cryptic Hub - المحرك الرئيسي المطور ]]
-- المطور: يامي (@d8u_)
-- تاريخ التحديث: 2026/02/27

local Cryptic = {
    -- 1. إعدادات المستودع والروابط
    Config = {
        UserName = "OnlyCryptic", 
        RepoName = "Cryptic",  
        Branch   = "main",
        Discord  = "https://discord.gg/QSvQJs7BdP",
        Webhook  = "https://discord.com/api/webhooks/1476744644183199834/w8CnCw7ehZom4b0MXkb0L4bCd9fy0sQs7LX4HZb4JfFUrqPqykwagx3hybF0UaY8ATr2"
    },
    
    -- 2. هيكل المجلدات والملفات
    Structure = {
        ["معلومات"] = { Folder = "Misc", Files = {"info"} },
        ["قسم اللاعب"] = { Folder = "Player", Files = {"speed", "fly", "noclip"} },
        ["أدوات"] = { Folder = "Misc", Files = {"tptool"} },
        ["قسم لاعبين"] = { Folder = "Combat", Files = {"esp", "spectate"} },
        ["قسم السيرفر"] = { Folder = "Misc", Files = {"server", "rejoin"} }
    },

    -- 3. نظام الترتيب الثابت لضمان ظهور "معلومات" أولاً والفتح عليها
    TabsOrder = {"معلومات", "قسم اللاعب", "أدوات", "قسم لاعبين", "قسم السيرفر"}
}

local lp = game.Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- وظيفة إرسال التقارير المنظمة إلى ديسكورد
local function SendLog(action, details)
    local gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
    local data = {
        ["embeds"] = {{
            ["title"] = "🚀 Arwa Hub | تقرير نشاط جديد",
            ["color"] = 0x00FF96, -- لون نيون أخضر
            ["fields"] = {
                {["name"] = "الحدث", ["value"] = action, ["inline"] = true},
                {["name"] = "التفاصيل", ["value"] = details or "لا توجد تفاصيل", ["inline"] = true},
                {["name"] = "اسم اللاعب", ["value"] = lp.Name, ["inline"] = true},
                {["name"] = "المعرف (ID)", ["value"] = tostring(lp.UserId), ["inline"] = true},
                {["name"] = "اللعبة", ["value"] = gameName, ["inline"] = false},
                {["name"] = "رمز السيرفر (JobId)", ["value"] = "```" .. game.JobId .. "```", ["inline"] = false}
            },
            ["footer"] = {["text"] = "نظام مراقبة Arwa Hub - 2026/02/27"}
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

-- بناء روابط الـ Raw لجلب الملفات من GitHub
local RawURL = "https://raw.githubusercontent.com/" .. Cryptic.Config.UserName .. "/" .. Cryptic.Config.RepoName .. "/" .. Cryptic.Config.Branch .. "/"

local function Import(path)
    local success, result = pcall(function() return game:HttpGet(RawURL .. path) end)
    if success and result then
        local func = loadstring(result)
        if func then return func() end
    end
    return nil
end

-- ==========================================
-- تشغيل العمليات التلقائية والتحميل
-- ==========================================

-- 1. نسخ رابط الديسكورد تلقائياً فور التشغيل
pcall(function() 
    setclipboard(Cryptic.Config.Discord) 
end)

-- 2. إرسال تقرير التشغيل فوراً
SendLog("تشغيل السكربت", "قام المستخدم بفتح الواجهة بنجاح")

-- 3. تحميل محرك الواجهة وتشغيل الأقسام بالترتيب
local UI = Import("UI_Engine.lua")

if UI then
    UI.Logger = SendLog -- تمرير وظيفة المراقبة للمحرك
    local MainWin = UI:CreateWindow("Cryptic Hub | كربتك")

    -- استخدام ipairs لضمان الالتزام بالترتيب الثابت لظهور "معلومات" أولاً
    for _, tabName in ipairs(Cryptic.TabsOrder) do
        local info = Cryptic.Structure[tabName]
        if info then
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
    end

    UI:Notify("تم تحميل Arwa Hub بنجاح! تم نسخ الرابط.")
else
    warn("❌ فشل تحميل UI_Engine.lua. تأكدي من رفعه في GitHub.")
end
