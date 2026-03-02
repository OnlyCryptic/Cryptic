-- [[ Cryptic Hub - المحرك الرئيسي V5.7 ]]
-- المطور: Cryptic | التحديث: الاعتماد الكلي على المحرك V4.3 وإصلاح شامل لجميع الأقسام

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
        ["خدع"] = { Folder = "Combat", Files = {"hitbox", "anime_aura", "invisibility", "zero_gravity", "carry", "magnet"} }
    },
    TabsOrder = {"معلومات", "قسم اللاعب", "أدوات", "استهداف لاعب", "قسم السيرفر", "خدع"}
}

-- [[ نظام المطور والتجارب ]]
-- يظهر فقط للمطور (أحمد) بناءً على UserID
if Players.LocalPlayer.UserId == 3875086037 then
    Cryptic.Structure["تجارب"] = { Folder = "Experiments", Files = {"test1", "anti_block"} }
    table.insert(Cryptic.TabsOrder, "تجارب")
end

-- دالة جلب الملفات من GitHub
local function Import(path)
    local url = "https://raw.githubusercontent.com/" .. Cryptic.Config.UserName .. "/" .. Cryptic.Config.RepoName .. "/" .. Cryptic.Config.Branch .. "/" .. path .. "?v=" .. tick()
    local s, r = pcall(game.HttpGet, game, url)
    if s and r then 
        local f = loadstring(r)
        if f then 
            local success, result = pcall(f)
            if success then return result end
        end
    end 
    return nil
end

-- دالة إرسال الإشعارات
local function SendNotify(title, text)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title, Text = text, Duration = 5
        })
    end)
end

-- تحميل محرك الواجهة
local UI = Import("UI_Engine.lua")
if UI then
    local MainWin = UI:CreateWindow("Cryptic Hub / " .. Cryptic.Config.Discord)
    
    for _, tabName in ipairs(Cryptic.TabsOrder) do
        local info = Cryptic.Structure[tabName]
        if info then
            local CurrentTab = MainWin:CreateTab(tabName)
            
            -- تحميل الملفات داخل كل قسم
            for _, fileName in ipairs(info.Files) do
                task.spawn(function()
                    local filePath = "Modules/" .. info.Folder .. "/" .. fileName .. ".lua"
                    local init = Import(filePath)
                    
                    if type(init) == "function" then
                        local success, err = pcall(function()
                            init(CurrentTab, UI)
                            CurrentTab:AddLine()
                        end)
                        if not success then
                            warn("❌ [Cryptic Hub]: خطأ في تشغيل " .. fileName .. ": " .. tostring(err))
                        end
                    end
                end)
            end
        end
    end
    
    SendNotify("Cryptic Hub", "✅ تم التحميل بنجاح! استمتع يا بطل")
end
