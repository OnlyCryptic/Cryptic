-- [[ Cryptic Hub - محرك الواجهة المطور والنهائي ]]
-- المطور: Arwa
-- النسخة المتكاملة: تدعم الهاتف، المراقبة، والتحكم الثلاثي الأبعاد

local UI = { Logger = nil } 
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- وظيفة إنشاء النافذة الرئيسية
function UI:CreateWindow(title)
    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "CrypticMobileFinal"
    Screen.ResetOnSpawn = false

    -- 1. زر استرجاع الواجهة العائم (C)
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

    -- منطق سحب زر الاسترجاع لضمان عدم حجب الرؤية
    local dBtn = false; local dStart; local sPos
    OpenBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch then dBtn = true; dStart = i.Position; sPos = OpenBtn.Position end end)
    UserInputService.InputChanged:Connect(function(i) if dBtn and i.UserInputType == Enum.UserInputType.Touch then local d = i.Position - dStart; OpenBtn.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + d.X, sPos.Y.Scale, sPos.Y.Offset + d.Y) end end)
    OpenBtn.InputEnded:Connect(function() dBtn = false end)

    -- 2. الإطار الرئيسي (Main Frame)
    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 440, 0, 280)
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

    -- 3. شريط التحكم العلوي (Title Bar)
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

    -- أزرار الإغلاق والإخفاء
    local Close = Instance.new("TextButton", TitleBar)
    Close.Text = "X"; Close.Position = UDim2.new(1, -35, 0, 5); Close.Size = UDim2.new(0, 25, 0, 25); Close.TextColor3 = Color3.new(1, 0, 0); Close.BackgroundTransparency = 1
    Close.MouseButton1Click:Connect(function() Screen:Destroy() end)

    local Hide = Instance.new("TextButton", TitleBar)
    Hide.Text = "-"; Hide.Position = UDim2.new(1, -70, 0, 5); Hide.Size = UDim2.new(0, 25, 0, 25); Hide.TextColor3 = Color3.new(1, 1, 1); Hide.BackgroundTransparency = 1
    Hide.MouseButton1Click:Connect(function() Main.Visible = false; OpenBtn.Visible = true end)
    OpenBtn.MouseButton1Click:Connect(function() Main.Visible = true; OpenBtn.Visible = false end)

    -- نظام سحب الواجهة (Dragging) للهواتف
    local dragging, dragStart, startPos
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function() dragging = false end)

    -- 4. القائمة الجانبية (Sidebar)
    local Sidebar = Instance.new("Frame", Main)
    Sidebar.Position = UDim2.new(0, 0, 0, 35)
    Sidebar.Size = UDim2.new(0, 110, 1, -35)
    Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Instance.new("UIListLayout", Sidebar).Padding = UDim.new(0, 2)

    -- 5. منطقة المحتوى (Content)
    local Content = Instance.new("Frame", Main)
    Content.Position = UDim2.new(0, 115, 0, 40)
    Content.Size = UDim2.new(1, -120, 1, -45)
    Content.BackgroundTransparency = 1

    local Window = {}
    function Window:CreateTab(name)
        local TabBtn = Instance.new("TextButton", Sidebar)
        TabBtn.Size = UDim2.new(1, 0, 0, 35); TabBtn.Text = name; TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); TabBtn.TextColor3 = Color3.new(1, 1, 1); TabBtn.BorderSizePixel = 0

        local Page = Instance.new("ScrollingFrame", Content)
        Page.Size = UDim2.new(1, 0, 1, 0); Page.Visible = false; Page.BackgroundTransparency = 1; Page.ScrollBarThickness = 2
        Instance.new("UIListLayout", Page).Padding = UDim.new(0, 8)

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(Content:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
            Page.Visible = true
        end)

        local TabOps = {}

        -- وحدة التحكم المتقدمة (سرعة/طيران)
        function TabOps:AddSpeedControl(label, callback)
            local Row = Instance.new("Frame", Page)
            Row.Size = UDim2.new(0.98, 0, 0, 50); Row.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", Row)
            local Lbl = Instance.new("TextLabel", Row); Lbl.Text = label; Lbl.Size = UDim2.new(0.3, 0, 1, 0); Lbl.TextColor3 = Color3.new(1, 1, 1); Lbl.BackgroundTransparency = 1; Lbl.TextXAlignment = "Right"
            local Input = Instance.new("TextBox", Row); Input.Size = UDim2.new(0, 45, 0, 30); Input.Position = UDim2.new(0.35, 0, 0.5, -15); Input.Text = "16"; Input.BackgroundColor3 = Color3.fromRGB(40, 40, 40); Input.TextColor3 = Color3.new(1, 1, 1)
            local Plus = Instance.new("TextButton", Row); Plus.Text = "+"; Plus.Size = UDim2.new(0, 25, 0, 25); Plus.Position = UDim2.new(0.58, 0, 0.5, -12); Plus.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
            local Minus = Instance.new("TextButton", Row); Minus.Text = "-"; Minus.Size = UDim2.new(0, 25, 0, 25); Minus.Position = UDim2.new(0.68, 0, 0.5, -12); Minus.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            local Toggle = Instance.new("TextButton", Row); Toggle.Size = UDim2.new(0, 40, 0, 20); Toggle.Position = UDim2.new(0.85, 0, 0.5, -10); Toggle.Text = ""; Toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60); Instance.new("UICorner", Toggle).CornerRadius = UDim.new(1, 0)
            
            local active = false
            Toggle.MouseButton1Click:Connect(function()
                active = not active
                Toggle.BackgroundColor3 = active and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(60, 60, 60)
                callback(active, tonumber(Input.Text) or 16)
                if UI.Logger then UI.Logger("تغيير ميزة رقمية", label .. " | القيمة: " .. Input.Text) end
            end)
            Plus.MouseButton1Click:Connect(function() Input.Text = tostring((tonumber(Input.Text) or 0) + 1) if active then callback(active, tonumber(Input.Text)) end end)
            Minus.MouseButton1Click:Connect(function() Input.Text = tostring((tonumber(Input.Text) or 0) - 1) if active then callback(active, tonumber(Input.Text)) end end)
        end

        -- وحدة التبديل البسيطة (للكشف ESP)
        function TabOps:AddToggle(label, callback)
            local Row = Instance.new("Frame", Page)
            Row.Size = UDim2.new(0.98, 0, 0, 50); Row.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", Row)
            local Lbl = Instance.new("TextLabel", Row); Lbl.Text = label; Lbl.Size = UDim2.new(0.7, 0, 1, 0); Lbl.Position = UDim2.new(0.05, 0, 0, 0); Lbl.TextColor3 = Color3.new(1, 1, 1); Lbl.BackgroundTransparency = 1; Lbl.TextXAlignment = "Right"
            local Toggle = Instance.new("TextButton", Row); Toggle.Size = UDim2.new(0, 45, 0, 22); Toggle.Position = UDim2.new(1, -55, 0.5, -11); Toggle.Text = ""; Toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60); Instance.new("UICorner", Toggle).CornerRadius = UDim.new(1, 0)
            
            local active = false
            Toggle.MouseButton1Click:Connect(function()
                active = not active
                Toggle.BackgroundColor3 = active and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(60, 60, 60)
                callback(active)
                if UI.Logger then UI.Logger("تغيير تبديل", label .. " | الحالة: " .. (active and "ON" or "OFF")) end
            end)
        end

        -- وحدة الأزرار البسيطة (للأوامر المباشرة)
        function TabOps:AddButton(text, callback)
            local Btn = Instance.new("TextButton", Page)
            Btn.Size = UDim2.new(0.95, 0, 0, 40); Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); Btn.Text = text; Btn.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", Btn)
            Btn.MouseButton1Click:Connect(function() callback() if UI.Logger then UI.Logger("ضغط زر", text) end end)
        end

        -- وحدة الإدخال (لرموز السيرفر)
        function TabOps:AddInput(label, placeholder, callback)
            local Row = Instance.new("Frame", Page)
            Row.Size = UDim2.new(0.95, 0, 0, 60); Row.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", Row)
            local Lbl = Instance.new("TextLabel", Row); Lbl.Text = label; Lbl.Size = UDim2.new(1, -10, 0, 25); Lbl.Position = UDim2.new(0, 5, 0, 5); Lbl.TextColor3 = Color3.fromRGB(0, 255, 150); Lbl.BackgroundTransparency = 1; Lbl.TextXAlignment = "Right"
            local Input = Instance.new("TextBox", Row); Input.Size = UDim2.new(0.9, 0, 0, 25); Input.Position = UDim2.new(0.05, 0, 0, 30); Input.PlaceholderText = placeholder; Input.Text = ""; Input.BackgroundColor3 = Color3.fromRGB(40, 40, 40); Input.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", Input)
            Input.FocusLost:Connect(function(enter) if enter then callback(Input.Text) if UI.Logger then UI.Logger("إدخال نص", label .. " | المحتوى: " .. Input.Text) end end end)
        end

        return TabOps
    end
    return Window
end

-- نظام التنبيهات
function UI:Notify(msg)
    warn("[Cryptic Hub]: " .. msg)
end

return UI
