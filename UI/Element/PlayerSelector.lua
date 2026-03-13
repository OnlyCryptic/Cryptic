-- [[ Cryptic Hub - Element: Player Selector ]]
-- المسار المقترح: UI/Elements/PlayerSelector.lua

local Players = game:GetService("Players")

return function(TabOps, label, placeholder, callback)
    TabOps.Order = TabOps.Order + 1
    
    -- 1. الإطار الرئيسي
    local Container = Instance.new("Frame", TabOps.Page)
    Container.LayoutOrder = TabOps.Order
    Container.Size = UDim2.new(0.95, 0, 0, 75)
    Container.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Instance.new("UICorner", Container)
    
    -- 2. العنوان
    local Lbl = Instance.new("TextLabel", Container)
    Lbl.Text = label
    Lbl.Size = UDim2.new(1, -10, 0, 25)
    Lbl.TextColor3 = Color3.fromRGB(0, 255, 150)
    Lbl.BackgroundTransparency = 1
    Lbl.TextXAlignment = Enum.TextXAlignment.Right

    -- 3. مربع البحث
    local SearchBox = Instance.new("TextBox", Container)
    SearchBox.Size = UDim2.new(0.9, 0, 0, 25)
    SearchBox.Position = UDim2.new(0.05, 0, 0, 25)
    SearchBox.PlaceholderText = placeholder
    SearchBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    SearchBox.TextColor3 = Color3.new(1, 1, 1)
    SearchBox.Text = ""
    SearchBox.ClearTextOnFocus = true
    Instance.new("UICorner", SearchBox)

    -- 4. زر إظهار/إخفاء القائمة
    local DropBtn = Instance.new("TextButton", Container)
    DropBtn.Size = UDim2.new(0.9, 0, 0, 15)
    DropBtn.Position = UDim2.new(0.05, 0, 0, 55)
    DropBtn.Text = "▼ عرض قائمة اللاعبين / Show Players ▼"
    DropBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    DropBtn.TextColor3 = Color3.fromRGB(170, 170, 170)
    DropBtn.TextSize = 11
    Instance.new("UICorner", DropBtn)

    -- 5. قائمة اللاعبين (المكان الذي تظهر فيه الصور والأسماء)
    local DropList = Instance.new("ScrollingFrame", Container)
    DropList.Size = UDim2.new(0.9, 0, 0, 140)
    DropList.Position = UDim2.new(0.05, 0, 0, 75)
    DropList.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    DropList.Visible = false
    DropList.ScrollBarThickness = 2
    Instance.new("UICorner", DropList)
    
    local ListLayout = Instance.new("UIListLayout", DropList)
    ListLayout.Padding = UDim.new(0, 5)
    ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() 
        DropList.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 5) 
    end)

    local isOpen = false
    local currentSelectedUser = nil

    -- حركة فتح وإغلاق القائمة
    DropBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        DropList.Visible = isOpen
        Container.Size = isOpen and UDim2.new(0.95, 0, 0, 220) or UDim2.new(0.95, 0, 0, 75)
        DropBtn.Text = isOpen and "▲ إغلاق القائمة / Close List ▲" or "▼ عرض قائمة اللاعبين / Show Players ▼"
    end)

    -- 6. دالة بناء وتحديث بطاقات اللاعبين داخل القائمة
    local function UpdateList(playersList)
        for _, v in pairs(DropList:GetChildren()) do
            if v:IsA("Frame") then v:Destroy() end
        end
        
        for _, p in pairs(playersList) do
            local PItem = Instance.new("Frame", DropList)
            PItem.Name = p.Name
            PItem.Size = UDim2.new(1, -10, 0, 40)
            
            -- تلوين اللاعب المحدد بالأخضر
            PItem.BackgroundColor3 = (currentSelectedUser == p.Name) and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(40, 40, 40)
            Instance.new("UICorner", PItem)

            -- جلب صورة اللاعب من روبلوكس
            local Avatar = Instance.new("ImageLabel", PItem)
            Avatar.Size = UDim2.new(0, 30, 0, 30)
            Avatar.Position = UDim2.new(0, 5, 0, 5)
            Avatar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            Instance.new("UICorner", Avatar).CornerRadius = UDim.new(1, 0)
            
            task.spawn(function()
                local s, thumb = pcall(function() return Players:GetUserThumbnailAsync(p.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420) end)
                if s and thumb then Avatar.Image = thumb end
            end)

            -- الاسم الوهمي (DisplayName)
            local NLabel = Instance.new("TextLabel", PItem)
            NLabel.Size = UDim2.new(1, -45, 0, 20); NLabel.Position = UDim2.new(0, 40, 0, 0)
            NLabel.Text = p.DisplayName; NLabel.TextColor3 = Color3.new(1, 1, 1)
            NLabel.BackgroundTransparency = 1; NLabel.TextXAlignment = Enum.TextXAlignment.Left; NLabel.Font = Enum.Font.GothamBold; NLabel.TextSize = 12

            -- اليوزر نيم الأصلي (@Username)
            local ULabel = Instance.new("TextLabel", PItem)
            ULabel.Size = UDim2.new(1, -45, 0, 20); ULabel.Position = UDim2.new(0, 40, 0, 18)
            ULabel.Text = "@" .. p.Name; ULabel.TextColor3 = Color3.fromRGB(170, 170, 170)
            ULabel.BackgroundTransparency = 1; ULabel.TextXAlignment = Enum.TextXAlignment.Left; ULabel.Font = Enum.Font.Gotham; ULabel.TextSize = 10

            -- زر اختيار هذا اللاعب
            local SelectBtn = Instance.new("TextButton", PItem)
            SelectBtn.Size = UDim2.new(1, 0, 1, 0); SelectBtn.BackgroundTransparency = 1; SelectBtn.Text = ""
            
            SelectBtn.MouseButton1Click:Connect(function()
                currentSelectedUser = p.Name
                SearchBox.Text = p.DisplayName .. " (@" .. p.Name .. ")"
                
                -- تغيير الألوان للتوضيح
                for _, v in pairs(DropList:GetChildren()) do
                    if v:IsA("Frame") then v.BackgroundColor3 = (v.Name == currentSelectedUser) and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(40, 40, 40) end
                end
                
                task.wait(0.15)
                isOpen = false; DropList.Visible = false
                Container.Size = UDim2.new(0.95, 0, 0, 75)
                DropBtn.Text = "▼ عرض قائمة اللاعبين / Show Players ▼"
                
                -- تسجيل وإرسال للديسكورد
                if TabOps.LogAction then TabOps.LogAction("👤 تحديد لاعب", label, "تم تحديد: " .. p.Name, 10181046) end
                pcall(callback, p) 
            end)
        end
    end

    -- 7. نظام البحث الذكي (عند الكتابة داخل المربع)
    SearchBox.Focused:Connect(function()
        currentSelectedUser = nil
        for _, v in pairs(DropList:GetChildren()) do
            if v:IsA("Frame") then v.BackgroundColor3 = Color3.fromRGB(40, 40, 40) end
        end
        pcall(callback, nil)
    end)

    SearchBox.FocusLost:Connect(function()
        local txt = SearchBox.Text
        if txt == "" then 
            currentSelectedUser = nil
            for _, v in pairs(DropList:GetChildren()) do
                if v:IsA("Frame") then v.BackgroundColor3 = Color3.fromRGB(40, 40, 40) end
            end
            pcall(callback, nil)
            return
        end

        local bestMatch = nil
        local search = txt:lower()
        -- البحث عن اللاعب الذي يبدأ اسمه بالحروف المكتوبة
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= Players.LocalPlayer and string.sub(p.Name:lower(), 1, #search) == search then
                bestMatch = p
                break 
            end
        end

        if bestMatch then
            currentSelectedUser = bestMatch.Name
            SearchBox.Text = bestMatch.DisplayName .. " (@" .. bestMatch.Name .. ")"
            for _, v in pairs(DropList:GetChildren()) do
                if v:IsA("Frame") then v.BackgroundColor3 = (v.Name == currentSelectedUser) and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(40, 40, 40) end
            end
            
            if TabOps.LogAction then TabOps.LogAction("🔍 بحث وتحديد لاعب", label, "تم تحديد: " .. bestMatch.Name, 10181046) end
            pcall(callback, bestMatch)
        else
            -- إذا لم يجد اللاعب، يرجع النص العادي
            currentSelectedUser = nil
            for _, v in pairs(DropList:GetChildren()) do
                if v:IsA("Frame") then v.BackgroundColor3 = Color3.fromRGB(40, 40, 40) end
            end
            pcall(callback, txt)
        end
    end)

    -- إرجاع أدوات خارجية للتحكم بالمربع (مثل تفريغه أو تحديث القائمة)
    return { 
        SetText = function(t) SearchBox.Text = t end, 
        UpdateList = UpdateList, 
        Clear = function() 
            SearchBox.Text = "" 
            currentSelectedUser = nil 
            for _, v in pairs(DropList:GetChildren()) do
                if v:IsA("Frame") then v.BackgroundColor3 = Color3.fromRGB(40, 40, 40) end
            end
        end 
    }
end
