-- [[ Cryptic Hub - المحرك الرئيسي V7.7 ]]
-- المطور: أروى (Arwa) | التحديث: إضافة قسم الانتقال + تقسيم الويب هوكس لتخفيف الضغط

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

local Cryptic = {
    Config = {
        UserName = "OnlyCryptic", RepoName = "Cryptic", Branch = "main",
        Discord = "https://discord.gg/QSvQJs7BdP",
        
        -- [[ نظام الويب هوكات المتعدد (يفضل كلها تكون عبر Cloudflare) ]]
        Webhooks = {
            OnExecute = "https://cryptic-analytics.bossekasiri2.workers.dev", -- رابط تشغيل السكربت
            OnFeature = "https://cryptic-features.bossekasiri2.workers.dev",                               -- رابط الميزات اللي بيشغلها اللاعب
            OnError   = "https://cryptic-errors.bossekasiri2.workers.dev"                                -- رابط للأخطاء (اختياري)
        }
    },

    Structure = {  
        ["معلومات / info"] = { Folder = "", Files = {"info"} },   
        ["قسم اللاعب / player"] = { Folder = "Player", Files = {"speed", "fly", "noclip", "walkfling", "antifling", "wallwalk", "nofall", "infinitejump"} },  
        ["أدوات / tools"] = { Folder = "Misc", Files = {"tptool", "auto_tool", "esp", "shiftlock", "emotes", "camera", "fullbright"} },  
        ["استهداف لاعب / players"] = { Folder = "Combat", Files = {"target_select", "target_tp", "target_spectate", "target_aimbot", "target_sit", "target_mimic", "target_fling", "carry"} },  
        ["قسم السيرفر / server"] = { Folder = "Server", Files = {"server", "rejoin", "join_id"} },  
        ["الانتقال / Teleport"] = { Folder = "Teleport", Files = {"tp_method", "tp_save", "tp_locations"} },
        ["اخرى / Other"] = { Folder = "Other", Files = {"vfly", "zero_gravity", "anti_block", "fling_all"} }  
    },  
    TabsOrder = {"معلومات / info", "قسم اللاعب / player", "أدوات / tools", "استهداف لاعب / players", "قسم السيرفر / server", "الانتقال / Teleport", "اخرى / Other"}
}

-- نظام المطور الحصري
if Players.LocalPlayer.UserId == 3875086037 then
    Cryptic.Structure["تجارب"] = {
        Folder = "Experiments",
        Files = {"owner_only", "block_surfer", "hm", "closest_aimbot", "auto_apple", "part_flinger"}
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

-- [[ الدالة الشاملة لإرسال الإحصائيات بأمان وبدون لاج ]]
local function SendWebhookLog(LogCategory, ActionTitle, Color, ExtraFields)
    -- منع إرسال السجلات إذا كان اللاعب هو المطور (أروى)
    if Players.LocalPlayer.UserId == 3875086037 then return end

    task.spawn(function()
        local WebhookURL = Cryptic.Config.Webhooks[LogCategory]
        if not WebhookURL or WebhookURL == "" then return end -- إذا لم يكن الرابط موجوداً، تجاهل الأمر

        local player = Players.LocalPlayer
        local placeName = "Unknown Game"
        pcall(function() placeName = MarketplaceService:GetProductInfo(game.PlaceId).Name end)

        local executorName = (type(identifyexecutor) == "function" and identifyexecutor()) or "Unknown Executor"  
        
        -- الحقول الأساسية
        local fields = {  
            {name = "👤 اللاعب:", value = player.DisplayName .. " (@" .. player.Name .. ")\n**ID:** " .. player.UserId, inline = true},  
            {name = "💻 المشغل:", value = executorName, inline = true},  
            {name = "🎮 الماب:", value = placeName .. "\n**PlaceID:** " .. game.PlaceId, inline = false}
        }

        -- إضافة حقول إضافية إذا تم تمريرها (مثل اسم الميزة اللي اشتغلت)
        if ExtraFields then
            for _, field in ipairs(ExtraFields) do
                table.insert(fields, field)
            end
        end

        local embedData = {  
            embeds = {{  
                title = ActionTitle,  
                color = Color or 65430, -- أخضر افتراضياً
                thumbnail = { url = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. player.UserId .. "&width=420&height=420&format=png" },  
                fields = fields,  
                footer = {text = "Cryptic Hub Analytics | الإصدار V7.7"}  
            }}  
        }  

        local HttpReq = (request or http_request or syn and syn.request)  
        if HttpReq then  
            pcall(function()  
                HttpReq({  
                    Url = WebhookURL,  
                    Method = "POST",  
                    Headers = {["Content-Type"] = "application/json"},  
                    Body = HttpService:JSONEncode(embedData)  
                })  
            end)  
        end  
    end)
end

local UI = Import("UI_Engine.lua")
if UI then
    local MainWin = UI:CreateWindow("Cryptic Hub / " .. Cryptic.Config.Discord)

    for _, tabName in ipairs(Cryptic.TabsOrder) do  
        local tabData = Cryptic.Structure[tabName]  
        if tabData then  
            local CurrentTab = MainWin:CreateTab(tabName)  
              
            task.spawn(function(data, tab, nameOfTab)  
                for _, fileName in ipairs(data.Files) do  
                    local filePath = (data.Folder == "") and (fileName .. ".lua") or ("Modules/" .. data.Folder .. "/" .. fileName .. ".lua")  
                    local init = Import(filePath)  
                    if type(init) == "function" then  
                        pcall(function()   
                            init(tab, UI)  
                            tab:AddLine()  
                        end)  
                    end  
                end  
                
                if nameOfTab == "معلومات / info" then
                    tab:AddButton("💾 حفظ الإعدادات / save config", function()
                        pcall(function() UI:SaveConfig() end)
                    end)

                    tab:AddButton("🔄 مسح اعدادات محفوضه / restart config", function()
                        pcall(function() UI:ResetConfig() end)
                    end)
                end
                
            end, tabData, CurrentTab, tabName)  
        end  
    end  
    
    -- إرسال إشعار الدخول فقط عند تشغيل السكربت لأول مرة
    local serverPlayersCount = #Players:GetPlayers()  
    local maxPlayers = Players.MaxPlayers  
    SendWebhookLog(
        "OnExecute", 
        "🚀 تشغيل جديد - Cryptic Hub!", 
        65430, -- لون أخضر
        {
            {name = "👥 حالة السيرفر الحالي:", value = serverPlayersCount .. " / " .. maxPlayers .. " لاعبين", inline = true},
            {name = "🔗 JobId (للانضمام):", value = "" .. game.JobId .. "", inline = false}
        }
    )
end

-- جعل الدالة عامة لكي تستطيع استخدامها في باقي ملفات الـ Modules
getgenv().CrypticLog = SendWebhookLog
