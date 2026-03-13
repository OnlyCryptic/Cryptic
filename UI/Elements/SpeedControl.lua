return function(TabOps, label, callback, default)
    TabOps.Order = TabOps.Order + 1
    
    local Row = Instance.new("Frame", TabOps.Page)
    Row.LayoutOrder = TabOps.Order
    Row.Size = UDim2.new(0.98, 0, 0, 45)
    Row.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Instance.new("UICorner", Row)
    
    local Tgl = Instance.new("TextButton", Row)
    Tgl.Size = UDim2.new(0, 45, 0, 22)
    Tgl.Position = UDim2.new(1, -55, 0.5, -11)
    Tgl.Text = ""
    Tgl.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Instance.new("UICorner", Tgl).CornerRadius = UDim.new(1, 0)
    
    local startVal = tostring(default or 50)
    local Inp = Instance.new("TextBox", Row)
    Inp.Size = UDim2.new(0, 40, 0, 22)
    Inp.Position = UDim2.new(1, -105, 0.5, -11)
    Inp.Text = startVal
    Inp.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Inp.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", Inp)

    local Lbl = Instance.new("TextLabel", Row)
    Lbl.Text = label
    Lbl.Size = UDim2.new(1, -120, 1, 0)
    Lbl.Position = UDim2.new(0, 5, 0, 0)
    Lbl.TextColor3 = Color3.new(1, 1, 1)
    Lbl.BackgroundTransparency = 1
    Lbl.TextXAlignment = Enum.TextXAlignment.Right
    Lbl.TextSize = 13
    Lbl.TextWrapped = false -- 🟢 تم إيقاف التفاف النص
    Lbl.TextTruncate = Enum.TextTruncate.AtEnd -- 🟢 إضافة (...) لو النص طويل
    
    local active = false
    local configKey = TabOps.TabName .. "_" .. label .. "_Speed"
    
    if TabOps.UI.ConfigData[configKey] ~= nil then 
        active = TabOps.UI.ConfigData[configKey].active
        Inp.Text = tostring(TabOps.UI.ConfigData[configKey].val) 
    end
    
    local function update() 
        Tgl.BackgroundColor3 = active and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(60, 60, 60)
        local val = tonumber(Inp.Text) or tonumber(startVal)
        TabOps.UI.ConfigData[configKey] = {active = active, val = val}
        pcall(callback, active, val) 
    end
    
    if active then task.spawn(function() task.wait(1.5); update() end) end
    Tgl.MouseButton1Click:Connect(function() active = not active; update(); if TabOps.LogAction then TabOps.LogAction("⚡ تحكم", label, active and Inp.Text or "معطل", active and 5763719 or 15548997) end end)
    Inp:GetPropertyChangedSignal("Text"):Connect(function() if active then update() end end)
end
