-- [[ Cryptic Hub - نظام الانتقال المتقدم (Clean V4) ]]
-- المطور: يامي | الوصف: انتقال سريع (🚀)، مفضلة (⭐)، حذف (❌) + دمج الحفظ لمنع التكرار

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local lp = Players.LocalPlayer
local StarterGui = game:GetService("StarterGui")

-- 🟢 دمجنا ملفات الحفظ في ملف واحد ذكي لمنع التكرار!
local FileName = "Cryptic_TP_Data_" .. game.PlaceId .. ".json"
local tpData = { Locs = {}, Favs = {} } 
local TPMethod = "انتقال فوري | Instant"
local currentSelectedLocation = nil

return function(Tab, UI)
    -- ==========================================
    -- دوال الإشعارات وحفظ/تحميل البيانات الذكية
    -- ==========================================
    local function Notify(title, text)
        pcall(function() StarterGui:SetCore("SendNotification", {Title=title, Text=text, Duration=3}) end)
    end

    local function LoadData()
        if isfile and isfile(FileName) then
            pcall(function() tpData = HttpService:JSONDecode(readfile(FileName)) end)
            tpData.Locs = tpData.Locs or {}
            tpData.Favs = tpData.Favs or {}
        end
    end

    local function SaveData()
        if writefile then pcall(function() writefile(FileName, HttpService:JSONEncode(tpData)) end) end
    end

    LoadData()

    -- ==========================================
    -- دالة الانتقال
    -- ==========================================
    local function TeleportTo(locName)
        local locData = tpData.Locs[locName]
        local char = lp.Character
        if not locData or not char or not char:FindFirstChild("HumanoidRootPart") then return end
        
        local targetCFrame = CFrame.new(locData.x, locData.y, locData.z)
        local rootPart = char.HumanoidRootPart
        
        if TPMethod == "انتقال فوري | Instant" then
            rootPart.CFrame = targetCFrame
            Notify("نجاح | Success 🚀", "تم الانتقال إلى / Teleported to:\n" .. locName)
        else
            local dist = (rootPart.Position - targetCFrame.Position).Magnitude
            local tweenTime = dist / 150 
            local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Linear)
            TweenService:Create(rootPart, tweenInfo, {CFrame = targetCFrame}):Play()
            Notify("نجاح | Success 🛸", "جاري الطيران إلى / Flying to:\n" .. locName)
        end
    end

    -- ==========================================
    -- واجهة المستخدم الرئيسية (بدون تكرارات)
    -- ==========================================
    Tab:AddDropdown("طريقة الانتقال | TP Method", {"انتقال فوري | Instant", "طيران سريع | Fly (Tween)"}, function(selected)
        TPMethod = selected
        Notify("Cryptic Hub 🚀", "تم تغيير طريقة الانتقال إلى / Changed to:\n" .. selected)
    end)
    Tab:AddLine()

    local DropdownContainer = Instance.new("Frame", Tab.Page)
    DropdownContainer.LayoutOrder = Tab.Order + 1
    Tab.Order = Tab.Order + 1
    DropdownContainer.Size = UDim2.new(0.95, 0, 0, 40)
    DropdownContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    DropdownContainer.ClipsDescendants = true
    Instance.new("UICorner", DropdownContainer)
    
    local MainBtn = Instance.new("TextButton", DropdownContainer)
    MainBtn.Size = UDim2.new(1, 0, 0, 40)
    MainBtn.BackgroundTransparency = 1
    MainBtn.Text = "▼ اختر مكان للانتقال | Select TP Location"
    MainBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
    MainBtn.Font = Enum.Font.GothamBold
    MainBtn.TextSize = 13

    local SearchBox = Instance.new("TextBox", DropdownContainer)
    SearchBox.Size = UDim2.new(0.9, 0, 0, 30)
    SearchBox.Position = UDim2.new(0.05, 0, 0, 45)
    SearchBox.Text = ""
    SearchBox.PlaceholderText = "بحث عن مكان / Search Location"
    SearchBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    SearchBox.TextColor3 = Color3.new(1, 1, 1)
    SearchBox.ClearTextOnFocus = false
    Instance.new("UICorner", SearchBox)

    local ListFrame = Instance.new("ScrollingFrame", DropdownContainer)
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
            local isFav = tpData.Favs[item.Name]
            local matchSearch = (searchText == "" or string.find(item.LowerName, searchText) ~= nil)
            
            item.Frame.Visible = matchSearch
            item.Frame.LayoutOrder = isFav and 1 or 2 
            item.StarBtn.Text = isFav and "⭐" or "☆"
            item.StarBtn.TextColor3 = isFav and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(150, 150, 150)
        end
    end

    local function RebuildDropdown()
        for _, item in ipairs(optionItems) do item.Frame:Destroy() end
        optionItems = {}
        
        local hasLocations = false
        for locName, _ in pairs(tpData.Locs) do
            hasLocations = true
            local ItemFrame = Instance.new("Frame", ListFrame)
            ItemFrame.Size = UDim2.new(1, -10, 0, 30)
            ItemFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            Instance.new("UICorner", ItemFrame)
            
            local SelectBtn = Instance.new("TextButton", ItemFrame)
            SelectBtn.Size = UDim2.new(0.55, 0, 1, 0)
            SelectBtn.BackgroundTransparency = 1
            SelectBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
            SelectBtn.Text = "  " .. locName
            SelectBtn.TextXAlignment = Enum.TextXAlignment.Left

            local TpBtn = Instance.new("TextButton", ItemFrame)
            TpBtn.Size = UDim2.new(0.15, 0, 1, 0)
            TpBtn.Position = UDim2.new(0.55, 0, 0, 0)
            TpBtn.BackgroundTransparency = 1
            TpBtn.Text = "🚀"
            TpBtn.TextSize = 14

            local StarBtn = Instance.new("TextButton", ItemFrame)
            StarBtn.Size = UDim2.new(0.15, 0, 1, 0)
            StarBtn.Position = UDim2.new(0.70, 0, 0, 0)
            StarBtn.BackgroundTransparency = 1
            StarBtn.Text = "☆"
            StarBtn.TextSize = 16

            local DeleteBtn = Instance.new("TextButton", ItemFrame)
            DeleteBtn.Size = UDim2.new(0.15, 0, 1, 0)
            DeleteBtn.Position = UDim2.new(0.85, 0, 0, 0)
            DeleteBtn.BackgroundTransparency = 1
            DeleteBtn.Text = "❌"
            DeleteBtn.TextSize = 12
            DeleteBtn.TextColor3 = Color3.fromRGB(255, 50, 50)

            table.insert(optionItems, {Frame = ItemFrame, Name = locName, LowerName = locName:lower(), SelectBtn = SelectBtn, StarBtn = StarBtn})

            SelectBtn.MouseButton1Click:Connect(function()
                MainBtn.Text = "▼ " .. locName
                currentSelectedLocation = locName
                isOpen = false
                DropdownContainer.Size = UDim2.new(0.95, 0, 0, 40)
            end)

            TpBtn.MouseButton1Click:Connect(function()
                TeleportTo(locName)
                isOpen = false
                DropdownContainer.Size = UDim2.new(0.95, 0, 0, 40)
            end)

            StarBtn.MouseButton1Click:Connect(function()
                tpData.Favs[locName] = tpData.Favs[locName] and nil or true
                SaveData()
                UpdateListDisplay()
            end)

            DeleteBtn.MouseButton1Click:Connect(function()
                tpData.Locs[locName] = nil
                tpData.Favs[locName] = nil
                SaveData()
                
                if currentSelectedLocation == locName then
                    currentSelectedLocation = nil
                    MainBtn.Text = "▼ اختر مكان للانتقال | Select TP Location"
                end
                
                RebuildDropdown()
                Notify("تم الحذف | Deleted 🗑️", "تم حذف المكان / Deleted:\n" .. locName)
            end)
        end

        if not hasLocations then
            MainBtn.Text = "▼ لا توجد أماكن محفوظة | No saved locations"
            currentSelectedLocation = nil
        elseif currentSelectedLocation and not tpData.Locs[currentSelectedLocation] then
            MainBtn.Text = "▼ اختر مكان للانتقال | Select TP Location"
            currentSelectedLocation = nil
        end
        UpdateListDisplay()
    end

    RebuildDropdown()

    ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ListFrame.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 10)
    end)

    MainBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        DropdownContainer.Size = isOpen and UDim2.new(0.95, 0, 0, 220) or UDim2.new(0.95, 0, 0, 40)
    end)

    SearchBox:GetPropertyChangedSignal("Text"):Connect(UpdateListDisplay)

    -- ==========================================
    -- قسم حفظ الأماكن الجديدة (تم مسح الزر المكرر)
    -- ==========================================
    Tab:AddLine()
    
    local locationNameInput = ""
    Tab:AddInput("اسم المكان الجديد | New Location Name", "اكتب اسم المكان... | Type name...", function(text)
        locationNameInput = text
    end)

    Tab:AddButton("📍 حفظ موقعي الحالي | Save Current Position", function()
        if locationNameInput == "" then 
            Notify("تنبيه | Alert ⚠️", "اكتب اسم المكان أولاً! | Type name first!")
            return 
        end
        
        local char = lp.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        
        local pos = char.HumanoidRootPart.CFrame
        tpData.Locs[locationNameInput] = {x = pos.X, y = pos.Y, z = pos.Z}
        SaveData()
        
        RebuildDropdown() 
        Notify("نجاح | Success ✅", "تم حفظ الإحداثيات / Saved:\n" .. locationNameInput)
    end)
    
    Tab:AddButton("🗑️ مسح كل أماكن هذا الماب | Clear All Locations", function()
        if isfile and isfile(FileName) then delfile(FileName) end
        tpData = { Locs = {}, Favs = {} }
        RebuildDropdown()
        Notify("تم المسح | Cleared 🗑️", "تم مسح جميع الأماكن والمفضلات!\nAll locations cleared!")
    end)
    Tab:AddLine()
end
