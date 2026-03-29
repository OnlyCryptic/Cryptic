-- [[ Cryptic Hub - Element: Line ]]
return function(TabOps)
    TabOps.Order = TabOps.Order + 1
    local L = Instance.new("Frame", TabOps.Page)
    L.LayoutOrder = TabOps.Order
    L.Size = UDim2.new(0.95, 0, 0, 1)
    L.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    L.BackgroundTransparency = 0.7
    L.BorderSizePixel = 0
    local G = Instance.new("UIGradient", L)
    G.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 150)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 150, 255))
    }
    G.Rotation = 0
end
