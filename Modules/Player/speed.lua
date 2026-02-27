-- [[ Cryptic Hub - السرعة ]]
return function(Tab, UI)
    local player = game.Players.LocalPlayer
    Tab:AddSpeedControl("سرعة المشي", function(active, value)
        local hum = player.Character and player.Character:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = active and value or 16 end
    end)
end
