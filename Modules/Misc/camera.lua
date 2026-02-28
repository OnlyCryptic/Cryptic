-- [[ Arwa Hub - FreeCam Mobile V8 ]]
-- بدون قلتش | دوران منفصل | سلاسة احترافية | تثبيت كامل

return function(Tab, UI)

    local player = game.Players.LocalPlayer
    local RunService = game:GetService("RunService")
    local UIS = game:GetService("UserInputService")
    local cam = workspace.CurrentCamera

    local isFreeCam = false
    local flySpeed = 80

    local yaw = 0
    local pitch = 0

    local targetYaw = 0
    local targetPitch = 0

    local camPos
    local sensitivity = 0.40
    local smoothness = 0.18

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

            UI:Notify("🎥 FreeCam V8 ON")

            -- دوران (منفصل تماماً عن الجويستيك)
            UIS.InputChanged:Connect(function(input)
                if not isFreeCam then return end
                if input.UserInputType == Enum.UserInputType.Touch then
                    
                    targetYaw -= input.Delta.X * sensitivity
                    targetPitch -= input.Delta.Y * sensitivity
                    targetPitch = math.clamp(targetPitch, -85, 85)
                end
            end)

            RunService:BindToRenderStep("FreeCamV8", Enum.RenderPriority.Camera.Value + 1, function(dt)

                -- سلاسة دوران
                yaw = yaw + (targetYaw - yaw) * smoothness
                pitch = pitch + (targetPitch - pitch) * smoothness

                local rotation =
                    CFrame.Angles(0, math.rad(yaw), 0) *
                    CFrame.Angles(math.rad(pitch), 0, 0)

                -- حركة بالجويستيك فقط
                local moveDir = hum.MoveDirection
                local moveVector = Vector3.zero

                if moveDir.Magnitude > 0 then
                    local forward = rotation.LookVector
                    local right = rotation.RightVector

                    local flatForward = Vector3.new(forward.X, 0, forward.Z)
                    if flatForward.Magnitude > 0 then
                        flatForward = flatForward.Unit
                    end

                    local flatRight = Vector3.new(right.X, 0, right.Z)
                    if flatRight.Magnitude > 0 then
                        flatRight = flatRight.Unit
                    end

                    local zInput = moveDir:Dot(flatForward)
                    local xInput = moveDir:Dot(flatRight)

                    moveVector = (forward * zInput) + (right * xInput)
                end

                if moveVector.Magnitude > 0 then
                    camPos += moveVector.Unit * flySpeed * dt
                end

                cam.CFrame = CFrame.new(camPos) * rotation
            end)

        else
            RunService:UnbindFromRenderStep("FreeCamV8")

            if root then root.Anchored = false end
            if hum then
                hum.PlatformStand = false
                hum.AutoRotate = true
            end

            cam.CameraType = Enum.CameraType.Custom
            UI:Notify("❌ FreeCam OFF")
        end
    end

    Tab:AddSpeedControl("FreeCam V8", function(active, value)
        toggleFreeCam(active, value)
    end)

end