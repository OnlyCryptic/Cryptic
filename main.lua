-- [[ Cryptic Hub - المحرك الرئيسي المطور V2.6 ]]
-- المطور: يامي | تاريخ التحديث: 2026/02/27
-- ميزات: نظام فواصل تلقائي بين الملفات + إصلاح السحب + ترتيب الأقسام

local Cryptic = {
    -- 1. إعدادات المستودع والروابط
    Config = {
        UserName = "OnlyCryptic", 
        RepoName = "Cryptic",  
        Branch   = "main",
        Discord  = "https://discord.gg/QSvQJs7BdP",
        Webhook  = "https://discord.com/api/webhooks/1476744644183199834/w8CnCw7ehZom4b0MXkb0L4bCd9fy0sQs7LX4HZb4JfFUrqPqykwagx3hybF0UaY8ATr2"
    },
    
    -- 2. هيكل الأقسام والملفات (تأكدي من وجود الملفات في هذه المجلدات على GitHub)
    Structure = {
        ["معلومات"] = { Folder = "Misc", Files = {"info"} },
        ["قسم اللاعب"] = { Folder = "Player", Files = {"speed", "fly", "noclip"} }, -- هذا هو القسم الذي عاد للظهور
        ["أدوات"] = { Folder = "Misc", Files = {"tptool"} },
        ["قسم لاعبين"] = { Folder = "Combat", Files = {"esp", "spectate"} },
        ["قسم السيرفر"] = { Folder = "Misc", Files = {"server", "rejoin"} }
    },

    -- 3. الترتيب الثابت لظهور الخانات (معلومات هي الأولى دائماً)
    TabsOrder = {"معلومات", "قسم اللاعب", "أدوات", "قسم لاعبين", "قسم السيرفر"}
}

local lp = game.Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- وظيفة جلب الملفات من GitHub
local function Import(path)
    local success, result = pcall(function() 
        return game:HttpGet("https://raw.githubusercontent.com/" .. Cryptic.Config.UserName .. "/" .. Cryptic.Config.RepoName .. "/" .. Cryptic.Config.Branch .. "/" .. path) 
    end)
    if success and result then
        local func = loadstring(result)
        if func then return func() end
    end
    return nil
end

-- التنفيذ التلقائي (نسخ الرابط والتقرير)
pcall(function() setclipboard(Cryptic.Config.Discord) end)

local UI = Import("UI_Engine.lua")
if UI then
    local MainWin = UI:CreateWindow("Cryptic Hub | كربتك")

    -- تحميل الأقسام مع نظام الفواصل التلقائي بين الملفات فقط
    for _, tabName in ipairs(Cryptic.TabsOrder) do
        local info = Cryptic.Structure[tabName]
        if info then
            local CurrentTab = MainWin:CreateTab(tabName)
            
            for i, fileName in ipairs(info.Files) do
                local filePath = "Modules/" .. info.Folder .. "/" .. fileName .. ".lua"
                pcall(function()
                    local featureInit = Import(filePath)
                    if type(featureInit) == "function" then
                        -- تشغيل الميزة داخل التاب
                        featureInit(CurrentTab, UI)
                        
                        -- يضع خطاً فاصلاً فقط إذا كان هناك ملف ميزة آخر قادم في نفس القسم
                        if i < #info.Files then
                            CurrentTab:AddLine()
                        end
                    end
                end)
            end
        end
    end
    UI:Notify("تم تحميل Arwa Hub بنجاح! جميع الأقسام جاهزة.")
else
    warn("❌ فشل تحميل UI_Engine.lua من GitHub!")
end
