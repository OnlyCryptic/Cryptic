return function(Tab, UI)
    local isSitting = false
    game:GetService("RunService").Heartbeat:Connect(function()
        local target = _G.ArwaTarget
        local lp = game.Players.LocalPlayer
        if isSitting and target and target.Character and target.Character:FindFirstChild("Head") then
            lp.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
            lp.Character.HumanoidRootPart.CFrame = target.Character.Head.CFrame * CFrame.new(0, 2.2, 0)
        end
    end)

    Tab:AddToggle("🪑 جلوس على الرأس", function(active)
        isSitting = active
        if game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.Sit = active
        end
    end)
end
