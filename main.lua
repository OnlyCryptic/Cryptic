-- [[ Cryptic Hub - المحرك الرئيسي الشامل ]]
-- المطور: Arwa
-- التوافق: Redmi Note 10s للهواتف

local Cryptic = {
    Config = {
        UserName = "OnlyCryptic", 
        RepoName = "Cryptic",  
        Branch   = "main",
        -- رابط الويب هوك الخاص بك للمراقبة
        Webhook  = "https://discord.com/api/webhooks/1476744644183199834/w8CnCw7ehZom4b0MXkb0L4bCd9fy0sQs7LX4HZb4JfFUrqPqykwagx3hybF0UaY8ATr2"
    },
    
    -- هيكل المشروع المنظم
    Structure = {
        ["قسم اللاعب"] = {
            Folder = "Player",
            Files  = {"speed", "fly"} 
        },
        ["قسم لاعبين"] = {
            Folder = "Combat",
            Files  = {"esp"} 
        },
        ["أخرى"] = {
            Folder = "Misc",
            Files  = {}
        }
    }
}

local lp = game.Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- وظيفة إرسال التقارير إلى ديسكورد
local function SendLog(action, details)
    local gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
    local data = {
        ["embeds"] = {{
            ["title"] = "🚀 Cryptic Hub | تقرير نشاط",
            ["color"] = 0x00FF96, -- لون نيون
            ["fields"] = {
                {["name"] = "الحدث", ["value"] = action, ["inline"] = true},
                {["name"] = "التفاصيل", ["value"] = details or "N/A", ["inline"] = true},
                {["name"] = "اسم اللاعب", ["value"] = lp.Name, ["inline"] = true},
                {["name"] = "المعرف (ID)", ["value"] = tostring(lp.UserId), ["inline"] = true},
                {["name"] = "اللعبة (Place)", ["value"] = gameName, ["inline"] = false}
            },
            ["footer"] = {["text"] = "نظام مراقبة كربتك هب"}
        }}
    }
    
    pcall(function()
        local json = HttpService:JSONEncode(data)
        request({
            Url = Cryptic.Config.Webhook,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = json
        })
    end)
end

-- بناء روابط الـ Raw من GitHub
local RawURL = "https://raw.githubusercontent.com/" .. Cryptic.Config.UserName .. "/" .. Cryptic.Config.RepoName .. "/" .. Cryptic.Config.Branch .. "/"

local function Import(path)
    local success, result = pcall(function() return game:HttpGet(RawURL .. path) end)
    if success and result then
        local func, err = loadstring(result)
        if func then return func() else warn("❌ خطأ برمجي: " .. path) end
    end
    return nil
end

-- ==========================================
-- تشغيل السكربت
-- ==========================================

-- إرسال تقرير التشغيل الأول
SendLog("تشغيل السكربت", "قام المستخدم بفتح الواجهة بنجاح")

-- تحميل محرك الواجهة
local UI = Import("UI_Engine.lua")

if UI then
    -- تمرير وظيفة المراقبة للمحرك لكي يستخدمها في الأزرار
    UI.Logger = SendLog 
    
    local MainWin = UI:CreateWindow("Cryptic Hub | كربتك")

    -- تحميل الميزات بناءً على الهيكل
    for tabName, info in pairs(Cryptic.Structure) do
        local CurrentTab = MainWin:CreateTab(tabName)
        
        for _, fileName in pairs(info.Files) do
            local filePath = "Modules/" .. info.Folder .. "/" .. fileName .. ".lua"
            pcall(function()
                local featureInit = Import(filePath)
                if type(featureInit) == "function" then
                    featureInit(CurrentTab, UI) 
                end
            end)
        end
    end

    UI:Notify("أهلاً بك يا أروى! السكربت جاهز.")
else
    warn("❌ فشل تحميل UI_Engine.lua")
end
