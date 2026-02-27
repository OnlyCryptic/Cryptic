-- [[ Cryptic Hub - محرك الواجهة المطور V3.3 ]]
-- المطور: Arwa | إصلاح الترتيب (LayoutOrder) والتفاف النصوص الطويلة

local UI = { Logger = nil } 
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

function UI:CreateWindow(title)
    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "ArwaHub_V3_3"
    Screen.ResetOnSpawn = false

    local OpenBtn = Instance.new("TextButton", Screen)
    OpenBtn.Size = UDim2.new(0, 45, 0, 45); OpenBtn.Position = UDim2.new(0, 10, 0.5, -22)
    OpenBtn.Visible = false; OpenBtn.Text = "C"; OpenBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
    OpenBtn.TextColor3 = Color3.fromRGB(15, 15, 15); OpenBtn.Font = Enum.Font.SourceSansBold; OpenBtn.TextSize = 24
    Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)

    local dragC, dragStartC, startPosC
    OpenBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch then dragC = true; dragStartC = i.Position; startPosC = OpenBtn.Position end end)
    UserInputService.InputChanged:Connect(function(i) if dragC and i.UserInputType == Enum.UserInputType.Touch then local d = i.Position - dragStartC; OpenBtn.Position = UDim2.new(startPosC.X.Scale, startPosC.X.Offset + d.X, startPosC.Y.Scale, startPosC.Y.Offset + d.Y) end end)
    OpenBtn.InputEnded:Connect(function() dragC = false end)

    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 440, 0, 280); Main.Position = UDim2.new(0.5, 0, 0.5, 0); Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Main.Active = true; Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

    local TitleBar = Instance.new("Frame", Main)
    TitleBar.Size = UDim2.new(1, 0, 0, 35); TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", TitleBar)
    local TitleLabel = Instance.new("TextLabel", TitleBar)
    TitleLabel.Text = title; TitleLabel.Size = UDim2.new(1, -120, 1, 0); TitleLabel.Position = UDim2.new(0, 10, 0, 0); TitleLabel.BackgroundTransparency = 1; TitleLabel.TextColor3 = Color3.new(1, 1, 1); TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local Close = Instance.new("TextButton", TitleBar); Close.Text = "X"; Close.Position = UDim2.new(1, -35, 0, 5); Close.Size = UDim2.new(0, 25, 0, 25); Close.TextColor3 = Color3.new(1, 0, 0); Close.BackgroundTransparency = 1; Close.MouseButton1Click:Connect(function() Screen:Destroy() end)
    local Hide = Instance.new("TextButton", TitleBar); Hide.Text = "-"; Hide.Position = UDim2.new(1, -70, 0, 5); Hide.Size = UDim2.new(0, 25, 0, 25); Hide.TextColor3 = Color3.new(1, 1, 1); Hide.BackgroundTransparency = 1; Hide.MouseButton1Click:Connect(function() Main.Visible = false; OpenBtn.Visible = true end); OpenBtn.MouseButton1Click:Connect(function() Main.Visible = true; OpenBtn.Visible = false end)

    local dragM, dragStartM, startPosM
    TitleBar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch then dragM = true; dragStartM = i.Position; startPosM = Main.Position end end)
    UserInputService.InputChanged:Connect(function(i) if dragM and i.UserInputType == Enum.UserInputType.Touch then local d = i.Position - dragStartM; Main.Position = UDim2.new(startPosM.X.Scale, startPosM.X.Offset + d.X, startPosM.Y.Scale, startPosM.Y.Offset + d.Y) end end)
    UserInputService.InputEnded:Connect(function() dragM = false end)

    local Sidebar = Instance.new("Frame", Main)
    Sidebar.Position = UDim2.new(0, 0, 0, 35); Sidebar.Size = UDim2.new(0, 110, 1, -35); Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 20); Instance.new("UIListLayout", Sidebar).Padding = UDim.new(0, 2)
    local Content = Instance.new("Frame", Main)
    Content.Position = UDim2.new(0, 115, 0, 40); Content.Size = UDim2.new(1, -120, 1, -45); Content.BackgroundTransparency = 1

    local Window = { FirstTab = nil }

    function Window:CreateTab(name)
        local TabBtn = Instance.new("TextButton", Sidebar); TabBtn.Size = UDim2.new(1, 0, 0, 35); TabBtn.Text = name; TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); TabBtn.TextColor3 = Color3.new(1, 1, 1); TabBtn.BorderSizePixel = 0
        
        local Page = Instance.new("ScrollingFrame", Content); Page.Size = UDim2.new(1, 0, 1, 0); Page.Visible = false; Page.BackgroundTransparency = 1; Page.ScrollBarThickness = 2
        -- التمدد التلقائي للصفحة لتجنب تقطيع العناصر
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        
        local ListLayout = Instance.new("UIListLayout", Page)
        ListLayout.Padding = UDim.new(0, 8)
        ListLayout.SortOrder = Enum.SortOrder.LayoutOrder -- إجبار الترتيب بالرقم

        if not Window.FirstTab then Window.FirstTab = Page; Page.Visible = true end
        TabBtn.MouseButton1Click:Connect(function() for _, v in pairs(Content:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end; Page.Visible = true end)

        local TabOps = {}
        local orderIndex = 0 -- عداد الترتيب لضمان مكان كل أداة

        function TabOps:AddLine()
            orderIndex = orderIndex + 1
            local L = Instance.new("Frame", Page)
            L.LayoutOrder = orderIndex
            L.Size = UDim2.new(0.95, 0, 0, 1); L.BackgroundColor3 = Color3.fromRGB(50, 50, 50); L.BackgroundTransparency = 0.5; L.BorderSizePixel = 0
        end

        function TabOps:AddSpeedControl(label, callback)
            orderIndex = orderIndex + 1
            local Row = Instance.new("Frame", Page)
            Row.LayoutOrder = orderIndex
            Row.Size = UDim2.new(0.98, 0, 0, 45); Row.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", Row)
            local Lbl = Instance.new("TextLabel", Row); Lbl.Text = label; Lbl.Size = UDim2.new(0.6, 0, 1, 0); Lbl.Position = UDim2.new(0.05, 0, 0, 0); Lbl.TextColor3 = Color3.new(1, 1, 1); Lbl.BackgroundTransparency = 1; Lbl.TextXAlignment = Enum.TextXAlignment.Right
            local Tgl = Instance.new("TextButton", Row); Tgl.Size = UDim2.new(0, 45, 0, 22); Tgl.Position = UDim2.new(1, -55, 0.5, -11); Tgl.Text = ""; Tgl.BackgroundColor3 = Color3.fromRGB(60, 60, 60); Instance.new("UICorner", Tgl).CornerRadius = UDim.new(1, 0)
            local Inp = Instance.new("TextBox", Row); Inp.Size = UDim2.new(0, 40, 0, 22); Inp.Position = UDim2.new(1, -105, 0.5, -11); Inp.Text = "50"; Inp.BackgroundColor3 = Color3.fromRGB(40, 40, 40); Inp.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", Inp)
            local active = false
            local function update() Tgl.BackgroundColor3 = active and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(60, 60, 60); callback(active, tonumber(Inp.Text) or 50) end
            Tgl.MouseButton1Click:Connect(function() active = not active; update() end)
            Inp:GetPropertyChangedSignal("Text"):Connect(function() if active then update() end end)
        end

        function TabOps:AddToggle(label, callback)
            orderIndex = orderIndex + 1
            local R = Instance.new("Frame", Page)
            R.LayoutOrder = orderIndex
            R.Size = UDim2.new(0.98, 0, 0, 45); R.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", R)
            local Lbl = Instance.new("TextLabel", R); Lbl.Text = label; Lbl.Size = UDim2.new(0.7, 0, 1, 0); Lbl.Position = UDim2.new(0.05, 0, 0, 0); Lbl.TextColor3 = Color3.new(1, 1, 1); Lbl.BackgroundTransparency = 1; Lbl.TextXAlignment = Enum.TextXAlignment.Right
            local B = Instance.new("TextButton", R); B.Size = UDim2.new(0, 45, 0, 22); B.Position = UDim2.new(1, -55, 0.5, -11); B.Text = ""; B.BackgroundColor3 = Color3.fromRGB(60, 60, 60); Instance.new("UICorner", B).CornerRadius = UDim.new(1, 0)
            local a = false; B.MouseButton1Click:Connect(function() a = not a; B.BackgroundColor3 = a and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(60, 60, 60); callback(a) end)
            return { SetState = function(s) a = s; B.BackgroundColor3 = s and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(60, 60, 60) end }
        end

        function TabOps:AddInput(label, placeholder, callback)
            orderIndex = orderIndex + 1
            local R = Instance.new("Frame", Page)
            R.LayoutOrder = orderIndex
            R.Size = UDim2.new(0.95, 0, 0, 60); R.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", R)
            local Lbl = Instance.new("TextLabel", R); Lbl.Text = label; Lbl.Size = UDim2.new(1, -10, 0, 25); Lbl.TextColor3 = Color3.fromRGB(0, 255, 150); Lbl.BackgroundTransparency = 1; Lbl.TextXAlignment = Enum.TextXAlignment.Right
            local I = Instance.new("TextBox", R); I.Size = UDim2.new(0.9, 0, 0, 25); I.Position = UDim2.new(0.05, 0, 0, 30); I.PlaceholderText = placeholder; I.BackgroundColor3 = Color3.fromRGB(40, 40, 40); I.TextColor3 = Color3.new(1, 1, 1); I.Text = ""; Instance.new("UICorner", I)
            local ig = false; I:GetPropertyChangedSignal("Text"):Connect(function() if not ig then callback(I.Text) end end)
            I.Focused:Connect(function() ig = true; I.Text = ""; ig = false; callback("") end)
            return { SetText = function(t) ig = true; I.Text = t; ig = false end, TextBox = I }
        end

        function TabOps:AddButton(t, c) 
            orderIndex = orderIndex + 1
            local B = Instance.new("TextButton", Page)
            B.LayoutOrder = orderIndex
            B.Size = UDim2.new(0.95, 0, 0, 40); B.BackgroundColor3 = Color3.fromRGB(30, 30, 30); B.Text = t; B.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", B); B.MouseButton1Click:Connect(function() c() end) 
        end

        function TabOps:AddLabel(t) 
            orderIndex = orderIndex + 1
            local R = Instance.new("Frame", Page)
            R.LayoutOrder = orderIndex
            R.Size = UDim2.new(0.98,0,0,35); R.BackgroundColor3 = Color3.fromRGB(25,25,25); Instance.new("UICorner",R); local L = Instance.new("TextLabel",R); L.Text = t; L.Size = UDim2.new(1,-10,1,0); L.TextColor3 = Color3.fromRGB(0,255,150); L.BackgroundTransparency = 1; L.TextXAlignment = Enum.TextXAlignment.Right; return {SetText=function(nt) L.Text=nt end} 
        end

        -- إصلاح مشكلة النص المقطوع والترتيب العشوائي للملاحظات
        function TabOps:AddParagraph(text)
            orderIndex = orderIndex + 1
            local Lbl = Instance.new("TextLabel", Page)
            Lbl.LayoutOrder = orderIndex
            -- استخدام الحجم التلقائي للارتفاع
            Lbl.Size = UDim2.new(0.95, 0, 0, 0)
            Lbl.AutomaticSize = Enum.AutomaticSize.Y
            Lbl.TextWrapped = true -- هذا يجعل النص ينزل لسطر جديد إذا كان طويلاً
            Lbl.Text = text
            Lbl.TextColor3 = Color3.fromRGB(170, 170, 170)
            Lbl.BackgroundTransparency = 1
            Lbl.TextXAlignment = Enum.TextXAlignment.Right
            Lbl.TextYAlignment = Enum.TextYAlignment.Top
            Lbl.TextSize = 13
        end

        return TabOps
    end
    return Window
end

function UI:Notify(msg) warn("[Cryptic Hub]: " .. msg) end
return UI
