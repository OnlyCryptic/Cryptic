-- [[ Cryptic Hub - المحرك الرئيسي المطور ]]
-- المطور: Arwa
-- النسخة: 1.2.0

local Cryptic = {
    Config = {
        UserName = "OnlyCryptic", 
        RepoName = "Cryptic",  
        Branch   = "main"
    },
    
    -- هيكل المشروع: هنا أضفنا "fly" لتظهر في الواجهة
    Structure = {
        ["قسم اللاعب"] = {
            Folder = "Player",
            Files  = {"speed", "fly"} -- ملفات المجلد Modules/Player/
        },
        ["قسم القتال"] = {
            Folder = "Combat",
            Files  = {} -- يمكنك إضافة "kill_aura" هنا لاحقاً
        },
        ["أخرى"] = {
            Folder = "Misc",
            Files  = {}
        }
    }
}

-- بناء رابط GitHub Raw
local RawURL = "https://raw.githubusercontent.com/" .. Cryptic.Config.UserName .. "/" .. Cryptic.Config.RepoName .. "/" .. Cryptic.Config.Branch .. "/"

-- وظيفة جلب الملفات
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
        warn("❌ تعذر تحميل: " .. path)
    end
    return nil
end

-- ==========================================
-- تشغيل المحرك
-- ==========================================

print("🚀 جاري تحميل Cryptic Hub لـ Arwa...")

-- 1. تحميل واجهة المستخدم (UI_Engine.lua)
local UI = Import("UI_Engine.lua")

if UI then
    -- 2. إنشاء النافذة الرئيسية (تدعم السحب والتحكم بالهاتف)
    local MainWin = UI:CreateWindow("Cryptic Hub | كربتك")

    -- 3. تحميل الأقسام والمجلدات والملفات تلقائياً
    for tabName, info in pairs(Cryptic.Structure) do
        -- إنشاء صفحة لكل قسم (مثال: قسم اللاعب)
        local CurrentTab = MainWin:CreateTab(tabName)
        
        for _, fileName in pairs(info.Files) do
            local filePath = "Modules/" .. info.Folder .. "/" .. fileName .. ".lua"
            
            -- تحميل ميزة (speed أو fly) وتمرير الصفحة لها
            pcall(function()
                local featureInit = Import(filePath)
                if type(featureInit) == "function" then
                    featureInit(CurrentTab, UI) 
                end
            end)
        end
    end

    UI:Notify("تم تحميل ميزات اللاعب (سرعة + طيران) بنجاح!")
else
    warn("❌ تأكدي من وجود ملف UI_Engine.lua في مستودع GitHub.")
end
