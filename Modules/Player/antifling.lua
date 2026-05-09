-- [[ Cryptic Hub - Anti-Fling ]]
-- Localized via i18n. الكي: player.antifling.*

return function(Tab, UI)
    local i18n = getgenv().CrypticI18n
    local T    = (i18n and i18n.T) or function(k) return k end

    local RunService = game:GetService("RunService")
    local Players    = game:GetService("Players")
    local lp         = Players.LocalPlayer

    local function Notify(text)
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title    = "Cryptic Hub",
                Text     = text,
                Duration = 3,
            })
        end)
    end

    local isAntiFling = false
    local connection

    local function toggleAntiFling(active)
        isAntiFling = active

        if isAntiFling then
            connection = RunService.Stepped:Connect(function()
                if not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then return end
                for _, otherPlayer in pairs(Players:GetPlayers()) do
                    if otherPlayer ~= lp and otherPlayer.Character then
                        for _, part in pairs(otherPlayer.Character:GetChildren()) do
                            if part:IsA("BasePart") and part.CanCollide then
                                part.CanCollide = false
                            end
                        end
                    end
                end
            end)
        else
            if connection then
                connection:Disconnect()
                connection = nil
            end
        end
    end

    Tab:AddToggle(T("player.antifling.label"), function(active)
        toggleAntiFling(active)
        if active then
            Notify(T("player.antifling.on"))
        end
    end)
end
