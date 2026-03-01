-- [[ Cryptic Hub - ميزة القفز اللانهائي ]]
-- المطور: Cryptic | الميزة: قفز مستمر في الهواء

return function(Tab, UI)
    local userInputService = game:GetService("UserInputService")
    local lp = game.Players.LocalPlayer
    local isInfiniteJump = false

    -- مستمع لطلب القفز
    userInputService.JumpRequest:Connect(function()
        if isInfiniteJump then
            local char = lp.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)

    Tab:AddToggle("قفز لانهائي", function(active)
        isInfiniteJump = active
        if active then
            UI:Notify("✅ تم تفعيل القفز اللانهائي في Cryptic Hub")
        else
            UI:Notify("❌ تم إيقاف الميزة")
        end
    end)
end
