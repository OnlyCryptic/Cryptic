-- [[ Cryptic Hub - UI Element: Folder ]]
return function(TabRef, title)
    TabRef.Order = TabRef.Order + 1
    
    local FolderContainer = Instance.new("Frame", TabRef.Page)
    FolderContainer.LayoutOrder = TabRef.Order
    FolderContainer.Size = UDim2.new(0.95, 0, 0, 40)
    FolderContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    FolderContainer.ClipsDescendants = true
    Instance.new("UICorner", FolderContainer).CornerRadius = UDim.new(0, 6)
    
    local HeaderBtn = Instance.new("TextButton", FolderContainer)
    HeaderBtn.Size = UDim2.new(1, 0, 0, 40)
    HeaderBtn.BackgroundTransparency = 1
    HeaderBtn.Text = "  ▶ " .. title
    HeaderBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
    HeaderBtn.Font = Enum.Font.GothamBold
    HeaderBtn.TextSize = 14
    HeaderBtn.TextXAlignment = Enum.TextXAlignment.Left

    local InnerPage = Instance.new("Frame", FolderContainer)
    InnerPage.Position = UDim2.new(0, 0, 0, 40)
    InnerPage.Size = UDim2.new(1, 0, 0, 0)
    InnerPage.BackgroundTransparency = 1
    
    local InnerLayout = Instance.new("UIListLayout", InnerPage)
    InnerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    InnerLayout.Padding = UDim.new(0, 5)
    
    local isOpen = false
    
    local function UpdateSize()
        if isOpen then
            local contentHeight = InnerLayout.AbsoluteContentSize.Y
            FolderContainer.Size = UDim2.new(0.95, 0, 0, 40 + contentHeight + 10)
            InnerPage.Size = UDim2.new(1, 0, 0, contentHeight + 10)
            HeaderBtn.Text = "  ▼ " .. title
        else
            FolderContainer.Size = UDim2.new(0.95, 0, 0, 40)
            HeaderBtn.Text = "  ▶ " .. title
        end
    end
    
    HeaderBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        UpdateSize()
    end)
    
    InnerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if isOpen then UpdateSize() end
    end)
    
    -- إرجاع كائن وهمي يشتغل كأنه Tab عشان يستقبل الدوال
    local FolderTab = setmetatable({
        Page = InnerPage,
        Order = 0
    }, {
        __index = TabRef
    })
    
    return FolderTab
end
