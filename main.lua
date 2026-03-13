-- [[ Cryptic Hub - المحرك الرئيسي V8.0 (النسخة المجزأة - Modular) ]]
-- المطور: يامي (Yami) | التحديث: دمج النظام المجزأ وربط العناصر تلقائياً

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
        ["أدوات / tools"] = { Folder = "Misc", Files = {"tptool", "auto_tool", "esp", "shiftlock", "emotes", "camera", "fullbright"} },  
        ["استهداف لاعب / players"] = { Folder = "Combat", Files = {"target_select", "target_tp", "target_spectate", "target_aimbot", "target_sit", "target_mimic", "target_fling", "carry"} },  
        ["قسم السيرفر / server"] = { Folder = "Server", Files = {"server", "rejoin", "join_id"} },  
        ["الانتقال / Teleport"] = { Folder = "Teleport", Files = {"tp_method", "tp_save", "tp_locations"} },
        ["اخرى / Other"] = { Folder = "Other", Files = {"vfly", "zero_gravity", "anti_block", "fling_all"} },
        ["اقتراحات / Suggestions"] = { Folder = "", Files = {"suggestion"} }
    },  
    TabsOrder = {"معلومات / info", "قسم اللاعب / player", "أدوات / tools", "استهداف لاعب / players", "قسم السيرفر / server", "الانتقال / Teleport", "اخرى / Other", "اقتراحات / Suggestions"}
}

if Players.LocalPlayer.UserId == 3875086037 then
    Cryptic.Structure["تجارب"] = {
        Folder = "Experiments",
        Files = {"owner_only", "block_surfer", "hm", "closest_aimbot", "auto_apple", "part_flinger"}
    }
    table.insert(Cryptic.TabsOrder, "تجارب")
end

-- دالة الاستدعاء العادية للملفات
local function Import(path)
    local url = "https://raw.githubusercontent.com/" .. Cryptic.Config.UserName .. "/" .. Cryptic.Config.RepoName .. "/" .. Cryptic.Config.Branch .. "/" .. path .. "?v=" .. tick()
    local s, r = pcall(game.HttpGet, game, url)
    if s and r then
        local f = loadstring(r)
        if f then return f() end
    end
    return nil
end

-- دالة مساعدة لتوليد روابط العناصر المجزأة بسرعة
local function GetElementURL(elementName)
    return "https://raw.githubusercontent.com/" .. Cryptic.Config.UserName .. "/" .. Cryptic.Config.RepoName .. "/" .. Cryptic.Config.Branch .. "/UI/Elements/" .. elementName .. ".lua?v=" .. tick()
end

-- 1. تغيير مسار الواجهة إلى ملف النواة الجديد
local UI = Import("UI/Core.lua")

if UI then
    local MainWin = UI:CreateWindow("Cryptic Hub / " .. Cryptic.Config.Discord)

    for _, tabName in ipairs(Cryptic.TabsOrder) do  
        local tabData = Cryptic.Structure[tabName]  
        if tabData then  
            local CurrentTab = MainWin:CreateTab(tabName)  

            -- 2. "الحيلة العبقرية": ربط الدوال القديمة بالملفات الجديدة تلقائياً
            -- هذا سيجعل ملفاتك القديمة تعمل بدون أي تعديل عليها!
            CurrentTab.AddButton = function(self, ...) return self:AddElement(GetElementURL("Button"), ...) end
            CurrentTab.AddToggle = function(self, ...) return self:AddElement(GetElementURL("Toggle"), ...) end
            CurrentTab.AddTimedToggle = function(self, ...) return self:AddElement(GetElementURL("TimedToggle"), ...) end
            CurrentTab.AddInput = function(self, ...) return self:AddElement(GetElementURL("Input"), ...) end
            CurrentTab.AddLargeInput = function(self, ...) return self:AddElement(GetElementURL("LargeInput"), ...) end
            CurrentTab.AddSpeedControl = function(self, ...) return self:AddElement(GetElementURL("SpeedControl"), ...) end
            CurrentTab.AddDropdown = function(self, ...) return self:AddElement(GetElementURL("Dropdown"), ...) end
            CurrentTab.AddPlayerSelector = function(self, ...) return self:AddElement(GetElementURL("PlayerSelector"), ...) end
            CurrentTab.AddProfileCard = function(self, ...) return self:AddElement(GetElementURL("ProfileCard"), ...) end
            CurrentTab.AddLine = function(self, ...) return self:AddElement(GetElementURL("Line"), ...) end
            CurrentTab.AddLabel = function(self, ...) return self:AddElement(GetElementURL("Label"), ...) end
            CurrentTab.AddParagraph = function(self, ...) return self:AddElement(GetElementURL("Paragraph"), ...) end
              
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
                    -- تم تحديث أزرار الحفظ لتستخدم النظام الجديد (الملفات)
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
