-- [[ Arwa Hub - الإيم بوت المطور (نسخة بدون قيود) ]]
-- المطور: Arwa | الميزات: إيم بوت عدواني، تحكم كامل بالسرعة، شيفت لوك مدمج

return function(Tab, UI)
    local runService = game:GetService("RunService")
    local lp = game.Players.LocalPlayer
    local camera = workspace.CurrentCamera
    
    local isAimbotting = false
    local smoothness = 0.2 -- القيمة الافتراضية (كلما زادت أصبح الإيم أسرع وأقوى)
    local shiftLockOffset = Vector3.new(1.7, 0.5, 0)

    -- زر التشغيل
    Tab:AddToggle("🔫 إيم بوت عدواني + شيفت لوك", function(active)
        isAimbotting = active
        local char = lp.Character
        local hum = char and char:FindFirstChild("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")

        if active then
            if hum then hum.CameraOffset = shiftLockOffset end
            UI:Notify("🔥 تم تفعيل الإيم بوت العدواني!")
        else
            if hum then hum.CameraOffset = Vector3.new(0, 0, 0) end
            local gyro = root and root:FindFirstChild("AimbotGyro")
            if gyro then gyro:Destroy() end
            UI:Notify("❌ تم الإيقاف")
        end
    end)

    -- خانة إدخال السرعة (التنعيم) - كما طلبتِ
    Tab:AddInput("🚀 قوة الالتصاق (0.1 إلى 1)", "0.2", function(val)
        local n = tonumber(val)
        if n then 
            -- حصر القيمة لضمان عدم حدوث لاج في الكاميرا
            smoothness = math.clamp(n, 0.01, 1)
            UI:Notify("تم ضبط قوة الإيم على: " .. smoothness)
        end
    end)

    -- حلقة التحكم المطورة
    runService.RenderStepped:Connect(function()
        local target = _G.ArwaTarget
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")

        if isAimbotting and target and target.Character and target.Character:FindFirstChild("Head") then
            local head = target.Character.Head
            
            -- تم حذف فحص الجدران هنا؛ الإيم سيلتصق بالهدف دائماً
            
            -- 1. تثبيت الكاميرا بنظام Lerp سريع
            local targetCF = CFrame.lookAt(camera.CFrame.Position, head.Position)
            camera.CFrame = camera.CFrame:Lerp(targetCF, smoothness)
            
            -- 2. توجيه جسم اللاعب لمواجهة الخصم (نظام الشيفت لوك)
            if root then
                local gyro = root:FindFirstChild("AimbotGyro") or Instance.new("BodyGyro", root)
                gyro.Name = "AimbotGyro"
                gyro.MaxTorque = Vector3.new(0, math.huge, 0)
                gyro.P = 50000 -- زيادة القوة ليكون الدوران فورياً
                gyro.D = 50 -- تقليل الارتداد
                gyro.CFrame = CFrame.lookAt(root.Position, Vector3.new(head.Position.X, root.Position.Y, head.Position.Z))
            end
        end
    end)
end
