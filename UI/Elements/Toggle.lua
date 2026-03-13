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
    Lbl.Size = UDim2.new(1, -70, 1, 0) 
    Lbl.Position = UDim2.new(0, 5, 0, 0)
    Lbl.TextColor3 = Color3.new(1, 1, 1)
    Lbl.BackgroundTransparency = 1
    Lbl.TextXAlignment = Enum.TextXAlignment.Right
    Lbl.TextSize = 13 
    Lbl.TextWrapped = false -- 🟢 تم إيقاف التفاف النص لمنع السطرين
    Lbl.TextTruncate = Enum.TextTruncate.AtEnd -- 🟢 إضافة (...) لو النص طويل
    
    local isActive = false
    local configKey = TabOps.TabName .. "_" .. label
    
    if TabOps.UI.ConfigData[configKey] ~= nil then isActive = TabOps.UI.ConfigData[configKey] end
    
    local function setState(state, isClick)
        isActive = state
        B.BackgroundColor3 = isActive and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(60, 60, 60)
        TabOps.UI.ConfigData[configKey] = isActive
        pcall(callback, isActive)
        if isClick and TabOps.LogAction then TabOps.LogAction("⚙️ تفعيل/إيقاف ميزة", label, isActive and "مفعل ✅" or "معطل ❌", isActive and 5763719 or 15548997) end
    end
    
    B.BackgroundColor3 = isActive and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(60, 60, 60)
    if isActive then task.spawn(function() task.wait(1.5); pcall(callback, isActive) end) end
    
    B.MouseButton1Click:Connect(function() setState(not isActive, true) end)
    return { SetState = function(self, state) setState(state, false) end }
end
