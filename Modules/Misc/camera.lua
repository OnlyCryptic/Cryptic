-- [[ Arwa Hub - FreeCam PRO ]]
-- حركة احترافية + دوران ماوس سلس + تسارع

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
    local sensitivity = 0.2
    local smoothness = 0.15

    local keys = {
        W = false,
        A = false,
        S = false,
        D = false,
        E = false,
        Q = false
    }

    -- إدخال الكيبورد
    UIS.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if keys[input.KeyCode.Name] ~= nil then
            keys[input.KeyCode.Name] = true
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if keys[input.KeyCode.Name] ~= nil then
            keys[input.KeyCode.Name] = false
        end
    end)

    local function getMoveVector()
        local move = Vector3.zero
        if keys.W then move += Vector3.new(0,0,-1) end
        if keys.S then move += Vector3.new(0,0,1) end
        if keys.A then move += Vector3.new(-1,0,0) end
        if keys.D then move += Vector3.new(1,0,0) end
        if keys.E then move += Vector3.new(0,1,0) end
        if keys.Q then move += Vector3.new(0,-1,0) end
        return move
    end

    local function toggleFreeCam(active)
        isFreeCam = active
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")

        if active and root then
            root.Anchored = true
            camCF = camera.CFrame
            UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
            UI:Notify("✅ FreeCam PRO Activated")

            RunService:BindToRenderStep("FreeCam", Enum.RenderPriority.Camera.Value + 1, function(dt)
                -- دوران الماوس
                local delta = UIS:GetMouseDelta()
                camCF *= CFrame.Angles(
                    math.rad(-delta.Y * sensitivity),
                    math.rad(-delta.X * sensitivity),
                    0
                )

                -- حركة
                local moveDir = getMoveVector()
                if moveDir.Magnitude > 0 then
                    moveDir = moveDir.Unit
                end

                local targetVel =
                    (camCF.LookVector * -moveDir.Z +
                     camCF.RightVector * moveDir.X +
                     Vector3.new(0,1,0) * moveDir.Y) * speed

                velocity = velocity:Lerp(targetVel, smoothness)

                camCF += velocity * dt
                camera.CFrame = camCF
            end)

        else
            if root then root.Anchored = false end
            UIS.MouseBehavior = Enum.MouseBehavior.Default
            RunService:UnbindFromRenderStep("FreeCam")
            UI:Notify("❌ FreeCam Disabled")
        end
    end

    Tab:AddToggle("🎥 FreeCam PRO", toggleFreeCam)
end