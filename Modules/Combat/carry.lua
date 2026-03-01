-- [[ Cryptic Hub - الرفع الفيزيائي الحقيقي (FE Elevator) ]]
-- المطور: Cryptic | التحديث: رفع يعتمد على فيزياء شخصيتك فقط لكي يراه السيرفر بالكامل

return function(Tab, UI)
    local runService = game:GetService("RunService")
    local players = game:GetService("Players")
    local lp = players.LocalPlayer
    
    local isCarrying = false
    local liftSpeed = 8 -- سرعة الرفع الفيزيائية للأعلى (قوة الدفع)

    -- 1. نظام البحث الذكي (نفس النظام المعتمد)
    local InputField = Tab:AddInput("البحث عن لاعب", "اكتب اليوزر وأغلق الكيبورد...", function() end)

    InputField.TextBox.FocusLost:Connect(function()
        local txt = InputField.TextBox.Text
        if txt == "" then _G.CrypticTarget = nil return end
        local bestMatch = nil
        local search = txt:lower()

        for _, p in pairs(players:GetPlayers()) do
            if p ~= lp and string.sub(p.Name:lower(), 1, #search) == search then
                bestMatch = p
                break 
            end
        end

        if bestMatch then
            _G.CrypticTarget = bestMatch
            InputField.SetText(bestMatch.DisplayName .. " (@" .. bestMatch.Name .. ")")
            UI:Notify("🎯 تم قفل الهدف: " .. bestMatch.DisplayName)
        else
            _G.CrypticTarget = nil
            UI:Notify("❌ لم يتم العثور على اللاعب")
        end
    end)

    -- 2. التفعيل
    Tab:AddToggle("🛌 رفع فيزيائي للسيرفر (FE Elevator)", function(active)
        isCarrying = active
        local char = lp.Character
        
        if active then
            if not _G.CrypticTarget or not _G.CrypticTarget.Character then
                isCarrying = false
                UI:Notify("⚠️ حدد لاعباً أولاً!")
                return
            end
            UI:Notify("🚀 شخصيتك الآن تعمل كمصعد فيزيائي تحت الهدف...")
            
            -- إعداد شخصيتك لتكون منصة (إيقاف الحركة العادية لمنع السقوط)
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.PlatformStand = true end
            end
        else
            -- إعادة الشخصية لوضعها الطبيعي عند الإيقاف
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.PlatformStand = false end
            end
            UI:Notify("❌ تم إيقاف الرفع الفيزيائي")
        end
    end)

    -- 3. المحرك الفيزيائي (السر هنا: لا نلمس إحداثيات الخصم أبداً)
    runService.Heartbeat:Connect(function()
        if not isCarrying or not _G.CrypticTarget then return end
        
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local targetChar = _G.CrypticTarget.Character
        local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")

        if root and targetRoot then
            -- 1. جعل أجزاء شخصيتك صلبة ليقف عليها الخصم
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                    part.Massless = true -- تقليل وزن شخصيتك لعدم إعاقة الرفع
                end
            end

            -- 2. جلب موقع الخصم الحالي
            local tPos = targetRoot.Position
            
            -- 3. تتبع الخصم في المحورين X و Z فقط (أنت دائماً تحته)
            -- لا نغير الـ Y بـ CFrame حتى لا نكسر الفيزياء
            root.CFrame = CFrame.new(tPos.X, root.Position.Y, tPos.Z)
            
            -- 4. استخدام قوة الدفع (Velocity) لشخصيتك للأعلى
            -- السيرفر سيقرأ أن شخصيتك ترتفع، وبما أن الخصم فوقك، سيرتفع معك غصباً عنه
            root.Velocity = Vector3.new(0, liftSpeed, 0)
            
            -- لمنع شخصيتك من الدوران أو السقوط
            root.RotVelocity = Vector3.new(0, 0, 0)
        end
    end)
end
