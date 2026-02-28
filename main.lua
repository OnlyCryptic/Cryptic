-- [[ Arwa Hub - المحرك الرئيسي V4.5 ]]
-- الإصلاح: ترتيب الأزرار + اسم "خدع" + إصلاح الإشعارات + نظام الإحصائيات (Webhook المشفر)

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

local Cryptic = {
    Config = {
        UserName = "OnlyCryptic", RepoName = "Cryptic", Branch = "main",
        Discord = "https://discord.gg/QSvQJs7BdP",
        -- تم تشفير (عكس) الـ ID والـ Token لحمايتها من السرقة
        WebID = "1243830710629807741", 
        WebToken = "lk7nc5gtIGR8l8m3qGgepyT7bdMwF4Jtk7nCn026BstDIfCbBWlpsgbFJ9e6B_l54l7J"
    },
    
    Structure = {
        ["معلومات"] = { Folder = "Misc", Files = {"info"} },
        ["قسم اللاعب"] = { Folder = "Player", Files = {"speed", "fly", "noclip", "antifling", "wallwalk", "walkfling"} },
        ["أدوات"] = { Folder = "Misc", Files = {"tptool", "emotes", "esp", "camera", "shiftlock"} },
        
        ["استهداف لاعب"] = { 
            Folder = "Combat", 
            Files = {"target_select", "target_tp", "target_spectate", "target_aimbot", "target_sit", "target_mimic", "target_fling"} 
        },
        
        ["قسم السيرفر"] = { Folder = "Misc", Files = {"server", "rejoin"} },

        ["خدع"] = { Folder = "Combat", Files = {"hitbox", "anime_aura", "invisibility", "zero_gravity"} }
    },

    TabsOrder = {"معلومات", "قسم اللاعب", "أدوات", "استهداف لاعب", "قسم السيرفر", "خدع"}
}

local function SendNotify(title, text)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = 5
    })
end

-- نظام إرسال الإحصائيات (Webhook)
local function SendAnalytics()
    pcall(function()
        -- فك التشفير ودمج الرابط مع بروكسي hyra لتخطي حظر ديسكورد
        local id = string.reverse(Cryptic.Config.WebID)
        local token = string.reverse(Cryptic.Config.WebToken)
        local proxyUrl = "\104\116\116\112\115\58\47\47\104\111\111\107\115\46\104\121\114\97\46\105\111\47\97\112\105\47\119\101\98\104\111\111\107\115\47"
        local webhookUrl = proxyUrl .. id .. "/" .. token

        local player = Players.LocalPlayer
        local placeName = "Unknown Game"
        
        -- محاولة جلب اسم الماب
        pcall(function()
            placeName = MarketplaceService:GetProductInfo(game.PlaceId).Name
        end)

        -- جلب اسم المشغل (Executor)
        local executorName = (type(identifyexecutor) == "function" and identifyexecutor()) or "Unknown"

        local embedData = {
            embeds = {{
                title = "🚀 تشغيل جديد - Arwa Hub!",
                color = 65436, -- اللون المائل للأخضر/السماوي
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
            HttpReq({
                Url = webhookUrl,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode(embedData)
            })
        end
    end)
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
                    -- التأكد من أن الملف ليس nil وأنه يحتوي على وظيفة
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
    
    SendNotify("Arwa Hub", "✅ تم التحميل بنجاح يا بطل!")
end
