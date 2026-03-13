-- [[ Cryptic Hub - Element: Line ]]
return function(TabOps)
    TabOps.Order = TabOps.Order + 1
    local L = Instance.new("Frame", TabOps.Page)
    L.LayoutOrder = TabOps.Order
    L.Size = UDim2.new(0.95, 0, 0, 1)
    L.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    L.BackgroundTransparency = 0.5
    L.BorderSizePixel = 0
end
