-- [[ Cryptic Hub - ميزة تطيير الهدف (Fling) المطور ]]
-- المطور: يامي (Yami) | الميزات: ضرب عشوائي، تتبع، عودة آمنة، إشعار 25 ثانية

return function(Tab, UI)
    local runService = game:GetService("RunService")
    local players = game:GetService("Players")
    local PhysicsService = game:GetService("PhysicsService")
    local StarterGui = game:GetService("StarterGui")
    local lp = players.LocalPlayer
    
    local isFlinging = false
    local originalCFrame = nil -- لحفظ مكانك للرجوع الآمن

    -- دالة إشعارات روبلوكس بمدة 25 ثانية
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
            -- استخدام المتغير المرتبط بملف البحث الخاص بك
            if not _G.ArwaTarget or not _G.ArwaTarget.Character then
                isFlinging = false
                SendRobloxNotification("Cryptic Hub", "⚠️ حدد لاعباً أولاً من مربع البحث أعلى القائمة!")
                return
            end

            -- فحص نظام التصادم في الماب (No-Collide Check)
            local targetChar = _G.ArwaTarget.Character
            local myTorso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or root
            local targetTorso = targetChar:FindFirstChild("Torso") or targetChar:FindFirstChild("UpperTorso") or targetChar:FindFirstChild("HumanoidRootPart")
            
            if myTorso and targetTorso then
                local success, canCollide = pcall(function()
                    return PhysicsService:CollisionGroupsAreCollidable(myTorso.CollisionGroup, targetTorso.CollisionGroup)
                end)
                
                if success and not canCollide then
                    isFlinging = false
                    SendRobloxNotification("Cryptic Hub", "🚫 هذا الماب يلغي تلامس اللاعبين (No-Collide)، الخدعة لن تعمل هنا!")
                    return 
                end
            end

            -- حفظ مكانك الحالي للرجوع إليه بسلام
            if root then
                originalCFrame = root.CFrame
            end

            -- تجميد شخصيتك للتحضير للدوران الحر
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
            
            -- قوة دفع للأعلى ולلجوانب لضمان الطيران
            root.Velocity = Vector3.new(math.random(-1000, 1000), 5000, math.random(-1000, 1000))
            root.RotVelocity = Vector3.new(rotX, rotY, rotZ)
        end
    end)
end