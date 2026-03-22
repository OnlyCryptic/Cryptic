-- [[ Cryptic Hub - Core Engine V8.5 (Compact + Clean Startup) ]]

local UI = { Logger = nil, ConfigData = {} } 
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")

local function CreateTween(instance, properties, duration)
    local tween = TweenService:Create(instance, TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), properties)
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
                fields = fields, footer = {text = "Cryptic Hub Analytics | الإصدار V8.5 Compact"}, timestamp = DateTime.now():ToIsoDate()
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
    Screen.Name = "CrypticHub_V8_Premium"; Screen.ResetOnSpawn = false

    local OpenBtn = Instance.new("TextButton", Screen)
    OpenBtn.Size = UDim2.new(0, 42, 0, 42); OpenBtn.Position = UDim2.new(0, 15, 0.5, -21); OpenBtn.Visible = false; OpenBtn.Text = "C"; OpenBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15); OpenBtn.BackgroundTransparency = 0.2; OpenBtn.TextColor3 = Color3.fromRGB(0, 255, 150); OpenBtn.Font = Enum.Font.GothamBlack; OpenBtn.TextSize = 22; Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)
    local OpenStroke = Instance.new("UIStroke", OpenBtn); OpenStroke.Color = Color3.fromRGB(0, 255, 150); OpenStroke.Thickness = 2; OpenStroke.Transparency = 0.1
    local OpenGradient = Instance.new("UIGradient", OpenStroke) 
    OpenGradient.Color = ColorSequence.new{ ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 150)), ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 150, 255)) }
    OpenBtn.MouseEnter:Connect(function() CreateTween(OpenBtn, {BackgroundTransparency = 0}, 0.2) end)
    OpenBtn.MouseLeave:Connect(function() CreateTween(OpenBtn, {BackgroundTransparency = 0.2}, 0.2) end)

    local dragToggle, dragInputT, dragStartT, startPosT
    OpenBtn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragToggle = true; dragStartT = input.Position; startPosT = OpenBtn.Position; input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragToggle = false end end) end end)
    OpenBtn.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInputT = input end end)
    UserInputService.InputChanged:Connect(function(input) if input == dragInputT and dragToggle then local delta = input.Position - dragStartT; OpenBtn.Position = UDim2.new(startPosT.X.Scale, startPosT.X.Offset + delta.X, startPosT.Y.Scale, startPosT.Y.Offset + delta.Y) end end)

    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 440, 0, 280); Main.Position = UDim2.new(0.5, 0, 0.5, 0); Main.AnchorPoint = Vector2.new(0.5, 0.5); Main.BackgroundColor3 = Color3.fromRGB(12, 12, 14); Main.BackgroundTransparency = 0.1; Main.Active = true; Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10); Main.ClipsDescendants = true 
    local MainStroke = Instance.new("UIStroke", Main); MainStroke.Thickness = 1.5; MainStroke.Transparency = 0.2
    local StrokeGradient = Instance.new("UIGradient", MainStroke)
    StrokeGradient.Color = ColorSequence.new{ ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 150)), ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 150, 255)) }

    local TitleBar = Instance.new("Frame", Main)
    TitleBar.Size = UDim2.new(1, 0, 0, 40); TitleBar.BackgroundColor3 = Color3.fromRGB(18, 18, 22); TitleBar.BorderSizePixel = 0; TitleBar.BackgroundTransparency = 0.3
    local TitleLine = Instance.new("Frame", TitleBar); TitleLine.Size = UDim2.new(1, 0, 0, 2); TitleLine.Position = UDim2.new(0, 0, 1, 0); TitleLine.BorderSizePixel = 0
    local LineGradient = Instance.new("UIGradient", TitleLine)
    LineGradient.Color = ColorSequence.new{ ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 150)), ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 150, 255)) }
    local TitleLabel = Instance.new("TextLabel", TitleBar); TitleLabel.Text = title; TitleLabel.Size = UDim2.new(1, -90, 1, 0); TitleLabel.Position = UDim2.new(0, 15, 0, 0); TitleLabel.BackgroundTransparency = 1; TitleLabel.TextColor3 = Color3.new(1, 1, 1); TitleLabel.TextXAlignment = Enum.TextXAlignment.Left; TitleLabel.Font = Enum.Font.GothamBlack; TitleLabel.TextSize = 14

    local draggingMain, dragInputMain, dragStartMain, startPosMain
    TitleBar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingMain = true; dragStartMain = input.Position; startPosMain = Main.Position; input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then draggingMain = false end end) end end)
    TitleBar.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInputMain = input end end)
    UserInputService.InputChanged:Connect(function(input) if input == dragInputMain and draggingMain then local delta = input.Position - dragStartMain; Main.Position = UDim2.new(startPosMain.X.Scale, startPosMain.X.Offset + delta.X, startPosMain.Y.Scale, startPosMain.Y.Offset + delta.Y) end end)

    local Close = Instance.new("TextButton", TitleBar); Close.Text = "X"; Close.Position = UDim2.new(1, -35, 0, 5); Close.Size = UDim2.new(0, 30, 0, 30); Close.TextColor3 = Color3.fromRGB(200, 75, 75); Close.Font = Enum.Font.GothamBold; Close.TextSize = 16; Close.BackgroundTransparency = 1
    Close.MouseEnter:Connect(function() CreateTween(Close, {TextColor3 = Color3.fromRGB(255, 50, 50), TextSize = 18}, 0.15) end)
    Close.MouseLeave:Connect(function() CreateTween(Close, {TextColor3 = Color3.fromRGB(200, 75, 75), TextSize = 16}, 0.15) end)
    Close.MouseButton1Click:Connect(function() 
        local confirmBindable = Instance.new("BindableFunction")
        confirmBindable.OnInvoke = function(choice)
            if choice == "إغلاق / Close" then Screen:Destroy() end
        end
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Cryptic Hub",
            Text = "هل أنت متأكد من إغلاق السكربت؟ / Are you sure you want to close the script?",
            Duration = 5, Button1 = "إغلاق / Close", Button2 = "إلغاء / Cancel", Callback = confirmBindable
        })
    end)

    local Hide = Instance.new("TextButton", TitleBar); Hide.Text = "—"; Hide.Position = UDim2.new(1, -70, 0, 5); Hide.Size = UDim2.new(0, 30, 0, 30); Hide.TextColor3 = Color3.fromRGB(180, 180, 180); Hide.Font = Enum.Font.GothamBold; Hide.TextSize = 16; Hide.BackgroundTransparency = 1
    Hide.MouseEnter:Connect(function() CreateTween(Hide, {TextColor3 = Color3.new(1, 1, 1), TextSize = 18}, 0.15) end)
    Hide.MouseLeave:Connect(function() CreateTween(Hide, {TextColor3 = Color3.fromRGB(180, 180, 180), TextSize = 16}, 0.15) end)
    Hide.MouseButton1Click:Connect(function() CreateTween(Main, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.3); task.wait(0.25); Main.Visible = false; OpenBtn.Visible = true end)
    OpenBtn.MouseButton1Click:Connect(function() Main.Visible = true; CreateTween(Main, {Size = UDim2.new(0, 440, 0, 280), BackgroundTransparency = 0.1}, 0.3); OpenBtn.Visible = false end)

    local Sidebar = Instance.new("ScrollingFrame", Main); Sidebar.Position = UDim2.new(0, 0, 0, 42); Sidebar.Size = UDim2.new(0, 120, 1, -42); Sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 18); Sidebar.BackgroundTransparency = 0.4; Sidebar.BorderSizePixel = 0; Sidebar.ScrollBarThickness = 2; Sidebar.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 150); Sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
    local SidebarLayout = Instance.new("UIListLayout", Sidebar); SidebarLayout.Padding = UDim.new(0, 5); SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    SidebarLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Sidebar.CanvasSize = UDim2.new(0, 0, 0, SidebarLayout.AbsoluteContentSize.Y + 15) end)

    local Content = Instance.new("Frame", Main); Content.Position = UDim2.new(0, 130, 0, 50); Content.Size = UDim2.new(1, -140, 1, -60); Content.BackgroundTransparency = 1

    local Window = { CurrentTab = nil }

    local function LogAction(title, fieldName, fieldValue, color)
        if getgenv().CrypticLog then pcall(function() getgenv().CrypticLog("OnFeature", title, color or 16776960, {{name = fieldName, value = tostring(fieldValue), inline = false}}) end) end
    end

    function Window:CreateTab(name)
        local TabBtn = Instance.new("TextButton", Sidebar); TabBtn.Size = UDim2.new(0.9, 0, 0, 35); TabBtn.Text = name; TabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25); TabBtn.BackgroundTransparency = 1; TabBtn.TextColor3 = Color3.fromRGB(170, 170, 170); TabBtn.Font = Enum.Font.GothamSemibold; TabBtn.TextSize = 11; TabBtn.BorderSizePixel = 0; Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6) 
        
        -- نقطة إشعار حمراء على التاب
        local NotifDot = Instance.new("Frame", TabBtn)
        NotifDot.Size = UDim2.new(0, 8, 0, 8)
        NotifDot.Position = UDim2.new(1, -10, 0, 4)
        NotifDot.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        NotifDot.BackgroundTransparency = 1
        Instance.new("UICorner", NotifDot).CornerRadius = UDim.new(1, 0)


        local ActiveLine = Instance.new("Frame", TabBtn); ActiveLine.Size = UDim2.new(0, 3, 0.6, 0); ActiveLine.Position = UDim2.new(0, 0, 0.2, 0); ActiveLine.BackgroundColor3 = Color3.fromRGB(0, 255, 150); ActiveLine.BorderSizePixel = 0; ActiveLine.BackgroundTransparency = 1; Instance.new("UICorner", ActiveLine)

        local Page = Instance.new("ScrollingFrame", Content); Page.Size = UDim2.new(1, 0, 1, 0); Page.Visible = false; Page.BackgroundTransparency = 1; Page.ScrollBarThickness = 3; Page.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 150); Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        local ListLayout = Instance.new("UIListLayout", Page); ListLayout.Padding = UDim.new(0, 10); ListLayout.SortOrder = Enum.SortOrder.LayoutOrder; ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Page.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 20) end)

        local function UpdateTabVisuals()
            for _, btn in pairs(Sidebar:GetChildren()) do 
                if btn:IsA("TextButton") then 
                    CreateTween(btn, {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(170, 170, 170)}, 0.2)
                    if btn:FindFirstChild("Frame") then CreateTween(btn.Frame, {BackgroundTransparency = 1}, 0.2) end
                end 
            end
            CreateTween(TabBtn, {BackgroundTransparency = 0.5, TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
            CreateTween(ActiveLine, {BackgroundTransparency = 0}, 0.2)
        end

        TabBtn.MouseEnter:Connect(function() if Window.CurrentTab ~= name then CreateTween(TabBtn, {BackgroundTransparency = 0.8, TextColor3 = Color3.fromRGB(200, 200, 200)}, 0.15) end end)
        TabBtn.MouseLeave:Connect(function() if Window.CurrentTab ~= name then CreateTween(TabBtn, {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(170, 170, 170)}, 0.15) end end)

        if not Window.CurrentTab then Window.CurrentTab = name; Page.Visible = true; UpdateTabVisuals() end
        TabBtn.MouseButton1Click:Connect(function() 
            Window.CurrentTab = name
            for _, v in pairs(Content:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
            Page.Visible = true; UpdateTabVisuals()
            -- إخفاء النقطة لما يدخل التاب
            NotifDot.BackgroundTransparency = 1
        end)

        local TabOps = { Order = 0, Page = Page, TabName = name, LogAction = LogAction, UI = UI, _TabBtn = TabBtn, _NotifDot = NotifDot }

        function TabOps:AddElement(moduleUrl, ...)
            local success, elementFunc = pcall(function() return loadstring(game:HttpGet(moduleUrl))() end)
            if success and type(elementFunc) == "function" then return elementFunc(self, ...) else warn("Cryptic Hub: Failed to load element from " .. tostring(moduleUrl)) end
        end

        -- ==============================
        -- دالة الشات المدمج
        -- ==============================
        function TabOps:AddChat(workerUrl, secretKey, repliesUrl)
            local lp = Players.LocalPlayer
            local WORKER = workerUrl
            local KEY = secretKey
            local REPLIES = repliesUrl

            local function HttpReq(method, path, body)
                local req = (request or http_request or syn and syn.request)
                if not req then return nil end
                local ok, res = pcall(function()
                    return req({
                        Url = WORKER .. path,
                        Method = method,
                        Headers = { ["Content-Type"] = "application/json", ["X-Cryptic-Key"] = KEY },
                        Body = body and HttpService:JSONEncode(body) or nil
                    })
                end)
                if ok and res and res.Body then
                    local sok, data = pcall(function() return HttpService:JSONDecode(res.Body) end)
                    if sok then return data end
                end
                return nil
            end

            local function FetchReplies()
                local ok, raw = pcall(game.HttpGet, game, REPLIES .. "?v=" .. tick())
                if ok and raw then
                    local sok, data = pcall(function() return HttpService:JSONDecode(raw) end)
                    if sok and type(data) == "table" then return data end
                end
                return {}
            end

            local function FormatTime(iso)
                if not iso then return "" end
                local h, m = iso:match("T(%d+):(%d+)")
                if h and m then
                    local hour = tonumber(h)
                    local ampm = hour >= 12 and "PM" or "AM"
                    hour = hour % 12; if hour == 0 then hour = 12 end
                    return string.format("%d:%s %s", hour, m, ampm)
                end
                return ""
            end

            self.Order = self.Order + 1

            -- ==============================
            -- شرح مختصر
            -- ==============================
            local HintFrame = Instance.new("Frame", self.Page)
            HintFrame.LayoutOrder = self.Order
            HintFrame.Size = UDim2.new(0.98, 0, 0, 38)
            HintFrame.BackgroundColor3 = Color3.fromRGB(0, 40, 28)
            HintFrame.BackgroundTransparency = 0.3
            Instance.new("UICorner", HintFrame).CornerRadius = UDim.new(0, 8)

            local HintLbl = Instance.new("TextLabel", HintFrame)
            HintLbl.Size = UDim2.new(1, -12, 1, 0)
            HintLbl.Position = UDim2.new(0, 6, 0, 0)
            HintLbl.BackgroundTransparency = 1
            HintLbl.Text = "💡 اكتب اقتراحك أو مشكلة واجهتها وسيرد عليك المطور\nWrite your suggestion or bug and the dev will reply"
            HintLbl.TextColor3 = Color3.fromRGB(0, 220, 130)
            HintLbl.Font = Enum.Font.Gotham
            HintLbl.TextSize = 9
            HintLbl.TextWrapped = true
            HintLbl.TextXAlignment = Enum.TextXAlignment.Left

            -- ==============================
            -- إطار الرسائل (قابل للسحب)
            -- ==============================
            self.Order = self.Order + 1

            local ChatFrame = Instance.new("Frame", self.Page)
            ChatFrame.LayoutOrder = self.Order
            ChatFrame.Size = UDim2.new(0.98, 0, 0, 200)
            ChatFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
            ChatFrame.BackgroundTransparency = 0.1
            Instance.new("UICorner", ChatFrame).CornerRadius = UDim.new(0, 10)
            local cfStroke = Instance.new("UIStroke", ChatFrame)
            cfStroke.Thickness = 1.2
            cfStroke.Transparency = 0.4
            local cfGrad = Instance.new("UIGradient", cfStroke)
            cfGrad.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 150)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 150, 255))
            }

            -- هيدر صغير
            local ChatHeader = Instance.new("Frame", ChatFrame)
            ChatHeader.Size = UDim2.new(1, 0, 0, 28)
            ChatHeader.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
            ChatHeader.BackgroundTransparency = 0.2
            ChatHeader.BorderSizePixel = 0
            Instance.new("UICorner", ChatHeader).CornerRadius = UDim.new(0, 10)

            local ChatTitle = Instance.new("TextLabel", ChatHeader)
            ChatTitle.Size = UDim2.new(1, -10, 1, 0)
            ChatTitle.Position = UDim2.new(0, 10, 0, 0)
            ChatTitle.BackgroundTransparency = 1
            ChatTitle.Text = "💬 المحادثة مع المطور / Chat with Dev"
            ChatTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
            ChatTitle.Font = Enum.Font.GothamBold
            ChatTitle.TextSize = 10
            ChatTitle.TextXAlignment = Enum.TextXAlignment.Left

            -- منطقة الرسائل قابلة للسكرول
            local MsgArea = Instance.new("ScrollingFrame", ChatFrame)
            MsgArea.Position = UDim2.new(0, 6, 0, 32)
            MsgArea.Size = UDim2.new(1, -12, 1, -80)
            MsgArea.BackgroundTransparency = 1
            MsgArea.ScrollBarThickness = 3
            MsgArea.ScrollBarImageColor3 = Color3.fromRGB(0, 200, 120)
            MsgArea.CanvasSize = UDim2.new(0, 0, 0, 0)
            MsgArea.ScrollingDirection = Enum.ScrollingDirection.Y
            local MsgLayout = Instance.new("UIListLayout", MsgArea)
            MsgLayout.Padding = UDim.new(0, 6)
            MsgLayout.SortOrder = Enum.SortOrder.LayoutOrder
            local MsgPad = Instance.new("UIPadding", MsgArea)
            MsgPad.PaddingTop = UDim.new(0, 4)
            MsgPad.PaddingBottom = UDim.new(0, 4)
            MsgLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                MsgArea.CanvasSize = UDim2.new(0, 0, 0, MsgLayout.AbsoluteContentSize.Y + 12)
                MsgArea.CanvasPosition = Vector2.new(0, math.huge)
            end)

            -- فاصل
            local Divider = Instance.new("Frame", ChatFrame)
            Divider.Size = UDim2.new(0.95, 0, 0, 1)
            Divider.Position = UDim2.new(0.025, 0, 1, -46)
            Divider.BackgroundTransparency = 0.6
            local DivGrad = Instance.new("UIGradient", Divider)
            DivGrad.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 150)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 150, 255))
            }

            -- منطقة الكتابة في الأسفل
            local InputFrame = Instance.new("Frame", ChatFrame)
            InputFrame.Size = UDim2.new(1, -12, 0, 36)
            InputFrame.Position = UDim2.new(0, 6, 1, -42)
            InputFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
            InputFrame.BackgroundTransparency = 0.2
            Instance.new("UICorner", InputFrame).CornerRadius = UDim.new(0, 8)
            local InputStroke = Instance.new("UIStroke", InputFrame)
            InputStroke.Thickness = 1
            InputStroke.Transparency = 0.7
            InputStroke.Color = Color3.fromRGB(0, 255, 150)

            local TxtBox = Instance.new("TextBox", InputFrame)
            TxtBox.Size = UDim2.new(1, -46, 1, -8)
            TxtBox.Position = UDim2.new(0, 10, 0, 4)
            TxtBox.BackgroundTransparency = 1
            TxtBox.TextColor3 = Color3.new(1, 1, 1)
            TxtBox.PlaceholderText = "✏️ اكتب هنا... / Type here..."
            TxtBox.PlaceholderColor3 = Color3.fromRGB(70, 70, 80)
            TxtBox.Font = Enum.Font.Gotham
            TxtBox.TextSize = 11
            TxtBox.TextXAlignment = Enum.TextXAlignment.Left
            TxtBox.TextWrapped = false
            TxtBox.ClearTextOnFocus = false
            TxtBox.Text = ""
            -- هايلايت عند الفوكس
            TxtBox.Focused:Connect(function()
                CreateTween(InputStroke, {Transparency = 0, Thickness = 1.2}, 0.15)
            end)
            TxtBox.FocusLost:Connect(function()
                CreateTween(InputStroke, {Transparency = 0.7, Thickness = 1}, 0.15)
            end)

            local SendBtn = Instance.new("TextButton", InputFrame)
            SendBtn.Size = UDim2.new(0, 32, 0, 26)
            SendBtn.Position = UDim2.new(1, -38, 0.5, -13)
            SendBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 110)
            SendBtn.Text = "↑"
            SendBtn.TextColor3 = Color3.new(1, 1, 1)
            SendBtn.Font = Enum.Font.GothamBold
            SendBtn.TextSize = 15
            Instance.new("UICorner", SendBtn).CornerRadius = UDim.new(0, 6)
            SendBtn.MouseEnter:Connect(function() CreateTween(SendBtn, {BackgroundColor3 = Color3.fromRGB(0, 220, 130)}, 0.15) end)
            SendBtn.MouseLeave:Connect(function() CreateTween(SendBtn, {BackgroundColor3 = Color3.fromRGB(0, 180, 110)}, 0.15) end)

            -- ==============================
            -- إضافة رسالة للواجهة
            -- ==============================
            local msgOrder = 0
            local function AddMsgRow(msgData)
                msgOrder = msgOrder + 1
                local isDev = msgData.type == "dev"
                local msgText = msgData.message or ""
                local extraH = math.max(0, math.floor(string.len(msgText) / 28)) * 13

                local row = Instance.new("Frame", MsgArea)
                row.LayoutOrder = msgOrder
                row.BackgroundTransparency = 1
                row.Size = UDim2.new(1, 0, 0, 46 + extraH)

                if isDev then
                    -- رسالة المطور: أيقونة + اسم أخضر يسار
                    local devIcon = Instance.new("TextLabel", row)
                    devIcon.Size = UDim2.new(0, 22, 0, 22)
                    devIcon.Position = UDim2.new(0, 0, 0, 2)
                    devIcon.BackgroundColor3 = Color3.fromRGB(0, 60, 40)
                    devIcon.BackgroundTransparency = 0.2
                    devIcon.Text = "👑"
                    devIcon.TextSize = 12
                    devIcon.Font = Enum.Font.Gotham
                    devIcon.TextXAlignment = Enum.TextXAlignment.Center
                    Instance.new("UICorner", devIcon).CornerRadius = UDim.new(1, 0)

                    local nameL = Instance.new("TextLabel", row)
                    nameL.Position = UDim2.new(0, 26, 0, 2)
                    nameL.Size = UDim2.new(0.5, 0, 0, 13)
                    nameL.BackgroundTransparency = 1
                    nameL.Text = "المطور / Dev"
                    nameL.TextColor3 = Color3.fromRGB(0, 220, 130)
                    nameL.Font = Enum.Font.GothamBold
                    nameL.TextSize = 10
                    nameL.TextXAlignment = Enum.TextXAlignment.Left

                    local bubble = Instance.new("Frame", row)
                    bubble.Position = UDim2.new(0, 26, 0, 17)
                    bubble.Size = UDim2.new(0.88, 0, 0, 24 + extraH)
                    bubble.BackgroundColor3 = Color3.fromRGB(0, 55, 38)
                    bubble.BackgroundTransparency = 0.2
                    Instance.new("UICorner", bubble).CornerRadius = UDim.new(0, 7)

                    local msgL = Instance.new("TextLabel", bubble)
                    msgL.Size = UDim2.new(1, -10, 1, 0)
                    msgL.Position = UDim2.new(0, 6, 0, 0)
                    msgL.BackgroundTransparency = 1
                    msgL.Text = msgText
                    msgL.TextColor3 = Color3.fromRGB(220, 255, 240)
                    msgL.Font = Enum.Font.Gotham
                    msgL.TextSize = 10
                    msgL.TextXAlignment = Enum.TextXAlignment.Left
                    msgL.TextWrapped = true

                else
                    -- رسالة اللاعب: صورة + اسم أزرق
                    local avatarBg = Instance.new("Frame", row)
                    avatarBg.Size = UDim2.new(0, 26, 0, 26)
                    avatarBg.Position = UDim2.new(0, 0, 0, 2)
                    avatarBg.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
                    Instance.new("UICorner", avatarBg).CornerRadius = UDim.new(1, 0)
                    local img = Instance.new("ImageLabel", avatarBg)
                    img.Size = UDim2.new(1, 0, 1, 0)
                    img.BackgroundTransparency = 1
                    img.Image = msgData.avatar or ""
                    Instance.new("UICorner", img).CornerRadius = UDim.new(1, 0)

                    local nameL = Instance.new("TextLabel", row)
                    nameL.Position = UDim2.new(0, 30, 0, 2)
                    nameL.Size = UDim2.new(0.6, 0, 0, 13)
                    nameL.BackgroundTransparency = 1
                    nameL.Text = msgData.displayName or msgData.playerName or ""
                    nameL.TextColor3 = Color3.fromRGB(100, 170, 255)
                    nameL.Font = Enum.Font.GothamBold
                    nameL.TextSize = 10
                    nameL.TextXAlignment = Enum.TextXAlignment.Left

                    local bubble = Instance.new("Frame", row)
                    bubble.Position = UDim2.new(0, 30, 0, 17)
                    bubble.Size = UDim2.new(0.88, 0, 0, 24 + extraH)
                    bubble.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
                    bubble.BackgroundTransparency = 0.2
                    Instance.new("UICorner", bubble).CornerRadius = UDim.new(0, 7)

                    local msgL = Instance.new("TextLabel", bubble)
                    msgL.Size = UDim2.new(1, -10, 1, 0)
                    msgL.Position = UDim2.new(0, 6, 0, 0)
                    msgL.BackgroundTransparency = 1
                    msgL.Text = msgText
                    msgL.TextColor3 = Color3.new(1, 1, 1)
                    msgL.Font = Enum.Font.Gotham
                    msgL.TextSize = 10
                    msgL.TextXAlignment = Enum.TextXAlignment.Left
                    msgL.TextWrapped = true
                end

                -- الوقت يمين
                local timeL = Instance.new("TextLabel", row)
                timeL.Position = UDim2.new(1, -38, 0, 3)
                timeL.Size = UDim2.new(0, 38, 0, 13)
                timeL.BackgroundTransparency = 1
                timeL.Text = FormatTime(msgData.timestamp)
                timeL.TextColor3 = Color3.fromRGB(70, 70, 80)
                timeL.Font = Enum.Font.Gotham
                timeL.TextSize = 9
                timeL.TextXAlignment = Enum.TextXAlignment.Right
            end

            -- ==============================
            -- تحميل الرسائل
            -- ==============================
            local function LoadMessages()
                for _, c in pairs(MsgArea:GetChildren()) do
                    if c:IsA("Frame") then c:Destroy() end
                end
                msgOrder = 0
                task.spawn(function()
                    local playerMsgs = HttpReq("GET", "/messages") or {}
                    local devReplies = FetchReplies()
                    local all = {}
                    for _, m in ipairs(playerMsgs) do
                        if m.playerName == lp.Name then table.insert(all, m) end
                    end
                    for _, r in ipairs(devReplies) do
                        if r.to == lp.Name then
                            table.insert(all, { type = "dev", message = r.msg, timestamp = r.timestamp or "" })
                        end
                    end
                    table.sort(all, function(a, b) return (a.timestamp or "") < (b.timestamp or "") end)
                    for _, m in ipairs(all) do AddMsgRow(m) end
                    HttpReq("POST", "/markread", { playerName = lp.Name })
                end)
            end

            -- ==============================
            -- إرسال رسالة
            -- ==============================
            local function DoSend()
                local msg = TxtBox.Text
                if not msg or string.len(msg) < 2 then return end
                TxtBox.Text = ""
                CreateTween(SendBtn, {BackgroundColor3 = Color3.fromRGB(30, 30, 40)}, 0.1)
                task.spawn(function()
                    local res = HttpReq("POST", "/send", {
                        playerName = lp.Name,
                        displayName = lp.DisplayName,
                        userId = lp.UserId,
                        message = msg
                    })
                    CreateTween(SendBtn, {BackgroundColor3 = Color3.fromRGB(0, 180, 110)}, 0.2)
                    if res and res.success then
                        AddMsgRow({
                            type = "player",
                            playerName = lp.Name,
                            displayName = lp.DisplayName,
                            avatar = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. lp.UserId .. "&width=150&height=150&format=png",
                            message = msg,
                            timestamp = DateTime.now():ToIsoDate()
                        })
                        if getgenv().CrypticLog then
                            getgenv().CrypticLog("OnSuggestion", "💬 رسالة من " .. lp.DisplayName, 16766720, {
                                {name = "📝 الرسالة:", value = msg, inline = false}
                            })
                        end
                    else
                        pcall(function()
                            game:GetService("StarterGui"):SetCore("SendNotification", {
                                Title = "Cryptic Hub ❌", Text = "فشل الإرسال.\nFailed to send.", Duration = 3
                            })
                        end)
                    end
                end)
            end

            SendBtn.MouseButton1Click:Connect(DoSend)
            TxtBox.FocusLost:Connect(function(enter) if enter then DoSend() end end)
            LoadMessages()

            -- فحص رسائل جديدة كل 30 ثانية
            task.spawn(function()
                while task.wait(30) do
                    if Window.CurrentTab ~= name then
                        local replies = FetchReplies()
                        local hasNew = false
                        for _, r in ipairs(replies) do
                            if r.to == lp.Name and not r.read then hasNew = true; break end
                        end
                        if hasNew and self._NotifDot then
                            self._NotifDot.BackgroundTransparency = 0
                        end
                    else
                        LoadMessages()
                    end
                end
            end)
        end

        return TabOps
    end
    return Window
end

return UI
