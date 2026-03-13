-- [[ Cryptic Hub - Element: Timed Toggle ]]
-- المسار المقترح: UI/Elements/TimedToggle.lua

return function(TabOps, label, callback)
    TabOps.Order = TabOps.Order + 1
    local R = Instance.new("Frame", TabOps.Page)
    R.LayoutOrder = TabOps.Order
    R.Size = UDim2.new(0.98, 0, 0, 45)
    R.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Instance.new("UICorner", R)
    
    local B = Instance.new("TextButton", R)
    B.Size = UDim2.new(0, 45, 0, 22)
    B.Position = UDim2.new(1, -55, 0.5, -11)
    B.Text = ""
    B.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Instance.new("UICorner", B).CornerRadius = UDim.new(1, 0)
    
    local Lbl = Instance.new("TextLabel", R)
    Lbl.Text = label
    Lbl.Size = UDim2.new(0.7, 0, 1, 0)
    Lbl.Position = UDim2.new(0.05, 0, 0, 0)
    Lbl.TextColor3 = Color3.new(1, 1, 1)
    Lbl.BackgroundTransparency = 1
    Lbl.TextXAlignment = Enum.TextXAlignment.Right
    
    local isRunning = false
    
    B.MouseButton1Click:Connect(function() 
        if isRunning then return end
        isRunning = true
        B.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        
        if TabOps.LogAction then 
            TabOps.LogAction("⏱️ تفعيل مؤقت", label, "تم التفعيل", 15844367) 
        end
        
        task.spawn(function() 
            pcall(callback, true)
            task.wait(2) -- الانتظار لثانيتين
            if B then B.BackgroundColor3 = Color3.fromRGB(60, 60, 60) end
            pcall(callback, false)
            isRunning = false 
        end) 
    end)
    
    return { Set = function() end, SetState = function() end }
end
