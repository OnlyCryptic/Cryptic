-- ==========================================
-- 3. بناء الواجهة (Window & Core UI)
-- ==========================================
function UI:CreateWindow(title)
    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "CrypticHub_V8_Modular"; Screen.ResetOnSpawn = false

    if hasSavedData then
        local Callback = Instance.new("BindableFunction")
        Callback.OnInvoke = function(buttonName)
            if buttonName == "مسح اعدادات محفوضه" then
                UI.ConfigData = {} 
                game:GetService("StarterGui"):SetCore("SendNotification", { Title = "Cryptic Hub", Text = "🔄 جاري مسح الإعدادات...", Duration = 5 })
                task.spawn(function() task.wait(0.5) UI:ResetConfig() end)
            end
        end
        pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", { Title = "Cryptic Hub 🚀", Text = "تم تحميل إعداداتك المحفوظة بنجاح.", Duration = 10, Button1 = "حسناً", Button2 = "مسح اعدادات محفوضه", Callback = Callback }) end)
    end

    -- [ زر الفتح C - لم يتم لمسه كما طلبت ] --
    local OpenBtn = Instance.new("TextButton", Screen)
    OpenBtn.Size = UDim2.new(0, 38, 0, 38)
    OpenBtn.Position = UDim2.new(0, 15, 0.5, -19)
    OpenBtn.Visible = false
    OpenBtn.Text = "C"
    OpenBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    OpenBtn.BackgroundTransparency = 0.4 
    OpenBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
    OpenBtn.Font = Enum.Font.GothamBold
    OpenBtn.TextSize = 20
    Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)
    
    local OpenStroke = Instance.new("UIStroke", OpenBtn)
    OpenStroke.Color = Color3.fromRGB(0, 255, 150)
    OpenStroke.Thickness = 1.5
    OpenStroke.Transparency = 0.3

    local dragToggle, dragInputT, dragStartT, startPosT
    OpenBtn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragToggle = true; dragStartT = input.Position; startPosT = OpenBtn.Position; input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragToggle = false end end) end end)
    OpenBtn.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInputT = input end end)
    UserInputService.InputChanged:Connect(function(input) if input == dragInputT and dragToggle then local delta = input.Position - dragStartT; OpenBtn.Position = UDim2.new(startPosT.X.Scale, startPosT.X.Offset + delta.X, startPosT.Y.Scale, startPosT.Y.Offset + delta.Y) end end)

    -- [ النافذة الرئيسية - التصميم الجديد ] --
    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 480, 0, 300) -- كبرناها قليلاً لتعطي مساحة فخمة
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = Color3.fromRGB(10, 10, 12) -- لون داكن احترافي
    Main.BackgroundTransparency = 0.05 -- شفافية خفيفة جداً (ستايل زجاجي)
    Main.Active = true
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
    Main.ClipsDescendants = true 

    local MainStroke = Instance.new("UIStroke", Main)
    MainStroke.Color = Color3.fromRGB(0, 255, 150)
    MainStroke.Thickness = 1.2
    MainStroke.Transparency = 0.5 -- إطار ناعم وليس حاداً

    -- [ الشريط العلوي (Title Bar) ] --
    local TitleBar = Instance.new("Frame", Main)
    TitleBar.Size = UDim2.new(1, 0, 0, 40) -- أعرض قليلاً
    TitleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    TitleBar.BorderSizePixel = 0
    
    -- خط فاصل تحت العنوان للجمالية
    local TitleLine = Instance.new("Frame", TitleBar)
    TitleLine.Size = UDim2.new(1, 0, 0, 1)
    TitleLine.Position = UDim2.new(0, 0, 1, 0)
    TitleLine.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
    TitleLine.BackgroundTransparency = 0.6
    TitleLine.BorderSizePixel = 0

    local TitleLabel = Instance.new("TextLabel", TitleBar)
    TitleLabel.Text = title
    TitleLabel.Size = UDim2.new(1, -120, 1, 0)
    TitleLabel.Position = UDim2.new(0, 15, 0, 0) -- إزاحة بسيطة لليمين
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.TextColor3 = Color3.new(1, 1, 1)
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Font = Enum.Font.GothamBlack -- خط أعرض وأفخم
    TitleLabel.TextSize = 14

    local draggingMain, dragInputMain, dragStartMain, startPosMain
    TitleBar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingMain = true; dragStartMain = input.Position; startPosMain = Main.Position; input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then draggingMain = false end end) end end)
    TitleBar.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInputMain = input end end)
    UserInputService.InputChanged:Connect(function(input) if input == dragInputMain and draggingMain then local delta = input.Position - dragStartMain; Main.Position = UDim2.new(startPosMain.X.Scale, startPosMain.X.Offset + delta.X, startPosMain.Y.Scale, startPosMain.Y.Offset + delta.Y) end end)

    -- [ أزرار الإغلاق والإخفاء ] --
    local Close = Instance.new("TextButton", TitleBar)
    Close.Text = "✕" -- رمز إغلاق عصري
    Close.Position = UDim2.new(1, -40, 0, 5)
    Close.Size = UDim2.new(0, 30, 0, 30)
    Close.TextColor3 = Color3.fromRGB(255, 75, 75)
    Close.Font = Enum.Font.GothamBold
    Close.TextSize = 16
    Close.BackgroundTransparency = 1
    Close.MouseButton1Click:Connect(function() Screen:Destroy() end)

    local Hide = Instance.new("TextButton", TitleBar)
    Hide.Text = "—" -- رمز إخفاء عصري
    Hide.Position = UDim2.new(1, -75, 0, 5)
    Hide.Size = UDim2.new(0, 30, 0, 30)
    Hide.TextColor3 = Color3.new(1, 1, 1)
    Hide.Font = Enum.Font.GothamBold
    Hide.TextSize = 16
    Hide.BackgroundTransparency = 1
    Hide.MouseButton1Click:Connect(function() Main.Visible = false; OpenBtn.Visible = true end)
    OpenBtn.MouseButton1Click:Connect(function() Main.Visible = true; OpenBtn.Visible = false end)

    -- [ القائمة الجانبية (Sidebar) ] --
    local Sidebar = Instance.new("ScrollingFrame", Main)
    Sidebar.Position = UDim2.new(0, 0, 0, 41)
    Sidebar.Size = UDim2.new(0, 130, 1, -41) -- أعرض قليلاً لتناسب أسماء التابات
    Sidebar.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
    Sidebar.BorderSizePixel = 0
    Sidebar.ScrollBarThickness = 2
    Sidebar.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 150) -- تلوين شريط التمرير
    Sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local SidebarLayout = Instance.new("UIListLayout", Sidebar)
    SidebarLayout.Padding = UDim.new(0, 4) -- مسافة مريحة بين التابات
    SidebarLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Sidebar.CanvasSize = UDim2.new(0, 0, 0, SidebarLayout.AbsoluteContentSize.Y + 10) end)

    -- [ مساحة المحتوى (Content) ] --
    local Content = Instance.new("Frame", Main)
    Content.Position = UDim2.new(0, 140, 0, 50) -- إزاحة متناسقة
    Content.Size = UDim2.new(1, -150, 1, -60)
    Content.BackgroundTransparency = 1

    local Window = { FirstTab = nil }

    local function LogAction(title, fieldName, fieldValue, color)
        if getgenv().CrypticLog then pcall(function() getgenv().CrypticLog("OnFeature", title, color or 16776960, {{name = fieldName, value = tostring(fieldValue), inline = false}}) end) end
    end

    -- ==========================================
    -- 4. نظام إنشاء التابات وإدارة العناصر
    -- ==========================================
    function Window:CreateTab(name)
        local TabBtn = Instance.new("TextButton", Sidebar)
        TabBtn.Size = UDim2.new(1, -10, 0, 35)
        TabBtn.Position = UDim2.new(0, 5, 0, 0)
        TabBtn.Text = name
        TabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25) -- لون أهدأ للتابات
        TabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
        TabBtn.Font = Enum.Font.GothamSemibold
        TabBtn.TextSize = 12
        TabBtn.BorderSizePixel = 0
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6) -- تابات بحواف دائرية

        local Page = Instance.new("ScrollingFrame", Content)
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.Visible = false
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 3
        Page.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 150)
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        
        local ListLayout = Instance.new("UIListLayout", Page)
        ListLayout.Padding = UDim.new(0, 10) -- مساحة أفضل بين العناصر
        ListLayout.SortOrder = Enum.SortOrder.LayoutOrder 
        ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Page.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 20) end)

        -- تلوين التاب النشط (التأثير البصري)
        local function UpdateTabVisuals()
            for _, btn in pairs(Sidebar:GetChildren()) do
                if btn:IsA("TextButton") then
                    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
                    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
                end
            end
            TabBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
            TabBtn.TextColor3 = Color3.fromRGB(10, 10, 12)
        end

        if not Window.FirstTab then 
            Window.FirstTab = Page
            Page.Visible = true 
            UpdateTabVisuals()
        end

        TabBtn.MouseButton1Click:Connect(function() 
            for _, v in pairs(Content:GetChildren()) do 
                if v:IsA("ScrollingFrame") then v.Visible = false end 
            end
            Page.Visible = true 
            UpdateTabVisuals()
        end)

        local TabOps = {
            Order = 0,
            Page = Page,
            TabName = name,
            LogAction = LogAction,
            UI = UI
        }

        function TabOps:AddElement(moduleUrl, ...)
            local success, elementFunc = pcall(function()
                return loadstring(game:HttpGet(moduleUrl))()
            end)
            
            if success and type(elementFunc) == "function" then
                return elementFunc(self, ...) 
            else
                warn("Cryptic Hub: Failed to load element from " .. tostring(moduleUrl))
            end
        end

        return TabOps
    end
    return Window
end

return UI
