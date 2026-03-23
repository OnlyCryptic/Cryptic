-- [[ Cryptic Hub - WalkFling ]]
-- نفس نظام IY بالضبط: يطير اللاعبين بمجرد الحركة

return function(Tab, UI)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local StarterGui = game:GetService("StarterGui")
    local lp = Players.LocalPlayer

    local isActive = false
    local noclipConn = nil

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
    end

    Tab:AddToggle("ووك فلينج / WalkFling", function(active)
        if active then
            isActive = true

            local char = lp.Character
            local hum = char and char:FindFirstChildWhichIsA("Humanoid")
            if hum then
                hum.Died:Connect(function() Stop() end)
            end

            StartNoclip()
            Notify("✅ تفعيل WalkFling", "✅ WalkFling enabled")

            -- نفس منطق IY بالضبط
            task.spawn(function()
                repeat
                    RunService.Heartbeat:Wait()

                    local character = lp.Character
                    local root = character and character:FindFirstChild("HumanoidRootPart")
                    local vel, movel = nil, 0.1

                    -- انتظر لما تكون الشخصية جاهزة
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

        else
            Stop()
        end
    end)

    Tab:AddLine()
end
