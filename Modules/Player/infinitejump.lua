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

    -- دمج اللغتين في اسم الزر مع تعديل الاسم 
    Tab:AddToggle("قفز لانهائي / Infinite Jump ( روجر ⚔️)", function(active)
        isInfiniteJump = active
        if active then
            -- إشعار التفعيل المزدوج
            UI:Notify("✅ تم تفعيل القفز اللانهائي في Cryptic Hub\n✅ Infinite Jump activated in Cryptic Hub")
        else
            -- إشعار الإيقاف المزدوج
            UI:Notify("❌ تم إيقاف الميزة\n❌ Feature disabled")
        end
    end)
end
