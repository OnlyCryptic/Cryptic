-- [[ Cryptic Hub - خدعة حمل اللاعبين ]]
-- المطور: Cryptic | الميزات: حمل الخصم، طيران بطيء، وضعية النوم، Noclip

return function(Tab, UI)
    local runService = game:GetService("RunService")
    local players = game:GetService("Players")
    local lp = players.LocalPlayer
    
    local isCarrying = false
    local liftHeight = 0
    local liftSpeed = 0.1 -- سرعة الرفع البطيء

    Tab:AddToggle("🛌 حمل اللاعب (Carry & Lift)", function(active)
        isCarrying = active
        liftHeight = 0 -- إعادة ضبط الارتفاع عند كل تفعيل
        
        if active then
            -- التأكد من وجود هدف مختار (يعتمد على ملف target_select)
            if not _G.TargetPlayer or not players:FindFirstChild(_G.TargetPlayer) then
                isCarrying = false
                UI:Notify("⚠️ الرجاء اختيار لاعب أولاً من قسم الاستهداف!")
                return
            end
            UI:Notify("✨ جاري حمل " .. _G.TargetPlayer .. " ورفعه ببطء...")
        else
            UI:Notify("❌ تم إيقاف عملية الحمل")
        end
    end)

    runService.Heartbeat:Connect(function()
        if not isCarrying then return end
        
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local targetPlr = players:FindFirstChild(_G.TargetPlayer)
        local targetChar = targetPlr and targetPlr.Character
        local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")

        if root and targetRoot then
            -- 1. تفعيل Noclip و Anti-Fling لشخصيتك
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                    part.Velocity = Vector3.new(0, 0, 0)
                end
            end

            -- 2. زيادة الارتفاع ببطء (الطيران البطيء)
            liftHeight = liftHeight + liftSpeed
            
            -- 3. وضع شخصيتك تحت اللاعب المستهدف بالضبط
            -- شخصيتك ستكون تحت الهدف بمقدار 3 مسامير وتصعد معه
            local basePos = targetRoot.Position
            root.CFrame = CFrame.new(basePos.X, basePos.Y - 3 + liftHeight, basePos.Z)

            -- 4. جعل الخصم يبدو كأنه نائم (تدوير 90 درجة) وحمله فوقك
            targetRoot.CFrame = root.CFrame * CFrame.new(0, 3, 0) * CFrame.Angles(math.rad(90), 0, 0)
            targetRoot.Velocity = Vector3.new(0, 0, 0) -- منعه من الحركة أو السقوط
        end
    end)
end
