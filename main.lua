-- [[ Cryptic Hub - المحرك الرئيسي V8.0 (النسخة المجزأة + تصحيح مسار Element) ]]

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local Cryptic = {
    Config = {
        UserName = "OnlyCryptic", RepoName = "Cryptic", Branch = "main", -- فرع رئيسي
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

local function Import(path)
    local url = "https://raw.githubusercontent.com/" .. Cryptic.Config.UserName .. "/" .. Cryptic.Config.RepoName .. "/" .. Cryptic.Config.Branch .. "/" .. path .. "?v=" .. tick()
    local s, r = pcall(game.HttpGet, game, url)
    if s and r then
        if r:match("404: Not Found") then
            warn("❌ خطأ: الملف غير موجود في GitHub! المسار: " .. path)
            return nil
        end
        local f, compileErr = loadstring(r)
        if f then 
            return f() 
        else
            warn("❌ خطأ في برمجة الملف: " .. path .. " | السبب: " .. tostring(compileErr))
        end
    else
        warn("❌ فشل الاتصال بالإنترنت لجلب: " .. path)
    end
    return nil
end

local ElementCache = {}

local function LoadElement(elementName)
    if ElementCache[elementName] then return ElementCache[elementName] end
    
    -- 🟢 تم التعديل هنا: Element بدون حرف s ليتوافق مع مجلدك في GitHub
    local path = "UI/Element/" .. elementName .. ".lua"
    local url = "https://raw.githubusercontent.com/" .. Cryptic.Config.UserName .. "/" .. Cryptic.Config.RepoName .. "/" .. Cryptic.Config.Branch .. "/" .. path .. "?v=" .. tick()
    local s, r = pcall(game.HttpGet, game, url)
    if s and r then
        if r:match("404: Not Found") then
            warn("❌ خطأ: عنصر الواجهة مفقود! المسار: " .. path)
            return nil
        end
        local chunk = loadstring(r)
        if chunk then 
            local func = chunk()
            ElementCache[elementName] = func
            return func
        end
    end
    warn("❌ فشل تحميل العنصر: " .. elementName)
    return nil
end

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
                        local success, err = pcall(function()   
                            init(tab, UI)  
                            tab:AddLine()  
                        end)
                        if not success then
                            warn("❌ خطأ أثناء تشغيل الملف: " .. filePath .. " | السبب: " .. tostring(err))
                        end
                    end  
                end  
                
                if nameOfTab == "معلومات / info" then
                    tab:AddButton("💾 حفظ الإعدادات / save config", function() pcall(function() UI:SaveConfig() end) end)
                    tab:AddButton("🔄 مسح اعدادات محفوضه / restart config", function() pcall(function() UI:ResetConfig() end) end)
                end
                
            end, tabData, CurrentTab, tabName)  
        end  
    end  
end
