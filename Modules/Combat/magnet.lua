-- [[ Cryptic Hub - مغناطيس السيرفر V2 ]]
-- المطور: Cryptic | التحديث: منع اللاج، رفع القطع عالياً جداً، فلترة ذكية للقطع المثبتة

return function(Tab, UI)
    local runService = game:GetService("RunService")
    local players = game:GetService("Players")
    local lp = players.LocalPlayer
    
    local isMagnet = false
    local magnetParts = {}
    local maxParts = 40 -- تحديد أقصى عدد للقطع لمنع اللاج نهائياً

    -- وظيفة الفحص الذكي (مقسمة لكي لا تجمد الجوال)
    local function scanParts()
        table.clear(magnetParts) -- تنظيف القائمة القديمة
        local count = 0
        
        for _, v in pairs(workspace:GetDescendants()) do
            -- التحقق الصارم: يجب أن تكون قطعة، وغير مثبتة، وليست مقفلة (Locked)
            if v:IsA("BasePart") and not v.Anchored and not v.Locked then
                -- التأكد التام أنها ليست جزءاً من لاعب أو شخصية حية
                if v.Parent and not v.Parent:FindFirstChildOfClass("Humanoid") and not v:IsDescendantOf(lp.Character) then
                    table.insert(magnetParts, v)
                    
                    -- السر وراء منع اللاج: تعطيل تصادم القطع المجمعة ببعضها
                    v.CanCollide = false 
                    
                    if #magnetParts >= maxParts then break end -- التوقف عند 40 قطعة لحماية المعالج
                end
            end
            
            -- تقسيم عملية البحث لتخفيف الضغط على الجوال
            count = count + 1
            if count % 200 == 0 then task.wait() end 
        end
    end

    Tab:AddToggle("🧲 مغناطيس السيرفر (V2)", function(active)
        isMagnet = active
        if active then
            UI:Notify("🔍 جاري الفحص الآمن للماب (بدون لاج)...")
            task.spawn(scanParts)
            UI:Notify("✨ تم التشغيل! انظر عالياً فوق رأسك.")
        else
            table.clear(magnetParts)
            UI:Notify("❌ تم إيقاف المغناطيس")
        end
    end)

    -- تحديث القطع كل 5 ثواني بدلاً من 3 لتخفيف استهلاك البطارية
    task.spawn(function()
        while task.wait(5) do
            if isMagnet then
                scanParts()
            end
        end
    end)

    -- المحرك الفعلي لرفع القطع عالياً جداً
    runService.Heartbeat:Connect(function()
        if not isMagnet then return end
        
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        
        if root then
            for _, part in ipairs(magnetParts) do
                -- تحقق إضافي لضمان عدم سحب قطع تم تثبيتها فجأة
                if part and part.Parent and not part.Anchored then
                    -- [[ رفع القطع عالياً جداً وتوزيعها ]]
                    -- Y = بين 20 و 35 مسمار فوق رأسك (عالية جداً كما طلبت)
                    -- X و Z = توزيع عشوائي واسع لكي تشكل سحابة فوقك
                    local randomX = math.random(-15, 15)
                    local randomY = math.random(25, 40) -- الارتفاع الشاهق
                    local randomZ = math.random(-15, 15)
                    
                    part.CFrame = root.CFrame * CFrame.new(randomX, randomY, randomZ)
                    
                    -- تجميد فيزياء القطعة وهي بالهواء لقتل اللاج نهائياً
                    part.Velocity = Vector3.new(0, 0, 0)
                    part.RotVelocity = Vector3.new(0, 0, 0)
                end
            end
        end
    end)
end
