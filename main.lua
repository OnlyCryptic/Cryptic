-- [[ Cryptic Hub - Loader ]]
-- هذا الملف يقوم بجلب النسخة المستقرة من فرع التجارب تلقائياً

local success, err = pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/OnlyCryptic/Cryptic/test/main.lua?v="..tick()))()
end)

if not success then
    warn("❌ Cryptic Hub Error: " .. tostring(err))
end
