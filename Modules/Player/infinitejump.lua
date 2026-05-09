-- [[ Cryptic Hub - ميزة القفز اللانهائي / Infinite Jump ]]
-- المطور: Cryptic | الميزة: قفز مستمر في الهواء / Feature: Continuous jumping in mid-air

return function(Tab, UI)
    local userInputService = game:GetService("UserInputService")
    local StarterGui = game:GetService("StarterGui")
    local lp = game.Players.LocalPlayer
    local isInfiniteJump = false

    -- مستمع لطلب القفز / Jump request listener
    userInputService.JumpRequest:Connect(function()
        if isInfiniteJump then
            local char = lp.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)

    -- زر التبديل مع إشعارات روبلوكس الرسمية
    Tab:AddToggle("قفز لانهائي / Infinite Jump", function(active)
        isInfiniteJump = active
        
        -- إشعار التفعيل المزدوج فقط (إطفاء صامت)
        if active then
            pcall(function()
                StarterGui:SetCore("SendNotification", {
                    Title = "Cryptic Hub",
                    Text = "✅ تم تفعيل القفز اللانهائي\n✅ Infinite Jump activated",
                    Duration = 4
                })
            end)
        end
    end)
end
