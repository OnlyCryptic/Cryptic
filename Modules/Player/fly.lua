-- [[ Cryptic Hub - 3D Mobile Fly ]]
-- هذا الكود يجعل الطيران يتبع اتجاه نظرك تماماً باستخدام الجويستيك

return function(Tab, UI)
    local player = game.Players.LocalPlayer
    local RunService = game:GetService("RunService")
    local cam = workspace.CurrentCamera
    
    local isFlying = false
    local flySpeed = 50
    local bodyVel, bodyGyro
    local connection

    local function toggleFly(active, speedValue)
        isFlying = active
        flySpeed = speedValue
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")

        if isFlying and root and hum then
            -- تنظيف أي قوى قديمة
            if bodyVel then bodyVel:Destroy() end
            if bodyGyro then bodyGyro:Destroy() end

            -- إعداد قوى الحركة والثبات
            bodyVel = Instance.new("BodyVelocity", root)
            bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bodyVel.Velocity = Vector3.new(0, 0, 0)

            bodyGyro = Instance.new("BodyGyro", root)
            bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            bodyGyro.P = 3000 -- قوة الدوران لمواجهة الكاميرا
            bodyGyro.CFrame = root.CFrame

            hum.PlatformStand = true -- تعطيل الوقوف العادي للطيران بسلاسة

            -- الحلقة الأساسية للطيران (التحكم الثلاثي الأبعاد)
            connection = RunService.RenderStepped:Connect(function()
                if isFlying and root and bodyVel then
                    -- جلب اتجاه الجويستيك (MoveDirection)
                    local moveDir = hum.MoveDirection
                    
                    if moveDir.Magnitude > 0 then
                        -- تحويل حركة الجويستيك لتكون نسبية للكاميرا
                        -- إذا ضغطت للأمام، ستطير باتجاه ما تراه الكاميرا (فوق أو تحت)
                        local cameraCFrame = cam.CFrame
                        
                        -- حساب المتجه الاتجاهي:
                        -- الـ LookVector يحدد الأمام والخلف (بما في ذلك الصعود والنزول)
                        -- الـ RightVector يحدد اليمين واليسار
                        
                        -- نأخذ قيمة الأمام/الخلف من الجويستيك ونضربها في اتجاه الكاميرا
                        local forwardMove = cameraCFrame.LookVector * (moveDir:Dot(cameraCFrame.LookVector) / cameraCFrame.LookVector.Magnitude)
                        
                        -- نستخدم ميكانيكية بسيطة: طالما تحرك الجويستيك، اتبع اتجاه الكاميرا
                        -- هذا السطر هو "السر" في الطيران الثلاثي الأبعاد:
                        bodyVel.Velocity = cam.CFrame.LookVector * flySpeed * (moveDir.Magnitude)
                        
                        -- إذا كنتِ تحركين الجويستيك لليمين أو اليسار فقط:
                        if math.abs(moveDir:Dot(cameraCFrame.RightVector)) > 0.5 then
                             bodyVel.Velocity = (cam.CFrame.LookVector * 0.5 + moveDir) * flySpeed
                        end
                    else
                        -- توقف تام عند ترك الجويستيك (Brake)
                        bodyVel.Velocity = Vector3.new(0, 0, 0)
                    end
                    
                    -- جعل جسم اللاعب يواجه دائماً الكاميرا (ثبات 3D)
                    bodyGyro.CFrame = cam.CFrame
                end
            end)
        else
            -- إغلاق الطيران وتنظيف الأدوات
            if connection then connection:Disconnect() end
            if bodyVel then bodyVel:Destroy() end
            if bodyGyro then bodyGyro:Destroy() end
            if hum then hum.PlatformStand = false end
            isFlying = false
        end
    end

    -- إضافة التحكم في واجهة كربتك
    Tab:AddSpeedControl("طيران", function(active, value)
        toggleFly(active, value)
        if active then
            UI:Notify("الطيران الثلاثي الأبعاد مفعّل | استمتع يا أروى")
        else
            UI:Notify("تم إيقاف الطيران")
        end
    end)
end
