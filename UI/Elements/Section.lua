-- [[ Cryptic Hub - Element: Section (Collapsible) ]]
-- الاستخدام: tab:AddSection("اسم السكشن", function(section) section:AddButton(...) end)
-- يشتغل مع Core.lua V8.5 بدون أي تعديل

return function(TabOps, label, buildFunc)

    local TweenService = game:GetService("TweenService")
    local function CreateTween(instance, properties, duration)
        local tween = TweenService:Create(instance, TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), properties)
        tween:Play()
        return tween
    end

    local Page = TabOps.Page

    -- الـ Container الرئيسي للسكشن كله
    local SectionContainer = Instance.new("Frame")
    SectionContainer.Name = "Section_" .. label
    SectionContainer.Size = UDim2.new(1, 0, 0, 36) -- الحجم الافتراضي (مغلق)
    SectionContainer.BackgroundTransparency = 1
    SectionContainer.ClipsDescendants = true
    SectionContainer.LayoutOrder = TabOps.Order or 0
    TabOps.Order = (TabOps.Order or 0) + 1
    SectionContainer.Parent = Page

    -- زر الهيدر (اللي تضغط عليه)
    local Header = Instance.new("TextButton")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 34)
    Header.Position = UDim2.new(0, 0, 0, 0)
    Header.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    Header.BackgroundTransparency = 0.2
    Header.BorderSizePixel = 0
    Header.Text = ""
    Header.AutoButtonColor = false
    Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 8)

    -- بوردر للهيدر
    local HeaderStroke = Instance.new("UIStroke", Header)
    HeaderStroke.Thickness = 1
    HeaderStroke.Transparency = 0.5
    local HeaderGradient = Instance.new("UIGradient", HeaderStroke)
    HeaderGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 150)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 150, 255))
    }

    -- نص العنوان
    local TitleLabel = Instance.new("TextLabel", Header)
    TitleLabel.Text = label
    TitleLabel.Size = UDim2.new(1, -50, 1, 0)
    TitleLabel.Position = UDim2.new(0, 12, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Font = Enum.Font.GothamSemibold
    TitleLabel.TextSize = 12

    -- سهم الفتح/الإغلاق
    local Arrow = Instance.new("TextLabel", Header)
    Arrow.Text = "▶"
    Arrow.Size = UDim2.new(0, 30, 1, 0)
    Arrow.Position = UDim2.new(1, -38, 0, 0)
    Arrow.BackgroundTransparency = 1
    Arrow.TextColor3 = Color3.fromRGB(0, 255, 150)
    Arrow.Font = Enum.Font.GothamBold
    Arrow.TextSize = 11

    -- شريط لوني صغير على اليسار
    local SideBar = Instance.new("Frame", Header)
    SideBar.Size = UDim2.new(0, 3, 0.6, 0)
    SideBar.Position = UDim2.new(0, 0, 0.2, 0)
    SideBar.BorderSizePixel = 0
    SideBar.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
    Instance.new("UICorner", SideBar).CornerRadius = UDim.new(1, 0)

    Header.Parent = SectionContainer

    -- الـ Body (المحتوى الداخلي)
    local Body = Instance.new("Frame", SectionContainer)
    Body.Name = "Body"
    Body.Size = UDim2.new(1, 0, 0, 0) -- يتحسب لاحقاً
    Body.Position = UDim2.new(0, 0, 0, 38)
    Body.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
    Body.BackgroundTransparency = 0.4
    Body.BorderSizePixel = 0
    Body.ClipsDescendants = true
    Body.Visible = false
    Instance.new("UICorner", Body).CornerRadius = UDim.new(0, 8)

    -- بوردر للبودي
    local BodyStroke = Instance.new("UIStroke", Body)
    BodyStroke.Thickness = 1
    BodyStroke.Transparency = 0.7
    local BodyGradient = Instance.new("UIGradient", BodyStroke)
    BodyGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 150)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 150, 255))
    }

    local BodyLayout = Instance.new("UIListLayout", Body)
    BodyLayout.Padding = UDim.new(0, 8)
    BodyLayout.SortOrder = Enum.SortOrder.LayoutOrder
    BodyLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local BodyPadding = Instance.new("UIPadding", Body)
    BodyPadding.PaddingTop = UDim.new(0, 8)
    BodyPadding.PaddingBottom = UDim.new(0, 8)
    BodyPadding.PaddingLeft = UDim.new(0, 6)
    BodyPadding.PaddingRight = UDim.new(0, 6)

    -- حساب الحجم الديناميكي للبودي
    local function UpdateBodySize()
        local contentH = BodyLayout.AbsoluteContentSize.Y + 16
        Body.Size = UDim2.new(1, 0, 0, contentH)
        return contentH
    end

    BodyLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if Body.Visible then
            local h = UpdateBodySize()
            SectionContainer.Size = UDim2.new(1, 0, 0, 38 + h + 6)
        end
    end)

    -- حالة الفتح/الإغلاق
    local isOpen = false

    Header.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            -- فتح
            Body.Visible = true
            local h = UpdateBodySize()
            CreateTween(SectionContainer, {Size = UDim2.new(1, 0, 0, 38 + h + 6)}, 0.25)
            CreateTween(Arrow, {Rotation = 90}, 0.2)
            CreateTween(TitleLabel, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
            CreateTween(Header, {BackgroundTransparency = 0}, 0.2)
        else
            -- إغلاق
            CreateTween(SectionContainer, {Size = UDim2.new(1, 0, 0, 36)}, 0.25)
            CreateTween(Arrow, {Rotation = 0}, 0.2)
            CreateTween(TitleLabel, {TextColor3 = Color3.fromRGB(200, 200, 200)}, 0.2)
            CreateTween(Header, {BackgroundTransparency = 0.2}, 0.2)
            task.delay(0.25, function() if not isOpen then Body.Visible = false end end)
        end
    end)

    Header.MouseEnter:Connect(function()
        if not isOpen then CreateTween(Header, {BackgroundTransparency = 0.05}, 0.15) end
    end)
    Header.MouseLeave:Connect(function()
        if not isOpen then CreateTween(Header, {BackgroundTransparency = 0.2}, 0.15) end
    end)

    -- ======================================================
    -- SectionOps: نفس دوال TabOps بس تضيف داخل البودي
    -- ======================================================
    local SectionOps = {
        Order = 0,
        Page = Body,           -- العناصر تتضاف للبودي مباشرة
        TabName = TabOps.TabName,
        LogAction = TabOps.LogAction,
        UI = TabOps.UI
    }

    -- نسخ كل الدوال الموجودة في TabOps للسكشن
    -- (Button, Toggle, TimedToggle, Input, etc.)
    local elementNames = {
        "Button", "Toggle", "TimedToggle", "Input", "LargeInput",
        "SpeedControl", "Dropdown", "PlayerSelector", "ProfileCard",
        "Line", "Label", "Paragraph"
    }

    for _, elName in ipairs(elementNames) do
        -- نسخ الدالة من TabOps لو موجودة
        if TabOps["Add" .. elName] then
            SectionOps["Add" .. elName] = function(self, ...)
                -- تبديل مؤقت للـ Page عشان العنصر يتضاف للبودي
                local originalPage = TabOps.Page
                local originalOrder = TabOps.Order
                TabOps.Page = Body
                TabOps.Order = self.Order
                local result = TabOps["Add" .. elName](TabOps, ...)
                self.Order = TabOps.Order
                TabOps.Page = originalPage
                TabOps.Order = originalOrder
                return result
            end
        end
    end

    -- دالة AddLine مخصصة للسكشن
    function SectionOps:AddLine()
        local Line = Instance.new("Frame")
        Line.Size = UDim2.new(0.95, 0, 0, 1)
        Line.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        Line.BorderSizePixel = 0
        Line.LayoutOrder = self.Order
        self.Order = self.Order + 1
        Line.Parent = Body
    end

    -- تشغيل الـ buildFunc اللي يضيف العناصر
    if type(buildFunc) == "function" then
        pcall(function()
            buildFunc(SectionOps)
        end)
    end

    return SectionOps
end
