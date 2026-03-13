-- [[ Cryptic Hub - Element: Paragraph ]]
return function(TabOps, text)
    TabOps.Order = TabOps.Order + 1
    local Lbl = Instance.new("TextLabel", TabOps.Page)
    Lbl.LayoutOrder = TabOps.Order
    Lbl.Size = UDim2.new(0.95, 0, 0, 0)
    Lbl.AutomaticSize = Enum.AutomaticSize.Y
    Lbl.TextWrapped = true
    Lbl.Text = text
    Lbl.TextColor3 = Color3.fromRGB(170, 170, 170)
    Lbl.BackgroundTransparency = 1
    Lbl.TextXAlignment = Enum.TextXAlignment.Right
    Lbl.TextSize = 13
    
    return { SetText = function(nt) Lbl.Text = nt end }
end
