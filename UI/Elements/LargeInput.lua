-- [[ Cryptic Hub - Element: Large Input ]]
-- المسار: UI/Elements/LargeInput.lua

return function(TabOps, label, placeholder, callback)
    TabOps.Order = TabOps.Order + 1
    
    local Row = Instance.new("Frame", TabOps.Page)
    Row.LayoutOrder = TabOps.Order
    Row.Size = UDim2.new(0.98, 0, 0, 110) -- ارتفاع مناسب لمربع كتابة الشكاوى
    Row.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 6)
    
    local Lbl = Instance.new("TextLabel", Row)
    Lbl.Text = label
    Lbl.Size = UDim2.new(1, -20, 0, 20)
    Lbl.Position = UDim2.new(0, 10, 0, 5)
    Lbl.TextColor3 = Color3.new(1, 1, 1)
    Lbl.BackgroundTransparency = 1
    Lbl.TextXAlignment = Enum.TextXAlignment.Right
    Lbl.Font = Enum.Font.GothamSemibold
    Lbl.TextSize = 13
    
    -- تصميم مربع الكتابة (عميق ومظلم)
    local InpBG = Instance.new("Frame", Row)
    InpBG.Size = UDim2.new(1, -20, 1, -35)
    InpBG.Position = UDim2.new(0, 10, 0, 25)
    InpBG.BackgroundColor3 = Color3.fromRGB(15, 15, 18) 
    Instance.new("UICorner", InpBG).CornerRadius = UDim.new(0, 4)
    local Stroke = Instance.new("UIStroke", InpBG)
    Stroke.Color = Color3.fromRGB(60, 60, 60)
    
    local Inp = Instance.new("TextBox", InpBG)
    Inp.Size = UDim2.new(1, -10, 1, -10)
    Inp.Position = UDim2.new(0, 5, 0, 5)
    Inp.Text = ""
    Inp.PlaceholderText = placeholder or "اكتب هنا..."
    Inp.BackgroundTransparency = 1
    Inp.TextColor3 = Color3.new(1, 1, 1)
    Inp.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
    Inp.TextXAlignment = Enum.TextXAlignment.Right
    Inp.TextYAlignment = Enum.TextYAlignment.Top
    Inp.Font = Enum.Font.Gotham
    Inp.TextSize = 12
    Inp.TextWrapped = true
    Inp.ClearTextOnFocus = false
    Inp.MultiLine = true
    
    -- تأثير تفاعلي (أنيميشن) عند الكتابة يضيء المربع
    local TweenService = game:GetService("TweenService")
    Inp.Focused:Connect(function() 
        TweenService:Create(Stroke, TweenInfo.new(0.3), {Color = Color3.fromRGB(0, 255, 150)}):Play() 
    end)
    Inp.FocusLost:Connect(function() 
        TweenService:Create(Stroke, TweenInfo.new(0.3), {Color = Color3.fromRGB(60, 60, 60)}):Play()
        pcall(callback, Inp.Text) 
    end)
end
