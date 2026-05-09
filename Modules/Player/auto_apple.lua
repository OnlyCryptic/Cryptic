-- [[ Cryptic Hub - Auto Heal Apple ]]
-- يعمل فقط في ماب 189707 ومعك جيمباس التفاحة (Red Apple #818778)
-- Localized via i18n. الكي: player.auto_apple.*

return function(Tab, UI)
    local i18n = getgenv().CrypticI18n
    local T    = (i18n and i18n.T) or function(k) return k end

    local Players    = game:GetService("Players")
    local StarterGui = game:GetService("StarterGui")
    local lp         = Players.LocalPlayer

    if game.PlaceId ~= 189707 then return false end

    local function HasApple()
        for _, tool in pairs(lp.Backpack:GetChildren()) do
            if tool:IsA("Tool") and string.find(string.lower(tool.Name), "apple") then
                return true
            end
        end
        local char = lp.Character
        if char then
            for _, tool in pairs(char:GetChildren()) do
                if tool:IsA("Tool") and string.find(string.lower(tool.Name), "apple") then
                    return true
                end
            end
        end
        return false
    end

    if not HasApple() then return false end

    local isActive  = false
    local isHealing = false

    local function Notify(text)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Cryptic Hub", Text = text, Duration = 3
            })
        end)
    end

    local function FindApple()
        local char = lp.Character
        if char then
            for _, tool in pairs(char:GetChildren()) do
                if tool:IsA("Tool") and string.find(string.lower(tool.Name), "apple") then
                    return tool
                end
            end
        end
        for _, tool in pairs(lp.Backpack:GetChildren()) do
            if tool:IsA("Tool") and string.find(string.lower(tool.Name), "apple") then
                return tool
            end
        end
        return nil
    end

    local function HealCycle()
        if isHealing then return end
        isHealing = true

        local char = lp.Character
        local hum  = char and char:FindFirstChild("Humanoid")

        if hum and hum.Health > 0 and hum.Health < hum.MaxHealth then
            local apple = FindApple()

            if apple then
                local currentEquipped = nil
                for _, tool in pairs(char:GetChildren()) do
                    if tool:IsA("Tool") and tool ~= apple then
                        currentEquipped = tool; break
                    end
                end

                if apple.Parent ~= char then
                    hum:EquipTool(apple)
                    task.wait(0.5)
                end

                apple:Activate()
                task.wait(1.5)

                if currentEquipped and currentEquipped.Parent == lp.Backpack then
                    hum:EquipTool(currentEquipped)
                else
                    hum:UnequipTools()
                end

                task.wait(8.1)
            end
        end

        isHealing = false
    end

    Tab:AddToggle(T("player.auto_apple.label"), function(state)
        isActive = state

        if state then
            Notify(T("player.auto_apple.on"))
            task.spawn(function()
                while isActive do
                    local char = lp.Character
                    local hum  = char and char:FindFirstChild("Humanoid")
                    if hum and hum.Health > 0 and hum.Health < hum.MaxHealth and not isHealing then
                        HealCycle()
                    end
                    task.wait(0.1)
                end
            end)
        else
            Notify(T("player.auto_apple.off"))
        end
    end)
end
