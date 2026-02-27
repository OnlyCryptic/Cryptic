-- [[ Cryptic Hub - المحرك الرئيسي المطور ]]
-- تحديث: إضافة الخطوط التلقائية بين الملفات لضمان التنظيم

local Cryptic = {
    Config = {
        UserName = "OnlyCryptic", RepoName = "Cryptic", Branch = "main",
        Discord = "https://discord.gg/QSvQJs7BdP",
        Webhook = "https://discord.com/api/webhooks/1476744644183199834/w8CnCw7ehZom4b0MXkb0L4bCd9fy0sQs7LX4HZb4JfFUrqPqykwagx3hybF0UaY8ATr2"
    },
    Structure = {
        ["معلومات"] = { Folder = "Misc", Files = {"info"} },
        ["قسم اللاعب"] = { Folder = "Player", Files = {"speed", "fly", "noclip"} },
        ["أدوات"] = { Folder = "Misc", Files = {"tptool"} },
        ["قسم لاعبين"] = { Folder = "Combat", Files = {"esp", "spectate"} },
        ["قسم السيرفر"] = { Folder = "Misc", Files = {"server", "rejoin"} }
    },
    TabsOrder = {"معلومات", "قسم اللاعب", "أدوات", "قسم لاعبين", "قسم السيرفر"}
}

-- كود النسخ والـ Log
pcall(function() setclipboard(Cryptic.Config.Discord) end)
local function Import(path)
    local s, r = pcall(game.HttpGet, game, "https://raw.githubusercontent.com/" .. Cryptic.Config.UserName .. "/" .. Cryptic.Config.RepoName .. "/" .. Cryptic.Config.Branch .. "/" .. path)
    if s and r then local f = loadstring(r); if f then return f() end end return nil
end

local UI = Import("UI_Engine.lua")
if UI then
    local MainWin = UI:CreateWindow("Cryptic Hub | كربتك")
    for _, tabName in ipairs(Cryptic.TabsOrder) do
        local info = Cryptic.Structure[tabName]
        local CurrentTab = MainWin:CreateTab(tabName)
        
        -- تحميل الملفات مع وضع خط فاصل بينها تلقائياً
        for i, fileName in ipairs(info.Files) do
            local filePath = "Modules/" .. info.Folder .. "/" .. fileName .. ".lua"
            pcall(function()
                local featureInit = Import(filePath)
                if type(featureInit) == "function" then
                    featureInit(CurrentTab, UI)
                    -- إذا لم يكن هذا الملف هو الأخير في القائمة، أضف خطاً فاصلاً
                    if i < #info.Files then
                        CurrentTab:AddLine()
                    end
                end
            end)
        end
    end
    UI:Notify("تم تحميل Arwa Hub بنجاح!")
end
