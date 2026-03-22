-- [[ Cryptic Hub - تتبع لاعب (Target Follow) ]]

return function(Tab, UI)
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local StarterGui = game:GetService("StarterGui")
    local lp = Players.LocalPlayer

    local isFollowing = false
    local followConn = nil
    local physicsConn = nil
    local FOLLOW_DISTANCE = 4

    local function Notify(ar, en)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Cryptic Hub",
                Text = ar .. "\n" .. en,
                Duration = 3,
            })
        end)
    end

    local function StopFollow()
        isFollowing = false
        if followConn then followConn:Disconnect() followConn = nil end
        if physicsConn then physicsConn:Disconnect() physicsConn = nil end

        local char = lp.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if hum and root then
            hum:MoveTo(root.Position)
        end
    end

    Tab:AddToggle("تتبع الهدف / Follow Target", function(active)
        if active then
            local target = _G.ArwaTarget
            if not target or not target.Character then
                Notify("⚠️ حدد لاعباً أولاً!", "⚠️ Select a player first!")
                StopFollow()
                return
            end

            isFollowing = true
            Notify(
                "🚶 يتتبع: " .. target.DisplayName,
                "🚶 Following: " .. target.DisplayName
            )

            -- لوب الفيزياء: noclip + antifling + nofall
            physicsConn = RunService.Stepped:Connect(function()
                if not isFollowing then return end
                local char = lp.Character
                if not char then return end
                local root = char:FindFirstChild("HumanoidRootPart")

                -- NoClip
                for _, p in pairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end

                -- AntiFling
                for _, pl in pairs(Players:GetPlayers()) do
                    if pl ~= lp and pl.Character then
                        for _, p in pairs(pl.Character:GetChildren()) do
                            if p:IsA("BasePart") then p.CanCollide = false end
                        end
                    end
                end

                -- NoFall
                if root then
                    local vel = root.AssemblyLinearVelocity
                    if vel.Y < -40 then
                        root.AssemblyLinearVelocity = Vector3.new(vel.X, -40, vel.Z)
                    end
                end
            end)

            -- لوب التتبع مع تتبع الارتفاع
            followConn = RunService.Heartbeat:Connect(function()
                if not isFollowing then return end

                local char = lp.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")

                local tgt = _G.ArwaTarget
                local tgtChar = tgt and tgt.Character
                local tgtRoot = tgtChar and tgtChar:FindFirstChild("HumanoidRootPart")

                if not root or not hum or not tgtRoot then return end
                if hum.Health <= 0 then return end

                -- نقطة خلف الهدف + نفس ارتفاعه
                local tgtCF = tgtRoot.CFrame
                local behindPos = tgtCF * CFrame.new(0, 0, FOLLOW_DISTANCE)

                -- نأخذ X,Z من النقطة خلفه، Y من الهدف نفسه
                local targetPos = Vector3.new(
                    behindPos.X,
                    tgtRoot.Position.Y, -- نفس ارتفاع الهدف
                    behindPos.Z
                )

                local distance = (root.Position - tgtRoot.Position).Magnitude

                if distance > FOLLOW_DISTANCE + 0.5 then
                    -- نحرك بـ CFrame في الاتجاهات الثلاث X,Y,Z
                    local fullTarget = Vector3.new(targetPos.X, tgtRoot.Position.Y, targetPos.Z)
                    local dir = (fullTarget - root.Position).Unit
                    local speed = math.min(distance * 0.3, hum.WalkSpeed)
                    root.CFrame = CFrame.new(root.Position + dir * speed * 0.05) * (root.CFrame - root.CFrame.Position)
                end
            end)

        else
            StopFollow()
            Notify("❌ توقف التتبع.", "❌ Follow stopped.")
        end
    end)

    Tab:AddLine()
end
