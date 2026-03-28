-- [[ Cryptic Hub - المحرك الرئيسي V8.2 (نظام سكربتات المابات) ]]
-- المطور: يامي | الإضافة: قسم ماب مخصص يظهر فقط عند الدخول للماب المسجّل

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

local Cryptic = {
    Config = {
        UserName = "OnlyCryptic", RepoName = "Cryptic", Branch = "test", 
        Discord = "https://discord.gg/QSvQJs7BdP"
    },

    -- ========================================================
    -- 🗺️ سجل المابات: PlaceId => مسار ملف الماب (بدون .lua)
    -- أضف ماب جديد بإضافة سطر هنا وإنشاء ملفه في Maps/
    -- ========================================================
    Maps = {
        [2753915549] = "Maps/2753915549"
    },

    Structure = {  
        ["معلومات / info"] = { Folder = "", Files = {"info"} },   
        ["قسم اللاعب / player"] = { Folder = "Player", Files = {"speed", "fly", "noclip", "walkfling", "antifling", "wallwalk", "nofall", "infinitejump"} },  
        ["أدوات / tools"] = { Folder = "Misc", Files = {"tptool", "auto_tool", "esp", "shiftlock", "emotes", "x-ray", "fullbright", "camera"} },  
        ["استهداف لاعب / players"] = { Folder = "Combat", Files = {"target_select", "target_tp", "target_spectate", "target_aimbot", "target_sit", "target_mimic", "target_fling", "bring_parts", "carry", "jark", "backpack", "Target_follow"} },  
        ["قسم السيرفر / server"] = { Folder = "Server", Files = {"server", "rejoin", "join_id"} },  
        ["الانتقال / Teleport"] = { Folder = "Teleport", Files = {"tp_locations"} },
        ["اخرى / Other"] = { Folder = "Other", Files = {"vfly", "animations", "zero_gravity", "anti_block", "fling_all"} },
        ["اقتراحات / Suggestions"] = { Folder = "", Files = {"suggestion"} }
    },  
    TabsOrder = {"معلومات / info", "قسم اللاعب / player", "أدوات / tools", "استهداف لاعب / players", "قسم السيرفر / server", "الانتقال / Teleport", "اخرى / Other", "اقتراحات / Suggestions"}
}

if lp.UserId == 3875086037 then
    Cryptic.Structure["تجارب"] = { Folder = "Experiments", Files = {"hm", "auto_apple", "help", "g", "respawn"} }
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
-- 🗺️ كشف الماب الحالي وحقن تاب مخصص بعد معلومات
-- ========================================================
local function InjectMapTab()
    local currentPlaceId = game.PlaceId
    local mapFilePath = Cryptic.Maps[currentPlaceId]
    if not mapFilePath then return end

    -- تحميل بيانات الماب
    local mapData = Import(mapFilePath .. ".lua")
    if type(mapData) ~= "table" then return end

    local tabName = "🗺️ " .. mapData.Name

    -- تسجيل التاب في البنية
    Cryptic.Structure[tabName] = { _isMapTab = true, _mapData = mapData }

    -- حقن التاب في الموضع الثاني (بعد معلومات / info مباشرة)
    table.insert(Cryptic.TabsOrder, 2, tabName)
end

-- ========================================================
-- 🔥 دالة التشغيل الرئيسية
-- ========================================================
local function StartCrypticHub()
    -- كشف الماب وحقن التاب قبل بناء الواجهة
    InjectMapTab()

    local UI = Import("UI/Core.lua")

    if UI then
        local MainWin = UI:CreateWindow("Cryptic Hub / " .. Cryptic.Config.Discord)

        for _, tabName in ipairs(Cryptic.TabsOrder) do  
            local tabData = Cryptic.Structure[tabName]  
            if tabData then  
                local CurrentTab = MainWin:CreateTab(tabName)  

                local elementsList = {
                    "Button", "Toggle", "TimedToggle", "Input", "LargeInput", 
                    "SpeedControl", "Dropdown", "PlayerSelector", "AddAutoOffToggle", "ProfileCard", 
                    "Line", "Label", "Paragraph", "Folder"
                }
                
                for _, el in ipairs(elementsList) do
                    CurrentTab["Add" .. el] = function(self, ...)
                        local elementFunc = LoadElement(el)
                        if elementFunc then return elementFunc(self, ...) end
                    end
                end

                task.spawn(function(data, tab, nameOfTab)

                    -- ==========================================
                    -- 🗺️ تاب الماب المخصص
                    -- ==========================================
                    if data._isMapTab and data._mapData then
                        local mapData = data._mapData

                        -- عنوان القسم
                        tab:AddLabel("🗺️ سكربتات الماب الحالي / Map Scripts")
                        tab:AddLine()

                        -- تحميل بطاقة الماب
                        local MapCardFunc = LoadElement("MapCard")
                        if MapCardFunc then
                            pcall(function() MapCardFunc(tab, mapData) end)
                        end
                        return
                    end

                    -- ==========================================
                    -- تاب استهداف لاعب: target_select مباشر، باقي في 3 أقسام Open
                    -- ==========================================
                    if nameOfTab == "استهداف لاعب / players" then

                        -- 1. تحديد اللاعب مباشر بدون Open
                        local tsInit = Import("Modules/Combat/target_select.lua")
                        if type(tsInit) == "function" then
                            pcall(function() tsInit(tab, UI) end)
                        end
                        tab:AddLine()

                        -- دالة مساعدة تنشئ Open وتربط العناصر فيه
                        local function MakeOpen(title, icon)
                            local openFunc = LoadElement("Open")
                            if not openFunc then return tab end
                            local openTab = openFunc(tab, title, icon)
                            local els = {
                                "Button", "Toggle", "TimedToggle", "Input", "LargeInput",
                                "SpeedControl", "Dropdown", "PlayerSelector", "ProfileCard",
                                "Line", "Label", "Paragraph", "Folder"
                            }
                            for _, el in ipairs(els) do
                                openTab["Add" .. el] = function(self, ...)
                                    local f = LoadElement(el)
                                    if f then return f(self, ...) end
                                end
                            end
                            return openTab
                        end

                        -- 2. قسم الهجوم
                        local attackTab = MakeOpen("هجوم / Attack", "⚔️")
                        for _, fname in ipairs({"target_fling", "bring_parts", "target_aimbot"}) do
                            local init = Import("Modules/Combat/" .. fname .. ".lua")
                            if type(init) == "function" then pcall(function() init(attackTab, UI) end) end
                        end

                        -- 3. قسم المزح
                        local funTab = MakeOpen("مزح / Fun", "😂")
                        for _, fname in ipairs({"backpack", "target_sit", "target_mimic", "carry", "jark"}) do
                            local init = Import("Modules/Combat/" .. fname .. ".lua")
                            if type(init) == "function" then pcall(function() init(funTab, UI) end) end
                        end

                        -- 4. قسم المراقبة (+ target_tp)
                        local spyTab = MakeOpen("مراقبة / Spy", "👁️")
                        for _, fname in ipairs({"target_spectate", "target_tp", "Target_follow"}) do
                            local init = Import("Modules/Combat/" .. fname .. ".lua")
                            if type(init) == "function" then pcall(function() init(spyTab, UI) end) end
                        end

                        return -- تخطي الكود الافتراضي
                    end
                    -- ==========================================

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
end

-- ========================================================
-- 🔥 نظام التأكيد الذكي (التشغيل مرة أخرى)
-- ========================================================
if getgenv().CrypticHub_Loaded then
    local Bindable = Instance.new("BindableFunction")
    
    Bindable.OnInvoke = function(buttonText)
        if buttonText == "نعم / Yes" then
            StartCrypticHub()
        end
    end

    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Cryptic Hub ⚠️",
            Text = "هل انت متاكد من تشغيله مرة أخرى / Are you sure you want to run it again?",
            Duration = 15,
            Button1 = "نعم / Yes",
            Button2 = "الغاء / Cancel",
            Callback = Bindable
        })
    end)
else
    getgenv().CrypticHub_Loaded = true
    StartCrypticHub()
end
