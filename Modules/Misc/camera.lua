-- [[ Arwa Hub - FreeCam Mobile PRO ]]
-- تثبيت اللاعب + دوران Touch حقيقي + حركة سلسة

return function(Tab, UI)

    local Players = game:GetService("Players")
    local UIS = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")

    local lp = Players.LocalPlayer
    local camera = workspace.CurrentCamera

    local isFreeCam = false
    local camCF
    local velocity = Vector3.zero

    local speed = 50
    local sensitivity = 0.18
    local smoothness = 0.12

    local movingForward = false
    local lastTouchPos

    local function toggleFreeCam(state)
        isFreeCam = state

        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")

        if state and root then
            
            -- تثبيت الشخصية
            root.Anchored = true

            camCF = camera.CFrame
            camera.CameraType = Enum.CameraType.Scriptable

            UI:Notify("📱 FreeCam Mobile PRO ON")

            -- تتبع السحب الحقيقي
            UIS.TouchStarted:Connect(function(touch)
                lastTouchPos = touch.Position
                movingForward = true
            end)

            UIS.TouchMoved:Connect(function(touch)
                if not lastTouchPos then return end

                local delta = touch.Position - lastTouchPos
                lastTouchPos = touch.Position

                camCF *= CFrame.Angles(
                    math.rad(-delta.Y * sensitivity),
                    math.rad(-delta.X * sensitivity),
                    0
                )
            end)

            UIS.TouchEnded:Connect(function()
                movingForward = false
                lastTouchPos = nil
            end)

            RunService:BindToRenderStep("MobileFreeCamPro", Enum.RenderPriority.Camera.Value + 1, function(dt)

                local targetVel = Vector3.zero

                if movingForward then
                    targetVel = camCF.LookVector * speed
                end

                -- سلاسة احترافية
                velocity = velocity:Lerp(targetVel, smoothness)

                camCF += velocity * dt
                camera.CFrame = camCF
            end)

        else
            -- رجوع طبيعي
            if root then root.Anchored = false end
            camera.CameraType = Enum.CameraType.Custom
            RunService:UnbindFromRenderStep("MobileFreeCamPro")

            UI:Notify("❌ FreeCam OFF")
        end
    end

    Tab:AddToggle("🎥 FreeCam Mobile PRO", toggleFreeCam)

end