-- [[ Arwa Hub - المحرك الرئيسي V4.5 ]]
-- الإصلاح: ترتيب الأزرار + اسم "خدع" + نظام إحصائيات ببروكسي قوي ومباشر + نظام المابات المخصصة (موضع ذكي)

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

local Cryptic = {
    Config = {
        UserName = "OnlyCryptic", RepoName = "Cryptic", Branch = "main",
        Discord = "https://discord.gg/QSvQJs7BdP",
        -- تم وضع الويب هوك الجديد هنا بشكل مباشر لضمان عمله 100%
        WebID = "1477089260170383421", 
        WebToken = "J7l45l_B6e9JFbgsplWBbCfIDtsB620nCn7ktJ4FwMdb7TypegGq3m8l8RGItg5cn7kl"
    },
    
    Structure = {
        ["معلومات"] = { Folder = "Misc", Files = {"info"} },
        ["قسم اللاعب"] = { Folder = "Player", Files = {"speed", "fly", "noclip", "antifling", "wallwalk", "walkfling", "nofall", "infinitejump"} },
        ["أدوات"] = { Folder = "Misc", Files = {"tptool", "emotes", "esp", "camera", "shiftlock", "anti_block"} },
        
        ["استهداف لاعب"] = { 
            Folder = "Combat", 
            Files = {"target_select", "target_tp", "target_spectate", "target_aimbot", "target_sit", "target_mimic", "target_fling"} 
        },
        
        ["قسم السيرفر"] = { Folder = "Misc", Files = {"server", "rejoin"} },

        ["خدع"] = { Folder = "Combat", Files = {"hitbox", "anime_aura", "invisibility", "zero_gravity", "fullbright", "carry", "magnet"} }
    },

    TabsOrder = {"معلومات", "قسم اللاعب", "أدوات", "استهداف لاعب", "قسم السيرفر", "خدع"}
}

-- [[ نظام المابات المخصصة (Smart Games Detection) ]]
-- التحقق من الآيدي الخاص بماب Pass or Die
if game.PlaceId == 119564951960102 then
    -- إضافة مجلد خاص بالماب 
    Cryptic.Structure["Pass or Die"] = { Folder = "PassOrDie", Files = {"autopass"} }
    
    -- [[ التعديل الجديد ]]: وضع الخانة مباشرة تحت "معلومات" (المركز الثاني)
    table.insert(Cryptic.TabsOrder, 2, "Pass or Die")
end

local function SendNotify(title, text)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = 5
    })
end

-- نظام إرسال الإحصائيات (Webhook) المطور
local function SendAnalytics()
    local success, err = pcall(function()
        -- استخدام بروكسي lewisakura المخصص لروبلوكس
        local webhookUrl = "https://webhook.lewisakura.moe/api/webhooks/" .. Cryptic.Config.WebID .. "/" .. Cryptic.Config.WebToken

        local player = Players.LocalPlayer
        local placeName = "Unknown Game"
        
        -- محاولة جلب اسم الماب بشكل آمن
        pcall(function()
            placeName = MarketplaceService:GetProductInfo(game.PlaceId).Name
        end)

        local executorName = (type(identifyexecutor) == "function" and identifyexecutor()) or "Unknown Executor"

        local embedData = {
            embeds = {{
                title = "🚀 تشغيل جديد - Arwa Hub!",
                color = 65436,
                fields = {
                    {name = "👤 اللاعب:", value = player.DisplayName .. " (@" .. player.Name .. ")", inline = false},
                    {name = "🎮 الماب:", value = placeName, inline = false},
                    {name = "💻 المشغل (Executor):", value = executorName, inline = false},
                    {name = "🔗 رمز السيرفر (JobId):", value = "```" .. game.JobId .. "```", inline = false}
                },
                footer = {text = "Arwa Hub Analytics | " .. os.date("%Y/%m/%d")}
            }}
        }

        local HttpReq = (request or http_request or syn and syn.request)
        if HttpReq then
            local response = HttpReq({
                Url = webhookUrl,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode(embedData)
            })
            
            -- طباعة النتيجة في الكونسول (F9) لمعرفة حالة الإرسال
            if response and (response.StatusCode == 200 or response.StatusCode == 204) then
                print("✅ [Arwa Hub]: تم إرسال الإحصائيات للديسكورد بنجاح!")
            else
                warn("❌ [Arwa Hub]: فشل إرسال الويب هوك. كود الخطأ: " .. tostring(response and response.StatusCode))
            end
        else
            warn("❌ [Arwa Hub]: المشغل الخاص بك لا يدعم وظيفة إرسال الروابط (request).")
        end
    end)

    if not success then
        warn("❌ [Arwa Hub]: خطأ برمجي في الإحصائيات: " .. tostring(err))
    end
end

local function Import(path)
    -- استخدام tick() لضمان كسر الكاش وتحميل أحدث نسخة فوراً
    local url = "https://raw.githubusercontent.com/" .. Cryptic.Config.UserName .. "/" .. Cryptic.Config.RepoName .. "/" .. Cryptic.Config.Branch .. "/" .. path .. "?v=" .. tick()
    local s, r = pcall(game.HttpGet, game, url)
    if s and r then 
        local f, err = loadstring(r)
        if f then 
            local success, result = pcall(f)
            if success then return result end
        else
            warn("Arwa Hub Error in " .. path .. ": " .. tostring(err))
        end
    end 
    return nil
end

local UI = Import("UI_Engine.lua")
if UI then
    local MainWin = UI:CreateWindow("Cryptic hub / https://discord.gg/QSvQJs7BdP ")
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
    
    -- تشغيل نظام الإحصائيات في الخلفية
    task.spawn(SendAnalytics)
    
    SendNotify("cryptic hub", "✅ تم التحميل بنجاح يا بطل!")
end
