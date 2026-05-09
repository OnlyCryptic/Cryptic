-- [[ Cryptic Hub - Element: Label ]]
return function(TabOps, text)
    TabOps.Order = TabOps.Order + 1
    local R = Instance.new("Frame", TabOps.Page)
    R.LayoutOrder = TabOps.Order
    R.Size = UDim2.new(0.98, 0, 0, 35)
    R.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Instance.new("UICorner", R)
    
    local L = Instance.new("TextLabel", R)
    L.Text = text
    L.Size = UDim2.new(1, -10, 1, 0)
    L.TextColor3 = Color3.fromRGB(0, 255, 150)
    L.BackgroundTransparency = 1
    L.TextXAlignment = Enum.TextXAlignment.Right
    
    -- يمكنك تغيير النص برمجياً لاحقاً
    return { SetText = function(nt) L.Text = nt end }
end
