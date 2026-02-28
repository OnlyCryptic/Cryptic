return function(Tab, UI)
    local runService = game:GetService("RunService")
    local lp = game.Players.LocalPlayer
    local isAimbotting = false

    Tab:AddToggle("🔫 إيم بوت على الهدف", function(active)
        isAimbotting = active
        if not active and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            local gyro = lp.Character.HumanoidRootPart:FindFirstChild("AimbotGyro")
            if gyro then gyro:Destroy() end
        end
    end)

    runService.RenderStepped:Connect(function()
        local target = _G.ArwaTarget
        if isAimbotting and target and target.Character and target.Character:FindFirstChild("Head") then
            local camera = workspace.CurrentCamera
            camera.CFrame = CFrame.lookAt(camera.CFrame.Position, target.Character.Head.Position)
            
            local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local gyro = root:FindFirstChild("AimbotGyro") or Instance.new("BodyGyro", root)
                gyro.Name = "AimbotGyro"
                gyro.MaxTorque = Vector3.new(0, math.huge, 0)
                gyro.CFrame = CFrame.lookAt(root.Position, Vector3.new(target.Character.Head.Position.X, root.Position.Y, target.Character.Head.Position.Z))
            end
        end
    end)
end
