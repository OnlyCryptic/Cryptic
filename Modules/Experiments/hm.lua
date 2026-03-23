-- [[ Cryptic Hub - WalkFling ]]

return function(Tab, UI)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local PhysicsService = game:GetService("PhysicsService")
    local StarterGui = game:GetService("StarterGui")
    local lp = Players.LocalPlayer

    local walkflinging = false
    local deathConn = nil
    local noclipConn = nil
    local antiflingConn = nil
    local flingThread = nil -- أضفنا هذا المتغير للتحكم في اللوب وإيقافه

    local function Notify(ar, en)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Cryptic Hub",
                Text = ar .. "\n" .. en,
                Duration = 4
            })
        end)
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
                    if ok then return can end
                end
            end
        end
        return true
    end

    -- دالة لتنظيف كل اللوبات والاتصالات لتجنب أي تعليق
    local function StopAll()
        if noclipConn then noclipConn:Disconnect() noclipConn = nil end
        if antiflingConn then antiflingConn:Disconnect() antiflingConn = nil end
        if deathConn then deathConn:Disconnect() deathConn = nil end
        if flingThread then task.cancel(flingThread) flingThread = nil end
    end

    local function StartWalkFling()
        if not CheckCollisionAllowed() then
            Notify(
                "🚫 الماب لا يدعم تلامس اللاعبين، لن تعمل!",
                "🚫 Map doesn't support player collision!"
            )
            walkflinging = false
            return
        end

        -- تنظيف أي اتصالات قديمة قبل البدء من جديد
        StopAll()

        -- نوكليب
        noclipConn = RunService.Stepped:Connect(function()
            if not walkflinging then return end
            local char = lp.Character
            if not char then return end
            for _, p in pairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end)

        -- antifling مخفي
        antiflingConn = RunService.Stepped:Connect(function()
            if not walkflinging then return end
            for _, pl in pairs(Players:GetPlayers()) do
                if pl ~= lp and pl.Character then
                    for _, part in pairs(pl.Character:GetChildren()) do
                        if part:IsA("BasePart") and part.CanCollide then
                            part.CanCollide = false
                        end
                    end
                end
            end
        end)

        -- مراقبة الموت
        local char = lp.Character
        local hum = char and char:FindFirstChildWhichIsA("Humanoid")
        if hum then
            deathConn = hum.Died:Connect(function()
                if not walkflinging then return end
                
                -- نوقف اللوب الحالي فورا عشان ما يتراكم اللوب بعد الريسبون
                if flingThread then task.cancel(flingThread) flingThread = nil end

                -- انتظر ريسبون
                local newChar = lp.CharacterAdded:Wait()
                local newHum = newChar:WaitForChild("Humanoid", 10)
                if not newHum then return end

                -- انتظر حتى اللاعب يتحرك بنفسه
                repeat RunService.Heartbeat:Wait()
                until newHum.MoveDirection.Magnitude > 0 or not walkflinging

                task.wait(0.2)
                if walkflinging then StartWalkFling() end
            end)
        end

        -- اللوب الأصلي من IY بعد تنظيفه وترتيبه
        flingThread = task.spawn(function()
            local movel = 0.1
            while walkflinging do
                RunService.Heartbeat:Wait()
                local character = lp.Character
                local root = character and character:FindFirstChild("HumanoidRootPart")

                -- لا ننفذ الأوامر إلا إذا كانت الشخصية والـ Root موجودين
                if character and character.Parent and root and root.Parent then
                    local vel = root.AssemblyLinearVelocity
                    root.AssemblyLinearVelocity = vel * 10000 + Vector3.new(0, 10000, 0)

                    RunService.RenderStepped:Wait()
                    if character and character.Parent and root and root.Parent then
                        root.AssemblyLinearVelocity = vel
                    end

                    RunService.Stepped:Wait()
                    if character and character.Parent and root and root.Parent then
                        root.AssemblyLinearVelocity = vel + Vector3.new(0, movel, 0)
                        movel = movel * -1
                    end
                end
            end
        end)
    end

    Tab:AddToggle("ووك فلينج / WalkFling", function(active)
        walkflinging = active
        if active then
            StartWalkFling()
            Notify(
                "✅ تم التفعيل! تطير بتمشي وتلمس ناس",
                "✅ Walk into players to fling them"
            )
        else
            -- إيقاف كل شيء عند إطفاء الزر
            StopAll()
        end
    end)

    Tab:AddLine()
end
