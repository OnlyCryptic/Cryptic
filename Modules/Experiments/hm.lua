-- [[ Cryptic Hub - WalkFling ]]

return function(Tab, UI)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local PhysicsService = game:GetService("PhysicsService")
    local StarterGui = game:GetService("StarterGui")
    local lp = Players.LocalPlayer

    local isActive = false
    local noclipConn = nil
    local antiflingConn = nil
    local deathConn = nil
    local loopRunning = false

    local function Notify(ar, en)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Cryptic Hub",
                Text = ar .. "\n" .. en,
                Duration = 3
            })
        end)
    end

    local function StartNoclip()
        if noclipConn then noclipConn:Disconnect() end
        noclipConn = RunService.Stepped:Connect(function()
            local char = lp.Character
            if not char then return end
            for _, p in pairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end)
    end

    local function StopNoclip()
        if noclipConn then noclipConn:Disconnect() noclipConn = nil end
        local char = lp.Character
        if char then
            for _, p in pairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = true end
            end
        end
    end

    local function StartAntiFling()
        if antiflingConn then antiflingConn:Disconnect() end
        antiflingConn = RunService.Stepped:Connect(function()
            if not lp.Character then return end
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= lp and p.Character then
                    for _, part in pairs(p.Character:GetChildren()) do
                        if part:IsA("BasePart") and part.CanCollide then
                            part.CanCollide = false
                        end
                    end
                end
            end
        end)
    end

    local function StopAntiFling()
        if antiflingConn then antiflingConn:Disconnect() antiflingConn = nil end
    end

    local function StopAll()
        isActive = false
        loopRunning = false
        StopNoclip()
        StopAntiFling()
        if deathConn then deathConn:Disconnect() deathConn = nil end
    end

    local function CheckCollisionAllowed()
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= lp and p.Character then
                local myTorso = lp.Character and (lp.Character:FindFirstChild("UpperTorso") or lp.Character:FindFirstChild("Torso"))
                local tgtTorso = p.Character:FindFirstChild("UpperTorso") or p.Character:FindFirstChild("Torso")
                if myTorso and tgtTorso then
                    local ok, can = pcall(function()
                        return PhysicsService:CollisionGroupsAreCollidable(myTorso.CollisionGroup, tgtTorso.CollisionGroup)
                    end)
                    return ok and can
                end
            end
        end
        return true
    end

    local function StartWalkFling()
        if not CheckCollisionAllowed() then
            Notify("🚫 الماب يلغي تصادم اللاعبين!", "🚫 Map disables collision!")
            isActive = false
            return
        end

        StartNoclip()
        StartAntiFling()

        -- مراقبة الموت
        if deathConn then deathConn:Disconnect() end
        local char = lp.Character
        local hum = char and char:FindFirstChildWhichIsA("Humanoid")
        if hum then
            deathConn = hum.Died:Connect(function()
                if not isActive then return end
                loopRunning = false
                StopNoclip()
                StopAntiFling()
                lp.CharacterAdded:Wait()
                task.wait(1.5)
                if isActive then StartWalkFling() end
            end)
        end

        -- اللوب الرئيسي
        loopRunning = true
        task.spawn(function()
            while loopRunning and isActive do
                RunService.Heartbeat:Wait()

                local character = lp.Character
                local root = character and character:FindFirstChild("HumanoidRootPart")
                local hum2 = character and character:FindFirstChildOfClass("Humanoid")

                if not root or not hum2 or hum2.Health <= 0 then
                    task.wait(0.1)
                    continue
                end

                -- فقط لما تكون فعلاً تمشي والـ velocity معقولة
                local vel = root.Velocity
                local flatSpeed = Vector3.new(vel.X, 0, vel.Z).Magnitude

                if hum2.MoveDirection.Magnitude > 0 and flatSpeed > 1 and flatSpeed < 100 then
                    root.Velocity = vel * 10000 + Vector3.new(0, 10000, 0)
                    RunService.RenderStepped:Wait()
                    if root and root.Parent then root.Velocity = vel end
                    RunService.Stepped:Wait()
                    if root and root.Parent then root.Velocity = vel + Vector3.new(0, 0.1, 0) end
                end
            end
        end)
    end

    Tab:AddToggle(".ووك فلينج / WalkFling", function(active)
        if active then
            isActive = true
            StartWalkFling()
            Notify("✅ تم التفعيل! تطير بتمشي وتلمس ناس", "✅ Walk into players to fling them")
        else
            StopAll()
        end
    end)

    Tab:AddLine()
end
