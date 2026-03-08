-- [[ Cryptic Hub - ميزة القفز اللانهائي / Infinite Jump ]]
-- المطور: Cryptic | الميزة: قفز مستمر في الهواء / Feature: Continuous jumping in mid-air

return function(Tab, UI)
    local userInputService = game:GetService("UserInputService")
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

    -- دمج اللغتين في اسم الزر
    Tab:AddToggle("قفز لانهائي / Infinite Jump", function(active)
        isInfiniteJump = active
        
        -- إشعار التفعيل المزدوج فقط (إطفاء صامت)
        if active then
            UI:Notify("✅ تم تفعيل القفز اللانهائي في Cryptic Hub\n✅ Infinite Jump activated in Cryptic Hub")
        end
        -- إذا تم إيقاف الميزة (active = false) لن يظهر أي إشعار وتنطفئ بصمت
    end)
end
