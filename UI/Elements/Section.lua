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
    SectionContainer.Size = UDim2.new(1, 0, 0, 40) -- الحجم الافتراضي (مغلق)
    SectionContainer.BackgroundTransparency = 1
    SectionContainer.ClipsDescendants = true
    SectionContainer.LayoutOrder = TabOps.Order or 0
    TabOps.Order = (TabOps.Order or 0) + 1
    SectionContainer.Parent = Page

    -- زر الهيدر (اللي تضغط عليه)
    local Header = Instance.new("TextButton")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 38)
    Header.Position = UDim2.new(0, 0, 0, 0)
    Header.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    Header.BackgroundTransparency = 0.1
    Header.BorderSizePixel = 0
    Header.Text = ""
    Header.AutoButtonColor = false
    Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 9)

    -- بوردر (خفي بالبداية، يضيء عند الفتح)
    local HeaderStroke = Instance.new("UIStroke", Header)
    HeaderStroke.Thickness = 1.2
    HeaderStroke.Transparency = 0.85
    local HeaderGradient = Instance.new("UIGradient", HeaderStroke)
    HeaderGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 150)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 150, 255))
    }

    -- دائرة مؤشر على اليسار (رمادية مغلق، خضراء مفتوح)
    local Dot = Instance.new("Frame", Header)
    Dot.Size = UDim2.new(0, 7, 0, 7)
    Dot.Position = UDim2.new(0, 12, 0.5, -3)
    Dot.BorderSizePixel = 0
    Dot.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
    Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)

    -- نص العنوان (منتصف)
    local TitleLabel = Instance.new("TextLabel", Header)
    TitleLabel.Text = label
    TitleLabel.Size = UDim2.new(1, -60, 1, 0)
    TitleLabel.Position = UDim2.new(0, 26, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.TextColor3 = Color3.fromRGB(165, 165, 180)
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Center
    TitleLabel.Font = Enum.Font.GothamSemibold
    TitleLabel.TextSize = 12

    -- خلفية السهم
    local ArrowBg = Instance.new("Frame", Header)
    ArrowBg.Size = UDim2.new(0, 22, 0, 22)
    ArrowBg.Position = UDim2.new(1, -32, 0.5, -11)
    ArrowBg.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
    ArrowBg.BackgroundTransparency = 0.2
    ArrowBg.BorderSizePixel = 0
    Instance.new("UICorner", ArrowBg).CornerRadius = UDim.new(0, 6)

    -- السهم نفسه (› أوضح من ▶)
    local Arrow = Instance.new("TextLabel", ArrowBg)
    Arrow.Text = "›"
    Arrow.Size = UDim2.new(1, 0, 1, 2)
    Arrow.Position = UDim2.new(0, 0, 0, 0)
    Arrow.BackgroundTransparency = 1
    Arrow.TextColor3 = Color3.fromRGB(120, 120, 145)
    Arrow.Font = Enum.Font.GothamBlack
    Arrow.TextSize = 20
    Arrow.TextXAlignment = Enum.TextXAlignment.Center

    -- خط تحتي يظهر فقط عند الفتح
    local BottomLine = Instance.new("Frame", Header)
    BottomLine.Size = UDim2.new(0.65, 0, 0, 1.5)
    BottomLine.Position = UDim2.new(0.175, 0, 1, -1)
    BottomLine.BorderSizePixel = 0
    BottomLine.BackgroundTransparency = 1
    local BLGradient = Instance.new("UIGradient", BottomLine)
    BLGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0,   Color3.fromRGB(0, 0, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 150)),
        ColorSequenceKeypoint.new(1,   Color3.fromRGB(0, 0, 0))
    }

    Header.Parent = SectionContainer

    -- الـ Body (المحتوى الداخلي)
    local Body = Instance.new("Frame", SectionContainer)
    Body.Name = "Body"
    Body.Size = UDim2.new(1, 0, 0, 0) -- يتحسب لاحقاً
    Body.Position = UDim2.new(0, 0, 0, 42)
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
            SectionContainer.Size = UDim2.new(1, 0, 0, 42 + h + 6)
        end
    end)

    -- حالة الفتح/الإغلاق
    local isOpen = false

    Header.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            Body.Visible = true
            local h = UpdateBodySize()
            CreateTween(SectionContainer, {Size = UDim2.new(1, 0, 0, 42 + h + 6)}, 0.28)
            CreateTween(Arrow, {Rotation = 90, TextColor3 = Color3.fromRGB(0, 255, 150)}, 0.2)
            CreateTween(ArrowBg, {BackgroundColor3 = Color3.fromRGB(0, 40, 25)}, 0.2)
            CreateTween(TitleLabel, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
            CreateTween(Header, {BackgroundColor3 = Color3.fromRGB(14, 22, 18), BackgroundTransparency = 0}, 0.2)
            CreateTween(HeaderStroke, {Transparency = 0.2}, 0.2)
            CreateTween(Dot, {BackgroundColor3 = Color3.fromRGB(0, 255, 150)}, 0.2)
            CreateTween(BottomLine, {BackgroundTransparency = 0}, 0.3)
        else
            CreateTween(SectionContainer, {Size = UDim2.new(1, 0, 0, 40)}, 0.25)
            CreateTween(Arrow, {Rotation = 0, TextColor3 = Color3.fromRGB(120, 120, 145)}, 0.2)
            CreateTween(ArrowBg, {BackgroundColor3 = Color3.fromRGB(28, 28, 38)}, 0.2)
            CreateTween(TitleLabel, {TextColor3 = Color3.fromRGB(165, 165, 180)}, 0.2)
            CreateTween(Header, {BackgroundColor3 = Color3.fromRGB(18, 18, 24), BackgroundTransparency = 0.1}, 0.2)
            CreateTween(HeaderStroke, {Transparency = 0.85}, 0.2)
            CreateTween(Dot, {BackgroundColor3 = Color3.fromRGB(70, 70, 90)}, 0.2)
            CreateTween(BottomLine, {BackgroundTransparency = 1}, 0.15)
            task.delay(0.26, function() if not isOpen then Body.Visible = false end end)
        end
    end)

    Header.MouseEnter:Connect(function()
        if not isOpen then
            CreateTween(Header, {BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(22, 22, 30)}, 0.15)
            CreateTween(TitleLabel, {TextColor3 = Color3.fromRGB(210, 210, 220)}, 0.15)
        end
    end)
    Header.MouseLeave:Connect(function()
        if not isOpen then
            CreateTween(Header, {BackgroundTransparency = 0.1, BackgroundColor3 = Color3.fromRGB(18, 18, 24)}, 0.15)
            CreateTween(TitleLabel, {TextColor3 = Color3.fromRGB(165, 165, 180)}, 0.15)
        end
    end)

    -- ======================================================
    -- SectionOps: دوال تضيف العناصر داخل البودي
    -- ======================================================
    local SectionOps = {
        Order = 0,
        Page = Body,
        TabName = TabOps.TabName,
        LogAction = TabOps.LogAction,
        UI = TabOps.UI
    }

    -- نفس طريقة main.lua: كل عنصر يتحمل عند الاستدعاء
    local elementNames = {
        "Button", "Toggle", "TimedToggle", "Input", "LargeInput",
        "SpeedControl", "Dropdown", "PlayerSelector", "ProfileCard",
        "Line", "Label", "Paragraph"
    }

    -- دالة تحميل العناصر (نفس LoadElement في main.lua)
    local ElementCache = {}
    local function LoadSectionElement(elementName)
        if ElementCache[elementName] then return ElementCache[elementName] end
        local branch = "test"
        local userName = "OnlyCryptic"
        local repoName = "Cryptic"
        -- نحاول نجيب الإعدادات من getgenv لو موجودة
        pcall(function()
            if getgenv().CrypticConfig then
                userName = getgenv().CrypticConfig.UserName or userName
                repoName = getgenv().CrypticConfig.RepoName or repoName
                branch   = getgenv().CrypticConfig.Branch   or branch
            end
        end)
        local url = "https://raw.githubusercontent.com/" .. userName .. "/" .. repoName .. "/" .. branch .. "/UI/Elements/" .. elementName .. ".lua?v=" .. tick()
        local s, r = pcall(game.HttpGet, game, url)
        if s and r then
            local chunk = loadstring(r)
            if chunk then
                local func = chunk()
                ElementCache[elementName] = func
                return func
            end
        end
        warn("Cryptic Section: Failed to load element - " .. elementName)
        return nil
    end

    for _, elName in ipairs(elementNames) do
        SectionOps["Add" .. elName] = function(self, ...)
            -- تبديل مؤقت للـ Page للبودي
            local originalPage  = TabOps.Page
            local originalOrder = TabOps.Order
            TabOps.Page  = Body
            TabOps.Order = self.Order
            -- نستخدم دالة TabOps لو موجودة، وإلا نحمّل العنصر مباشرة
            local result
            if TabOps["Add" .. elName] then
                result = TabOps["Add" .. elName](TabOps, ...)
            else
                local elementFunc = LoadSectionElement(elName)
                if elementFunc then result = elementFunc(TabOps, ...) end
            end
            self.Order  = TabOps.Order
            TabOps.Page  = originalPage
            TabOps.Order = originalOrder
            return result
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
