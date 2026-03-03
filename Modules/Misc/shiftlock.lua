-- [[ Cryptic Hub - ميزة الشيفت لوك للجوال ]]
-- المطور: يامي (Yami) | التحديث: زر عائم مع فيزياء توجيه الكاميرا الاحترافية

return function(Tab, UI)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local lp = Players.LocalPlayer
    local Camera = workspace.CurrentCamera
    
    local ShiftLockActive = false
    local Connection = nil
    
    -- 1. تصميم الزر العائم (مخفي بالبداية)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CrypticShiftLock"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- حماية الواجهة داخل الـ CoreGui عشان ما تنحذف
    local success, _ = pcall(function()
        ScreenGui.Parent = game:GetService("CoreGui")
    end)
    if not success then
        ScreenGui.Parent = lp:WaitForChild("PlayerGui")
    end
    ScreenGui.Enabled = false -- مخفي حتى يفعله من السكربت
    
    local ShiftButton = Instance.new("ImageButton")
    ShiftButton.Name = "Toggle"
    ShiftButton.Parent = ScreenGui
    ShiftButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    ShiftButton.BackgroundTransparency = 0.4
    ShiftButton.Position = UDim2.new(0.85, 0, 0.6, 0) -- موضع ممتاز لإبهام اليد اليمنى
    ShiftButton.Size = UDim2.new(0, 55, 0, 55)
    ShiftButton.Image = "rbxassetid://152648032" -- أيقونة قفل كلاسيكية
    ShiftButton.ImageTransparency = 0.2
    
    -- حواف دائرية للزر العائم
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(1, 0)
    UICorner.Parent = ShiftButton

    -- 2. دالة تشغيل وإيقاف الشيفت لوك
    local function ToggleShiftLock(state)
        ShiftLockActive = state
        local char = lp.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        
        if ShiftLockActive then
            ShiftButton.ImageColor3 = Color3.fromRGB(0, 255, 100) -- يتحول أخضر إذا شغال
            if hum then 
                hum.CameraOffset = Vector3.new(1.75, 0, 0) -- إزاحة الكاميرا لليمين
                hum.AutoRotate = false -- إيقاف دوران روبلوكس التلقائي
            end
            
            -- ربط حركة اللاعب بالكاميرا (RenderStepped لضمان نعومة الحركة بدون لاق)
            Connection = RunService.RenderStepped:Connect(function()
                if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") and lp.Character:FindFirstChild("Humanoid") then
                    local charRoot = lp.Character.HumanoidRootPart
                    local camLook = Camera.CFrame.LookVector
                    
                    -- إجبار الشخصية على النظر في نفس اتجاه الكاميرا (X و Z فقط عشان ما يميل للأرض)
                    charRoot.CFrame = CFrame.new(charRoot.Position, charRoot.Position + Vector3.new(camLook.X, 0, camLook.Z))
                else
                    -- في حال مات اللاعب، نفصل السكربت عشان ما يقلتش
                    ToggleShiftLock(false)
                end
            end)
        else
            ShiftButton.ImageColor3 = Color3.fromRGB(255, 255, 255) -- يرجع أبيض إذا طافي
            if hum then 
                hum.CameraOffset = Vector3.new(0, 0, 0) -- إرجاع الكاميرا للنص
                hum.AutoRotate = true -- إرجاع الحركة الطبيعية
            end
            if Connection then
                Connection:Disconnect()
                Connection = nil
            end
        end
    end

    -- عند الضغط على الزر العائم
    ShiftButton.MouseButton1Click:Connect(function()
        ToggleShiftLock(not ShiftLockActive)
    end)

    -- 3. إضافة زر التحكم في الواجهة الرئيسية للسكربت
    Tab:AddToggle("🔘 إظهار زر الشيفت لوك (للجوال)", function(state)
        ScreenGui.Enabled = state
        
        -- إذا خفى الزر وكان الشيفت لوك شغال، نطفيه تلقائياً
        if not state and ShiftLockActive then
            ToggleShiftLock(false)
        end
        
        if state then
            UI:Notify("✅ تم إظهار زر الشيفت لوك على الشاشة!")
        else
            UI:Notify("❌ تم إخفاء الزر.")
        end
    end)
    
    Tab:AddLine()
end
