-- [[ Cryptic Hub - Teleport to Target ]]

return function(Tab, UI)
    local Players = game:GetService("Players")
    local StarterGui = game:GetService("StarterGui")
    local lp = Players.LocalPlayer

    local i18n = getgenv().CrypticI18n
    local T = (i18n and i18n.T) or function(k) return k end

    local function Notify(text)
        pcall(function() StarterGui:SetCore("SendNotification", {Title = "Cryptic Hub", Text = text, Duration = 3}) end)
    end

    Tab:AddButton(T("combat.tp.label"), function()
        local target = _G.ArwaTarget
        if not target or not target.Character then
            Notify(T("combat.common.no_target"))
            return
        end

        local char = lp.Character
        if not char then return end

        local myRoot = char:FindFirstChild("HumanoidRootPart")
        local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
        if not myRoot or not tRoot then return end

        myRoot.CFrame = tRoot.CFrame * CFrame.new(0, 0, -3)
        Notify(string.format(T("combat.tp.success_fmt"), target.DisplayName))
    end)
end
