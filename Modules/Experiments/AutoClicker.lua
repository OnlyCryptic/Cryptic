-- [[ Cryptic Hub - Simple & Pro Auto Clicker ]]
-- المطور: arwa hope | الوصف: أوتو كليكر بسيط واحترافي، مع قفل ذكي للسحب وتصميم خفيف

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

return function(Tab, UI)
    -- متغيرات التحكم
    local isEnabled = false
    local isVisible = true
    local speedMs = 100 -- السرعة الافتراضية 100 أجزاء من الثانية

    -- ==========================================
    -- 🟢 تصميم مؤشر التصويب (الدائرة)
    -- ==========================================
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CrypticSimpleAC"
    ScreenGui.Parent = (gethui and gethui()) or CoreGui
    ScreenGui.IgnoreGuiInset = true 
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local TargetFrame = Instance.new("Frame", ScreenGui)
    TargetFrame.Size = UDim2.new(0, 45, 0, 45)
    TargetFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    TargetFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    TargetFrame.BackgroundTransparency = 0.99 -- شفاف عشان الجوال يلقطه بدون ما يغطي الشاشة
    TargetFrame.Active = true

    local OuterRing = Instance.new("Frame", TargetFrame)
    OuterRing.Size = UDim2.new(0, 24, 0, 24)
    OuterRing.Position = UDim2.new(0.5, 0, 0.5, 0)
    OuterRing.AnchorPoint = Vector2.new(0.5, 0.5)
    OuterRing.BackgroundTransparency = 1
    local RingStroke = Instance.new("UIStroke", OuterRing)
    RingStroke.Color = Color3.fromRGB(0, 255, 150) -- لون أخضر (جاهز للسحب)
    RingStroke.Thickness = 2
    Instance.new("UICorner", OuterRing).CornerRadius = UDim.new(1, 0)

    local CenterDot = Instance.new("Frame", TargetFrame)
    CenterDot.Size = UDim2.new(0, 6, 0, 6)
    CenterDot.Position = UDim2.new(0.5, 0, 0.5, 0)
    CenterDot.AnchorPoint = Vector2.new(0.5, 0.5)
    CenterDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", CenterDot).CornerRadius = UDim.new(1, 0)

    -- ==========================================
    -- 🟢 نظام السحب الذكي (مع القفل)
    -- ==========================================
    local dragging, dragInput, dragStart, startPos
    TargetFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            -- 🔥 هنا السر: يمنع السحب نهائياً إذا الكليكر شغال أو الدائرة مخفية!
            if isEnabled or not isVisible then return end 
            
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
    -- 🟢 حلقة الضغط (Auto Clicker Loop)
    -- ==========================================
    task.spawn(function()
        while true do
            if isEnabled and TargetFrame and ScreenGui.Parent then
                local cx = TargetFrame.AbsolutePosition.X + (TargetFrame.AbsoluteSize.X / 2)
                local cy = TargetFrame.AbsolutePosition.Y + (TargetFrame.AbsoluteSize.Y / 2)
                
                -- إرسال ضغطة وهمية في مكان الدائرة بدون إزعاج شاشة اللاعب
                VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, true, game, 1)
                task.wait(0.01)
                VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, false, game, 1)
                
                task.wait(speedMs / 1000)
            else
                task.wait(0.1)
            end
        end
    end)

    -- ==========================================
    -- 🟢 واجهة التحكم في الـ Hub (أزرار نظيفة)
    -- ==========================================
    
    Tab:AddToggle("تفعيل الكليكر / Enable Clicker", function(state)
        isEnabled = state
        if isEnabled then
            RingStroke.Color = Color3.fromRGB(255, 50, 50) -- يتغير أحمر وقت الضرب (يعني مقفول)
        else
            RingStroke.Color = Color3.fromRGB(0, 255, 150) -- يرجع أخضر إذا طافي (جاهز للسحب)
        end
    end)

    Tab:AddToggle("إخفاء الدائرة / Hide Target", function(state)
        -- إذا كان مفعل (true)، نخفي الدائرة (isVisible = false)
        isVisible = not state
        ScreenGui.Enabled = isVisible
    end)

    Tab:AddInput("السرعة (ms) / Speed", function(val)
        local num = tonumber(val)
        if num and num > 0 then
            speedMs = num
        else
            pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", {Title="Cryptic Hub", Text="أدخل رقم صحيح!\nValid number please!", Duration=3}) end)
        end
    end)

    Tab:AddLine()
end
