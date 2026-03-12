-- [[ Cryptic Hub - محرك الواجهة المطور V9.0 (نسخة التصميم الخرافي) ]]
-- المطور: يامي (Yami) | التحديث: تصميم عصري بالكامل + حواف دائرية + ألوان متناسقة + أنماط أقسام جديدة

local UI = { Logger = nil } 
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")

-- [[ 1. لوحة الألوان العصرية (Harmony Theme) ]]
local Theme = {
    Back = Color3.fromRGB(10, 10, 10),
    Sidebar = Color3.fromRGB(15, 15, 15),
    Container = Color3.fromRGB(20, 20, 20),
    Accent = Color3.fromRGB(0, 255, 150),
    TextMain = Color3.fromRGB(255, 255, 255),
    TextSec = Color3.fromRGB(170, 170, 170),
    Button = Color3.fromRGB(30, 30, 30),
    ActiveTab = Color3.fromRGB(0, 255, 150),
    CornerRadius = UDim.new(0, 10)
}

-- [[ 2. الروابط السرية (للتشفير) ]]
local SecretWebhooks = {
    OnExecute = "https://cryptic-analytics.bossekasiri2.workers.dev",
    OnFeature = "https://cryptic-features.bossekasiri2.workers.dev",
    OnError   = "https://cryptic-errors.bossekasiri2.workers.dev",
    OnSuggestion = "https://cryptic-suggestions.bossekasiri2.workers.dev"
}

-- [[ 3. دالة إرسال الإحصائيات (مخفية) ]]
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
            {name = "👤 اللاعب / Player:", value = player.DisplayName .. " (@" .. player.Name .. ")\n**ID:** " .. player.UserId, inline = true},  
            {name = "💻 المشغل / Executor:", value = executorName, inline = true},  
            {name = "🎮 الماب / Game:", value = placeName .. "\n**PlaceID:** " .. game.PlaceId, inline = false}
        }

        if ExtraFields then
            for _, field in ipairs(ExtraFields) do
                local valStr = tostring(field.value)
                if string.len(valStr) > 1000 then
                    table.insert(fields, {name = field.name .. " [Part 1]", value = string.sub(valStr, 1, 1000), inline = false})
                    table.insert(fields, {name = field.name .. " [Part 2]", value = string.sub(valStr, 1001, 2000), inline = false})
                else
                    table.insert(fields, field)
                end
            end
        end

        local embedData = { embeds = {{ title = ActionTitle, color = Color or 65430, thumbnail = { url = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. player.UserId .. "&width=420&height=420&format=png" }, fields = fields, footer = {text = "Cryptic Hub Analytics | V9.0"}, timestamp = DateTime.now():ToIsoDate() }} }  
        local HttpReq = (request or http_request or syn and syn.request)  
        if HttpReq then pcall(function() HttpReq({ Url = WebhookURL, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode(embedData) }) end) end
    end)
end
getgenv().CrypticLog = SendWebhookLog

-- [[ 4. إدارة الإعدادات ]]
local ConfigFile = "CrypticHub_Settings.json"
UI.ConfigData = {}
local hasSavedData = false

pcall(function()
    if isfile and isfile(ConfigFile) then
        local content = readfile(ConfigFile)
        local data = HttpService:JSONDecode(content)
        if type(data) == "table" and next(data) ~= nil then UI.ConfigData = data; hasSavedData = true end
    end
end)

function UI:SaveConfig()
    local success, err = pcall(function() writefile(ConfigFile, HttpService:JSONEncode(UI.ConfigData)) end)
    local StarterGui = game:GetService("StarterGui")
    if success then StarterGui:SetCore("SendNotification", {Title = "Cryptic Hub", Text = "💾 تم الحفظ / Saved!", Duration = 5})
    else StarterGui:SetCore("SendNotification", {Title = "⚠️ خطأ / Error", Text = "فشل الحفظ: المشغل لا يدعم هذه الميزة.", Duration = 5}) end
end

function UI:ResetConfig()
    pcall(function()
        if isfile and isfile(ConfigFile) then delfile(ConfigFile) end
        UI.ConfigData = {}
        local queue_tp = queue_on_teleport or (syn and syn.queue_on_teleport) or (getgenv and getgenv().queue_on_teleport)
        if queue_tp then queue_tp([[ task.wait(3) loadstring(game:HttpGet("https://raw.githubusercontent.com/OnlyCryptic/Cryptic/main/main.lua"))() ]]) end
        local player = Players.LocalPlayer
        if #game.JobId > 0 then TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player) else TeleportService:Teleport(game.PlaceId, player) end
    end)
end

-- [[ 5. دالة تهيئة الواجهة (CreateWindow) ]]
function UI:CreateWindow(title)
    local Screen = Instance.new("ScreenGui", CoreGui); Screen.Name = "CrypticHub_V9"; Screen.ResetOnSpawn = false

    if hasSavedData then
        local Callback = Instance.new("BindableFunction")
        Callback.OnInvoke = function(buttonName) if buttonName == "مسح / Reset" then UI.ConfigData = {}; task.spawn(function() task.wait(0.5) UI:ResetConfig() end) end end
        pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", { Title = "Cryptic Hub 🚀", Text = "تم تحميل إعداداتك / Config Loaded.", Duration = 8, Button1 = "حسناً / OK", Button2 = "مسح / Reset", Callback = Callback }) end)
    end

    local OpenBtn = Instance.new("TextButton", Screen)
    OpenBtn.Size = UDim2.new(0, 85, 0, 35); OpenBtn.Position = UDim2.new(0, 10, 0.5, -17); OpenBtn.Visible = false; OpenBtn.Text = "Cryptic"; OpenBtn.BackgroundColor3 = Theme.Accent; OpenBtn.TextColor3 = Theme.Back; OpenBtn.Font = Enum.Font.GothamBold; OpenBtn.TextSize = 14
    Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)
    local OpenStroke = Instance.new("UIStroke", OpenBtn); OpenStroke.Color = Color3.fromRGB(255, 255, 255); OpenStroke.Thickness = 1.5; OpenStroke.Transparency = 0.4

    local dragToggle, dragInputT, dragStartT, startPosT
    OpenBtn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragToggle = true; dragStartT = input.Position; startPosT = OpenBtn.Position; input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragToggle = false end end) end end)
    OpenBtn.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInputT = input end end)
    UserInputService.InputChanged:Connect(function(input) if input == dragInputT and dragToggle then local delta = input.Position - dragStartT; OpenBtn.Position = UDim2.new(startPosT.X.Scale, startPosT.X.Offset + delta.X, startPosT.Y.Scale, startPosT.Y.Offset + delta.Y) end end)

    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 440, 0, 280); Main.Position = UDim2.new(0.5, 0, 0.5, 0); Main.AnchorPoint = Vector2.new(0.5, 0.5); Main.BackgroundColor3 = Theme.Back; Main.Active = true; Main.ClipsDescendants = true 
    Instance.new("UICorner", Main).CornerRadius = Theme.CornerRadius
    local MainStroke = Instance.new("UIStroke", Main); MainStroke.Color = Theme.Accent; MainStroke.Thickness = 1.2; MainStroke.Transparency = 0.6; MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local TitleBar = Instance.new("Frame", Main)
    TitleBar.Size = UDim2.new(1, 0, 0, 35); TitleBar.BackgroundColor3 = Theme.Sidebar; TitleBar.BorderSizePixel = 0
    Instance.new("UICorner", TitleBar).CornerRadius = Theme.CornerRadius
    local TitleLabel = Instance.new("TextLabel", TitleBar)
    TitleLabel.Text = title; TitleLabel.Size = UDim2.new(1, -120, 1, 0); TitleLabel.Position = UDim2.new(0, 15, 0, 0); TitleLabel.BackgroundTransparency = 1; TitleLabel.TextColor3 = Theme.TextMain; TitleLabel.TextXAlignment = Enum.TextXAlignment.Left; TitleLabel.Font = Enum.Font.GothamBold

    local draggingMain, dragInputMain, dragStartMain, startPosMain
    TitleBar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingMain = true; dragStartMain = input.Position; startPosMain = Main.Position; input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then draggingMain = false end end) end end)
    TitleBar.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInputMain = input end end)
    UserInputService.InputChanged:Connect(function(input) if input == dragInputMain and draggingMain then local delta = input.Position - dragStartMain; Main.Position = UDim2.new(startPosMain.X.Scale, startPosMain.X.Offset + delta.X, startPosMain.Y.Scale, startPosMain.Y.Offset + delta.Y) end end)

    local Close = Instance.new("TextButton", TitleBar); Close.Text = "X"; Close.Position = UDim2.new(1, -30, 0, 5); Close.Size = UDim2.new(0, 25, 0, 25); Close.TextColor3 = Color3.new(1, 0.2, 0.2); Close.BackgroundTransparency = 1; Close.Font = Enum.Font.GothamBold; Close.MouseButton1Click:Connect(function() Screen:Destroy() end)
    local Hide = Instance.new("TextButton", TitleBar); Hide.Text = "-"; Hide.Position = UDim2.new(1, -60, 0, 5); Hide.Size = UDim2.new(0, 25, 0, 25); Hide.TextColor3 = Theme.TextMain; Hide.BackgroundTransparency = 1; Hide.Font = Enum.Font.GothamBold; Hide.MouseButton1Click:Connect(function() Main.Visible = false; OpenBtn.Visible = true end); OpenBtn.MouseButton1Click:Connect(function() Main.Visible = true; OpenBtn.Visible = false end)

    local Sidebar = Instance.new("ScrollingFrame", Main)
    Sidebar.Position = UDim2.new(0, 5, 0, 40); Sidebar.Size = UDim2.new(0, 110, 1, -45); Sidebar.BackgroundColor3 = Theme.Sidebar; Sidebar.BorderSizePixel = 0; Sidebar.ScrollBarThickness = 2; Sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)
    local SidebarLayout = Instance.new("UIListLayout", Sidebar); SidebarLayout.Padding = UDim.new(0, 4)
    local SidebarPadding = Instance.new("UIPadding", Sidebar); SidebarPadding.PaddingTop = UDim.new(0, 5); SidebarPadding.PaddingLeft = UDim.new(0, 5); SidebarPadding.PaddingRight = UDim.new(0, 5)
    SidebarLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Sidebar.CanvasSize = UDim2.new(0, 0, 0, SidebarLayout.AbsoluteContentSize.Y + 10) end)

    local Content = Instance.new("Frame", Main)
    Content.Position = UDim2.new(0, 120, 0, 40); Content.Size = UDim2.new(1, -125, 1, -45); Content.BackgroundTransparency = 1

    SendWebhookLog("OnExecute", "🚀 تشغيل جديد / NewExecution - Cryptic Hub V9!", Theme.Accent, {{name = "👥 السيرفر / Server:", value = #Players:GetPlayers() .. " / " .. Players.MaxPlayers .. " Players", inline = true}})

    local Window = { FirstTab = nil, Tabs = {} }

    local function LogAction(title, fieldName, fieldValue, color) if getgenv().CrypticLog then pcall(function() getgenv().CrypticLog("OnFeature", title, color or 16776960, {{name = fieldName, value = tostring(fieldValue), inline = false}}) end) end end

    -- [[ دالة إنشاء الأقسام (تصميم جديد للأقسام المفعلة) ]]
    function Window:CreateTab(name)
        local TabBtn = Instance.new("TextButton", Sidebar)
        TabBtn.Size = UDim2.new(1, 0, 0, 35); TabBtn.Text = name; TabBtn.BackgroundColor3 = Theme.Button; TabBtn.TextColor3 = Theme.TextSec; TabBtn.BorderSizePixel = 0; TabBtn.TextXAlignment = Enum.TextXAlignment.Left; TabBtn.Font = Enum.Font.Gotham; TabBtn.TextSize = 13
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)
        local TabPadding = Instance.new("UIPadding", TabBtn); TabPadding.PaddingLeft = UDim.new(0, 10)
        
        -- إطار الحدود الخضراء للأقسام المفعلة (مخفي افتراضياً)
        local TabStroke = Instance.new("UIStroke", TabBtn); TabStroke.Color = Theme.Accent; TabStroke.Thickness = 1.5; TabStroke.Transparency = 1; TabStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

        local Page = Instance.new("ScrollingFrame", Content); Page.Size = UDim2.new(1, 0, 1, 0); Page.Visible = false; Page.BackgroundTransparency = 1; Page.ScrollBarThickness = 2; Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        local ListLayout = Instance.new("UIListLayout", Page); ListLayout.Padding = UDim.new(0, 8); ListLayout.SortOrder = Enum.SortOrder.LayoutOrder 
        ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Page.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 15) end)

        table.insert(Window.Tabs, {Button = TabBtn, Stroke = TabStroke})

        -- جعل أول قسم هو المفعل تلقائياً
        if not Window.FirstTab then
            Window.FirstTab = Page; Page.Visible = true; TabBtn.TextColor3 = Theme.Accent; TabBtn.BackgroundColor3 = Color3.fromRGB(20,20,20); TabStroke.Transparency = 0.5
        end

        TabBtn.MouseButton1Click:Connect(function()
            -- إعادة تعيين شكل كل الأقسام
            for _, t in pairs(Window.Tabs) do
                t.Page.Visible = false; t.Button.TextColor3 = Theme.TextSec; t.Button.BackgroundColor3 = Theme.Button; t.Stroke.Transparency = 1
            end
            -- تفعيل القسم الحالي
            Page.Visible = true; TabBtn.TextColor3 = Theme.Accent; TabBtn.BackgroundColor3 = Color3.fromRGB(20,20,20); TabStroke.Transparency = 0.5
        end)

        Window.Tabs[#Window.Tabs].Page = Page

        local TabOps = {}; local orderIndex = 0 

        -- [[ تصميم العناصر الداخلية المحدث ]]
        function TabOps:AddProfileCard(player) orderIndex = orderIndex + 1; local R = Instance.new("Frame", Page); R.LayoutOrder = orderIndex; R.Size = UDim2.new(0.98, 0, 0, 75); R.BackgroundColor3 = Theme.Container; Instance.new("UICorner", R).CornerRadius = UDim.new(0, 8); local Avatar = Instance.new("ImageLabel", R); Avatar.Size = UDim2.new(0, 55, 0, 55); Avatar.Position = UDim2.new(1, -65, 0, 10); Avatar.BackgroundColor3 = Color3.fromRGB(40, 40, 40); Instance.new("UICorner", Avatar).CornerRadius = UDim.new(1, 0); task.spawn(function() local s, thumb = pcall(function() return game:GetService("Players"):GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420) end); if s and thumb then Avatar.Image = thumb end end); local NameLbl = Instance.new("TextLabel", R); NameLbl.Size = UDim2.new(1, -80, 0, 25); NameLbl.Position = UDim2.new(0, 10, 0, 12); NameLbl.BackgroundTransparency = 1; NameLbl.Text = "welcome, " .. player.DisplayName; NameLbl.TextColor3 = Theme.Accent; NameLbl.TextXAlignment = Enum.TextXAlignment.Right; NameLbl.Font = Enum.Font.GothamBold; NameLbl.TextSize = 16; local UserLbl = Instance.new("TextLabel", R); UserLbl.Size = UDim2.new(1, -80, 0, 20); UserLbl.Position = UDim2.new(0, 10, 0, 37); UserLbl.BackgroundTransparency = 1; UserLbl.Text = "@" .. player.Name; UserLbl.TextColor3 = Theme.TextSec; UserLbl.TextXAlignment = Enum.TextXAlignment.Right; UserLbl.Font = Enum.Font.Gotham; UserLbl.TextSize = 13 end
        function TabOps:AddLine() orderIndex = orderIndex + 1; local L = Instance.new("Frame", Page); L.LayoutOrder = orderIndex; L.Size = UDim2.new(0.95, 0, 0, 1); L.BackgroundColor3 = Theme.Button; L.BorderSizePixel = 0 end
        function TabOps:AddLabel(t) orderIndex = orderIndex + 1; local R = Instance.new("Frame", Page); R.LayoutOrder = orderIndex; R.Size = UDim2.new(0.98,0,0,30); R.BackgroundColor3 = Theme.Container; Instance.new("UICorner",R).CornerRadius = UDim.new(0,6); local L = Instance.new("TextLabel",R); L.Text = t; L.Size = UDim2.new(1,-20,1,0); L.Position = UDim2.new(0, 10, 0, 0); L.TextColor3 = Theme.Accent; L.BackgroundTransparency = 1; L.TextXAlignment = Enum.TextXAlignment.Right; L.Font = Enum.Font.Gotham; return {SetText=function(nt) L.Text=nt end} end
        function TabOps:AddParagraph(text) orderIndex = orderIndex + 1; local Lbl = Instance.new("TextLabel", Page); Lbl.LayoutOrder = orderIndex; Lbl.Size = UDim2.new(0.95, 0, 0, 0); Lbl.AutomaticSize = Enum.AutomaticSize.Y; Lbl.TextWrapped = true; Lbl.Text = text; Lbl.TextColor3 = Theme.TextSec; Lbl.BackgroundTransparency = 1; Lbl.TextXAlignment = Enum.TextXAlignment.Right; Lbl.TextSize = 13; Lbl.Font = Enum.Font.Gotham end
        function TabOps:AddButton(t, c) orderIndex = orderIndex + 1; local B = Instance.new("TextButton", Page); B.LayoutOrder = orderIndex; B.Size = UDim2.new(0.95, 0, 0, 40); B.BackgroundColor3 = Theme.Button; B.Text = t; B.TextColor3 = Theme.TextMain; B.Font = Enum.Font.GothamBold; Instance.new("UICorner", B).CornerRadius = UDim.new(0, 8); B.MouseButton1Click:Connect(function() LogAction("🔘 ضغطة زر", "تم الضغط على:", t, Theme.Accent); pcall(c) end) end

        function TabOps:AddInput(label, placeholder, callback)
            orderIndex = orderIndex + 1; local R = Instance.new("Frame", Page); R.LayoutOrder = orderIndex; R.Size = UDim2.new(0.95, 0, 0, 60); R.BackgroundColor3 = Theme.Container; Instance.new("UICorner", R).CornerRadius = UDim.new(0, 8); local Lbl = Instance.new("TextLabel", R); Lbl.Text = label; Lbl.Size = UDim2.new(1, -20, 0, 25); Lbl.Position = UDim2.new(0, 10, 0, 0); Lbl.TextColor3 = Theme.Accent; Lbl.BackgroundTransparency = 1; Lbl.TextXAlignment = Enum.TextXAlignment.Right; local I = Instance.new("TextBox", R); I.Size = UDim2.new(0.9, 0, 0, 25); I.Position = UDim2.new(0.05, 0, 0, 30); I.PlaceholderText = placeholder; I.BackgroundColor3 = Theme.Button; I.TextColor3 = Theme.TextMain; I.Text = ""; Instance.new("UICorner", I).CornerRadius = UDim.new(0, 6)
            local configKey = name .. "_" .. label .. "_Input"
            if UI.ConfigData[configKey] ~= nil then I.Text = UI.ConfigData[configKey]; task.spawn(function() task.wait(1.5) pcall(callback, I.Text) end) end
            I:GetPropertyChangedSignal("Text"):Connect(function() UI.ConfigData[configKey] = I.Text; pcall(callback, I.Text) end)
            I.FocusLost:Connect(function() if I.Text ~= "" then LogAction("⌨️ إدخال نص", label .. ":", I.Text, 10181046) end end)
            return { SetText = function(t) I.Text = t end, TextBox = I }
        end

        function TabOps:AddLargeInput(label, placeholder, callback)
            orderIndex = orderIndex + 1; local R = Instance.new("Frame", Page); R.LayoutOrder = orderIndex; R.Size = UDim2.new(0.95, 0, 0, 110); R.BackgroundColor3 = Theme.Container; Instance.new("UICorner", R).CornerRadius = UDim.new(0, 8)
            local Lbl = Instance.new("TextLabel", R); Lbl.Text = label; Lbl.Size = UDim2.new(1, -20, 0, 25); Lbl.Position = UDim2.new(0, 10, 0, 0); Lbl.TextColor3 = Theme.Accent; Lbl.BackgroundTransparency = 1; Lbl.TextXAlignment = Enum.TextXAlignment.Right
            local I = Instance.new("TextBox", R); I.Size = UDim2.new(0.9, 0, 0, 75); I.Position = UDim2.new(0.05, 0, 0, 25); I.PlaceholderText = placeholder; I.BackgroundColor3 = Theme.Button; I.TextColor3 = Theme.TextMain; I.Text = ""; I.MultiLine = true; I.TextWrapped = true; I.ClearTextOnFocus = false; I.TextYAlignment = Enum.TextYAlignment.Top; Instance.new("UICorner", I).CornerRadius = UDim.new(0, 6)
            I:GetPropertyChangedSignal("Text"):Connect(function() pcall(callback, I.Text) end)
            return { SetText = function(t) I.Text = t end, TextBox = I }
        end

        function TabOps:AddSpeedControl(label, callback, default)
            orderIndex = orderIndex + 1; local Row = Instance.new("Frame", Page); Row.LayoutOrder = orderIndex; Row.Size = UDim2.new(0.98, 0, 0, 45); Row.BackgroundColor3 = Theme.Container; Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 8); local Lbl = Instance.new("TextLabel", Row); Lbl.Text = label; Lbl.Size = UDim2.new(0.6, 0, 1, 0); Lbl.Position = UDim2.new(0.05, 0, 0, 0); Lbl.TextColor3 = Theme.TextMain; Lbl.BackgroundTransparency = 1; Lbl.TextXAlignment = Enum.TextXAlignment.Right; Lbl.Font = Enum.Font.Gotham; local Tgl = Instance.new("TextButton", Row); Tgl.Size = UDim2.new(0, 45, 0, 22); Tgl.Position = UDim2.new(1, -55, 0.5, -11); Tgl.Text = ""; Tgl.BackgroundColor3 = Theme.Button; Instance.new("UICorner", Tgl).CornerRadius = UDim.new(1, 0); local startVal = tostring(default or 50); local Inp = Instance.new("TextBox", Row); Inp.Size = UDim2.new(0, 40, 0, 22); Inp.Position = UDim2.new(1, -105, 0.5, -11); Inp.Text = startVal; Inp.BackgroundColor3 = Theme.Sidebar; Inp.TextColor3 = Theme.TextMain; Instance.new("UICorner", Inp).CornerRadius = UDim.new(0, 4); 
            local active = false
            local configKey = name .. "_" .. label .. "_Speed"
            if UI.ConfigData[configKey] ~= nil then active = UI.ConfigData[configKey].active; Inp.Text = tostring(UI.ConfigData[configKey].val) end
            local function update() Tgl.BackgroundColor3 = active and Theme.Accent or Theme.Button; local val = tonumber(Inp.Text) or tonumber(startVal); UI.ConfigData[configKey] = {active = active, val = val}; pcall(callback, active, val) end
            if active then task.spawn(function() task.wait(1.5) update() end) end
            Tgl.MouseButton1Click:Connect(function() active = not active; update(); LogAction("⚡ تحكم بالسرعة", label, active and ("مفعل - القيمة: " .. Inp.Text) or "معطل", active and Theme.Accent or 15548997) end)
            Inp:GetPropertyChangedSignal("Text"):Connect(function() if active then update() end end)
        end

        function TabOps:AddToggle(label, callback)
            orderIndex = orderIndex + 1; local R = Instance.new("Frame", Page); R.LayoutOrder = orderIndex; R.Size = UDim2.new(0.98, 0, 0, 45); R.BackgroundColor3 = Theme.Container; Instance.new("UICorner", R).CornerRadius = Theme.CornerRadius; local B = Instance.new("TextButton", R); B.Size = UDim2.new(0, 45, 0, 22); B.Position = UDim2.new(1, -55, 0.5, -11); B.Text = ""; B.BackgroundColor3 = Theme.Button; Instance.new("UICorner", B).CornerRadius = UDim.new(1, 0); local Lbl = Instance.new("TextLabel", R); Lbl.Text = label; Lbl.Size = UDim2.new(0.7, 0, 1, 0); Lbl.Position = UDim2.new(0.05, 0, 0, 0); Lbl.TextColor3 = Theme.TextMain; Lbl.BackgroundTransparency = 1; Lbl.TextXAlignment = Enum.TextXAlignment.Right; Lbl.Font = Enum.Font.Gotham; 
            local a = false
            local configKey = name .. "_" .. label
            if UI.ConfigData[configKey] ~= nil then a = UI.ConfigData[configKey] end
            local function set(s, isClick) a = s; B.BackgroundColor3 = a and Theme.Accent or Theme.Button; UI.ConfigData[configKey] = a; pcall(callback, a); if isClick then LogAction("⚙️ تفعيل/إيقاف ميزة", label, a and "مفعل ✅" or "معطل ❌", a and Theme.Accent or 15548997) end end
            B.BackgroundColor3 = a and Theme.Accent or Theme.Button
            if a then task.spawn(function() task.wait(1.5); pcall(callback, a) end) end
            B.MouseButton1Click:Connect(function() set(not a, true) end)
            return { SetSet = function(self, s) set(s, false) end, SetState = function(self, s) set(s, false) end }
        end

        function TabOps:AddTimedToggle(label, callback)
            orderIndex = orderIndex + 1; local R = Instance.new("Frame", Page); R.LayoutOrder = orderIndex; R.Size = UDim2.new(0.98, 0, 0, 45); R.BackgroundColor3 = Theme.Container; Instance.new("UICorner", R).CornerRadius = Theme.CornerRadius; local B = Instance.new("TextButton", R); B.Size = UDim2.new(0, 45, 0, 22); B.Position = UDim2.new(1, -55, 0.5, -11); B.Text = ""; B.BackgroundColor3 = Theme.Button; Instance.new("UICorner", B).CornerRadius = UDim.new(1, 0); local Lbl = Instance.new("TextLabel", R); Lbl.Text = label; Lbl.Size = UDim2.new(0.7, 0, 1, 0); Lbl.Position = UDim2.new(0.05, 0, 0, 0); Lbl.TextColor3 = Theme.TextMain; Lbl.BackgroundTransparency = 1; Lbl.TextXAlignment = Enum.TextXAlignment.Right; Lbl.Font = Enum.Font.Gotham; local isRunning = false
            B.MouseButton1Click:Connect(function() if isRunning then return end; isRunning = true; B.BackgroundColor3 = Theme.Accent; LogAction("⏱️ تفعيل مؤقت", label, "تم التفعيل", 15844367); task.spawn(function() pcall(callback, true); task.wait(2); if B then B.BackgroundColor3 = Theme.Button end; pcall(callback, false); isRunning = false end) end)
            return { Set = function() end, SetState = function() end }
        end

        function TabOps:AddPlayerSelector(label, placeholder, callback)
            orderIndex = orderIndex + 1; local Container = Instance.new("Frame", Page); Container.LayoutOrder = orderIndex; Container.Size = UDim2.new(0.95, 0, 0, 75); Container.BackgroundColor3 = Theme.Container; Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 8); local Lbl = Instance.new("TextLabel", Container); Lbl.Text = label; Lbl.Size = UDim2.new(1, -20, 0, 25); Lbl.Position = UDim2.new(0, 10, 0, 0); Lbl.TextColor3 = Theme.Accent; Lbl.BackgroundTransparency = 1; Lbl.TextXAlignment = Enum.TextXAlignment.Right; Lbl.Font = Enum.Font.Gotham; local SearchBox = Instance.new("TextBox", Container); SearchBox.Size = UDim2.new(0.9, 0, 0, 25); SearchBox.Position = UDim2.new(0.05, 0, 0, 25); SearchBox.PlaceholderText = placeholder; SearchBox.BackgroundColor3 = Theme.Button; SearchBox.TextColor3 = Theme.TextMain; SearchBox.Text = ""; SearchBox.ClearTextOnFocus = true; Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 6); local DropBtn = Instance.new("TextButton", Container); DropBtn.Size = UDim2.new(0.9, 0, 0, 18); DropBtn.Position = UDim2.new(0.05, 0, 0, 53); DropBtn.Text = "▼ عرض قائمة اللاعبين / Show Players ▼"; DropBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35); DropBtn.TextColor3 = Theme.TextSec; DropBtn.TextSize = 11; DropBtn.Font = Enum.Font.Gotham; Instance.new("UICorner", DropBtn).CornerRadius = UDim.new(0, 4); local DropList = Instance.new("ScrollingFrame", Container); DropList.Size = UDim2.new(0.9, 0, 0, 140); DropList.Position = UDim2.new(0.05, 0, 0, 75); DropList.BackgroundColor3 = Theme.Sidebar; DropList.Visible = false; DropList.ScrollBarThickness = 3; DropList.BorderSizePixel = 0; Instance.new("UICorner", DropList).CornerRadius = UDim.new(0, 6)
            local ListLayout = Instance.new("UIListLayout", DropList); ListLayout.Padding = UDim.new(0, 5); local ListPadding = Instance.new("UIPadding", DropList); ListPadding.PaddingTop = UDim.new(0, 5); ListPadding.PaddingLeft = UDim.new(0, 5); ListPadding.PaddingRight = UDim.new(0, 5)
            ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() DropList.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 10) end)
            local isOpen = false; local currentSelectedUser = nil; DropBtn.MouseButton1Click:Connect(function() isOpen = not isOpen; DropList.Visible = isOpen; Container.Size = isOpen and UDim2.new(0.95, 0, 0, 220) or UDim2.new(0.95, 0, 0, 75); DropBtn.Text = isOpen and "▲ إغلاق القائمة / Close List ▲" or "▼ عرض قائمة اللاعبين / Show Players ▼" end)
            local function UpdateList(playersList) for _, v in pairs(DropList:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end; for _, p in pairs(playersList) do local PItem = Instance.new("Frame", DropList); PItem.Name = p.Name; PItem.Size = UDim2.new(1, 0, 0, 40); PItem.BackgroundColor3 = (currentSelectedUser == p.Name) and Color3.fromRGB(40, 40, 40) or Theme.Button; Instance.new("UICorner", PItem).CornerRadius = UDim.new(0, 6); local Avatar = Instance.new("ImageLabel", PItem); Avatar.Size = UDim2.new(0, 30, 0, 30); Avatar.Position = UDim2.new(0, 5, 0, 5); Avatar.BackgroundColor3 = Theme.Container; Instance.new("UICorner", Avatar).CornerRadius = UDim.new(1, 0); task.spawn(function() local s, t = pcall(function() return game:GetService("Players"):GetUserThumbnailAsync(p.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420) end); if s and t then Avatar.Image = t end end); local NLabel = Instance.new("TextLabel", PItem); NLabel.Size = UDim2.new(1, -45, 0, 20); NLabel.Position = UDim2.new(0, 40, 0, 2); NLabel.Text = p.DisplayName; NLabel.TextColor3 = Theme.TextMain; NLabel.BackgroundTransparency = 1; NLabel.TextXAlignment = Enum.TextXAlignment.Left; NLabel.Font = Enum.Font.GothamBold; NLabel.TextSize = 12; local ULabel = Instance.new("TextLabel", PItem); ULabel.Size = UDim2.new(1, -45, 0, 20); ULabel.Position = UDim2.new(0, 40, 0, 20); ULabel.Text = "@" .. p.Name; ULabel.TextColor3 = Theme.TextSec; ULabel.BackgroundTransparency = 1; ULabel.TextXAlignment = Enum.TextXAlignment.Left; ULabel.Font = Enum.Font.Gotham; ULabel.TextSize = 10; local SelectBtn = Instance.new("TextButton", PItem); SelectBtn.Size = UDim2.new(1, 0, 1, 0); SelectBtn.BackgroundTransparency = 1; SelectBtn.Text = ""; SelectBtn.MouseButton1Click:Connect(function() currentSelectedUser = p.Name; SearchBox.Text = p.DisplayName .. " (@" .. p.Name .. ")"; for _, v in pairs(DropList:GetChildren()) do if v:IsA("Frame") then v.BackgroundColor3 = (v.Name == currentSelectedUser) and Color3.fromRGB(40, 40, 40) or Theme.Button end end; task.wait(0.15); isOpen = false; DropList.Visible = false; Container.Size = UDim2.new(0.95, 0, 0, 75); DropBtn.Text = "▼ عرض قائمة اللاعبين / Show Players ▼"; pcall(callback, p) end) end end
            SearchBox.Focused:Connect(function() currentSelectedUser = nil; for _, v in pairs(DropList:GetChildren()) do if v:IsA("Frame") then v.BackgroundColor3 = Theme.Button end end; pcall(callback, nil) end)
            SearchBox.FocusLost:Connect(function() local txt = SearchBox.Text; if txt == "" then currentSelectedUser = nil; for _, v in pairs(DropList:GetChildren()) do if v:IsA("Frame") then v.BackgroundColor3 = Theme.Button end end; pcall(callback, nil); return end; local bestMatch = nil; local search = txt:lower(); for _, p in pairs(Players:GetPlayers()) do if p ~= Players.LocalPlayer and string.sub(p.Name:lower(), 1, #search) == search then bestMatch = p; break end end; if bestMatch then currentSelectedUser = bestMatch.Name; SearchBox.Text = bestMatch.DisplayName .. " (@" .. bestMatch.Name .. ")"; for _, v in pairs(DropList:GetChildren()) do if v:IsA("Frame") then v.BackgroundColor3 = (v.Name == currentSelectedUser) and Color3.fromRGB(40, 40, 40) or Theme.Button end end; pcall(callback, bestMatch) else currentSelectedUser = nil; for _, v in pairs(DropList:GetChildren()) do if v:IsA("Frame") then v.BackgroundColor3 = Theme.Button end end; pcall(callback, txt) end end)
            return { SetText = function(t) SearchBox.Text = t end, UpdateList = UpdateList, Clear = function() SearchBox.Text = ""; currentSelectedUser = nil; for _, v in pairs(DropList:GetChildren()) do if v:IsA("Frame") then v.BackgroundColor3 = Theme.Button end end end }
        end

        function TabOps:AddDropdown(label, options, callback)
            orderIndex = orderIndex + 1; local isOpen = false; local DropdownFrame = Instance.new("Frame", Page); DropdownFrame.LayoutOrder = orderIndex; DropdownFrame.BackgroundColor3 = Theme.Container; DropdownFrame.ClipsDescendants = true; DropdownFrame.Size = UDim2.new(0.95, 0, 0, 40); Instance.new("UICorner", DropdownFrame).CornerRadius = UDim.new(0, 8); local MainBtn = Instance.new("TextButton", DropdownFrame); MainBtn.Size = UDim2.new(1, 0, 0, 40); MainBtn.BackgroundTransparency = 1; MainBtn.Text = ""; local TitleLbl = Instance.new("TextLabel", MainBtn); TitleLbl.Size = UDim2.new(1, -20, 1, 0); TitleLbl.Position = UDim2.new(0, -10, 0, 0); TitleLbl.BackgroundTransparency = 1; TitleLbl.Text = label .. " : [اختر]"; TitleLbl.TextColor3 = Theme.Accent; TitleLbl.TextXAlignment = Enum.TextXAlignment.Right; TitleLbl.Font = Enum.Font.Gotham; local ArrowLbl = Instance.new("TextLabel", MainBtn); ArrowLbl.Size = UDim2.new(0, 30, 1, 0); ArrowLbl.Position = UDim2.new(0, 5, 0, 0); ArrowLbl.BackgroundTransparency = 1; ArrowLbl.Text = "▼"; ArrowLbl.TextColor3 = Theme.TextMain; local OptionsContainer = Instance.new("ScrollingFrame", DropdownFrame); OptionsContainer.Size = UDim2.new(1, 0, 1, -40); OptionsContainer.Position = UDim2.new(0, 0, 0, 40); OptionsContainer.BackgroundTransparency = 1; OptionsContainer.ScrollBarThickness = 2; OptionsContainer.BorderSizePixel = 0; local OptLayout = Instance.new("UIListLayout", OptionsContainer); OptLayout.SortOrder = Enum.SortOrder.LayoutOrder; OptLayout.Padding = UDim.new(0, 3); local OptPadding = Instance.new("UIPadding", OptionsContainer); OptPadding.PaddingTop = UDim.new(0, 5); OptPadding.PaddingLeft = UDim.new(0, 5); OptPadding.PaddingRight = UDim.new(0, 5)
            local function RefreshSize() if isOpen then local h = math.clamp(OptLayout.AbsoluteContentSize.Y + 50, 40, 150); DropdownFrame.Size = UDim2.new(0.95, 0, 0, h); OptionsContainer.CanvasSize = UDim2.new(0, 0, 0, OptLayout.AbsoluteContentSize.Y + 10) else DropdownFrame.Size = UDim2.new(0.95, 0, 0, 40) end end
            MainBtn.MouseButton1Click:Connect(function() isOpen = not isOpen; ArrowLbl.Text = isOpen and "▲" or "▼"; RefreshSize() end)
            for i, opt in ipairs(options) do local OptBtn = Instance.new("TextButton", OptionsContainer); OptBtn.Size = UDim2.new(1, 0, 0, 30); OptBtn.BackgroundColor3 = Theme.Button; OptBtn.Text = tostring(opt); OptBtn.TextColor3 = Theme.TextMain; OptBtn.Font = Enum.Font.Gotham; Instance.new("UICorner", OptBtn).CornerRadius = UDim.new(0, 6); OptBtn.MouseButton1Click:Connect(function() TitleLbl.Text = label .. " : " .. tostring(opt); isOpen = false; ArrowLbl.Text = "▼"; RefreshSize(); LogAction("🔽 اختيار من القائمة", label, tostring(opt), 15105570); pcall(callback, opt) end) end
            return { Refresh = function(newOptions) for _, v in pairs(OptionsContainer:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end; for i, opt in ipairs(newOptions) do local OptBtn = Instance.new("TextButton", OptionsContainer); OptBtn.Size = UDim2.new(1, 0, 0, 30); OptBtn.BackgroundColor3 = Theme.Button; OptBtn.Text = tostring(opt); OptBtn.TextColor3 = Theme.TextMain; Instance.new("UICorner", OptBtn).CornerRadius = UDim.new(0, 6); OptBtn.MouseButton1Click:Connect(function() TitleLbl.Text = label .. " : " .. tostring(opt); isOpen = false; ArrowLbl.Text = "▼"; RefreshSize(); LogAction("🔽 اختيار من القائمة", label, tostring(opt), 15105570); pcall(callback, opt) end) end; if isOpen then RefreshSize() end end }
        end

        return TabOps
    end
    return Window
end

return UI
