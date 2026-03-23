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
    local flingThread = nil

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

    local function StopAll()
        if noclipConn then noclipConn:Disconnect() noclipConn = nil end
        if antiflingConn then antiflingConn:Disconnect() antiflingConn = nil end
        if deathConn then deathConn:Disconnect() deathConn = nil end
        if flingThread then task.cancel(flingThread) flingThread = nil end
    end

    local function StartWalkFling()
        StopAll()

        -- نوكليب معدل: يمنع سقوطك تحت الأرض عبر استثناء الأرجل والـ RootPart
        noclipConn = RunService.Stepped:Connect(function()
            if not walkflinging then return end
            local char = lp.Character
            if not char then return end
            for _, p in pairs(char:GetDescendants()) do
                if p:IsA("BasePart") then
                    local pName = p.Name:lower()
                    if not string.find(pName, "leg") and not string.find(pName, "foot") and pName ~= "humanoidrootpart" then
                        p.CanCollide = false
                    end
                end
            end
        end)

        -- antifling مخفي: يمنع اللاعبين الآخرين من التأثير عليك
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
                
                if flingThread then task.cancel(flingThread) flingThread = nil end

                local newChar = lp.CharacterAdded:Wait()
                local newHum = newChar:WaitForChild("Humanoid", 10)
                if not newHum then return end

                repeat RunService.Heartbeat:Wait()
                until newHum.MoveDirection.Magnitude > 0 or not walkflinging

                task.wait(0.2)
                if walkflinging then StartWalkFling() end
            end)
        end

        -- اللوب الخاص بالفيزياء معدل لمنع الاختفاء تحت الماب
        flingThread = task.spawn(function()
            local movel = 0.1
            while walkflinging do
                RunService.Heartbeat:Wait()
                local character = lp.Character
                local root = character and character:FindFirstChild("HumanoidRootPart")

                if character and character.Parent and root and root.Parent then
                    local vel = root.AssemblyLinearVelocity
                    
                    -- إجبار السرعة العمودية Y لتكون موجبة دائماً (10000 للأعلى)
                    -- هذا هو السر الذي سيمنعك من السقوط للأسفل تماماً
                    root.AssemblyLinearVelocity = Vector3.new(vel.X * 10000, 10000, vel.Z * 10000)

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

    Tab:AddToggle("ووك ..فلينج / WalkFling", function(active)
        if active then
            -- فحص التلامس أولاً
            if not CheckCollisionAllowed() then
                Notify(
                    "🚫 الماب لا يدعم تلامس اللاعبين، لن تعمل!",
                    "🚫 Map doesn't support player collision!"
                )
                walkflinging = false
                task.defer(function()
                    if Tab.SetToggleState then
                        Tab:SetToggleState("ووك فلينج / WalkFling", false)
                    end
                end)
                return
            end

            walkflinging = true
            StartWalkFling()
            Notify(
                "✅ تم التفعيل! تطير بتمشي وتلمس ناس",
                "✅ Walk into players to fling them"
            )
        else
            walkflinging = false
            StopAll()
        end
    end)

    Tab:AddLine()
end
