-- [[ Cryptic Hub - Element: Toggle ]]
-- المسار المقترح: UI/Elements/Toggle.lua

return function(TabOps, label, callback)
    TabOps.Order = TabOps.Order + 1
    
    -- 1. تصميم واجهة زر التفعيل
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
    
    -- 2. نظام الحفظ واسترجاع الحالة (Config)
    local isActive = false
    local configKey = TabOps.TabName .. "_" .. label
    
    -- قراءة القيمة المحفوظة مسبقاً من ملف Core (إن وجدت)
    if TabOps.UI.ConfigData[configKey] ~= nil then 
        isActive = TabOps.UI.ConfigData[configKey] 
    end
    
    -- 3. دالة تغيير الحالة (التشغيل/الإيقاف)
    local function setState(state, isClick)
        isActive = state
        -- تغيير اللون: أزرق إذا شغال، رمادي إذا طافي
        B.BackgroundColor3 = isActive and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(60, 60, 60)
        
        -- حفظ الحالة الجديدة في الإعدادات
        TabOps.UI.ConfigData[configKey] = isActive
        
        -- تنفيذ كود الميزة الخاصة بك
        pcall(callback, isActive)
        
        -- إرسال إشعار للديسكورد (فقط إذا ضغط اللاعب بيده)
        if isClick and TabOps.LogAction then
            TabOps.LogAction("⚙️ تفعيل/إيقاف ميزة", label, isActive and "مفعل ✅" or "معطل ❌", isActive and 5763719 or 15548997)
        end
    end
    
    -- 4. تطبيق الحالة الابتدائية عند فتح السكربت
    B.BackgroundColor3 = isActive and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(60, 60, 60)
    if isActive then 
        task.spawn(function() 
            task.wait(1.5) -- تأخير بسيط لضمان تحميل اللعبة بالكامل قبل التشغيل التلقائي
            pcall(callback, isActive) 
        end) 
    end
    
    -- 5. ربط الضغطة بالدالة
    B.MouseButton1Click:Connect(function() 
        setState(not isActive, true) 
    end)
    
    -- إرجاع أداة للتحكم بالزر من الخارج (لو أردت إطفاءه من زر آخر مثلاً)
    return { 
        SetState = function(self, state) setState(state, false) end 
    }
end
