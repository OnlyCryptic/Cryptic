-- [[ Cryptic Hub - Infinite Jump ]]
-- Localized via i18n. الكي: player.infinitejump.*

return function(Tab, UI)
    local i18n = getgenv().CrypticI18n
    local T    = (i18n and i18n.T) or function(k) return k end

    local userInputService = game:GetService("UserInputService")
    local StarterGui       = game:GetService("StarterGui")
    local lp               = game.Players.LocalPlayer
    local isInfiniteJump   = false

    userInputService.JumpRequest:Connect(function()
        if isInfiniteJump then
            local char = lp.Character
            local hum  = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)

    Tab:AddToggle(T("player.infinitejump.label"), function(active)
        isInfiniteJump = active

        if active then
            pcall(function()
                StarterGui:SetCore("SendNotification", {
                    Title    = "Cryptic Hub",
                    Text     = T("player.infinitejump.on"),
                    Duration = 4,
                })
            end)
        end
    end)
end
