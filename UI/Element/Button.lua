-- [[ Cryptic Hub - Element: Button ]]
-- المسار المقترح: UI/Elements/Button.lua

return function(TabOps, text, callback)
    -- 1. زيادة الترتيب التلقائي للعناصر في الصفحة
    TabOps.Order = TabOps.Order + 1
    
    -- 2. تصميم الزر
    local B = Instance.new("TextButton", TabOps.Page)
    B.LayoutOrder = TabOps.Order
    B.Size = UDim2.new(0.95, 0, 0, 40)
    B.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    B.Text = text
    B.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", B)
    
    -- 3. برمجة الضغطة (تنفيذ الدالة + إرسال للديسكورد)
    B.MouseButton1Click:Connect(function()
        -- إرسال الإشعار للديسكورد عبر دالة LogAction الموجودة في Core
        if TabOps.LogAction then
            TabOps.LogAction("🔘 ضغطة زر", "تم الضغط على:", text, 3447003)
        end
        
        -- تنفيذ الأمر الخاص بالزر
        pcall(callback)
    end)
    
    return B
end
