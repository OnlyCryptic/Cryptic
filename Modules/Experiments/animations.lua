-- [[ Cryptic Hub - Animation Changer (HumanoidDescription Master Fix) ]]
-- المطور: يامي | الوصف: الطريقة الرسمية لتغيير المشيات بدون تجميد

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local lp = Players.LocalPlayer
local StarterGui = game:GetService("StarterGui")

-- 🟢 نظام حفظ المفضلات
local FavFileName = "CrypticHub_FavoriteAnims.json"
local FavoriteAnims = {}

pcall(function()
    if isfile and isfile(FavFileName) then
        local decoded = HttpService:JSONDecode(readfile(FavFileName))
        if type(decoded) == "table" then
            FavoriteAnims = decoded
        end
    end
end)

local function SaveFavorites()
    pcall(function()
        if writefile then
            writefile(FavFileName, HttpService:JSONEncode(FavoriteAnims))
        end
    end)
end

-- ⚠️ تنبيه هام: يجب تحديث هذه الأيديات لتكون Animation IDs حقيقية (وليست Bundle IDs)
-- يمكنك استخدام كود الـ Studio الذي وجدته لاستخراج الأيديات الصحيحة وتحديث هذه القائمة
local AnimationPacks = {
    ["Community / تزحلق"]        = {idle="15640351030", walk="15640354132", run="15640359525", jump="15640356676", fall="15640352017", climb="15640355340", swim="15640362543"},
    ["Ninja / النينجا"]          = {idle="656117400",  walk="656121766",  run="656118852",  jump="656117878",  fall="656115606",  climb="656114359",  swim="656119721"},
    -- قم بتحديث باقي القائمة هنا...
}

return function(Tab, UI)
    local isToggleOn = false
    local selectedAnimData = nil
    local originalAnims = nil

    local function Notify(title, text)
        pcall(function()
            StarterGui:SetCore("SendNotification", {Title=title, Text=text, Duration=3})
        end)
    end

    -- ✅ الطريقة الصحيحة عبر HumanoidDescription
    local function ApplyAnimation(animData)
        local char = lp.Character
        if not char then return end
        
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end

        if hum.RigType == Enum.HumanoidRigType.R6 then
            Notify("تنبيه ⚠️", "المشيات تعمل على R15 فقط!")
            return
        end

        local success, desc = pcall(function() return hum:GetAppliedDescription() end)
        if not success or not desc then return end

        if not originalAnims then
            originalAnims = {
                idle  = desc.IdleAnimation,
                walk  = desc.WalkAnimation,
                run   = desc.RunAnimation,
                jump  = desc.JumpAnimation,
                fall  = desc.FallAnimation,
                climb = desc.ClimbAnimation,
                swim  = desc.SwimAnimation,
            }
        end

        desc.IdleAnimation  = tonumber(animData.idle)  or desc.IdleAnimation
        desc.WalkAnimation  = tonumber(animData.walk)  or desc.WalkAnimation
        desc.RunAnimation   = tonumber(animData.run)   or desc.RunAnimation
        desc.JumpAnimation  = tonumber(animData.jump)  or desc.JumpAnimation
        desc.FallAnimation  = tonumber(animData.fall)  or desc.FallAnimation
        desc.ClimbAnimation = tonumber(animData.climb) or desc.ClimbAnimation
        desc.SwimAnimation  = tonumber(animData.swim)  or desc.SwimAnimation

        pcall(function()
            hum:ApplyDescription(desc)
        end)
    end

    local function RestoreOriginalAnims()
        if not originalAnims then return end
        local char = lp.Character
        if not char then return end
        
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end

        local success, desc = pcall(function() return hum:GetAppliedDescription() end)
        if success and desc then
            desc.IdleAnimation  = originalAnims.idle
            desc.WalkAnimation  = originalAnims.walk
            desc.RunAnimation   = originalAnims.run
            desc.JumpAnimation  = originalAnims.jump
            desc.FallAnimation  = originalAnims.fall
            desc.ClimbAnimation = originalAnims.climb
            desc.SwimAnimation  = originalAnims.swim
            
            pcall(function()
                hum:ApplyDescription(desc)
            end)
        end
        originalAnims = nil
    end

    -- ==========================================
    -- واجهة المستخدم (UI)
    -- ==========================================
    local function AddAdvancedDropdown(tabRef, title, options, callback)
        tabRef.Order = tabRef.Order + 1
        
        local Container = Instance.new("Frame", tabRef.Page)
        Container.LayoutOrder = tabRef.Order
        Container.Size = UDim2.new(0.95, 0, 0, 40)
        Container.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        Container.ClipsDescendants = true
        Instance.new("UICorner", Container)
        
        local MainBtn = Instance.new("TextButton", Container)
        MainBtn.Size = UDim2.new(1, 0, 0, 40)
        MainBtn.BackgroundTransparency = 1
        MainBtn.Text = "▼ " .. title
        MainBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
        MainBtn.Font = Enum.Font.GothamBold
        MainBtn.TextSize = 13

        local SearchBox = Instance.new("TextBox", Container)
        SearchBox.Size = UDim2.new(0.9, 0, 0, 30)
        SearchBox.Position = UDim2.new(0.05, 0, 0, 45)
        SearchBox.Text = "" 
        SearchBox.PlaceholderText = "بحث / Search" 
        SearchBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        SearchBox.TextColor3 = Color3.new(1, 1, 1)
        SearchBox.ClearTextOnFocus = false
        Instance.new("UICorner", SearchBox)

        local ListFrame = Instance.new("ScrollingFrame", Container)
        ListFrame.Size = UDim2.new(0.9, 0, 0, 130)
        ListFrame.Position = UDim2.new(0.05, 0, 0, 80)
        ListFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        ListFrame.ScrollBarThickness = 2
        Instance.new("UICorner", ListFrame)
        
        local ListLayout = Instance.new("UIListLayout", ListFrame)
        ListLayout.Padding = UDim.new(0, 5)
        ListLayout.SortOrder = Enum.SortOrder.LayoutOrder 

        local isOpen = false
        local optionItems = {}

        local function UpdateListDisplay()
            local searchText = SearchBox.Text:lower()
            for _, item in ipairs(optionItems) do
                local isFav = FavoriteAnims[item.RealName]
                local matchSearch = (searchText == "" or string.find(item.LowerName, searchText) ~= nil)
                
                item.Frame.Visible = matchSearch
                item.Frame.LayoutOrder = isFav and 1 or 2 
                item.StarBtn.Text = isFav and "⭐" or "☆"
                item.StarBtn.TextColor3 = isFav and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(150, 150, 150)
            end
        end

        for optName, data in pairs(options) do
            local ItemFrame = Instance.new("Frame", ListFrame)
            ItemFrame.Size = UDim2.new(1, -10, 0, 30)
            ItemFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            Instance.new("UICorner", ItemFrame)
            
            local SelectBtn = Instance.new("TextButton", ItemFrame)
            SelectBtn.Size = UDim2.new(0.85, 0, 1, 0)
            SelectBtn.BackgroundTransparency = 1
            SelectBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
            SelectBtn.Text = "  " .. optName
            SelectBtn.TextXAlignment = Enum.TextXAlignment.Left

            local StarBtn = Instance.new("TextButton", ItemFrame)
            StarBtn.Size = UDim2.new(0.15, 0, 1, 0)
            StarBtn.Position = UDim2.new(0.85, 0, 0, 0)
            StarBtn.BackgroundTransparency = 1
            StarBtn.Text = "☆"
            StarBtn.TextSize = 16

            table.insert(optionItems, {
                Frame = ItemFrame, SelectBtn = SelectBtn, StarBtn = StarBtn, 
                RealName = optName, LowerName = optName:lower()
            })

            SelectBtn.MouseButton1Click:Connect(function()
                MainBtn.Text = "▼ محدد: " .. optName
                isOpen = false
                Container.Size = UDim2.new(0.95, 0, 0, 40)
                callback(optName, data)
            end)

            StarBtn.MouseButton1Click:Connect(function()
                FavoriteAnims[optName] = FavoriteAnims[optName] and nil or true
                SaveFavorites()
                UpdateListDisplay() 
            end)
        end

        UpdateListDisplay() 

        ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            ListFrame.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 10)
        end)

        MainBtn.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            Container.Size = isOpen and UDim2.new(0.95, 0, 0, 220) or UDim2.new(0.95, 0, 0, 40)
            MainBtn.Text = (isOpen and "▲ " or "▼ ") .. (selectedAnimData and "محدد: " or title)
        end)

        SearchBox:GetPropertyChangedSignal("Text"):Connect(UpdateListDisplay)
    end

    -- ==========================================
    -- ربط الأزرار
    -- ==========================================
    AddAdvancedDropdown(Tab, "اختر مشية / Select Animation", AnimationPacks, function(name, data)
        selectedAnimData = data
        if isToggleOn then
            ApplyAnimation(data)
            Notify("نجاح / Success 🏃‍♂️", "تم تغيير المشية إلى / Changed to:\n" .. name)
        end
    end)

    Tab:AddToggle("تفعيل المشية / Toggle Animation", function(state)
        isToggleOn = state
        if state then
            if not selectedAnimData then
                Notify("تنبيه ⚠️", "يرجى اختيار مشية من القائمة أولاً!")
                return
            end
            ApplyAnimation(selectedAnimData)
        else
            RestoreOriginalAnims()
        end
    end)

    lp.CharacterAdded:Connect(function(char)
        originalAnims = nil 
        task.delay(1, function()
            local hum = char:WaitForChild("Humanoid", 5)
            if not hum or hum.Health <= 0 then return end
            if isToggleOn and selectedAnimData then
                ApplyAnimation(selectedAnimData)
            end
        end)
    end)
    
    Tab:AddLine()
end
