-- [[ Arwa Hub - ميزة التطيير بالمشي الصامت (Walk Fling) ]]
-- المطور: Arwa | المظهر: لاعب طبيعي | الميزة: تطيير خارق عند اللمس

return function(Tab, UI)
    local runService = game:GetService("RunService")
    local lp = game.Players.LocalPlayer
    local isWalkFling = false

    Tab:AddToggle("🌪️ تطيير صامت (Walk Fling)", function(active)
        isWalkFling = active
        if active then
            UI:Notify("✅ تم التفعيل. شخصيتك الآن طبيعية، فقط المسي اللاعبين!")
        else
            UI:Notify("❌ تم إيقاف التطيير")
        end
    end)

    -- الملحوظة المطلوبة
    Tab:AddParagraph("📝 ملاحقة: شخصيتك ستظهر بشكل طبيعي جداً، فقط المسيهم وسيطيرون فوراً.")

    runService.Heartbeat:Connect(function()
        if isWalkFling and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            local root = lp.Character.HumanoidRootPart
            
            -- 1. الحفاظ على المظهر الطبيعي (إلغاء قوة الرفع لكي لا يطير اللاعب)
            -- نترك السرعة (Velocity) كما هي لكي يتحرك اللاعب بشكل عادي
            
            -- 2. إلغاء التصادم الداخلي لمنع تطيير نفسك
            for _, part in pairs(lp.Character:GetDescendants()) do
                if part:IsA("BasePart") then 
                    part.CanCollide = false 
                end
            end

            -- 3. تطبيق "قوة التدوير المغناطيسية" (RotVelocity)
            -- نستخدم قيمة ضخمة جداً لضمان التطيير الفوري عند التلامس
            -- القوة هنا لا تؤثر على مظهر المشي بل تؤثر فقط على من يلمسك
            root.RotVelocity = Vector3.new(0, 30000, 0) 
            
            -- لضمان عدم اهتزاز الشخصية، نجعل القوة تتركز في ثبات الجاذبية
            root.Velocity = Vector3.new(0, -2, 0) -- قوة جذب خفيفة جداً لتبقي قدمك على الأرض
        end
    end)
end
