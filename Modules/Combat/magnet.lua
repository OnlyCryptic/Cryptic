-- [[ Cryptic Hub - الإعصار الهجومي V10 ]]
-- المطور: Cryptic | الميزات: جمع القطع، التحكم بالحجم، توجيه ضربة صاروخية للاعب محدد (Fling Attack)

return function(Tab, UI)
    local runService = game:GetService("RunService")
    local players = game:GetService("Players")
    local lp = players.LocalPlayer
    
    local isMagnet = false
    local isAttacking = false
    local targetPlayer = nil
    local scanList = {}
    local capturedParts = {} 
    local magnetRadius = 40 
    local pullSpeed = 12 
    local orbitSpeed = 4 
    local orbitRadius = 12 
    local maxPartSize = 150 
    local attackSpeed = 150 -- سرعة انطلاق القطع نحو الهدف (صاروخية)

    -- 1. إعدادات المغناطيس (السرعة والحجم)
    Tab:AddInput("قوة التثبيت (رقم)", "اكتب رقم (مثال: 10 أو 15)", function(txt)
        local num = tonumber(txt)
        if num then pullSpeed = num end
    end)

    Tab:AddInput("أقصى حجم للقطعة (رقم)", "الافتراضي 150", function(txt)
        local num = tonumber(txt)
        if num then maxPartSize = num end
    end)

    -- 2. نظام البحث الذكي عن الهدف (نفس نظام الـ Carry)
    local TargetInput = Tab:AddInput("🎯 استهداف لاعب للهجوم", "اكتب اليوزر وأغلق الكيبورد...", function() end)

    TargetInput.TextBox.FocusLost:Connect(function()
        local txt = TargetInput.TextBox.Text
        if txt == "" then targetPlayer = nil return end

        local bestMatch = nil
        local search = txt:lower()

        for _, p in pairs(players:GetPlayers()) do
            if p ~= lp and string.sub(p.Name:lower(), 1, #search) == search then
                bestMatch = p
                break 
            end
        end

        if bestMatch then
            targetPlayer = bestMatch
            TargetInput.SetText(bestMatch.DisplayName .. " (@" .. bestMatch.Name .. ")")
            UI:Notify("🎯 تم قفل الهدف بنجاح: " .. bestMatch.DisplayName)
        else
            targetPlayer = nil
            UI:Notify("❌ لم يتم العثور على اللاعب")
        end
    end)

    -- 3. أزرار التشغيل والهجوم
    Tab:AddToggle("🌪️ تشغيل الإعصار (جمع القطع)", function(active)
        isMagnet = active
        if active then
            UI:Notify("🚀 الإعصار جاهز! اجمع القطع الآن.")
        else
            isAttacking = false -- إيقاف الهجوم تلقائياً إذا طفيت المغناطيس
            capturedParts = {} 
            UI:Notify("❌ تم إيقاف الإعصار.")
        end
    end)

    Tab:AddToggle("⚔️ هجوم الإعصار (إطلاق القطع)", function(active)
        if active and not targetPlayer then
            UI:Notify("⚠️ الرجاء تحديد لاعب من خانة البحث أولاً!")
            return
        end
        isAttacking = active
        if active then
            UI:Notify("🔥 جاري قصف " .. targetPlayer.DisplayName .. " بالقطع!")
        else
            UI:Notify("🛑 تم إيقاف الهجوم، القطع تعود إليك.")
        end
    end)

    -- 4. حلقة المراقبة والبحث عن القطع
    task.spawn(function()
        while task.wait(2) do
            if isMagnet then
                local tempParts = {}
                for _, part in ipairs(workspace:GetDescendants()) do
                    if part:IsA("BasePart") then
                        if not part.Locked and not part.Anchored and not part.Parent:FindFirstChildOfClass("Humanoid") and not part:IsDescendantOf(lp.Character) then
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

    -- 5. المحرك الفيزيائي (الدوران + الهجوم)
    runService.Heartbeat:Connect(function()
        if not isMagnet then return end
        
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        local timeNow = tick()
        
        -- التقاط القطع القريبة
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
                
                -- [[ وضع الهجوم المباشر ]]
                if isAttacking and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local tRoot = targetPlayer.Character.HumanoidRootPart
                    
                    part.CanCollide = true -- تفعيل الصلابة عشان تصدم الهدف وتطيره
                    
                    -- توجيه القطعة نحو الهدف مباشرة بسرعة خارقة
                    local direction = (tRoot.Position - part.Position).Unit
                    part.Velocity = direction * attackSpeed
                    
                    -- دوران عنيف للقطعة لزيادة نسبة الـ Fling عند الاصطدام
                    part.RotVelocity = Vector3.new(math.random(-50, 50), math.random(-50, 50), math.random(-50, 50))
                    
                -- [[ وضع الدوران العادي (تجميع) ]]
                else
                    part.CanCollide = false -- منع اللاق لك
                    
                    local angleOffset = (i / count) * (math.pi * 2)
                    local currentAngle = (timeNow * orbitSpeed) + angleOffset
                    
                    local targetX = root.Position.X + (math.cos(currentAngle) * orbitRadius)
                    local targetZ = root.Position.Z + (math.sin(currentAngle) * orbitRadius)
                    local targetY = root.Position.Y + 12 
                    
                    local targetPos = Vector3.new(targetX, targetY, targetZ)
                    local pullDirection = (targetPos - part.Position)
                    
                    part.Velocity = (pullDirection * pullSpeed) + root.Velocity 
                    part.RotVelocity = Vector3.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))
                end
                
                -- التخلص من القطع التي ضاعت بعيداً جداً (حماية)
                if (part.Position - root.Position).Magnitude > 300 then
                    capturedParts[part] = nil
                end
            else
                capturedParts[part] = nil 
            end
        end
    end)
end
