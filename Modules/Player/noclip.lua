-- [[ Cryptic Hub - Advanced NoClip ]]
-- Localized via i18n. الكي: player.noclip.*

return function(Tab, UI)
    local i18n = getgenv().CrypticI18n
    local T    = (i18n and i18n.T) or function(k) return k end

    local RunService = game:GetService("RunService")
    local StarterGui = game:GetService("StarterGui")
    local player = game.Players.LocalPlayer
    local noclipActive = false
    local connection

    local originalStates = {}

    local function toggleNoclip(active)
        noclipActive = active

        if noclipActive then
            originalStates = {}

            connection = RunService.Stepped:Connect(function()
                if noclipActive and player.Character then
                    for _, part in pairs(player.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            if originalStates[part] == nil then
                                originalStates[part] = part.CanCollide
                            end
                            part.CanCollide = false
                        end
                    end
                end
            end)
        else
            if connection then
                connection:Disconnect()
                connection = nil
            end

            for part, originalCollideState in pairs(originalStates) do
                if part and part.Parent then
                    part.CanCollide = originalCollideState
                end
            end

            originalStates = {}
        end
    end

    Tab:AddToggle(T("player.noclip.label"), function(active)
        toggleNoclip(active)

        if UI.Logger then
            local actionLog = active and T("player.noclip.log_action_on") or T("player.noclip.log_action_off")
            UI.Logger(T("player.noclip.log_title"), actionLog)
        end

        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title    = "Cryptic Hub",
                Text     = active and T("player.noclip.on") or T("player.noclip.off"),
                Duration = 4,
            })
        end)
    end)
end
