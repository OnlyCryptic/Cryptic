-- [[ Cryptic Hub - Checkpoint System ]]

local i18n = getgenv().CrypticI18n
local T = (i18n and i18n.T) or function(k) return k end

return function(Tab, UI)
    local player = game.Players.LocalPlayer
    local StarterGui = game:GetService("StarterGui")

    local checkpointEnabled = false
    local savedPosition = nil

    local function Notify(title, text)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = title,
                Text = text,
                Duration = 3
            })
        end)
    end

    Tab:AddButton("💾 " .. T("teleport.checkpoint.save"), function()
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum  = char and char:FindFirstChildOfClass("Humanoid")

        if not root or not hum then
            Notify("Cryptic Hub", "⚠️ " .. T("teleport.checkpoint.save_fail"))
            return
        end

        if hum.Health <= 0 then
            Notify("Cryptic Hub", "⚠️ " .. T("teleport.checkpoint.dead"))
            return
        end

        savedPosition = root.CFrame
        local pos = root.Position
        local x = math.round(pos.X)
        local y = math.round(pos.Y)
        local z = math.round(pos.Z)
        Notify("Cryptic Hub", string.format("📍 " .. T("teleport.checkpoint.saved_fmt"), x, y, z))
    end)

    Tab:AddToggle(T("teleport.checkpoint.respawn_label"), function(active)
        checkpointEnabled = active

        if active then
            if savedPosition then
                Notify("Cryptic Hub", "✅ " .. T("teleport.checkpoint.enabled"))
            else
                Notify("Cryptic Hub", "⚠️ " .. T("teleport.checkpoint.none"))
            end
        end
    end)

    player.CharacterAdded:Connect(function(newChar)
        if checkpointEnabled and savedPosition then
            local root = newChar:WaitForChild("HumanoidRootPart", 5)
            local hum  = newChar:WaitForChild("Humanoid", 5)

            if root and hum then
                task.wait(0.5)
                hum.WalkSpeed = 0
                root.CFrame = savedPosition
                task.wait(0.1)
                hum.WalkSpeed = 16
            end
        end
    end)
end
