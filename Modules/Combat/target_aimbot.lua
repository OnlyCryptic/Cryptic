-- [[ Cryptic Hub - Aim Bot ]]

return function(Tab, UI)
    local runService = game:GetService("RunService")
    local players = game:GetService("Players")
    local StarterGui = game:GetService("StarterGui")
    local lp = players.LocalPlayer
    local camera = workspace.CurrentCamera

    local i18n = getgenv().CrypticI18n
    local T = (i18n and i18n.T) or function(k) return k end

    local isAimbotting = false
    local shiftLockOffset = Vector3.new(1.7, 0.5, 0)

    local function Notify(text)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Cryptic Hub",
                Text = text,
                Duration = 5,
            })
        end)
    end

    Tab:AddToggle(T("combat.aimbot.label"), function(active)
        isAimbotting = active
        local char = lp.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")

        if active then
            if not _G.ArwaTarget or not _G.ArwaTarget.Character then
                isAimbotting = false
                Notify(T("combat.common.no_target"))
                return
            end
            if hum then hum.CameraOffset = shiftLockOffset end
            Notify(string.format(T("combat.aimbot.on_fmt"), _G.ArwaTarget.DisplayName))
        else
            if hum then hum.CameraOffset = Vector3.new(0, 0, 0) end
            if root then
                local gyro = root:FindFirstChild("CrypticGyro")
                if gyro then gyro:Destroy() end
            end
            Notify(T("combat.aimbot.off"))
        end
    end)

    runService.RenderStepped:Connect(function()
        local target = _G.ArwaTarget
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        if isAimbotting and target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local targetChest = target.Character.HumanoidRootPart
            camera.CFrame = CFrame.lookAt(camera.CFrame.Position, targetChest.Position)

            if root then
                local gyro = root:FindFirstChild("CrypticGyro") or Instance.new("BodyGyro", root)
                gyro.Name = "CrypticGyro"
                gyro.MaxTorque = Vector3.new(0, math.huge, 0)
                gyro.P = 100000
                gyro.D = 100
                gyro.CFrame = CFrame.lookAt(root.Position, Vector3.new(targetChest.Position.X, root.Position.Y, targetChest.Position.Z))
            end

            if hum and hum.CameraOffset ~= shiftLockOffset then
                hum.CameraOffset = shiftLockOffset
            end
        end
    end)
end
