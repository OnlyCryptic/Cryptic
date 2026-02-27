-- [[ Cryptic Hub - المحرك الرئيسي المطور ]]
-- المطور: Arwa
-- التوافق: للهواتف (Redmi Note 10s)

local Cryptic = {
    -- إعدادات مستودع GitHub الخاص بك
    Config = {
        UserName = "OnlyCryptic", 
        RepoName = "Cryptic",  
        Branch   = "main"
    },
    
    -- هيكل المشروع: توزيع المجلدات والملفات على الأقسام
    Structure = {
        ["قسم اللاعب"] = {
            Folder = "Player",
            Files  = {"speed", "fly"} -- تحميل ميزات السرعة والطيران
        },
        ["قسم لاعبين"] = { -- تم تغيير الاسم ليكون "قسم لاعبين" في الواجهة
            Folder = "Combat",
            Files  = {"esp"} -- تحميل ميزة الكشف
        },
        ["أخرى"] = {
            Folder = "Misc",
            Files  = {} -- هنا يمكنك إضافة ملفات مثل anti_afk لاحقاً
        }
    }
}

-- بناء رابط الـ Raw لجلب الملفات من GitHub
local RawURL = "https://raw.githubusercontent.com/" .. Cryptic.Config.UserName .. "/" .. Cryptic.Config.RepoName .. "/" .. Cryptic.Config.Branch .. "/"

-- وظيفة استيراد الملفات وتشغيلها برمجياً
local function Import(path)
    local success, result = pcall(function()
        return game:HttpGet(RawURL .. path)
    end)
    
    if success and result then
        local func, err = loadstring(result)
        if func then
            return func()
        else
            warn("❌ خطأ في كود الملف: " .. path .. " | " .. tostring(err))
        end
    else
        warn("❌ تعذر الوصول للملف: " .. path)
    end
    return nil
end

-- ==========================================
-- بداية تشغيل السكربت
-- ==========================================

print("🚀 جاري تحميل Cryptic Hub...")

-- 1. تحميل محرك الواجهة المخصص للهاتف (UI_Engine.lua)
local UI = Import("UI_Engine.lua")

if UI then
    -- 2. إنشاء النافذة الرئيسية (تدعم السحب، الإخفاء، والإغلاق)
    local MainWin = UI:CreateWindow("Cryptic Hub | كربتك")

    -- 3. بناء الأقسام وتحميل الملفات تلقائياً
    for tabName, info in pairs(Cryptic.Structure) do
        -- إنشاء صفحة في القائمة الجانبية (Sidebar)
        local CurrentTab = MainWin:CreateTab(tabName)
        
        for _, fileName in pairs(info.Files) do
            local filePath = "Modules/" .. info.Folder .. "/" .. fileName .. ".lua"
            
            -- تحميل الملف الفرعي وتمرير الصفحة له ليضيف أزراره
            pcall(function()
                local featureInit = Import(filePath)
                if type(featureInit) == "function" then
                    featureInit(CurrentTab, UI) 
                end
            end)
        end
    end

    UI:Notify("تم تحميل السكربت بنجاح! استمتع يا أروى.")
else
    warn("❌ فشل تحميل UI_Engine.lua. تأكد من رفعه في المجلد الرئيسي للمستودع.")
end
