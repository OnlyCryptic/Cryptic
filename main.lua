-- [[ Cryptic Hub - المحرك الشامل ]]
local Cryptic = {
    UserName = "OnlyCryptic",
    RepoName = "Cryptic",
    Branch   = "main",
    
    -- الفهرس: أضف أسماء الملفات هنا فقط وسيقوم السكربت بالباقي
    Structure = {
        ["اللاعب"] = { Folder = "Player", Files = {"speed"} }, -- أضف "fly" هنا لاحقاً
        ["القتال"] = { Folder = "Combat", Files = {} },
        ["أخرى"]   = { Folder = "Misc",   Files = {} }
    }
}

local RawURL = "https://raw.githubusercontent.com/"..Cryptic.UserName.."/"..Cryptic.RepoName.."/"..Cryptic.Branch.."/"

local function Import(path)
    local s, r = pcall(game.HttpGet, game, RawURL..path)
    if s and r then
        local f, e = loadstring(r)
        if f then return f() end
        warn("خطأ في ملف "..path..": "..tostring(e))
    end
    return nil
end

-- تشغيل الواجهة
local UI = Import("UI_Engine.lua")
if UI then
    local MainWin = UI:CreateWindow("كربتك هب | Cryptic")

    -- تحميل المجلدات والملفات تلقائياً
    for tabName, info in pairs(Cryptic.Structure) do
        local Tab = MainWin:CreateTab(tabName)
        for _, fileName in pairs(info.Files) do
            local scriptFunc = Import("Modules/"..info.Folder.."/"..fileName..".lua")
            if type(scriptFunc) == "function" then
                scriptFunc(Tab, UI)
            end
        end
    end
    UI:Notify("تم تشغيل Cryptic بنجاح!")
end
