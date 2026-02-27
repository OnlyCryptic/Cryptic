-- [[ Arwa Hub - المحرك الرئيسي الشامل V2.8 ]]
-- المطور: يامي | تاريخ التحديث: 2026/02/27
-- ميزات: تحميل آلي، فواصل منظمة، نظام مراقبة، وسلاسة الهاتف

local Cryptic = {
    Config = {
        UserName = "OnlyCryptic", 
        RepoName = "Cryptic",  
        Branch   = "main",
        Discord  = "https://discord.gg/QSvQJs7BdP",
        Webhook  = "https://discord.com/api/webhooks/1476744644183199834/w8CnCw7ehZom4b0MXkb0L4bCd9fy0sQs7LX4HZb4JfFUrqPqykwagx3hybF0UaY8ATr2"
    },
    
    -- هيكل السكربت: أي ملف تضعينه هنا سيحمله السكربت تلقائياً
    Structure = {
        ["معلومات"] = { Folder = "Misc", Files = {"info"} },
        ["قسم اللاعب"] = { Folder = "Player", Files = {"speed", "fly", "noclip"} }, -- ملفات السرعة والطيران
        ["أدوات"] = { Folder = "Misc", Files = {"tptool"} },
        ["قسم لاعبين"] = { Folder = "Combat", Files = {"esp", "spectate"} },
        ["قسم السيرفر"] = { Folder = "Misc", Files = {"server", "rejoin"} }
    },
    TabsOrder = {"معلومات", "قسم اللاعب", "أدوات", "قسم لاعبين", "قسم السيرفر"}
}

local lp = game.Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- وظيفة جلب الملفات من GitHub مع نظام كشف الأخطاء
local function Import(path)
    local success, result = pcall(function() 
        return game:HttpGet("https://raw.githubusercontent.com/" .. Cryptic.Config.UserName .. "/" .. Cryptic.Config.RepoName .. "/" .. Cryptic.Config.Branch .. "/" .. path) 
    end)
    if success and result then
        local func, err = loadstring(result)
        if func then return func() end
        warn("❌ خطأ برمجي في ملف: " .. path .. " | " .. tostring(err))
    end
    warn("⚠️ فشل جلب الملف من GitHub: " .. path)
    return nil
end

-- نسخ الرابط تلقائياً
pcall(function() setclipboard(Cryptic.Config.Discord) end)

local UI = Import("UI_Engine.lua")
if UI then
    local MainWin = UI:CreateWindow("Cryptic Hub | كربتك")

    -- التحميل التلقائي المنظم
    for _, tabName in ipairs(Cryptic.TabsOrder) do
        local info = Cryptic.Structure[tabName]
        if info then
            local CurrentTab = MainWin:CreateTab(tabName)
            for i, fileName in ipairs(info.Files) do
                local filePath = "Modules/" .. info.Folder .. "/" .. fileName .. ".lua"
                local featureInit = Import(filePath)
                if type(featureInit) == "function" then
                    featureInit(CurrentTab, UI)
                    -- وضع خط فاصل آلي بين الملفات المختلفة في نفس القسم
                    if i < #info.Files then
                        CurrentTab:AddLine()
                    end
                end
            end
        end
    end
    UI:Notify("تم تحميل Arwa Hub بنجاح! جميع الأقسام جاهزة.")
else
    warn("❌ فشل تحميل UI_Engine.lua")
end
