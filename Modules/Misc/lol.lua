return function(Tab, UI)
    local TabOps = Tab.TabOps or {}

    if TabOps.Page then
        TabOps.Order = (TabOps.Order or 0) + 1
        local L = Instance.new("Frame", TabOps.Page)

        L.LayoutOrder = -1
        L.Size = UDim2.new(0.95, 0, 0, 1)
        L.AnchorPoint = Vector2.new(0.5, 0)
        L.Position = UDim2.new(0.5, 0, 0, 0)
        L.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        L.BackgroundTransparency = 0.7
        L.BorderSizePixel = 0

        local G = Instance.new("UIGradient", L)
        G.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 150)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 150, 255))
        }
    end
end
