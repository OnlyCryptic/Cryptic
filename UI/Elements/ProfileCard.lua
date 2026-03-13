-- [[ Cryptic Hub - Element: Profile Card ]]
return function(TabOps, player)
    TabOps.Order = TabOps.Order + 1
    local R = Instance.new("Frame", TabOps.Page)
    R.LayoutOrder = TabOps.Order
    R.Size = UDim2.new(0.98, 0, 0, 75)
    R.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Instance.new("UICorner", R).CornerRadius = UDim.new(0, 8)
    
    local Avatar = Instance.new("ImageLabel", R)
    Avatar.Size = UDim2.new(0, 55, 0, 55)
    Avatar.Position = UDim2.new(1, -65, 0, 10)
    Avatar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Instance.new("UICorner", Avatar).CornerRadius = UDim.new(1, 0)
    
    task.spawn(function()
        local s, thumb = pcall(function() return game:GetService("Players"):GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420) end)
        if s and thumb then Avatar.Image = thumb end
    end)
    
    local NameLbl = Instance.new("TextLabel", R)
    NameLbl.Size = UDim2.new(1, -80, 0, 25)
    NameLbl.Position = UDim2.new(0, 10, 0, 12)
    NameLbl.BackgroundTransparency = 1
    NameLbl.Text = "welcome, " .. player.DisplayName
    NameLbl.TextColor3 = Color3.fromRGB(0, 255, 150)
    NameLbl.TextXAlignment = Enum.TextXAlignment.Right
    NameLbl.Font = Enum.Font.GothamBold
    NameLbl.TextSize = 16
    
    local UserLbl = Instance.new("TextLabel", R)
    UserLbl.Size = UDim2.new(1, -80, 0, 20)
    UserLbl.Position = UDim2.new(0, 10, 0, 37)
    UserLbl.BackgroundTransparency = 1
    UserLbl.Text = "@" .. player.Name
    UserLbl.TextColor3 = Color3.fromRGB(170, 170, 170)
    UserLbl.TextXAlignment = Enum.TextXAlignment.Right
    UserLbl.Font = Enum.Font.Gotham
    UserLbl.TextSize = 13
end
