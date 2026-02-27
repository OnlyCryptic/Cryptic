-- [[ Cryptic Hub - محرك الواجهة العصرية ]]
-- الستايل: Dark & Neon | لغة: العربية | دعم الهاتف: 100%

local UI = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- إعدادات الألوان العصرية
local Theme = {
    Background = Color3.fromRGB(15, 15, 15),
    Sidebar = Color3.fromRGB(20, 20, 20),
    Accent = Color3.fromRGB(0, 255, 150), -- لون نيون (أخضر فسفوري)
    Text = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(180, 180, 180)
}

function UI:CreateWindow(config)
    local MainGui = Instance.new("ScreenGui")
    MainGui.Name = "CrypticUI"
    MainGui.Parent = game:GetService("CoreGui") -- لضمان عدم حذفه بسهولة
    MainGui.ResetOnSpawn = false

    -- الإطار الرئيسي
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0.6, 0, 0.6, 0) -- حجم نسبي ليتناسب مع الهاتف
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = MainGui

    -- إضافة حواف دائرية (Corner)
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = MainFrame

    -- إضافة خط نيون علوي
    local GlowBar = Instance.new("Frame")
    GlowBar.Size = UDim2.new(1, 0, 0, 3)
    GlowBar.BackgroundColor3 = Theme.Accent
    GlowBar.BorderSizePixel = 0
    GlowBar.Parent = MainFrame
    Instance.new("UICorner").Parent = GlowBar

    -- العنوان (بالعربية)
    local Title = Instance.new("TextLabel")
    Title.Text = config.Title or "كربتك هب"
    Title.Size = UDim2.new(0, 200, 0, 40)
    Title.Position = UDim2.new(1, -10, 0, 10) -- من اليمين
    Title.AnchorPoint = Vector2.new(1, 0)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Theme.Accent
    Title.TextSize = 22
    Title.Font = Enum.Font.Ubuntu
    Title.TextXAlignment = Enum.TextXAlignment.Right
    Title.Parent = MainFrame

    -- منطقة الأقسام (Scrolling Frame)
    local Container = Instance.new("ScrollingFrame")
    Container.Size = UDim2.new(0.9, 0, 0.75, 0)
    Container.Position = UDim2.new(0.5, 0, 0.55, 0)
    Container.AnchorPoint = Vector2.new(0.5, 0.5)
    Container.BackgroundTransparency = 1
    Container.BorderSizePixel = 0
    Container.ScrollBarThickness = 2
    Container.Parent = MainFrame

    local Layout = Instance.new("UIListLayout")
    Layout.Parent = Container
    Layout.Padding = UDim.new(0, 8)
    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    -- وظيفة إضافة "زر" عصري
    function config:AddButton(text, callback)
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(0.95, 0, 0, 40)
        Btn.BackgroundColor3 = Theme.Sidebar
        Btn.Text = text
        Btn.TextColor3 = Theme.Text
        Btn.TextSize = 16
        Btn.Font = Enum.Font.SourceSansBold
        Btn.Parent = Container
        
        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(0, 6)
        BtnCorner.Parent = Btn

        -- تأثير النيون عند الضغط
        Btn.MouseButton1Click:Connect(function()
            local tween = TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Accent, TextColor3 = Theme.Background})
            tween:Play()
            tween.Completed:Wait()
            TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Sidebar, TextColor3 = Theme.Text}):Play()
            callback()
        end)
    end

    -- جعل النافذة قابلة للسحب (Draggable) للهواتف
    local dragging, dragInput, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return config
end

function UI:Notify(msg)
    print("📢 إشعار كربتك: " .. msg)
    -- يمكن لاحقاً إضافة نظام إشعارات منبثقة هنا
end

return UI

