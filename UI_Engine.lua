-- [[ Cryptic Hub - محرك الواجهة المطور V3.1 ]]
-- المطور: Arwa | التحديث: استعادة النصوص وإصلاح تصميم الأزرار

local UI = { Logger = nil } 
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

function UI:CreateWindow(title)
    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "ArwaHub_V3_1"
    Screen.ResetOnSpawn = false

    -- زر C العائم
    local OpenBtn = Instance.new("TextButton", Screen)
    OpenBtn.Size = UDim2.new(0, 45, 0, 45)
    OpenBtn.Position = UDim2.new(0, 10, 0.5, -22)
    OpenBtn.Visible = false
    OpenBtn.Text = "C"
    OpenBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
    OpenBtn.TextColor3 = Color3.fromRGB(15, 15, 15)
    OpenBtn.Font = Enum.Font.SourceSansBold
    OpenBtn.TextSize = 24
    Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)

    -- سحب الزر العائم
    local dragC, dragStartC, startPosC
    OpenBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragC = true; dragStartC = input.Position; startPosC = OpenBtn.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragC and input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStartC
            OpenBtn.Position = UDim2.new(startPosC.X.Scale, startPosC.X.Offset + delta.X, startPosC.Y.Scale, startPosC.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function() dragC = false end)

    -- الإطار الرئيسي
    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 440, 0, 280)
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Main.Active = true
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

    local TitleBar = Instance.new("Frame", Main)
    TitleBar.Size = UDim2.new(1, 0, 0, 35)
    TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Instance.new("UICorner", TitleBar)

    local TitleLabel = Instance.new("TextLabel", TitleBar)
    TitleLabel.Text = title
    TitleLabel.Size = UDim2.new(1, -120, 1, 0)
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.TextColor3 = Color3.new(1, 1, 1)
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- أزرار التحكم
    local Close = Instance.new("TextButton", TitleBar)
    Close.Text = "X"; Close.Position = UDim2.new(1, -35, 0, 5); Close.Size = UDim2.new(0, 25, 0, 25); Close.TextColor3 = Color3.new(1, 0, 0); Close.BackgroundTransparency = 1
    Close.MouseButton1Click:Connect(function() Screen:Destroy() end)

    local Hide = Instance.new("TextButton", TitleBar)
    Hide.Text = "-"; Hide.Position = UDim2.new(1, -70, 0, 5); Hide.Size = UDim2.new(0, 25, 0, 25); Hide.TextColor3 = Color3.new(1, 1, 1); Hide.BackgroundTransparency = 1
    Hide.MouseButton1Click:Connect(function() Main.Visible = false; OpenBtn.Visible = true end)
    OpenBtn.MouseButton1Click:Connect(function() Main.Visible = true; OpenBtn.Visible = false end)

    -- سحب الواجهة
    local dragM, dragStartM, startPosM
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragM = true; dragStartM = input.Position; startPosM = Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragM and input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStartM
            Main.Position = UDim2.new(startPosM.X.Scale, startPosM.X.Offset + delta.X, startPosM.Y.Scale, startPosM.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function() dragM = false end)

    local Sidebar = Instance.new("Frame", Main)
    Sidebar.Position = UDim2.new(0, 0, 0, 35)
    Sidebar.Size = UDim2.new(0, 110, 1, -35)
    Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Instance.new("UIListLayout", Sidebar).Padding = UDim.new(0, 2)

    local Content = Instance.new("Frame", Main)
    Content.Position = UDim2.new(0, 115, 0, 40)
    Content.Size = UDim2.new(1, -120, 1, -45)
    Content.BackgroundTransparency = 1

    local Window = { FirstTab = nil }

    function Window:CreateTab(name)
        local TabBtn = Instance.new("TextButton", Sidebar)
        TabBtn.Size = UDim2.new(1, 0, 0, 35)
        TabBtn.Text = name
        TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        TabBtn.TextColor3 = Color3.new(1, 1, 1)
        TabBtn.BorderSizePixel = 0

        local Page = Instance.new("ScrollingFrame", Content)
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.Visible = false
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 2
        Instance.new("UIListLayout", Page).Padding = UDim.new(0, 8)

        if not Window.FirstTab then Window.FirstTab = Page; Page.Visible = true end
        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(Content:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
            Page.Visible = true
        end)

        local TabOps = {}

        -- وظيفة الخط الفاصل
        function TabOps:AddLine()
            local Line = Instance.new("Frame", Page)
            Line.Size = UDim2.new(0.95, 0, 0, 1)
            Line.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            Line.BackgroundTransparency = 0.5
            Line.BorderSizePixel = 0
        end

        -- وظيفة التحكم في السرعة (مصلحة بالكامل)
        function TabOps:AddSpeedControl(label, callback)
            local Row = Instance.new("Frame", Page)
            Row.Size = UDim2.new(0.98, 0, 0, 50)
            Row.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            Instance.new("UICorner", Row)

            local Lbl = Instance.new("TextLabel", Row)
            Lbl.Text = label
            Lbl.Size = UDim2.new(0.5, 0, 1, 0)
            Lbl.Position = UDim2.new(0.45, 0, 0, 0)
            Lbl.TextColor3 = Color3.new(1, 1, 1)
            Lbl.BackgroundTransparency = 1
            Lbl.TextXAlignment = Enum.TextXAlignment.Right

            local Tgl = Instance.new("TextButton", Row)
            Tgl.Size = UDim2.new(0, 45, 0, 22)
            Tgl.Position = UDim2.new(0.05, 0, 0.5, -11)
            Tgl.Text = ""
            Tgl.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            Instance.new("UICorner", Tgl).CornerRadius = UDim.new(1, 0)

            local Inp = Instance.new("TextBox", Row)
            Inp.Size = UDim2.new(0, 60, 0, 25)
            Inp.Position = UDim2.new(0.2, 0, 0.5, -12.5)
            Inp.Text = "50"
            Inp.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            Inp.TextColor3 = Color3.new(1, 1, 1)
            Instance.new("UICorner", Inp)

            local active = false
            local function update()
                Tgl.BackgroundColor3 = active and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(60, 60, 60)
                callback(active, tonumber(Inp.Text) or 50)
            end
            Tgl.MouseButton1Click:Connect(function() active = not active; update() end)
            Inp:GetPropertyChangedSignal("Text"):Connect(function() if active then update() end end)
        end

        -- وظيفة زر التبديل (مصلحة)
        function TabOps:AddToggle(label, callback)
            local Row = Instance.new("Frame", Page)
            Row.Size = UDim2.new(0.98, 0, 0, 45)
            Row.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            Instance.new("UICorner", Row)

            local Lbl = Instance.new("TextLabel", Row)
            Lbl.Text = label
            Lbl.Size = UDim2.new(0.7, 0, 1, 0)
            Lbl.Position = UDim2.new(0.05, 0, 0, 0)
            Lbl.TextColor3 = Color3.new(1, 1, 1)
            Lbl.BackgroundTransparency = 1
            Lbl.TextXAlignment = Enum.TextXAlignment.Right

            local Tgl = Instance.new("TextButton", Row)
            Tgl.Size = UDim2.new(0, 45, 0, 22)
            Tgl.Position = UDim2.new(1, -55, 0.5, -11)
            Tgl.Text = ""
            Tgl.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            Instance.new("UICorner", Tgl).CornerRadius = UDim.new(1, 0)

            local active = false
            Tgl.MouseButton1Click:Connect(function()
                active = not active
                Tgl.BackgroundColor3 = active and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(60, 60, 60)
                callback(active)
            end)
            return { SetState = function(s) active = s; Tgl.BackgroundColor3 = s and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(60, 60, 60) end }
        end

        -- وظيفة الإدخال (مصلحة)
        function TabOps:AddInput(label, placeholder, callback)
            local Row = Instance.new("Frame", Page)
            Row.Size = UDim2.new(0.95, 0, 0, 60)
            Row.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            Instance.new("UICorner", Row)

            local Lbl = Instance.new("TextLabel", Row)
            Lbl.Text = label
            Lbl.Size = UDim2.new(1, -10, 0, 25)
            Lbl.TextColor3 = Color3.fromRGB(0, 255, 150)
            Lbl.BackgroundTransparency = 1
            Lbl.TextXAlignment = Enum.TextXAlignment.Right

            local Inp = Instance.new("TextBox", Row)
            Inp.Size = UDim2.new(0.9, 0, 0, 25)
            Inp.Position = UDim2.new(0.05, 0, 0, 30)
            Inp.PlaceholderText = placeholder
            Inp.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            Inp.TextColor3 = Color3.new(1, 1, 1)
            Inp.Text = ""
            Instance.new("UICorner", Inp)

            local ignore = false
            Inp:GetPropertyChangedSignal("Text"):Connect(function() if not ignore then callback(Inp.Text) end end)
            Inp.Focused:Connect(function() ignore = true; Inp.Text = ""; ignore = false; callback("") end)

            return { SetText = function(t) ignore = true; Inp.Text = t; ignore = false end, TextBox = Inp }
        end

        function TabOps:AddButton(text, callback)
            local Btn = Instance.new("TextButton", Page)
            Btn.Size = UDim2.new(0.95, 0, 0, 40)
            Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            Btn.Text = text
            Btn.TextColor3 = Color3.new(1, 1, 1)
            Instance.new("UICorner", Btn)
            Btn.MouseButton1Click:Connect(function() callback() end)
        end

        function TabOps:AddLabel(text)
            local Row = Instance.new("Frame", Page)
            Row.Size = UDim2.new(0.98, 0, 0, 35)
            Row.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            Instance.new("UICorner", Row)
            local Lbl = Instance.new("TextLabel", Row)
            Lbl.Text = text; Lbl.Size = UDim2.new(1, -10, 1, 0); Lbl.TextColor3 = Color3.fromRGB(0, 255, 150); Lbl.BackgroundTransparency = 1; Lbl.TextXAlignment = Enum.TextXAlignment.Right
            return { SetText = function(nt) Lbl.Text = nt end }
        end

        function TabOps:AddParagraph(text)
            local Lbl = Instance.new("TextLabel", Page)
            Lbl.Size = UDim2.new(0.95, 0, 0, 25)
            Lbl.Text = text; Lbl.TextColor3 = Color3.fromRGB(150, 150, 150); Lbl.BackgroundTransparency = 1; Lbl.TextXAlignment = Enum.TextXAlignment.Right; Lbl.TextSize = 11
        end

        return TabOps
    end
    return UI
end

function UI:Notify(msg) warn("[Cryptic Hub]: " .. msg) end
return UI
