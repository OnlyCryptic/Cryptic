-- [[ Cryptic Hub - Core Engine V8.1 (Glassmorphism UI) ]]

local UI = { Logger = nil, ConfigData = {} } 
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

-- ==========================================
-- 1. نظام الويب هوكات (Webhooks)
-- ==========================================
local SecretWebhooks = {
    OnExecute = "https://cryptic-analytics.bossekasiri2.workers.dev",
    OnFeature = "https://cryptic-features.bossekasiri2.workers.dev",
    OnError   = "https://cryptic-errors.bossekasiri2.workers.dev",
    OnSuggestion = "https://cryptic-suggestions.bossekasiri2.workers.dev"
}

local function SendWebhookLog(LogCategory, ActionTitle, Color, ExtraFields)
    if Players.LocalPlayer.UserId == 3875086037 then return end

    task.spawn(function()
        local WebhookURL = SecretWebhooks[LogCategory]
        if not WebhookURL or WebhookURL == "" then return end

        local player = Players.LocalPlayer
        local placeName = "Unknown Game"
        pcall(function() placeName = MarketplaceService:GetProductInfo(game.PlaceId).Name end)
        local executorName = (type(identifyexecutor) == "function" and identifyexecutor()) or "Unknown Executor"  
        
        local fields = {  
            {name = "👤 اللاعب:", value = player.DisplayName .. " (@" .. player.Name .. ")\n**ID:** " .. player.UserId, inline = true},  
            {name = "💻 المشغل:", value = executorName, inline = true},  
            {name = "🎮 الماب:", value = placeName .. "\n**PlaceID:** " .. game.PlaceId, inline = false}
        }

        if ExtraFields then
            for _, field in ipairs(ExtraFields) do
                local valStr = tostring(field.value)
                if string.len(valStr) > 1000 then
                    table.insert(fields, {name = field.name .. " [الجزء 1]", value = string.sub(valStr, 1, 1000), inline = false})
                    table.insert(fields, {name = field.name .. " [الجزء 2]", value = string.sub(valStr, 1001, 2000), inline = false})
                else
                    table.insert(fields, field)
                end
            end
        end

        local embedData = {  
            embeds = {{  
                title = ActionTitle,  
                color = Color or 65430, 
                thumbnail = { url = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. player.UserId .. "&width=420&height=420&format=png" },  
                fields = fields,  
                footer = {text = "Cryptic Hub Analytics | الإصدار V8.1"},
                timestamp = DateTime.now():ToIsoDate()
            }}  
        }  

        local HttpReq = (request or http_request or syn and syn.request)  
        if HttpReq then  
            pcall(function()  
                HttpReq({ Url = WebhookURL, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode(embedData) })  
            end)  
        end  
    end)
end

getgenv().CrypticLog = SendWebhookLog

task.spawn(function()
    local serverPlayersCount = #Players:GetPlayers()  
    local maxPlayers = Players.MaxPlayers  
    SendWebhookLog("OnExecute", "🚀 تشغيل جديد - Cryptic Hub!", 65430, {
        {name = "👥 حالة السيرفر الحالي:", value = serverPlayersCount .. " / " .. maxPlayers .. " لاعبين", inline = true},
        {name = "🔗 JobId (للانضمام):", value = "" .. game.JobId .. "", inline = false}
    })
end)

-- ==========================================
-- 2. نظام حفظ الإعدادات (Config System)
-- ==========================================
local ConfigFile = "CrypticHub_Settings.json"
local hasSavedData = false

pcall(function()
    if isfile and isfile(ConfigFile) then
        local content = readfile(ConfigFile)
        local data = HttpService:JSONDecode(content)
        if type(data) == "table" and next(data) ~= nil then
            UI.ConfigData = data
            hasSavedData = true
        end
    end
end)

function UI:SaveConfig()
    local success, err = pcall(function() writefile(ConfigFile, HttpService:JSONEncode(UI.ConfigData)) end)
    local StarterGui = game:GetService("StarterGui")
    if success then
        StarterGui:SetCore("SendNotification", {Title = "Cryptic Hub", Text = "💾 تم حفظ الإعدادات بنجاح!", Duration = 5})
    else
        StarterGui:SetCore("SendNotification", {Title = "⚠️ خطأ", Text = "فشل الحفظ: المشغل لا يدعم هذه الميزة.", Duration = 5})
    end
end

function UI:ResetConfig()
    pcall(function()
        if isfile and isfile(ConfigFile) then delfile(ConfigFile) end
        UI.ConfigData = {}
        local queue_tp = queue_on_teleport or (syn and syn.queue_on_teleport) or (getgenv and getgenv().queue_on_teleport)
        if queue_tp then
            -- ملاحظة: الرابط هنا لفرع test عشان تجاربك
            queue_tp([[ task.wait(3) loadstring(game:HttpGet("https://raw.githubusercontent.com/OnlyCryptic/Cryptic/test/main.lua"))() ]])
        end
        local player = Players.LocalPlayer
        if #game.JobId > 0 then TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player) else TeleportService:Teleport(game.PlaceId, player) end
    end)
end

-- ==========================================
-- 3. بناء الواجهة (Window & Core UI)
-- ==========================================
function UI:CreateWindow(title)
    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "CrypticHub_V8_Modular"; Screen.ResetOnSpawn = false

    if hasSavedData then
        local Callback = Instance.new("BindableFunction")
        Callback.OnInvoke = function(buttonName)
            if buttonName == "مسح اعدادات محفوضه" then
                UI.ConfigData = {} 
                game:GetService("StarterGui"):SetCore("SendNotification", { Title = "Cryptic Hub", Text = "🔄 جاري مسح الإعدادات...", Duration = 5 })
                task.spawn(function() task.wait(0.5) UI:ResetConfig() end)
            end
        end
        pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", { Title = "Cryptic Hub 🚀", Text = "تم تحميل إعداداتك المحفوظة بنجاح.", Duration = 10, Button1 = "حسناً", Button2 = "مسح اعدادات محفوضه", Callback = Callback }) end)
    end

    local OpenBtn = Instance.new("TextButton", Screen)
    OpenBtn.Size = UDim2.new(0, 38, 0, 38)
    OpenBtn.Position = UDim2.new(0, 15, 0.5, -19)
    OpenBtn.Visible = false
    OpenBtn.Text = "C"
    OpenBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    OpenBtn.BackgroundTransparency = 0.4 
    OpenBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
    OpenBtn.Font = Enum.Font.GothamBold
    OpenBtn.TextSize = 20
    Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)
    
    local OpenStroke = Instance.new("UIStroke", OpenBtn)
    OpenStroke.Color = Color3.fromRGB(0, 255, 150)
    OpenStroke.Thickness = 1.5
    OpenStroke.Transparency = 0.3

    local dragToggle, dragInputT, dragStartT, startPosT
    OpenBtn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragToggle = true; dragStartT = input.Position; startPosT = OpenBtn.Position; input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragToggle = false end end) end end)
    OpenBtn.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInputT = input end end)
    UserInputService.InputChanged:Connect(function(input) if input == dragInputT and dragToggle then local delta = input.Position - dragStartT; OpenBtn.Position = UDim2.new(startPosT.X.Scale, startPosT.X.Offset + delta.X, startPosT.Y.Scale, startPosT.Y.Offset + delta.Y) end end)

    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 480, 0, 300) 
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = Color3.fromRGB(10, 10, 12) 
    Main.BackgroundTransparency = 0.05 
    Main.Active = true
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
    Main.ClipsDescendants = true 

    local MainStroke = Instance.new("UIStroke", Main)
    MainStroke.Color = Color3.fromRGB(0, 255, 150)
    MainStroke.Thickness = 1.2
    MainStroke.Transparency = 0.5

    local TitleBar = Instance.new("Frame", Main)
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    TitleBar.BorderSizePixel = 0
    
    local TitleLine = Instance.new("Frame", TitleBar)
    TitleLine.Size = UDim2.new(1, 0, 0, 1)
    TitleLine.Position = UDim2.new(0, 0, 1, 0)
    TitleLine.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
    TitleLine.BackgroundTransparency = 0.6
    TitleLine.BorderSizePixel = 0

    local TitleLabel = Instance.new("TextLabel", TitleBar)
    TitleLabel.Text = title
    TitleLabel.Size = UDim2.new(1, -120, 1, 0)
    TitleLabel.Position = UDim2.new(0, 15, 0, 0) 
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.TextColor3 = Color3.new(1, 1, 1)
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Font = Enum.Font.GothamBlack 
    TitleLabel.TextSize = 14

    local draggingMain, dragInputMain, dragStartMain, startPosMain
    TitleBar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingMain = true; dragStartMain = input.Position; startPosMain = Main.Position; input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then draggingMain = false end end) end end)
    TitleBar.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInputMain = input end end)
    UserInputService.InputChanged:Connect(function(input) if input == dragInputMain and draggingMain then local delta = input.Position - dragStartMain; Main.Position = UDim2.new(startPosMain.X.Scale, startPosMain.X.Offset + delta.X, startPosMain.Y.Scale, startPosMain.Y.Offset + delta.Y) end end)

    local Close = Instance.new("TextButton", TitleBar)
    Close.Text = "✕" 
    Close.Position = UDim2.new(1, -40, 0, 5)
    Close.Size = UDim2.new(0, 30, 0, 30)
    Close.TextColor3 = Color3.fromRGB(255, 75, 75)
    Close.Font = Enum.Font.GothamBold
    Close.TextSize = 16
    Close.BackgroundTransparency = 1
    Close.MouseButton1Click:Connect(function() Screen:Destroy() end)

    local Hide = Instance.new("TextButton", TitleBar)
    Hide.Text = "—" 
    Hide.Position = UDim2.new(1, -75, 0, 5)
    Hide.Size = UDim2.new(0, 30, 0, 30)
    Hide.TextColor3 = Color3.new(1, 1, 1)
    Hide.Font = Enum.Font.GothamBold
    Hide.TextSize = 16
    Hide.BackgroundTransparency = 1
    Hide.MouseButton1Click:Connect(function() Main.Visible = false; OpenBtn.Visible = true end)
    OpenBtn.MouseButton1Click:Connect(function() Main.Visible = true; OpenBtn.Visible = false end)

    local Sidebar = Instance.new("ScrollingFrame", Main)
    Sidebar.Position = UDim2.new(0, 0, 0, 41)
    Sidebar.Size = UDim2.new(0, 130, 1, -41)
    Sidebar.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
    Sidebar.BorderSizePixel = 0
    Sidebar.ScrollBarThickness = 2
    Sidebar.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 150) 
    Sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local SidebarLayout = Instance.new("UIListLayout", Sidebar)
    SidebarLayout.Padding = UDim.new(0, 4) 
    SidebarLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Sidebar.CanvasSize = UDim2.new(0, 0, 0, SidebarLayout.AbsoluteContentSize.Y + 10) end)

    local Content = Instance.new("Frame", Main)
    Content.Position = UDim2.new(0, 140, 0, 50) 
    Content.Size = UDim2.new(1, -150, 1, -60)
    Content.BackgroundTransparency = 1

    local Window = { FirstTab = nil }

    local function LogAction(title, fieldName, fieldValue, color)
        if getgenv().CrypticLog then pcall(function() getgenv().CrypticLog("OnFeature", title, color or 16776960, {{name = fieldName, value = tostring(fieldValue), inline = false}}) end) end
    end

    function Window:CreateTab(name)
        local TabBtn = Instance.new("TextButton", Sidebar)
        TabBtn.Size = UDim2.new(1, -10, 0, 35)
        TabBtn.Position = UDim2.new(0, 5, 0, 0)
        TabBtn.Text = name
        TabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
        TabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
        TabBtn.Font = Enum.Font.GothamSemibold
        TabBtn.TextSize = 12
        TabBtn.BorderSizePixel = 0
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6) 

        local Page = Instance.new("ScrollingFrame", Content)
        Page.Size = UDim2.new(1,
