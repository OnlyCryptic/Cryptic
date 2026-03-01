-- [[ Cryptic Hub - إعصار القطع الدوار V7 ]]
-- المطور: Cryptic | التحديث: دوران القطع حول الرأس (Orbiting) + توزيع رياضي منتظم

return function(Tab, UI)
    local runService = game:GetService("RunService")
    local players = game:GetService("Players")
    local lp = players.LocalPlayer
    
    local isMagnet = false
    local scanList = {}
    local magnetRadius = 45 -- مسافة السحب FE
    local pullSpeed = 8 -- سرعة الجذب والتتبع
    local orbitSpeed = 3 -- سرعة الدوران (الإعصار)
    local orbitRadius = 10 -- وسع الدائرة حول رأسك

    -- 1. التحكم بقوة الجذب
    Tab:AddInput("قوة الجذب الدوار (رقم)", "اكتب رقم (مثال: 8 أو 15)", function(txt)
        local num = tonumber(txt)
        if num then
            pullSpeed = num
            UI:Notify("⚡ تم تعيين قوة التجاذب إلى: " .. num)
        else
            UI:Notify("⚠️ الرجاء كتابة رقم صحيح!")
        end
    end)

    -- 2. حلقة المراقبة الذكية
    task.spawn(function()
        while task.wait(2) do
            if isMagnet then
                local tempParts = {}
                for _, part in ipairs(workspace:GetDescendants()) do
                    if part:IsA("BasePart") then
                        if not part.Locked and not part.Parent:FindFirstChildOfClass("Humanoid") and not part:IsDescendantOf(lp.Character) then
                            if part.Size.X <= 40 and part.Size.Y <= 40 and part.Size.Z <= 40 then
                                table.insert(tempParts, part)
                            end
                        end
                    end
                end
                scanList = tempParts
            end
        end
    end)

    -- 3. زر التفعيل
    Tab:AddToggle("🌪️ إعصار القطع (Orbit V7)", function(active)
        isMagnet = active
        if active then
            UI:Notify("🚀 تم تفعيل الإعصار! القطع ستدور في حلقة فوق رأسك.")
        else
            scanList = {}
            UI:Notify("❌ تم إيقاف الإعصار.")
        end
    end)

    -- 4. المحرك الفيزيائي والرياضي (هنا سحر الدوران)
    runService.Heartbeat:Connect(function()
        if not isMagnet then return end
        
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        local timeNow = tick() -- نستخدم الوقت لحساب الحركة الدائرية المستمرة
        local totalParts = #scanList -- عدد القطع المسحوبة

        for i, part in ipairs(scanList) do
            if part and part.Parent then
                local rootOfPart = part:GetRootPart()
                
                -- التأكد أن القطعة مفكوكة تماماً
                if not part.Anchored and rootOfPart and not rootOfPart.Anchored then
                    local dist = (part.Position - root.Position).Magnitude
                    
                    if dist <= magnetRadius then
                        part.CanCollide = false -- منع اللاق نهائياً
                        
                        -- [[ الرياضيات السحرية لتشكيل الحلقة الدوارة ]]
                        -- توزيع القطع بالتساوي على الدائرة
                        local angleOffset = (i / totalParts) * (math.pi * 2)
                        local currentAngle = (timeNow * orbitSpeed) + angleOffset
                        
                        -- حساب إحداثيات الدوران (X و Z) والارتفاع (Y)
                        local targetX = root.Position.X + (math.cos(currentAngle) * orbitRadius)
                        local targetZ = root.Position.Z + (math.sin(currentAngle) * orbitRadius)
                        local targetY = root.Position.Y + 15 -- ترتفع 15 مسمار فوق رأسك
                        
                        local targetPos = Vector3.new(targetX, targetY, targetZ)
                        local pullDirection = (targetPos - part.Position)
                        
                        -- تطبيق السحب نحو المسار الدائري
                        part.Velocity = pullDirection * pullSpeed 
                        
                        -- جعل القطعة تدور حول نفسها أيضاً لتعطي شكل عشوائي وجميل للإعصار
                        part.RotVelocity = Vector3.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))
                    end
                end
            end
        end
    end)
end
