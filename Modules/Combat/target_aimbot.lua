-- [[ Arwa Hub - إيم بوت وشيفت لوك (نظام بلوكس فروت) ]]
-- المطور: Arwa | الميزات: تثبيت كامل (Character & Camera)، قوة 100% تلقائية

return function(Tab, UI)
    local runService = game:GetService("RunService")
    local lp = game.Players.LocalPlayer
    local camera = workspace.CurrentCamera
    
    local isAimbotting = false
    -- القوة تم ضبطها تلقائياً على 1 لأقصى تثبيت
    local power = 1 
    local shiftLockOffset = Vector3.new(1.7, 0.5, 0)

    -- زر التشغيل الوحيد (نظام احترافي بسيط)
    Tab:AddToggle("ايم بوت ", function(active)
        isAimbotting = active
        local char = lp.Character
        local hum = char and char:FindFirstChild("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")

        if active then
            if hum then hum.CameraOffset = shiftLockOffset end
            UI:Notify("✅ الوضع القتالي مفعل (تثبيت كامل)")
        else
            -- إرجاع الحالة الطبيعية عند الإيقاف
            if hum then hum.CameraOffset = Vector3.new(0, 0, 0) end
            local gyro = root and root:FindFirstChild("AimbotGyro")
            if gyro then gyro:Destroy() end
            UI:Notify("❌ تم إلغاء القفل")
        end
    end)

    -- حلقة التحديث بنظام الالتصاق المغناطيسي
    runService.RenderStepped:Connect(function()
        local target = _G.ArwaTarget
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")

        if isAimbotting and target and target.Character and target.Character:FindFirstChild("Head") then
            local head = target.Character.Head
            
            -- 1. تثبيت الكاميرا فوراً على الهدف (بدون تنعيم ليكون القفل 100%)
            camera.CFrame = CFrame.lookAt(camera.CFrame.Position, head.Position)
            
            -- 2. تثبيت جسم اللاعب (Character Pin) لمواجهة الخصم دائماً
            if root then
                local gyro = root:FindFirstChild("AimbotGyro") or Instance.new("BodyGyro", root)
                gyro.Name = "AimbotGyro"
                gyro.MaxTorque = Vector3.new(0, math.huge, 0) -- قفل الدوران الأفقي فقط للسماح بالقفز
                gyro.P = 100000 -- قوة جبارة تمنع الجسم من الانحراف عن الهدف
                gyro.D = 100
                
                -- جعل الشخصية والكاميرا والهدف في خط واحد مستقيم
                gyro.CFrame = CFrame.lookAt(root.Position, Vector3.new(head.Position.X, root.Position.Y, head.Position.Z))
            end

            -- الحفاظ على إزاحة الشيفت لوك الجانبية (مثل أيقونة بلوكس فروت الخضراء)
            if hum and hum.CameraOffset ~= shiftLockOffset then
                hum.CameraOffset = shiftLockOffset
            end
        end
    end)
end
