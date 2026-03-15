-- [[ Cryptic Hub - نظام الانتقال المتقدم (Clean UI Version) ]]
-- المطور: يامي | الوصف: تصميم مبسط، اسم بالمنتصف، زر ❌ مصغر، وانتقال مرتب

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local lp = Players.LocalPlayer
local StarterGui = game:GetService("StarterGui")

local FileName = "Cryptic_TP_" .. game.PlaceId .. ".json"
local locations = {} 
local TPMethod = "انتقال فوري | Instant"
local currentSelectedLocation = nil

return function(Tab, UI)
    -- ==========================================
    -- دوال الإشعارات وحفظ/تحميل البيانات
    -- ==========================================
    local function Notify(title, text)
        pcall(function() StarterGui:SetCore("SendNotification", {Title=title, Text=text, Duration=3}) end)
    end

    local function LoadData()
        if isfile and isfile(FileName) then
            pcall(function() locations = HttpService:JSONDecode(readfile(FileName)) end)
        end
    end

    local function SaveData()
        if writefile then pcall(function() writefile(FileName, HttpService:JSONEncode(locations)) end) end
    end

    LoadData()

    -- ==========================================
    -- دالة الانتقال
    -- ==========================================
    local function TeleportTo(locName)
        local locData = locations[locName]
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
    -- إعدادات طريقة الانتقال
    -- ==========================================
    Tab:AddDropdown("طريقة الانتقال | TP Method", {"انتقال فوري | Instant", "طيران سريع | Fly (Tween)"}, function(selected)
        TPMethod = selected
        Notify("Cryptic Hub 🚀", "تم تغيير طريقة الانتقال إلى / Changed to:\n" .. selected)
    end)
    Tab:AddLine()

    -- ==========================================
    -- بناء القائمة الاحترافية المبسطة
    -- ==========================================
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
            local matchSearch = (searchText == "" or string.find(item.LowerName, searchText) ~= nil)
            item.Frame.Visible = matchSearch
        end
    end

    local function RebuildDropdown()
        for _, item in ipairs(optionItems) do item.Frame:Destroy() end
        optionItems = {}
        
        -- ترتيب الأسماء أبجدياً ليكون الشكل أرتب
        local sortedNames = {}
        for locName, _ in pairs(locations) do table.insert(sortedNames, locName) end
        table.sort(sortedNames)

        local hasLocations = #sortedNames > 0

        for _, locName in ipairs(sortedNames) do
            local ItemFrame = Instance.new("Frame", ListFrame)
            ItemFrame.Size = UDim2.new(1, -10, 0, 30)
            ItemFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            Instance.new("UICorner", ItemFrame)
            
            -- زر اختيار الاسم (موسّط ويأخذ 85% من المساحة)
            local SelectBtn = Instance.new("TextButton", ItemFrame)
            SelectBtn.Size = UDim2.new(0.85, 0, 1, 0)
            SelectBtn.BackgroundTransparency = 1
            SelectBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
            SelectBtn.Text = locName
            SelectBtn.TextXAlignment = Enum.TextXAlignment.Center -- 🔴 الاسم في المنتصف

            -- زر الحذف ❌ (مصغر ويأخذ 15% من المساحة في الزاوية)
            local DeleteBtn = Instance.new("TextButton", ItemFrame)
            DeleteBtn.Size = UDim2.new(0.15, 0, 1, 0)
            DeleteBtn.Position = UDim2.new(0.85, 0, 0, 0)
            DeleteBtn.BackgroundTransparency = 1
            DeleteBtn.Text = "❌"
            DeleteBtn.TextSize = 10 -- 🔴 حجم مصغر وأنيق
            DeleteBtn.TextColor3 = Color3.fromRGB(255, 70, 70)

            table.insert(optionItems, {Frame = ItemFrame, Name = locName, LowerName = locName:lower(), SelectBtn = SelectBtn})

            SelectBtn.MouseButton1Click:Connect(function()
                MainBtn.Text = "▼ " .. locName
                currentSelectedLocation = locName
                isOpen = false
                DropdownContainer.Size = UDim2.new(0.95, 0, 0, 40)
            end)

            DeleteBtn.MouseButton1Click:Connect(function()
                locations[locName] = nil
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
        elseif currentSelectedLocation and not locations[currentSelectedLocation] then
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
    -- زر الانتقال العادي (أسفل القائمة)
    -- ==========================================
    Tab:AddButton("🚀 انتقال إلى المكان المحدد | Teleport to Selected", function()
        if not currentSelectedLocation then
            Notify("تنبيه | Alert ⚠️", "الرجاء اختيار مكان من القائمة أولاً!\nPlease select a location first!")
            return
        end
        TeleportTo(currentSelectedLocation)
    end)
    Tab:AddLine()

    -- ==========================================
    -- قسم إضافة مكان جديد
    -- ==========================================
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
        locations[locationNameInput] = {x = pos.X, y = pos.Y, z = pos.Z}
        SaveData()
        
        RebuildDropdown() 
        Notify("نجاح | Success ✅", "تم حفظ الإحداثيات / Saved:\n" .. locationNameInput)
    end)
    
    Tab:AddLine()
end
