-- [[ Cryptic Hub - الطيران الثلاثي الأبعاد المصلح / Fixed 3D Fly ]]

return function(Tab, UI)
    local player = game.Players.LocalPlayer
    local RunService = game:GetService("RunService")
    local StarterGui = game:GetService("StarterGui")
    local cam = workspace.CurrentCamera
    local isFlying = false
    local flySpeed = 50
    local bodyVel, bodyGyro, connection, deathConn

    local function Notify(title, text)
        pcall(function()
            StarterGui:SetCore("SendNotification", {Title = title, Text = text, Duration = 3})
        end)
    end

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

            -- مراقبة الموت
            if deathConn then deathConn:Disconnect() end
            deathConn = hum.Died:Connect(function()
                if not isFlying then return end
                -- تنظيف القديم
                if connection then connection:Disconnect() connection = nil end
                if bodyVel then pcall(function() bodyVel:Destroy() end) bodyVel = nil end
                if bodyGyro then pcall(function() bodyGyro:Destroy() end) bodyGyro = nil end
                -- انتظر إزالة الشخصية الميتة أولاً
                task.wait(0.2)
                -- الآن انتظر الشخصية الجديدة الحية
                local newChar = player.Character
                local newHum = newChar and newChar:FindFirstChild("Humanoid")
                if not newChar or not newHum or newHum.Health <= 0 then
                    newChar = player.CharacterAdded:Wait()
                end
                -- تأكد من تحميل الأجزاء
                newChar:WaitForChild("HumanoidRootPart", 10)
                newChar:WaitForChild("Humanoid", 10)
                task.wait(0.3)
                if isFlying then toggleFly(true, flySpeed) end
            end)

        else
            if connection then connection:Disconnect() end
            if bodyVel then bodyVel:Destroy() end
            if bodyGyro then bodyGyro:Destroy() end
            if deathConn then deathConn:Disconnect() deathConn = nil end
            if hum then hum.PlatformStand = false end
        end
    end

    Tab:AddSpeedControl("طيران / Fly", function(active, value)
        toggleFly(active, value)
        if active then
            Notify("Cryptic Hub", "✈️ تم تفعيل الطيران!\n✈️ Fly activated!")
        end
    end, 50)
end
