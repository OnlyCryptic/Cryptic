-- [[ Cryptic Hub - الطيران الثلاثي الأبعاد المصلح ]]
-- المطور: Arwa | إصلاح الطيران للأعلى والأسفل باستخدام الجويستيك 

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
            bodyGyro.P = 5000 -- ثبات عالي للكاميرا
            
            hum.PlatformStand = true

            connection = RunService.RenderStepped:Connect(function()
                if isFlying and root and bodyVel then
                    local moveDir = hum.MoveDirection
                    
                    if moveDir.Magnitude > 0 then
                        -- 1. استخراج اتجاه الكاميرا (العمق واليمين/اليسار)
                        local look = cam.CFrame.LookVector
                        local right = cam.CFrame.RightVector
                        
                        -- 2. تسطيح اتجاه الكاميرا ليتوافق مع قراءة الجويستيك
                        local flatLook = Vector3.new(look.X, 0, look.Z)
                        if flatLook.Magnitude > 0 then flatLook = flatLook.Unit end
                        
                        local flatRight = Vector3.new(right.X, 0, right.Z)
                        if flatRight.Magnitude > 0 then flatRight = flatRight.Unit end
                        
                        -- 3. حساب قوة الدفع من الجويستيك (للأمام/للخلف واليمين/اليسار)
                        local zInput = moveDir:Dot(flatLook)
                        local xInput = moveDir:Dot(flatRight)
                        
                        -- 4. دمج قوة الجويستيك مع اتجاه الكاميرا الحقيقي (3D)
                        local flyDir = (look * zInput) + (right * xInput)
                        
                        -- 5. تطبيق السرعة في الاتجاه الصحيح
                        if flyDir.Magnitude > 0 then
                            bodyVel.Velocity = flyDir.Unit * flySpeed
                        else
                            bodyVel.Velocity = Vector3.new(0, 0, 0)
                        end
                    else
                        bodyVel.Velocity = Vector3.new(0, 0, 0) -- التوقف التام عند ترك الجويستيك
                    end
                    
                    -- تثبيت دوران اللاعب ليطابق الكاميرا
                    bodyGyro.CFrame = cam.CFrame
                end
            end)
        else
            -- تنظيف الخواص عند إيقاف الطيران
            if connection then connection:Disconnect() end
            if bodyVel then bodyVel:Destroy() end
            if bodyGyro then bodyGyro:Destroy() end
            if hum then hum.PlatformStand = false end
        end
    end

    Tab:AddSpeedControl("طيران 3D", function(active, value)
        toggleFly(active, value)
    end)
end
