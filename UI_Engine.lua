-- [[ Cryptic Hub - محرك الواجهة المطور V5.8 ]]
-- المطور: يامي (Yami) | التحديث: نظام سحب سلس جداً للنافذة الرئيسية وزر الفتح + إصلاحات القوائم

local UI = { Logger = nil } 
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

function UI:CreateWindow(title)
    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "CrypticHub_V5"; Screen.ResetOnSpawn = false

    -- [[ 1. زر الفتح الأنيق ]]
    local OpenBtn = Instance.new("TextButton", Screen)
    OpenBtn.Size = UDim2.new(0, 85, 0, 35); OpenBtn.Position = UDim2.new(0, 10, 0.5, -17)
    OpenBtn.Visible = false; OpenBtn.Text = "Cryptic"; OpenBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
    OpenBtn.TextColor3 = Color3.fromRGB(15, 15, 15); OpenBtn.Font = Enum.Font.GothamBold; OpenBtn.TextSize = 14
    Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)
    
    local OpenStroke = Instance.new("UIStroke", OpenBtn)
    OpenStroke.Color = Color3.fromRGB(255, 255, 255)
    OpenStroke.Thickness = 2
    OpenStroke.Transparency = 0.5

    -- [[ نظام السحب السلس لزر الفتح ]]
    local dragToggle, dragInputT, dragStartT, startPosT
    OpenBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragToggle = true; dragStartT = input.Position; startPosT = OpenBtn.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragToggle = false end end)
        end
    end)
    OpenBtn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInputT = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInputT and dragToggle then
            local delta = input.Position - dragStartT
            OpenBtn.Position = UDim2.new(startPosT.X.Scale, startPosT.X.Offset + delta.X, startPosT.Y.Scale, startPosT.Y.Offset + delta.Y)
        end
    end)

    -- [[ 2. النافذة الرئيسية ]]
    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 440, 0, 280); Main.Position = UDim2.new(0.5, 0, 0.5, 0); Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Main.Active = true
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
    Main.ClipsDescendants = true 

    -- الشريط العلوي
    local TitleBar = Instance.new("Frame", Main)
    TitleBar.Size = UDim2.new(1, 0, 0, 35); TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", TitleBar)
    local TitleLabel = Instance.new("TextLabel", TitleBar)
    TitleLabel.Text = title; TitleLabel.Size = UDim2.new(1, -120, 1, 0); TitleLabel.Position = UDim2.new(0, 10, 0, 0); TitleLabel.BackgroundTransparency = 1; TitleLabel.TextColor3 = Color3.new(1, 1, 1); TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- [[ نظام السحب السلس للنافذة الرئيسية (من الشريط العلوي) ]]
    local draggingMain, dragInputMain, dragStartMain, startPosMain
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingMain = true; dragStartMain = input.Position; startPosMain = Main.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then draggingMain = false end end)
        end
    end)
    TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInputMain = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInputMain and draggingMain then
            local delta = input.Position - dragStartMain
            Main.Position = UDim2.new(startPosMain.X.Scale, startPosMain.X.Offset + delta.X, startPosMain.Y.Scale, startPosMain.Y.Offset + delta.Y)
        end
    end)

    -- أزرار الإغلاق والإخفاء
    local Close = Instance.new("TextButton", TitleBar); Close.Text = "X"; Close.Position = UDim2.new(1, -35, 0, 5); Close.Size = UDim2.new(0, 25, 0, 25); Close.TextColor3 = Color3.new(1, 0, 0); Close.BackgroundTransparency = 1; Close.MouseButton1Click:Connect(function() Screen:Destroy() end)
    local Hide = Instance.new("TextButton", TitleBar); Hide.Text = "-"; Hide.Position = UDim2.new(1, -70, 0, 5); Hide.Size = UDim2.new(0, 25, 0, 25); Hide.TextColor3 = Color3.new(1, 1, 1); Hide.BackgroundTransparency = 1; Hide.MouseButton1Click:Connect(function() Main.Visible = false; OpenBtn.Visible = true end); OpenBtn.MouseButton1Click:Connect(function() Main.Visible = true; OpenBtn.Visible = false end)

    -- [[ 3. القائمة الجانبية (بدون قلتش السحب اللانهائي) ]]
    local Sidebar = Instance.new("ScrollingFrame", Main)
    Sidebar.Position = UDim2.new(0, 0, 0, 35); Sidebar.Size = UDim2.new(0, 110, 1, -35); Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 20); Sidebar.BorderSizePixel = 0; Sidebar.ScrollBarThickness = 2
    Sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
    local SidebarLayout = Instance.new("UIListLayout", Sidebar); SidebarLayout.Padding = UDim.new(0, 2)
    
    SidebarLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Sidebar.CanvasSize = UDim2.new(0, 0, 0, SidebarLayout.AbsoluteContentSize.Y + 5)
    end)

    local Content = Instance.new("Frame", Main)
    Content.Position = UDim2.new(0, 115, 0, 40); Content.Size = UDim2.new(1, -120, 1, -45); Content.BackgroundTransparency = 1

    local Window = { FirstTab = nil }

    function Window:CreateTab(name)
        local TabBtn = Instance.new("TextButton", Sidebar); TabBtn.Size = UDim2.new(1, 0, 0, 35); TabBtn.Text = name; TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); TabBtn.TextColor3 = Color3.new(1, 1, 1); TabBtn.BorderSizePixel = 0
        
        -- [[ 4. قائمة المحتوى (بدون قلتش السحب اللانهائي) ]]
        local Page = Instance.new("ScrollingFrame", Content); Page.Size = UDim2.new(1, 0, 1, 0); Page.Visible = false; Page.BackgroundTransparency = 1; Page.ScrollBarThickness = 2
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        local ListLayout = Instance.new("UIListLayout", Page); ListLayout.Padding = UDim.new(0, 8); ListLayout.SortOrder = Enum.SortOrder.LayoutOrder 
        
        ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 15)
        end)

        if not Window.FirstTab then Window.FirstTab = Page; Page.Visible = true end
        TabBtn.MouseButton1Click:Connect(function() 
            for _, v in pairs(Content:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
            Page.Visible = true 
        end)

        local TabOps = {}
        local orderIndex = 0 

        function TabOps:AddProfileCard(player)
            orderIndex = orderIndex + 1
            local R = Instance.new("Frame", Page)
            R.LayoutOrder = orderIndex; R.Size = UDim2.new(0.98, 0, 0, 75); R.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            Instance.new("UICorner", R).CornerRadius = UDim.new(0, 8)
            
            local Avatar = Instance.new("ImageLabel", R)
            Avatar.Size = UDim2.new(0, 55, 0, 55); Avatar.Position = UDim2.new(1, -65, 0, 10)
            Avatar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            Instance.new("UICorner", Avatar).CornerRadius = UDim.new(1, 0)
            
            task.spawn(function()
                local s, thumb = pcall(function() return game:GetService("Players"):GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420) end)
                if s and thumb then Avatar.Image = thumb end
            end)

            local NameLbl = Instance.new("TextLabel", R)
            NameLbl.Size = UDim2.new(1, -80, 0, 25); NameLbl.Position = UDim2.new(0, 10, 0, 12)
            NameLbl.BackgroundTransparency = 1; NameLbl.Text = "أهلاً بك، " .. player.DisplayName
            NameLbl.TextColor3 = Color3.fromRGB(0, 255, 150); NameLbl.TextXAlignment = Enum.TextXAlignment.Right
            NameLbl.Font = Enum.Font.GothamBold; NameLbl.TextSize = 16
            
            local UserLbl = Instance.new("TextLabel", R)
            UserLbl.Size = UDim2.new(1, -80, 0, 20); UserLbl.Position = UDim2.new(0, 10, 0, 37)
            UserLbl.BackgroundTransparency = 1; UserLbl.Text = "@" .. player.Name
            UserLbl.TextColor3 = Color3.fromRGB(170, 170, 170); UserLbl.TextXAlignment = Enum.TextXAlignment.Right
            UserLbl.Font = Enum.Font.Gotham; UserLbl.TextSize = 13
        end

        function TabOps:AddLine()
            orderIndex = orderIndex + 1; local L = Instance.new("Frame", Page); L.LayoutOrder = orderIndex; L.Size = UDim2.new(0.95, 0, 0, 1); L.BackgroundColor3 = Color3.fromRGB(50, 50, 50); L.BackgroundTransparency = 0.5; L.BorderSizePixel = 0
        end

        function TabOps:AddLabel(t) 
            orderIndex = orderIndex + 1; local R = Instance.new("Frame", Page); R.LayoutOrder = orderIndex; R.Size = UDim2.new(0.98,0,0,35); R.BackgroundColor3 = Color3.fromRGB(25,25,25); Instance.new("UICorner",R); local L = Instance.new("TextLabel",R); L.Text = t; L.Size = UDim2.new(1,-10,1,0); L.TextColor3 = Color3.fromRGB(0, 255, 150); L.BackgroundTransparency = 1; L.TextXAlignment = Enum.TextXAlignment.Right; return {SetText=function(nt) L.Text=nt end} 
        end

        function TabOps:AddParagraph(text)
            orderIndex = orderIndex + 1; local Lbl = Instance.new("TextLabel", Page); Lbl.LayoutOrder = orderIndex; Lbl.Size = UDim2.new(0.95, 0, 0, 0); Lbl.AutomaticSize = Enum.AutomaticSize.Y; Lbl.TextWrapped = true; Lbl.Text = text; Lbl.TextColor3 = Color3.fromRGB(170, 170, 170); Lbl.BackgroundTransparency = 1; Lbl.TextXAlignment = Enum.TextXAlignment.Right; Lbl.TextSize = 13
        end

        function TabOps:AddInput(label, placeholder, callback)
            orderIndex = orderIndex + 1; local R = Instance.new("Frame", Page); R.LayoutOrder = orderIndex; R.Size = UDim2.new(0.95, 0, 0, 60); R.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", R); local Lbl = Instance.new("TextLabel", R); Lbl.Text = label; Lbl.Size = UDim2.new(1, -10, 0, 25); Lbl.TextColor3 = Color3.fromRGB(0, 255, 150); Lbl.BackgroundTransparency = 1; Lbl.TextXAlignment = Enum.TextXAlignment.Right; local I = Instance.new("TextBox", R); I.Size = UDim2.new(0.9, 0, 0, 25); I.Position = UDim2.new(0.05, 0, 0, 30); I.PlaceholderText = placeholder; I.BackgroundColor3 = Color3.fromRGB(40, 40, 40); I.TextColor3 = Color3.new(1, 1, 1); I.Text = ""; Instance.new("UICorner", I); I:GetPropertyChangedSignal("Text"):Connect(function() callback(I.Text) end); return { SetText = function(t) I.Text = t end, TextBox = I }
        end

        function TabOps:AddSpeedControl(label, callback, default)
            orderIndex = orderIndex + 1; local Row = Instance.new("Frame", Page); Row.LayoutOrder = orderIndex; Row.Size = UDim2.new(0.98, 0, 0, 45); Row.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", Row); local Lbl = Instance.new("TextLabel", Row); Lbl.Text = label; Lbl.Size = UDim2.new(0.6, 0, 1, 0); Lbl.Position = UDim2.new(0.05, 0, 0, 0); Lbl.TextColor3 = Color3.new(1, 1, 1); Lbl.BackgroundTransparency = 1; Lbl.TextXAlignment = Enum.TextXAlignment.Right; local Tgl = Instance.new("TextButton", Row); Tgl.Size = UDim2.new(0, 45, 0, 22); Tgl.Position = UDim2.new(1, -55, 0.5, -11); Tgl.Text = ""; Tgl.BackgroundColor3 = Color3.fromRGB(60, 60, 60); Instance.new("UICorner", Tgl).CornerRadius = UDim.new(1, 0); local startVal = tostring(default or 50); local Inp = Instance.new("TextBox", Row); Inp.Size = UDim2.new(0, 40, 0, 22); Inp.Position = UDim2.new(1, -105, 0.5, -11); Inp.Text = startVal; Inp.BackgroundColor3 = Color3.fromRGB(40, 40, 40); Inp.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", Inp); local active = false; local function update() Tgl.BackgroundColor3 = active and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(60, 60, 60); callback(active, tonumber(Inp.Text) or tonumber(startVal)) end; Tgl.MouseButton1Click:Connect(function() active = not active; update() end); Inp:GetPropertyChangedSignal("Text"):Connect(function() if active then update() end end)
        end

        function TabOps:AddButton(t, c) 
            orderIndex = orderIndex + 1; local B = Instance.new("TextButton", Page); B.LayoutOrder = orderIndex; B.Size = UDim2.new(0.95, 0, 0, 40); B.BackgroundColor3 = Color3.fromRGB(30, 30, 30); B.Text = t; B.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", B); B.MouseButton1Click:Connect(c) 
        end

        function TabOps:AddToggle(label, callback)
            orderIndex = orderIndex + 1; local R = Instance.new("Frame", Page); R.LayoutOrder = orderIndex; R.Size = UDim2.new(0.98, 0, 0, 45); R.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", R); local B = Instance.new("TextButton", R); B.Size = UDim2.new(0, 45, 0, 22); B.Position = UDim2.new(1, -55, 0.5, -11); B.Text = ""; B.BackgroundColor3 = Color3.fromRGB(60, 60, 60); Instance.new("UICorner", B).CornerRadius = UDim.new(1, 0); local Lbl = Instance.new("TextLabel", R); Lbl.Text = label; Lbl.Size = UDim2.new(0.7, 0, 1, 0); Lbl.Position = UDim2.new(0.05, 0, 0, 0); Lbl.TextColor3 = Color3.new(1, 1, 1); Lbl.BackgroundTransparency = 1; Lbl.TextXAlignment = Enum.TextXAlignment.Right; local a = false; local function set(s) a = s; B.BackgroundColor3 = a and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(60, 60, 60) end; B.MouseButton1Click:Connect(function() set(not a); callback(a) end); return { SetState = function(self, s) set(s) end, Set = function(self, s) set(s) end }
        end

        function TabOps:AddTimedToggle(label, callback)
            orderIndex = orderIndex + 1; local R = Instance.new("Frame", Page); R.LayoutOrder = orderIndex; R.Size = UDim2.new(0.98, 0, 0, 45); R.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", R); local B = Instance.new("TextButton", R); B.Size = UDim2.new(0, 45, 0, 22); B.Position = UDim2.new(1, -55, 0.5, -11); B.Text = ""; B.BackgroundColor3 = Color3.fromRGB(60, 60, 60); Instance.new("UICorner", B).CornerRadius = UDim.new(1, 0); local Lbl = Instance.new("TextLabel", R); Lbl.Text = label; Lbl.Size = UDim2.new(0.7, 0, 1, 0); Lbl.Position = UDim2.new(0.05, 0, 0, 0); Lbl.TextColor3 = Color3.new(1, 1, 1); Lbl.BackgroundTransparency = 1; Lbl.TextXAlignment = Enum.TextXAlignment.Right; local isRunning = false
            B.MouseButton1Click:Connect(function() 
                if isRunning then return end; isRunning = true; B.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
                task.spawn(function() pcall(callback, true); task.wait(2); if B then B.BackgroundColor3 = Color3.fromRGB(60, 60, 60) end; pcall(callback, false); isRunning = false end)
            end)
            return { Set = function() end, SetState = function() end }
        end

        return TabOps
    end
    return Window
end
return UI
