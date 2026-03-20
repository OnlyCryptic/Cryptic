-- [[ Cryptic Hub - Auto Clicker V6 ]]
-- المطور: arwa hope

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local lp = Players.LocalPlayer

return function(Tab, UI)
    local ACFolder = Tab:AddFolder("    🖱️ أوتو كليكر / Auto Clicker")

    local isEnabled = false
    local isVisible = false
    local speedMs = 100

    -- ==========================================
    -- 🟢 تصميم المؤشر
    -- ==========================================
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CrypticProAC_V6"
    ScreenGui.Parent = (gethui and gethui()) or CoreGui
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Enabled = false

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
    -- 🟢 السحب مع القفل
    -- ==========================================
    local dragging, dragInput, dragStart, startPos
    local inputConn -- 🔥 نحفظ الـ connection عشان نفصله لاحقاً

    TargetFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 
           or input.UserInputType == Enum.UserInputType.Touch then
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
        if input.UserInputType == Enum.UserInputType.MouseMovement 
           or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    -- 🔥 الحل: نحفظ الـ connection
    inputConn = UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            TargetFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    -- ==========================================
    -- 🟢 حلقة الضغط الذكية
    -- ==========================================
    -- 🔥 الحل الأساسي لمشكلتك:
    -- نحسب أبعاد الـ UI ونتجنبها تماماً
    -- نتحقق إن الإصبع مش فوق أي Roblox UI قبل الضغط
    
    local function IsPointOverUI(x, y)
        -- نتحقق من كل الـ ScreenGui الموجودة
        for _, gui in ipairs(Players.LocalPlayer.PlayerGui:GetDescendants()) do
            if gui:IsA("GuiObject") and gui.Visible then
                local pos = gui.AbsolutePosition
                local size = gui.AbsoluteSize
                if x >= pos.X and x <= pos.X + size.X 
                   and y >= pos.Y and y <= pos.Y + size.Y then
                    -- تحقق إنه يقبل input (مش مجرد زينة)
                    if gui:IsA("TextButton") or gui:IsA("ImageButton") 
                       or gui:IsA("ScrollingFrame") then
                        return true
                    end
                end
            end
        end
        return false
    end

    task.spawn(function()
        while true do
            if isEnabled and ScreenGui.Parent then
                local cx = TargetFrame.AbsolutePosition.X + (TargetFrame.AbsoluteSize.X / 2)
                local cy = TargetFrame.AbsolutePosition.Y + (TargetFrame.AbsoluteSize.Y / 2)

                -- 🔥 تحقق إن النقطة مش فوق UI قبل الضغط
                if not IsPointOverUI(cx, cy) then
                    if UserInputService.TouchEnabled then
                        -- 🔥 حل مشكلة الإصبعين:
                        -- نستخدم touchId منفصل (99) عشان ما يتعارض مع إصبع الحركة (0,1)
                        VirtualInputManager:SendTouchEvent(99, 0, cx, cy)
                        task.wait(0.01)
                        VirtualInputManager:SendTouchEvent(99, 2, cx, cy)
                    else
                        VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, true, game, 1)
                        task.wait(0.01)
                        VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, false, game, 1)
                    end
                end

                task.wait(speedMs / 1000)
            else
                task.wait(0.1)
            end
        end
    end)

    -- ==========================================
    -- 🟢 واجهة التحكم
    -- ==========================================

    ACFolder:AddToggle("👁️ إظهار الدائرة / Show Target", function(state)
        isVisible = state
        ScreenGui.Enabled = isVisible
    end)

    ACFolder:AddToggle("⚡ تفعيل الكليكر / Enable Clicker", function(state)
        isEnabled = state
        RingStroke.Color = isEnabled 
            and Color3.fromRGB(255, 50, 50)   -- أحمر = يضغط
            or  Color3.fromRGB(0, 255, 150)    -- أخضر = جاهز
    end)

    -- 🔥 Slider بدل TextBox
    -- min=50ms (20 ضغطة/ثانية) | max=2000ms (ضغطة كل ثانيتين)
    ACFolder:AddSlider("⚡ السرعة / Speed (ms)", {
        min = 50,
        max = 2000,
        default = 100,
        increment = 50,
    }, function(val)
        speedMs = val
    end)

    -- زر معلومات
    ACFolder:AddButton("💡 50ms=سريع جداً | 1000ms=ثانية", function()
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Speed Guide",
                Text = "50ms = 20 ضغطة/ثانية (سريع)\n500ms = 2 ضغطة/ثانية\n1000ms = ضغطة كل ثانية",
                Duration = 5
            })
        end)
    end)
end