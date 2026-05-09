-- [[ Cryptic Hub - Element: Line ]]
return function(TabOps)
    TabOps.Order = TabOps.Order + 1

    -- container يعطي الخط مسافة فوق وتحت مثل باقي العناصر
    local Container = Instance.new("Frame", TabOps.Page)
    Container.LayoutOrder = TabOps.Order
    Container.Size = UDim2.new(0.98, 0, 0, 4)
    Container.BackgroundTransparency = 1
    Container.BorderSizePixel = 0

    -- الخط نفسه يتمركز وسط الـ container
    local L = Instance.new("Frame", Container)
    L.AnchorPoint = Vector2.new(0.5, 0.5)
    L.Position = UDim2.new(0.5, 0, 0.5, 0)
    L.Size = UDim2.new(0.95, 0, 0, 1)
    L.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    L.BackgroundTransparency = 0.4
    L.BorderSizePixel = 0

    local G = Instance.new("UIGradient", L)
    G.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 150)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 150, 255))
    }
    G.Rotation = 0
end
