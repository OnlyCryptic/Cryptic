-- [[ Arwa Hub - ميزة تطيير الهدف (Fling) المطور ]]
-- المطور: يامي (Yami) | الميزات: ملاحقة مستمرة، فحص تصادم، عودة آمنة، إشعار 25 ثانية

return function(Tab, UI)
    local runService = game:GetService("RunService")
    local players = game:GetService("Players")
    local PhysicsService = game:GetService("PhysicsService")
    local StarterGui = game:GetService("StarterGui")
    local lp = players.LocalPlayer
    
    local isFlinging = false
    local originalCFrame = nil -- متغير لحفظ مكانك قبل التطيير

    -- دالة إشعارات روبلوكس بمدة 25 ثانية
    local function SendRobloxNotification(title, text)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = title,
                Text = text,
                Duration = 25, -- تم ضبط المدة لتكون 25 ثانية
            })
        end)
    end

    -- [[ زر التفعيل مع فحص التصادم والحفظ ]]
    Tab:AddToggle("تطيير الهدف / fling", function(active)
        isFlinging = active
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")

        if active then
            -- التأكد من وجود هدف
            if not _G.ArwaTarget or not _G.ArwaTarget.Character then
                isFlinging = false
                SendRobloxNotification("Arwa Hub", "⚠️ حدد لاعباً أولاً من مربع البحث أعلى القائمة!")
                return
            end

            -- فحص نظام التصادم في الماب (Collision Check)
            local targetChar = _G.ArwaTarget.Character
            local myTorso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or root
            local targetTorso = targetChar:FindFirstChild("Torso") or targetChar:FindFirstChild("UpperTorso") or targetChar:FindFirstChild("HumanoidRootPart")
            
            if myTorso and targetTorso then
                local success, canCollide = pcall(function()
                    return PhysicsService:CollisionGroupsAreCollidable(myTorso.CollisionGroup, targetTorso.CollisionGroup)
                end)
                
                if success and not canCollide then
                    isFlinging = false
                    SendRobloxNotification("Arwa Hub", "🚫 الماب يلغي تلامس اللاعبين (No-Collide)، الخدعة لن تعمل هنا!")
                    return 
                end
            end

            -- حفظ مكانك الحالي للرجوع إليه بسلام
            if root then
                originalCFrame = root.CFrame
            end

            -- تجميد شخصيتك للتحضير للدوران (يمنع مقاومة اللعبة للدوران)
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.PlatformStand = true end
            end

            SendRobloxNotification("Arwa Hub", "🔥 جاري تطيير وملاحقة: " .. _G.ArwaTarget.DisplayName)
        else
            -- [[ الإيقاف والعودة الآمنة ]]
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

                -- إرجاع الأوزان الطبيعية
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Massless = false 
                    end
                end
            end
            SendRobloxNotification("Arwa Hub", "❌ توقف التطيير وعدت لمكانك بأمان.")
        end
    end)

    -- [[ المحرك الفيزيائي للتطيير والملاحقة ]]
    runService.Heartbeat:Connect(function()
        if not isFlinging or not _G.ArwaTarget then return end
        
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local targetChar = _G.ArwaTarget.Character
        local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")

        if root and targetRoot then
            -- إعداد التصادم للدوران القاتل
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    -- الجزء الأساسي يجب أن يصطدم ليطير الخصم
                    if part.Name == "HumanoidRootPart" or part.Name == "Torso" or part.Name == "UpperTorso" then
                        part.CanCollide = true
                    else
                        part.CanCollide = false
                    end
                    part.Massless = true
                end
            end

            -- الملاحقة المستمرة مع التنبؤ بحركة الخصم 
            -- (إذا الخصم يركض، شخصيتك راح تسبقه بخطوة وتلتصق فيه)
            local predictedPos = targetRoot.CFrame + (targetRoot.Velocity * 0.1)
            root.CFrame = predictedPos

            -- قوة دوران مغزلية خارقة في جميع الاتجاهات (Fling)
            root.Velocity = Vector3.new(0, 0, 0) -- البقاء في نفس مستوى الخصم
            root.RotVelocity = Vector3.new(50000, 50000, 50000) 
        end
    end)
end
