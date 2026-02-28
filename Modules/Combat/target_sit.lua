return function(Tab, UI)
    local runService = game:GetService("RunService")
    local lp = game.Players.LocalPlayer
    local isSitting = false

    Tab:AddToggle("🪑 الجلوس على رأس الهدف", function(active)
        isSitting = active
        if lp.Character and lp.Character:FindFirstChild("Humanoid") then
            lp.Character.Humanoid.Sit = active
        end
    end)

    runService.Heartbeat:Connect(function()
        local target = _G.ArwaTarget
        if isSitting and target and target.Character and target.Character:FindFirstChild("Head") then
            local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
            if root then
                root.Velocity = Vector3.new(0,0,0)
                root.CFrame = target.Character.Head.CFrame * CFrame.new(0, 2.2, 0)
            end
        end
    end)
end
