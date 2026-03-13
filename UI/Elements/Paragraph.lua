return function(TabOps, title, content)
    TabOps.Order = TabOps.Order + 1
    
    local Row = Instance.new("Frame", TabOps.Page)
    Row.LayoutOrder = TabOps.Order
    Row.Size = UDim2.new(0.98, 0, 0, 75) -- 🟢 حجم ثابت بدلاً من التلقائي المزعج
    Row.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 6)
    
    local TitleLbl = Instance.new("TextLabel", Row)
    TitleLbl.Text = title
    TitleLbl.Size = UDim2.new(1, -20, 0, 25)
    TitleLbl.Position = UDim2.new(0, 10, 0, 5)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.TextColor3 = Color3.fromRGB(0, 255, 150)
    TitleLbl.Font = Enum.Font.GothamBold
    TitleLbl.TextSize = 14
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Center
    
    local ContentLbl = Instance.new("TextLabel", Row)
    ContentLbl.Text = content
    ContentLbl.Size = UDim2.new(1, -20, 0, 40)
    ContentLbl.Position = UDim2.new(0, 10, 0, 30)
    ContentLbl.BackgroundTransparency = 1
    ContentLbl.TextColor3 = Color3.fromRGB(180, 180, 180)
    ContentLbl.Font = Enum.Font.Gotham
    ContentLbl.TextSize = 12
    ContentLbl.TextWrapped = true
    ContentLbl.TextXAlignment = Enum.TextXAlignment.Center
    ContentLbl.TextYAlignment = Enum.TextYAlignment.Top
end
