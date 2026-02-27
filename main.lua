-- [[ Cryptic Hub - المحرك الرئيسي V3.5 ]]
-- المطور: Arwa | تعديل ترتيب الأقسام ونقل ESP

local Cryptic = {
    Config = {
        UserName = "OnlyCryptic", RepoName = "Cryptic", Branch = "main",
        Discord = "https://discord.gg/QSvQJs7BdP",
        Webhook = "https://discord.com/api/webhooks/1476744644183199834/w8CnCw7ehZom4b0MXkb0L4bCd9fy0sQs7LX4HZb4JfFUrqPqykwagx3hybF0UaY8ATr2"
    },
    Structure = {
        ["معلومات"] = { Folder = "Misc", Files = {"info"} },
        ["قسم اللاعب"] = { Folder = "Player", Files = {"speed", "fly", "noclip", "antifling"} },
        
        -- نقلنا esp إلى قسم أدوات (يقرأ من مجلد Misc)
        ["أدوات"] = { Folder = "Misc", Files = {"tptool", "emotes", "esp"} },
        
        -- تم تغيير الاسم إلى "ستهداف لاعب" وبقي فيه المراقبة فقط
        ["ستهداف لاعب"] = { Folder = "Combat", Files = {"spectate"} },
        
        ["قسم السيرفر"] = { Folder = "Misc", Files = {"server", "rejoin"} }
    },
    
    -- تحديث ترتيب ظهور الأقسام في القائمة الجانبية
    TabsOrder = {"معلومات", "قسم اللاعب", "أدوات", "ستهداف لاعب", "قسم السيرفر"}
}

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

local function SendWebhookLog()
    task.spawn(function()
        if Cryptic.Config.Webhook == "" then return end
        local executor = identifyexecutor and identifyexecutor() or "مُشغل غير معروف"
        local gameName = "ماب غير معروف"
        pcall(function() gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name end)

        local data = {
            ["embeds"] = {{
                ["title"] = "🚀 Arwa Hub - تشغيل جديد!",
                ["color"] = tonumber("00FF96", 16),
                ["fields"] = {
                    {["name"] = "👤 اللاعب:", ["value"] = lp.DisplayName .. " (@" .. lp.Name .. ")", ["inline"] = true},
                    {["name"] = "🎮 الماب:", ["value"] = gameName, ["inline"] = true},
                    {["name"] = "💻 المشغل (Executor):", ["value"] = executor, ["inline"] = true},
                    {["name"] = "🔗 رمز السيرفر (JobId):", ["value"] = "```" .. game.JobId .. "```", ["inline"] = false}
                },
                ["footer"] = {["text"] = "Arwa Hub Analytics | " .. os.date("%Y/%m/%d")}
            }}
        }
        local requestFunc = request or http_request or (http and http.request) or syn.request
        if requestFunc then pcall(function() requestFunc({Url = Cryptic.Config.Webhook, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode(data)}) end) end
    end)
end

local function Import(path)
    local s, r = pcall(game.HttpGet, game, "https://raw.githubusercontent.com/" .. Cryptic.Config.UserName .. "/" .. Cryptic.Config.RepoName .. "/" .. Cryptic.Config.Branch .. "/" .. path)
    if s and r then local f = loadstring(r); if f then return f() end end return nil
end

local UI = Import("UI_Engine.lua")
if UI then
    local MainWin = UI:CreateWindow("Cryptic Hub | كربتك")
    for _, tabName in ipairs(Cryptic.TabsOrder) do
        local info = Cryptic.Structure[tabName]
        if info then
            local CurrentTab = MainWin:CreateTab(tabName)
            for i, fileName in ipairs(info.Files) do
                local filePath = "Modules/" .. info.Folder .. "/" .. fileName .. ".lua"
                local init = Import(filePath)
                if type(init) == "function" then
                    init(CurrentTab, UI)
                    if i < #info.Files then CurrentTab:AddLine() end
                end
            end
        end
    end
    SendWebhookLog()
end
