-- [[ Arwa Hub - FreeCam MOBILE ]]
-- تحكم بالسحب + حركة تلقائية للأمام

return function(Tab, UI)
    local Players = game:GetService("Players")
    local UIS = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")

    local camera = workspace.CurrentCamera

    local isFreeCam = false
    local camCF
    local speed = 40
    local sensitivity = 0.25
    local moveForward = false

    local function toggleFreeCam(active)
        isFreeCam = active

        if active then
            camCF = camera.CFrame
            camera.CameraType = Enum.CameraType.Scriptable
            UI:Notify("📱 FreeCam Mobile ON")

            RunService:BindToRenderStep("MobileFreeCam", Enum.RenderPriority.Camera.Value + 1, function(dt)
                
                -- دوران عبر السحب
                local delta = UIS:GetMouseDelta()

                camCF *= CFrame.Angles(
                    math.rad(-delta.Y * sensitivity),
                    math.rad(-delta.X * sensitivity),
                    0
                )

                -- حركة للأمام عند الضغط المستمر
                if moveForward then
                    camCF += camCF.LookVector * speed * dt
                end

                camera.CFrame = camCF
            end)

            -- لمس الشاشة للحركة
            UIS.TouchStarted:Connect(function()
                moveForward = true
            end)

            UIS.TouchEnded:Connect(function()
                moveForward = false
            end)

        else
            camera.CameraType = Enum.CameraType.Custom
            RunService:UnbindFromRenderStep("MobileFreeCam")
            UI:Notify("❌ FreeCam OFF")
        end
    end

    Tab:AddToggle("🎥 FreeCam Mobile", toggleFreeCam)
end