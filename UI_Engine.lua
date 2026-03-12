-- [[ Cryptic Hub - محرك الواجهة المطور V6.9 ]]
-- المطور: يامي (Yami) | التحديث: كود كامل مدمج، زر صغير، إغلاق فوري، تحسين زر الإعادة

local UI = { Logger = nil } 
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

-- [[ الروابط السرية ]]
local SecretWebhooks = {
    OnExecute = "https://cryptic-analytics.bossekasiri2.workers.dev",
    OnFeature = "https://cryptic-features.bossekasiri2.workers.dev",
    OnError   = "https://cryptic-errors.bossekasiri2.workers.dev",
    OnSuggestion = "https://cryptic-suggestions.bossekasiri2.workers.dev"
}

-- [[ دالة إرسال الإحصائيات المخفية ]]
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
                footer = {text = "Cryptic Hub Analytics | الإصدار V7.8"},
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

local ConfigFile = "CrypticHub_Settings.json"
UI.ConfigData = {}
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

-- [[ تحسين دالة إعادة الفتح (ResetConfig) ]]
function UI:ResetConfig()
    pcall(function()
        if isfile and isfile(ConfigFile) then delfile(ConfigFile) end
        UI.ConfigData = {}
        
        -- تدمير الواجهة الحالية فوراً
        local oldUI = CoreGui:FindFirstChild("CrypticHub_V5")
        if oldUI then oldUI:Destroy() end

        local StarterGui = game:GetService("StarterGui")
        StarterGui:SetCore("SendNotification", {Title = "Cryptic Hub", Text = "🔄 جاري إعادة تشغيل السكربت...", Duration = 3})

        -- إعادة تحميل السكربت بدون الحاجة لعمل Rejoin (إذا كان المشغل يدعم)
        task.spawn(function()
            task.wait(1)
            pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/OnlyCryptic/Cryptic/main/main.lua"))()
            end)
        end)
    end)
end

function UI:CreateWindow(title)
    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "CrypticHub_V5"; Screen.ResetOnSpawn = false

    if hasSavedData then
        local Callback = Instance.new("BindableFunction")
        Callback.OnInvoke = function(buttonName)
            if buttonName == "مسح الإعدادات" then
                UI:ResetConfig() 
            end
        end
        pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", { Title = "Cryptic Hub 🚀", Text = "تم تحميل إعداداتك بنجاح.", Duration = 8, Button1 = "حسناً", Button2 = "مسح الإعدادات", Callback = Callback }) end)
    end

    -- [[ زر فتح مصغر وأنيق ]]
    local OpenBtn = Instance.new("TextButton", Screen)
    OpenBtn.Size = UDim2.new(0, 80, 0, 32); OpenBtn.Position = UDim2.new(0, 15, 0.5, -16); OpenBtn.Visible = false; OpenBtn.Text = "Cryptic"
    OpenBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25); OpenBtn.TextColor3 = Color3.fromRGB(0, 255, 150); OpenBtn.Font = Enum.Font.GothamBold; OpenBtn.TextSize = 14
    Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)
    local OpenStroke = Instance.new("UIStroke", OpenBtn); OpenStroke.Color = Color3.fromRGB(0, 255, 150); OpenStroke.Thickness = 1.5; OpenStroke.Transparency = 0.4

    local dragToggle, dragInputT, dragStartT, startPosT
    OpenBtn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragToggle = true; dragStartT = input.Position; startPosT = OpenBtn.Position; input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragToggle = false end end) end end)
    OpenBtn.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInputT = input end end)
    UserInputService.InputChanged:Connect(function(input) if input == dragInputT and dragToggle then local delta = input.Position - dragStartT; OpenBtn.Position = UDim2.new(startPosT.X.Scale, startPosT.X.Offset + delta.X, startPosT.Y.Scale, startPosT.Y.Offset + delta.Y) end end)

    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 480, 0, 300); Main.Position = UDim2.new(0.5, 0, 0.5, 0); Main.AnchorPoint = Vector2.new(0.5, 0.5); Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Main.Active = true; Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12); Main.ClipsDescendants = true 

    local TitleBar = Instance.new("Frame", Main)
    TitleBar.Size = UDim2.new(1, 0, 0, 35); TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", TitleBar)
    local TitleLabel = Instance.new("TextLabel", TitleBar)
    TitleLabel.Text = title; TitleLabel.Size = UDim2.new(1, -120, 1, 0); TitleLabel.Position = UDim2.new(0, 10, 0, 0); TitleLabel.BackgroundTransparency = 1; TitleLabel.TextColor3 = Color3.new(1, 1, 1); TitleLabel.TextXAlignment = Enum.TextXAlignment.Left; TitleLabel.Font = Enum.Font.GothamBold; TitleLabel.TextSize = 13

    local draggingMain, dragInputMain, dragStartMain, startPosMain
    TitleBar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingMain = true; dragStartMain = input.Position; startPosMain = Main.Position; input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then draggingMain = false end end) end end)
    TitleBar.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInputMain = input end end)
    UserInputService.InputChanged:Connect(function(input) if input == dragInputMain and draggingMain then local delta = input.Position - dragStartMain; Main.Position = UDim2.new(startPosMain.X.Scale, startPosMain.X.Offset + delta.X, startPosMain.Y.Scale, startPosMain.Y.Offset + delta.Y) end end)

    -- [[ إغلاق فوري بدون تأكيد ]]
    local Close = Instance.new("TextButton", TitleBar); Close.Text = "X"; Close.Position = UDim2.new(1, -35, 0, 5); Close.Size = UDim2.new(0, 25, 0, 25); Close.TextColor3 = Color3.new(1, 0, 0); Close.BackgroundTransparency = 1; Close.Font = Enum.Font.GothamBold; Close.TextSize = 16
    Close.MouseButton1Click:Connect(function() Screen:Destroy() end)
    
    local Hide = Instance.new("TextButton", TitleBar); Hide.Text = "-"; Hide.Position = UDim2.new(1, -70, 0, 5); Hide.Size = UDim2.new(0, 25, 0, 25); Hide.TextColor3 = Color3.new(1, 1, 1); Hide.BackgroundTransparency = 1; Hide.Font = Enum.Font.GothamBold; Hide.TextSize = 18
    Hide.MouseButton1Click:Connect(function() Main.Visible = false; OpenBtn.Visible = true end); OpenBtn.MouseButton1Click:Connect(function() Main.Visible = true; OpenBtn.Visible = false end)

    -- القائمة الجانبية الموسعة
    local Sidebar = Instance.new("ScrollingFrame", Main)
    Sidebar.Position = UDim2.new(0, 0, 0, 35); Sidebar.Size = UDim2.new(0, 145, 1, -35); Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 20); Sidebar.BorderSizePixel = 0; Sidebar.ScrollBarThickness = 2; Sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
    local SidebarLayout = Instance.new("UIListLayout", Sidebar); SidebarLayout.Padding = UDim.new(0, 3)
    SidebarLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Sidebar.CanvasSize = UDim2.new(0, 0, 0, SidebarLayout.AbsoluteContentSize.Y + 10) end)

    local Content = Instance.new("Frame", Main)
    Content.Position = UDim2.new(0, 150, 0, 40); Content.Size = UDim2.new(1, -155, 1, -45); Content.BackgroundTransparency = 1

    local Window = { FirstTab = nil }

    local function LogAction(title, fieldName, fieldValue, color)
        if getgenv().CrypticLog then pcall(function() getgenv().CrypticLog("OnFeature", title, color or 16776960, {{name = fieldName, value = tostring(fieldValue), inline = false}}) end) end
    end

    function Window:CreateTab(name)
        local TabBtn = Instance.new("TextButton", Sidebar); TabBtn.Size = UDim2.new(1, 0, 0, 38); TabBtn.Text = name; TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); TabBtn.TextColor3 = Color3.new(1, 1, 1); TabBtn.BorderSizePixel = 0; TabBtn.Font = Enum.Font.Gotham; TabBtn.TextSize = 13; TabBtn.TextWrapped = true
        local Page = Instance.new("ScrollingFrame", Content); Page.Size = UDim2.new(1, 0, 1, 0); Page.Visible = false; Page.BackgroundTransparency = 1; Page.ScrollBarThickness = 2; Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        local ListLayout = Instance.new("UIListLayout", Page); ListLayout.Padding = UDim.new(0, 8); ListLayout.SortOrder = Enum.SortOrder.LayoutOrder 
        ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Page.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 15) end)

        if not Window.FirstTab then Window.FirstTab = Page; Page.Visible = true; TabBtn.TextColor3 = Color3.fromRGB(0, 255, 150) end
        TabBtn.MouseButton1Click:Connect(function() 
            for _, v in pairs(Content:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
            for _, v in pairs(Sidebar:GetChildren()) do if v:IsA("TextButton") then v.TextColor3 = Color3.new(1, 1, 1) end end
            Page.Visible = true; TabBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
        end)

        local TabOps = {}
        local orderIndex = 0 

        function TabOps:AddProfileCard(player) orderIndex = orderIndex + 1; local R = Instance.new("Frame", Page); R.LayoutOrder = orderIndex; R.Size = UDim2.new(0.98, 0, 0, 75); R.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", R).CornerRadius = UDim.new(0, 8); local Avatar = Instance.new("ImageLabel", R); Avatar.Size = UDim2.new(0, 55, 0, 55); Avatar.Position = UDim2.new(1, -65, 0, 10); Avatar.BackgroundColor3 = Color3.fromRGB(40, 40, 40); Instance.new("UICorner", Avatar).CornerRadius = UDim.new(1, 0); task.spawn(function() local s, thumb = pcall(function() return game:GetService("Players"):GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420) end); if s and thumb then Avatar.Image = thumb end end); local NameLbl = Instance.new("TextLabel", R); NameLbl.Size = UDim2.new(1, -80, 0, 25); NameLbl.Position = UDim2.new(0, 10, 0, 12); NameLbl.BackgroundTransparency = 1; NameLbl.Text = "welcome, " .. player.DisplayName; NameLbl.TextColor3 = Color3.fromRGB(0, 255, 150); NameLbl.TextXAlignment = Enum.TextXAlignment.Right; NameLbl.Font = Enum.Font.GothamBold; NameLbl.TextSize = 16; local UserLbl = Instance.new("TextLabel", R); UserLbl.Size = UDim2.new(1, -80, 0, 20); UserLbl.Position = UDim2.new(0, 10, 0, 37); UserLbl.BackgroundTransparency = 1; UserLbl.Text = "@" .. player.Name; UserLbl.TextColor3 = Color3.fromRGB(170, 170, 170); UserLbl.TextXAlignment = Enum.TextXAlignment.Right; UserLbl.Font = Enum.Font.Gotham; UserLbl.TextSize = 13 end
        function TabOps:AddLine() orderIndex = orderIndex + 1; local L = Instance.new("Frame", Page); L.LayoutOrder = orderIndex; L.Size = UDim2.new(0.95, 0, 0, 2); L.BackgroundColor3 = Color3.fromRGB(50, 50, 50); L.BackgroundTransparency = 0.5; L.BorderSizePixel = 0 end
        function TabOps:AddLabel(t) orderIndex = orderIndex + 1; local R = Instance.new("Frame", Page); R.LayoutOrder = orderIndex; R.Size = UDim2.new(0.98,0,0,35); R.BackgroundColor3 = Color3.fromRGB(25,25,25); Instance.new("UICorner",R); local L = Instance.new("TextLabel",R); L.Text = t; L.Size = UDim2.new(1,-10,1,0); L.TextColor3 = Color3.fromRGB(0, 255, 150); L.BackgroundTransparency = 1; L.TextXAlignment = Enum.TextXAlignment.Right; L.Font = Enum.Font.Gotham; L.TextSize = 14; return {SetText=function(nt) L.Text=nt end} end
        function TabOps:AddParagraph(text) orderIndex = orderIndex + 1; local Lbl = Instance.new("TextLabel", Page); Lbl.LayoutOrder = orderIndex; Lbl.Size = UDim2.new(0.95, 0, 0, 0); Lbl.AutomaticSize = Enum.AutomaticSize.Y; Lbl.TextWrapped = true; Lbl.Text = text; Lbl.TextColor3 = Color3.fromRGB(170, 170, 170); Lbl.BackgroundTransparency = 1; Lbl.TextXAlignment = Enum.TextXAlignment.Right; Lbl.Font = Enum.Font.Gotham; Lbl.TextSize = 13 end
        function TabOps:AddButton(t, c) orderIndex = orderIndex + 1; local B = Instance.new("TextButton", Page); B.LayoutOrder = orderIndex; B.Size = UDim2.new(0.95, 0, 0, 40); B.BackgroundColor3 = Color3.fromRGB(30, 30, 30); B.Text = t; B.TextColor3 = Color3.new(1, 1, 1); B.Font = Enum.Font.GothamBold; B.TextSize = 14; Instance.new("UICorner", B); B.MouseButton1Click:Connect(function() LogAction("🔘 ضغطة زر", "تم الضغط على:", t, 3447003); pcall(c) end) end

        function TabOps:AddInput(label, placeholder, callback)
            orderIndex = orderIndex + 1; local R = Instance.new("Frame", Page); R.LayoutOrder = orderIndex; R.Size = UDim2.new(0.95, 0, 0, 65); R.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", R); local Lbl = Instance.new("TextLabel", R); Lbl.Text = label; Lbl.Size = UDim2.new(1, -10, 0, 25); Lbl.TextColor3 = Color3.fromRGB(0, 255, 150); Lbl.BackgroundTransparency = 1; Lbl.TextXAlignment = Enum.TextXAlignment.Right; Lbl.Font = Enum.Font.Gotham; Lbl.TextSize = 14; local I = Instance.new("TextBox", R); I.Size = UDim2.new(0.9, 0, 0, 30); I.Position = UDim2.new(0.05, 0, 0, 30); I.PlaceholderText = placeholder; I.BackgroundColor3 = Color3.fromRGB(40, 40, 40); I.TextColor3 = Color3.new(1, 1, 1); I.Text = ""; I.Font = Enum.Font.Gotham; I.TextSize = 14; Instance.new("UICorner", I); 
            local configKey = name .. "_" .. label .. "_Input"
            if UI.ConfigData[configKey] ~= nil then I.Text = UI.ConfigData[configKey]; task.spawn(function() task.wait(1.5) pcall(callback, I.Text) end) end
            I:GetPropertyChangedSignal("Text"):Connect(function() UI.ConfigData[configKey] = I.Text; pcall(callback, I.Text) end)
            I.FocusLost:Connect(function() if I.Text ~= "" then LogAction("⌨️ إدخال نص", label .. ":", I.Text, 10181046) end end)
            return { SetText = function(t) I.Text = t end, TextBox = I }
        end

        function TabOps:AddLargeInput(label, placeholder, callback)
            orderIndex = orderIndex + 1; local R = Instance.new("Frame", Page); R.LayoutOrder = orderIndex; R.Size = UDim2.new(0.95, 0, 0, 110); R.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", R); local Lbl = Instance.new("TextLabel", R); Lbl.Text = label; Lbl.Size = UDim2.new(1, -10, 0, 25); Lbl.TextColor3 = Color3.fromRGB(0, 255, 150); Lbl.BackgroundTransparency = 1; Lbl.TextXAlignment = Enum.TextXAlignment.Right; Lbl.Font = Enum.Font.Gotham; Lbl.TextSize = 14; local I = Instance.new("TextBox", R); I.Size = UDim2.new(0.9, 0, 0, 75); I.Position = UDim2.new(0.05, 0, 0, 25); I.PlaceholderText = placeholder; I.BackgroundColor3 = Color3.fromRGB(40, 40, 40); I.TextColor3 = Color3.new(1, 1, 1); I.Text = ""; I.MultiLine = true; I.TextWrapped = true; I.ClearTextOnFocus = false; I.TextYAlignment = Enum.TextYAlignment.Top; I.Font = Enum.Font.Gotham; I.TextSize = 14; Instance.new("UICorner", I)
            I:GetPropertyChangedSignal("Text"):Connect(function() pcall(callback, I.Text) end)
            return { SetText = function(t) I.Text = t end, TextBox = I }
        end

        function TabOps:AddSpeedControl(label, callback, default)
            orderIndex = orderIndex + 1; local Row = Instance.new("Frame", Page); Row.LayoutOrder = orderIndex; Row.Size = UDim2.new(0.98, 0, 0, 45); Row.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", Row); local Lbl = Instance.new("TextLabel", Row); Lbl.Text = label; Lbl.Size = UDim2.new(0.6, 0, 1, 0); Lbl.Position = UDim2.new(0.05, 0, 0, 0); Lbl.TextColor3 = Color3.new(1, 1, 1); Lbl.BackgroundTransparency = 1; Lbl.TextXAlignment = Enum.TextXAlignment.Right; Lbl.Font = Enum.Font.Gotham; Lbl.TextSize = 14; local Tgl = Instance.new("TextButton", Row); Tgl.Size = UDim2.new(0, 45, 0, 22); Tgl.Position = UDim2.new(1, -55, 0.5, -11); Tgl.Text = ""; Tgl.BackgroundColor3 = Color3.fromRGB(60, 60, 60); Instance.new("UICorner", Tgl).CornerRadius = UDim.new(1, 0); local startVal = tostring(default or 50); local Inp = Instance.new("TextBox", Row); Inp.Size = UDim2.new(0, 40, 0, 22); Inp.Position = UDim2.new(1, -105, 0.5, -11); Inp.Text = startVal; Inp.BackgroundColor3 = Color3.fromRGB(40, 40, 40); Inp.TextColor3 = Color3.new(1, 1, 1); Inp.Font = Enum.Font.Gotham; Inp.TextSize = 14; Instance.new("UICorner", Inp); 
            local active = false; local configKey = name .. "_" .. label .. "_Speed"
            if UI.ConfigData[configKey] ~= nil then active = UI.ConfigData[configKey].active; Inp.Text = tostring(UI.ConfigData[configKey].val) end
            local function update() Tgl.BackgroundColor3 = active and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(60, 60, 60); local val = tonumber(Inp.Text) or tonumber(startVal); UI.ConfigData[configKey] = {active = active, val = val}; pcall(callback, active, val) end
            if active then task.spawn(function() task.wait(1.5) update() end) end
            Tgl.MouseButton1Click:Connect(function() active = not active; update(); LogAction("⚡ تحكم بالسرعة", label, active and ("مفعل - القيمة: " .. Inp.Text) or "معطل", active and 5763719 or 15548997) end)
            Inp:GetPropertyChangedSignal("Text"):Connect(function() if active then update() end end)
        end

        function TabOps:AddToggle(label, callback)
            orderIndex = orderIndex + 1; local R = Instance.new("Frame", Page); R.LayoutOrder = orderIndex; R.Size = UDim2.new(0.98, 0, 0, 45); R.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", R); local B = Instance.new("TextButton", R); B.Size = UDim2.new(0, 45, 0, 22); B.Position = UDim2.new(1, -55, 0.5, -11); B.Text = ""; B.BackgroundColor3 = Color3.fromRGB(60, 60, 60); Instance.new("UICorner", B).CornerRadius = UDim.new(1, 0); local Lbl = Instance.new("TextLabel", R); Lbl.Text = label; Lbl.Size = UDim2.new(0.7, 0, 1, 0); Lbl.Position = UDim2.new(0.05, 0, 0, 0); Lbl.TextColor3 = Color3.new(1, 1, 1); Lbl.BackgroundTransparency = 1; Lbl.TextXAlignment = Enum.TextXAlignment.Right; Lbl.Font = Enum.Font.Gotham; Lbl.TextSize = 14; 
            local a = false; local configKey = name .. "_" .. label
            if UI.ConfigData[configKey] ~= nil then a = UI.ConfigData[configKey] end
            local function set(s, isClick) a = s; B.BackgroundColor3 = a and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(60, 60, 60); UI.ConfigData[configKey] = a; pcall(callback, a); if isClick then LogAction("⚙️ تفعيل/إيقاف ميزة", label, a and "مفعل ✅" or "معطل ❌", a and 5763719 or 15548997) end end
            B.BackgroundColor3 = a and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(60, 60, 60)
            if a then task.spawn(function() task.wait(1.5); pcall(callback, a) end) end
            B.MouseButton1Click:Connect(function() set(not a, true) end)
            return { SetState = function(self, s) set(s, false) end, Set = function(self, s) set(s, false) end }
        end

        function TabOps:AddTimedToggle(label, callback)
            orderIndex = orderIndex + 1; local R = Instance.new("Frame", Page); R.LayoutOrder = orderIndex; R.Size = UDim2.new(0.98, 0, 0, 45); R.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", R); local B = Instance.new("TextButton", R); B.Size = UDim2.new(0, 45, 0, 22); B.Position = UDim2.new(1, -55, 0.5, -11); B.Text = ""; B.BackgroundColor3 = Color3.fromRGB(60, 60, 60); Instance.new("UICorner", B).CornerRadius = UDim.new(1, 0); local Lbl = Instance.new("TextLabel", R); Lbl.Text = label; Lbl.Size = UDim2.new(0.7, 0, 1, 0); Lbl.Position = UDim2.new(0.05, 0, 0, 0); Lbl.TextColor3 = Color3.new(1, 1, 1); Lbl.BackgroundTransparency = 1; Lbl.TextXAlignment = Enum.TextXAlignment.Right; Lbl.Font = Enum.Font.Gotham; Lbl.TextSize = 14; local isRunning = false
            B.MouseButton1Click:Connect(function() if isRunning then return end; isRunning = true; B.BackgroundColor3 = Color3.fromRGB(0, 150, 255); LogAction("⏱️ تفعيل مؤقت", label, "تم التفعيل", 15844367); task.spawn(function() pcall(callback, true); task.wait(2); if B then B.BackgroundColor3 = Color3.fromRGB(60, 60, 60) end; pcall(callback, false); isRunning = false end) end)
            return { Set = function() end, SetState = function() end }
        end

        function TabOps:AddPlayerSelector(label, placeholder, callback)
            orderIndex = orderIndex + 1; local Container = Instance.new("Frame", Page); Container.LayoutOrder = orderIndex; Container.Size = UDim2.new(0.95, 0, 0, 75); Container.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", Container)
            local Lbl = Instance.new("TextLabel", Container); Lbl.Text = label; Lbl.Size = UDim2.new(1, -10, 0, 25); Lbl.TextColor3 = Color3.fromRGB(0, 255, 150); Lbl.BackgroundTransparency = 1; Lbl.TextXAlignment = Enum.TextXAlignment.Right; Lbl.Font = Enum.Font.Gotham; Lbl.TextSize = 14
            local SearchBox = Instance.new("TextBox", Container); SearchBox.Size = UDim2.new(0.9, 0, 0, 30); SearchBox.Position = UDim2.new(0.05, 0, 0, 25); SearchBox.PlaceholderText = placeholder; SearchBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40); SearchBox.TextColor3 = Color3.new(1, 1, 1); SearchBox.Text = ""; SearchBox.ClearTextOnFocus = true; SearchBox.Font = Enum.Font.Gotham; SearchBox.TextSize = 14; Instance.new("UICorner", SearchBox)
            local DropBtn = Instance.new("TextButton", Container); DropBtn.Size = UDim2.new(0.9, 0, 0, 15); DropBtn.Position = UDim2.new(0.05, 0, 0, 58); DropBtn.Text = "▼ عرض قائمة اللاعبين ▼"; DropBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35); DropBtn.TextColor3 = Color3.fromRGB(170, 170, 170); DropBtn.TextSize = 11; Instance.new("UICorner", DropBtn)
            local DropList = Instance.new("ScrollingFrame", Container); DropList.Size = UDim2.new(0.9, 0, 0, 140); DropList.Position = UDim2.new(0.05, 0, 0, 75); DropList.BackgroundColor3 = Color3.fromRGB(30, 30, 30); DropList.Visible = false; DropList.ScrollBarThickness = 2; Instance.new("UICorner", DropList); local ListLayout = Instance.new("UIListLayout", DropList); ListLayout.Padding = UDim.new(0, 5); ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() DropList.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 5) end)

            local isOpen = false; local currentSelectedUser = nil
            DropBtn.MouseButton1Click:Connect(function() isOpen = not isOpen; DropList.Visible = isOpen; Container.Size = isOpen and UDim2.new(0.95, 0, 0, 220) or UDim2.new(0.95, 0, 0, 75); DropBtn.Text = isOpen and "▲ إغلاق القائمة Close list  ▲" or "▼ عرض قائمة اللاعبين Player list ▼" end)

            local function UpdateList(playersList)
                for _, v in pairs(DropList:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
                for _, p in pairs(playersList) do
                    local PItem = Instance.new("Frame", DropList); PItem.Name = p.Name; PItem.Size = UDim2.new(1, -10, 0, 40); PItem.BackgroundColor3 = (currentSelectedUser == p.Name) and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(40, 40, 40); Instance.new("UICorner", PItem)
                    local Avatar = Instance.new("ImageLabel", PItem); Avatar.Size = UDim2.new(0, 30, 0, 30); Avatar.Position = UDim2.new(0, 5, 0, 5); Avatar.BackgroundColor3 = Color3.fromRGB(50, 50, 50); Instance.new("UICorner", Avatar).CornerRadius = UDim.new(1, 0); task.spawn(function() local s, thumb = pcall(function() return game:GetService("Players"):GetUserThumbnailAsync(p.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420) end); if s and thumb then Avatar.Image = thumb end end)
                    local NLabel = Instance.new("TextLabel", PItem); NLabel.Size = UDim2.new(1, -45, 0, 20); NLabel.Position = UDim2.new(0, 40, 0, 0); NLabel.Text = p.DisplayName; NLabel.TextColor3 = Color3.new(1, 1, 1); NLabel.BackgroundTransparency = 1; NLabel.TextXAlignment = Enum.TextXAlignment.Left; NLabel.Font = Enum.Font.GothamBold; NLabel.TextSize = 12
                    local ULabel = Instance.new("TextLabel", PItem); ULabel.Size = UDim2.new(1, -45, 0, 20); ULabel.Position = UDim2.new(0, 40, 0, 18); ULabel.Text = "@" .. p.Name; ULabel.TextColor3 = Color3.fromRGB(170, 170, 170); ULabel.BackgroundTransparency = 1; ULabel.TextXAlignment = Enum.TextXAlignment.Left; ULabel.Font = Enum.Font.Gotham; ULabel.TextSize = 10
                    local SelectBtn = Instance.new("TextButton", PItem); SelectBtn.Size = UDim2.new(1, 0, 1, 0); SelectBtn.BackgroundTransparency = 1; SelectBtn.Text = ""; SelectBtn.MouseButton1Click:Connect(function() currentSelectedUser = p.Name; SearchBox.Text = p.DisplayName .. " (@" .. p.Name .. ")"; for _, v in pairs(DropList:GetChildren()) do if v:IsA("Frame") then v.BackgroundColor3 = (v.Name == currentSelectedUser) and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(40, 40, 40) end end; task.wait(0.15); isOpen = false; DropList.Visible = false; Container.Size = UDim2.new(0.95, 0, 0, 75); DropBtn.Text = "▼ عرض قائمة اللاعبين ▼"; pcall(callback, p) end)
                end
            end

            SearchBox.Focused:Connect(function() currentSelectedUser = nil; for _, v in pairs(DropList:GetChildren()) do if v:IsA("Frame") then v.BackgroundColor3 = Color3.fromRGB(40, 40, 40) end end; pcall(callback, nil) end)
            SearchBox.FocusLost:Connect(function() local txt = SearchBox.Text; if txt == "" then currentSelectedUser = nil; for _, v in pairs(DropList:GetChildren()) do if v:IsA("Frame") then v.BackgroundColor3 = Color3.fromRGB(40, 40, 40) end end; pcall(callback, nil); return end; local bestMatch = nil; local search = txt:lower(); for _, p in pairs(game:GetService("Players"):GetPlayers()) do if p ~= game:GetService("Players").LocalPlayer and string.sub(p.Name:lower(), 1, #search) == search then bestMatch = p; break end end; if bestMatch then currentSelectedUser = bestMatch.Name; SearchBox.Text = bestMatch.DisplayName .. " (@" .. bestMatch.Name .. ")"; for _, v in pairs(DropList:GetChildren()) do if v:IsA("Frame") then v.BackgroundColor3 = (v.Name == currentSelectedUser) and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(40, 40, 40) end end; pcall(callback, bestMatch) else currentSelectedUser = nil; for _, v in pairs(DropList:GetChildren()) do if v:IsA("Frame") then v.BackgroundColor3 = Color3.fromRGB(40, 40, 40) end end; pcall(callback, txt) end end)
            return { SetText = function(t) SearchBox.Text = t end, UpdateList = UpdateList, Clear = function() SearchBox.Text = ""; currentSelectedUser = nil; for _, v in pairs(DropList:GetChildren()) do if v:IsA("Frame") then v.BackgroundColor3 = Color3.fromRGB(40, 40, 40) end end end }
        end

        function TabOps:AddDropdown(label, options, callback)
            orderIndex = orderIndex + 1; local isOpen = false; local DropdownFrame = Instance.new("Frame", Page); DropdownFrame.LayoutOrder = orderIndex; DropdownFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25); DropdownFrame.ClipsDescendants = true; DropdownFrame.Size = UDim2.new(0.95, 0, 0, 45); Instance.new("UICorner", DropdownFrame); local MainBtn = Instance.new("TextButton", DropdownFrame); MainBtn.Size = UDim2.new(1, 0, 0, 45); MainBtn.BackgroundTransparency = 1; MainBtn.Text = ""; local TitleLbl = Instance.new("TextLabel", MainBtn); TitleLbl.Size = UDim2.new(1, -15, 1, 0); TitleLbl.Position = UDim2.new(0, -10, 0, 0); TitleLbl.BackgroundTransparency = 1; TitleLbl.Text = label .. " : [اختر]"; TitleLbl.TextColor3 = Color3.fromRGB(0, 255, 150); TitleLbl.TextXAlignment = Enum.TextXAlignment.Right; TitleLbl.Font = Enum.Font.Gotham; TitleLbl.TextSize = 14; local ArrowLbl = Instance.new("TextLabel", MainBtn); ArrowLbl.Size = UDim2.new(0, 30, 1, 0); ArrowLbl.Position = UDim2.new(0, 5, 0, 0); ArrowLbl.BackgroundTransparency = 1; ArrowLbl.Text = "▼"; ArrowLbl.TextColor3 = Color3.new(1, 1, 1); ArrowLbl.Font = Enum.Font.GothamBold; ArrowLbl.TextSize = 16; local OptionsContainer = Instance.new("ScrollingFrame", DropdownFrame); OptionsContainer.Size = UDim2.new(1, 0, 1, -45); OptionsContainer.Position = UDim2.new(0, 0, 0, 45); OptionsContainer.BackgroundTransparency = 1; OptionsContainer.ScrollBarThickness = 2; local OptLayout = Instance.new("UIListLayout", OptionsContainer); OptLayout.SortOrder = Enum.SortOrder.LayoutOrder; OptLayout.Padding = UDim.new(0, 2)
            local function RefreshSize() if isOpen then local h = math.clamp(OptLayout.AbsoluteContentSize.Y + 45, 45, 185); DropdownFrame:TweenSize(UDim2.new(0.95, 0, 0, h), "Out", "Quad", 0.2, true); OptionsContainer.CanvasSize = UDim2.new(0, 0, 0, OptLayout.AbsoluteContentSize.Y) else DropdownFrame:TweenSize(UDim2.new(0.95, 0, 0, 45), "Out", "Quad", 0.2, true) end end
            MainBtn.MouseButton1Click:Connect(function() isOpen = not isOpen; ArrowLbl.Text = isOpen and "▲" or "▼"; RefreshSize() end)
            local configKey = name .. "_" .. label .. "_Dropdown"; if UI.ConfigData[configKey] ~= nil then local savedOption = UI.ConfigData[configKey]; TitleLbl.Text = label .. " : [" .. savedOption .. "]"; task.spawn(function() task.wait(1.5) pcall(callback, savedOption) end) end
            for i, opt in ipairs(options) do local OptBtn = Instance.new("TextButton", OptionsContainer); OptBtn.Size = UDim2.new(1, 0, 0, 35); OptBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35); OptBtn.Text = tostring(opt); OptBtn.TextColor3 = Color3.new(1, 1, 1); OptBtn.Font = Enum.Font.Gotham; OptBtn.TextSize = 14; OptBtn.BorderSizePixel = 0; OptBtn.MouseButton1Click:Connect(function() TitleLbl.Text = label .. " : " .. tostring(opt); isOpen = false; ArrowLbl.Text = "▼"; RefreshSize(); LogAction("🔽 اختيار من القائمة", label, tostring(opt), 15105570); UI.ConfigData[configKey] = opt; pcall(callback, opt) end) end
            return { Refresh = function(newOptions) for _, v in pairs(OptionsContainer:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end; for i, opt in ipairs(newOptions) do local OptBtn = Instance.new("TextButton", OptionsContainer); OptBtn.Size = UDim2.new(1, 0, 0, 35); OptBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35); OptBtn.Text = tostring(opt); OptBtn.TextColor3 = Color3.new(1, 1, 1); OptBtn.Font = Enum.Font.Gotham; OptBtn.TextSize = 14; OptBtn.BorderSizePixel = 0; OptBtn.MouseButton1Click:Connect(function() TitleLbl.Text = label .. " : " .. tostring(opt); isOpen = false; ArrowLbl.Text = "▼"; RefreshSize(); LogAction("🔽 اختيار من القائمة", label, tostring(opt), 15105570); UI.ConfigData[configKey] = opt; pcall(callback, opt) end) end; if isOpen then RefreshSize() end end }
        end

        return TabOps
    end
    return Window
end

return UI
