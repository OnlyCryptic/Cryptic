-- [[ Cryptic Hub - الملف الرئيسي ]]
-- المطور: Arwa
-- الوصف: المحمل الذكي للأقسام والواجهة

local Cryptic = {
    Version = "1.0.0",
    BaseURL = "https://raw.githubusercontent.com/USERNAME/REPO_NAME/main/", -- استبدل USERNAME و REPO_NAME ببياناتك
    Categories = {
        "Player",   -- سيتم البحث عن Modules/Player.lua
        "Combat",   -- سيتم البحث عن Modules/Combat.lua
        "Misc",     -- سيتم البحث عن Modules/Misc.lua
        "Settings"  -- سيتم البحث عن Modules/Settings.lua
    }
}

-- وظيفة التحميل الآمن من GitHub
local function SecureLoad(path)
    local success, result = pcall(function()
        return game:HttpGet(Cryptic.BaseURL .. path)
    end)
    if success then return result end
    warn("❌ فشل تحميل الملف: " .. path)
    return nil
end

-- 1. تحميل محرك الواجهة (UI Engine)
print("⏳ جاري تحميل واجهة Cryptic...")
local UIEngineCode = SecureLoad("UI_Engine.lua")
if UIEngineCode then
    local UI = loadstring(UIEngineCode)()
    
    -- إنشاء النافذة الرئيسية (بالعربية)
    local MainWin = UI:CreateWindow({
        Title = "Cryptic Hub | كربتك",
        Subtitle = "الإصدار " .. Cryptic.Version,
        MobileOptimized = true -- تفعيل وضع الهاتف
    })

    -- 2. تحميل الأقسام تلقائياً
    for _, categoryName in pairs(Cryptic.Categories) do
        local categoryFile = "Modules/" .. categoryName .. ".lua"
        local code = SecureLoad(categoryFile)
        
        if code then
            -- تشغيل ملف القسم وتمرير واجهة المستخدم له ليضيف أزراره
            local success, module = pcall(function()
                return loadstring(code)()(MainWin, UI)
            end)
            
            if success then
                print("✅ تم تحميل قسم: " .. categoryName)
            else
                print("⚠️ خطأ في تشغيل قسم " .. categoryName .. ": " .. module)
            end
        end
    end
    
    UI:Notify("تم تحميل السكربت بنجاح! استمتع يا أروى.")
end
