-- [[ Arwa Hub - إيم بوت وشيفت لوك (نظام التثبيت المطلق) ]]
-- المطور: Arwa | الميزات: قفل الكاميرا (Scriptable)، تثبيت 100%، قوة Blox Fruits

return function(Tab, UI)
    local runService = game:GetService("RunService")
    local lp = game.Players.LocalPlayer
    local camera = workspace.CurrentCamera
    
    local isAimbotting = false
    local shiftLockOffset = Vector3.new(1.7, 2, 8) -- إزاحة الكاميرا (يمين، فوق، خلف)

    Tab:AddToggle("🟢 شيفت لوك + إيم بوت (قفل الكاميرا)", function(active)
        isAimbotting = active
        local char = lp.Character
        local hum = char and char:FindFirstChild("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")

        if active then
            -- تحويل الكاميرا لوضع البرمجة لمنع اللعبة من تحريكها
            camera.CameraType = Enum.CameraType.Scriptable
            UI:Notify("✅ تم قفل الكاميرا والجسم على الهدف")
        else
            -- إعادة الكاميرا لوضعها الطبيعي فوراً
            camera.CameraType = Enum.CameraType.Custom
            if hum then hum.CameraOffset = Vector3.new(0, 0, 0) end
            local gyro = root and root:FindFirstChild("AimbotGyro")
            if gyro then gyro:Destroy() end
            UI:Notify("❌ تم فك القفل")
        end
    end)

    runService.RenderStepped:Connect(function()
        local target = _G.ArwaTarget
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")

        if isAimbotting and target and target.Character and target.Character:FindFirstChild("Head") then
            local head = target.Character.Head
            
            -- 1. إجبار الكاميرا على البقاء في وضع Scriptable
            camera.CameraType = Enum.CameraType.Scriptable
            
            -- 2. حساب موقع الكاميرا بحيث تتبع اللاعب من الخلف والجانب (نظام بلوكس فروت)
            -- الكاميرا ستكون دائماً خلف اللاعب بمسافة محددة وتنظر للهدف
            local relativeOffset = root.CFrame:VectorToWorldSpace(shiftLockOffset)
            local camPos = root.Position + relativeOffset
            
            -- تثبيت الكاميرا لتنظر للهدف مباشرة
            camera.CFrame = CFrame.lookAt(camera.CFrame.Position, head.Position)
            
            -- 3. تثبيت جسم اللاعب (Character Pin)
            if root then
                local gyro = root:FindFirstChild("AimbotGyro") or Instance.new("BodyGyro", root)
                gyro.Name = "AimbotGyro"
                gyro.MaxTorque = Vector3.new(0, math.huge, 0) 
                gyro.P = 100000 -- قوة جبارة للتثبيت
                gyro.CFrame = CFrame.lookAt(root.Position, Vector3.new(head.Position.X, root.Position.Y, head.Position.Z))
            end
        elseif not isAimbotting and camera.CameraType == Enum.CameraType.Scriptable then
            -- تأمين العودة للوضع الطبيعي إذا فقد السكربت الهدف
            camera.CameraType = Enum.CameraType.Custom
        end
    end)
end
