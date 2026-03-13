-- [[ Cryptic Hub - Element: Paragraph ]]
-- المسار: UI/Elements/Paragraph.lua

return function(TabOps, title, content)
    TabOps.Order = TabOps.Order + 1
    
    local Row = Instance.new("Frame", TabOps.Page)
    Row.LayoutOrder = TabOps.Order
    Row.Size = UDim2.new(0.98, 0, 0, 0)
    Row.BackgroundColor3 = Color3.fromRGB(20, 20, 25) -- لون خلفية خفيف ومميز
    Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 6)
    
    -- إطار نيون خفيف يعطي فخامة للنص
    local Stroke = Instance.new("UIStroke", Row)
    Stroke.Color = Color3.fromRGB(0, 255, 150)
    Stroke.Thickness = 1
    Stroke.Transparency = 0.6
    
    local TitleLbl = Instance.new("TextLabel", Row)
    TitleLbl.Text = title
    TitleLbl.Size = UDim2.new(1, -20, 0, 20)
    TitleLbl.Position = UDim2.new(0, 10, 0, 5)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.TextColor3 = Color3.fromRGB(0, 255, 150)
    TitleLbl.Font = Enum.Font.GothamBold
    TitleLbl.TextSize = 13
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Center
    
    local ContentLbl = Instance.new("TextLabel", Row)
    ContentLbl.Text = content
    ContentLbl.Size = UDim2.new(1, -20, 0, 0)
    ContentLbl.Position = UDim2.new(0, 10, 0, 25)
    ContentLbl.BackgroundTransparency = 1
    ContentLbl.TextColor3 = Color3.fromRGB(180, 180, 180)
    ContentLbl.Font = Enum.Font.Gotham
    ContentLbl.TextSize = 12 -- خط صغير ومرتب
    ContentLbl.TextXAlignment = Enum.TextXAlignment.Center
    ContentLbl.TextYAlignment = Enum.TextYAlignment.Top
    ContentLbl.TextWrapped = true
    ContentLbl.AutomaticSize = Enum.AutomaticSize.Y
    
    -- تحديث حجم الإطار تلقائياً بناءً على كمية النص
    Row.Size = UDim2.new(0.98, 0, 0, ContentLbl.AbsoluteSize.Y + 35)
    ContentLbl:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        Row.Size = UDim2.new(0.98, 0, 0, ContentLbl.AbsoluteSize.Y + 35)
    end)
end
