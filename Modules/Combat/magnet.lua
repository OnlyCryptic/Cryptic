-- [[ Cryptic Hub - مغناطيس السيرفر الصاروخي V6 ]]
-- المطور: Cryptic | التحديث: تحكم بسرعة السحب + تمركز سريع فوق الرأس

return function(Tab, UI)
    local runService = game:GetService("RunService")
    local players = game:GetService("Players")
    local lp = players.LocalPlayer
    
    local isMagnet = false
    local scanList = {}
    local magnetRadius = 45 -- مسافة ملكية السيرفر (FE)
    local pullSpeed = 4 -- السرعة الافتراضية

    -- 1. خانة التحكم بسرعة السحب
    Tab:AddInput("سرعة المغناطيس (رقم)", "اكتب رقم (مثال: 10 أو 20)", function(txt)
        local num = tonumber(txt)
        if num then
            pullSpeed = num
            UI:Notify("⚡ تم تعيين سرعة السحب إلى: " .. num)
        else
            UI:Notify("⚠️ الرجاء كتابة رقم صحيح!")
        end
    end)

    -- 2. حلقة المراقبة (تفحص القطع المكسورة والمرمية كل ثانيتين)
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
    Tab:AddToggle("🧲 مغناطيس فوق الرأس (V6)", function(active)
        isMagnet = active
        if active then
            UI:Notify("🚀 المغناطيس جاهز! امشِ لشفط القطع فوق رأسك.")
        else
            scanList = {}
            UI:Notify("❌ تم إيقاف المغناطيس وسقطت القطع.")
        end
    end)

    -- 4. المحرك الفيزيائي السريع (هنا التمركز فوق الرأس)
    runService.Heartbeat:Connect(function()
        if not isMagnet then return end
        
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        for _, part in ipairs(scanList) do
            if part and part.Parent then
                local rootOfPart = part:GetRootPart()
                
                -- التحقق من أن القطعة مفكوكة تماماً
                if not part.Anchored and rootOfPart and not rootOfPart.Anchored then
                    local dist = (part.Position - root.Position).Magnitude
                    
                    if dist <= magnetRadius then
                        part.CanCollide = false -- منع اللاق
                        
                        -- [[ التمركز فوق الرأس مباشرة بـ 20 مسمار ]]
                        local targetPos = root.Position + Vector3.new(0, 20, 0)
                        local pullDirection = (targetPos - part.Position)
                        
                        -- [[ تطبيق السرعة الصاروخية التي اخترتها ]]
                        -- السيرفر سيشاهد القطع تطير بسرعة وتستقر فوق رأسك
                        part.Velocity = pullDirection * pullSpeed 
                        part.RotVelocity = Vector3.new(0, 0, 0)
                    end
                end
            end
        end
    end)
end
