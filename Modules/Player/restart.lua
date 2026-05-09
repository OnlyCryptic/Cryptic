-- [[ Cryptic Hub - Restart (die) ]]
-- يقتل الشخصية بكل طريقة ممكنة + ينطفي تلقائياً عند الموت
-- Localized via i18n. الكي: player.restart.*

return function(Tab, UI)
    local i18n = getgenv().CrypticI18n
    local T    = (i18n and i18n.T) or function(k) return k end

    local Players    = game:GetService("Players")
    local StarterGui = game:GetService("StarterGui")
    local lp         = Players.LocalPlayer

    local function Notify(text)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title    = "Cryptic Hub",
                Text     = text,
                Duration = 3,
            })
        end)
    end

    local function ForceKill()
        local char = lp.Character
        if not char then
            pcall(function() lp:LoadCharacter() end)
            return
        end

        local hum = char:FindFirstChildOfClass("Humanoid")

        if hum then
            pcall(function() hum.Health = 0 end)
        end

        task.delay(0.15, function()
            local c = lp.Character
            local h = c and c:FindFirstChildOfClass("Humanoid")
            if h and h.Health > 0 then
                pcall(function() lp:LoadCharacter() end)
            end
        end)

        task.delay(0.3, function()
            local c = lp.Character
            local r = c and c:FindFirstChild("HumanoidRootPart")
            if r then pcall(function() r:Destroy() end) end
        end)

        task.delay(0.5, function()
            local c = lp.Character
            local h = c and c:FindFirstChildOfClass("Humanoid")
            if (h and h.Health > 0) or not c then
                pcall(function() lp:LoadCharacter() end)
            end
        end)
    end

    Tab:AddAddAutoOffToggle(T("player.restart.label"), function(active)
        if active then
            Notify(T("player.restart.on"))
            ForceKill()
        end
    end)
end
