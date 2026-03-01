-- [[ Cryptic Hub - مغناطيس السيرفر FE الحقيقي V3 ]]
-- المطور: Cryptic | التحديث: رؤية السيرفر للقطع (FE) + منع سحب الملحومات (Welds) + حماية اللاق

return function(Tab, UI)
    local runService = game:GetService("RunService")
    local players = game:GetService("Players")
    local lp = players.LocalPlayer
    
    local isMagnet = false
    local looseParts = {}
    local magnetRadius = 45 -- مسافة السحب (الحد الأقصى لكي يراها السيرفر)

    -- 1. وظيفة الفحص العميق (تتأكد إن القطعة مفكوكة 100% وما فيها لحام)
    local function isTrulyLoose(part)
        if part.Anchored or part.Locked then return false end
        
        -- البحث عن القطع الملتصقة بها (Welds)
        local connected = part:GetConnectedParts()
        for _, p in ipairs(connected) do
            if p.Anchored then return false end -- إذا ملصوقة بشيء مثبت، اتركها!
        end
        return true
    end

    -- 2. حلقة فحص الماب كل 3 ثواني (خفيفة جداً على Redmi Note 10s)
    task.spawn(function()
        while task.wait(3) do
            if isMagnet then
                local tempParts = {}
                for _, part in ipairs(workspace:GetDescendants()) do
                    if part:IsA("BasePart") then
                        -- استثناء اللاعبين وشخصيتك
                        if not part.Parent:FindFirstChild("Humanoid") and not part:IsDescendantOf(lp.Character) then
                            if isTrulyLoose(part) then
                                table.insert(tempParts, part)
                            end
                        end
                    end
                end
                looseParts = tempParts -- تحديث القائمة بالقطع الآمنة فقط
            end
        end
    end)

    -- 3. زر التفعيل
    Tab:AddToggle("🧲 مغناطيس السيرفر (FE V3)", function(active)
        isMagnet = active
        if active then
            UI:Notify("🚀 تم تفعيل المغناطيس FE. امشِ بجانب القطع لرفعها للسماء!")
        else
            looseParts = {}
            UI:Notify("❌ تم إيقاف المغناطيس")
        end
    end)

    -- 4. محرك السحب الفيزيائي (يراه السيرفر)
    runService.Heartbeat:Connect(function()
        if not isMagnet then return end
        
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        for _, part in ipairs(looseParts) do
            if part and part.Parent then
                -- حساب المسافة بينك وبين القطعة
                local dist = (part.Position - root.Position).Magnitude
                
                -- السر هنا: القطعة ترتفع فقط إذا كانت قريبة منك (لكي يراها السيرفر)
                if dist <= magnetRadius then
                    part.CanCollide = false -- منع التصادم لقتل اللاق
                    
                    -- رفعها عالياً جداً فوق رأسك (بين 25 و 40 مسمار)
                    part.CFrame = root.CFrame * CFrame.new(math.random(-15, 15), math.random(25, 40), math.random(-15, 15))
                    
                    -- إعطاء قوة دفع خفيفة لإجبار السيرفر على تحديث موقعها للجميع
                    part.Velocity = Vector3.new(0, 5, 0)
                    part.RotVelocity = Vector3.new(0, 0, 0)
                end
            end
        end
    end)
end
