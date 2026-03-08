-- [[ Cryptic Hub - الايم بوت (Aimbot) لأقرب لاعب ]]
-- المطور: يامي (Yami) | الوصف: توجيه الكاميرا تلقائياً لأقرب لاعب حي

return function(Tab, UI)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local StarterGui = game:GetService("StarterGui")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    local isAimbotActive = false
    local aimbotConnection = nil
    
    local targetPartName = "HumanoidRootPart" 

    local function SendRobloxNotification(title, text)
        pcall(function() StarterGui:SetCore("SendNotification", { Title = title, Text = text, Duration = 3 }) end)
    end

    local function getClosestPlayer()
        local closestPlayer = nil
        local shortestDistance = math.huge 

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local character = player.Character
                local targetPart = character:FindFirstChild(targetPartName)
                local humanoid = character:FindFirstChildOfClass("Humanoid")

                if targetPart and humanoid and humanoid.Health > 0 then
                    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    
                    if myRoot then
                        local distance = (targetPart.Position - myRoot.Position).Magnitude
                        
                        if distance < shortestDistance then
                            closestPlayer = player
                            shortestDistance = distance
                        end
                    end
                end
            end
        end
        return closestPlayer
    end

    Tab:AddToggle("ايم بوت (أقرب لاعب) / Auto Aimbot", function(state)
        isAimbotActive = state

        if isAimbotActive then
            SendRobloxNotification("Cryptic Hub", "🎯 تم تفعيل الايم بوت! الكاميرا ستلاحق أقرب هدف.")
            
            aimbotConnection = RunService.RenderStepped:Connect(function()
                if not isAimbotActive then return end
                
                local myChar = LocalPlayer.Character
                local myHumanoid = myChar and myChar:FindFirstChildOfClass("Humanoid")
                
                if not myChar or not myHumanoid or myHumanoid.Health <= 0 then return end
                
                local target = getClosestPlayer()
                
                if target and target.Character then
                    local targetPart = target.Character:FindFirstChild(targetPartName)
                    if targetPart then
                        local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
                        Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, 0.5)
                    end
                end
            end)
        else
            if aimbotConnection then
                aimbotConnection:Disconnect()
                aimbotConnection = nil
            end
            SendRobloxNotification("Cryptic Hub", "❌ تم إيقاف الايم بوت.")
        end
    end)
end
