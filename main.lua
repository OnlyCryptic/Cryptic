-- [[ Cryptic Hub - المحرك الرئيسي ]]
-- المطور: Arwa
-- هذا الملف يقوم بتحميل الواجهة ثم الأوامر من المجلدات تلقائياً

local Cryptic = {
    -- 1. إعدادات الروابط الخاصة بمستودعك
    Config = {
        UserName = "OnlyCryptic", 
        RepoName = "Cryptic",  
        Branch   = "main"
    },
    
    -- 2. هيكل المشروع (تأكدي من وجود هذه المجلدات والملفات في GitHub)
    Structure = {
        ["قسم اللاعب"] = {
            Folder = "Player",
            Files  = {"speed", "fly", "jump"} 
        },
        ["قسم القتال"] = {
            Folder = "Combat",
            Files  = {"kill_aura", "hitbox"}
        },
        ["أخرى"] = {
            Folder = "Misc",
            Files  = {"anti_afk", "rejoin"}
        }
    }
}

-- رابط القاعدة لجلب الملفات الخام (Raw) من مستودع OnlyCryptic
local RawURL = "https://raw.githubusercontent.com/" .. Cryptic.Config.UserName .. "/" .. Cryptic.Config.RepoName .. "/" .. Cryptic.Config.Branch .. "/"

-- وظيفة ذكية لتحميل الملفات وتشغيلها
local function Import(path)
    local success, result = pcall(function()
        return game:HttpGet(RawURL .. path)
    end)
    
    if success and result then
        local func, err = loadstring(result)
        if func then
            return func()
        else
            warn("❌ خطأ برمجي في ملف " .. path .. ": " .. err)
        end
    else
        warn("❌ تعذر جلب الملف من المسار: " .. path)
    end
    return nil
end

-- ==========================================
-- بداية تشغيل السكربت
-- ==========================================

print("🚀 جاري تشغيل Cryptic Hub الخاص بـ OnlyCryptic...")

-- 1. تحميل محرك الواجهة (UI_Engine.lua)
-- تأكدي أن ملف UI_Engine.lua موجود في المجلد الرئيسي للمستودع
local UI = Import("UI_Engine.lua")

if UI then
    -- 2. إنشاء النافذة الرئيسية
    local MainWin = UI:CreateWindow({
        Title = "Cryptic Hub | كربتك",
        Description = "نظام السكربتات المنظم",
        AccentColor = Color3.fromRGB(0, 255, 150) -- لون النيون الأخضر
    })

    -- 3. تحميل الأقسام والملفات بناءً على الهيكل
    for tabName, info in pairs(Cryptic.Structure) do
        -- إنشاء صفحة (Tab) لكل مجلد
        local CurrentTab = MainWin:CreateTab(tabName)
        
        for _, fileName in pairs(info.Files) do
            -- بناء مسار الملف (مثال: Modules/Player/speed.lua)
            local filePath = "Modules/" .. info.Folder .. "/" .. fileName .. ".lua"
            
            -- تحميل ملف الميزة وتمرير الـ Tab له ليضيف أزراره فيه
            pcall(function()
                local featureInit = Import(filePath)
                if type(featureInit) == "function" then
                    featureInit(CurrentTab, UI) 
                end
            end)
        end
    end

    UI:Notify("تم تحميل جميع الأقسام بنجاح! استمتع يا أروى.")
else
    warn("❌ فشل تحميل محرك الواجهة الأساسي (UI_Engine.lua). تأكدي من رفعه على GitHub.")
end
