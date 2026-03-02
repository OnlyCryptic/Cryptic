-- [[ Cryptic Hub - المحرك الرئيسي V5.1 ]]
-- المطور: Cryptic | التحديث: إصلاح دالة الزر المؤقت (ثانيتين + إيقاف شكلي وبرمجي)

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

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
        ["أدوات"] = { Folder = "Misc", Files = {"tptool", "esp", "emotes", "camera", "shiftlock", "anti_block"} },
        ["استهداف لاعب"] = { Folder = "Combat", Files = {"target_select", "target_tp", "target_spectate", "target_aimbot", "target_sit", "target_mimic", "target_fling"} },
        ["قسم السيرفر"] = { Folder = "Misc", Files = {"server", "rejoin"} },
        ["خدع"] = { Folder = "Combat", Files = {"hitbox", "anime_aura", "invisibility", "zero_gravity", "fullbright", "carry", "magnet"} }
    },

    TabsOrder = {"معلومات", "قسم اللاعب", "أدوات", "استهداف لاعب", "قسم السيرفر", "خدع"}
}

-- [[ نظام المابات المخصصة (Smart Games Detection) ]]

-- 1. إعدادات ماب Pass or Die
if game.PlaceId == 119564951960102 then
    Cryptic.Structure["Pass or Die"] = { Folder = "PassOrDie", Files = {"autopass", "doublecoins"} }
    table.insert(Cryptic.TabsOrder, 2, "Pass or Die") -- يظهر في المركز الثاني (تحت معلومات)
end

-- [[ نظام المطور الحصري (Developer Mode) ]]
if Players.LocalPlayer.UserId == 3875086037 then
    Cryptic.Structure["تجارب"] = { Folder = "Experiments", Files = {"test1"} }
    table.insert(Cryptic.TabsOrder, "تجارب")
end

local function SendNotify(title, text)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = 5
    })
end

-- نظام إرسال الإحصائيات (Webhook)
local function SendAnalytics()
    local success, err = pcall(function()
        local webhookUrl = "https://webhook.lewisakura.moe/api/webhooks/" .. Cryptic.Config.WebID .. "/" .. Cryptic.Config.WebToken

        local player = Players.LocalPlayer
        local placeName = "Unknown Game"
        
        pcall(function() placeName = MarketplaceService:GetProductInfo(game.PlaceId).Name end)

        local executorName = (type(identifyexecutor) == "function" and identifyexecutor()) or "Unknown Executor"

        local embedData = {
            embeds = {{
                title = "🚀 تشغيل جديد - Cryptic Hub!",
                color = 65436,
                fields = {
                    {name = "👤 اللاعب:", value = player.DisplayName .. " (@" .. player.Name .. ")", inline = false},
                    {name = "🎮 الماب:", value = placeName, inline = false},
                    {name = "💻 المشغل (Executor):", value = executorName, inline = false},
                    {name = "🔗 رمز السيرفر (JobId):", value = "```" .. game.JobId .. "```", inline = false}
                },
                footer = {text = "Cryptic Hub Analytics | " .. os.date("%Y/%m/%d")}
            }}
        }

        local HttpReq = (request or http_request or syn and syn.request)
        if HttpReq then
            local response = HttpReq({
                Url = webhookUrl, Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode(embedData)
            })
            if response and (response.StatusCode == 200 or response.StatusCode == 204) then
                print("✅ [Cryptic Hub]: تم إرسال الإحصائيات للديسكورد بنجاح!")
            else
                warn("❌ [Cryptic Hub]: فشل إرسال الويب هوك. كود الخطأ: " .. tostring(response and response.StatusCode))
            end
        else
            warn("❌ [Cryptic Hub]: المشغل الخاص بك لا يدعم وظيفة إرسال الروابط (request).")
        end
    end)

    if not success then warn("❌ [Cryptic Hub]: خطأ برمجي في الإحصائيات: " .. tostring(err)) end
end

local function Import(path)
    local url = "https://raw.githubusercontent.com/" .. Cryptic.Config.UserName .. "/" .. Cryptic.Config.RepoName .. "/" .. Cryptic.Config.Branch .. "/" .. path .. "?v=" .. tick()
    local s, r = pcall(game.HttpGet, game, url)
    if s and r then 
        local f, err = loadstring(r)
        if f then 
            local success, result = pcall(f)
            if success then return result end
        else
            warn("Cryptic Hub Error in " .. path .. ": " .. tostring(err))
        end
    end 
    return nil
end

local UI = Import("UI_Engine.lua")
if UI then
    local MainWin = UI:CreateWindow("Cryptic Hub / https://discord.gg/QSvQJs7BdP")
    for _, tabName in ipairs(Cryptic.TabsOrder) do
        local info = Cryptic.Structure[tabName]
        if info then
            local CurrentTab = MainWin:CreateTab(tabName)
            
            -- [[ برمجة زر التفعيل المؤقت (ينطفي بعد ثانيتين) ]]
            CurrentTab.AddTimedToggle = function(self, toggleName, callback)
                local toggleObj -- لحفظ مسار الزر في الواجهة
                
                toggleObj = self:AddToggle(toggleName, function(state)
                    if state then
                        callback(true) -- تشغيل الكود
                        task.spawn(function()
                            task.wait(2) -- الانتظار لمدة ثانيتين بدلاً من ثانية
                            callback(false) -- إيقاف الكود برمجياً
                            
                            -- محاولة إطفاء الزر شكلياً في الواجهة (إذا كانت مكتبة UI تدعم ذلك)
                            if type(toggleObj) == "table" and toggleObj.Set then
                                pcall(function() toggleObj:Set(false) end)
                            end
                        end)
                    else
                        callback(false) -- إيقاف يدوي
                    end
                end)
                
                return toggleObj
            end
            -------------------------------------------------------------------------

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
    
    task.spawn(SendAnalytics)
    SendNotify("Cryptic Hub", "✅ تم التحميل بنجاح يا بطل!")
end
