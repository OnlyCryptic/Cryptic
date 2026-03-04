-- [[ Cryptic Hub - ميزة تطيير الهدف (Fling) المطور ]]
-- المطور: يامي (Yami) | الميزات: تطيير الأهداف المتحركة بثقل، عودة آمنة بالتجميد، إشعار 25 ثانية

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
                Duration = 25, 
            })
        end)
    end

    -- [[ زر التفعيل ]]
    Tab:AddToggle("تطيير الهدف / Fling", function(active)
        isFlinging = active
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")

        if active then
            -- القراءة من متغير الاستهداف المرتبط بملف البحث
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

            -- حفظ مكانك الحالي للرجوع إليه
            if root then
                originalCFrame = root.CFrame
            end

            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.PlatformStand = true end
            end

            SendRobloxNotification("Cryptic Hub", "🔥 جاري تطيير وملاحقة: " .. _G.ArwaTarget.DisplayName)
        else
            -- [[ الرجوع الآمن باستخدام التجميد (Anchoring) لمنع الموت ]]
            if char and root then
                local hum = char:FindFirstChildOfClass("Humanoid")
                
                -- تجميد اللاعب مؤقتاً لامتصاص الصدمة الفيزيائية
                root.Anchored = true 
                root.Velocity = Vector3.new(0, 0, 0)
                root.RotVelocity = Vector3.new(0, 0, 0)
                
                -- إرجاع الأوزان والخصائص الطبيعية
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)
                        part.CanCollide = true
                        part.Massless = false
                    end
                end

                if originalCFrame then
                    -- نرفعه 3 مسامير عن الأرض عشان ما يندمج مع الأرض ويموت
                    root.CFrame = originalCFrame + Vector3.new(0, 3, 0)
                    originalCFrame = nil
                end

                -- انتظار لتستقر الفيزياء
                task.wait(0.1) 
                
                if hum then hum.PlatformStand = false end
                root.Anchored = false 
            end
            SendRobloxNotification("Cryptic Hub", "❌ توقف التطيير وعدت لمكانك بأمان.")
        end
    end)

    -- [[ المحرك الفيزيائي للتطيير ]]
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
                        -- رفع الكثافة بشكل ضخم لجعلك ثقيلاً مثل الجدار
                        part.CustomPhysicalProperties = PhysicalProperties.new(100, 0.3, 0.5)
                        part.Massless = false 
                    else
                        part.CanCollide = false
                    end
                end
            end

            local targetVel = targetRoot.Velocity
            local offset = Vector3.new(math.random(-1, 1), math.random(-1, 1), math.random(-1, 1))
            
            -- الالتصاق الدقيق والتنبؤ بالحركة مع إزاحة عشوائية للضرب من كل الجهات
            root.CFrame = CFrame.new(targetRoot.Position + (targetVel * 0.1) + offset)

            -- سرعة جنونية في كل المحاور لضمان تدمير فيزياء الهدف وتطييره
            root.Velocity = Vector3.new(math.random(-50000, 50000), 50000, math.random(-50000, 50000))
            root.RotVelocity = Vector3.new(50000, 50000, 50000)
        end
    end)
end
