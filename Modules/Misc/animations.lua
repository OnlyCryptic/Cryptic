-- [[ Cryptic Hub - ميزة تغيير المشيات (Searchable Dropdown + Server Replicated) ]]
-- المطور: يامي | الوصف: قائمة بحث ذكية لاختيار مشيات تظهر لجميع اللاعبين

local Players = game:GetService("Players")
local lp = Players.LocalPlayer

-- مكتبة أشهر مشيات روبلوكس (مع الأكواد الرسمية لكل حركة)
local AnimationPacks = {
    ["Ninja / النينجا"] = {
        idle = "http://www.roblox.com/asset/?id=656117400",
        walk = "http://www.roblox.com/asset/?id=656121766",
        run = "http://www.roblox.com/asset/?id=656118852",
        jump = "http://www.roblox.com/asset/?id=656117878",
        fall = "http://www.roblox.com/asset/?id=656117606",
        climb = "http://www.roblox.com/asset/?id=656114359",
        swim = "http://www.roblox.com/asset/?id=656121397"
    },
    ["Zombie / الزومبي"] = {
        idle = "http://www.roblox.com/asset/?id=616158929",
        walk = "http://www.roblox.com/asset/?id=616168032",
        run = "http://www.roblox.com/asset/?id=616163682",
        jump = "http://www.roblox.com/asset/?id=616161748",
        fall = "http://www.roblox.com/asset/?id=616157476",
        climb = "http://www.roblox.com/asset/?id=616156119",
        swim = "http://www.roblox.com/asset/?id=616165109"
    },
    ["Superhero / البطل الخارق"] = {
        idle = "http://www.roblox.com/asset/?id=782841498",
        walk = "http://www.roblox.com/asset/?id=782843345",
        run = "http://www.roblox.com/asset/?id=782842708",
        jump = "http://www.roblox.com/asset/?id=782842230",
        fall = "http://www.roblox.com/asset/?id=782842046",
        climb = "http://www.roblox.com/asset/?id=782841270",
        swim = "http://www.roblox.com/asset/?id=782843136"
    },
    ["Mage / الساحر"] = {
        idle = "http://www.roblox.com/asset/?id=1084999930",
        walk = "http://www.roblox.com/asset/?id=1085001851",
        run = "http://www.roblox.com/asset/?id=1085001188",
        jump = "http://www.roblox.com/asset/?id=1085000438",
        fall = "http://www.roblox.com/asset/?id=1085000213",
        climb = "http://www.roblox.com/asset/?id=1084999554",
        swim = "http://www.roblox.com/asset/?id=1085001603"
    },
    ["Robot / الروبوت"] = {
        idle = "http://www.roblox.com/asset/?id=616089559",
        walk = "http://www.roblox.com/asset/?id=616095330",
        run = "http://www.roblox.com/asset/?id=616091901",
        jump = "http://www.roblox.com/asset/?id=616090535",
        fall = "http://www.roblox.com/asset/?id=616088211",
        climb = "http://www.roblox.com/asset/?id=616087119",
        swim = "http://www.roblox.com/asset/?id=616094499"
    }
}

return function(Tab, UI)
    Tab:AddParagraph("تغيير المشية / Animation Changer", "المشية تظهر لجميع اللاعبين في السيرفر!")

    -- ==========================================
    -- دالة بناء الدروب داون مع البحث الذكي
    -- ==========================================
    local function AddSearchableDropdown(tabRef, title, options, callback)
        tabRef.Order = tabRef.Order + 1
        
        -- الحاوية الرئيسية
        local Container = Instance.new("Frame", tabRef.Page)
        Container.LayoutOrder = tabRef.Order
        Container.Size = UDim2.new(0.95, 0, 0, 40)
        Container.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        Container.ClipsDescendants = true
        Instance.new("UICorner", Container)
        
        -- زر فتح/إغلاق القائمة
        local MainBtn = Instance.new("TextButton", Container)
        MainBtn.Size = UDim2.new(1, 0, 0, 40)
        MainBtn.BackgroundTransparency = 1
        MainBtn.Text = "▼ " .. title
        MainBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
        MainBtn.Font = Enum.Font.GothamBold
        MainBtn.TextSize = 14

        -- مربع البحث (مخفي بالبداية)
        local SearchBox = Instance.new("TextBox", Container)
        SearchBox.Size = UDim2.new(0.9, 0, 0, 30)
        SearchBox.Position = UDim2.new(0.05, 0, 0, 45)
        SearchBox.PlaceholderText = "🔍 ابحث عن المشية..."
        SearchBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        SearchBox.TextColor3 = Color3.new(1, 1, 1)
        Instance.new("UICorner", SearchBox)

        -- قائمة الخيارات
        local ListFrame = Instance.new("ScrollingFrame", Container)
        ListFrame.Size = UDim2.new(0.9, 0, 0, 120)
        ListFrame.Position = UDim2.new(0.05, 0, 0, 80)
        ListFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        ListFrame.ScrollBarThickness = 2
        Instance.new("UICorner", ListFrame)
        
        local ListLayout = Instance.new("UIListLayout", ListFrame)
        ListLayout.Padding = UDim.new(0, 5)

        local isOpen = false
        local optionButtons = {}

        -- دالة إنشاء الأزرار داخل القائمة
        for optName, _ in pairs(options) do
            local btn = Instance.new("TextButton", ListFrame)
            btn.Size = UDim2.new(1, -10, 0, 30)
            btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            btn.TextColor3 = Color3.fromRGB(200, 200, 200)
            btn.Text = optName
            Instance.new("UICorner", btn)
            
            table.insert(optionButtons, {Button = btn, Name = optName:lower()})

            btn.MouseButton1Click:Connect(function()
                MainBtn.Text = "▼ " .. optName
                isOpen = false
                Container.Size = UDim2.new(0.95, 0, 0, 40)
                callback(optName, options[optName])
            end)
        end

        ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            ListFrame.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 10)
        end)

        -- حركة الفتح والإغلاق
        MainBtn.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            if isOpen then
                Container.Size = UDim2.new(0.95, 0, 0, 210)
                MainBtn.Text = "▲ " .. title
            else
                Container.Size = UDim2.new(0.95, 0, 0, 40)
                MainBtn.Text = "▼ " .. title
            end
        end)

        -- 🟢 نظام الفلترة والبحث الذكي
        SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
            local searchText = SearchBox.Text:lower()
            for _, item in ipairs(optionButtons) do
                if searchText == "" or string.find(item.Name, searchText) then
                    item.Button.Visible = true
                else
                    item.Button.Visible = false
                end
            end
        end)
    end

    -- ==========================================
    -- دالة تطبيق المشية على اللاعب
    -- ==========================================
    local function ApplyAnimation(packName, animData)
        local char = lp.Character
        if not char then return end
        
        local animateScript = char:FindFirstChild("Animate")
        if not animateScript then
            game:GetService("StarterGui"):SetCore("SendNotification", { Title = "Cryptic Hub", Text = "❌ لم يتم العثور على سكربت الحركة!", Duration = 3 })
            return
        end

        -- استبدال الأكواد داخل سكربت الحركة الخاص بك
        pcall(function()
            animateScript.idle.Animation1.AnimationId = animData.idle
            animateScript.idle.Animation2.AnimationId = animData.idle
            animateScript.walk.WalkAnim.AnimationId = animData.walk
            animateScript.run.RunAnim.AnimationId = animData.run
            animateScript.jump.JumpAnim.AnimationId = animData.jump
            animateScript.fall.FallAnim.AnimationId = animData.fall
            animateScript.climb.ClimbAnim.AnimationId = animData.climb
            animateScript.swim.Swim.AnimationId = animData.swim
            
            -- 🟢 السر لكي تتفعل فوراً وتظهر للجميع: إطفاء وتشغيل سكربت الحركة!
            animateScript.Disabled = true
            task.wait(0.1)
            animateScript.Disabled = false
            
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Cryptic Hub 🏃‍♂️",
                Text = "✅ تم تفعيل مشية [" .. packName .. "] للجميع!",
                Duration = 4
            })
        end)
    end

    -- استدعاء الدروب داون وربطها بالدالة
    AddSearchableDropdown(Tab, "اختر مشية / Select Animation", AnimationPacks, ApplyAnimation)

    Tab:AddLine()
end
