-- [[ Cryptic Hub - الطيران الثلاثي الأبعاد المصلح / Fixed 3D Fly ]]
-- المطور: أروى (Arwa) | التحديث: ضبط السرعة الافتراضية على 50 لتتوافق مع المحرك الجديد / Update: Default speed set to 50 to match the new engine

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
                        local look = cam.CFrame.LookVector
                        local right = cam.CFrame.RightVector
                        
                        local flatLook = Vector3.new(look.X, 0, look.Z)
                        if flatLook.Magnitude > 0 then flatLook = flatLook.Unit end
                        
                        local flatRight = Vector3.new(right.X, 0, right.Z)
                        if flatRight.Magnitude > 0 then flatRight = flatRight.Unit end
                        
                        local zInput = moveDir:Dot(flatLook)
                        local xInput = moveDir:Dot(flatRight)
                        
                        local flyDir = (look * zInput) + (right * xInput)
                        
                        if flyDir.Magnitude > 0 then
                            bodyVel.Velocity = flyDir.Unit * flySpeed
                        else
                            bodyVel.Velocity = Vector3.new(0, 0, 0)
                        end
                    else
                        bodyVel.Velocity = Vector3.new(0, 0, 0) 
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

    -- [[ التعديل هنا / Modification Here ]]
    -- أضفنا الرقم 50 في النهاية ليكون هو القيمة الافتراضية عند التحميل / Added 50 at the end to be the default value on load
    Tab:AddSpeedControl("طيران / Fly", function(active, value)
        toggleFly(active, value)
    end, 50)
end
