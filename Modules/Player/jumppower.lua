-- [[ Cryptic Hub - Jump Power (Bypass) ]]
-- Localized via i18n. الكي: player.jumppower.*

return function(Tab, UI)
    local i18n = getgenv().CrypticI18n
    local T    = (i18n and i18n.T) or function(k) return k end

    local Players      = game:GetService("Players")

    local lp           = Players.LocalPlayer
    local isActive     = false
    local jumpValue    = 100
    local charConn     = nil
    local deathConn    = nil
    local changedJP    = nil
    local changedJH    = nil

    -- حساب JumpHeight مسبقاً
    local function toHeight(v) return (v * v) / (2 * 196.2) end

    local function applyJumpPower(hum, value)
        if not hum or not hum.Parent then return end
        pcall(function() hum.JumpPower = value end)
        pcall(function()
            if sethiddenproperty then
                sethiddenproperty(hum, "JumpPower", value)
            end
        end)
        pcall(function() hum.JumpHeight = toHeight(value) end)
    end

    local function cleanup()
        if changedJP then changedJP:Disconnect() changedJP = nil end
        if changedJH then changedJH:Disconnect() changedJH = nil end
    end

    local function activateOnChar(char)
        cleanup()
        local hum = char:WaitForChild("Humanoid", 10)
        if not hum then return end

        -- تطبيق فوري
        applyJumpPower(hum, jumpValue)

        -- Changed events فقط — بدون Heartbeat لتفادي اللاق
        changedJP = hum:GetPropertyChangedSignal("JumpPower"):Connect(function()
            if isActive and math.abs(hum.JumpPower - jumpValue) > 0.1 then
                pcall(function() hum.JumpPower = jumpValue end)
                pcall(function()
                    if sethiddenproperty then sethiddenproperty(hum, "JumpPower", jumpValue) end
                end)
            end
        end)

        changedJH = hum:GetPropertyChangedSignal("JumpHeight"):Connect(function()
            if isActive then
                local expected = toHeight(jumpValue)
                if math.abs(hum.JumpHeight - expected) > 0.01 then
                    pcall(function() hum.JumpHeight = expected end)
                end
            end
        end)

        if deathConn then deathConn:Disconnect() deathConn = nil end
        deathConn = hum.Died:Connect(function() cleanup() end)
    end

    charConn = lp.CharacterAdded:Connect(function(newChar)
        if isActive then
            task.wait(0.3)
            activateOnChar(newChar)
        end
    end)

    local function toggleJumpPower(active, value)
        isActive  = active
        jumpValue = value or jumpValue

        if active then
            local char = lp.Character
            if char then activateOnChar(char) end
        else
            cleanup()
            local char = lp.Character
            local hum  = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                pcall(function() hum.JumpPower = 50 end)
                pcall(function() hum.JumpHeight = 7.2 end)
            end
        end
    end

    Tab:AddSpeedControl(T("player.jumppower.label"), function(active, value)
        toggleJumpPower(active, value)
    end, 100)
end