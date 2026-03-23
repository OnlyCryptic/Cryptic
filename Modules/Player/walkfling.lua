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
    local flingConn = nil

    local function Notify(ar, en)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Cryptic Hub",
                Text = ar .. "\n" .. en,
                Duration = 3
            })
        end)
    end

    -- ==============================
    -- AntiFling مخفي (يلغي تصادم اللاعبين الثانيين عشان ما يطيروك)
    -- ==============================
    local function StartAntiFling()
        if antiflingConn then antiflingConn:Disconnect() end
        antiflingConn = RunService.Stepped:Connect(function()
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
    end

    local function StopAntiFling()
        if antiflingConn then antiflingConn:Disconnect() antiflingConn = nil end
    end

    -- ==============================
    -- NoClip لشخصيتك
    -- ==============================
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

    local function StopFlingLoop()
        if flingConn then flingConn:Disconnect() flingConn = nil end
    end

    local function Stop()
        isActive = false
        StopFlingLoop()
        StopNoclip()
        StopAntiFling()
        if deathConn then deathConn:Disconnect() deathConn = nil end
    end

    local function CheckCollisionAllowed()
        local otherPlayer = nil
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= lp and p.Character then otherPlayer = p; break end
        end
        if not otherPlayer then return true end

        local myChar = lp.Character
        local myTorso = myChar and (myChar:FindFirstChild("UpperTorso") or myChar:FindFirstChild("Torso"))
        local tgtTorso = otherPlayer.Character and (
            otherPlayer.Character:FindFirstChild("UpperTorso") or
            otherPlayer.Character:FindFirstChild("Torso")
        )
        if not myTorso or not tgtTorso then return true end

        local ok, canCollide = pcall(function()
            return PhysicsService:CollisionGroupsAreCollidable(myTorso.CollisionGroup, tgtTorso.CollisionGroup)
        end)
        return ok and canCollide
    end

    local function StartFlingLoop()
        StopFlingLoop()
        local loopRunning = true
        flingConn = { Disconnect = function() loopRunning = false end }

        task.spawn(function()
            while loopRunning and isActive do
                RunService.Heartbeat:Wait()

                local character = lp.Character
                local root = character and character:FindFirstChild("HumanoidRootPart")
                local hum = character and character:FindFirstChildOfClass("Humanoid")

                if not character or not root or not hum or hum.Health <= 0 then
                    task.wait(0.1)
                    continue
                end

                local vel = root.Velocity
                local horizontalSpeed = Vector3.new(vel.X, 0, vel.Z).Magnitude

                -- تجاهل لو ما في حركة أفقية (واقف أو بس قافز)
                if horizontalSpeed < 0.5 then
                    task.wait(0.05)
                    continue
                end

                -- تجاهل لو السرعة كبيرة جداً (بعد انتقال أو قفز لانهائي)
                if horizontalSpeed > 200 or math.abs(vel.Y) > 100 then
                    root.Velocity = Vector3.new(0, math.min(vel.Y, 50), 0)
                    task.wait(0.1)
                    continue
                end

                -- طبق الفلينج على الحركة الأفقية فقط
                local flatVel = Vector3.new(vel.X, 0, vel.Z)
                local movel = 0.1
                root.Velocity = flatVel * 10000 + Vector3.new(0, 10000, 0)

                RunService.RenderStepped:Wait()
                if character and character.Parent and root and root.Parent then
                    root.Velocity = flatVel
                end

                RunService.Stepped:Wait()
                if character and character.Parent and root and root.Parent then
                    root.Velocity = flatVel + Vector3.new(0, movel, 0)
                end
            end
        end)
    end

    local function StartWalkFling()
        if not CheckCollisionAllowed() then
            Notify("🚫 الماب يلغي تصادم اللاعبين!", "🚫 Map disables player collision!")
            isActive = false
            return
        end

        StartNoclip()
        StartAntiFling() -- يشتغل بخفاء
        StartFlingLoop()

        if deathConn then deathConn:Disconnect() end
        local char = lp.Character
        local hum = char and char:FindFirstChildWhichIsA("Humanoid")
        if hum then
            deathConn = hum.Died:Connect(function()
                if not isActive then return end
                StopFlingLoop()
                StopNoclip()
                StopAntiFling()

                local newChar = lp.CharacterAdded:Wait()
                local newHum = newChar:WaitForChild("Humanoid", 10)
                if newHum then
                    repeat task.wait(0.1) until newHum.Health >= newHum.MaxHealth or not isActive
                end
                task.wait(0.5)

                if isActive then StartWalkFling() end
            end)
        end
    end

    Tab:AddToggle("ووك فلينج / WalkFling", function(active)
        if active then
            isActive = true
            StartWalkFling()
            Notify(
                "✅ تم التفعيل! تطير بتمشي وتلمس ناس",
                "✅ Enabled! Walk into players to fling them"
            )
        else
            Stop()
        end
    end)

    Tab:AddLine()
end
