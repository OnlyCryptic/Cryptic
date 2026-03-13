-- [[ Cryptic Hub - Loader ]]
-- هذا الملف في الفرع الرئيسي يقوم بتشغيل فرع التجارب (test) تلقائياً

local success, err = pcall(function()
    -- أضفنا ?v=tick لضمان تحميل آخر تحديث من GitHub بدون تأخير الكاش
    loadstring(game:HttpGet("https://raw.githubusercontent.com/OnlyCryptic/Cryptic/test/main.lua?v="..tick()))()
end)

if not success then
    warn("❌ Cryptic Hub Loader Error: " .. tostring(err))
end
