-- [[ Cryptic Hub - تطيير الجميع الذكي (Smart Auto Fling All - Physics Fix) ]]
-- المطور: يامي | الوصف: سحب مغناطيسي للسماح بالدوران، استهداف الواقفين، تخطي للطائرين

return function(Tab, UI)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local StarterGui = game:GetService("StarterGui")
    local LocalPlayer = Players.LocalPlayer

    local isFlingAllActive = false
    local bav = nil 
    local bp = nil

    local function Notify(arText, enText)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Cryptic Hub",
                Text = arText .. "\n" .. enText,
                Duration = 5
            })
        end)
    end

    Tab:AddToggle("تطيير الجميع الذكي / Smart Fling All", function(state)
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

            -- 1. أداة الدوران (للنصف العلوي)
            bav = Instance.new("BodyAngularVelocity")
            bav.Name = "CrypticAutoFlingBAV"
            bav.AngularVelocity = Vector3.new(0, 50000, 0)
            bav.MaxTorque = Vector3.new(0, math.huge, 0)
            bav.P = math.huge
            bav.Parent = torso

            -- 2. أداة التتبع المغناطيسي (لجعل الفيزياء تعمل بحرية)
            bp = Instance.new("BodyPosition")
            bp.Name = "CrypticAutoFlingBP"
            bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bp.P = 15000 -- قوة السحب
            bp.D = 100
            bp.Parent = root

            -- إيقاف التصادم المبدئي للطيران السلس
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end

            task.spawn(function()
                while isFlingAllActive do
                    for _, targetPlayer in ipairs(Players:GetPlayers()) do
                        if not isFlingAllActive then break end
                        
                        if targetPlayer ~= LocalPlayer and targetPlayer.Character then
                            local targetChar = targetPlayer.Character
                            local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                            local targetHum = targetChar:FindFirstChildOfClass("Humanoid")

                            if targetRoot and targetHum and targetHum.Health > 0 then
                                -- التحقق من أن الضحية واقفة
                                local isStationary = targetRoot.Velocity.Magnitude < 5
                                
                                if isStationary then
                                    local startTime = tick()
                                    local initialTargetY = targetRoot.Position.Y
                                    
                                    -- انتقال فوري مرة واحدة لتسريع السحب المغناطيسي
                                    root.CFrame = CFrame.new(targetRoot.Position)

                                    -- 🔴 الهجوم لمدة 1.5 ثانية (باستخدام Stepped لتجاوز فيزياء اللعبة)
                                    while isFlingAllActive and targetRoot and targetRoot.Parent and targetHum.Health > 0 and (tick() - startTime < 1.5) do
                                        
                                        -- تحديث موقع المغناطيس ليتطابق مع الضحية
                                        bp.Position = targetRoot.Position
                                        
                                        -- إجبار الجزء العلوي على الدوران، وتثبيت السفلي (الكاميرا)
                                        root.RotVelocity = Vector3.new(0, 0, 0)
                                        torso.RotVelocity = Vector3.new(0, 50000, 0)
                                        
                                        -- تفعيل الضرب المدمر
                                        root.CanCollide = true
                                        root.CustomPhysicalProperties = PhysicalProperties.new(100, 0, 1)

                                        -- تخطي سريع إذا طارت الضحية
                                        if targetRoot.Velocity.Magnitude > 40 or math.abs(targetRoot.Position.Y - initialTargetY) > 10 then
                                            break 
                                        end
                                        
                                        RunService.Stepped:Wait() -- أسرع وأقوى من task.wait فيزيائياً
                                    end
                                    
                                    root.CanCollide = false -- إيقاف التصادم قبل الانتقال للضحية التالية
                                end
                            end
                        end
                    end
                    task.wait(0.1)
                end

                -- [[ إيقاف التطيير والتنظيف ]]
                if bav then bav:Destroy() bav = nil end
                if bp then bp:Destroy() bp = nil end
                
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
                    for _, part in pairs(finalChar:GetDescendants()) do
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
