-- [[ Cryptic Hub - المحرك الرئيسي V6.8 ]]
-- المطور: Cryptic | التحديث: إصلاح نطاق المتغيرات وضمان ظهور كافة الأقسام

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local Cryptic = {
    Config = {
        UserName = "OnlyCryptic", RepoName = "Cryptic", Branch = "main",
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
        ["خدع"] = { Folder = "Combat", Files = {"zero_gravity"} }
    },
    TabsOrder = {"معلومات", "قسم اللاعب", "أدوات", "استهداف لاعب", "قسم السيرفر", "خدع"}
}

-- [[ نظام المطور الحصري لأحمد بناءً على صورته الجديدة ]]
if Players.LocalPlayer.UserId == 3875086037 then
    Cryptic.Structure["تجارب"] = { 
        Folder = "Experiments", 
        Files = {"test1", "anti_block", "carry", "hitbox", "invisibility", "magnet", "anime_aura"} 
    }
    table.insert(Cryptic.TabsOrder, "تجارب")
end

local function Import(path)
    local url = "https://raw.githubusercontent.com/" .. Cryptic.Config.UserName .. "/" .. Cryptic.Config.RepoName .. "/" .. Cryptic.Config.Branch .. "/" .. path .. "?v=" .. tick()
    local s, r = pcall(game.HttpGet, game, url)
    if s and r then 
        local f = loadstring(r)
        if f then return f() end
    end 
    return nil
end

local UI = Import("UI_Engine.lua")
if UI then
    local MainWin = UI:CreateWindow("Cryptic Hub / " .. Cryptic.Config.Discord)
    
    -- تحميل كل قسم بشكل مستقل لضمان الظهور
    for _, tabName in ipairs(Cryptic.TabsOrder) do
        local tabData = Cryptic.Structure[tabName]
        if tabData then
            local CurrentTab = MainWin:CreateTab(tabName)
            
            -- حقن دالة الزر المؤقت يدوياً لضمان التوافق
            CurrentTab.AddTimedToggle = function(self, label, callback)
                return self:AddToggle(label, function(active)
                    if active then
                        pcall(callback, true)
                        task.spawn(function()
                            task.wait(2)
                            pcall(callback, false)
                        end)
                    end
                end)
            end

            -- [[ التعديل الجوهري: تمرير البيانات داخل task.spawn لضمان عدم الخلط ]]
            task.spawn(function(data, tab)
                for _, fileName in ipairs(data.Files) do
                    local filePath = "Modules/" .. data.Folder .. "/" .. fileName .. ".lua"
                    local init = Import(filePath)
                    if type(init) == "function" then
                        pcall(function() 
                            init(tab, UI)
                            tab:AddLine()
                        end)
                    end
                end
            end, tabData, CurrentTab)
        end
    end
end
