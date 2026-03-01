-- [[ Cryptic Hub - الإعصار المثبت (Sticky Orbit V8) ]]
-- المطور: Cryptic | التحديث: مسافة 40 + دمج سرعة اللاعب مع القطع لمنع تساقطها + نظام القفل

return function(Tab, UI)
    local runService = game:GetService("RunService")
    local players = game:GetService("Players")
    local lp = players.LocalPlayer
    
    local isMagnet = false
    local scanList = {}
    local capturedParts = {} -- [السر هنا]: قائمة للقطع اللي مسكناها عشان ما تفلت
    local magnetRadius = 40 -- المسافة المطلوبة للالتقاط (كما طلبت)
    local pullSpeed = 12 -- سرعة التمركز فوق الرأس
    local orbitSpeed = 4 -- سرعة الدوران حول الرأس
    local orbitRadius = 12 -- وسع حلقة الدوران

    -- 1. خانة قوة الجذب
    Tab:AddInput("قوة التثبيت (رقم)", "اكتب رقم (مثال: 10 أو 15)", function(txt)
        local num = tonumber(txt)
        if num then
            pullSpeed = num
            UI:Notify("⚡ تم تعيين قوة التثبيت إلى: " .. num)
        end
    end)

    -- 2. حلقة المراقبة (تبحث عن القطع الجديدة كل ثانيتين)
    task.spawn(function()
        while task.wait(2) do
            if isMagnet then
                local tempParts = {}
                for _, part in ipairs(workspace:GetDescendants()) do
                    if part:IsA("BasePart") then
                        if not part.Locked and not part.Anchored and not part.Parent:FindFirstChildOfClass("Humanoid") and not part:IsDescendantOf(lp.Character) then
                            if part.Size.X <= 40 and part.Size.Y <= 40 and part.Size.Z <= 40 then
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
    Tab:AddToggle("🌪️ إعصار دوار مثبت (V8)", function(active)
        isMagnet = active
        if active then
            UI:Notify("🚀 الإعصار جاهز! القطع ستلتصق بك ولن تسقط إذا ركضت.")
        else
            capturedParts = {} -- تفريغ القطع الممسوكة لتسقط
            UI:Notify("❌ تم إيقاف الإعصار.")
        end
    end)

    -- 4. المحرك الفيزيائي المتطور (مدمج مع سرعة اللاعب)
    runService.Heartbeat:Connect(function()
        if not isMagnet then return end
        
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        local timeNow = tick()
        
        -- [[ نظام الالتقاط الذكي ]]: بمجرد دخول القطعة مسافة 40، يتم قفلها
        for _, part in ipairs(scanList) do
            if part and part.Parent then
                local dist = (part.Position - root.Position).Magnitude
                if dist <= magnetRadius then
                    -- إضافتها لقائمة الممسوكات إذا لم تكن موجودة
                    if not capturedParts[part] then
                        capturedParts[part] = true
                    end
                end
            end
        end

        -- حساب عدد القطع الممسوكة لتوزيعها في الدائرة
        local count = 0
        for part, _ in pairs(capturedParts) do
            if part and part.Parent then count = count + 1 end
        end

        local i = 0
        for part, _ in pairs(capturedParts) do
            if part and part.Parent then
                i = i + 1
                part.CanCollide = false -- منع اللاق
                
                -- حساب موقعها في الدائرة
                local angleOffset = (i / count) * (math.pi * 2)
                local currentAngle = (timeNow * orbitSpeed) + angleOffset
                
                local targetX = root.Position.X + (math.cos(currentAngle) * orbitRadius)
                local targetZ = root.Position.Z + (math.sin(currentAngle) * orbitRadius)
                local targetY = root.Position.Y + 12 -- ترتفع فوق الرأس بـ 12 مسمار
                
                local targetPos = Vector3.new(targetX, targetY, targetZ)
                local pullDirection = (targetPos - part.Position)
                
                -- [[ الحل السحري لمنع السقوط ]]:
                -- نجمع (اتجاه السحب) + (سرعة شخصيتك الحالية)
                -- هذا يخلي القطعة تركض معاك بنفس سرعتك وتدور في نفس الوقت!
                part.Velocity = (pullDirection * pullSpeed) + root.Velocity 
                
                -- دوران عشوائي خفيف للقطعة نفسها
                part.RotVelocity = Vector3.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))
                
                -- نظام حماية: إذا مت أو ترسبنت وبعدت القطع جداً، ينفك القفل عنها
                if (part.Position - root.Position).Magnitude > 100 then
                    capturedParts[part] = nil
                end
            else
                capturedParts[part] = nil -- تنظيف القطع المحذوفة
            end
        end
    end)
end
