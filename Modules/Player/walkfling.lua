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
    local flingConn = nil -- كونيكشن منفصل للفلينج

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

    local function StopFlingLoop()
        if flingConn then flingConn:Disconnect() flingConn = nil end
    end

    local function Stop()
        isActive = false
        StopFlingLoop()
        StopNoclip()
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
        flingConn = {Disconnect = function() loopRunning = false end}

        task.spawn(function()
            while loopRunning and isActive do
                RunService.Heartbeat:Wait()

                local character = lp.Character
                local root = character and character:FindFirstChild("HumanoidRootPart")
                local hum = character and character:FindFirstChildOfClass("Humanoid")

                if not character or not root or not hum then
                    task.wait(0.1)
                    continue
                end

                -- تجاهل لو الشخصية طازجة (الـ Health ما اكتملت بعد)
                if hum.Health <= 0 then
                    task.wait(0.1)
                    continue
                end

                local vel = root.Velocity
                local movel = 0.1

                -- نفس منطق IY
                root.Velocity = vel * 10000 + Vector3.new(0, 10000, 0)

                RunService.RenderStepped:Wait()
                if character and character.Parent and root and root.Parent then
                    root.Velocity = vel
                end

                RunService.Stepped:Wait()
                if character and character.Parent and root and root.Parent then
                    root.Velocity = vel + Vector3.new(0, movel, 0)
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
        StartFlingLoop()

        -- مراقبة الموت
        if deathConn then deathConn:Disconnect() end
        local char = lp.Character
        local hum = char and char:FindFirstChildWhichIsA("Humanoid")
        if hum then
            deathConn = hum.Died:Connect(function()
                if not isActive then return end

                -- أوقف اللوب والنوكليب فوراً
                StopFlingLoop()
                StopNoclip()

                -- انتظر ريسبون كامل
                local newChar = lp.CharacterAdded:Wait()
                -- انتظر حتى الـ HumanoidRootPart موجود وصحة كاملة
                local newRoot = newChar:WaitForChild("HumanoidRootPart", 10)
                local newHum = newChar:WaitForChild("Humanoid", 10)
                if newHum then
                    -- انتظر الصحة تكتمل
                    repeat task.wait(0.1) until newHum.Health >= newHum.MaxHealth or not isActive
                end
                task.wait(0.5) -- تأمين إضافي

                if isActive then
                    StartWalkFling()
                end
            end)
        end
    end

    Tab:AddToggle("ووك فلينك. / WalkFling", function(active)
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
