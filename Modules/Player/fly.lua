-- ملف ميزة الطيران (fly.lua)
return function(Tab, UI)
    local player = game.Players.LocalPlayer
    local mouse = player:GetMouse()
    local bodyVel, bodyGyro
    local isFlying = false
    local flySpeed = 50

    -- وظيفة تشغيل/إيقاف الطيران
    local function toggleFly(active, speedValue)
        isFlying = active
        flySpeed = speedValue
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")

        if isFlying and root then
            -- إنشاء أدوات التحكم في الحركة
            bodyVel = Instance.new("BodyVelocity", root)
            bodyVel.MaxForce = Vector3.new(1, 1, 1) * 10^6
            bodyVel.Velocity = Vector3.new(0, 0, 0)

            bodyGyro = Instance.new("BodyGyro", root)
            bodyGyro.MaxTorque = Vector3.new(1, 1, 1) * 10^6
            bodyGyro.CFrame = root.CFrame

            -- حلقة التحكم في الاتجاه (Loop)
            task.spawn(function()
                while isFlying and root and bodyVel do
                    -- التحكم يعتمد على اتجاه الكاميرا
                    local cam = workspace.CurrentCamera
                    bodyVel.Velocity = cam.CFrame.LookVector * flySpeed
                    bodyGyro.CFrame = cam.CFrame
                    task.wait()
                end
            end)
        else
            -- تنظيف الأدوات عند الإيقاف
            if bodyVel then bodyVel:Destroy() end
            if bodyGyro then bodyGyro:Destroy() end
            isFlying = false
        end
    end

    -- إضافة التحكم للواجهة بنفس تصميم السرعة
    Tab:AddSpeedControl("طيران", function(active, value)
        toggleFly(active, value)
        if active then
            UI:Notify("تم تفعيل الطيران بسرعة: " .. value)
        else
            UI:Notify("تم إيقاف الطيران")
        end
    end)
end
