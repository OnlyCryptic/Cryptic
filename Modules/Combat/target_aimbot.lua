-- [[ Arwa Hub - الإيم بوت المطور مع شيفت لوك تلقائي ]]
-- المطور: Arwa | الميزات: إيم ناعم، شيفت لوك مدمج، توجيه 3D

return function(Tab, UI)
    local runService = game:GetService("RunService")
    local lp = game.Players.LocalPlayer
    local camera = workspace.CurrentCamera
    
    local isAimbotting = false
    local smoothness = 0.15 -- درجة التنعيم (كلما قل الرقم كان الإيم أهدأ وأكثر واقعية)
    local shiftLockOffset = Vector3.new(1.7, 0.5, 0) -- إزاحة الكاميرا الجانبية

    Tab:AddToggle("🔫 إيم بوت", function(active)
        isAimbotting = active
        local char = lp.Character
        local hum = char and char:FindFirstChild("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")

        if active then
            UI:Notify("🎯 تم تفعيل الإيم بوت والشيفت لوك")
            -- تفعيل إزاحة الكاميرا فوراً عند التشغيل
            if hum then hum.CameraOffset = shiftLockOffset end
        else
            -- تنظيف عند الإيقاف
            if hum then hum.CameraOffset = Vector3.new(0, 0, 0) end
            local gyro = root and root:FindFirstChild("AimbotGyro")
            if gyro then gyro:Destroy() end
            UI:Notify("❌ تم إيقاف النظام")
        end
    end)

    -- حلقة التحديث الموحدة (التحكم الكامل)
    runService.RenderStepped:Connect(function()
        local target = _G.ArwaTarget
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")

        if isAimbotting and target and target.Character and target.Character:FindFirstChild("Head") then
            local targetPart = target.Character.Head
            
            -- 1. توجيه الكاميرا بنظام التنعيم (Lerp) ليكون الإيم احترافياً
            local lookAtCFrame = CFrame.lookAt(camera.CFrame.Position, targetPart.Position)
            camera.CFrame = camera.CFrame:Lerp(lookAtCFrame, smoothness)
            
            -- 2. توجيه جسم اللاعب (الشيفت لوك) نحو الهدف دائماً
            if root then
                local gyro = root:FindFirstChild("AimbotGyro") or Instance.new("BodyGyro", root)
                gyro.Name = "AimbotGyro"
                gyro.MaxTorque = Vector3.new(0, math.huge, 0) -- يسمح بالقفز بحرية كما طلبتِ سابقاً
                gyro.P = 30000 -- سرعة الدوران
                
                -- إجبار الجسم على مواجهة الهدف يميناً ويساراً
                gyro.CFrame = CFrame.lookAt(root.Position, Vector3.new(targetPart.Position.X, root.Position.Y, targetPart.Position.Z))
            end
            
            -- 3. ضمان ثبات إزاحة الكاميرا (الشيفت لوك الجانبي)
            if hum and hum.CameraOffset ~= shiftLockOffset then
                hum.CameraOffset = shiftLockOffset
            end
        end
    end)
end
