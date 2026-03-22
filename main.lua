-- [[ Cryptic Hub - المحرك الرئيسي V8.1 (نظام التأكيد الذكي) ]]
-- المطور: يامي | الوصف: حماية من التكرار مع رسالة تأكيد (نعم/إلغاء)

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

local Cryptic = {
    Config = {
        UserName = "OnlyCryptic", RepoName = "Cryptic", Branch = "test", 
        Discord = "https://discord.gg/QSvQJs7BdP"
    },

    Structure = {  
        ["معلومات / info"] = { Folder = "", Files = {"info"} },   
        ["قسم اللاعب / player"] = { Folder = "Player", Files = {"speed", "fly", "noclip", "walkfling", "antifling", "wallwalk", "nofall", "infinitejump"} },  
        ["أدوات / tools"] = { Folder = "Misc", Files = {"tptool", "auto_tool", "esp", "shiftlock", "emotes", "x-ray", "fullbright", "camera"} },  
        ["استهداف لاعب / players"] = { Folder = "Combat", Files = {"target_select", "target_tp", "target_spectate", "target_aimbot", "target_sit", "target_mimic", "target_fling", "bring_parts", "carry", "jark"} },  
        ["قسم السيرفر / server"] = { Folder = "Server", Files = {"server", "rejoin", "join_id"} },  
        ["الانتقال / Teleport"] = { Folder = "Teleport", Files = {"tp_locations"} },
        ["اخرى / Other"] = { Folder = "Other", Files = {"animations", "vfly", "zero_gravity", "anti_block", "fling_all"} },
        ["اقتراحات / Suggestions"] = { Folder = "", Files = {"suggestion"} }
    },  
    TabsOrder = {"معلومات / info", "قسم اللاعب / player", "أدوات / tools", "استهداف لاعب / players", "قسم السيرفر / server", "الانتقال / Teleport", "اخرى / Other", "اقتراحات / Suggestions"}
}

if lp.UserId == 3875086037 then
    Cryptic.Structure["تجارب"] = { Folder = "Experiments", Files = {"hm", "auto_apple", "help"} }
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
-- 🔥 دالة التشغيل الرئيسية (مغلفة لتشتغل وقت الحاجة فقط)
-- ========================================================
local function StartCrypticHub()
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
                    "Line", "Label", "Paragraph", "Folder"
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
end

-- ========================================================
-- 🔥 نظام التأكيد الذكي (التشغيل مرة أخرى)
-- ========================================================
if getgenv().CrypticHub_Loaded then
    local Bindable = Instance.new("BindableFunction")
    
    Bindable.OnInvoke = function(buttonText)
        if buttonText == "نعم / Yes" then
            -- إذا وافق اللاعب، يتم استدعاء دالة التشغيل من جديد
            StartCrypticHub()
        end
        -- إذا ضغط "الغاء / Cancel" لن يحدث شيء وسيتوقف التنفيذ
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
    -- إذا كانت هذه أول مرة يشتغل فيها السكربت
    getgenv().CrypticHub_Loaded = true
    StartCrypticHub()
end
