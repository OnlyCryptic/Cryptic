-- [[ Cryptic Hub - 3D Mobile Fly Pro ]]
-- المطور: Arwa | تحديث: نظام الملاحة الفضائية المتكامل
-- هذا الكود يمنحكِ تحكماً كاملاً في جميع الاتجاهات بناءً على نظرة الكاميرا

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
            if bodyVel then bodyVel:Destroy() end
            if bodyGyro then bodyGyro:Destroy() end

            bodyVel = Instance.new("BodyVelocity", root)
            bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bodyVel.Velocity = Vector3.new(0, 0, 0)

            bodyGyro = Instance.new("BodyGyro", root)
            bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            bodyGyro.P = 5000 -- زيادة قوة التثبيت لمنع الارتزاز
            bodyGyro.CFrame = root.CFrame

            hum.PlatformStand = true

            connection = RunService.RenderStepped:Connect(function()
                if isFlying and root and bodyVel then
                    local moveDir = hum.MoveDirection -- اتجاه الجويستيك بالنسبة للعالم
                    
                    if moveDir.Magnitude > 0 then
                        -- ** السر هنا يا أروى **
                        -- نقوم بتحويل اتجاه الحركة ليكون تابعاً لإحداثيات الكاميرا المحلية
                        -- هذا يجعل (للأمام) في الجويستيك يعني (أمام الكاميرا) 
                        -- و(للخلف) يعني (عكس اتجاه الكاميرا) تماماً حتى لو كنتِ تنظرين للسماء
                        
                        local direction = cam.CFrame:VectorToWorldSpace(
                            cam.CFrame:VectorToObjectSpace(moveDir)
                        )
                        
                        -- تطبيق السرعة بناءً على الاتجاه المحسوب
                        bodyVel.Velocity = direction * flySpeed
                    else
                        -- فرامل فورية عند ترك الجويستيك
                        bodyVel.Velocity = Vector3.new(0, 0, 0)
                    end
                    
                    -- جعل اللاعب يواجه دائماً اتجاه نظر الكاميرا لثبات الرؤية
                    bodyGyro.CFrame = cam.CFrame
                end
            end)
        else
            if connection then connection:Disconnect() end
            if bodyVel then bodyVel:Destroy() end
            if bodyGyro then bodyGyro:Destroy() end
            if hum then hum.PlatformStand = false end
            isFlying = false
        end
    end

    Tab:AddSpeedControl("طيران 3D", function(active, value)
        toggleFly(active, value)
        if active then
            UI:Notify("تم تشغيل الطيران الحر | التحكم الآن بيدكِ يا أروى")
        else
            UI:Notify("تم إيقاف الطيران")
        end
    end)
end
