local UI = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

function UI:CreateWindow(title)
    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "CrypticMobile"
    
    -- الزر الصغير لإظهار السكربت بعد إخفائه (Restore Button)
    local OpenBtn = Instance.new("TextButton", Screen)
    OpenBtn.Size = UDim2.new(0, 50, 0, 50)
    OpenBtn.Position = UDim2.new(0, 10, 0.5, -25)
    OpenBtn.Visible = false
    OpenBtn.Text = "C"
    OpenBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
    Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)

    -- الإطار الرئيسي
    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 420, 0, 260)
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    local MainCorner = Instance.new("UICorner", Main)
    MainCorner.CornerRadius = UDim.new(0, 12)

    -- شريط السحب والتحكم العلوي (Title Bar)
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
    TitleLabel.TextXAlignment = "Left"

    -- أزرار التحكم (إغلاق، إخفاء)
    local Close = Instance.new("TextButton", TitleBar)
    Close.Text = "X"
    Close.TextColor3 = Color3.new(1, 0, 0)
    Close.Position = UDim2.new(1, -35, 0, 5)
    Close.Size = UDim2.new(0, 25, 0, 25)
    Close.BackgroundTransparency = 1

    local Hide = Instance.new("TextButton", TitleBar)
    Hide.Text = "-"
    Hide.TextColor3 = Color3.new(1, 1, 1)
    Hide.Position = UDim2.new(1, -70, 0, 5)
    Hide.Size = UDim2.new(0, 25, 0, 25)
    Hide.BackgroundTransparency = 1

    -- منطق الإخفاء والإظهار
    Hide.MouseButton1Click:Connect(function()
        Main.Visible = false
        OpenBtn.Visible = true
    end)
    OpenBtn.MouseButton1Click:Connect(function()
        Main.Visible = true
        OpenBtn.Visible = false
    end)
    Close.MouseButton1Click:Connect(function()
        Screen:Destroy()
    end)

    -- نظام السحب المخصص للهاتف (Dragging)
    local dragStart, startPos
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragStart = input.Position
            startPos = Main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragStart = nil end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragStart then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- باقي الهيكل (Sidebar و Content) كما طلبته سابقاً
    local Sidebar = Instance.new("Frame", Main)
    Sidebar.Position = UDim2.new(0, 0, 0, 35)
    Sidebar.Size = UDim2.new(0, 100, 1, -35)
    Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    local SideLayout = Instance.new("UIListLayout", Sidebar)

    local Content = Instance.new("Frame", Main)
    Content.Position = UDim2.new(0, 105, 0, 40)
    Content.Size = UDim2.new(1, -110, 1, -45)
    Content.BackgroundTransparency = 1

    local Window = {}
    function Window:CreateTab(name)
        local TabBtn = Instance.new("TextButton", Sidebar)
        TabBtn.Size = UDim2.new(1, 0, 0, 35)
        TabBtn.Text = name
        TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        TabBtn.TextColor3 = Color3.new(1, 1, 1)

        local Page = Instance.new("ScrollingFrame", Content)
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.Visible = false
        Page.BackgroundTransparency = 1
        Instance.new("UIListLayout", Page).Padding = UDim.new(0, 5)

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(Content:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
            Page.Visible = true
        end)

        local TabOps = {}
        -- ميزة التحكم بالسرعة (المستطيل مع الإدخال والأزرار)
        function TabOps:AddSpeedControl(label, callback)
            local Row = Instance.new("Frame", Page)
            Row.Size = UDim2.new(0.95, 0, 0, 50)
            Row.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            Instance.new("UICorner", Row)

            local Lbl = Instance.new("TextLabel", Row)
            Lbl.Text = label
            Lbl.Size = UDim2.new(0.3, 0, 1, 0)
            Lbl.TextColor3 = Color3.new(1, 1, 1)
            Lbl.BackgroundTransparency = 1

            local Input = Instance.new("TextBox", Row)
            Input.Size = UDim2.new(0, 40, 0, 30)
            Input.Position = UDim2.new(0.35, 0, 0.5, -15)
            Input.Text = "16"
            Input.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            Input.TextColor3 = Color3.new(1, 1, 1)

            local Plus = Instance.new("TextButton", Row)
            Plus.Text = "+"
            Plus.Size = UDim2.new(0, 25, 0, 25)
            Plus.Position = UDim2.new(0.55, 0, 0.5, -12)
            Plus.BackgroundColor3 = Color3.fromRGB(0, 255, 150)

            local Minus = Instance.new("TextButton", Row)
            Minus.Text = "-"
            Minus.Size = UDim2.new(0, 25, 0, 25)
            Minus.Position = UDim2.new(0.65, 0, 0.5, -12)
            Minus.BackgroundColor3 = Color3.fromRGB(255, 80, 80)

            local Toggle = Instance.new("TextButton", Row)
            Toggle.Size = UDim2.new(0, 40, 0, 20)
            Toggle.Position = UDim2.new(0.85, 0, 0.5, -10)
            Toggle.Text = ""
            Toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            local TCorner = Instance.new("UICorner", Toggle)
            TCorner.CornerRadius = UDim.new(1, 0)

            local isActive = false
            Toggle.MouseButton1Click:Connect(function()
                isActive = not isActive
                Toggle.BackgroundColor3 = isActive and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(60, 60, 60)
                callback(isActive, tonumber(Input.Text) or 16)
            end)

            Plus.MouseButton1Click:Connect(function()
                Input.Text = tostring((tonumber(Input.Text) or 16) + 1)
                if isActive then callback(isActive, tonumber(Input.Text)) end
            end)

            Minus.MouseButton1Click:Connect(function()
                Input.Text = tostring((tonumber(Input.Text) or 16) - 1)
                if isActive then callback(isActive, tonumber(Input.Text)) end
            end)
        end
        return TabOps
    end
    return Window
end

return UI
