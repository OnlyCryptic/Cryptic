-- [[ Arwa Hub - الطيران الثلاثي الأبعاد ]]
-- المطور: Arwa | تحكم كامل يتبع الكاميرا والجويستيك

return function(Tab, UI)
    local player = game.Players.LocalPlayer
    local RunService = game:GetService("RunService")
    local cam = workspace.CurrentCamera
    local isFlying = false
    local flySpeed = 50
    local bodyVel, bodyGyro, connection

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
            
            bodyGyro = Instance.new("BodyGyro", root)
            bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            bodyGyro.P = 5000
            
            hum.PlatformStand = true

            connection = RunService.RenderStepped:Connect(function()
                if isFlying and root and bodyVel then
                    local moveDir = hum.MoveDirection
                    if moveDir.Magnitude > 0 then
                        -- نظام التحكم الثلاثي الأبعاد: يطابق الجويستيك مع اتجاه الكاميرا
                        local direction = cam.CFrame:VectorToWorldSpace(cam.CFrame:VectorToObjectSpace(moveDir))
                        bodyVel.Velocity = direction * flySpeed
                    else
                        bodyVel.Velocity = Vector3.new(0, 0.1, 0) -- ثبات في الهواء
                    end
                    bodyGyro.CFrame = cam.CFrame
                end
            end)
        else
            if connection then connection:Disconnect() end
            if bodyVel then bodyVel:Destroy() end
            if bodyGyro then bodyGyro:Destroy() end
            if hum then hum.PlatformStand = false end
        end
    end

    Tab:AddSpeedControl("طيران 3D", function(active, value)
        toggleFly(active, value)
        UI:Notify(active and "تم تشغيل الطيران الحر" or "تم إيقاف الطيران")
    end)
end
