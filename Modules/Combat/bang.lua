-- [[ Cryptic Hub - Bang Module ]]

return function(Tab, UI)
    local RunService  = game:GetService("RunService")
    local Players     = game:GetService("Players")
    local StarterGui  = game:GetService("StarterGui")
    local lp          = Players.LocalPlayer

    local i18n = getgenv().CrypticI18n
    local T = (i18n and i18n.T) or function(k) return k end

    local bangActive    = false
    local bangAnim      = nil
    local bangTrack     = nil
    local bangLoop      = nil
    local antiflingConn = nil
    local noclipConn    = nil
    local diedConn      = nil

    local function Notify(text)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Cryptic Hub",
                Text  = text,
                Duration = 3,
            })
        end)
    end

    local function isR6(character)
        if not character then return false end
        return character:FindFirstChild("Torso") ~= nil
            and character:FindFirstChild("UpperTorso") == nil
    end

    local function EnableAntifling()
        if antiflingConn then antiflingConn:Disconnect() end
        antiflingConn = RunService.Stepped:Connect(function()
            if not lp.Character then return end
            for _, other in pairs(Players:GetPlayers()) do
                if other ~= lp and other.Character then
                    for _, part in pairs(other.Character:GetChildren()) do
                        if part:IsA("BasePart") and part.CanCollide then
                            part.CanCollide = false
                        end
                    end
                end
            end
        end)
    end

    local function EnableNoclip()
        if noclipConn then noclipConn:Disconnect() end
        noclipConn = RunService.Stepped:Connect(function()
            if not lp.Character then return end
            for _, part in pairs(lp.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    end

    local function StopBang()
        bangActive = false
        if bangLoop      then bangLoop:Disconnect();      bangLoop      = nil end
        if antiflingConn then antiflingConn:Disconnect(); antiflingConn = nil end
        if noclipConn    then noclipConn:Disconnect();    noclipConn    = nil end
        if diedConn      then diedConn:Disconnect();      diedConn      = nil end

        pcall(function() if bangTrack then bangTrack:Stop() end end)
        pcall(function() if bangAnim  then bangAnim:Destroy() end end)
        bangTrack = nil
        bangAnim  = nil
    end

    local toggle
    toggle = Tab:AddToggle(T("combat.bang.label"), function(active)
        if active then
            local target = _G.ArwaTarget
            if not target or not target.Character then
                Notify(T("combat.common.no_target"))
                task.defer(function() toggle:SetState(false) end)
                return
            end

            local char = lp.Character
            local hum  = char and char:FindFirstChildOfClass("Humanoid")
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if not char or not hum or not root then
                Notify(T("combat.common.no_character"))
                task.defer(function() toggle:SetState(false) end)
                return
            end

            bangActive = true
            EnableAntifling()
            EnableNoclip()

            local animId
            if isR6(char) then
                animId = "rbxassetid://148840371"
            else
                animId = "rbxassetid://5918726674"
            end

            bangAnim               = Instance.new("Animation")
            bangAnim.AnimationId   = animId
            bangTrack              = hum:LoadAnimation(bangAnim)
            bangTrack:Play(0.1, 1, 1)
            bangTrack:AdjustSpeed(isR6(char) and 3 or 1.5)

            local bangOffset = CFrame.new(0, 0, 1.1)

            bangLoop = RunService.Stepped:Connect(function()
                pcall(function()
                    if not bangActive then return end
                    local tChar = _G.ArwaTarget and _G.ArwaTarget.Character
                    if not tChar then return end
                    local tTorso = tChar:FindFirstChild("UpperTorso")
                                or tChar:FindFirstChild("Torso")
                                or tChar:FindFirstChild("HumanoidRootPart")
                    if not tTorso then return end
                    local myRoot = char:FindFirstChild("HumanoidRootPart")
                    if not myRoot then return end
                    myRoot.CFrame = tTorso.CFrame * bangOffset
                end)
            end)

            diedConn = hum.Died:Connect(function()
                StopBang()
                task.defer(function() toggle:SetState(false) end)
            end)

            Notify(T("combat.bang.on"))
        else
            StopBang()
        end
    end)
end
