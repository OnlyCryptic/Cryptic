return function(Tab, UI)
    local isAimbot = false
    game:GetService("RunService").RenderStepped:Connect(function()
        local target = _G.ArwaTarget
        if isAimbot and target and target.Character and target.Character:FindFirstChild("Head") then
            workspace.CurrentCamera.CFrame = CFrame.lookAt(workspace.CurrentCamera.CFrame.Position, target.Character.Head.Position)
        end
    end)

    Tab:AddToggle("🔫 تشغيل الإيم بوت", function(active)
        isAimbot = active
    end)
end
