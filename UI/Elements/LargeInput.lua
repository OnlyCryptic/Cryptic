-- [[ Cryptic Hub - Element: Large Input Box ]]
-- المسار المقترح: UI/Elements/LargeInput.lua

return function(TabOps, label, placeholder, callback)
    TabOps.Order = TabOps.Order + 1
    local R = Instance.new("Frame", TabOps.Page)
    R.LayoutOrder = TabOps.Order
    R.Size = UDim2.new(0.95, 0, 0, 110) -- حجم كبير مقارنة بالعادي
    R.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Instance.new("UICorner", R)

    local Lbl = Instance.new("TextLabel", R)
    Lbl.Text = label
    Lbl.Size = UDim2.new(1, -10, 0, 25)
    Lbl.TextColor3 = Color3.fromRGB(0, 255, 150)
    Lbl.BackgroundTransparency = 1
    Lbl.TextXAlignment = Enum.TextXAlignment.Right

    local I = Instance.new("TextBox", R)
    I.Size = UDim2.new(0.9, 0, 0, 75)
    I.Position = UDim2.new(0.05, 0, 0, 25)
    I.PlaceholderText = placeholder
    I.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    I.TextColor3 = Color3.new(1, 1, 1)
    I.Text = ""
    I.MultiLine = true -- يسمح بالكتابة في عدة أسطر
    I.TextWrapped = true
    I.ClearTextOnFocus = false
    I.TextYAlignment = Enum.TextYAlignment.Top
    Instance.new("UICorner", I)

    -- تحديث وإرسال النص عند تغييره (بدون حفظ في Config لكي لا يثقل الملف)
    I:GetPropertyChangedSignal("Text"):Connect(function() pcall(callback, I.Text) end)
    return { SetText = function(t) I.Text = t end, TextBox = I }
end
