-- [[ Cryptic Hub - Advanced WalkSpeed ]]
-- Localized via i18n. الكي: player.speed.*

return function(Tab, UI)
    local i18n = getgenv().CrypticI18n
    local T    = (i18n and i18n.T) or function(k) return k end

    local player     = game.Players.LocalPlayer
    local StarterGui = game:GetService("StarterGui")

    local isSpeedActive = false
    local currentSpeed  = 50

    local function Notify(title, text)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title    = title,
                Text     = text,
                Duration = 3,
            })
        end)
    end

    Tab:AddSpeedControl(T("player.speed.label"), function(active, value)
        isSpeedActive = active
        currentSpeed  = value

        local char = player.Character
        local hum  = char and char:FindFirstChild("Humanoid")

        if hum then
            hum.WalkSpeed = active and value or 16
        end

        if active then
            Notify("Cryptic Hub", T("player.speed.on"))
        end
    end, 50)

    player.CharacterAdded:Connect(function(newChar)
        if isSpeedActive then
            local hum = newChar:WaitForChild("Humanoid", 5)
            if hum then
                hum.WalkSpeed = currentSpeed
            end
        end
    end)
end
