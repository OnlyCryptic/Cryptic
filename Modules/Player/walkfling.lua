-- [[ Arwa Hub - ميزة الإعصار (Spin Fling) مع Anti-Fling ]]
-- المطور: Arwa | المظهر: دوران مستمر | الميزة: تطيير + حماية مطلقة

return function(Tab, UI)
    local runService = game:GetService("RunService")
    local lp = game.Players.LocalPlayer
    local isSpinFling = false
    local spinSpeed = 25 -- سرعة الدوران المرئي

    Tab:AddToggle("🌪️ إعصار التطيير (Spin Fling)", function(active)
        isSpinFling = active
        if active then
            UI:Notify("✅ تم تفعيل الإعصار والحماية! يمكنك المشي والدوران الآن")
        else
            UI:Notify("❌ تم إيقاف الإعصار")
        end
    end)

    Tab:AddParagraph("📝 ملاحقة: ستدور شخصيتك باستمرار سواء كنتِ واقفة أو تمشين، وأي لاعب تلمسينه سيطير.")

    runService.Heartbeat:Connect(function()
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")

        if isSpinFling and root and hum then
            -- 1. نظام الـ Anti-Fling (حماية شخصيتك)
            -- جعل كل أجزاء جسمك لا تصطدم بأحد لكي لا يتم تطييرك
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                    -- تصفير السرعة الخطية لمنع تراكم قوة التطيير ضدك
                    part.Velocity = Vector3.new(0, 0, 0) 
                end
            end

            -- 2. الدوران المرئي (يجعلك تدورين وأنت واقفة أو تمشين)
            -- نغير زاوية الجسم فقط دون التأثير على موقعك
            root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(spinSpeed), 0)

            -- 3. قوة التطيير الفيزيائية (RotVelocity)
            -- هذه القوة هي المسؤولة عن تطيير الخصوم فور التلامس
            root.RotVelocity = Vector3.new(0, 50000, 0) -- قوة جبارة
            
            -- ضمان بقاءك على الأرض بشكل طبيعي أثناء المشي
            root.Velocity = Vector3.new(root.Velocity.X, -2, root.Velocity.Z)
        end
    end)
end
