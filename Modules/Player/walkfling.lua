-- [[ Cryptic Hub - WalkFling ]]

return function(Tab, UI)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local PhysicsService = game:GetService("PhysicsService")
    local StarterGui = game:GetService("StarterGui")
    local lp = Players.LocalPlayer

    local isActive = false
    local noclipConn = nil
    local deathConn = nil

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

    local function Stop()
        isActive = false
        StopNoclip()
        if deathConn then deathConn:Disconnect() deathConn = nil end
    end

    -- ==============================
    -- فحص إذا الماب يسمح بالتصادم
    -- ==============================
    local function CheckCollisionAllowed()
        local otherPlayer = nil
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= lp and p.Character then
                otherPlayer = p
                break
            end
        end
        if not otherPlayer then return true end -- ما في لاعبين، افترض يشتغل

        local myChar = lp.Character
        local myTorso = myChar and (myChar:FindFirstChild("UpperTorso") or myChar:FindFirstChild("Torso"))
        local tgtTorso = otherPlayer.Character and (
            otherPlayer.Character:FindFirstChild("UpperTorso") or
            otherPlayer.Character:FindFirstChild("Torso")
        )

        if not myTorso or not tgtTorso then return true end

        local ok, canCollide = pcall(function()
            return PhysicsService:CollisionGroupsAreCollidable(
                myTorso.CollisionGroup,
                tgtTorso.CollisionGroup
            )
        end)

        return ok and canCollide
    end

    local function StartWalkFling()
        if deathConn then deathConn:Disconnect() end

        -- فحص الماب
        local allowed = CheckCollisionAllowed()
        if not allowed then
            Notify(
                "🚫 هذا الماب يلغي تصادم اللاعبين، لن تعمل!",
                "🚫 Map disables player collision, won't work!"
            )
            isActive = false
            return
        end

        StartNoclip()

        -- مراقبة الموت
        local char = lp.Character
        local hum = char and char:FindFirstChildWhichIsA("Humanoid")
        if hum then
            deathConn = hum.Died:Connect(function()
                if not isActive then return end
                StopNoclip()
                -- انتظر ريسبون وأعد التشغيل
                lp.CharacterAdded:Wait()
                task.wait(1)
                if isActive then StartWalkFling() end
            end)
        end

        -- نفس منطق IY
        task.spawn(function()
            repeat
                RunService.Heartbeat:Wait()
                local character = lp.Character
                local root = character and character:FindFirstChild("HumanoidRootPart")
                local vel, movel = nil, 0.1

                while not (character and character.Parent and root and root.Parent) do
                    RunService.Heartbeat:Wait()
                    character = lp.Character
                    root = character and character:FindFirstChild("HumanoidRootPart")
                end

                vel = root.Velocity
                root.Velocity = vel * 10000 + Vector3.new(0, 10000, 0)

                RunService.RenderStepped:Wait()
                if character and character.Parent and root and root.Parent then
                    root.Velocity = vel
                end

                RunService.Stepped:Wait()
                if character and character.Parent and root and root.Parent then
                    root.Velocity = vel + Vector3.new(0, movel, 0)
                    movel = movel * -1
                end
            until isActive == false
        end)
    end

    Tab:AddToggle("تطيير ناس بلمسهم / WalkFling", function(active)
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
