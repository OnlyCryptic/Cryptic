-- [[ Cryptic Hub - الإعصار الشامل V9 ]]
-- المطور: Cryptic | التحديث: التحكم بحجم القطع المسحوبة لسحب الأشياء الكبيرة

return function(Tab, UI)
    local runService = game:GetService("RunService")
    local players = game:GetService("Players")
    local lp = players.LocalPlayer
    
    local isMagnet = false
    local scanList = {}
    local capturedParts = {} 
    local magnetRadius = 40 
    local pullSpeed = 12 
    local orbitSpeed = 4 
    local orbitRadius = 12 
    local maxPartSize = 150 -- تم رفع الحجم الافتراضي لـ 150 لسحب القطع الكبيرة

    -- 1. خانات التحكم بالسرعة والحجم
    Tab:AddInput("قوة التثبيت (رقم)", "اكتب رقم (مثال: 10 أو 15)", function(txt)
        local num = tonumber(txt)
        if num then pullSpeed = num end
    end)

    -- الخانة الجديدة للتحكم بحجم القطع
    Tab:AddInput("أقصى حجم للقطعة (رقم)", "الافتراضي 150", function(txt)
        local num = tonumber(txt)
        if num then 
            maxPartSize = num 
            UI:Notify("📏 تم تعيين أقصى حجم إلى: " .. num)
        end
    end)

    -- 2. حلقة المراقبة (تفحص القطع بناءً على الحجم الجديد)
    task.spawn(function()
        while task.wait(2) do
            if isMagnet then
                local tempParts = {}
                for _, part in ipairs(workspace:GetDescendants()) do
                    if part:IsA("BasePart") then
                        if not part.Locked and not part.Anchored and not part.Parent:FindFirstChildOfClass("Humanoid") and not part:IsDescendantOf(lp.Character) then
                            -- [[ السر هنا ]]: استخدام الحجم الذي تحددينه في الواجهة
                            if part.Size.X <= maxPartSize and part.Size.Y <= maxPartSize and part.Size.Z <= maxPartSize then
                                local rootOfPart = part:GetRootPart()
                                if rootOfPart and not rootOfPart.Anchored then
                                    table.insert(tempParts, part)
                                end
                            end
                        end
                    end
                end
                scanList = tempParts
            end
        end
    end)

    -- 3. زر التفعيل
    Tab:AddToggle("🌪️ إعصار دوار شامل (V9)", function(active)
        isMagnet = active
        if active then
            UI:Notify("🚀 الإعصار جاهز! سيبدأ بسحب القطع الكبيرة والصغيرة.")
        else
            capturedParts = {} 
            UI:Notify("❌ تم إيقاف الإعصار.")
        end
    end)

    -- 4. المحرك الفيزيائي
    runService.Heartbeat:Connect(function()
        if not isMagnet then return end
        
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        local timeNow = tick()
        
        for _, part in ipairs(scanList) do
            if part and part.Parent then
                local dist = (part.Position - root.Position).Magnitude
                if dist <= magnetRadius then
                    if not capturedParts[part] then
                        capturedParts[part] = true
                    end
                end
            end
        end

        local count = 0
        for part, _ in pairs(capturedParts) do
            if part and part.Parent then count = count + 1 end
        end

        local i = 0
        for part, _ in pairs(capturedParts) do
            if part and part.Parent then
                i = i + 1
                part.CanCollide = false 
                
                local angleOffset = (i / count) * (math.pi * 2)
                local currentAngle = (timeNow * orbitSpeed) + angleOffset
                
                local targetX = root.Position.X + (math.cos(currentAngle) * orbitRadius)
                local targetZ = root.Position.Z + (math.sin(currentAngle) * orbitRadius)
                local targetY = root.Position.Y + 12 
                
                local targetPos = Vector3.new(targetX, targetY, targetZ)
                local pullDirection = (targetPos - part.Position)
                
                part.Velocity = (pullDirection * pullSpeed) + root.Velocity 
                part.RotVelocity = Vector3.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))
                
                if (part.Position - root.Position).Magnitude > 150 then
                    capturedParts[part] = nil
                end
            else
                capturedParts[part] = nil 
            end
        end
    end)
end
