-- [[ Arwa Hub - ميزة تطيير اللاعبين بالمشي (Walk Fling) ]]
-- المطور: Arwa | الميزات: تطيير صامت، حماية شخصية، إخفاء الدوران

return function(Tab, UI)
    local runService = game:GetService("RunService")
    local lp = game.Players.LocalPlayer
    local isWalkFling = false

    Tab:AddToggle("🌪️ تطيير اللاعبين (Walk Fling)", function(active)
        isWalkFling = active
        if active then
            UI:Notify("✅ تم تفعيل Walk Fling. فقط اقتربي من أي لاعب!")
        else
            UI:Notify("❌ تم إيقاف التطيير")
        end
    end)

    -- الملحوظة التي طلبتِها
    Tab:AddParagraph("📝 ملحوظة: لا تحتاجي للضغط على أي شيء، فقط المسيهم وسيطيرون فوراً.")

    runService.Heartbeat:Connect(function()
        if isWalkFling and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            local root = lp.Character.HumanoidRootPart
            
            -- إلغاء التصادم لضمان عدم تعثركِ أثناء التطيير
            for _, part in pairs(lp.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end

            -- تطبيق قوة دفع مخفية (Velocity)
            -- نستخدم قوة دوران هائلة لكن في اتجاه واحد لكي لا تظهر الشخصية وهي تهتز
            root.Velocity = Vector3.new(0, 30, 0) -- رفعة خفيفة جداً
            root.RotVelocity = Vector3.new(0, 20000, 0) -- قوة تطيير جبارة عند التلامس
        end
    end)
end
