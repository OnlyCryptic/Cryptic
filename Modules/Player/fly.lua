-- ملف ميزة الطيران المطور (الجويستيك)
return function(Tab, UI)
    local player = game.Players.LocalPlayer
    local isFlying = false
    local flySpeed = 50
    local bodyVel, bodyGyro

    local function toggleFly(active, speedValue)
        isFlying = active
        flySpeed = speedValue
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")

        if isFlying and root and hum then
            -- إعداد القوى الفيزيائية
            bodyVel = Instance.new("BodyVelocity", root)
            bodyVel.MaxForce = Vector3.new(1, 1, 1) * 10^6
            bodyVel.Velocity = Vector3.new(0, 0.1, 0) -- رفعة بسيطة للثبات

            bodyGyro = Instance.new("BodyGyro", root)
            bodyGyro.MaxTorque = Vector3.new(1, 1, 1) * 10^6
            bodyGyro.CFrame = root.CFrame

            -- تعطيل الجاذبية مؤقتاً لضمان سلاسة الطيران
            hum.PlatformStand = true 

            task.spawn(function()
                while isFlying and root and hum and bodyVel do
                    -- استخدام MoveDirection المرتبط بالدائرة (Joystick)
                    local moveDir = hum.MoveDirection
                    
                    if moveDir.Magnitude > 0 then
                        -- التحرك في اتجاه الجويستيك بالسرعة المحددة
                        bodyVel.Velocity = moveDir * flySpeed
                    else
                        -- التوقف في الهواء عند ترك الجويستيك
                        bodyVel.Velocity = Vector3.new(0, 0, 0)
                    end
                    
                    -- الحفاظ على توازن اللاعب وتوجيهه مع الكاميرا
                    bodyGyro.CFrame = workspace.CurrentCamera.CFrame
                    task.wait()
                end
            end)
        else
            -- تنظيف عند الإغلاق
            if bodyVel then bodyVel:Destroy() end
            if bodyGyro then bodyGyro:Destroy() end
            if hum then hum.PlatformStand = false end
            isFlying = false
        end
    end

    -- إضافة التحكم للواجهة
    Tab:AddSpeedControl("طيران الجويستيك", function(active, value)
        toggleFly(active, value)
        if active then
            UI:Notify("طيران الجويستيك مفعّل | السرعة: " .. value)
        else
            UI:Notify("تم إيقاف الطيران")
        end
    end)
end
