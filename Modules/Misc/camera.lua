-- [[ Arwa Hub - FreeCam 3D Joystick ]]
-- تحكم مثل الطيران + تثبيت كامل للاعب

return function(Tab, UI)

    local player = game.Players.LocalPlayer
    local RunService = game:GetService("RunService")
    local cam = workspace.CurrentCamera

    local isFreeCam = false
    local flySpeed = 60
    local connection

    local function toggleFreeCam(active, speedValue)
        isFreeCam = active
        flySpeed = speedValue

        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")

        if isFreeCam and root and hum then
            
            -- تثبيت اللاعب بالكامل
            root.Anchored = true
            hum.PlatformStand = true
            hum.AutoRotate = false

            -- فصل الكاميرا عن اللاعب
            cam.CameraType = Enum.CameraType.Scriptable
            local camPos = cam.CFrame.Position
            local camRot = cam.CFrame - cam.CFrame.Position

            UI:Notify("🎥 FreeCam 3D ON")

            connection = RunService.RenderStepped:Connect(function()

                local moveDir = hum.MoveDirection

                if moveDir.Magnitude > 0 then
                    
                    local look = cam.CFrame.LookVector
                    local right = cam.CFrame.RightVector

                    -- تسطيح الاتجاه لاستخدام قراءة الجويستيك
                    local flatLook = Vector3.new(look.X, 0, look.Z)
                    if flatLook.Magnitude > 0 then
                        flatLook = flatLook.Unit
                    end

                    local flatRight = Vector3.new(right.X, 0, right.Z)
                    if flatRight.Magnitude > 0 then
                        flatRight = flatRight.Unit
                    end

                    local zInput = moveDir:Dot(flatLook)
                    local xInput = moveDir:Dot(flatRight)

                    local finalMove =
                        (look * zInput) +
                        (right * xInput)

                    if finalMove.Magnitude > 0 then
                        camPos += finalMove.Unit * flySpeed * RunService.RenderStepped:Wait()
                    end
                end

                -- تحديث الكاميرا
                cam.CFrame = CFrame.new(camPos) * (cam.CFrame - cam.CFrame.Position)

            end)

        else
            if connection then connection:Disconnect() end
            if root then root.Anchored = false end
            if hum then
                hum.PlatformStand = false
                hum.AutoRotate = true
            end

            cam.CameraType = Enum.CameraType.Custom
            UI:Notify("❌ FreeCam OFF")
        end
    end

    Tab:AddSpeedControl("FreeCam 3D", function(active, value)
        toggleFreeCam(active, value)
    end)

end