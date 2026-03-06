-- [[ Cryptic Hub - ميزة تطيير الهدف (Fling) المطور ]]
-- المطور: أروى (Arwa) | الميزات: ضرب عشوائي، تتبع، عودة آمنة، فحص ذكي للتلامس

return function(Tab, UI)
    local runService = game:GetService("RunService")
    local players = game:GetService("Players")
    local PhysicsService = game:GetService("PhysicsService")
    local StarterGui = game:GetService("StarterGui")
    local lp = players.LocalPlayer
    
    local isFlinging = false
    local originalCFrame = nil -- لحفظ مكانك للرجوع الآمن

    -- دالة إشعارات روبلوكس بمدة 10 ثواني
    local function SendRobloxNotification(title, text)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = title,
                Text = text,
                Duration = 10, 
            })
        end)
    end

    -- [[ زر التفعيل ]]
    Tab:AddToggle("تطيير الهدف / Fling", function(active)
        isFlinging = active
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")

        if active then
            -- 1. التأكد من وجود هدف
            if not _G.ArwaTarget or not _G.ArwaTarget.Character then
                isFlinging = false
                SendRobloxNotification("Cryptic Hub", "⚠️ حدد لاعباً أولاً من مربع البحث أعلى القائمة!")
                return
            end

            -- [[ 2. الفحص الذكي والمزدوج لنظام التصادم (No-Collide Check) ]]
            local targetChar = _G.ArwaTarget.Character
            local myTorso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or root
            local targetTorso = targetChar:FindFirstChild("Torso") or targetChar:FindFirstChild("UpperTorso") or targetChar:FindFirstChild("HumanoidRootPart")
            
            if myTorso and targetTorso then
                -- الفحص الأول: هل الماب يستخدم مجموعات تصادم تمنع التلامس؟
                local success, canCollideGroup = pcall(function()
                    return PhysicsService:CollisionGroupsAreCollidable(myTorso.CollisionGroup, targetTorso.CollisionGroup)
                end)
                
                -- الفحص الثاني: هل الماب يحول اللاعبين لأشباح (CanCollide = false)؟
                local isTargetGhost = (targetTorso.CanCollide == false) and (targetChar:FindFirstChild("HumanoidRootPart") and targetChar.HumanoidRootPart.CanCollide == false)
                
                -- إذا تحقق أي من الشروط، يتم إيقاف التطيير فوراً!
                if (success and not canCollideGroup) or isTargetGhost then
                    isFlinging = false
                    SendRobloxNotification("Cryptic Hub", "🚫 هذا الماب يمنع تلامس اللاعبين (No-Collide)! الخدعة لن تعمل هنا.")
                    return 
                end
            end

            -- 3. حفظ مكانك الحالي للرجوع إليه بسلام
            if root then
                originalCFrame = root.CFrame
            end

            -- 4. تجميد شخصيتك للتحضير للدوران الحر
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.PlatformStand = true end
            end

            SendRobloxNotification("Cryptic Hub", "🔥 جاري تطيير وملاحقة: " .. _G.ArwaTarget.DisplayName)
        else
            -- [[ الإيقاف والعودة الآمنة لمكانك ]]
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.PlatformStand = false end
                
                if root then
                    -- تصفير الدوران والسرعة لمنع القلتشات
                    root.Velocity = Vector3.new(0, 0, 0)
                    root.RotVelocity = Vector3.new(0, 0, 0)
                    
                    -- العودة للمكان الأصلي بسلام
                    if originalCFrame then
                        root.CFrame = originalCFrame
                        originalCFrame = nil
                    end
                end

                -- إرجاع الأوزان والخصائص الفيزيائية الطبيعية
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Massless = false 
                        part.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)
                    end
                end
            end
            SendRobloxNotification("Cryptic Hub", "❌ توقف التطيير وعدت لمكانك بأمان.")
        end
    end)

    -- [[ المحرك الفيزيائي للتطيير والملاحقة العشوائية ]]
    runService.Heartbeat:Connect(function()
        if not isFlinging or not _G.ArwaTarget then return end
        
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local targetChar = _G.ArwaTarget.Character
        local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")

        if root and targetRoot then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    if part.Name == "HumanoidRootPart" or part.Name == "Torso" or part.Name == "UpperTorso" then
                        part.CanCollide = true
                        -- رفع كثافة شخصيتك لتصبح مثل الجدار المتحرك وتقليل الاحتكاك
                        part.CustomPhysicalProperties = PhysicalProperties.new(100, 0, 1)
                    else
                        part.CanCollide = false
                    end
                    part.Massless = true
                end
            end

            -- تتبع الهدف مع حساب سرعته الحالية (Predictive Tracking)
            local targetVel = targetRoot.Velocity
            local predictedPos = targetRoot.Position + (targetVel * 0.1)

            -- ضرب عشوائي من جميع الأنحاء لتدمير فيزياء الهدف
            local randX = math.random(-3, 3)
            local randY = math.random(-2, 3)
            local randZ = math.random(-3, 3)
            local randomOffset = Vector3.new(randX, randY, randZ)
            
            root.CFrame = CFrame.new(predictedPos + randomOffset)

            -- دوران عشوائي بسرعات جنونية في جميع المحاور
            local rotX = math.random(-50000, 50000)
            local rotY = math.random(-50000, 50000)
            local rotZ = math.random(-50000, 50000)
            
            -- قوة دفع للأعلى وللجوانب لضمان الطيران
            root.Velocity = Vector3.new(math.random(-1000, 1000), 5000, math.random(-1000, 1000))
            root.RotVelocity = Vector3.new(rotX, rotY, rotZ)
        end
    end)
end
