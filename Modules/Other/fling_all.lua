-- [[ Cryptic Hub - تطيير الجميع (Auto Fling All) ]]
-- المطور: يامي (Yami) | الوصف: انتقال متسلسل وتطيير إجباري بدون فحص مزعج للتلامس

return function(Tab, UI)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
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

            -- 🗑️ تم إزالة فحص التلامس بالكامل! السكربت سيهجم فوراً.

            Notify("🌪️ جاري تطيير الجميع بالترتيب...", "Starting to fling everyone...")

            -- حفظ المكان للرجوع إليه
            local originalCFrame = root.CFrame
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.PlatformStand = true end -- تجميد المشي لتجنب القلتشات

            -- [[ حلقة التطيير المتسلسلة ]]
            task.spawn(function()
                while isFlingAllActive do
                    for _, targetPlayer in ipairs(Players:GetPlayers()) do
                        if not isFlingAllActive then break end
                        
                        if targetPlayer ~= LocalPlayer and targetPlayer.Character then
                            local targetChar = targetPlayer.Character
                            local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                            local targetHum = targetChar:FindFirstChildOfClass("Humanoid")

                            if targetRoot and targetHum and targetHum.Health > 0 then
                                local startTime = tick()
                                
                                -- الهجوم على هذا اللاعب لمدة 2.5 ثانية
                                while isFlingAllActive and targetChar and targetChar.Parent and targetHum.Health > 0 and (tick() - startTime < 2.5) do
                                    local myChar = LocalPlayer.Character
                                    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                                    
                                    if myRoot then
                                        -- إجبار شخصيتك على الصلابة والوزن الثقيل لتدمير الهدف (Noclip + Anti-Fling مدمج)
                                        for _, part in pairs(myChar:GetChildren()) do
                                            if part:IsA("BasePart") then
                                                if part.Name == "HumanoidRootPart" or part.Name == "Torso" or part.Name == "UpperTorso" then
                                                    part.CanCollide = true
                                                    part.CustomPhysicalProperties = PhysicalProperties.new(100, 0, 1)
                                                else
                                                    part.CanCollide = false
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
                    -- استراحة بسيطة قبل إعادة الدورة على السيرفر
                    task.wait(0.1)
                end

                -- [[ إيقاف التطيير والعودة للحالة الطبيعية ]]
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
                            -- إرجاع حالة الاصطدام للطبيعي
                            if part.Name == "HumanoidRootPart" then
                                part.CanCollide = false
                            else
                                part.CanCollide = true
                            end
                        end
                    end
                end
                
                Notify("✅ تم إيقاف التطيير ورجعت لمكانك", "Fling All stopped, returned to position")
            end)
        else
            isFlingAllActive = false
        end
    end)
end
