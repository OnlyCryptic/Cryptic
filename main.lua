-- [[ Cryptic Hub - المحرك الرئيسي V6.4 ]]
-- المطور: Cryptic | الإصلاح: ضمان ظهور كافة الأقسام ومنع تعليق التحميل

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
        ["خدع"] = { Folder = "Combat", Files = {"zero_gravity"} }
    },
    
    TabsOrder = {"معلومات", "قسم اللاعب", "أدوات", "استهداف لاعب", "قسم السيرفر", "خدع"}
}

-- [[ نظام المطور الحصري لأحمد ]]
if Players.LocalPlayer.UserId == 3875086037 then
    Cryptic.Structure["تجارب"] = { Folder = "Experiments", Files = {"test1", "anti_block", "magnet", "anime_aura", "hitbox", "invisibility", "carry"} }
    table.insert(Cryptic.TabsOrder, "تجارب")
end

-- [[ نظام المابات المخصصة ]]
if game.PlaceId == 119564951960102 then
    Cryptic.Structure["Pass or Die"] = { Folder = "PassOrDie", Files = {"autopass", "doublecoins"} }
    table.insert(Cryptic.TabsOrder, 2, "Pass or Die")
end

-- دالة جلب الأكواد (المحسنة)
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

-- [[ تشغيل المحرك والواجهة ]]
local UI = Import("UI_Engine.lua")
if UI then
    local MainWin = UI:CreateWindow("Cryptic Hub / " .. Cryptic.Config.Discord)
    
    -- تحميل الأقسام بشكل تسلسلي لضمان الثبات
    for _, tabName in ipairs(Cryptic.TabsOrder) do
        local info = Cryptic.Structure[tabName]
        if info then
            local CurrentTab = MainWin:CreateTab(tabName)
            
            -- حقن دالة الزر المؤقت
            CurrentTab.AddTimedToggle = function(self, toggleName, callback)
                local toggleObj
                toggleObj = self:AddToggle(toggleName, function(state)
                    if state then
                        callback(true)
                        task.spawn(function()
                            task.wait(2)
                            callback(false)
                            if type(toggleObj) == "table" and (toggleObj.Set or toggleObj.SetState) then
                                pcall(function() (toggleObj.Set or toggleObj.SetState)(toggleObj, false) end)
                            end
                        end)
                    else
                        callback(false)
                    end
                end)
                return toggleObj
            end

            -- تحميل الملفات داخل كل قسم مع حماية pcall
            task.spawn(function()
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
            end)
        end
    end
end
