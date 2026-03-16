-- [[ Cryptic Hub - المحرك الرئيسي V8.0 (النسخة المجزأة مع الكاش) ]]
-- المطور: يامي (Yami) | التحديث: نظام الكاش لتسريع الواجهة ومنع اللاق

-- ========================================================
-- 🔥 الحماية من التكرار (Anti-Multiple Execution)
-- ========================================================
if getgenv().CrypticHub_Loaded then
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Cryptic Hub ⚠️",
            Text = "السكربت شغال بالفعل! لا حاجة لتفعيله مرة أخرى.",
            Duration = 3
        })
    end)
    return -- هذا السطر يوقف السكربت فوراً ويمنع تكرار الواجهة
end
getgenv().CrypticHub_Loaded = true -- تسجيل أن السكربت تم تشغيله الآن

-- ========================================================

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local Cryptic = {
    Config = {
        UserName = "OnlyCryptic", RepoName = "Cryptic", Branch = "test", -- فرع التجارب
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

-- إضافة قسم التجارب للمالك فقط
if Players.LocalPlayer.UserId == 3875086037 then
    Cryptic.Structure["تجارب"] = {
        Folder = "Experiments",
        Files = {"hm", "auto_apple"}
    }
    table.insert(Cryptic.TabsOrder, "تجارب")
end

-- دالة الاستدعاء العادية لملفات الميزات
local function Import(path)
    local url = "https://raw.githubusercontent.com/" .. Cryptic.Config.UserName .. "/" .. Cryptic.Config.RepoName .. "/" .. Cryptic.Config.Branch .. "/" .. path .. "?v=" .. tick()
    local s, r = pcall(game.HttpGet, game, url)
    if s and r then
        local f = loadstring(r)
        if f then return f() end
    end
    return nil
end

-- ========================================================
-- 🔥 نظام الذاكرة المؤقتة (Cache) لعناصر الواجهة (مهم جداً للسرعة)
-- ========================================================
local ElementCache = {}

local function LoadElement(elementName)
    -- إذا كان الملف محملاً مسبقاً، خذه من الذاكرة فوراً
    if ElementCache[elementName] then return ElementCache[elementName] end
    
    -- إذا لم يكن محملاً، اجلبه من GitHub
    local url = "https://raw.githubusercontent.com/" .. Cryptic.Config.UserName .. "/" .. Cryptic.Config.RepoName .. "/" .. Cryptic.Config.Branch .. "/UI/Elements/" .. elementName .. ".lua?v=" .. tick()
    local s, r = pcall(game.HttpGet, game, url)
    if s and r then
        local chunk = loadstring(r)
        if chunk then 
            local func = chunk() -- تفعيل الدالة
            ElementCache[elementName] = func -- حفظها في الذاكرة
            return func
        end
    end
    warn("Cryptic Hub: Failed to load element - " .. elementName)
    return nil
end

-- ========================================================
-- بناء الواجهة وتركيب التابات
-- ========================================================
local UI = Import("UI/Core.lua") -- استدعاء النواة الجديدة

if UI then
    local MainWin = UI:CreateWindow("Cryptic Hub / " .. Cryptic.Config.Discord)

    for _, tabName in ipairs(Cryptic.TabsOrder) do  
        local tabData = Cryptic.Structure[tabName]  
        if tabData then  
            local CurrentTab = MainWin:CreateTab(tabName)  

            -- ربط كل دوال إضافة الأزرار بنظام الكاش الذكي
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

            -- استدعاء ملفات الأقسام (المميزات الخاصة بك)
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
                
                -- أزرار الحفظ في قسم المعلومات
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
