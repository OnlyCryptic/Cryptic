-- [[ Arwa Hub - FreeCam 3D Mobile PRO ]]
-- جويستيك + سحب للشاشة + تثبيت كامل للاعب

return function(Tab, UI)

    local player = game.Players.LocalPlayer
    local RunService = game:GetService("RunService")
    local UIS = game:GetService("UserInputService")
    local cam = workspace.CurrentCamera

    local isFreeCam = false
    local flySpeed = 70
    local connection

    local yaw = 0
    local pitch = 0
    local camPos
    local sensitivity = 0.25

    local lastTouchPos

    local function toggleFreeCam(active, speedValue)
        isFreeCam = active
        flySpeed = speedValue

        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")

        if isFreeCam and root and hum then
            
            -- تثبيت كامل
            root.Anchored = true
            hum.PlatformStand = true
            hum.AutoRotate = false

            cam.CameraType = Enum.CameraType.Scriptable
            camPos = cam.CFrame.Position

            yaw = 0
            pitch = 0

            UI:Notify("🎥 FreeCam Mobile PRO ON")

            -- تحريك الكاميرا بالسحب
            UIS.TouchMoved:Connect(function(touch)
                if not isFreeCam then return end
                
                if lastTouchPos then
                    local delta = touch.Position - lastTouchPos
                    
                    yaw -= delta.X * sensitivity
                    pitch -= delta.Y * sensitivity

                    pitch = math.clamp(pitch, -80, 80)
                end

                lastTouchPos = touch.Position
            end)

            UIS.TouchEnded:Connect(function()
                lastTouchPos = nil
            end)

            connection = RunService.RenderStepped:Connect(function(dt)

                -- حساب اتجاه الكاميرا
                local rotation =
                    CFrame.Angles(0, math.rad(yaw), 0) *
                    CFrame.Angles(math.rad(pitch), 0, 0)

                local moveDir = hum.MoveDirection

                if moveDir.Magnitude > 0 then
                    local forward = rotation.LookVector
                    local right = rotation.RightVector

                    local flatForward = Vector3.new(forward.X, 0, forward.Z).Unit
                    local flatRight = Vector3.new(right.X, 0, right.Z).Unit

                    local zInput = moveDir:Dot(flatForward)
                    local xInput = moveDir:Dot(flatRight)

                    local finalMove =
                        (forward * zInput) +
                        (right * xInput)

                    if finalMove.Magnitude > 0 then
                        camPos += finalMove.Unit * flySpeed * dt
                    end
                end

                cam.CFrame = CFrame.new(camPos) * rotation
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

    Tab:AddSpeedControl("FreeCam 3D Mobile", function(active, value)
        toggleFreeCam(active, value)
    end)

end