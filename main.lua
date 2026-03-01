-- [[ Arwa Hub - المحرك الرئيسي V4.6 ]]
-- الإصلاح: تصميم بطاقة معلومات احترافية (Embed) + زر الديسكورد الذكي الذي ينطفئ تلقائياً

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

local Cryptic = {
    Config = {
        UserName = "OnlyCryptic", RepoName = "Cryptic", Branch = "main",
        Discord = "https://discord.gg/QSvQJs7BdP",
        -- الويب هوك الخاص بك يعمل 100%
        WebID = "1477089260170383421", 
        WebToken = "J7l45l_B6e9JFbgsplWBbCfIDtsB620nCn7ktJ4FwMdb7TypegGq3m8l8RGItg5cn7kl"
    },
    
    Structure = {
        -- تم إزالة "معلومات" من هنا لأننا سنبنيها بشكل مخصص وجميل في الأسفل
        ["قسم اللاعب"] = { Folder = "Player", Files = {"speed", "fly", "noclip", "antifling", "wallwalk", "walkfling", "nofall", "infinitejump"} },
        ["أدوات"] = { Folder = "Misc", Files = {"tptool", "emotes", "esp", "camera", "shiftlock", "anti_block"} },
        ["استهداف لاعب"] = { Folder = "Combat", Files = {"target_select", "target_tp", "target_spectate", "target_aimbot", "target_sit", "target_mimic", "target_fling"} },
        ["قسم السيرفر"] = { Folder = "Misc", Files = {"server", "rejoin"} },
        ["خدع"] = { Folder = "Combat", Files = {"hitbox", "anime_aura", "invisibility", "zero_gravity", "fullbright", "carry", "magnet"} }
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
    local success, err = pcall(function()
        local webhookUrl = "https://webhook.lewisakura.moe/api/webhooks/" .. Cryptic.Config.WebID .. "/" .. Cryptic.Config.WebToken
        local player = Players.LocalPlayer
        local placeName = "Unknown Game"
        
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
            if response and (response.StatusCode == 200 or response.StatusCode == 204) then
                print("✅ [Arwa Hub]: تم إرسال الإحصائيات للديسكورد بنجاح!")
            end
        end
    end)
end

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

local UI = Import("UI_Engine.lua")
if UI then
    local MainWin = UI:CreateWindow("Arwa Hub / https://discord.gg/QSvQJs7BdP")
    
    for _, tabName in ipairs(Cryptic.TabsOrder) do
        local CurrentTab = MainWin:CreateTab(tabName)
        
        -- [[ تصميم قسم المعلومات (Embed) الجديد ]]
        if tabName == "معلومات" then
            local player = Players.LocalPlayer
            
            CurrentTab:AddLabel("==== [ 👤 بطاقة اللاعب ] ====")
            CurrentTab:AddLabel("الاسم: " .. player.DisplayName)
            CurrentTab:AddLabel("اليوزر: @" .. player.Name)
            CurrentTab:AddLabel("عمر الحساب: " .. player.AccountAge .. " يوم")
            
            CurrentTab:AddLine()
            
            CurrentTab:AddLabel("==== [ ⚙️ معلومات السكربت ] ====")
            CurrentTab:AddLabel("المطور: Arwa")
            CurrentTab:AddLabel("الإصدار: V4.6 (أداء سلس ومحسّن)")
            CurrentTab:AddLabel("الحالة: آمن 🟢 (Undetected)")
            
            CurrentTab:AddLine()
            
            -- زر الديسكورد الذكي (يشتغل ويطفي نفسه)
            local discordToggle
            discordToggle = CurrentTab:AddToggle("🔗 نسخ رابط الديسكورد", function(active)
                if active then
                    if setclipboard then 
                        setclipboard(Cryptic.Config.Discord) 
                        UI:Notify("✅ تم نسخ رابط الديسكورد بنجاح!")
                    else
                        UI:Notify("❌ جهازك لا يدعم النسخ التلقائي")
                    end
                    
                    -- إطفاء الزر تلقائياً بعد ثانية واحدة للحفاظ على الترتيب
                    task.spawn(function()
                        task.wait(1)
                        pcall(function()
                            -- دعم لأغلب مكتبات الـ UI لإعادة الزر لوضع الإيقاف
                            if type(discordToggle) == "table" and discordToggle.Set then
                                discordToggle:Set(false)
                            end
                        end)
                    end)
                end
            end)
            
        else
            -- التحميل الديناميكي لباقي الأقسام
            local info = Cryptic.Structure[tabName]
            if info then
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
    end
    
    -- تشغيل الإحصائيات في الخلفية
    task.spawn(SendAnalytics)
    
    SendNotify("Arwa Hub", "✅ تم التحميل بنجاح يا بطل!")
end
