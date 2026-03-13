-- [[ Cryptic Hub - Element: Speed Control ]]
-- المسار المقترح: UI/Elements/SpeedControl.lua

return function(TabOps, label, callback, default)
    TabOps.Order = TabOps.Order + 1
    
    -- 1. الإطار الرئيسي للعنصر
    local Row = Instance.new("Frame", TabOps.Page)
    Row.LayoutOrder = TabOps.Order
    Row.Size = UDim2.new(0.98, 0, 0, 45)
    Row.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Instance.new("UICorner", Row)
    
    -- 2. النص (العنوان)
    local Lbl = Instance.new("TextLabel", Row)
    Lbl.Text = label
    Lbl.Size = UDim2.new(0.6, 0, 1, 0)
    Lbl.Position = UDim2.new(0.05, 0, 0, 0)
    Lbl.TextColor3 = Color3.new(1, 1, 1)
    Lbl.BackgroundTransparency = 1
    Lbl.TextXAlignment = Enum.TextXAlignment.Right
    
    -- 3. زر التفعيل (Toggle)
    local Tgl = Instance.new("TextButton", Row)
    Tgl.Size = UDim2.new(0, 45, 0, 22)
    Tgl.Position = UDim2.new(1, -55, 0.5, -11)
    Tgl.Text = ""
    Tgl.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Instance.new("UICorner", Tgl).CornerRadius = UDim.new(1, 0)
    
    -- 4. مربع إدخال القيمة (الرقم)
    local startVal = tostring(default or 50)
    local Inp = Instance.new("TextBox", Row)
    Inp.Size = UDim2.new(0, 40, 0, 22)
    Inp.Position = UDim2.new(1, -105, 0.5, -11)
    Inp.Text = startVal
    Inp.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Inp.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", Inp)
    
    -- 5. نظام الحفظ واسترجاع القيمة (Config)
    local active = false
    local configKey = TabOps.TabName .. "_" .. label .. "_Speed"
    
    if TabOps.UI.ConfigData[configKey] ~= nil then 
        active = TabOps.UI.ConfigData[configKey].active
        Inp.Text = tostring(TabOps.UI.ConfigData[configKey].val) 
    end
    
    -- دالة تحديث الحالة وتنفيذ الأمر
    local function update() 
        Tgl.BackgroundColor3 = active and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(60, 60, 60)
        local val = tonumber(Inp.Text) or tonumber(startVal)
        
        -- حفظ الحالة (التفعيل + الرقم)
        TabOps.UI.ConfigData[configKey] = {active = active, val = val}
        pcall(callback, active, val) 
    end
    
    -- التشغيل التلقائي عند بدء السكربت إذا كان محفوظاً
    if active then 
        task.spawn(function() task.wait(1.5); update() end) 
    end
    
    -- 6. التفاعل مع الزر
    Tgl.MouseButton1Click:Connect(function() 
        active = not active
        update()
        
        -- إرسال الإشعار
        if TabOps.LogAction then
            TabOps.LogAction("⚡ تحكم بالسرعة", label, active and ("مفعل - القيمة: " .. Inp.Text) or "معطل", active and 5763719 or 15548997) 
        end
    end)
    
    -- 7. التحديث التلقائي إذا غيرت الرقم والزر شغال
    Inp:GetPropertyChangedSignal("Text"):Connect(function() 
        if active then update() end 
    end)
end
