-- [[ Cryptic Hub - تطيير الجميع (Auto Fling All) ]]
-- المطور: يامي (Yami) | الوصف: الانتقال لجميع اللاعبين بالترتيب وتطييرهم

return function(Tab, UI)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local PhysicsService = game:GetService("PhysicsService")
    local StarterGui = game:GetService("StarterGui")
    local LocalPlayer = Players.LocalPlayer

    local isFlingAllActive = false

    -- دالة الإشعارات المزدوجة (عربي/إنجليزي)
    local function Notify(arText, enText)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Cryptic Hub",
                Text = arText .. "\n" .. enText,
                Duration = 5
            })
        end)
    end

    Tab:AddToggle("تطيير الجميع / Fling All", function(state)
        isFlingAllActive = state
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        
        if state then
            if not char or not root then
                isFlingAllActive = false
                return
            end

            -- [[ 1. فحص التلامس (Collision Check) ]]
            -- نفحص أول لاعب موجود لنتأكد من دعم الماب للتلامس
            local canCollideMap = true
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local targetTorso = p.Character:FindFirstChild("Torso") or p.Character:FindFirstChild("UpperTorso")
                    local myTorso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
                    
                    if myTorso and targetTorso then
                        local success, collidable = pcall(function()
                            return PhysicsService:CollisionGroupsAreCollidable(myTorso.CollisionGroup, targetTorso.CollisionGroup)
                        end)
                        if (success and not collidable) or targetTorso.CanCollide == false then
                            canCollideMap = false
                            break
                        end
                    end
                end
            end

            if not canCollideMap then
                isFlingAllActive = false
                Notify("🚫 الماب لا يدعم تلامس اللاعبين!", "Map does not support player collision!")
                return
            end

            Notify("🌪️ جاري تطيير الجميع بالترتيب...", "Starting to fling everyone...")

            -- حفظ المكان للرجوع إليه
            local originalCFrame = root.CFrame
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.PlatformStand = true end -- تجميد المشي لتجنب القلتشات

            -- [[ 2. حلقة التطيير المتسلسلة ]]
            task.spawn(function()
                while isFlingAllActive do
                    for _, targetPlayer in ipairs(Players:GetPlayers()) do
                        if not isFlingAllActive then break end
                        if targetPlayer ~= LocalPlayer and targetPlayer.Character then
                            local targetChar = targetPlayer.Character
                            local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                            local targetHum = targetChar:FindFirstChildOfClass("Humanoid")

                            -- التأكد أن الهدف حي
                            if targetRoot and targetHum and targetHum.Health > 0 then
                                local startTime = tick()
                                
                                -- الهجوم على هذا اللاعب لمدة 2.5 ثانية أو حتى يموت/يطير
                                while isFlingAllActive and targetChar and targetChar.Parent and targetHum.Health > 0 and (tick() - startTime < 2.5) do
                                    local myChar = LocalPlayer.Character
                                    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                                    
                                    if myRoot then
                                        -- تفعيل Noclip و Anti-Fling لشخصيتك
                                        for _, part in pairs(myChar:GetChildren()) do
                                            if part:IsA("BasePart") then
                                                if part.Name == "HumanoidRootPart" or part.Name == "Torso" or part.Name == "UpperTorso" then
                                                    part.CanCollide = true
                                                    part.CustomPhysicalProperties = PhysicalProperties.new(100, 0, 1) -- وزن ثقيل
                                                else
                                                    part.CanCollide = false -- Noclip لباقي الجسم
                                                end
                                                part.Massless = true
                                            end
                                        end

                                        -- التتبع الذكي والدوران المدمر
                                        local targetVel = targetRoot.Velocity
                                        local predictedPos = targetRoot.Position + (targetVel * 0.1)
                                        
                                        myRoot.CFrame = CFrame.new(predictedPos + Vector3.new(math.random(-2,2), math.random(-1,2), math.random(-2,2)))
                                        myRoot.Velocity = Vector3.new(0, 5000, 0)
                                        myRoot.RotVelocity = Vector3.new(math.random(-50000, 50000), math.random(-50000, 50000), math.random(-50000, 50000))
                                    end
                                    task.wait()
                                end
                            end
                        end
                    end
                    task.wait(0.1)
                end

                -- [[ 3. إيقاف التطيير والعودة للحالة الطبيعية ]]
                local finalChar = LocalPlayer.Character
                local finalRoot = finalChar and finalChar:FindFirstChild("HumanoidRootPart")
                local finalHum = finalChar and finalChar:FindFirstChildOfClass("Humanoid")
                
                if finalHum then finalHum.PlatformStand = false end
                
                if finalRoot then
                    finalRoot.Velocity = Vector3.new(0,0,0)
                    finalRoot.RotVelocity = Vector3.new(0,0,0)
                    if originalCFrame then finalRoot.CFrame = originalCFrame end
                end

                if finalChar then
                    for _, part in pairs(finalChar:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.Massless = false
                            part.CustomPhysicalProperties = nil
                            part.CanCollide = true
                        end
                    end
                end
                
                Notify("✅ تم إيقاف التطيير ورجعت لمكانك", "Fling All stopped, returned to position")
            end)
        else
            -- إيقاف الحلقة (سيتم التعامل معها داخل task.spawn)
            isFlingAllActive = false
        end
    end)
end
