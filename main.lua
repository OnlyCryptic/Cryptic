-- [[ Cryptic Hub - المحرك الرئيسي ]]
-- المطور: Arwa
-- هذا الملف يقوم بتحميل الواجهة ثم الأوامر من المجلدات تلقائياً

local Cryptic = {
    -- 1. إعدادات الروابط (استبدلي الروابط ببيانات مستودعك)
    Config = {
        UserName = "YOUR_GITHUB_NAME", -- اسمك في جيت هوب
        RepoName = "YOUR_REPO_NAME",  -- اسم المستودع
        Branch   = "main"
    },
    
    -- 2. هيكل المشروع (المجلدات والملفات التي بداخلها)
    -- هذا هو "الفهرس" الذي يخبر السكربت ماذا يحمل
    Structure = {
        ["قسم اللاعب"] = {
            Folder = "Player",
            Files  = {"speed", "fly", "jump"} -- أسماء الملفات في مجلد Player بدون .lua
        },
        ["قسم القتال"] = {
            Folder = "Combat",
            Files  = {"kill_aura", "hitbox"} -- أسماء الملفات في مجلد Combat بدون .lua
        },
        ["أخرى"] = {
            Folder = "Misc",
            Files  = {"anti_afk", "rejoin"}
        }
    }
}

-- رابط القاعدة لجلب الملفات الخام (Raw)
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

print("🚀 جاري تشغيل Cryptic Hub...")

-- 1. تحميل محرك الواجهة (UI_Engine.lua)
local UI = Import("UI_Engine.lua")

if UI then
    -- 2. إنشاء النافذة الرئيسية
    local MainWin = UI:CreateWindow({
        Title = "Cryptic Hub | كربتك",
        Description = "نظام السكربتات المنظم",
        AccentColor = Color3.fromRGB(0, 255, 150) -- لون النيون
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
                    featureInit(CurrentTab, UI) -- نرسل الصفحة والمحرك للملف الفرعي
                end
            end)
        end
    end

    UI:Notify("تم تحميل جميع الأقسام بنجاح! استمتع.")
else
    warn("❌ فشل تحميل محرك الواجهة الأساسي.")
end
