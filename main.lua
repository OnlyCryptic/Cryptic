-- [[ Arwa Hub - المحرك الرئيسي V4.4 ]]
-- الإصلاح: ترتيب الأزرار + اسم "خدع" + إصلاح الإشعارات

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
        
        -- تعديل الترتيب ليصبح الانتقال فوق المراقبة
        ["استهداف لاعب"] = { 
            Folder = "Combat", 
            Files = {"target_select", "target_tp", "target_spectate", "target_aimbot", "target_sit", "target_mimic", "target_fling"} 
        },
        
        ["قسم السيرفر"] = { Folder = "Misc", Files = {"server", "rejoin"} },

        -- تغيير الاسم من "تعديل الخصوم" إلى "خدع"
        ["خدع"] = { Folder = "Combat", Files = {"hitbox", "anime_aura"} }
    },

    -- الترتيب النهائي للأقسام (خدع في آخر القائمة)
    TabsOrder = {"معلومات", "قسم اللاعب", "أدوات", "استهداف لاعب", "قسم السيرفر", "خدع"}
}

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

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
    UI:Notify("✅ تم التحديث بنجاح! تفحصي قسم خدع الآن")
end
