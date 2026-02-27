-- ملف ميزة الطيران ثلاثي الأبعاد (3D Movement)
-- يتحرك اللاعب في الاتجاه الذي تنظر إليه الكاميرا باستخدام الجويستيك
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
        local cam = workspace.CurrentCamera

        if isFlying and root and hum then
            -- إنشاء القوى الفيزيائية للثبات والطيران
            bodyVel = Instance.new("BodyVelocity", root)
            bodyVel.MaxForce = Vector3.new(1, 1, 1) * 10^6
            bodyVel.Velocity = Vector3.new(0, 0, 0)

            bodyGyro = Instance.new("BodyGyro", root)
            bodyGyro.MaxTorque = Vector3.new(1, 1, 1) * 10^6
            bodyGyro.CFrame = root.CFrame

            -- تعطيل وضع المشي العادي لضمان سلاسة الحركة في الهواء
            hum.PlatformStand = true 

            task.spawn(function()
                while isFlying and root and hum and bodyVel do
                    local moveDir = hum.MoveDirection -- اتجاه الحركة من الجويستيك
                    
                    if moveDir.Magnitude > 0 then
                        -- تحويل حركة الجويستيك لتكون ثلاثية الأبعاد بناءً على اتجاه الكاميرا
                        -- إذا وجهتِ الكاميرا للأعلى وضغطتِ للأمام، سيتم استخدام LookVector للطيران للأعلى
                        local cameraCFrame = cam.CFrame
                        local look = cameraCFrame.LookVector
                        local right = cameraCFrame.RightVector
                        
                        -- حساب المتجه المحلي للحركة
                        local localMove = cameraCFrame:VectorToObjectSpace(moveDir)
                        
                        -- تطبيق السرعة في الاتجاه الثلاثي الأبعاد
                        bodyVel.Velocity = (look * -localMove.Z + right * localMove.X) * flySpeed
                    else
                        -- التوقف التام في الهواء عند ترك الجويستيك
                        bodyVel.Velocity = Vector3.new(0, 0, 0)
                    end
                    
                    -- جعل جسم اللاعب يواجه دائماً اتجاه الكاميرا
                    bodyGyro.CFrame = cam.CFrame
                    task.wait()
                end
            end)
        else
            -- تنظيف الأدوات وإعادة اللاعب للوضع الطبيعي عند الإغلاق
            if bodyVel then bodyVel:Destroy() end
            if bodyGyro then bodyGyro:Destroy() end
            if hum then hum.PlatformStand = false end
            isFlying = false
        end
    end

    -- إضافة التحكم للواجهة بنفس التصميم الذي أعجبك
    Tab:AddSpeedControl("طيران 3D", function(active, value)
        toggleFly(active, value)
        if active then
            UI:Notify("الطيران ثلاثي الأبعاد مفعّل")
        else
            UI:Notify("تم إيقاف الطيران")
        end
    end)
end
