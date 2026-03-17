-- [[ Cryptic Hub - تطيير الجميع الذكي (Constant Spin V5) ]]
-- المطور: يامي | الوصف: دوران مستمر لا يتوقف، استهداف الواقفين، تخطي للطائرين

return function(Tab, UI)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local StarterGui = game:GetService("StarterGui")
    local LocalPlayer = Players.LocalPlayer

    local isFlingAllActive = false
    local bav = nil 
    local spinConnection = nil -- 🔴 فصلنا الدوران في اتصال مستقل

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
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local torso = char and (char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso"))
        
        if state then
            if not char or not root or not hum or not torso then
                isFlingAllActive = false
                Notify("خطأ ⚠️", "لم يتم العثور على أجزاء الشخصية!")
                return
            end

            Notify("🌪️ جاري مسح السيرفر...", "Scanning and flinging stationary players...")

            local originalCFrame = root.CFrame
            hum.PlatformStand = true

            -- تجهيز أداة الدوران
            bav = Instance.new("BodyAngularVelocity")
            bav.Name = "CrypticAutoFlingBAV"
            bav.AngularVelocity = Vector3.new(0, 50000, 0)
            bav.MaxTorque = Vector3.new(0, math.huge, 0)
            bav.P = math.huge
            bav.Parent = torso

            -- 🔴 1. حلقة الفيزياء والدوران المستمر (لا تتوقف أبداً)
            spinConnection = RunService.Heartbeat:Connect(function()
                if not isFlingAllActive then return end
                
                local myChar = LocalPlayer.Character
                local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                local myTorso = myChar and (myChar:FindFirstChild("UpperTorso") or myChar:FindFirstChild("Torso"))
                
                if myRoot and myTorso then
                    -- تثبيت جذري للكاميرا
                    myRoot.Velocity = Vector3.new(0, 0, 0)
                    myRoot.RotVelocity = Vector3.new(0, 0, 0)
                    
                    -- دوران مستمر للنصف العلوي كالإعصار
                    myTorso.RotVelocity = Vector3.new(0, 50000, 0)

                    -- جعل الجسم صلب ومقاوم للجاذبية
                    for _, part in pairs(myChar:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.Massless = true
                            if part.Name == "HumanoidRootPart" or part.Name == "Torso" or part.Name == "UpperTorso" then
                                part.CanCollide = true
                                part.CustomPhysicalProperties = PhysicalProperties.new(100, 0, 1)
                            else
                                part.CanCollide = false
                            end
                        end
                    end
                end
            end)

            -- 🔴 2. حلقة التتبع والانتقال (CFrame فقط)
            task.spawn(function()
                while isFlingAllActive do
                    for _, targetPlayer in ipairs(Players:GetPlayers()) do
                        if not isFlingAllActive then break end
                        
                        if targetPlayer ~= LocalPlayer and targetPlayer.Character then
                            local targetChar = targetPlayer.Character
                            local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                            local targetHum = targetChar:FindFirstChildOfClass("Humanoid")

                            if targetRoot and targetHum and targetHum.Health > 0 then
                                -- التحقق من اللاعب الواقف
                                local isStationary = targetRoot.Velocity.Magnitude < 5
                                
                                if isStationary then
                                    local startTime = tick()
                                    local initialTargetY = targetRoot.Position.Y
                                    
                                    -- الانتقال للضحية لـ 1.5 ثانية
                                    while isFlingAllActive and targetChar and targetChar.Parent and targetHum.Health > 0 and (tick() - startTime < 1.5) do
                                        local myChar = LocalPlayer.Character
                                        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                                        
                                        if myRoot then
                                            -- التمركز الدقيق في الضحية (الدوران شغال أساساً من الـ Heartbeat)
                                            myRoot.CFrame = targetRoot.CFrame
                                            
                                            -- التخطي لو الضحية طارت
                                            if targetRoot.Velocity.Magnitude > 40 or math.abs(targetRoot.Position.Y - initialTargetY) > 10 then
                                                break 
                                            end
                                        end
                                        task.wait()
                                    end
                                end
                            end
                        end
                    end
                    task.wait(0.1)
                end

                -- [[ إيقاف التطيير والتنظيف ]]
                if spinConnection then spinConnection:Disconnect() spinConnection = nil end
                if bav then bav:Destroy() bav = nil end
                
                local finalChar = LocalPlayer.Character
                local finalRoot = finalChar and finalChar:FindFirstChild("HumanoidRootPart")
                local finalHum = finalChar and finalChar:FindFirstChildOfClass("Humanoid")
                local finalTorso = finalChar and (finalChar:FindFirstChild("UpperTorso") or finalChar:FindFirstChild("Torso"))
                
                if finalHum then finalHum.PlatformStand = false end
                if finalTorso then finalTorso.RotVelocity = Vector3.new(0,0,0) end
                
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
                            if part.Name == "HumanoidRootPart" then
                                part.CanCollide = false
                            else
                                part.CanCollide = true
                            end
                        end
                    end
                end
                
                Notify("✅ توقف التطيير", "Fling All stopped, returned to position")
            end)
        else
            isFlingAllActive = false
        end
    end)
    
    Tab:AddLine()
end
