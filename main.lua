-- [[ Cryptic Hub - المحرك الرئيسي V8.0 (النسخة المجزأة مع الكاش + Rejoin الذكي) ]]
-- المطور: يامي | الوصف: حماية من التكرار مع أزرار Rejoin و Server Hop تلقائي

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local lp = Players.LocalPlayer

-- ========================================================
-- إعدادات السكربت (رفعناها للأعلى لنستفيد منها في إعادة الدخول)
-- ========================================================
local Cryptic = {
    Config = {
        UserName = "OnlyCryptic", RepoName = "Cryptic", Branch = "test", 
        Discord = "https://discord.gg/QSvQJs7BdP"
    },

    Structure = {  
        ["معلومات / info"] = { Folder = "", Files = {"info"} },   
        ["قسم اللاعب / player"] = { Folder = "Player", Files = {"speed", "fly", "noclip", "walkfling", "antifling", "wallwalk", "nofall", "infinitejump"} },  
        ["أدوات / tools"] = { Folder = "Misc", Files = {"tptool", "auto_tool", "esp", "shiftlock", "emotes", "x-ray", "fullbright", "camera"} },  
        ["استهداف لاعب / players"] = { Folder = "Combat", Files = {"target_select", "target_tp", "target_spectate", "target_aimbot", "target_sit", "target_mimic", "target_fling", "carry"} },  
        ["قسم السيرفر / server"] = { Folder = "Server", Files = {"server", "rejoin", "join_id"} },  
        ["الانتقال / Teleport"] = { Folder = "Teleport", Files = {"tp_locations"} },
        ["اخرى / Other"] = { Folder = "Other", Files = {"animations", "vfly", "zero_gravity", "anti_block", "fling_all"} },
        ["اقتراحات / Suggestions"] = { Folder = "", Files = {"suggestion"} }
    },  
    TabsOrder = {"معلومات / info", "قسم اللاعب / player", "أدوات / tools", "استهداف لاعب / players", "قسم السيرفر / server", "الانتقال / Teleport", "اخرى / Other", "اقتراحات / Suggestions"}
}

-- ========================================================
-- 🔥 بوابة الحماية من التكرار مع نظام الأزرار (Rejoin / Hop)
-- ========================================================
if getgenv().CrypticHub_Loaded then
    local Bindable = Instance.new("BindableFunction")
    
    Bindable.OnInvoke = function(buttonText)
        if buttonText == "إعادة ودخول / Rejoin" then
            
            -- 1. تجهيز السكربت ليشتغل تلقائياً بعد الانتقال (باستخدام queue_on_teleport)
            local qot = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
            if qot then
                -- ضع هنا كود التشغيل الخاص بسكربتك (الـ Loader)
                -- لو كان عندك كود قصير ينسخه اللاعبون، ضعه مكان النص بالأسفل
                qot([[
                    task.wait(3)
                    -- ضع كود الـ loadstring الخاص بك هنا ليتم حقنه تلقائياً:
                    -- loadstring(game:HttpGet('https://raw.githubusercontent.com/OnlyCryptic/Cryptic/test/main.lua'))()
                ]])
            end

            -- محاولة 1: الدخول لنفس السيرفر
            local success, _ = pcall(function()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, lp)
            end)

            -- محاولة 2: إذا فشل الدخول لنفس السيرفر، نسوي Server Hop
            if not success then
                local req = request or http_request or (syn and syn.request)
                local hopSuccess = false
                
                if req then
                    pcall(function()
                        local res = req({
                            Url = "https://games.roblox.com/v1/games/" .. tostring(game.PlaceId) .. "/servers/Public?sortOrder=Asc&limit=100",
                            Method = "GET"
                        })
                        local data = HttpService:JSONDecode(res.Body)
                        if data and data.data then
                            for _, server in ipairs(data.data) do
                                -- البحث عن سيرفر فيه مساحة ومختلف عن السيرفر الحالي
                                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                                    TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, lp)
                                    hopSuccess = true
                                    break
                                end
                            end
                        end
                    end)
                end

                -- محاولة 3: إذا فشل كل شيء، نبلغ اللاعب بالتدخل اليدوي
                if not hopSuccess then
                    pcall(function()
                        game:GetService("StarterGui"):SetCore("SendNotification", {
                            Title = "تنبيه ⚠️",
                            Text = "اعد دخول بنفسك تستعمله / Rejoin manually to use it",
                            Duration = 10
                        })
                    end)
                end
            end
        end
        -- إذا ضغط "الغاء / Cancel" لن يحدث شيء، سينتهي الإشعار فقط
    end

    -- عرض الإشعار مع الأزرار
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Cryptic Hub ⚠️",
            Text = "السكربت شغال بالفعل اعد دخول لإعادة تشغيله / Re-join and activate it again",
            Duration = 15,
            Button1 = "إعادة ودخول / Rejoin",
            Button2 = "الغاء / Cancel",
            Callback = Bindable
        })
    end)
    return -- توقيف السكربت هنا
end
getgenv().CrypticHub_Loaded = true -- إغلاق البوابة بعد التحميل

-- ========================================================
-- إضافة قسم التجارب للمالك فقط
-- ========================================================
if lp.UserId == 3875086037 then
    Cryptic.Structure["تجارب"] = { Folder = "Experiments", Files = {"hm", "auto_apple", "dances"} }
    table.insert(Cryptic.TabsOrder, "تجارب")
end

-- ========================================================
-- دوال الاستدعاء والكاش
-- ========================================================
local function Import(path)
    local url = "https://raw.githubusercontent.com/" .. Cryptic.Config.UserName .. "/" .. Cryptic.Config.RepoName .. "/" .. Cryptic.Config.Branch .. "/" .. path .. "?v=" .. tick()
    local s, r = pcall(game.HttpGet, game, url)
    if s and r then
        local f = loadstring(r)
        if f then return f() end
    end
    return nil
end

local ElementCache = {}
local function LoadElement(elementName)
    if ElementCache[elementName] then return ElementCache[elementName] end
    local url = "https://raw.githubusercontent.com/" .. Cryptic.Config.UserName .. "/" .. Cryptic.Config.RepoName .. "/" .. Cryptic.Config.Branch .. "/UI/Elements/" .. elementName .. ".lua?v=" .. tick()
    local s, r = pcall(game.HttpGet, game, url)
    if s and r then
        local chunk = loadstring(r)
        if chunk then 
            local func = chunk() 
            ElementCache[elementName] = func 
            return func
        end
    end
    warn("Cryptic Hub: Failed to load element - " .. elementName)
    return nil
end

-- ========================================================
-- بناء الواجهة وتركيب التابات
-- ========================================================
local UI = Import("UI/Core.lua")

if UI then
    local MainWin = UI:CreateWindow("Cryptic Hub / " .. Cryptic.Config.Discord)

    for _, tabName in ipairs(Cryptic.TabsOrder) do  
        local tabData = Cryptic.Structure[tabName]  
        if tabData then  
            local CurrentTab = MainWin:CreateTab(tabName)  

            local elementsList = {
                "Button", "Toggle", "TimedToggle", "Input", "LargeInput", 
                "SpeedControl", "Dropdown", "PlayerSelector", "ProfileCard", 
                "Line", "Label", "Paragraph"
            }
            
            for _, el in ipairs(elementsList) do
                CurrentTab["Add" .. el] = function(self, ...)
                    local elementFunc = LoadElement(el)
                    if elementFunc then return elementFunc(self, ...) end
                end
            end

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
end
