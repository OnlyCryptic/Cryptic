-- [[ Cryptic Hub - مغناطيس السيرفر الديناميكي V5 ]]
-- المطور: Cryptic | التحديث: استجابة للكسر المباشر + السحب ضمن نطاق الملكية (45) فقط

return function(Tab, UI)
    local runService = game:GetService("RunService")
    local players = game:GetService("Players")
    local lp = players.LocalPlayer
    
    local isMagnet = false
    local scanList = {} -- قائمة للمراقبة فقط
    local magnetRadius = 45 -- المسافة الآمنة لكي يراها السيرفر

    -- 1. حلقة المراقبة (تفحص الماب بهدوء كل ثانيتين وتجهز القطع القابلة للسحب)
    task.spawn(function()
        while task.wait(2) do
            if isMagnet then
                local tempParts = {}
                for _, part in ipairs(workspace:GetDescendants()) do
                    if part:IsA("BasePart") then
                        -- نتأكد إنها مو تابعة للاعبين وإنها مو مقفلة
                        if not part.Locked and not part.Parent:FindFirstChildOfClass("Humanoid") and not part:IsDescendantOf(lp.Character) then
                            -- نستثني القطع العملاقة جداً (الأراضي)
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

    Tab:AddToggle("🧲 مغناطيس ذكي (FE V5)", function(active)
        isMagnet = active
        if active then
            UI:Notify("🚀 المغناطيس جاهز! اكسر الأشياء أو اقترب منها لسحبها.")
        else
            scanList = {}
            UI:Notify("❌ تم إيقاف المغناطيس.")
        end
    end)

    -- 2. المحرك الفيزيائي (هنا يتم تطبيق فكرتك الذكية)
    runService.Heartbeat:Connect(function()
        if not isMagnet then return end
        
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        for _, part in ipairs(scanList) do
            -- نتأكد إن القطعة لسا موجودة باللعبة
            if part and part.Parent then
                
                -- [[ تطبيق فكرتك الأولى: التحقق اللحظي من الانفصال ]]
                -- السكربت يتأكد "الآن" هل القطعة مفكوكة تماماً؟ 
                -- إذا كانت ملحومة بجدار، بيتجاهلها.. وإذا انكسر الجدار وطاحت، بيبدأ يسحبها!
                local rootOfPart = part:GetRootPart()
                if not part.Anchored and rootOfPart and not rootOfPart.Anchored then
                    
                    -- [[ تطبيق فكرتك الثانية: السحب ضمن مسافة الـ 45 فقط ]]
                    local dist = (part.Position - root.Position).Magnitude
                    if dist <= magnetRadius then
                        
                        -- تعطيل التصادم لمنع اللاق على جوالك
                        part.CanCollide = false 
                        
                        -- تحديد نقطة التجمع (30 مسمار فوق راسك)
                        local targetPos = root.Position + Vector3.new(0, 30, 0)
                        
                        -- حساب اتجاه السحب
                        local pullDirection = (targetPos - part.Position)
                        
                        -- الدفع الفيزيائي (Velocity) الذي يراه السيرفر
                        -- كلما كانت القطعة بعيدة، تُسحب بسرعة، ولما تقرب فوقك تبطئ وتستقر
                        part.Velocity = pullDirection * 3 
                        part.RotVelocity = Vector3.new(0, 0, 0)
                    end
                end
            end
        end
    end)
end
