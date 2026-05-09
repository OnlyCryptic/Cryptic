-- [[ Cryptic Hub - Copy Walk V2.1 ]]

local Players    = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local lp         = Players.LocalPlayer

return function(Tab, UI)

    local i18n = getgenv().CrypticI18n
    local T = (i18n and i18n.T) or function(k) return k end

    local isToggleOn        = false
    local originalAnimateIds = nil
    local customIdleConnection = nil
    local loadedIdle2Track     = nil

    local FOLDERS = { "idle", "walk", "run", "jump", "fall", "climb", "swim" }

    local function Notify(text)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title    = "Cryptic Hub",
                Text     = text,
                Duration = 4,
            })
        end)
    end

    local function StopCustomIdle()
        if customIdleConnection then
            customIdleConnection:Disconnect()
            customIdleConnection = nil
        end
        if loadedIdle2Track then
            pcall(function() loadedIdle2Track:Stop() end)
            loadedIdle2Track = nil
        end
    end

    local function ReadAnimsFrom(character)
        local animate = character:FindFirstChild("Animate")
        if not animate then return nil end

        local function getId(folder, child)
            local f = animate:FindFirstChild(folder)
            if not f then return nil end
            local c = f:FindFirstChild(child)
            if not c then return nil end
            local id = c.AnimationId
            if id and id ~= "" then
                return tostring(id):match("%d+")
            end
            return nil
        end

        return {
            idle   = getId("idle",  "Animation1"),
            idle2  = getId("idle",  "Animation2"),
            walk   = getId("walk",  "WalkAnim"),
            walk2  = getId("walk",  "WalkAnim2"),
            run    = getId("run",   "RunAnim"),
            run2   = getId("run",   "RunAnim2"),
            jump   = getId("jump",  "JumpAnim"),
            jump2  = getId("jump",  "JumpAnim2"),
            fall   = getId("fall",  "FallAnim"),
            fall2  = getId("fall",  "FallAnim2"),
            climb  = getId("climb", "ClimbAnim"),
            climb2 = getId("climb", "ClimbAnim2"),
            swim   = getId("swim",  "Swim"),
            swim2  = getId("swim",  "Swim2"),
        }
    end

    local function BackupAnimateIds(animate)
        if originalAnimateIds then return end
        originalAnimateIds = {}
        for _, folderName in ipairs(FOLDERS) do
            local folder = animate:FindFirstChild(folderName)
            if folder then
                local list = {}
                for _, child in ipairs(folder:GetChildren()) do
                    if child:IsA("Animation") then
                        table.insert(list, { obj = child, id = child.AnimationId })
                    end
                end
                if #list > 0 then
                    originalAnimateIds[folderName] = list
                end
            end
        end
    end

    local function ApplyAnimation(animData)
        local char = lp.Character
        if not char then return end

        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end

        if hum.RigType == Enum.HumanoidRigType.R6 then
            Notify(T("combat.copy_walk.r6_warning"))
            return
        end

        StopCustomIdle()

        local animate  = char:FindFirstChild("Animate")
        local animator = hum:FindFirstChildOfClass("Animator")
        if not animate or not animator then return end

        BackupAnimateIds(animate)

        animate.Disabled = true

        for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
            pcall(function() track:Stop(0) end)
        end

        local function setAnim(folder, childName, id)
            if not folder then return end
            local anim = folder:FindFirstChild(childName)
            if anim then
                if id and tostring(id) ~= "" then
                    anim.AnimationId = "rbxassetid://" .. tostring(id)
                end
            elseif id and tostring(id) ~= "" then
                local newAnim = Instance.new("Animation")
                newAnim.Name        = childName
                newAnim.AnimationId = "rbxassetid://" .. tostring(id)
                newAnim.Parent      = folder
            end
        end

        local idle  = animate:FindFirstChild("idle")
        local walk  = animate:FindFirstChild("walk")
        local run   = animate:FindFirstChild("run")
        local jump  = animate:FindFirstChild("jump")
        local fall  = animate:FindFirstChild("fall")
        local climb = animate:FindFirstChild("climb")
        local swim  = animate:FindFirstChild("swim")

        setAnim(idle,  "Animation1", animData.idle)
        setAnim(idle,  "Animation2", animData.idle2 or animData.idle)
        setAnim(walk,  "WalkAnim",   animData.walk)
        setAnim(walk,  "WalkAnim2",  animData.walk2 or animData.walk)
        setAnim(run,   "RunAnim",    animData.run   or animData.walk)
        setAnim(run,   "RunAnim2",   animData.run2  or animData.run or animData.walk)
        setAnim(jump,  "JumpAnim",   animData.jump)
        setAnim(jump,  "JumpAnim2",  animData.jump2 or animData.jump)
        setAnim(fall,  "FallAnim",   animData.fall)
        setAnim(fall,  "FallAnim2",  animData.fall2 or animData.fall)
        setAnim(climb, "ClimbAnim",  animData.climb)
        setAnim(climb, "ClimbAnim2", animData.climb2 or animData.climb)
        setAnim(swim,  "Swim",       animData.swim)
        setAnim(swim,  "Swim2",      animData.swim2 or animData.swim)

        pcall(function()
            local desc = hum:GetAppliedDescription()
            if desc then
                local function setId(prop, id)
                    if id and tostring(id) ~= "" then
                        pcall(function() desc[prop] = tonumber(id) end)
                    end
                end
                setId("IdleAnimation",  animData.idle)
                setId("WalkAnimation",  animData.walk  or animData.idle)
                setId("RunAnimation",   animData.run   or animData.walk or animData.idle)
                setId("JumpAnimation",  animData.jump)
                setId("FallAnimation",  animData.fall)
                setId("ClimbAnimation", animData.climb)
                setId("SwimAnimation",  animData.swim)
                hum:ApplyDescription(desc)
            end
        end)

        for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
            pcall(function() track:Stop(0) end)
        end

        task.defer(function()
            if animate and animate.Parent then
                animate.Disabled = false
            end
        end)

        if animData.idle2 then
            local customIdleAnim = Instance.new("Animation")
            customIdleAnim.AnimationId = "rbxassetid://" .. animData.idle2
            loadedIdle2Track = animator:LoadAnimation(customIdleAnim)
            loadedIdle2Track.Priority = Enum.AnimationPriority.Action
            loadedIdle2Track.Looped   = false

            local lastMoveTime  = tick()
            local isIdle2Active = false

            customIdleConnection = RunService.Heartbeat:Connect(function()
                if not loadedIdle2Track then return end
                if hum.MoveDirection.Magnitude > 0 then
                    lastMoveTime = tick()
                    if isIdle2Active then
                        loadedIdle2Track:Stop(0.4)
                        isIdle2Active = false
                    end
                elseif isIdle2Active then
                    if not loadedIdle2Track.IsPlaying then
                        isIdle2Active = false
                        lastMoveTime  = tick()
                    end
                elseif tick() - lastMoveTime >= 12 then
                    isIdle2Active = true
                    loadedIdle2Track:Play(0.4)
                end
            end)
        end
    end

    local function RestoreOriginalAnims()
        local char = lp.Character
        if not char then return end

        local hum     = char:FindFirstChildOfClass("Humanoid")
        local animate = char:FindFirstChild("Animate")

        StopCustomIdle()

        if not hum or not animate then
            originalAnimateIds = nil
            return
        end

        local animator = hum:FindFirstChildOfClass("Animator")

        animate.Disabled = true

        if animator then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                pcall(function() track:Stop(0) end)
            end
        end

        if originalAnimateIds then
            for folderName, list in pairs(originalAnimateIds) do
                local folder = animate:FindFirstChild(folderName)
                if folder then
                    for _, entry in ipairs(list) do
                        if entry.obj and entry.obj.Parent == folder then
                            pcall(function() entry.obj.AnimationId = entry.id end)
                        end
                    end
                end
            end
        end

        task.defer(function()
            if animate and animate.Parent then
                animate.Disabled = false
            end
        end)

        originalAnimateIds = nil
    end

    Tab:AddToggle(T("combat.copy_walk.label"), function(active)
        isToggleOn = active

        if active then
            local target = _G.ArwaTarget
            if not target or not target.Character then
                isToggleOn = false
                Notify(T("combat.common.no_target"))
                return
            end

            local targetChar = target.Character
            local hum = targetChar:FindFirstChildOfClass("Humanoid")

            if hum and hum.RigType == Enum.HumanoidRigType.R6 then
                isToggleOn = false
                Notify(T("combat.copy_walk.target_r6"))
                return
            end

            local stolenAnims = ReadAnimsFrom(targetChar)
            if not stolenAnims then
                isToggleOn = false
                Notify(T("combat.copy_walk.read_fail"))
                return
            end

            ApplyAnimation(stolenAnims)
            Notify(string.format(T("combat.copy_walk.on_fmt"), target.DisplayName))
        else
            RestoreOriginalAnims()
            Notify(T("combat.copy_walk.off"))
        end
    end)

    lp.CharacterAdded:Connect(function(char)
        originalAnimateIds = nil
        StopCustomIdle()
        task.delay(1, function()
            local hum = char:WaitForChild("Humanoid", 5)
            if not hum or hum.Health <= 0 then return end
            if not isToggleOn then return end

            local target = _G.ArwaTarget
            if not target or not target.Character then return end

            local stolenAnims = ReadAnimsFrom(target.Character)
            if stolenAnims then
                ApplyAnimation(stolenAnims)
            end
        end)
    end)
end
