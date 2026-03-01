-- [[ Cryptic Hub - ميزة الرفع الحقيقي والواقعي ]]
-- المطور: Cryptic | الميزة: رفع فيزيائي (FE) يراه المستهدف والسيرفر

return function(Tab, UI)
    local runService = game:GetService("RunService")
    local players = game:GetService("Players")
    local lp = players.LocalPlayer
    
    local isCarrying = false
    local liftHeight = 0
    local liftSpeed = 0.04 -- سرعة رفع بطيئة جداً لتبدو واقعية

    -- 1. خانة البحث الذكي (كما طلبت تماماً)
    local InputField = Tab:AddInput("البحث عن لاعب", "اكتب بداية اليوزر وأغلق الكيبورد...", function() end)

    InputField.TextBox.FocusLost:Connect(function()
        local txt = InputField.TextBox.Text
        if txt == "" then 
            _G.CrypticTarget = nil
            return 
        end

        local bestMatch = nil
        local search = txt:lower()

        for _, p in pairs(players:GetPlayers()) do
            -- البحث بمطابقة بداية الاسم
            if p ~= lp and string.sub(p.Name:lower(), 1, #search) == search then
                bestMatch = p
                break 
            end
        end

        if bestMatch then
            _G.CrypticTarget = bestMatch
            -- تحديث النص ليظهر الاسم الكامل والاسم المستعار
            InputField.SetText(bestMatch.DisplayName .. " (@" .. bestMatch.Name .. ")")
            UI:Notify("🎯 تم تحديد الهدف للرفع: " .. bestMatch.DisplayName)
        else
            _G.CrypticTarget = nil
            UI:Notify("❌ لم يتم العثور على اللاعب")
        end
    end)

    -- 2. زر تفعيل الرفع الحقيقي
    Tab:AddToggle("🛌 تفعيل الرفع الحقيقي (Carry)", function(active)
        isCarrying = active
        liftHeight = 0
        
        if active then
            if not _G.CrypticTarget or not _G.CrypticTarget.Character then
                isCarrying = false
                UI:Notify("⚠️ حدد لاعباً أولاً من الخانة أعلاه!")
                return
            end
            UI:Notify("✨ بدأ الرفع الحقيقي لـ " .. _G.CrypticTarget.DisplayName)
        else
            UI:Notify("❌ توقف الرفع")
        end
    end)

    -- المحرك الفيزيائي للرفع (FE Synchronization)
    runService.Heartbeat:Connect(function()
        if not isCarrying or not _G.CrypticTarget then return end
        
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local targetChar = _G.CrypticTarget.Character
        local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")

        if root and targetRoot then
            -- تفعيل Noclip لشخصيتك لتجنب التصادمات
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end

            -- زيادة الارتفاع "شوي بشوي"
            liftHeight = liftHeight + liftSpeed
            
            -- [[ سر الرفع الحقيقي ]]
            -- نستخدم Velocity لإجبار سيرفر روبلوكس على قبول إحداثيات اللاعب الجديدة
            targetRoot.Velocity = Vector3.new(0, 15, 0) 
            
            -- وضع شخصيتك تحت الهدف لتظهر كأنك "أنت" من ترفعه
            local targetPos = targetRoot.Position
            root.CFrame = CFrame.new(targetPos.X, targetPos.Y - 3.5 + liftHeight, targetPos.Z)

            -- تثبيت الهدف بوضعية النوم فوقك
            targetRoot.CFrame = root.CFrame * CFrame.new(0, 3.5, 0) * CFrame.Angles(math.rad(90), 0, 0)
        end
    end)
end
