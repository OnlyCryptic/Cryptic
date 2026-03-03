-- [[ Cryptic Hub - المحرك الرئيسي V6.7 ]]
-- المطور: Cryptic | الإصلاح: تحديث المسارات بناءً على مجلد Experiments الجديد + حماية pcall شاملة

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

local Cryptic = {
    Config = {
        UserName = "OnlyCryptic", 
        RepoName = "Cryptic", 
        Branch = "main",
        Discord = "https://discord.gg/QSvQJs7BdP",
        WebID = "1477089260170383421", 
        WebToken = "J7l45l_B6e9JFbgsplWBbCfIDtsB620nCn7ktJ4FwMdb7TypegGq3m8l8RGItg5cn7kl"
    },
    
    Structure = {
        ["معلومات"] = { Folder = "Misc", Files = {"info"} },
        ["قسم اللاعب"] = { Folder = "Player", Files = {"speed", "fly", "noclip", "antifling", "wallwalk", "walkfling", "nofall", "infinitejump"} },
        ["أدوات"] = { Folder = "Misc", Files = {"tptool", "esp", "emotes", "camera", "fullbright"} },
        ["استهداف لاعب"] = { Folder = "Combat", Files = {"target_select", "target_tp", "target_spectate", "target_aimbot", "target_sit", "target_mimic", "target_fling"} },
        ["قسم السيرفر"] = { Folder = "Misc", Files = {"server", "rejoin"} },
        ["خدع"] = { Folder = "Combat", Files = {"zero_gravity"} } -- تم ترك الملفات التي لم تظهر في مجلد Experiments هنا
    },
    
    TabsOrder = {"معلومات", "قسم اللاعب", "أدوات", "استهداف لاعب", "قسم السيرفر", "خدع"}
}

-- [[ نظام المطور الحصري لأحمد ]]
-- تم تعديل هذا القسم ليطابق صورتك بالضبط ويجلب الملفات من مجلد Experiments
if Players.LocalPlayer.UserId == 3875086037 then
    Cryptic.Structure["تجارب"] = { 
        Folder = "Experiments", 
        Files = {"test1", "anti_block", "carry", "hitbox", "invisibility", "magnet", "anime_aura"} 
    }
    table.insert(Cryptic.TabsOrder, "تجارب")
end

-- دالة جلب الأكواد من GitHub مع منع التخزين المؤقت
local function Import(path)
    local url = "https://raw.githubusercontent.com/" .. Cryptic.Config.UserName .. "/" .. Cryptic.Config.RepoName .. "/" .. Cryptic.Config.Branch .. "/" .. path .. "?v=" .. tick()
    local s, r = pcall(game.HttpGet, game, url)
    if s and r then 
        local f, err = loadstring(r)
        if f then 
            local success, result = pcall(f)
            if success then return result end
        end
    end 
    return nil
end

-- [[ تحميل محرك الواجهة وتشغيل السكربت ]]
local UI = Import("UI_Engine.lua")
if UI then
    local MainWin = UI:CreateWindow("Cryptic Hub / " .. Cryptic.Config.Discord)
    
    -- تحميل الأقسام بشكل مستقل تماماً لضمان عدم اختفاء أي منها
    for _, tabName in ipairs(Cryptic.TabsOrder) do
        -- حماية pcall لإنشاء التاب: إذا فشل تاب واحد، البقية ستظهر بالتأكيد
        task.spawn(function()
            local successTab, CurrentTab = pcall(function() return MainWin:CreateTab(tabName) end)
            
            if successTab and CurrentTab then
                local info = Cryptic.Structure[tabName]
                if info then
                    -- تحميل ملفات القسم بشكل متسلسل داخل التاب
                    for _, fileName in ipairs(info.Files) do
                        local filePath = "Modules/" .. info.Folder .. "/" .. fileName .. ".lua"
                        local init = Import(filePath)
                        
                        if type(init) == "function" then
                            pcall(function() 
                                init(CurrentTab, UI)
                                CurrentTab:AddLine()
                            end)
                        end
                    end
                end
            end
        end)
    end
end
