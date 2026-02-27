return function(Tab, UI)
    Tab:AddSpeedControl("سرعة المشي", function(enabled, value)
        local char = game.Players.LocalPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if hum then
            hum.WalkSpeed = enabled and value or 16
        end
    end)
end
