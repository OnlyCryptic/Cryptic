-- [[ Cryptic Hub - Perfect Auto Clicker (Smart Speed + UI Fix) ]]
-- المطور: arwa hope | الوصف: أوتو كليكر نظيف، حساب سرعة ذكي (s/ms)، وتعديل محاذاة النص

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local GuiService = game:GetService("GuiService")

return function(Tab, UI)
    -- 🔥 ضفنا 4 مسافات في البداية عشان العنوان يندف يمين وما يكون لاصق باليسار
    local ACFolder = Tab:AddFolder("    🖱️ أوتو كليكر / Auto Clicker")

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
    ScreenGui.Enabled = false -- 💡 مخفية في البداية!

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
                local inset = GuiService:GetGuiInset()
                local cx = TargetFrame.AbsolutePosition.X + (TargetFrame.AbsoluteSize.X / 2)
                local cy = TargetFrame.AbsolutePosition.Y + (TargetFrame.AbsoluteSize.Y / 2) + inset.Y
                
                if UserInputService.TouchEnabled then
                    VirtualInputManager:SendTouchEvent(1, 0, cx, cy)
                    task.wait(0.01)
                    VirtualInputManager:SendTouchEvent(1, 2, cx, cy)
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
    -- 🟢 أزرار التحكم داخل المجلد
    -- ==========================================
    
    ACFolder:AddToggle("👁️ إظهار الدائرة / Show Target", function(state)
        isVisible = state
        ScreenGui.Enabled = isVisible
    end)

    ACFolder:AddToggle("⚡ تفعيل الكليكر / Enable Clicker", function(state)
        isEnabled = state
        if isEnabled then
            RingStroke.Color = Color3.fromRGB(255, 50, 50) -- مقفول ويضرب
        else
            RingStroke.Color = Color3.fromRGB(0, 255, 150) -- جاهز للسحب
        end
    end)

    -- 🔥 إدخال السرعة الذكي (يفهم s و ms)
    ACFolder:AddInput("السرعة | Speed (Ex: 2s, 50ms, 100)", function(val)
        local str = tostring(val):lower():gsub(" ", "") -- نحول النص لحروف صغيرة ونشيل المسافات
        local parsedNum = nil

        -- لو كتب ms
        if str:find("ms") then
            parsedNum = tonumber(str:gsub("ms", ""))
        -- لو كتب s (نضرب في 1000)
        elseif str:find("s") then
            local sNum = tonumber(str:gsub("s", ""))
            if sNum then parsedNum = sNum * 1000 end
        -- لو كتب رقم حاف (نعتبره ms)
        else
            parsedNum = tonumber(str)
        end

        -- لو الرقم صحيح نحفظه ونعطيه إشعار
        if parsedNum and parsedNum > 0 then
            speedMs = parsedNum
            pcall(function() 
                game:GetService("StarterGui"):SetCore("SendNotification", {Title="Cryptic Hub", Text="تم تعيين السرعة: " .. speedMs .. "ms", Duration=2}) 
            end)
        else
            pcall(function() 
                game:GetService("StarterGui"):SetCore("SendNotification", {Title="Cryptic Hub", Text="إدخال خاطئ! جرب: 2s أو 100", Duration=3}) 
            end)
        end
    end)

    -- 🔥 زر توضيحي أنيق
    ACFolder:AddButton("💡 ملاحظة: 1000ms = 1s", function()
        pcall(function() 
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title="Speed Info", 
                Text="مثال: \nإذا كتبت 2s يعني يضغط كل ثانيتين.\nإذا كتبت 50 يعني يضغط 20 مرة بالثانية.", 
                Duration=5
            }) 
        end)
    end)

end
