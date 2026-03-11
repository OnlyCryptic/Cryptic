-- [[ Cryptic Hub - محرك الواجهة المطور V6.5 ]]
-- المطور: يامي (Yami) | التحديث: إضافة مربع الإدخال الكبير (Large Input) للاقتراحات

local UI = { Logger = nil } 
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

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

function UI:ResetConfig()
    pcall(function()
        if isfile and isfile(ConfigFile) then delfile(ConfigFile) end
        UI.ConfigData = {}
        local queue_tp = queue_on_teleport or (syn and syn.queue_on_teleport) or (getgenv and getgenv().queue_on_teleport)
        if queue_tp then
            queue_tp([[ task.wait(3) loadstring(game:HttpGet("https://raw.githubusercontent.com/OnlyCryptic/Cryptic/main/main.lua"))() ]])
        end
        local player = Players.LocalPlayer
        if #game.JobId > 0 then TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player) else TeleportService:Teleport(game.PlaceId, player) end
    end)
end

function UI:CreateWindow(title)
    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "CrypticHub_V5"; Screen.ResetOnSpawn = false

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
    OpenBtn.Size = UDim2.new(0, 85, 0, 35); OpenBtn.Position = UDim2.new(0, 10, 0.5, -17); OpenBtn.Visible = false; OpenBtn.Text = "Cryptic"; OpenBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 150); OpenBtn.TextColor3 = Color3.fromRGB(15, 15, 15); OpenBtn.Font = Enum.Font.GothamBold; OpenBtn.TextSize = 14; Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)
    local OpenStroke = Instance.new("UIStroke", OpenBtn); OpenStroke.Color = Color3.fromRGB(255, 255, 255); OpenStroke.Thickness = 2; OpenStroke.Transparency = 0.5

    local dragToggle, dragInputT, dragStartT, startPosT
    OpenBtn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragToggle = true; dragStartT = input.Position; startPosT = OpenBtn.Position; input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragToggle = false end end) end end)
    OpenBtn.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInputT = input end end)
    UserInputService.InputChanged:Connect(function(input) if input == dragInputT and dragToggle then local delta = input.Position - dragStartT; OpenBtn.Position = UDim2.new(startPosT.X.Scale, startPosT.X.Offset + delta.X, startPosT.Y.Scale, startPosT.Y.Offset + delta.Y) end end)

    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 440, 0, 280); Main.Position = UDim2.new(0.5, 0, 0.5, 0); Main.AnchorPoint = Vector2.new(0.5, 0.5); Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Main.Active = true; Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12); Main.ClipsDescendants = true 

    local TitleBar = Instance.new("Frame", Main)
    TitleBar.Size = UDim2.new(1, 0, 0, 35); TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", TitleBar)
    local TitleLabel = Instance.new("TextLabel", TitleBar)
    TitleLabel.Text = title; TitleLabel.Size = UDim2.new(1, -120, 1, 0); TitleLabel.Position = UDim2.new(0, 10, 0, 0); TitleLabel.BackgroundTransparency = 1; TitleLabel.TextColor3 = Color3.new(1, 1, 1); TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local draggingMain, dragInputMain, dragStartMain, startPosMain
    TitleBar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingMain = true; dragStartMain = input.Position; startPosMain = Main.Position; input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then draggingMain = false end end) end end)
    TitleBar.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInputMain = input end end)
    UserInputService.InputChanged:Connect(function(input) if input == dragInputMain and draggingMain then local delta = input.Position - dragStartMain; Main.Position = UDim2.new(startPosMain.X.Scale, startPosMain.X.Offset + delta.X, startPosMain.Y.Scale, startPosMain.Y.Offset + delta.Y) end end)

    local Close = Instance.new("TextButton", TitleBar); Close.Text = "X"; Close.Position = UDim2.new(1, -35, 0, 5); Close.Size = UDim2.new(0, 25, 0, 25); Close.TextColor3 = Color3.new(1, 0, 0); Close.BackgroundTransparency = 1; Close.MouseButton1Click:Connect(function() Screen:Destroy() end)
    local Hide = Instance.new("TextButton", TitleBar); Hide.Text = "-"; Hide.Position = UDim2.new(1, -70, 0, 5); Hide.Size = UDim2.new(0, 25, 0, 25); Hide.TextColor3 = Color3.new(1, 1, 1); Hide.BackgroundTransparency = 1; Hide.MouseButton1Click:Connect(function() Main.Visible = false; OpenBtn.Visible = true end); OpenBtn.MouseButton1Click:Connect(function() Main.Visible = true; OpenBtn.Visible = false end)

    local Sidebar = Instance.new("ScrollingFrame", Main)
    Sidebar.Position = UDim2.new(0, 0, 0, 35); Sidebar.Size = UDim2.new(0, 110, 1, -35); Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 20); Sidebar.BorderSizePixel = 0; Sidebar.ScrollBarThickness = 2; Sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
    local SidebarLayout = Instance.new("UIListLayout", Sidebar); SidebarLayout.Padding = UDim.new(0, 2)
    SidebarLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Sidebar.CanvasSize = UDim2.new(0, 0, 0, SidebarLayout.AbsoluteContentSize.Y + 5) end)

    local Content = Instance.new("Frame", Main)
    Content.Position = UDim2.new(0, 115, 0, 40); Content.Size = UDim2.new(1, -120, 1, -45); Content.BackgroundTransparency = 1

    local Window = { FirstTab = nil }

    local function LogAction(title, fieldName, fieldValue, color)
        if getgenv().CrypticLog then pcall(function() getgenv().CrypticLog("OnFeature", title, color or 16776960, {{name = fieldName, value = tostring(fieldValue), inline = false}}) end) end
    end

    function Window:CreateTab(name)
        local TabBtn = Instance.new("TextButton", Sidebar); TabBtn.Size = UDim2.new(1, 0, 0, 35); TabBtn.Text = name; TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); TabBtn.TextColor3 = Color3.new(1, 1, 1); TabBtn.BorderSizePixel = 0
        local Page = Instance.new("ScrollingFrame", Content); Page.Size = UDim2.new(1, 0, 1, 0); Page.Visible = false; Page.BackgroundTransparency = 1; Page.ScrollBarThickness = 2; Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        local ListLayout = Instance.new("UIListLayout", Page); ListLayout.Padding = UDim.new(0, 8); ListLayout.SortOrder = Enum.SortOrder.LayoutOrder 
        ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Page.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 15) end)

        if not Window.FirstTab then Window.FirstTab = Page; Page.Visible = true end
        TabBtn.MouseButton1Click:Connect(function() for _, v in pairs(Content:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end; Page.Visible = true end)

        local TabOps = {}
        local orderIndex = 0 

        function TabOps:AddProfileCard(player) orderIndex = orderIndex + 1; local R = Instance.new("Frame", Page); R.LayoutOrder = orderIndex; R.Size = UDim2.new(0.98, 0, 0, 75); R.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", R).CornerRadius = UDim.new(0, 8); local Avatar = Instance.new("ImageLabel", R); Avatar.Size = UDim2.new(0, 55, 0, 55); Avatar.Position = UDim2.new(1, -65, 0, 10); Avatar.BackgroundColor3 = Color3.fromRGB(40, 40, 40); Instance.new("UICorner", Avatar).CornerRadius = UDim.new(1, 0); task.spawn(function() local s, thumb = pcall(function() return game:GetService("Players"):GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420) end); if s and thumb then Avatar.Image = thumb end end); local NameLbl = Instance.new("TextLabel", R); NameLbl.Size = UDim2.new(1, -80, 0, 25); NameLbl.Position = UDim2.new(0, 10, 0, 12); NameLbl.BackgroundTransparency = 1; NameLbl.Text = "welcome, " .. player.DisplayName; NameLbl.TextColor3 = Color3.fromRGB(0, 255, 150); NameLbl.TextXAlignment = Enum.TextXAlignment.Right; NameLbl.Font = Enum.Font.GothamBold; NameLbl.TextSize = 16; local UserLbl = Instance.new("TextLabel", R); UserLbl.Size = UDim2.new(1, -80, 0, 20); UserLbl.Position = UDim2.new(0, 10, 0, 37); UserLbl.BackgroundTransparency = 1; UserLbl.Text = "@" .. player.Name; UserLbl.TextColor3 = Color3.fromRGB(170, 170, 170); UserLbl.TextXAlignment = Enum.TextXAlignment.Right; UserLbl.Font = Enum.Font.Gotham; UserLbl.TextSize = 13 end
        function TabOps:AddLine() orderIndex = orderIndex + 1; local L = Instance.new("Frame", Page); L.LayoutOrder = orderIndex; L.Size = UDim2.new(0.95, 0, 0, 1); L.BackgroundColor3 = Color3.fromRGB(50, 50, 50); L.BackgroundTransparency = 0.5; L.BorderSizePixel = 0 end
        function TabOps:AddLabel(t) orderIndex = orderIndex + 1; local R = Instance.new("Frame", Page); R.LayoutOrder = orderIndex; R.Size = UDim2.new(0.98,0,0,35); R.BackgroundColor3 = Color3.fromRGB(25,25,25); Instance.new("UICorner",R); local L = Instance.new("TextLabel",R); L.Text = t; L.Size = UDim2.new(1,-10,1,0); L.TextColor3 = Color3.fromRGB(0, 255, 150); L.BackgroundTransparency = 1; L.TextXAlignment = Enum.TextXAlignment.Right; return {SetText=function(nt) L.Text=nt end} end
        function TabOps:AddParagraph(text) orderIndex = orderIndex + 1; local Lbl = Instance.new("TextLabel", Page); Lbl.LayoutOrder = orderIndex; Lbl.Size = UDim2.new(0.95, 0, 0, 0); Lbl.AutomaticSize = Enum.AutomaticSize.Y; Lbl.TextWrapped = true; Lbl.Text = text; Lbl.TextColor3 = Color3.fromRGB(170, 170, 170); Lbl.BackgroundTransparency = 1; Lbl.TextXAlignment = Enum.TextXAlignment.Right; Lbl.TextSize = 13 end
        function TabOps:AddButton(t, c) orderIndex = orderIndex + 1; local B = Instance.new("TextButton", Page); B.LayoutOrder = orderIndex; B.Size = UDim2.new(0.95, 0, 0, 40); B.BackgroundColor3 = Color3.fromRGB(30, 30, 30); B.Text = t; B.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", B); B.MouseButton1Click:Connect(function() LogAction("🔘 ضغطة زر", "تم الضغط على:", t, 3447003); pcall(c) end) end

        function TabOps:AddInput(label, placeholder, callback)
            orderIndex = orderIndex + 1; local R = Instance.new("Frame", Page); R.LayoutOrder = orderIndex; R.Size = UDim2.new(0.95, 0, 0, 60); R.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", R); local Lbl = Instance.new("TextLabel", R); Lbl.Text = label; Lbl.Size = UDim2.new(1, -10, 0, 25); Lbl.TextColor3 = Color3.fromRGB(0, 255, 150); Lbl.BackgroundTransparency = 1; Lbl.TextXAlignment = Enum.TextXAlignment.Right; local I = Instance.new("TextBox", R); I.Size = UDim2.new(0.9, 0, 0, 25); I.Position = UDim2.new(0.05, 0, 0, 30); I.PlaceholderText = placeholder; I.BackgroundColor3 = Color3.fromRGB(40, 40, 40); I.TextColor3 = Color3.new(1, 1, 1); I.Text = ""; Instance.new("UICorner", I); 
            local configKey = name .. "_" .. label .. "_Input"
            if UI.ConfigData[configKey] ~= nil then I.Text = UI.ConfigData[configKey]; task.spawn(function() task.wait(1.5) pcall(callback, I.Text) end) end
            I:GetPropertyChangedSignal("Text"):Connect(function() UI.ConfigData[configKey] = I.Text; pcall(callback, I.Text) end)
            I.FocusLost:Connect(function() if I.Text ~= "" then LogAction("⌨️ إدخال نص", label .. ":", I.Text, 10181046) end end)
            return { SetText = function(t) I.Text = t end, TextBox = I }
        end

        -- [[ إضافة المربع الكبير (Large Input) لكتابة الرسائل الطويلة ]]
        function TabOps:AddLargeInput(label, placeholder, callback)
            orderIndex = orderIndex + 1
            local R = Instance.new("Frame", Page)
            R.LayoutOrder = orderIndex
            R.Size = UDim2.new(0.95, 0, 0, 110) -- ارتفاع أكبر
            R.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            Instance.new("UICorner", R)

            local Lbl = Instance.new("TextLabel", R)
            Lbl.Text = label
            Lbl.Size = UDim2.new(1, -10, 0, 25)
            Lbl.TextColor3 = Color3.fromRGB(0, 255, 150)
            Lbl.BackgroundTransparency = 1
            Lbl.TextXAlignment = Enum.TextXAlignment.Right

            local I = Instance.new("TextBox", R)
            I.Size = UDim2.new(0.9, 0, 0, 75)
            I.Position = UDim2.new(0.05, 0, 0, 25)
            I.PlaceholderText = placeholder
            I.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            I.TextColor3 = Color3.new(1, 1, 1)
            I.Text = ""
            I.MultiLine = true -- يسمح بالكتابة في أسطر متعددة (مثل واتساب)
            I.TextWrapped = true -- يمنع النص من الخروج عن الإطار
            I.ClearTextOnFocus = false
            I.TextYAlignment = Enum.TextYAlignment.Top -- يبدأ الكتابة من الأعلى
            Instance.new("UICorner", I)

            -- لا نحفظ الرسالة في Config لأنها سترسل وتحذف
            I:GetPropertyChangedSignal("Text"):Connect(function() pcall(callback, I.Text) end)

            -- إرجاع دالة للتحكم في النص برمجياً (لمسحه بعد الإرسال)
            return { SetText = function(t) I.Text = t end, TextBox = I }
        end

        function TabOps:AddSpeedControl(label, callback, default)
            orderIndex = orderIndex + 1; local Row = Instance.new("Frame", Page); Row.LayoutOrder = orderIndex; Row.Size = UDim2.new(0.98, 0, 0, 45); Row.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", Row); local Lbl = Instance.new("TextLabel", Row); Lbl.Text = label; Lbl.Size = UDim2.new(0.6, 0, 1, 0); Lbl.Position = UDim2.new(0.05, 0, 0, 0); Lbl.TextColor3 = Color3.new(1, 1, 1); Lbl.BackgroundTransparency = 1; Lbl.TextXAlignment = Enum.TextXAlignment.Right; local Tgl = Instance.new("TextButton", Row); Tgl.Size = UDim2.new(0, 45, 0, 22); Tgl.Position = UDim2.new(1, -55, 0.5, -11); Tgl.Text = ""; Tgl.BackgroundColor3 = Color3.fromRGB(60, 60, 60); Instance.new("UICorner", Tgl).CornerRadius = UDim.new(1, 0); local startVal = tostring(default or 50); local Inp = Instance.new("TextBox", Row); Inp.Size = UDim2.new(0, 40, 0, 22); Inp.Position = UDim2.new(1, -105, 0.5, -11); Inp.Text = startVal; Inp.BackgroundColor3 = Color3.fromRGB(40, 40, 40); Inp.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", Inp); 
            local active = false
            local configKey = name .. "_" .. label .. "_Speed"
            if UI.ConfigData[configKey] ~= nil then active = UI.ConfigData[configKey].active; Inp.Text = tostring(UI.ConfigData[configKey].val) end
            local function update() Tgl.BackgroundColor3 = active and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(60, 60, 60); local val = tonumber(Inp.Text) or tonumber(startVal); UI.ConfigData[configKey] = {active = active, val = val}; pcall(callback, active, val) end
            if active then task.spawn(function() task.wait(1.5) update() end) end
            Tgl.MouseButton1Click:Connect(function() active = not active; update(); LogAction("⚡ تحكم بالسرعة", label, active and ("مفعل - القيمة: " .. Inp.Text) or "معطل", active and 5763719 or 15548997) end)
            Inp:GetPropertyChangedSignal("Text"):Connect(function() if active then update() end end)
        end

        function TabOps:AddToggle(label, callback)
            orderIndex = orderIndex + 1; local R = Instance.new("Frame", Page); R.LayoutOrder = orderIndex; R.Size = UDim2.new(0.98, 0, 0, 45); R.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", R); local B = Instance.new("TextButton", R); B.Size = UDim2.new(0, 45, 0, 22); B.Position = UDim2.new(1, -55, 0.5, -11); B.Text = ""; B.BackgroundColor3 = Color3.fromRGB(60, 60, 60); Instance.new("UICorner", B).CornerRadius = UDim.new(1, 0); local Lbl = Instance.new("TextLabel", R); Lbl.Text = label; Lbl.Size = UDim2.new(0.7, 0, 1, 0); Lbl.Position = UDim2.new(0.05, 0, 0, 0); Lbl.TextColor3 = Color3.new(1, 1, 1); Lbl.BackgroundTransparency = 1; Lbl.TextXAlignment = Enum.TextXAlignment.Right; 
            local a = false
            local configKey = name .. "_" .. label
            if UI.ConfigData[configKey] ~= nil then a = UI.ConfigData[configKey] end
            local function set(s, isClick) a = s; B.BackgroundColor3 = a and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(60, 60, 60); UI.ConfigData[configKey] = a; pcall(callback, a); if isClick then LogAction("⚙️ تفعيل/إيقاف ميزة", label, a and "مفعل ✅" or "معطل ❌", a and 5763719 or 15548997) end end
            B.BackgroundColor3 = a and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(60, 60, 60)
            if a then task.spawn(function() task.wait(1.5); pcall(callback, a) end) end
            B.MouseButton1Click:Connect(function() set(not a, true) end)
            return { SetState = function(self, s) set(s, false) end, Set = function(self, s) set(s, false) end }
        end

        function TabOps:AddTimedToggle(label, callback)
            orderIndex = orderIndex + 1; local R = Instance.new("Frame", Page); R.LayoutOrder = orderIndex; R.Size = UDim2.new(0.98, 0, 0, 45); R.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", R); local B = Instance.new("TextButton", R); B.Size = UDim2.new(0, 45, 0, 22); B.Position = UDim2.new(1, -55, 0.5, -11); B.Text = ""; B.BackgroundColor3 = Color3.fromRGB(60, 60, 60); Instance.new("UICorner", B).CornerRadius = UDim.new(1, 0); local Lbl = Instance.new("TextLabel", R); Lbl.Text = label; Lbl.Size = UDim2.new(0.7, 0, 1, 0); Lbl.Position = UDim2.new(0.05, 0, 0, 0); Lbl.TextColor3 = Color3.new(1, 1, 1); Lbl.BackgroundTransparency = 1; Lbl.TextXAlignment = Enum.TextXAlignment.Right; local isRunning = false
            B.MouseButton1Click:Connect(function() if isRunning then return end; isRunning = true; B.BackgroundColor3 = Color3.fromRGB(0, 150, 255); LogAction("⏱️ تفعيل مؤقت", label, "تم التفعيل", 15844367); task.spawn(function() pcall(callback, true); task.wait(2); if B then B.BackgroundColor3 = Color3.fromRGB(60, 60, 60) end; pcall(callback, false); isRunning = false end) end)
            return { Set = function() end, SetState = function() end }
        end

                -- [[ إضافة المربع الكبير (Large Input) لكتابة الرسائل الطويلة ]]
        function TabOps:AddLargeInput(label, placeholder, callback)
            orderIndex = orderIndex + 1
            local R = Instance.new("Frame", Page)
            R.LayoutOrder = orderIndex
            R.Size = UDim2.new(0.95, 0, 0, 110) -- ارتفاع أكبر
            R.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            Instance.new("UICorner", R)

            local Lbl = Instance.new("TextLabel", R)
            Lbl.Text = label
            Lbl.Size = UDim2.new(1, -10, 0, 25)
            Lbl.TextColor3 = Color3.fromRGB(0, 255, 150)
            Lbl.BackgroundTransparency = 1
            Lbl.TextXAlignment = Enum.TextXAlignment.Right

            local I = Instance.new("TextBox", R)
            I.Size = UDim2.new(0.9, 0, 0, 75)
            I.Position = UDim2.new(0.05, 0, 0, 25)
            I.PlaceholderText = placeholder
            I.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            I.TextColor3 = Color3.new(1, 1, 1)
            I.Text = ""
            I.MultiLine = true -- يسمح بالكتابة في أسطر متعددة (مثل واتساب)
            I.TextWrapped = true -- يمنع النص من الخروج عن الإطار
            I.ClearTextOnFocus = false
            I.TextYAlignment = Enum.TextYAlignment.Top -- يبدأ الكتابة من الأعلى
            Instance.new("UICorner", I)

            -- لا نحفظ الرسالة في Config لأنها سترسل وتحذف
            I:GetPropertyChangedSignal("Text"):Connect(function() pcall(callback, I.Text) end)

            -- إرجاع دالة للتحكم في النص برمجياً (لمسحه بعد الإرسال)
            return { SetText = function(t) I.Text = t end, TextBox = I }
        end

                        -- [[ إضافة قائمة اللاعبين الاحترافية (Player Selector) ]]
        function TabOps:AddPlayerSelector(label, placeholder, callback)
            orderIndex = orderIndex + 1
            local Container = Instance.new("Frame", Page)
            Container.LayoutOrder = orderIndex
            Container.Size = UDim2.new(0.95, 0, 0, 75)
            Container.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            Instance.new("UICorner", Container)
            
            local Lbl = Instance.new("TextLabel", Container)
            Lbl.Text = label
            Lbl.Size = UDim2.new(1, -10, 0, 25)
            Lbl.TextColor3 = Color3.fromRGB(0, 255, 150)
            Lbl.BackgroundTransparency = 1
            Lbl.TextXAlignment = Enum.TextXAlignment.Right

            -- المستطيل الأول (للبحث اليدوي)
            local SearchBox = Instance.new("TextBox", Container)
            SearchBox.Size = UDim2.new(0.9, 0, 0, 25)
            SearchBox.Position = UDim2.new(0.05, 0, 0, 25)
            SearchBox.PlaceholderText = placeholder
            SearchBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            SearchBox.TextColor3 = Color3.new(1, 1, 1)
            SearchBox.Text = ""
            SearchBox.ClearTextOnFocus = true -- تم تفعيل المسح التلقائي عند الضغط
            Instance.new("UICorner", SearchBox)

            -- المستطيل الأصغر (الزر لفتح القائمة)
            local DropBtn = Instance.new("TextButton", Container)
            DropBtn.Size = UDim2.new(0.9, 0, 0, 15)
            DropBtn.Position = UDim2.new(0.05, 0, 0, 55)
            DropBtn.Text = "▼ عرض قائمة اللاعبين / Show Players ▼"
            DropBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            DropBtn.TextColor3 = Color3.fromRGB(170, 170, 170)
            DropBtn.TextSize = 11
            Instance.new("UICorner", DropBtn)

            -- القائمة المنسدلة (المكان الاحترافي)
            local DropList = Instance.new("ScrollingFrame", Container)
            DropList.Size = UDim2.new(0.9, 0, 0, 140)
            DropList.Position = UDim2.new(0.05, 0, 0, 75)
            DropList.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            DropList.Visible = false
            DropList.ScrollBarThickness = 2
            Instance.new("UICorner", DropList)
            
            local ListLayout = Instance.new("UIListLayout", DropList)
            ListLayout.Padding = UDim.new(0, 5)
            ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() 
                DropList.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 5) 
            end)

            local isOpen = false
            local currentSelectedUser = nil -- لحفظ اسم اللاعب المحدد

            DropBtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                DropList.Visible = isOpen
                Container.Size = isOpen and UDim2.new(0.95, 0, 0, 220) or UDim2.new(0.95, 0, 0, 75)
                DropBtn.Text = isOpen and "▲ إغلاق القائمة / Close List ▲" or "▼ عرض قائمة اللاعبين / Show Players ▼"
            end)

            local function UpdateList(playersList)
                for _, v in pairs(DropList:GetChildren()) do
                    if v:IsA("Frame") then v:Destroy() end
                end
                for _, p in pairs(playersList) do
                    local PItem = Instance.new("Frame", DropList)
                    PItem.Name = p.Name -- نعطي المربع اسم اللاعب عشان نلقاه بسرعة
                    PItem.Size = UDim2.new(1, -10, 0, 40)
                    
                    -- لو كان اللاعب محدد، خليه أخضر، وإلا رمادي
                    if currentSelectedUser == p.Name then
                        PItem.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
                    else
                        PItem.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                    end
                    
                    Instance.new("UICorner", PItem)

                    -- صورة اللاعب المصغرة
                    local Avatar = Instance.new("ImageLabel", PItem)
                    Avatar.Size = UDim2.new(0, 30, 0, 30)
                    Avatar.Position = UDim2.new(0, 5, 0, 5)
                    Avatar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                    Instance.new("UICorner", Avatar).CornerRadius = UDim.new(1, 0)
                    task.spawn(function()
                        local s, thumb = pcall(function() return game:GetService("Players"):GetUserThumbnailAsync(p.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420) end)
                        if s and thumb then Avatar.Image = thumb end
                    end)

                    -- الاسم
                    local NLabel = Instance.new("TextLabel", PItem)
                    NLabel.Size = UDim2.new(1, -45, 0, 20); NLabel.Position = UDim2.new(0, 40, 0, 0)
                    NLabel.Text = p.DisplayName; NLabel.TextColor3 = Color3.new(1, 1, 1)
                    NLabel.BackgroundTransparency = 1; NLabel.TextXAlignment = Enum.TextXAlignment.Left; NLabel.Font = Enum.Font.GothamBold; NLabel.TextSize = 12

                    -- اليوزر
                    local ULabel = Instance.new("TextLabel", PItem)
                    ULabel.Size = UDim2.new(1, -45, 0, 20); ULabel.Position = UDim2.new(0, 40, 0, 18)
                    ULabel.Text = "@" .. p.Name; ULabel.TextColor3 = Color3.fromRGB(170, 170, 170)
                    ULabel.BackgroundTransparency = 1; ULabel.TextXAlignment = Enum.TextXAlignment.Left; ULabel.Font = Enum.Font.Gotham; ULabel.TextSize = 10

                    local SelectBtn = Instance.new("TextButton", PItem)
                    SelectBtn.Size = UDim2.new(1, 0, 1, 0); SelectBtn.BackgroundTransparency = 1; SelectBtn.Text = ""
                    
                    SelectBtn.MouseButton1Click:Connect(function()
                        currentSelectedUser = p.Name
                        SearchBox.Text = p.DisplayName .. " (@" .. p.Name .. ")"
                        
                        -- تحديث الألوان لكل المربعات
                        for _, v in pairs(DropList:GetChildren()) do
                            if v:IsA("Frame") then
                                v.BackgroundColor3 = (v.Name == currentSelectedUser) and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(40, 40, 40)
                            end
                        end
                        
                        task.wait(0.15)
                        isOpen = false; DropList.Visible = false
                        Container.Size = UDim2.new(0.95, 0, 0, 75)
                        DropBtn.Text = "▼ عرض قائمة اللاعبين / Show Players ▼"
                        pcall(callback, p) 
                    end)
                end
            end

            -- مسح التحديد فوراً عند الضغط على المربع لكتابة اسم جديد
            SearchBox.Focused:Connect(function()
                currentSelectedUser = nil
                for _, v in pairs(DropList:GetChildren()) do
                    if v:IsA("Frame") then v.BackgroundColor3 = Color3.fromRGB(40, 40, 40) end
                end
                pcall(callback, nil) -- إلغاء التحديد برمجياً عشان توقف الميزات القديمة
            end)

            -- عند كتابة اليوزر يدوياً وإغلاق الكيبورد
            SearchBox.FocusLost:Connect(function()
                local txt = SearchBox.Text
                if txt == "" then 
                    currentSelectedUser = nil
                    for _, v in pairs(DropList:GetChildren()) do
                        if v:IsA("Frame") then v.BackgroundColor3 = Color3.fromRGB(40, 40, 40) end
                    end
                    pcall(callback, nil)
                    return
                end

                -- بحث ذكي عن اللاعب
                local bestMatch = nil
                local search = txt:lower()
                for _, p in pairs(game:GetService("Players"):GetPlayers()) do
                    if p ~= game:GetService("Players").LocalPlayer and string.sub(p.Name:lower(), 1, #search) == search then
                        bestMatch = p
                        break 
                    end
                end

                if bestMatch then
                    currentSelectedUser = bestMatch.Name
                    -- إكمال الاسم تلقائياً في المستطيل الأول
                    SearchBox.Text = bestMatch.DisplayName .. " (@" .. bestMatch.Name .. ")"
                    
                    -- تلوين المربع الأخضر في القائمة (حتى لو كانت مقفلة)
                    for _, v in pairs(DropList:GetChildren()) do
                        if v:IsA("Frame") then
                            v.BackgroundColor3 = (v.Name == currentSelectedUser) and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(40, 40, 40)
                        end
                    end
                    
                    pcall(callback, bestMatch)
                else
                    -- في حال كتب اسم غلط
                    currentSelectedUser = nil
                    for _, v in pairs(DropList:GetChildren()) do
                        if v:IsA("Frame") then v.BackgroundColor3 = Color3.fromRGB(40, 40, 40) end
                    end
                    pcall(callback, txt) -- إرسال النص عشان السكربت يطبع "اللاعب غير موجود"
                end
            end)

            return { 
                SetText = function(t) SearchBox.Text = t end, 
                UpdateList = UpdateList, 
                Clear = function() 
                    SearchBox.Text = "" 
                    currentSelectedUser = nil 
                    for _, v in pairs(DropList:GetChildren()) do
                        if v:IsA("Frame") then v.BackgroundColor3 = Color3.fromRGB(40, 40, 40) end
                    end
                end 
            }
        end


        function TabOps:AddDropdown(label, options, callback)
            orderIndex = orderIndex + 1; local isOpen = false; local DropdownFrame = Instance.new("Frame", Page); DropdownFrame.LayoutOrder = orderIndex; DropdownFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25); DropdownFrame.ClipsDescendants = true; DropdownFrame.Size = UDim2.new(0.95, 0, 0, 40); Instance.new("UICorner", DropdownFrame); local MainBtn = Instance.new("TextButton", DropdownFrame); MainBtn.Size = UDim2.new(1, 0, 0, 40); MainBtn.BackgroundTransparency = 1; MainBtn.Text = ""; local TitleLbl = Instance.new("TextLabel", MainBtn); TitleLbl.Size = UDim2.new(1, -15, 1, 0); TitleLbl.Position = UDim2.new(0, -10, 0, 0); TitleLbl.BackgroundTransparency = 1; TitleLbl.Text = label .. " : [اختر]"; TitleLbl.TextColor3 = Color3.fromRGB(0, 255, 150); TitleLbl.TextXAlignment = Enum.TextXAlignment.Right; local ArrowLbl = Instance.new("TextLabel", MainBtn); ArrowLbl.Size = UDim2.new(0, 30, 1, 0); ArrowLbl.Position = UDim2.new(0, 5, 0, 0); ArrowLbl.BackgroundTransparency = 1; ArrowLbl.Text = "▼"; ArrowLbl.TextColor3 = Color3.new(1, 1, 1); local OptionsContainer = Instance.new("ScrollingFrame", DropdownFrame); OptionsContainer.Size = UDim2.new(1, 0, 1, -40); OptionsContainer.Position = UDim2.new(0, 0, 0, 40); OptionsContainer.BackgroundTransparency = 1; OptionsContainer.ScrollBarThickness = 2; local OptLayout = Instance.new("UIListLayout", OptionsContainer); OptLayout.SortOrder = Enum.SortOrder.LayoutOrder; OptLayout.Padding = UDim.new(0, 2)
            local function RefreshSize() if isOpen then local h = math.clamp(OptLayout.AbsoluteContentSize.Y + 40, 40, 150); DropdownFrame.Size = UDim2.new(0.95, 0, 0, h); OptionsContainer.CanvasSize = UDim2.new(0, 0, 0, OptLayout.AbsoluteContentSize.Y) else DropdownFrame.Size = UDim2.new(0.95, 0, 0, 40) end end
            MainBtn.MouseButton1Click:Connect(function() isOpen = not isOpen; ArrowLbl.Text = isOpen and "▲" or "▼"; RefreshSize() end)
            for i, opt in ipairs(options) do local OptBtn = Instance.new("TextButton", OptionsContainer); OptBtn.Size = UDim2.new(1, 0, 0, 30); OptBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35); OptBtn.Text = tostring(opt); OptBtn.TextColor3 = Color3.new(1, 1, 1); OptBtn.BorderSizePixel = 0; OptBtn.MouseButton1Click:Connect(function() TitleLbl.Text = label .. " : " .. tostring(opt); isOpen = false; ArrowLbl.Text = "▼"; RefreshSize(); LogAction("🔽 اختيار من القائمة", label, tostring(opt), 15105570); pcall(callback, opt) end) end
            return { Refresh = function(newOptions) for _, v in pairs(OptionsContainer:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end; for i, opt in ipairs(newOptions) do local OptBtn = Instance.new("TextButton", OptionsContainer); OptBtn.Size = UDim2.new(1, 0, 0, 30); OptBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35); OptBtn.Text = tostring(opt); OptBtn.TextColor3 = Color3.new(1, 1, 1); OptBtn.BorderSizePixel = 0; OptBtn.MouseButton1Click:Connect(function() TitleLbl.Text = label .. " : " .. tostring(opt); isOpen = false; ArrowLbl.Text = "▼"; RefreshSize(); LogAction("🔽 اختيار من القائمة", label, tostring(opt), 15105570); pcall(callback, opt) end) end; if isOpen then RefreshSize() end end }
        end

        return TabOps
    end
    return Window
end

return UI
