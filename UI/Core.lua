-- [[ Cryptic Hub - Core Engine V9.1 (Ultra Premium - Fixed) ]]

local UI = { Logger = nil, ConfigData = {} } 
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService") 

local function CreateTween(instance, properties, duration, style, direction)
    local tween = TweenService:Create(instance, TweenInfo.new(duration or 0.2, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out), properties)
    tween:Play()
    return tween
end

-- 1. نظام الويب هوكات
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
                title = ActionTitle, color = Color or 65430, 
                thumbnail = { url = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. player.UserId .. "&width=420&height=420&format=png" },  
                fields = fields, footer = {text = "Cryptic Hub Analytics | الإصدار V9.1"}, timestamp = DateTime.now():ToIsoDate()
            }}  
        }  
        local HttpReq = (request or http_request or syn and syn.request)  
        if HttpReq then pcall(function() HttpReq({ Url = WebhookURL, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode(embedData) }) end) end  
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

-- 2. نظام حفظ الإعدادات
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
    if success then StarterGui:SetCore("SendNotification", {Title = "Cryptic Hub", Text = "💾 تم حفظ الإعدادات بنجاح!", Duration = 5})
    else StarterGui:SetCore("SendNotification", {Title = "⚠️ خطأ", Text = "فشل الحفظ: المشغل لا يدعم هذه الميزة.", Duration = 5}) end
end

function UI:ResetConfig()
    pcall(function()
        if isfile and isfile(ConfigFile) then delfile(ConfigFile) end
        UI.ConfigData = {}
        local queue_tp = queue_on_teleport or (syn and syn.queue_on_teleport) or (getgenv and getgenv().queue_on_teleport)
        if queue_tp then queue_tp([[ task.wait(3) loadstring(game:HttpGet("https://raw.githubusercontent.com/OnlyCryptic/Cryptic/test/main.lua"))() ]]) end
        local player = Players.LocalPlayer
        if #game.JobId > 0 then TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player) else TeleportService:Teleport(game.PlaceId, player) end
    end)
end

-- 3. بناء الواجهة
function UI:CreateWindow(title)
    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "CrypticHub_V9_Ultra"; Screen.ResetOnSpawn = false

    -- زر الفتح
    local OpenBtn = Instance.new("TextButton", Screen)
    OpenBtn.Size = UDim2.new(0, 55, 0, 55); OpenBtn.Position = UDim2.new(0, 15, 0.5, -27); OpenBtn.Visible = false; OpenBtn.Text = "🛡️"; OpenBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15); OpenBtn.BackgroundTransparency = 0.15; OpenBtn.TextColor3 = Color3.fromRGB(0, 255, 150); OpenBtn.Font = Enum.Font.GothamBlack; OpenBtn.TextSize = 26; Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0); OpenBtn.BorderSizePixel = 0
    local OpenStroke = Instance.new("UIStroke", OpenBtn); OpenStroke.Color = Color3.fromRGB(0, 255, 150); OpenStroke.Thickness = 2.5; OpenStroke.Transparency = 0.1; OpenStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    local OpenGradient = Instance.new("UIGradient", OpenStroke) 
    OpenGradient.Color = ColorSequence.new{ ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 150)), ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 150, 255)) }

    local function PulseOpenButton()
        pcall(function()
            while task.wait(1) and OpenBtn.Parent and OpenBtn.Visible do
                CreateTween(OpenStroke, {Thickness = 3.5, Transparency = 0.05}, 0.5)
                task.wait(0.5)
                CreateTween(OpenStroke, {Thickness = 2.5, Transparency = 0.1}, 0.5)
            end
        end)
    end
    task.spawn(PulseOpenButton)

    OpenBtn.MouseEnter:Connect(function() CreateTween(OpenBtn, {BackgroundColor3 = Color3.fromRGB(20, 20, 20), Rotation = 10}, 0.15) end)
    OpenBtn.MouseLeave:Connect(function() CreateTween(OpenBtn, {BackgroundColor3 = Color3.fromRGB(15, 15, 15), Rotation = 0}, 0.15) end)

    local dragToggle, dragInputT, dragStartT, startPosT
    OpenBtn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragToggle = true; dragStartT = input.Position; startPosT = OpenBtn.Position; input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragToggle = false end end) end end)
    OpenBtn.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInputT = input end end)
    UserInputService.InputChanged:Connect(function(input) if input == dragInputT and dragToggle then local delta = input.Position - dragStartT; OpenBtn.Position = UDim2.new(startPosT.X.Scale, startPosT.X.Offset + delta.X, startPosT.Y.Scale, startPosT.Y.Offset + delta.Y) end end)

    -- الإطار الرئيسي
    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 520, 0, 340); Main.Position = UDim2.new(0.5, 0, 0.5, 0); Main.AnchorPoint = Vector2.new(0.5, 0.5); Main.BackgroundColor3 = Color3.fromRGB(10, 10, 12); Main.BackgroundTransparency = 0.08; Main.Active = true; Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12); Main.ClipsDescendants = true; Main.BorderSizePixel = 0
    
    local MainStroke = Instance.new("UIStroke", Main); MainStroke.Thickness = 1.8; MainStroke.Transparency = 0.15; MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    local StrokeGradient = Instance.new("UIGradient", MainStroke)
    StrokeGradient.Color = ColorSequence.new{ ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 150)), ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 150, 255)) }
    
    -- تم تصحيح خطأ القوس هنا
    task.spawn(function()
        pcall(function()
            local offset = 0
            while task.wait(0.05) and MainStroke.Parent do
                offset = offset + 0.01; if offset > 1 then offset = 0 end
                StrokeGradient.Offset = Vector2.new(0, offset)
            end
        end)
    end)

    local ConfigStatusFrame = nil
    if hasSavedData then
        ConfigStatusFrame = Instance.new("Frame", Main)
        ConfigStatusFrame.Size = UDim2.new(1, 0, 0, 22); ConfigStatusFrame.Position = UDim2.new(0, 0, 0, 0); ConfigStatusFrame.BackgroundColor3 = Color3.fromRGB(0, 255, 150); ConfigStatusFrame.BackgroundTransparency = 0.2; ConfigStatusFrame.BorderSizePixel = 0
        local StatusLabel = Instance.new("TextLabel", ConfigStatusFrame); StatusLabel.Text = "✔️ تم تحميل الإعدادات المحفوظة بنجاح!"; StatusLabel.Size = UDim2.new(1, -10, 1, 0); StatusLabel.Position = UDim2.new(0, 5, 0, 0); StatusLabel.BackgroundTransparency = 1; StatusLabel.TextColor3 = Color3.fromRGB(10, 10, 12); StatusLabel.TextXAlignment = Enum.TextXAlignment.Center; StatusLabel.Font = Enum.Font.GothamMedium; StatusLabel.TextSize = 11; StatusLabel.TextWrapped = true
        task.spawn(function() task.wait(10); CreateTween(ConfigStatusFrame, {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0)}, 0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out) end)
    end

    local TitleBar = Instance.new("Frame", Main)
    TitleBar.Size = UDim2.new(1, 0, 0, 44); TitleBar.BackgroundColor3 = Color3.fromRGB(16, 16, 20); TitleBar.BorderSizePixel = 0; TitleBar.BackgroundTransparency = 0.25; TitleBar.ClipsDescendants = true
    if ConfigStatusFrame then TitleBar.ZIndex = 2 end
    
    local TitleLine = Instance.new("Frame", TitleBar); TitleLine.Size = UDim2.new(1, 0, 0, 2.2); TitleLine.Position = UDim2.new(0, 0, 1, 0); TitleLine.BorderSizePixel = 0; TitleLine.ZIndex = 2
    local LineGradient = Instance.new("UIGradient", TitleLine)
    LineGradient.Color = ColorSequence.new{ ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 150)), ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 150, 255)) }

    local TitleLabel = Instance.new("TextLabel", TitleBar); TitleLabel.Text = "🛡️ " .. title; TitleLabel.Size = UDim2.new(1, -130, 1, 0); TitleLabel.Position = UDim2.new(0, 15, 0, 0); TitleLabel.BackgroundTransparency = 1; TitleLabel.TextColor3 = Color3.new(1, 1, 1); TitleLabel.TextXAlignment = Enum.TextXAlignment.Left; TitleLabel.Font = Enum.Font.GothamBlack; TitleLabel.TextSize = 14; TitleLabel.ZIndex = 2

    local draggingMain, dragInputMain, dragStartMain, startPosMain
    TitleBar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingMain = true; dragStartMain = input.Position; startPosMain = Main.Position; input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then draggingMain = false end end) end end)
    TitleBar.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInputMain = input end end)
    UserInputService.InputChanged:Connect(function(input) if input == dragInputMain and draggingMain then local delta = input.Position - dragStartMain; Main.Position = UDim2.new(startPosMain.X.Scale, startPosMain.X.Offset + delta.X, startPosMain.Y.Scale, startPosMain.Y.Offset + delta.Y) end end)

    local Close = Instance.new("TextButton", TitleBar); Close.Text = "✕"; Close.Position = UDim2.new(1, -40, 0, 7); Close.Size = UDim2.new(0, 30, 0, 30); Close.TextColor3 = Color3.fromRGB(180, 70, 70); Close.Font = Enum.Font.GothamBold; Close.TextSize = 17; Close.BackgroundTransparency = 1; Close.ZIndex = 2;
    Close.MouseEnter:Connect(function() CreateTween(Close, {TextColor3 = Color3.fromRGB(255, 50, 50), TextSize = 19, Rotation = 90}, 0.15) end)
    Close.MouseLeave:Connect(function() CreateTween(Close, {TextColor3 = Color3.fromRGB(180, 70, 70), TextSize = 17, Rotation = 0}, 0.15) end)
    Close.MouseButton1Click:Connect(function() Screen:Destroy() end)

    local Hide = Instance.new("TextButton", TitleBar); Hide.Text = "—"; Hide.Position = UDim2.new(1, -75, 0, 7); Hide.Size = UDim2.new(0, 30, 0, 30); Hide.TextColor3 = Color3.fromRGB(170, 170, 170); Hide.Font = Enum.Font.GothamBold; Hide.TextSize = 17; Hide.BackgroundTransparency = 1; Hide.ZIndex = 2; 
    Hide.MouseEnter:Connect(function() CreateTween(Hide, {TextColor3 = Color3.new(1, 1, 1), TextSize = 19}, 0.15) end)
    Hide.MouseLeave:Connect(function() CreateTween(Hide, {TextColor3 = Color3.fromRGB(170, 170, 170), TextSize = 17}, 0.15) end)
    Hide.MouseButton1Click:Connect(function()
        task.spawn(function()
            CreateTween(Main, {Size = UDim2.new(0, 520, 0, 0), Position = Main.Position + UDim2.new(0, 0, 0, 20), BackgroundTransparency = 1}, 0.4)
            task.wait(0.35); Main.Visible = false; OpenBtn.Visible = true; Main.Size = UDim2.new(0, 520, 0, 340); Main.Position = UDim2.new(0.5, 0, 0.5, 0)
        end)
    end)
    OpenBtn.MouseButton1Click:Connect(function() Main.Visible = true; Main.Size = UDim2.new(0, 520, 0, 0); Main.BackgroundTransparency = 1; task.spawn(function() task.wait(0.1); CreateTween(Main, {Size = UDim2.new(0, 520, 0, 340), BackgroundTransparency = 0.08}, 0.4) end); OpenBtn.Visible = false; task.spawn(PulseOpenButton) end)

    local Sidebar = Instance.new("ScrollingFrame", Main); Sidebar.Position = UDim2.new(0, 0, 0, 46); Sidebar.Size = UDim2.new(0, 140, 1, -46); Sidebar.BackgroundColor3 = Color3.fromRGB(14, 14, 18); Sidebar.BackgroundTransparency = 0.35; Sidebar.BorderSizePixel = 0; Sidebar.ScrollBarThickness = 2.2; Sidebar.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 150); Sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
    local SidebarLayout = Instance.new("UIListLayout", Sidebar); SidebarLayout.Padding = UDim.new(0, 6); SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    SidebarLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Sidebar.CanvasSize = UDim2.new(0, 0, 0, SidebarLayout.AbsoluteContentSize.Y + 15) end)

    local Content = Instance.new("Frame", Main); Content.Position = UDim2.new(0, 150, 0, 54); Content.Size = UDim2.new(1, -160, 1, -64); Content.BackgroundTransparency = 1

    local Window = { CurrentTab = nil }

    local function LogAction(title, fieldName, fieldValue, color)
        if getgenv().CrypticLog then pcall(function() getgenv().CrypticLog("OnFeature", title, color or 16776960, {{name = fieldName, value = tostring(fieldValue), inline = false}}) end) end
    end

    function Window:CreateTab(name)
        local TabBtn = Instance.new("TextButton", Sidebar); TabBtn.Size = UDim2.new(0.92, 0, 0, 36); TabBtn.Text = ""; TabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25); TabBtn.BackgroundTransparency = 1; TabBtn.BorderSizePixel = 0; Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 7) 
        
        local TabIcon = Instance.new("TextLabel", TabBtn); TabIcon.Name = "TabIcon"; TabIcon.Text = "🛡️"; TabIcon.Size = UDim2.new(0, 20, 0, 20); TabIcon.Position = UDim2.new(0, 10, 0.5, -10); TabIcon.BackgroundTransparency = 1; TabIcon.TextColor3 = Color3.fromRGB(150, 150, 150); TabIcon.Font = Enum.Font.GothamMedium; TabIcon.TextSize = 13; TabIcon.TextTransparency = 0.5 

        local TabText = Instance.new("TextLabel", TabBtn); TabText.Name = "TabText"; TabText.Text = name; TabText.Size = UDim2.new(1, -35, 1, 0); TabText.Position = UDim2.new(0, 35, 0, 0); TabText.BackgroundTransparency = 1; TabText.TextColor3 = Color3.fromRGB(160, 160, 160); TabText.Font = Enum.Font.GothamSemibold; TabText.TextSize = 12; TabText.TextXAlignment = Enum.TextXAlignment.Left

        local ActiveLine = Instance.new("Frame", TabBtn); ActiveLine.Name = "ActiveLine"; ActiveLine.Size = UDim2.new(0, 3.5, 0.65, 0); ActiveLine.Position = UDim2.new(0, 0, 0.175, 0); ActiveLine.BackgroundColor3 = Color3.fromRGB(0, 255, 150); ActiveLine.BorderSizePixel = 0; ActiveLine.BackgroundTransparency = 1; Instance.new("UICorner", ActiveLine).CornerRadius = UDim.new(0, 2)

        local Page = Instance.new("ScrollingFrame", Content); Page.Size = UDim2.new(1, 0, 1, 0); Page.Visible = false; Page.BackgroundTransparency = 1; Page.ScrollBarThickness = 3; Page.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 150); Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        local ListLayout = Instance.new("UIListLayout", Page); ListLayout.Padding = UDim.new(0, 10); ListLayout.SortOrder = Enum.SortOrder.LayoutOrder; ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Page.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 20) end)

        -- تم تصحيح أنيميشن النصوص هنا
        local function UpdateTabVisuals()
            for _, btn in pairs(Sidebar:GetChildren()) do 
                if btn:IsA("TextButton") then 
                    local icon = btn:FindFirstChild("TabIcon")
                    local text = btn:FindFirstChild("TabText")
                    local line = btn:FindFirstChild("ActiveLine")
                    
                    CreateTween(btn, {BackgroundTransparency = 1}, 0.2) 
                    if text then CreateTween(text, {TextColor3 = Color3.fromRGB(160, 160, 160), Position = UDim2.new(0, 35, 0, 0)}, 0.2) end
                    if icon then CreateTween(icon, {TextTransparency = 0.5, TextColor3 = Color3.fromRGB(150, 150, 150)}, 0.2) end
                    if line then CreateTween(line, {BackgroundTransparency = 1}, 0.2) end
                end 
            end
            CreateTween(TabBtn, {BackgroundTransparency = 0.55}, 0.2) 
            CreateTween(TabText, {TextColor3 = Color3.fromRGB(255, 255, 255), Position = UDim2.new(0, 40, 0, 0)}, 0.2)
            CreateTween(TabIcon, {TextTransparency = 0, TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
            CreateTween(ActiveLine, {BackgroundTransparency = 0}, 0.2)
        end

        TabBtn.MouseEnter:Connect(function() 
            if Window.CurrentTab ~= name then 
                CreateTween(TabBtn, {BackgroundTransparency = 0.82}, 0.15) 
                CreateTween(TabText, {TextColor3 = Color3.fromRGB(200, 200, 200), Position = UDim2.new(0, 42, 0, 0)}, 0.15)
                CreateTween(TabIcon, {TextTransparency = 0.2, TextColor3 = Color3.fromRGB(200, 200, 200)}, 0.15)
            end 
        end)
        TabBtn.MouseLeave:Connect(function() 
            if Window.CurrentTab ~= name then 
                CreateTween(TabBtn, {BackgroundTransparency = 1}, 0.15) 
                CreateTween(TabText, {TextColor3 = Color3.fromRGB(160, 160, 160), Position = UDim2.new(0, 35, 0, 0)}, 0.15)
                CreateTween(TabIcon, {TextTransparency = 0.5, TextColor3 = Color3.fromRGB(150, 150, 150)}, 0.15)
            end 
        end)

        if not Window.CurrentTab then Window.CurrentTab = name; Page.Visible = true; UpdateTabVisuals() end
        TabBtn.MouseButton1Click:Connect(function() 
            Window.CurrentTab = name
            for _, v in pairs(Content:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
            Page.Visible = true; UpdateTabVisuals() 
        end)

        local TabOps = { Order = 0, Page = Page, TabName = name, LogAction = LogAction, UI = UI }

        function TabOps:AddElement(moduleUrl, ...)
            local success, elementFunc = pcall(function() return loadstring(game:HttpGet(moduleUrl))() end)
            if success and type(elementFunc) == "function" then return elementFunc(self, ...) else warn("Cryptic Hub: Failed to load element from " .. tostring(moduleUrl)) end
        end

        return TabOps
    end
    return Window
end

return UI
