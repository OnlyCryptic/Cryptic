-- [[ Cryptic Hub - Perfect Auto Clicker (Mobile Fix) ]]
-- المطور: arwa hope | الوصف: أوتو كليكر نظيف داخل Folder، مع حل مشكلة الماوس في الجوال ووزن الضغطة

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local GuiService = game:GetService("GuiService")

return function(Tab, UI)
    -- 🔥 نحط كل شيء داخل المجلد عشان الزحمة
    local ACFolder = Tab:AddFolder("🖱️ أوتو كليكر / Auto Clicker")

    local isEnabled = false
    local isVisible = false
    local speedMs = 100 -- السرعة الافتراضية

    -- ==========================================
    -- 🟢 تصميم مؤشر التصويب (الدائرة)
    -- ==========================================
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CrypticProAC"
    ScreenGui.Parent = (gethui and gethui()) or CoreGui
    ScreenGui.IgnoreGuiInset = true 
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Enabled = false -- 💡 مخفية في البداية زي ما طلبتي!

    local TargetFrame = Instance.new("Frame", ScreenGui)
    TargetFrame.Size = UDim2.new(0, 45, 0, 45)
    TargetFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    TargetFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    TargetFrame.BackgroundTransparency = 0.99 
    TargetFrame.Active = true

    local OuterRing = Instance.new("Frame", TargetFrame)
    OuterRing.Size = UDim2.new(0, 24, 0, 24)
    OuterRing.Position = UDim2.new(0.5, 0, 0.5, 0)
    OuterRing.AnchorPoint = Vector2.new(0.5, 0.5)
    OuterRing.BackgroundTransparency = 1
    local RingStroke = Instance.new("UIStroke", OuterRing)
    RingStroke.Color = Color3.fromRGB(0, 255, 150)
    RingStroke.Thickness = 2
    Instance.new("UICorner", OuterRing).CornerRadius = UDim.new(1, 0)

    local CenterDot = Instance.new("Frame", TargetFrame)
    CenterDot.Size = UDim2.new(0, 6, 0, 6)
    CenterDot.Position = UDim2.new(0.5, 0, 0.5, 0)
    CenterDot.AnchorPoint = Vector2.new(0.5, 0.5)
    CenterDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", CenterDot).CornerRadius = UDim.new(1, 0)

    -- ==========================================
    -- 🟢 نظام السحب مع القفل
    -- ==========================================
    local dragging, dragInput, dragStart, startPos
    TargetFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if isEnabled or not isVisible then return end -- يمنع السحب لو الكليكر شغال
            
            dragging = true
            dragStart = input.Position
            startPos = TargetFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    TargetFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            TargetFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- ==========================================
    -- 🟢 حلقة الضغط (مع حل مشكلة الجوال والوزنية)
    -- ==========================================
    task.spawn(function()
        while true do
            if isEnabled and TargetFrame and ScreenGui.Parent then
                -- 💡 حساب الإحداثيات الدقيقة (تعويض شريط روبلوكس العلوي عشان تضبط بالنص)
                local inset = GuiService:GetGuiInset()
                local cx = TargetFrame.AbsolutePosition.X + (TargetFrame.AbsoluteSize.X / 2)
                local cy = TargetFrame.AbsolutePosition.Y + (TargetFrame.AbsoluteSize.Y / 2) + inset.Y
                
                -- 💡 الذكاء هنا: إذا تلعبين من جوال يسوي "لمس" بدل "كليك ماوس"
                if UserInputService.TouchEnabled then
                    VirtualInputManager:SendTouchEvent(1, 0, cx, cy) -- لمس الشاشة (Touch Down)
                    task.wait(0.01)
                    VirtualInputManager:SendTouchEvent(1, 2, cx, cy) -- رفع الإصبع (Touch Up)
                else
                    VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, true, game, 1)
                    task.wait(0.01)
                    VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, false, game, 1)
                end
                
                task.wait(speedMs / 1000)
            else
                task.wait(0.1)
            end
        end
    end)

    -- ==========================================
    -- 🟢 أزرار التحكم داخل المجلد (نظيفة وبسيطة)
    -- ==========================================
    
    ACFolder:AddToggle("👁️ إظهار الدائرة / Show Target", function(state)
        isVisible = state
        ScreenGui.Enabled = isVisible
    end)

    ACFolder:AddToggle("⚡ تفعيل الكليكر / Enable Clicker", function(state)
        isEnabled = state
        if isEnabled then
            RingStroke.Color = Color3.fromRGB(255, 50, 50) -- يصير أحمر = مقفول ويضرب
        else
            RingStroke.Color = Color3.fromRGB(0, 255, 150) -- يصير أخضر = جاهز للسحب
        end
    end)

    -- إدخال بسيط جداً ومباشر للسرعة
    ACFolder:AddInput("السرعة | Speed (ms)", function(val)
        local num = tonumber(val)
        if num and num > 0 then
            speedMs = num
        end
    end)

end
