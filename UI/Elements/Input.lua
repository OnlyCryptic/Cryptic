-- [[ Cryptic Hub - Element: Input Box ]]
-- المسار المقترح: UI/Elements/Input.lua

return function(TabOps, label, placeholder, callback)
    TabOps.Order = TabOps.Order + 1
    
    -- 1. تصميم واجهة مربع الإدخال
    local R = Instance.new("Frame", TabOps.Page)
    R.LayoutOrder = TabOps.Order
    R.Size = UDim2.new(0.95, 0, 0, 60)
    R.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Instance.new("UICorner", R)
    
    -- عنوان المربع
    local Lbl = Instance.new("TextLabel", R)
    Lbl.Text = label
    Lbl.Size = UDim2.new(1, -10, 0, 25)
    Lbl.TextColor3 = Color3.fromRGB(0, 255, 150)
    Lbl.BackgroundTransparency = 1
    Lbl.TextXAlignment = Enum.TextXAlignment.Right
    
    -- مكان الكتابة (TextBox)
    local I = Instance.new("TextBox", R)
    I.Size = UDim2.new(0.9, 0, 0, 25)
    I.Position = UDim2.new(0.05, 0, 0, 30)
    I.PlaceholderText = placeholder
    I.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    I.TextColor3 = Color3.new(1, 1, 1)
    I.Text = ""
    I.ClearTextOnFocus = false -- عشان ما ينمسح الكلام إذا ضغطت عليه للتعديل
    Instance.new("UICorner", I)
    
    -- 2. نظام الحفظ واسترجاع النص (Config)
    local configKey = TabOps.TabName .. "_" .. label .. "_Input"
    
    -- قراءة النص المحفوظ مسبقاً من ملف Core
    if TabOps.UI.ConfigData[configKey] ~= nil then 
        I.Text = TabOps.UI.ConfigData[configKey]
        
        -- تشغيل الدالة التلقائية بعد التحميل
        task.spawn(function() 
            task.wait(1.5) 
            pcall(callback, I.Text) 
        end) 
    end
    
    -- 3. تحديث الحفظ وتشغيل الدالة مع كل تغيير في النص
    I:GetPropertyChangedSignal("Text"):Connect(function() 
        TabOps.UI.ConfigData[configKey] = I.Text
        pcall(callback, I.Text) 
    end)
    
    -- 4. إرسال إشعار للديسكورد فقط عند الانتهاء من الكتابة
    I.FocusLost:Connect(function() 
        if I.Text ~= "" and TabOps.LogAction then 
            TabOps.LogAction("⌨️ إدخال نص", label .. ":", I.Text, 10181046) 
        end 
    end)
    
    -- إرجاع أداة تسمح لك بتغيير النص برمجياً من الخارج لو احتجت
    return { 
        SetText = function(t) I.Text = t end, 
        TextBox = I 
    }
end
