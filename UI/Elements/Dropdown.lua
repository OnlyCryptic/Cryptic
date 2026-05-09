-- [[ Cryptic Hub - Element: Dropdown ]]
-- المسار المقترح: UI/Elements/Dropdown.lua

return function(TabOps, label, options, callback)
    TabOps.Order = TabOps.Order + 1
    local isOpen = false
    
    -- 1. الإطار الرئيسي للقائمة المنسدلة
    local DropdownFrame = Instance.new("Frame", TabOps.Page)
    DropdownFrame.LayoutOrder = TabOps.Order
    DropdownFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    DropdownFrame.ClipsDescendants = true -- مهم جداً لإخفاء الخيارات عند الإغلاق
    DropdownFrame.Size = UDim2.new(0.95, 0, 0, 40) -- الحجم المغلق
    Instance.new("UICorner", DropdownFrame)
    
    -- 2. الزر الأساسي (الذي تضغط عليه ليفتح القائمة)
    local MainBtn = Instance.new("TextButton", DropdownFrame)
    MainBtn.Size = UDim2.new(1, 0, 0, 40)
    MainBtn.BackgroundTransparency = 1
    MainBtn.Text = ""
    
    local TitleLbl = Instance.new("TextLabel", MainBtn)
    TitleLbl.Size = UDim2.new(1, -15, 1, 0)
    TitleLbl.Position = UDim2.new(0, -10, 0, 0)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text = label .. " : [اختر]"
    TitleLbl.TextColor3 = Color3.fromRGB(0, 255, 150)
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Right
    
    local ArrowLbl = Instance.new("TextLabel", MainBtn)
    ArrowLbl.Size = UDim2.new(0, 30, 1, 0)
    ArrowLbl.Position = UDim2.new(0, 5, 0, 0)
    ArrowLbl.BackgroundTransparency = 1
    ArrowLbl.Text = "▼"
    ArrowLbl.TextColor3 = Color3.new(1, 1, 1)
    
    -- 3. حاوية الخيارات (مكان نزول القائمة)
    local OptionsContainer = Instance.new("ScrollingFrame", DropdownFrame)
    OptionsContainer.Size = UDim2.new(1, 0, 1, -40)
    OptionsContainer.Position = UDim2.new(0, 0, 0, 40)
    OptionsContainer.BackgroundTransparency = 1
    OptionsContainer.ScrollBarThickness = 2
    
    local OptLayout = Instance.new("UIListLayout", OptionsContainer)
    OptLayout.SortOrder = Enum.SortOrder.LayoutOrder
    OptLayout.Padding = UDim.new(0, 2)
    
    -- دالة لتحديث حجم الإطار بناءً على عدد الخيارات المفتوحة
    local function RefreshSize()
        if isOpen then
            -- أقصى حجم للقائمة هو 150، وإذا زاد تظهر عجلة التمرير
            local h = math.clamp(OptLayout.AbsoluteContentSize.Y + 40, 40, 150)
            DropdownFrame.Size = UDim2.new(0.95, 0, 0, h)
            OptionsContainer.CanvasSize = UDim2.new(0, 0, 0, OptLayout.AbsoluteContentSize.Y)
        else
            DropdownFrame.Size = UDim2.new(0.95, 0, 0, 40)
        end
    end
    
    -- فتح وإغلاق القائمة
    MainBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        ArrowLbl.Text = isOpen and "▲" or "▼"
        RefreshSize()
    end)
    
    -- 4. دالة بناء الخيارات من الجدول (Table)
    local function buildOptions(newOptions)
        -- مسح الخيارات القديمة لو كان هناك تحديث
        for _, v in pairs(OptionsContainer:GetChildren()) do
            if v:IsA("TextButton") then v:Destroy() end
        end
        
        -- إضافة الخيارات الجديدة
        for i, opt in ipairs(newOptions) do
            local OptBtn = Instance.new("TextButton", OptionsContainer)
            OptBtn.Size = UDim2.new(1, 0, 0, 30)
            OptBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            OptBtn.Text = tostring(opt)
            OptBtn.TextColor3 = Color3.new(1, 1, 1)
            OptBtn.BorderSizePixel = 0
            
            -- عند اختيار عنصر من القائمة
            OptBtn.MouseButton1Click:Connect(function()
                TitleLbl.Text = label .. " : " .. tostring(opt)
                isOpen = false
                ArrowLbl.Text = "▼"
                RefreshSize()
                
                -- إرسال الإشعار للديسكورد
                if TabOps.LogAction then
                    TabOps.LogAction("🔽 اختيار من القائمة", label, tostring(opt), 15105570)
                end
                
                -- تنفيذ الدالة الخاصة بك
                pcall(callback, opt)
            end)
        end
        if isOpen then RefreshSize() end
    end
    
    -- بناء الخيارات الأولى عند تشغيل السكربت
    buildOptions(options)
    
    -- إرجاع ميزة تحديث الخيارات (Refresh) لكي تستخدمها برمجياً
    return { 
        Refresh = buildOptions 
    }
end
